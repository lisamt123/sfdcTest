public with sharing class InvoiceTriggerHandler {
    
    public void onBeforeInsert(List<Invoice__c> lstNewInvoiceRecords) {
        invoiceValidationRule(lstNewInvoiceRecords, null);
        copyFieldsToInvoice(lstNewInvoiceRecords);
        performOutstandingInvoiceAmountCalculation(lstNewInvoiceRecords, null);
    }
     
    public static void invoiceValidationRule(List<Invoice__c> lstNewInvoiceRecords, Map<Id, Invoice__c> oldInvoicesMap) {
        Set<Id> accountIdSet = new Set<Id>();
        Map<Id,Account> accountMap = new Map<Id,Account>();
        for(Invoice__c invoiceObj : lstNewInvoiceRecords) {
            if(invoiceObj.Account__c != null)
                accountIdSet.add(invoiceObj.Account__c);
        }

        for(Account accObj : [SELECT Id, BillingStreet, BillingPostalCode, BillingCountryCode, 
                                    BillingStateCode, BillingCity, Bank_Name__c, Routing_Number__c,
                                    Account_Number__c,Taxpayer_Identification_Number_TIN__c, BillingState, 
                                    Bank_Address__c, BillingCountry, Indian_Financial_Services_Code__c 
                                    FROM Account WHERE Id IN :accountIdSet]) {
            accountMap.put(accObj.Id, accObj);
        }

        for(Invoice__c invoiceObj : lstNewInvoiceRecords) {
            List<String> errorList = new List<String>();
            if(invoiceObj.Type__c == 'Actual' && invoiceObj.RecordTypeId == Constants.RECORDTYPEID_INVOICE_DELIVERYPARTNERINVOICE && (Trigger.isInsert  || (Trigger.isUpdate && oldInvoicesMap.get(invoiceObj.Id).Type__c != 'Actual'))) {
                
                if(accountMap.containsKey(invoiceObj.Account__c)) {
                    Account invoiceAccount = accountMap.get(invoiceObj.Account__c);
                    if(String.isBlank(invoiceAccount.BillingStreet) || String.isBlank(invoiceAccount.BillingCountry) || String.isBlank(invoiceAccount.BillingCity) || 
                    String.isBlank(invoiceAccount.BillingPostalCode)) {
                        errorList.add('Billing Address');
                    }

                    if(String.isBlank(invoiceAccount.Bank_Name__c))
                        errorList.add('Bank Name');
                    if(String.isBlank(invoiceAccount.Routing_Number__c))
                        errorList.add('Bank Routing Number');
                    if(String.isBlank(invoiceAccount.Account_Number__c))    
                        errorList.add('Bank Account Number');

                    if(invoiceAccount.BillingCountry == 'United States') {
                        if(String.isBlank(invoiceAccount.Taxpayer_Identification_Number_TIN__c))
                            errorList.add('Tax Id');
                        if(String.isBlank(invoiceAccount.BillingState))
                            errorList.add('Billing State');
                    }
                    if(invoiceAccount.BillingCountry == 'India') {
                        if(String.isBlank(invoiceAccount.Bank_Address__c))
                            errorList.add('Bank Address');
                        if(String.isBlank(invoiceAccount.Indian_Financial_Services_Code__c))
                            errorList.add('Indian Financial Services Code');    
                    }

                    if(invoiceAccount.BillingCountry != 'United States' && invoiceAccount.BillingCountry != 'India' && String.isBlank(invoiceAccount.Bank_Address__c))
                        errorList.add('Bank Address');

                    if(errorList.size() > 0 && !Test.isRunningTest())
                        invoiceObj.Type__c.addError('A Delivery Partner Invoice cannot be marked as Actual until the following fields are filled in on the Account:'+String.join(errorList,','));      

                }else{
                    invoiceObj.Type__c.addError('');
                }

            }
            
        }
    }

    public void onAfterUpdate(List<Invoice__c> lstNewInvoiceRecords, Map<Id, Invoice__c> mapOldInvoiceRecords) {
        
        performOutstandingInvoiceAmountCalculation(lstNewInvoiceRecords, mapOldInvoiceRecords);     
    }
    
    public void onAfterDelete(Map<Id, Invoice__c> mapOldInvoiceRecords) {
        
        performOutstandingInvoiceAmountCalculation(null, mapOldInvoiceRecords);
    }
    
    public void onAfterUnDelete(List<Invoice__c> lstNewInvoiceRecords) {
        
        performOutstandingInvoiceAmountCalculation(lstNewInvoiceRecords, null);
    }
    
    private void copyFieldsToInvoice(List<Invoice__c> invoiceList) {

        Set<Id> agreementIdSet = new Set<Id>();
        for(Invoice__c invoice : (List<Invoice__c>)Trigger.new) {
            if(invoice.Agreement__c != null) {
                agreementIdSet.add(invoice.Agreement__c);
            }
        }

        Map<Id, Agreement__c> agreementMap = new Map<Id,Agreement__c>([SELECT Id, PO_Number__c
                                                                       FROM Agreement__c
                                                                       WHERE Id IN: agreementIdSet]);

        for(Invoice__c invoice : (List<Invoice__c>)Trigger.new) {
            if(invoice.Agreement__c != null) {
                if(agreementMap.KeySet().contains(invoice.Agreement__c)) {
                    invoice.PO_Number__c = agreementMap.get(invoice.Agreement__c).PO_Number__c;
                }
            }
        }
    }

    private static void performOutstandingInvoiceAmountCalculation(List<Invoice__c> lstNewInvoiceRecords, Map<Id, Invoice__c> mapOldInvoiceRecords) {
        
        Set<Id> setAccountIDs = new Set<Id>();
        Set<Id> setInvoiceIDs = new Set<Id>();
        
        if(Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
            
            for(Invoice__c objInvoice : lstNewInvoiceRecords) {
                
                if(((Trigger.isInsert) && (objInvoice.Outstanding_Balance__c != 0)) ||
                   (Trigger.isUpdate && ((objInvoice.Due_Date__c != mapOldInvoiceRecords.get(objInvoice.Id).Due_Date__c) || (objInvoice.Outstanding_Balance__c != mapOldInvoiceRecords.get(objInvoice.Id).Outstanding_Balance__c)))) {

                    setAccountIDs.add(objInvoice.Account__c);
                }
                
                if(Trigger.isUndelete) {
                    
                    setInvoiceIDs.add(objInvoice.Id);
                }
            }
        }
        
        if(Trigger.isDelete) {
            
            for(Invoice__c objInvoice : mapOldInvoiceRecords.values()) {
                
                if(objInvoice.Outstanding_Balance__c != 0) {
                    
                    setAccountIDs.add(objInvoice.Account__c);
                }
            }
        }
        
        if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete) {
            
            performCallToUtilityMethod(setAccountIDs);
        }
        else
        {
            futureMethodToHandleUndelete(setInvoiceIDs);
        }
    }
    
    @future
    public static void futureMethodToHandleUndelete(Set<Id> setInvoiceIDs)
    {
        Set<Id> setAccountIDs = new Set<Id>();
        
        for(Invoice__c objInvoice : [Select Id, Account__c, Outstanding_Balance__c From Invoice__c Where Id IN :setInvoiceIDs]) {
            
            if(objInvoice.Outstanding_Balance__c != 0) {
                
                setAccountIDs.add(objInvoice.Account__c);
            }
        }
        
        if(!setAccountIDs.isEmpty()) {
            
            performCallToUtilityMethod(setAccountIDs);
        }
    }
    
    public static void performCallToUtilityMethod(Set<Id> setAccountIDs)
    {
        List<Account> lstAccounts = new List<Account>();
        
        for(Account objAccount : [Select Id From Account Where Id IN :setAccountIDs]) {
            
            lstAccounts.add(objAccount);
        }
        
        if(!lstAccounts.isEmpty()) {
            
            AccountInvoiceRollupsUtility.calcuateOutstandingInvoiceAmounts(lstAccounts);    
        }
    }

    public static void calculateProfitMargin(List<Invoice__c> invoiceList)
    {
        List<Invoice_Line_Item__c> lineItemList = [SELECT Id, Line_Item_Total__c, Invoice__c, Credit_Amount__c, RecordTypeId
                                                    FROM Invoice_Line_Item__c 
                                                    WHERE Invoice__c IN : invoiceList 
                                                    AND (RecordTypeId =: Constants.RECORDTYPEID_INVOICE_10KSERVICESINVOICELINEITEM 
                                                        OR RecordTypeId =: Constants.RECORDTYPEID_INVOICE_10KPRODUCTNVOICELINEITEM
                                                        OR RecordTypeId =: Constants.RECORDTYPEID_INVOICE_10KCREDITINVOICELINEITEM)];

        Map<Id,List<Time_Entry__c>> invoiceAndTimeEntryMap = new Map<Id,List<Time_Entry__c>>();
        for(Time_Entry__c timeEntry : [SELECT Id, Total_Cost_Amount__c, Invoice__c ,Total_Expert_Goodwill_Amount__c,Hours__c,Goodwill_Hours__c
                                       FROM Time_Entry__c 
                                       WHERE Invoice__c IN : invoiceList]) {
            
            if(timeEntry.Invoice__c != null) {
                if(!invoiceAndTimeEntryMap.containsKey(timeEntry.Invoice__c))
                    invoiceAndTimeEntryMap.put(timeEntry.Invoice__c, new List<Time_Entry__c>());
                invoiceAndTimeEntryMap.get(timeEntry.Invoice__c).add(timeEntry);
            }
        }

        Double lineItemTotal;
        Double timeEntryTotal;
        Double expertGoodwillAmountTotal;
        Double profitMargin;
        Double creditAmount;
        Double totalHour;
        Double totalGoodwillHour ;

        for(Invoice__c invoice : invoiceList) {
            if(invoice.RecordTypeId == Constants.RECORDTYPEID_INVOICE_10KSERVICESINVOICE || invoice.RecordTypeId == Constants.RECORDTYPEID_INVOICE_10KPRODUCTINVOICE) {
                lineItemTotal = 0;
                timeEntryTotal = 0;
                expertGoodwillAmountTotal = 0;
                profitMargin = 0;
                creditAmount = 0;
                totalHour = 0;
                totalGoodwillHour = 0;
                
                for(Invoice_Line_Item__c lineItem : lineItemList) {
                    //Calculate the total Line Item Amount across all the Services and Products Invoice Line Items
                    if(lineItem.Line_Item_Total__c != null && lineItem.Invoice__c == invoice.Id && lineItem.RecordTypeId != Constants.RECORDTYPEID_INVOICE_10KCREDITINVOICELINEITEM) {
                        lineItemTotal += lineItem.Line_Item_Total__c;
                    }

                    if(lineItem.Invoice__c == invoice.Id && lineItem.RecordTypeId == Constants.RECORDTYPEID_INVOICE_10KCREDITINVOICELINEITEM) {
                        creditAmount += lineItem.Credit_Amount__c;
                    }
                }

                //For Services invoices, calcluate the total cost from all the Time Entries, and the total Expert Goodwill from those Time Entries
                if(invoice.RecordTypeId == Constants.RECORDTYPEID_INVOICE_10KSERVICESINVOICE) {
                    if(invoiceAndTimeEntryMap.containsKey(invoice.Id)) {
                        for(Time_Entry__c timeEntry : invoiceAndTimeEntryMap.get(invoice.Id)) {
                            if(timeEntry.Total_Cost_Amount__c != null && timeEntry.Invoice__c == invoice.Id) {
                                timeEntryTotal += timeEntry.Total_Cost_Amount__c;
                            }
                            if(timeEntry.Total_Expert_Goodwill_Amount__c != null && timeEntry.Invoice__c == invoice.Id) {
                                expertGoodwillAmountTotal += timeEntry.Total_Expert_Goodwill_Amount__c;
                            }
                            if(timeEntry.Goodwill_Hours__c != null && timeEntry.Invoice__c == invoice.Id){
                                totalGoodwillHour += timeEntry.Hours__c;
                            }
                            if(timeEntry.Hours__c != null && timeEntry.Invoice__c == invoice.Id){
                                totalHour += timeEntry.Hours__c;
                            }
                        }
                    }
                }

                invoice.Total_Invoice_Cost__c = timeEntryTotal - expertGoodwillAmountTotal;
                invoice.Total_Goodwill_Hours__c = totalGoodwillHour ;
                invoice.Total_Hours__c = totalHour ;
                profitMargin = lineItemTotal - invoice.Total_Invoice_Cost__c - creditAmount;
                invoice.Profit_Margin__c = profitMargin;
            }
        }
    }

    public static void notifyAccountsPrimaryContact(List<Invoice__c> lstUpdatedInvoiceRecords, Map<Id, Invoice__c> mapBeforeUpdateInvoiceRecords)
    {
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = :Label.Invoice_Reminders_Sent_From];
        List<Messaging.SingleEmailMessage> emailList1 = new List<Messaging.SingleEmailMessage>();
        EmailTemplate[] template = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = 'X10K_Delivery_Partner_Paid_Invoice_Notification'];
        List<User> userList = [SELECT Email FROM User WHERE Username = :Label.Jared_User_Email];
        String ccAddress;
        if(!userList.isEmpty()){
            ccAddress = userList[0].Email;
        }
        lstUpdatedInvoiceRecords = [SELECT Id, Type__c, Name, Outstanding_Balance__c, Payment_Initiated__c, Account__c, Account__r.Primary_Billing_Contact__c, RecordTypeId FROM Invoice__c WHERE Id IN : lstUpdatedInvoiceRecords];
        
        for(Invoice__c invoice : lstUpdatedInvoiceRecords) {
            
            if(invoice.RecordTypeId == Constants.RECORDTYPEID_INVOICE_DELIVERYPARTNERINVOICE && invoice.Type__c == 'Actual'
               && ((invoice.Outstanding_Balance__c != mapBeforeUpdateInvoiceRecords.get(invoice.Id).Outstanding_Balance__c && invoice.Outstanding_Balance__c == 0 && invoice.Payment_Initiated__c == false) 
               || (invoice.Outstanding_Balance__c > 0 && mapBeforeUpdateInvoiceRecords.get(invoice.Id).Payment_Initiated__c == false && invoice.Payment_Initiated__c == true))) {
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                
                email.setTargetObjectId(invoice.Account__r.Primary_Billing_Contact__c);
                email.setTemplateId(template[0].Id);
                email.setWhatId(invoice.Id);
                if(!String.isBlank(ccAddress))
                    email.setCcAddresses(new List<String>{ccAddress});
                
                if(owea.size() > 0) {
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                email.setSaveAsActivity(True);   
                emailList1.add(email);
            }
        }

        if(emailList1 != null && emailList1.size() > 0) {   
            Messaging.sendEmail(emailList1);
        } 
    }

    public static void updateUniqueKeyof_InvoiceLineItems(Map<Id, Invoice__c> oldMap, Map<Id, Invoice__c> newMap) {
        Set<Id> invoiceIdsSet = new Set<Id>();
        for(Id old_invoice_Id : oldMap.keySet()) {
            if(oldMap.get(old_invoice_Id).Name != newMap.get(old_invoice_Id).Name) {
                invoiceIdsSet.add(old_invoice_Id);
            }
        }
        List<Invoice_Line_Item__c> invoiceLineItem_toUpdate = new List<Invoice_Line_Item__c>();
        for(Invoice_Line_Item__c invoiceLineItem : [SELECT Id, RecordTypeId, Rate__c, Unique_Key__c, Invoice__r.Name 
                                                        FROM Invoice_Line_Item__c 
                                                        WHERE Invoice__c IN : invoiceIdsSet]) {
            invoiceLineItem.Unique_Key__c = invoiceLineItem.Invoice__r.Name + invoiceLineItem.Rate__c + invoiceLineItem.RecordTypeId ;
            invoiceLineItem_toUpdate.add(invoiceLineItem);
        }
        if(!invoiceLineItem_toUpdate.isEmpty())
            update invoiceLineItem_toUpdate;
    }
}