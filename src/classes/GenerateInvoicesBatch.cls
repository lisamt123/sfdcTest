global class GenerateInvoicesBatch implements Database.Batchable<sObject> {

    String query = 'SELECT Id FROM Agreement__c WHERE RecordTypeId != \'' + Constants.RECORDTYPEID_AGREEMENT_DELIVERYPARTER + '\'';
    
    public Boolean lastMonth = false;                   
    
    global GenerateInvoicesBatch() {}
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Agreement__c> startingAgreementList) {
        
        Set<Id> startingAgreementIdSet = new Set<Id>();
        for(Agreement__c agreement : startingAgreementList) {
            startingAgreementIdSet.add(agreement.Id);
        }

        List<Agreement__c> agreementList = new List<Agreement__c>();
        for(Agreement__c agreement : [SELECT Id, Name, Account__c, Account__r.Name, RecordTypeId, Payment_Terms__c, Rate_Structure__c, 
                                             Account__r.Billing_Code__c, Effective_Date__c, Valid_Through__c, Retainer_Overage_Behavior__c,
                                             Account__r.Most_Recent_Billing_Period_End_Date__c,
                                             (SELECT Id, Agreement__c, Assignment_Type__c, Monthly_Rate__c, Number_of_Months__c, Role__c, Region__c, 
                                                     Hourly_Rate__c, Hours_Per_Month__c, Number_of_Weeks__c, Hours_Per_Week__c, Weekly_Rate__c 
                                              FROM Rates__r)
                                      FROM Agreement__c 
                                      WHERE Id IN: startingAgreementIdSet]) {
            agreementList.add(agreement);
        }
        Map<Id,List<Project_Agreement__c>> projectAgreementMap = new Map<Id,List<Project_Agreement__c>>();
        for(Project_Agreement__c projectAgreement : [SELECT Id, Agreement__c, Project__c 
                                                    FROM Project_Agreement__c 
                                                    WHERE Agreement__c IN: startingAgreementIdSet
                                                        AND Project__r.Invoiced_Separately__c = false
                                                        AND Project__r.Internal__c = false]) {
            if(!projectAgreementMap.containsKey(projectAgreement.Agreement__c))
                projectAgreementMap.put(projectAgreement.Agreement__c,new List<Project_Agreement__c>());
            projectAgreementMap.get(projectAgreement.Agreement__c).add(projectAgreement);
        }

        if(!agreementList.isEmpty()) {
            Boolean chargeForOverages;
            String selectedDateTimeDisplay;
            Integer numberOfWeeks;
            Date periodStartDate;
            Date periodEndDate;
            Date invoiceGeneratedOn;
            //Date dueDate;
            Id selectedAgreementId;
            Boolean isMonthly                                   = false;
            Map<String, Rate__c> agreementRateMap               = new Map<String, Rate__c>();
            List<Invoice_Line_Item__c> invoiceLineItemList      = new List<Invoice_Line_Item__c>();
            Set<Id> projectIdSet                                = new Set<Id>();
            List<Time_Entry__c> timeEntryList                   = new List<Time_Entry__c>();
            List<Assignment__c> assignmentsWithoutValidRates    = new List<Assignment__c>();
            String selectedProject                              = 'All';
            Boolean validRecordType                             = true;
            String mapKey                                       = '';
            String recordTypeId                                 = Constants.RECORDTYPEID_AGREEMENT_RETAINER;
            Agreement__c agreement                              = agreementList[0];

            selectedAgreementId = agreement.Id;
            chargeForOverages = (agreement.Retainer_Overage_Behavior__c == 'No Extra Charge') ? false : true;
            if(projectAgreementMap.keySet().size() == 0) {
                validRecordType = false;
            }
            if(agreement.Account__r.Billing_Code__c == null || agreement.Account__r.Billing_Code__c == '') {
                validRecordType = false;
            }
            if(agreement.Payment_Terms__c == null || agreement.Payment_Terms__c == '') {
                validRecordType = false;
            }
            if(agreement.Rate_Structure__c == 'Monthly') {
                isMonthly = true;
            }
            if(validRecordType) {
                //Build up a set of Ids of all the Projects that are tied to this Agreement
                for(Project_Agreement__c projAgree : projectAgreementMap.get(agreement.Id)) {
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

                if((agreement.Rate_Structure__c == 'Monthly' && agreement.RecordTypeId == recordTypeId) || agreement.RecordTypeId != recordTypeId) {
                    Date currentDate    = lastMonth ? Date.today().addMonths(-1) : Date.today();
                    periodStartDate     = Date.newInstance(currentDate.year(), currentDate.month(), 1);
                    periodEndDate       = Date.newInstance(currentDate.year(), currentDate.month()+1, 1)-1;

                    invoiceGeneratedOn = lastMonth ? Date.newInstance(Date.today().year(), Date.today().month(), 1) : Date.newInstance(Date.today().year(), Date.today().month() + 1, 1);

                    Datetime selectedDateTime   = Datetime.newInstance(currentDate.year(), currentDate.month(), 1);
                    selectedDateTimeDisplay     = selectedDateTime.format('MMyyyy');
                }
                else if(agreement.Rate_Structure__c == 'Weekly' && agreement.RecordTypeId == recordTypeId){
                    Date currentDate    = lastMonth ? agreement.Account__r.Most_Recent_Billing_Period_End_Date__c.addDays(-27) : agreement.Account__r.Most_Recent_Billing_Period_End_Date__c.addDays(1);
                    periodStartDate     = currentDate;
                    periodEndDate       = currentDate.addDays(27);

                    invoiceGeneratedOn = Date.newInstance(periodEndDate.year(), periodEndDate.month(), 1);

                    Datetime selectedDateTime   = Datetime.newInstance(periodStartDate.year(),periodStartDate.month(),periodStartDate.day());
                    selectedDateTimeDisplay     = selectedDateTime.format('MMddyyyy');

                    numberOfWeeks = (periodStartDate.daysBetween(periodEndDate) / 7) + 1;
                }

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
                
                //dueDate = invoiceGeneratedOn.addDays(Integer.valueOf(agreement.Payment_Terms__c.split(' ')[1]));

                if(invoiceLineItemList.size() > 0)
                {
                  //Initialize the Invoice header
                    Invoice__c invoice                      = new Invoice__c();
                    invoice.RecordTypeId                    = Constants.RECORDTYPEID_INVOICE_10KSERVICESINVOICE;
                    invoice.Name                            = '10K-';
                    invoice.Name                            += agreement.Account__r.Billing_Code__c + '-';
                    invoice.Name                            += selectedDateTimeDisplay;
                    invoice.Account__c                      = agreement.Account__c;
                    invoice.Agreement__c                    = agreement.Id;
                    invoice.Billing_Period_Start_Date__c    = periodStartDate;
                    invoice.Billing_Period_End_Date__c      = periodEndDate;
                    invoice.Type__c                         = 'Draft';
                    invoice.Invoice_Generated_On__c         = invoiceGeneratedOn;
                    //invoice.Due_Date__c                     = dueDate;

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
                    List<Invoice__c> invoiceList = [SELECT Id , Name FROM Invoice__c WHERE Name =: invoice.Name AND Type__c = 'Draft' LIMIT 1];
                    if(invoiceList.size() > 0 ){
                        invoice.Id = invoiceList[0].Id;
                    }
                    if(lastMonth && invoiceList.size() > 0){
                        PageReference newInvoice = InvoiceCreationUtility.saveInvoiceAndLineItems(invoice,invoiceLineItemList,timeEntryList,false);
                    }
                    else if (!lastMonth) {
                        PageReference newInvoice = InvoiceCreationUtility.saveInvoiceAndLineItems(invoice,invoiceLineItemList,timeEntryList,false);
                    }
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {

        //Automatically start the next job in the series of Invoicing jobs
        GenerateDeliveryPartnerInvoicesBatch deliveryPartnerInvoiceBatch = new GenerateDeliveryPartnerInvoicesBatch();

        //If this job was run with lastMonth = TRUE, the next step is to run the regular Invoice Batch for the prior month
        if(lastMonth) {
            deliveryPartnerInvoiceBatch.lastMonth = true;
            ChainedBatchId__c batchIds = ChainedBatchId__c.getOrgDefaults();
            if(!Test.isRunningTest())
                batchIds.ThirdBatch_Id__c = Database.executeBatch(deliveryPartnerInvoiceBatch, 1);
            upsert batchIds;
        }
        //If however the job was run for the current month, there next steps is to run the regular Invoice Batch for the current month
        else {
            deliveryPartnerInvoiceBatch.lastMonth = false;
            ChainedBatchId__c batchIds = ChainedBatchId__c.getOrgDefaults();
            if(!Test.isRunningTest())
                batchIds.SixthBatch_Id__c = Database.executeBatch(deliveryPartnerInvoiceBatch, 1);
            upsert batchIds;
        }
    }
}