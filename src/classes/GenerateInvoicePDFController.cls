public without sharing class GenerateInvoicePDFController {

    public List<Invoice_Line_Item__c> invoiceLineItemList{get;set;} 
    
    public Boolean displaySection {get; set;}
    public Boolean isProductInvoice {get; set;}

    private String invoiceId;
    
    public List<LightningReportGenerationController.ProjectWrapper> allData {get; set;}
    public Map<String,Invoice_Line_Item__c> invoiceLineItemMap {get;set;}

    public String strConcatenatedProjectNames;
    public String strDisplayProjectNames {get;set;}
    public String strBillableStartDate {get;set;}
    public String strBillableEndDate {get;set;}
    
    public String accountName {get;set;} 
    public String addressLine1 {get;set;} 
    public String addressLine2 {get;set;} 
    public String addressLine3 {get;set;} 
    public date billingPeriodForRegion {get;set;}
    
    
    public GenerateInvoicePDFController(ApexPages.StandardController controller) {
        
        system.debug(LoggingLevel.INFO, 'Entering the GenerateInvoicePDFController constructor!');
        billingPeriodForRegion = Date.newInstance(2018,03,01);
        displaySection = false;
        invoiceLineItemMap = new Map<String,Invoice_Line_Item__c>();
        invoiceId = ApexPages.currentPage().getParameters().get('Id');
        String invoiceName = ((Invoice__c)controller.getRecord()).Name; 
        
        strBillableStartDate = String.valueOf(((Invoice__c)controller.getRecord()).Billing_Period_Start_Date__c);
        strBillableEndDate = String.valueOf(((Invoice__c)controller.getRecord()).Billing_Period_End_Date__c);
        
        List<Invoice__c> invoiceList = [SELECT Id, RecordTypeId, Agreement__c, Account__r.BillingStreet, Account__r.BillingCity, Account__r.Name, 
                                               Account__r.BillingState, Account__r.BillingPostalCode, Account__r.BillingCountry, Due_Date__c, 
                                               Sent_To_Customer_On__c, Billing_Period_Start_Date__c, Billing_Period_End_Date__c,
                                               Agreement__r.Invoice_Branding__c
                                        FROM Invoice__c 
                                        WHERE Id =: invoiceId];
        
        isProductInvoice = false;

        if(invoiceList != null && !invoiceList.isEmpty()) {
            
            accountName = invoiceList[0].Account__r.Name;

            addressLine1 = !String.isBlank(invoiceList[0].Account__r.BillingStreet) ? ' ' + invoiceList[0].Account__r.BillingStreet : '';
            
            addressLine2 = !String.isBlank(invoiceList[0].Account__r.BillingCity) ? invoiceList[0].Account__r.BillingCity : '';
            addressLine2 += !String.isBlank(invoiceList[0].Account__r.BillingState) ? '  ' + invoiceList[0].Account__r.BillingState : '';
            addressLine2 +=!String.isBlank(invoiceList[0].Account__r.BillingPostalCode ) ? '  ' + invoiceList[0].Account__r.BillingPostalCode : '';
            
            addressLine3 = !String.isBlank(invoiceList[0].Account__r.BillingCountry) ? invoiceList[0].Account__r.BillingCountry : '';

            if(invoiceList[0].RecordTypeId == Constants.RECORDTYPEID_INVOICE_10KPRODUCTINVOICE) {
                isProductInvoice = true;
            }
        }
        
        strConcatenatedProjectNames = '';
        strDisplayProjectNames = '';
        
        //Extract all non-Goodwill Invoice Line Items.
        invoiceLineItemList = [SELECT Id, Name, Rate__r.Role__c,Rate__r.Assignment_Type__c,Rate__r.Region__c,Rate__r.Hourly_Rate__c, Hours__c, Line_Item_Total__c, Hourly_Rate_Text__c, 
                                      Billable_Hours_Total__c, Rate__r.Name, Rate__r.Monthly_Rate__c, Monthly_Rate_Text__c, Named_Resource__c, 
                                      Trimmed_Rate_Name__c, Goodwill_Amount__c, Invoice__r.Name, Invoice__r.PO_Number__c, Credit_Amount__c, 
                                      Invoice__r.Billing_Period_Start_Date__c, Invoice__r.Billing_Period_End_Date__c, RecordType.Name, 
                                      Invoice__r.Account__r.Name, Invoice__r.Agreement__r.Billing_Contact__r.Name, Product__c,
                                      Invoice__r.Account__r.BillingStreet, Invoice__r.Account__r.BillingCity, Product__r.Name,
                                      Invoice__r.Account__r.BillingPostalCode, Invoice__r.Account__r.BillingCountry, Expense_Amount__c, 
                                      Expert_Names__c, Invoice__r.Invoice_Generated_On__c, Invoice__r.Account__r.BillingState, Description__c, 
                                      Invoice__r.Expert_Names__c, Invoice__r.Sent_To_Customer_On__c, RecordTypeId, Sales_Price__c, Discount__c  
                               FROM Invoice_Line_Item__c
                               WHERE Invoice__c =: invoiceId
                                   AND (Goodwill_Amount__c = null
                                      OR Goodwill_Amount__c = 0) 
                                  AND RecordTypeId != : Constants.RECORDTYPEID_INVOICE_10KCREDITINVOICELINEITEM 
                                  AND RecordTypeId != : Constants.RECORDTYPEID_INVOICE_10KEXPENSEINVOICELINEITEM 
                               ORDER BY Rate__r.Name ASC,
                                        Line_Item_Total__c DESC];

    system.debug(invoiceLineItemList.size());

    //Add the Goodwill Invoice Line Items to the end of the list
    invoiceLineItemList.addAll([SELECT Id, Name, Rate__r.Role__c,Rate__r.Assignment_Type__c,Rate__r.Region__c,Rate__r.Hourly_Rate__c, Hours__c, Line_Item_Total__c, Hourly_Rate_Text__c, 
                                         Billable_Hours_Total__c,  Rate__r.Name, Rate__r.Monthly_Rate__c, Monthly_Rate_Text__c, Named_Resource__c, 
                                         Trimmed_Rate_Name__c, Goodwill_Amount__c, Invoice__r.Name, Invoice__r.PO_Number__c,
                                         Invoice__r.Billing_Period_Start_Date__c, Invoice__r.Billing_Period_End_Date__c, Credit_Amount__c, 
                                         Invoice__r.Account__r.Name, Invoice__r.Agreement__r.Billing_Contact__r.Name, RecordType.Name, 
                                         Invoice__r.Account__r.BillingStreet, Invoice__r.Sent_To_Customer_On__c, Invoice__r.Account__r.BillingCity, 
                                         Invoice__r.Account__r.BillingPostalCode, Invoice__r.Account__r.BillingCountry, Description__c, 
                                         Expert_Names__c, Invoice__r.Invoice_Generated_On__c, Invoice__r.Account__r.BillingState,
                                         Invoice__r.Expert_Names__c,RecordTypeId, Sales_Price__c, Discount__c, Expense_Amount__c 
                                    FROM Invoice_Line_Item__c
                                    WHERE Invoice__c =: invoiceId
                                      AND (Goodwill_Amount__c != null
                                           AND Goodwill_Amount__c != 0) 
                                      AND RecordTypeId != : Constants.RECORDTYPEID_INVOICE_10KCREDITINVOICELINEITEM 
                                      AND RecordTypeId != : Constants.RECORDTYPEID_INVOICE_10KEXPENSEINVOICELINEITEM 
                                  ORDER BY Rate__r.Name ASC,
                                           Line_Item_Total__c DESC]);
      
      system.debug(invoiceLineItemList.size());

      //Add the Expense Invoice Line Items to the end of the list
    invoiceLineItemList.addAll([SELECT Id, Name, Rate__r.Role__c,Rate__r.Assignment_Type__c,Rate__r.Region__c,Rate__r.Hourly_Rate__c, Hours__c, Line_Item_Total__c, Hourly_Rate_Text__c, 
                                         Billable_Hours_Total__c,  Rate__r.Name, Rate__r.Monthly_Rate__c, Monthly_Rate_Text__c, Named_Resource__c, 
                                         Trimmed_Rate_Name__c, Goodwill_Amount__c, Invoice__r.Name, Invoice__r.PO_Number__c,
                                         Invoice__r.Billing_Period_Start_Date__c, Invoice__r.Billing_Period_End_Date__c, Credit_Amount__c, 
                                         Invoice__r.Account__r.Name, Invoice__r.Agreement__r.Billing_Contact__r.Name, RecordType.Name, 
                                         Invoice__r.Account__r.BillingStreet, Invoice__r.Sent_To_Customer_On__c, Invoice__r.Account__r.BillingCity, 
                                         Invoice__r.Account__r.BillingPostalCode, Invoice__r.Account__r.BillingCountry, Description__c, 
                                         Expert_Names__c, Invoice__r.Invoice_Generated_On__c, Invoice__r.Account__r.BillingState,
                                         Invoice__r.Expert_Names__c,RecordTypeId, Sales_Price__c, Discount__c, Expense_Amount__c 
                                    FROM Invoice_Line_Item__c
                                    WHERE Invoice__c =: invoiceId
                                      AND (Expense_Amount__c  != null
                                           AND Expense_Amount__c  != 0) 
                                      AND RecordTypeId != : Constants.RECORDTYPEID_INVOICE_10KCREDITINVOICELINEITEM
                                  ORDER BY Rate__r.Name ASC,
                                           Line_Item_Total__c DESC]);
      
      system.debug(invoiceLineItemList.size());

      //Add the Credit Invoice Line Items to the end of the list
    invoiceLineItemList.addAll([SELECT Id, Name, Rate__r.Role__c,Rate__r.Assignment_Type__c,Rate__r.Region__c,Rate__r.Hourly_Rate__c, Hours__c, Line_Item_Total__c, Hourly_Rate_Text__c, 
                                         Billable_Hours_Total__c,  Rate__r.Name, Rate__r.Monthly_Rate__c, Monthly_Rate_Text__c, Named_Resource__c, 
                                         Trimmed_Rate_Name__c, Goodwill_Amount__c, Invoice__r.Name, Invoice__r.PO_Number__c,
                                         Invoice__r.Billing_Period_Start_Date__c, Invoice__r.Billing_Period_End_Date__c, Credit_Amount__c, 
                                         Invoice__r.Account__r.Name, Invoice__r.Agreement__r.Billing_Contact__r.Name, RecordType.Name, 
                                         Invoice__r.Account__r.BillingStreet, Invoice__r.Sent_To_Customer_On__c, Invoice__r.Account__r.BillingCity, 
                                         Invoice__r.Account__r.BillingPostalCode, Invoice__r.Account__r.BillingCountry, Description__c, 
                                         Expert_Names__c, Invoice__r.Invoice_Generated_On__c, Invoice__r.Account__r.BillingState,
                                         Invoice__r.Expert_Names__c,RecordTypeId, Sales_Price__c, Discount__c, Expense_Amount__c
                                    FROM Invoice_Line_Item__c
                                    WHERE Invoice__c =: invoiceId
                                      AND (Credit_Amount__c  != null
                                           AND Credit_Amount__c  != 0) 
                                      AND RecordTypeId != : Constants.RECORDTYPEID_INVOICE_10KEXPENSEINVOICELINEITEM
                                  ORDER BY Rate__r.Name ASC,
                                           Line_Item_Total__c DESC]);
      
      system.debug(invoiceLineItemList.size());
      System.debug(invoiceId+'==='+strBillableStartDate+'==='+strBillableEndDate);
      
        /* Created by Trekbin on 19-Aug, 2016 as per the requirement on Task T-0006 [R] */
        //Check if the invoiceId, Billable Period Start Date, Billable Period End Date contains some value, if so then proceed  [R]
        if((invoiceId != null && invoiceId != '') && (strBillableStartDate != null && strBillableStartDate != '') && (strBillableEndDate != null && strBillableEndDate != '')){
            
            //Declare a set to hold the Project names of the TimeEntry records  [R]
            set<String> setProjectNamesToDisplay = new set<String>();
            
            //Iterate over all the TimeEntry records pertaining to that Invoice records in order to fetch project details   [R]
            for(Time_Entry__c objTimeEntry : [Select Id, Name, Assignment__c, Assignment__r.Project__c, Assignment__r.Project__r.Name, Invoice__c From Time_Entry__c Where Invoice__c = :invoiceId]) {
                
                //Proceed if the Time_Entry__c record contains any assignment related project   [R]
                if(objTimeEntry.Assignment__r.Project__c != null) { 
                
                    //Add the Project names pertaining to TimeEntry's  Assignment record into a set [R]
                    setProjectNamesToDisplay.add(objTimeEntry.Assignment__r.Project__r.Name);
                }
            }
            
            //If the set formed above contains any value then proceed   [R]
            if(!setProjectNamesToDisplay.isEmpty()) {
                
                //Set the displaySection to true if time entry records persists
                displaySection = true;
                System.debug(setProjectNamesToDisplay);
                //Iterate over all the project Names from the set and prepare a concatenated string [R]
                for(String strProjectName : setProjectNamesToDisplay) {
                    
                    //Hold the project Names in a string    [R]
                    System.debug(strProjectName);
                    strConcatenatedProjectNames += strProjectName+'#';
                }
                
                //Bind the concatenated string to the page after removing last comma    [R]
                strDisplayProjectNames = strConcatenatedProjectNames.removeEnd('#');
                System.debug(strDisplayProjectNames+'=============='+strConcatenatedProjectNames);
                //Check if the strConcatenatedProjectNames contains any value then proceed  [R]
                if(strConcatenatedProjectNames != null && strConcatenatedProjectNames != '') {  
                    LightningReportGenerationController.invoiceId = invoiceId;
                    //Pass the parameteres to 'LightningReportGenerationController' controller  [R]
                    allData = LightningReportGenerationController.getDefaultValues(strBillableStartDate, strBillableEndDate, strDisplayProjectNames,null);  
                }
            }
        }   
            
      if(invoiceName !=null) {
          ApexPages.currentPage().getHeaders().put('content-disposition', 'inline; filename='+invoiceName+'.pdf');
      }
    }
}