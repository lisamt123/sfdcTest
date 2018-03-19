global class PastDueInvoiceNotificationBatch implements Database.Batchable<sObject> {
        
    String invoiceRecordType = Constants.RECORDTYPEID_INVOICE_DELIVERYPARTNERINVOICE;
    Date todaysDate = Date.today();
    Map<String, Currency_Code_With_Symbols__c> currencyAndSymbolMap = Currency_Code_With_Symbols__c.getAll();

    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String query = 'SELECT Id FROM Account WHERE Primary_Billing_Contact__c != null';
        return Database.getQueryLocator(query);
    }
  
    global void execute(Database.BatchableContext BC, List<Account> startingScope){
        Map<Id, List<Invoice__c>> invoiceMap = new map<Id,List<Invoice__c>>();
        Map<Id, List<contactWrapp>> accountWrapperMap = new map<Id,List<contactWrapp>>();
        List<Invoice__c> invoiceListExcludedFromPastDueNotification = new List<Invoice__c>();
        
        Set<Id> startingAccountIdSet = new Set<Id>();
        for(Account account : startingScope) {
            startingAccountIdSet.add(account.Id);
        }
        
        List<Account> scope = new List<Account>();
        for(Account account : [SELECT Id, Name, Primary_Billing_Contact__r.Email, Primary_Billing_Contact__r.FirstName, Primary_Billing_Contact__r.LastName, Owner.Email, Owner.Name,
                                    (SELECT Id, Name, Account__c, Due_Date__c, Invoice_Generated_On__c, Total_Invoice_Amount__c, Agreement__r.Billing_Contact__r.Email, Exclude_From_Next_Past_Due_Notification__c, 
                                            Account__r.Primary_Billing_Contact__r.Email, Account__r.Primary_Billing_Contact__r.FirstName, Account__r.Primary_Billing_Contact__r.LastName,
                                            Account__r.Owner.Email, Account__r.Owner.Name, Account__r.Name, Outstanding_Balance__c, Agreement__r.Additional_Invoice_Recipients__c
                                    FROM Invoices__r
                                    WHERE RecordTypeId !=: invoiceRecordType
                                            AND Due_Date__c < : todaysDate
                                            AND Outstanding_Balance__c > 0 ORDER BY Due_Date__c ASC)
                            FROM Account
                            WHERE Id IN: startingAccountIdSet]){
            scope.add(account);
        }

        List<Messaging.SingleEmailMessage> emailList1 = new List<Messaging.SingleEmailMessage>();
        if(scope != null && scope.size() > 0){
            for(Account acc : scope){
                for(Invoice__c invoice: acc.Invoices__r){
                    List<Invoice__c> tempInvoiceList = new List<Invoice__c>();
                    if(invoiceMap.containsKey(acc.Id)){
                        tempInvoiceList = invoiceMap.get(acc.Id);
                    }
                    if(invoice.Exclude_From_Next_Past_Due_Notification__c == FALSE)
                    {
                        tempInvoiceList.add(invoice);
                        invoiceMap.put(acc.Id,tempInvoiceList);
                    }
                    else
                    {
                        invoiceListExcludedFromPastDueNotification.add(invoice);
                    }

                    List<contactWrapp> tempWrapList = new list<contactWrapp>();
                    /*if(accountWrapperMap.containsKey(acc.Primary_Billing_Contact__c)){
                        tempWrapList = accountWrapperMap.get(acc.Id);
                    }*/
                    tempWrapList.add(new contactWrapp(acc.Primary_Billing_Contact__c, acc.Primary_Billing_Contact__r.email,acc.Primary_Billing_Contact__r.FirstName, acc.Primary_Billing_Contact__r.LastName));
                    
                    accountWrapperMap.put(acc.Id,tempWrapList);
                }
            } 
        }
        
        
        if(accountWrapperMap != null && accountWrapperMap.size() > 0 && invoiceMap != null && invoiceMap.size() > 0){

            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = :Label.Invoice_Reminders_Sent_From];
            EmailTemplate[] template = [select id, name from EmailTemplate where developername = 'Invoice_Reminder_Notification'];
            for(string acc: accountWrapperMap.keySet()){
                integer count = 1;
                list<Messaging.EmailFileAttachment> attachmentList =  new list<Messaging.EmailFileAttachment>();
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                if(invoiceMap.get(acc) != null && invoiceMap.get(acc).size() > 0){
                    if(accountWrapperMap.get(acc) != null && accountWrapperMap.get(acc).size() > 0 && invoiceMap.get(acc) != null && invoiceMap.get(acc).size() > 0){
                        string[] toaddress =  new list<string>{accountWrapperMap.get(acc)[0].contactId};
                        Set<String> invoiceRecipients = new Set<String>();
                        for(Invoice__c inv : invoiceMap.get(acc))
                        {
                            if(inv.Agreement__r.Additional_Invoice_Recipients__c != null && inv.Agreement__r.Additional_Invoice_Recipients__c != '')
                            {
                                for(String recipients : inv.Agreement__r.Additional_Invoice_Recipients__c.Split(','))
                                {
                                    if(Pattern.matches('^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$', recipients.trim()))
                                    {
                                        if(recipients.trim() != accountWrapperMap.get(acc)[0].emailList)
                                            invoiceRecipients.add(recipients.trim());
                                        System.debug(recipients.trim());
                                    }
                                }
                            }
                            if(inv.Agreement__r.Billing_Contact__r.Email != null && inv.Agreement__r.Billing_Contact__r.Email != '')
                            {
                                if(inv.Agreement__r.Billing_Contact__r.Email != accountWrapperMap.get(acc)[0].emailList)
                                    invoiceRecipients.add(inv.Agreement__r.Billing_Contact__r.Email);
                            }
                        }
                        System.debug(invoiceRecipients);
                        List<String> ccAddresses = new list<string>{invoiceMap.get(acc)[0].account__r.owner.email};
                        
                        for(invoice__c inv: invoiceMap.get(acc)){
                            
                            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                            attach.setFileName(inv.Name+'.pdf');
                            attach.setInline(false);
                            PageReference pageName = Page.GenerateInvoicePDF;
                            pageName.getParameters().put('id', inv.id);
                            try
                            {
                                attach.Body = pageName.getContentAsPDF();
                            } 
                            catch(exception e)
                            {
                                attach.Body = Blob.valueof('test');
                            }
                            attachmentList.add(attach);
                        }
                        
                        email.setTemplateId(template[0].Id);
                        email.setWhatId(acc);
                        if(toaddress != null && toaddress.size() >0){
                            email.setTargetObjectId(toaddress[0]);
                        }
                        if(invoiceRecipients.size() > 0)
                        {
                            ccAddresses.addAll(invoiceRecipients);
                        }
                        if(ccAddresses != null && ccAddresses.size() >0){
                            email.setCcAddresses(ccAddresses);
                        }
                        if ( owea.size() > 0 ) 
                        {
                            email.setOrgWideEmailAddressId(owea.get(0).Id);
                        }
                        email.setFileAttachments(attachmentList);
                        email.setSaveAsActivity(True);   
                        emailList1.add(email);  
                    } 
                }  
            } 
             
        }
        if(emailList1 != null && emailList1.size() > 0){   
            Messaging.sendEmail(emailList1);
        } 
        if(!invoiceListExcludedFromPastDueNotification.isEmpty())
        {
            for(Invoice__c invoice : invoiceListExcludedFromPastDueNotification)
            {
                invoice.Exclude_From_Next_Past_Due_Notification__c = FALSE;
            }

            update invoiceListExcludedFromPastDueNotification;  
        }
    } 
    
    public class contactWrapp{
        public string contactId;
        public string emailList;
        public string firstName;
        public string lastname; 
        
        public contactWrapp(string conId, string mailId, string conFirstName, string conLastName){
            contactId = conId;
            emailList = mailId;
            firstName = conFirstName;
            lastname = conLastName;
        }
    }   
 
    global void finish(Database.BatchableContext BC){
    }

}