public with sharing class GenerateInvoicesController {
    
    private static final String MISSING_BILLING_CODE = 'The Account for this Agreement is missing a Billing Code. Please provide one on the Account before generating invoices.';
    private static final String MISSING_PAYMENT_TERMS = 'This Agreement is missing Payment Terms. Please select a value in the Payment Terms field on the Agreement before generating invoices.';
    private static final String NO_UNBILLED_TIME_ENTRIES = 'No unbilled Time Entry data was found for this Agreement';
    private static final String MISSING_ASSIGNMENT_RATES = 'One or more Assignments are missing Rates for the selected time period. Resolve this issue and try again.';
    private static final String AGREEMENT_NOT_FOUND = 'Something went wrong looking up the Agreement. Please try launching the page again from the Agreement\'s Generate Invoices button.';
    private static final String MISSING_PROJECT_AGREEMENTS = 'This Agreement is not associated to any Projects. Please relate the Agreement to at least one Project and try again.';

    public String selectedMonth {get; set;}
    public String selectedProject {get; set;}
    public Agreement__c agreement {get; set;}
   
    public List<Assignment__c> assignmentsWithoutValidRates {get; set;}
    public Boolean assignmentsWithoutRates {get; set;}

    //public Map<String, Decimal> rateKeyToHoursCount {get; set;}
    public Map<String, Rate__c> agreementRateMap {get; set;}

    public InvoiceWrapper invoiceWrapper {get; set;}
    public List<Time_Entry__c> timeEntryList {get; set;}
    public List<Invoice_Line_Item__c> invoiceLineItemList {get; set;}
    public Invoice__c invoice {get; set;}
    public String selectedDateTimeDisplay {get; set;}

    public Date agreementStartDate {get; set;}
    public Date agreementEndDate {get; set;}
    public Date earliestTimeEntryDate {get; set;}
    public String earliestDayOfWeek {get; set;}
    public Date periodStartDate {get; set;}
    public Date periodEndDate {get; set;} 
    public String selectedPeriodEndDate {get; set;}
    public Integer numberOfWeeks {get; set;}

    public Boolean validRecordType {get; set;}
    public Boolean monthSelected {get; set;}
    public Boolean projectSelected {get; set;}
    public Boolean periodEndDateSelected {get; set;}
    public Boolean isMonthly {get; set;}
    public Boolean chargeForOverages {get; set;}

    public Map<Id, List<String>> projectToNameAndCodeMap;
    private Map<String, String> monthYearWithUnbilledTimeEntriesMap;

    private Set<String> projectSet;
    
    private Set<Id> projectIdSet;

    private Id selectedAgreementId;

    public GenerateInvoicesController() {
        monthSelected = false;
        projectSelected = false;
        validRecordType = true;
        assignmentsWithoutRates = false;
        isMonthly = false;
        earliestTimeEntryDate = null;
        
        assignmentsWithoutValidRates = new List<Assignment__c>();
        invoiceLineItemList = new List<Invoice_Line_Item__c>();
        timeEntryList = new List<Time_Entry__c>();
        agreementRateMap = new Map<String, Rate__c>();
        projectToNameAndCodeMap = new Map<Id, List<String>>();
        monthYearWithUnbilledTimeEntriesMap = new Map<String, String>();

        projectIdSet = new Set<Id>();
        projectSet = new Set<String>();

        List<Agreement__c> agreementList = new List<Agreement__c>();
        List<String> projectNameAndCodeList = new List<String>();
        Id agreementId = ApexPages.currentPage().getParameters().get('agreementId');
        String mapKey = '';

        //Fetch the Agreement based on the Id parameter that was sent in
        agreementList = [SELECT Id, Name, Account__c, Account__r.Name, RecordTypeId, Payment_Terms__c, Rate_Structure__c,
                                Account__r.Billing_Code__c, Effective_Date__c, Valid_Through__c, Retainer_Overage_Behavior__c,
                                (SELECT Id, Agreement__c, Assignment_Type__c, Monthly_Rate__c, Number_of_Months__c, Role__c, Region__c, 
                                        Hourly_Rate__c, Hours_Per_Month__c, Number_of_Weeks__c, Hours_Per_Week__c, Weekly_Rate__c
                                 FROM Rates__r),
                                (SELECT Id, Agreement__c, Project__c
                                 FROM Project_Agreements__r)
                         FROM Agreement__c
                         WHERE Id =: agreementId];
        
        //Pull the Agreement out of the query set, and if it's not there, present a message to the user
        if(!agreementList.isEmpty()) {
            agreement = agreementList[0];
            selectedAgreementId = agreement.Id;
            chargeForOverages = (agreement.Retainer_Overage_Behavior__c == 'No Extra Charge') ? false : true;
        }
        else {
            validRecordType = false;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, AGREEMENT_NOT_FOUND));
        }

        //@TODO Put up an error message if there are no Project Agreements
        if(agreement.Project_Agreements__r == null || agreement.Project_Agreements__r.size() == 0) {
            validRecordType = false;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, MISSING_PROJECT_AGREEMENTS));
        }
        if(agreement.Account__r.Billing_Code__c == null || agreement.Account__r.Billing_Code__c == '') {
            validRecordType = false;
            //@TODO - Intead, display a way to capture the billing code and updated it at the Account
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, MISSING_BILLING_CODE));
        }
        if(agreement.Payment_Terms__c == null || agreement.Payment_Terms__c == '') {
            validRecordType = false;
            //@TODO - Intead, display a way to capture the payment terms and updated it at the Agreement
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, MISSING_PAYMENT_TERMS));
        }
        
        if(agreement.Rate_Structure__c == 'Monthly') {
            isMonthly = true;
        }

        //If we didn't run into any error conditions, proceed loading the rest of the page
        if(validRecordType) {
            for(Agreement__c agreement : agreementList) {
                //Build up a set of Ids of all the Projects that are tied to this Agreement
                for(Project_Agreement__c projAgree : agreement.Project_Agreements__r) {
                    projectIdSet.add(projAgree.Project__c);
                }
                
                //Build up a map of all the Rates that are tied to this Agreement, keyed with AssignmentType+Role+RecordId
                //@TODO - Will need to update this for date-bound Capacity records
                for(Rate__c rate : agreement.Rates__r) {
                    mapKey = rate.Assignment_Type__c + '@' + rate.Region__c + '@' + rate.Role__c;
                    if(rate.Assignment_Type__c == Constants.ASSIGNMENTTYPE_NAMEDRESOURCE) {
                        mapKey += '@' + rate.Id;
                    }

                    agreementRateMap.put(mapKey, rate);
                }
            }

            //Get all the Time Entries for all the selected Project. We need to determine 1) What billing periods the
            //unbilled time exist in, and 2) a collection of Project Names and Billing Codes
            String monthYearMapKey = '';
            String monthYearMapValue = '';
            DateTime tempDateTime;

            for(Time_Entry__c timeEntry : [SELECT Id, Date__c, Assignment__r.Project__c, Assignment__r.Project__r.Name, 
                                                  Assignment__r.Project__r.Project_Billing_Code__c, Invoice__c
                                           FROM Time_Entry__c
                                           WHERE Assignment__r.Project__c IN: projectIdSet
                                                 AND Invoice__c = null
                                                 AND Assignment__r.Billable__c = true
                                                 AND Assignment__r.Rate__r.Agreement__c =: selectedAgreementId
                                           ORDER BY Date__c DESC]) {
                
                projectNameAndCodeList = new List<String>();
                projectNameAndCodeList.add(timeEntry.Assignment__r.Project__r.Name);
                projectNameAndCodeList.add(timeEntry.Assignment__r.Project__r.Project_Billing_Code__c);
                
                if(!projectToNameAndCodeMap.containsKey(timeEntry.Assignment__r.Project__c)) {
                    projectToNameAndCodeMap.put(timeEntry.Assignment__r.Project__c, projectNameAndCodeList);
                }

                //Build up a unique set of Year/Month combinations in which we have unbilled Time Entry data so we
                //can display the Month picklist correctly
                monthYearMapKey = timeEntry.Date__c.Year() + '-' + timeEntry.Date__c.Month();
                tempDateTime = Datetime.newInstance(timeEntry.Date__c.Year(), timeEntry.Date__c.Month(), timeEntry.Date__c.Day());
                monthYearMapValue = tempDateTime.format('MMMMM') + ' ' + timeEntry.Date__c.Year();
                
                monthYearWithUnbilledTimeEntriesMap.put(monthYearMapKey, monthYearMapValue);

                if(earliestTimeEntryDate == null || earliestTimeEntryDate > timeEntry.Date__c) {
                    earliestTimeEntryDate = timeEntry.Date__c;
                }
            }
            system.debug('earliestTimeEntryDate : ' + earliestTimeEntryDate);

            //If we are on a Weekly Agreement, calculate the Period Start Date and Period End Date Options
            if(!isMonthly) {
                Date tempDate;
                if(earliestTimeEntryDate != null) {
                    DateTime earliestDateTime;
                    tempDate = earliestTimeEntryDate;
                    do {
                        earliestDateTime = DateTime.newInstance(tempDate.Year(), tempDate.Month(), tempDate.Day());
                        earliestDayOfWeek = earliestDateTime.format('EEEE');
                        tempDate = tempDate.addDays(-1);
                    } while(earliestDayOfWeek != 'Monday');
                    
                    periodStartDate = tempDate.addDays(1);

                    agreementStartDate = agreement.Effective_Date__c;
                    agreementEndDate = agreement.Valid_Through__c;
                }
            }

            //Error condition if the Agreement has no unbilled Time Entries associated with it
            if(monthYearWithUnbilledTimeEntriesMap.isEmpty()) {
                validRecordType = false;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, NO_UNBILLED_TIME_ENTRIES));
            }
        }
    }

    //Called when the Month is selected to get all the Projects that have unbilled time, and to calculate the time periods
    public PageReference fetchProjects() {

        //@TODO - Add a warning, or disable the button, if they pick a future or current active month

        //@TODO - Move this into a method we can call to easily reset the page
        projectSelected = false;
        selectedProject = null;
        
        monthSelected = false;
        assignmentsWithoutRates = false;

        if(selectedMonth != null) {
            monthSelected = true;
            setStartAndEndDates();
        }
        else if(selectedPeriodEndDate != null) {
            periodEndDateSelected = true;
            setStartAndEndDates();
        }
        
        //@TODO - Move the calculation of projectToNameAndCodeMap down here, so it's specifically based on the selected date

        return null;
    }

    //Called when the Project is selected to get all the Time Entry data, and do all the math for how to create Invoice Line Items
    public PageReference fetchTimeEntryData() {
        
        invoiceLineItemList = new List<Invoice_Line_Item__c>();
        timeEntryList = new List<Time_Entry__c>();
        projectSelected = false;

        if(selectedProject != null) {
            projectSelected = true;
        }
        
        system.debug('The Agreement Id = ' + selectedAgreementId);

        if(selectedProject != null && (monthSelected || periodEndDateSelected)) {

            /*////////////////////////////////For Loop Replaced need to call utility class method/////////////////////////////////////*/
            Set<Id> agreementIdSet = new Set<Id>{selectedAgreementId};
            String result = InvoiceCreationUtility.generateServicesInvoice( chargeForOverages, 
                                                                                    isMonthly, 
                                                                                    agreementRateMap, 
                                                                                    numberOfWeeks,  
                                                                                    invoiceLineItemList,
                                                                                    periodStartDate,
                                                                                    periodEndDate,
                                                                                    projectIdSet,
                                                                                    agreementIdSet,
                                                                                    timeEntryList,
                                                                                    assignmentsWithoutValidRates,
                                                                                    selectedProject,
                                                                                    false);
            if(result.contains('MISSING_ASSIGNMENT_RATES')){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, MISSING_ASSIGNMENT_RATES));
                assignmentsWithoutRates = true; 
            }
            if(invoiceLineItemList.size() > 0)
            {
                //Initialize the Invoice header
                Invoice__c invoice = new Invoice__c();
                invoice.RecordTypeId = Constants.RECORDTYPEID_INVOICE_10KSERVICESINVOICE;
                invoice.Name = '10K-';

                if(selectedProject == 'All') {
                    invoice.Name += agreement.Account__r.Billing_Code__c + '-';
                }
                else {
                    invoice.Name += projectToNameAndCodeMap.get(selectedProject)[1] + '-';
                }

                invoice.Name += selectedDateTimeDisplay;
                invoice.Account__c = agreement.Account__c;
                invoice.Agreement__c = agreement.Id;
                invoice.Billing_Period_Start_Date__c = periodStartDate;
                invoice.Billing_Period_End_Date__c = periodEndDate;
                invoice.Type__c = 'Actual';
                invoice.Invoice_Generated_On__c = system.today();
                invoice.Due_Date__c = system.today().addDays(Integer.valueOf(agreement.Payment_Terms__c.split(' ')[1]));

                //Set the names of all Resources who billed hours for this Invoice into the Expert_Names__c field on the Invoice
                if(result.split('@').size() > 1)
                    invoice.Expert_Names__c = result.split('@')[1].split('##')[0];
                Decimal invoiceAmount;
                try{

                    invoiceAmount = Decimal.valueOf(result.split('##')[1]);
                }
                catch(Exception ex){
                    invoiceAmount = 0.0;
                }
                invoiceWrapper = new InvoiceWrapper(invoice, invoiceAmount);
            }
        }
        return null;
    }

    /*////////////////////////////////////////Call saveInvoiceAndLineItems Method From Utility Class////////////////////////////////////*/
    public PageReference saveInvoiceAndLineItems()
    {
        
        PageReference newInvoice = InvoiceCreationUtility.saveInvoiceAndLineItems(invoiceWrapper.Invoice,invoiceLineItemList,timeEntryList, false);
        return newInvoice;
    }
    
    //Getter method to calculate a list of selectable Months, dynamically based on the months in which unbilled Time Entries appear for the Agreement
    public List<SelectOption> getMonthOptions() {
        List<SelectOption> monthOptions = new List<SelectOption>();
        monthOptions.add(new SelectOption('','--None--'));
        
        for(String monthYearKey : monthYearWithUnbilledTimeEntriesMap.KeySet()) {
            monthOptions.add(new SelectOption(monthYearKey, monthYearWithUnbilledTimeEntriesMap.get(monthYearKey)));    
        }
        monthOptions.sort();
        return monthOptions;
    }

    //Getter method to calculate a list of selectable Dates, dynamically based on the determined Period Start Date, and the time remaining in the Agreement
    public List<SelectOption> getPeriodEndDateOptions() {
        List<SelectOption> periodEndDateOptions = new List<SelectOption>();
        periodEndDateOptions.add(new SelectOption('','--None--'));
        
        //Set our first End Date option as the Sunday following the Monday that was determined as the Period Start Date
        Date tempEndDate = periodStartDate.addDays(6);
        DateTime tempDateTime;
        do {
            tempDateTime = DateTime.newInstance(tempEndDate.Year(), tempEndDate.Month(), tempEndDate.Day());
            periodEndDateOptions.add(new SelectOption(tempDateTime.format('YYYY-MM-dd'), tempDateTime.format('EEEE MMMM d, yyyy')));
            tempEndDate = tempEndDate.addDays(7);
        } while(tempEndDate <= agreementEndDate);
        
        return periodEndDateOptions;
    }

    //Getter method to calculate a list of Projects for the Agreement, dynamically based on which Projects have unbilled Time Entries
    public List<SelectOption> getProjectOptions() {
        projectSet = new Set<String>();

        List<SelectOption> projectOptions = new List<SelectOption>();
        projectOptions.add(new SelectOption('','--None--'));
        projectOptions.add(new SelectOption('All','All'));

        String projectDisplayName = '';

        for(Id projectId : projectToNameAndCodeMap.KeySet()) {
            if(projectToNameAndCodeMap.get(projectId)[1] != null) {
                projectDisplayName = projectToNameAndCodeMap.get(projectId)[0] + ' (' + projectToNameAndCodeMap.get(projectId)[1] + ')';
                projectOptions.add(new SelectOption(projectId, projectDisplayName));    
            }
        }
        projectOptions.sort();
        return projectOptions;
    }

    //Private helper method to convert the text value of the selected Month & Year, from the picklist, into usable Start and End dates
    private void setStartAndEndDates() {
        
        if(isMonthly) {
            List<String> dateParts = selectedMonth.split('-');
            periodStartDate = Date.newInstance(Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), 1);
            periodEndDate = Date.newInstance(Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1])+1, 1)-1;

            Datetime selectedDateTime = Datetime.newInstance(Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), 1);
            selectedDateTimeDisplay = selectedDateTime.format('MMyyyy');
        }
        else {
            List<String> dateParts = selectedPeriodEndDate.split('-');
            periodEndDate = Date.newInstance(Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), Integer.valueOf(dateParts[2]));

            Datetime selectedDateTime = Datetime.newInstance(Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), Integer.valueOf(dateParts[2]));
            selectedDateTimeDisplay = selectedDateTime.format('MMddyyyy');

            numberOfWeeks = (periodStartDate.daysBetween(periodEndDate) / 7) + 1;
        }
    }

    //Small wrapper class to help with displaying in-memory Invoice details on the UI
    public class InvoiceWrapper {
        public Invoice__c invoice {get; set;}
        public Decimal invoiceAmount {get; set;}

        public InvoiceWrapper(Invoice__c invoice, Decimal invoiceAmount) {
            this.invoice = invoice;
            this.invoiceAmount = invoiceAmount;
        }
    }
}