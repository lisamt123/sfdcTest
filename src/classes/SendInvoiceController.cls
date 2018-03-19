global class SendInvoiceController {

    public static final String MISSING_AGREEMENT                        = 'No Agreement exists for this Invoice';
    public static final String MISSING_BILLING_CONTACT                  = 'The Agreement for this Invoice is missing a Billing Contact';
    public static final String MISSING_BILLING_CONTACT_PRODUCT          = 'The Account for this Invoice is missing a Primary Billing Contact';
    public static final String MISSING_BILLING_CONTACT_EMAIL            = 'The Billing Contact on the Agreement has no Email Address';
    public static final String MISSING_BILLING_CONTACT_EMAIL_PRODUCT    = 'The Primary Billing Contact on the Account has no Email Address';
    public static final String INVOICE_SENT_SUCCESSFULLY                = 'Invoice sent successfully';
    public static final String INVOICE_NOT_FOUND                        = 'Invoice not found, please try again';
    public static final String TEMPLATE_NOT_FOUND                       = 'A matching email template was not found, please contact a System Administrator';
    public static final String AGREEMENT_TEMPLATE_NOT_FOUND             = 'The custom Email Template indicated on the Agreement could not be found';
    public static final String ACCOUNT_TEMPLATE_NOT_FOUND               = 'The custom Email Template indicated on the Account could not be found';
    public static String templateId;
    public static Boolean isMailList                                    = true;
    public static Boolean isProductInvoice                              = false;
    @TestVisible private Invoice__c invoice ;
    private static List<Invoice__c> invoiceList = new List<Invoice__c>();
    private static List<String> additionalRecipients;

    public SendInvoiceController(ApexPages.StandardController std) {
        invoice = (Invoice__c) std.getRecord();
    }

    @RemoteAction
    public static String sendInvoice(Id invoiceId) {
        invoiceList = [SELECT Id, Name, Account__c, Account__r.Primary_Billing_Contact__c, Account__r.Primary_Billing_Contact__r.Email, Sent_To_Customer_On__c, Type__c, Due_Date__c,Account__r.Payment_Terms__c,
                                               Account__r.Additional_Invoice_Recipients__c, Agreement__c, Agreement__r.Billing_Contact__c, Agreement__r.Payment_Terms__c, Agreement__r.Billing_Contact__r.Email, 
                                               Account__r.Custom_Invoice_Email_Template__c, RecordTypeId, Agreement__r.Additional_Invoice_Recipients__c, Agreement__r.Custom_Invoice_Email_Template__c,
                                               Account__r.Bank_Address__c,Account__r.Indian_Financial_Services_Code__c,Account__r.Account_Number__c,Account__r.BillingCountry,Account__r.Taxpayer_Identification_Number_TIN__c,
                                               Account__r.Routing_Number__c,Account__r.Bank_Name__c,Account__r.BillingAddress,
                                               Account__r.BillingStreet,Account__r.BillingCountryCode,Account__r.BillingCity,Account__r.BillingPostalCode,Account__r.BillingStateCode,
                                               (SELECT Id
                                                FROM Time_Entries__r)
                                        FROM Invoice__c 
                                        WHERE Id =: invoiceId];
                                       
        system.debug('Right after query, invoiceList : ' + invoiceList);

        if(invoiceList != null && invoiceList.size() > 0) {

            system.debug('invoiceList : ' + invoiceList);
            system.debug('invoice.Agreement : ' + invoiceList[0].Agreement__c);
            system.debug('invoice.Agreement.BillingContact : ' + invoiceList[0].Agreement__r.Billing_Contact__c);
            if(invoiceList[0].RecordTypeId != Constants.RECORDTYPEID_INVOICE_10KPRODUCTINVOICE)
            {
                if(invoiceList[0].Agreement__c == null) {
                    return MISSING_AGREEMENT;
                }
                else if(invoiceList[0].Agreement__r.Billing_Contact__c == null) {
                    return MISSING_BILLING_CONTACT;
                }
                else if(invoiceList[0].Agreement__r.Billing_Contact__r.Email == null || invoiceList[0].Agreement__r.Billing_Contact__r.Email == '') {
                    return MISSING_BILLING_CONTACT_EMAIL;
                }
                else {
                    return updateInvoiceBeforeSending(invoiceList);
                }
            }
            else {
                //Product Invoice code goes here
                if(invoiceList[0].Account__r.Primary_Billing_Contact__c == null) {
                    return MISSING_BILLING_CONTACT_PRODUCT;
                }
                else if(invoiceList[0].Account__r.Primary_Billing_Contact__r.Email == null || invoiceList[0].Account__r.Primary_Billing_Contact__r.Email == '') {
                    return MISSING_BILLING_CONTACT_EMAIL_PRODUCT;
                }
                else {
                    return updateInvoiceBeforeSending(invoiceList);
                }
            }
        }
        else{
            return INVOICE_NOT_FOUND; 
        }                                            
    }
     
    public static List<Messaging.SingleEmailMessage> sendEmailToCustomer(List<Invoice__c> invoiceList1, List<String> additionalRecipients1) {
        Map<String,EmailTemplate> emailTemplateMap = new Map<String,EmailTemplate>();
        
        for(EmailTemplate selectedEmailTemplate : [SELECT Id, DeveloperName FROM EmailTemplate LIMIT 500]) {
            emailTemplateMap.put(selectedEmailTemplate.DeveloperName, selectedEmailTemplate);
        }

        system.debug('emailTemplateMap : ' + emailTemplateMap);

        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        
        Blob pdfData;
        for(Invoice__c invoice : invoiceList1) {
            if(invoice.RecordTypeId != Constants.RECORDTYPEID_INVOICE_10KPRODUCTINVOICE)
            {
                if(invoice.Agreement__r.Custom_Invoice_Email_Template__c != null && !emailTemplateMap.keySet().contains(invoice.Agreement__r.Custom_Invoice_Email_Template__c)){
                    templateId = null;
                    isMailList = false;
                    return mailList;
                }
                if(invoice.Agreement__r.Custom_Invoice_Email_Template__c != null && emailTemplateMap.keySet().contains(invoice.Agreement__r.Custom_Invoice_Email_Template__c)) {
                    templateId = emailTemplateMap.get(invoice.Agreement__r.Custom_Invoice_Email_Template__c).Id;
                }
                else if( invoice.RecordTypeId == Constants.RECORDTYPEID_INVOICE_10KSERVICESINVOICE) {
                    templateId = emailTemplateMap.get('X10K_Services_Invoice_Notification').Id;
                }
                else{
                    templateId = null;
                }
            }
            else
            {
                if(invoice.Account__r.Custom_Invoice_Email_Template__c != null && !emailTemplateMap.keySet().contains(invoice.Account__r.Custom_Invoice_Email_Template__c)){
                    templateId = null;
                    isMailList = false;
                    return mailList;
                }
                if(invoice.Account__r.Custom_Invoice_Email_Template__c != null && emailTemplateMap.keySet().contains(invoice.Account__r.Custom_Invoice_Email_Template__c)) {
                    templateId = emailTemplateMap.get(invoice.Account__r.Custom_Invoice_Email_Template__c).Id;
                }
                else if( invoice.RecordTypeId == Constants.RECORDTYPEID_INVOICE_10KPRODUCTINVOICE) {
                    templateId = emailTemplateMap.get('X10K_Product_Invoice_Notification').Id;
                    isProductInvoice = true;
                }
                else{
                    templateId = null;
                }
            }
            if(templateId != null) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateId(templateId);
                if(invoice.RecordTypeId == Constants.RECORDTYPEID_INVOICE_10KPRODUCTINVOICE)
                {
                    mail.setTargetObjectId(invoice.Account__r.Primary_Billing_Contact__c);
                }
                else
                {
                    mail.setTargetObjectId(invoice.Agreement__r.Billing_Contact__c);
                }
                mail.setWhatId(invoice.Id);
                mail.setSaveAsActivity(true);
                mail.setCcAddresses(additionalRecipients1);
                mail.setBccAddresses(new List<String>{Userinfo.getUserEmail()});
                
                List<Messaging.EmailFileAttachment> fileAttachments = new List<Messaging.EmailFileAttachment>();
                PageReference invoicePDFPageRef = new PageReference('/apex/GenerateInvoicePDF?id='+invoice.Id);
               
                Messaging.EmailFileAttachment invoicePDFAttachment = new Messaging.EmailFileAttachment(); 

                pdfData = Test.isRunningTest() ? Blob.valueOf('UNIT.TEST') : invoicePDFPageRef.getcontentAsPDF();

                invoicePDFAttachment.setFileName(invoice.Name+'.pdf');
                invoicePDFAttachment.setBody(pdfdata);  
                fileAttachments.add(invoicePDFAttachment);

                mail.setFileAttachments(fileAttachments);
                mailList.add(mail);
            }           
        } 
        return mailList;   
    }

    @RemoteAction
    public static String sendUpdatedInvoice(Id invoiceId)
    {
        invoiceList = [SELECT Id, Name, Account__c, Account__r.Primary_Billing_Contact__c, Account__r.Primary_Billing_Contact__r.Email, Sent_To_Customer_On__c, Type__c, Due_Date__c, Account__r.Payment_Terms__c,
                                   Account__r.Additional_Invoice_Recipients__c, Agreement__c, Agreement__r.Billing_Contact__c, Agreement__r.Payment_Terms__c, Agreement__r.Billing_Contact__r.Email, 
                                   Account__r.Custom_Invoice_Email_Template__c, RecordTypeId, Agreement__r.Additional_Invoice_Recipients__c, Agreement__r.Custom_Invoice_Email_Template__c,
                                   (SELECT Id
                                    FROM Time_Entries__r) 
                            FROM Invoice__c 
                            WHERE Id =: invoiceId];
        
        Utils utilities = new Utils();
        //Filter out any invalid email addressess found in the Additional Invoice Recipients field
        Set<String> additionalRecipientsSet = new Set<String>();
        
        if(invoiceList[0].Agreement__r.Additional_Invoice_Recipients__c != null) {
            for(String email: invoiceList[0].Agreement__r.Additional_Invoice_Recipients__c.split(',')) {
                additionalRecipientsSet.add(email.trim());
            }
        }

        if(invoiceList[0].Account__r.Additional_Invoice_Recipients__c != null) {
            for(String email : invoiceList[0].Account__r.Additional_Invoice_Recipients__c.split(',')) {
                additionalRecipientsSet.add(email.trim());
            }
        }

        if(!additionalRecipientsSet.isEmpty()) {
            System.debug('additionalRecipientsSet : ' + additionalRecipientsSet);
            Boolean validEmail;
            for(String emailAddress : additionalRecipientsSet) {
                System.debug('emailAddress : ' + emailAddress);
                validEmail = true;
                validEmail = utilities.validateEmail(emailAddress);
                System.debug('Valid Email? : ' + validEmail);
                if(!validEmail) {
                    System.debug('Removing this one! : ' + emailAddress);
                    additionalRecipientsSet.remove(emailAddress);
                }
            }
        }
        additionalRecipients = new List<String>(additionalRecipientsSet);
                            
        List<Messaging.SingleEmailMessage> emailList = sendEmailToCustomer(invoiceList, additionalRecipients);
        
        if(templateId != null)
        {
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailList);

            if(!results.get(0).isSuccess()) 
            {
                System.StatusCode statusCode = results.get(0).getErrors()[0].getStatusCode();
                return results.get(0).getErrors()[0].getMessage();
            }
            else 
            {
                return INVOICE_SENT_SUCCESSFULLY;
            }
        }
        else
        {
            if(!isMailList && invoiceList[0].RecordTypeId != Constants.RECORDTYPEID_INVOICE_10KPRODUCTINVOICE)
            {
                return AGREEMENT_TEMPLATE_NOT_FOUND;
            }
            else
            {
                return ACCOUNT_TEMPLATE_NOT_FOUND;
            }
            return TEMPLATE_NOT_FOUND;
        }
    }

    public static String updateInvoiceBeforeSending(List<Invoice__c> invoiceList1)
    {
        if(invoiceList1[0].Type__c == 'Draft'){
                if(invoiceList1[0].RecordTypeId == Constants.RECORDTYPEID_INVOICE_DELIVERYPARTNERINVOICE) {
                    if(!String.isBlank(invoiceList1[0].Account__r.BillingStreet) && !String.isBlank(invoiceList1[0].Account__r.BillingCountryCode) && !String.isBlank(invoiceList1[0].Account__r.BillingCity) && 
                    !String.isBlank(invoiceList1[0].Account__r.BillingPostalCode) && !String.isBlank(invoiceList1[0].Account__r.BillingStateCode)) {
                        if(!String.isBlank(invoiceList1[0].Account__r.Bank_Name__c) && 
                            !String.isBlank(invoiceList1[0].Account__r.Routing_Number__c) && !String.isBlank(invoiceList1[0].Account__r.Account_Number__c)) {
                            if(invoiceList1[0].Account__r.BillingCountry == 'United States') {
                                if(!String.isBlank(invoiceList1[0].Account__r.Taxpayer_Identification_Number_TIN__c ))
                                    invoiceList1[0].Type__c = 'Actual';
                            }else if (invoiceList1[0].Account__r.BillingCountry == 'India') {
                                if(!String.isBlank(invoiceList1[0].Account__r.Bank_Address__c) && !String.isBlank(invoiceList1[0].Account__r.Indian_Financial_Services_Code__c))
                                    invoiceList1[0].Type__c = 'Actual';
                            }else {
                                if(!String.isBlank(invoiceList1[0].Account__r.Bank_Address__c))
                                    invoiceList1[0].Type__c = 'Actual';
                            }
                        }
                    }
                }
                else
                    invoiceList1[0].Type__c = 'Actual';
            }
        if(invoiceList1[0].Sent_To_Customer_On__c == null) {
            invoiceList1[0].Sent_To_Customer_On__c = System.today();
        }

        system.debug(LoggingLevel.INFO, 'invoiceList1 : ' + invoiceList1);
        system.debug(LoggingLevel.INFO, 'invoiceList1[0] : ' + invoiceList1[0]);
        system.debug(LoggingLevel.INFO, 'invoiceList1[0].Agreement__c : ' + invoiceList1[0].Agreement__c);
        boolean outcome = invoiceList1[0].Agreement__c != null;
        system.debug(LoggingLevel.INFO, 'invoiceList1[0].Agreement__c != null : ' + outcome);
        system.debug(LoggingLevel.INFO, 'invoiceList1[0].Agreement__r : ' + invoiceList1[0].Agreement__r);

        if(invoiceList1[0].Agreement__c != null && invoiceList1[0].Agreement__r.Payment_Terms__c != null) {
            invoiceList1[0].Due_Date__c = invoiceList1[0].Sent_To_Customer_On__c.addDays(Integer.valueOf(invoiceList1[0].Agreement__r.Payment_Terms__c.split(' ')[1]));
        }
        else if(invoiceList1[0].Account__c != null && invoiceList1[0].Account__r.Payment_Terms__c != null) {
            invoiceList1[0].Due_Date__c = invoiceList1[0].Sent_To_Customer_On__c.addDays(Integer.valueOf(invoiceList1[0].Account__r.Payment_Terms__c.split(' ')[1]));
        }
        update invoiceList1;

        return 'Updated';
    }

    public PageReference returnBack() {
        Invoice__c currentInvoice = [SELECT ID FROM Invoice__c WHERE Id =: invoice.Id ];
        PageReference invoicePage = new ApexPages.StandardController(currentInvoice).view();
        invoicePage.setRedirect(true);
        return invoicePage;
    }
}