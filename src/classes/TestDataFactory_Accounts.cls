public with sharing class TestDataFactory_Accounts {
    
    public static List<Account> generateAccounts(Id recordTypeId, String name, String accountType, Integer numOfEmpFocusOnSF, String whatTypeHelpLookingFor, String currentUseOf3rdPartyRes,
    														String sfProductUsed, String sfEdition, String partnerType, String requiredSecurityPI, String projectAndRequirementMgmtTool, String preferedMeetingTool, String ifHowtoLogTimeInTheirSystem, 
    														String deliveryStandards, String documentsProvided, String BillingCountry, String BillingStreet, String BillingCity, String BillingState, String BillingPostalCode, String Region,
    														Id primaryBillingContactID, String paymentTerms, String additionalInvoiceRecipients, String billingCode, String customInvoiceEmailTemplate, String invoicingNotes, String accountRecordType,
    														Integer numOfRecords) {
		return generateAccountsInternal(recordTypeId, name, accountType, numOfEmpFocusOnSF, whatTypeHelpLookingFor, currentUseOf3rdPartyRes,
    														sfProductUsed, sfEdition, partnerType, requiredSecurityPI, projectAndRequirementMgmtTool, preferedMeetingTool, ifHowtoLogTimeInTheirSystem, 
    														deliveryStandards, documentsProvided, BillingCountry, BillingStreet, BillingCity, BillingState, BillingPostalCode, Region,
    														primaryBillingContactID, paymentTerms, additionalInvoiceRecipients, billingCode, customInvoiceEmailTemplate, invoicingNotes, accountRecordType,
    														numOfRecords);
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<Account> generateAccountsInternal(Id recordTypeId, String name, String accountType, Integer numOfEmpFocusOnSF, String whatTypeHelpLookingFor, String currentUseOf3rdPartyRes,
    														String sfProductUsed, String sfEdition, String partnerType, String requiredSecurityPI, String projectAndRequirementMgmtTool, String preferedMeetingTool, String ifHowtoLogTimeInTheirSystem, 
    														String deliveryStandards, String documentsProvided, String BillingCountry, String BillingStreet, String BillingCity, String BillingState, String BillingPostalCode, String Region,
    														Id primaryBillingContactID, String paymentTerms, String additionalInvoiceRecipients, String billingCode, String customInvoiceEmailTemplate, String invoicingNotes, String accountRecordType,
    														Integer numOfRecords) {
    	List<Account> accountList = new List<Account>();
        
        for(Integer i = 0; i < numOfRecords; i++) {
			Account acc = new Account();
            acc.Name = name;
            acc.RecordTypeId = recordTypeId;
            acc.Type = accountType;
            acc.Salesforce_Products_Used__c = sfProductUsed;//App Cloud;Sales Cloud
            acc.Salesforce_Edition__c = sfEdition;
            acc.Partner_Type__c = partnerType;
            acc.Num_of_Employees_Focused_on_Salesforce__c = numOfEmpFocusOnSF;
            acc.What_type_of_help_are_you_looking_for__c = whatTypeHelpLookingFor;
            acc.Current_Use_of_3rd_Party_SFDC_Resources__c = currentUseOf3rdPartyRes;
            acc.Required_Security_Personnel_Information__c = requiredSecurityPI;
            acc.Project_And_Requirement_Management_Tools__c = projectAndRequirementMgmtTool;
            acc.Preferred_Meeting_Tool__c = preferedMeetingTool;
            acc.If_How_To_Log_Time_In_Their_System__c = ifHowtoLogTimeInTheirSystem;
            acc.Delivery_Standards__c = deliveryStandards;
            acc.Documentation_Provided__c = documentsProvided;
            acc.BillingCountry = BillingCountry;
            acc.BillingStreet = BillingStreet;
            acc.BillingCity = BillingCity;
            acc.BillingState = BillingState;
            acc.BillingPostalCode = BillingPostalCode;
            //acc.Region__c = Region;
            acc.Region_Picklist__c = Region;
            acc.Primary_Billing_Contact__c = primaryBillingContactID;
            acc.Payment_Terms__c = paymentTerms;
            acc.Additional_Invoice_Recipients__c = additionalInvoiceRecipients;
            acc.Billing_Code__c = billingCode;
            acc.Custom_Invoice_Email_Template__c = customInvoiceEmailTemplate;
            acc.Invoicing_Notes__c = invoicingNotes;
            acc.Account_Record_Type__c = accountRecordType;
            
            /*
            //Other fields 
            acc.Phone = phone;
            acc.Fax = Fax;
            acc.Website = website;
            acc.ParentID = '';
            acc.Account_Status__c
            acc.Industry
            acc.AccountSource
            acc.Signed_NDA__c = false;
            acc.Received_W9__c = false;
            acc.Routing_Number__c
            acc.Taxpayer_Identification_Number_TIN__c
            acc.Account_Number__c
            acc.Bank_Name__c
            acc.Partner_Tier__c
            acc.Description
            acc.Appirio_DSM_Status__c
            acc.X10K_DSM_Status__c
            acc.Appirio_DSM_Expiration_Date__c
            acc.ShippingStreet
            acc.ShippingCountry
            acc.ShippingCity
            acc.ShippingState
            acc.ShippingPostalCode
            acc.TotalOutstandingInvoices0_30DaysOverdue__c
            acc.TotalOutstandingInvoices31_60DaysOverdue__c
            acc.TotalOutstandingInvoices61_90DaysOverdue__c
            acc.TotalOutstandingInvoices_90DaysOverdue__c
            acc.Billing_Frequency__c
            acc.List_Experts_On_Invoices__c
            acc.Include_Timesheet_Summary_on_Invoices__c
            acc.Migration_Id__c
            acc.QuickBooks_Id__c
            */
            accountList.add(acc); 
        }
        
        return AccountList;
    }
}