public class SendMultipleInvoiceController {

    public List<WrapInvoice> wrapInvoiceList                        {get;set;}
    public List<SelectOption> dateOptions                           {get;set;}
    public Boolean isLightningExperience                            {get;set;}
    public String processResult                                     {get;set;}
    public String selectedType                                      {get;set;}    
    public String selectedDateOption                                {get;set;}
    public static final String INVOICE_SENT_SUCCESSFULLY            = 'Invoice sent successfully';
    public static final String INVOICE_NOT_FOUND                    = 'Invoice not found, please try again';
    public static Boolean isMailList                                = true;
    public static Boolean isProductInvoice                          = false;
    private static List<Invoice__c> invoiceList                     = new List<Invoice__c>();
    private List<Invoice__c > tempwrapinvoiceList;
    public static String templateId;
    private static List<String> additionalRecipients;
    private Account selectedAccount;
    private Date sDate;
    private Date eDate;
    
    public SendMultipleInvoiceController(ApexPages.StandardController std) {
        selectedAccount = (Account) std.getRecord();
        selectedType = 'All'; 
        
        wrapinvoiceList = new List<WrapInvoice>();
        retrieveInvoices();
        dateOptions = new List<SelectOption>();
        dateOptions.add(new SelectOption('','All'));
        Set<String> dateoptionsStringSet = new Set<String>();
        for(Invoice__c inv : tempwrapinvoiceList) {
            Date invoiceStartDate = inv.Invoice_Generated_On__c;
            if(invoiceStartDate != null) {
                String str = invoiceStartDate.toStartOfMonth().format() + ' - ' + invoiceStartDate.addMonths(1).toStartOfMonth().addDays(-1).format();
                if(!dateoptionsStringSet.contains(str)) {
                    dateoptionsStringSet.add(str);
                    dateOptions.add(new SelectOption(str,str));
                }
            }
            If(inv.Type__c == 'Draft') {
                selectedType = 'Draft';
                //break;
            }
        }
        fetchTypeBasedInvoice();
        
        isLightningExperience = false;
        
        if(ApexPages.CurrentPage().GetParameters().get('sfdcIFrameOrigin') != null) {
            isLightningExperience = true;
        }
    }
    
    public List<selectOption> getTypes() {
        List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options
        options.add(new selectOption('All', 'All')); 
        options.add(new selectOption('Draft', 'Draft'));
        return options; //return the picklist options
    }

    public void retrieveInvoices() {
        if(selectedDateOption != null && selectedDateOption != '') {
            String dString      = selectedDateOption.split(' - ')[0];
            Date startDate      = Date.parse(dString);
            dString             = selectedDateOption.split(' - ')[1];
            Date endDate        = Date.parse(dString);
            tempwrapinvoiceList = [Select Id,Name,Account__c,Agreement__c,Agreement__r.Id,Agreement__r.Name,Total_Invoice_Amount__c,Type__c,
                                        Invoice_Generated_On__c,Sent_To_Customer_On__c,Due_Date__c,Billing_Period_Start_Date__c,Billing_Period_End_Date__c
                                    From Invoice__c 
                                    Where Account__c = : selectedAccount.Id 
                                        AND Billing_Period_Start_Date__c >=: startDate
                                        AND Billing_Period_End_Date__c <=: endDate
                                        Order By Invoice_Generated_On__c DESC];
        }
        else {
            tempwrapinvoiceList = [Select Id,Name,Account__c,Agreement__c,Agreement__r.Id,Agreement__r.Name,Total_Invoice_Amount__c,Type__c,
                                        Invoice_Generated_On__c,Sent_To_Customer_On__c,Due_Date__c,Billing_Period_Start_Date__c,Billing_Period_End_Date__c
                                    From Invoice__c 
                                    Where Account__c = : selectedAccount.Id 
                                        Order By Invoice_Generated_On__c DESC];
        }
        fetchTypeBasedInvoice();
        
    }
    
    public void fetchTypeBasedInvoice() {
        wrapinvoiceList.Clear();
        If(selectedType == 'Draft') {            
            for(Invoice__c inv : tempwrapinvoiceList) {
                If(inv.Type__c == 'Draft')
                    wrapinvoiceList.add(new WrapInvoice(false,inv));
            }
        }else if(selectedType == 'All') {
            for(Invoice__c inv : tempwrapinvoiceList) {
                wrapinvoiceList.add(new WrapInvoice(false,inv));
            }
        }
    }
    
    public void sendInvoice() {
        Set<Id> invoicesIds = new Set<Id>(); 
        for(WrapInvoice wrapObj :  wrapInvoiceList) {
            If(wrapObj.isSelected == true) {
                invoicesIds.add(wrapObj.invoice.Id);
            }
        }
        invoiceList = [SELECT Id, Name, Account__c, Account__r.Primary_Billing_Contact__c, Account__r.Primary_Billing_Contact__r.Email, Sent_To_Customer_On__c, Type__c, Due_Date__c,Account__r.Payment_Terms__c,
                               Account__r.Additional_Invoice_Recipients__c, Agreement__c, Agreement__r.Billing_Contact__c, Agreement__r.Payment_Terms__c, Agreement__r.Billing_Contact__r.Email, 
                               Account__r.Custom_Invoice_Email_Template__c, RecordTypeId, Agreement__r.Additional_Invoice_Recipients__c, Agreement__r.Custom_Invoice_Email_Template__c,
                               Account__r.Bank_Address__c,Account__r.Indian_Financial_Services_Code__c,Account__r.Account_Number__c,Account__r.BillingCountry,Account__r.Taxpayer_Identification_Number_TIN__c,
                               Account__r.Routing_Number__c,Account__r.Bank_Name__c,Account__r.BillingAddress,
                               Account__r.BillingStreet,Account__r.BillingCountryCode,Account__r.BillingCity,Account__r.BillingPostalCode,Account__r.BillingStateCode,
                               (SELECT Id
                               FROM Time_Entries__r)
                        FROM Invoice__c 
                        WHERE Id IN : invoicesIds];
                                       
        system.debug('Right after query, invoiceList : ' + invoiceList);
        List<Invoice__c> newTempinvoiceList = new List<Invoice__c>();
        
        if(invoiceList != null && invoiceList.size() > 0) {
            for(Invoice__c mainInvoice : invoiceList) {

                //Product Invoice code goes here
                if(mainInvoice.Account__r.Primary_Billing_Contact__c == null) {
                    processResult =  'The Account is missing a Primary Billing Contact';
                    return;
                }
                else if(mainInvoice.Account__r.Primary_Billing_Contact__r.Email == null || mainInvoice.Account__r.Primary_Billing_Contact__r.Email == '') {
                    processResult =  'The Primary Billing Contact on the Account has no Email Address';
                    return;
                }
                else {
                    newTempinvoiceList.add(mainInvoice); 
                }
            }
            processResult = updateInvoiceBeforeSending(newTempinvoiceList);
            return;
        }
        else{
            processResult =  INVOICE_NOT_FOUND; 
            return;
        }                                            
    }
    
    public String updateInvoiceBeforeSending(List<Invoice__c> invoiceList1) {
        for(Invoice__c mainInv : invoiceList1) {
            if(mainInv.Type__c == 'Draft'){
                if(mainInv.RecordTypeId == Constants.RECORDTYPEID_INVOICE_DELIVERYPARTNERINVOICE) {
                    if(!String.isBlank(mainInv.Account__r.BillingStreet) && !String.isBlank(mainInv.Account__r.BillingCountryCode) && !String.isBlank(mainInv.Account__r.BillingCity) && 
                    !String.isBlank(mainInv.Account__r.BillingPostalCode) && !String.isBlank(mainInv.Account__r.BillingStateCode)) {
                        if(!String.isBlank(mainInv.Account__r.Bank_Name__c) && 
                            !String.isBlank(mainInv.Account__r.Routing_Number__c) && !String.isBlank(mainInv.Account__r.Account_Number__c)) {
                            if(mainInv.Account__r.BillingCountry == 'United States') {
                                if(!String.isBlank(mainInv.Account__r.Taxpayer_Identification_Number_TIN__c ))
                                    mainInv.Type__c = 'Actual';
                            }else if (mainInv.Account__r.BillingCountry == 'India') {
                                if(!String.isBlank(mainInv.Account__r.Bank_Address__c) && !String.isBlank(mainInv.Account__r.Indian_Financial_Services_Code__c))
                                    mainInv.Type__c = 'Actual';
                            }else {
                                if(!String.isBlank(mainInv.Account__r.Bank_Address__c))
                                    mainInv.Type__c = 'Actual';
                            }
                        }
                    }
                }
                else
                    mainInv.Type__c = 'Actual';
            }
            if(mainInv.Sent_To_Customer_On__c == null) {
                mainInv.Sent_To_Customer_On__c = System.today();
            }
            if(mainInv.Agreement__c != null && mainInv.Agreement__r.Payment_Terms__c != null) {
            mainInv.Due_Date__c = mainInv.Sent_To_Customer_On__c.addDays(Integer.valueOf(mainInv.Agreement__r.Payment_Terms__c.split(' ')[1]));
            }
            else if(mainInv.Account__c != null && mainInv.Account__r.Payment_Terms__c != null) {
                mainInv.Due_Date__c = mainInv.Sent_To_Customer_On__c.addDays(Integer.valueOf(mainInv.Account__r.Payment_Terms__c.split(' ')[1]));
            }
            mainInv.Selected_To_Send_From_Account__c = true;
        }
        update invoiceList1;
        return 'Updated';
    }
    
    public void sendUpdatedInvoice()
    {
        Set<Id> invoicesIds = new Set<Id>(); 
        for(WrapInvoice wrapObj :  wrapInvoiceList) {
            If(wrapObj.isSelected == true) {
                invoicesIds.add(wrapObj.invoice.Id);
            }
        }
        invoiceList = [SELECT Id, Name, Account__c, Account__r.Primary_Billing_Contact__c, Account__r.Primary_Billing_Contact__r.Email, Sent_To_Customer_On__c, Type__c, Due_Date__c,Account__r.Payment_Terms__c,
                               Account__r.Additional_Invoice_Recipients__c, Agreement__c, Agreement__r.Billing_Contact__c, Agreement__r.Payment_Terms__c, Agreement__r.Billing_Contact__r.Email, 
                               Account__r.Custom_Invoice_Email_Template__c, RecordTypeId, Agreement__r.Additional_Invoice_Recipients__c, Agreement__r.Custom_Invoice_Email_Template__c,
                               (SELECT Id
                                FROM Time_Entries__r)
                        FROM Invoice__c 
                        WHERE Id IN : invoicesIds];
        
        Utils utilities = new Utils();
        //Filter out any invalid email addressess found in the Additional Invoice Recipients field
        Set<String> additionalRecipientsSet = new Set<String>();
        
        for(Invoice__c mainInv : invoiceList ) {
            if(mainInv.Agreement__c != null && mainInv.Agreement__r.Billing_Contact__c != null && mainInv.Agreement__r.Billing_Contact__r.Email != null ) {
                additionalRecipientsSet.add(mainInv.Agreement__r.Billing_Contact__r.Email.trim());
            }
            if(mainInv.Agreement__c != null && mainInv.Agreement__r.Additional_Invoice_Recipients__c != null) {
                for(String email: mainInv.Agreement__r.Additional_Invoice_Recipients__c.split(',')) {
                    additionalRecipientsSet.add(email.trim());
                }
            }
        }   
        for(Invoice__c mainInv : invoiceList ) { 
            if(mainInv.Account__c!= null && mainInv.Account__r.Additional_Invoice_Recipients__c != null) {
                for(String email : mainInv.Account__r.Additional_Invoice_Recipients__c.split(',')) {
                    additionalRecipientsSet.add(email.trim());
                }
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
        List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailList);
        for(Invoice__c mainInv : invoiceList) {
            mainInv.Selected_To_Send_From_Account__c = false;
        }
        update invoiceList;
        if(!results.get(0).isSuccess()) 
        {
            System.StatusCode statusCode = results.get(0).getErrors()[0].getStatusCode();
            processResult =  results.get(0).getErrors()[0].getMessage();
            return;
        }
        else 
        {
            processResult = INVOICE_SENT_SUCCESSFULLY;
            return;
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
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<Messaging.EmailFileAttachment> fileAttachments = new List<Messaging.EmailFileAttachment>();
        EmailTemplate[] template = [select id, name from EmailTemplate where developername =: Label.Send_Invoice_From_Account];
        for(Invoice__c invoice : invoiceList1) {
                
            
            mail.setTargetObjectId(invoice.Account__r.Primary_Billing_Contact__c);
            mail.setWhatId(invoice.Account__c);
            
            PageReference invoicePDFPageRef = Page.GenerateInvoicePDF;
            invoicePDFPageRef.getParameters().put('id', invoice.id);
           
            Messaging.EmailFileAttachment invoicePDFAttachment = new Messaging.EmailFileAttachment(); 

            pdfData = Test.isRunningTest() ? Blob.valueOf('UNIT.TEST') : invoicePDFPageRef.getcontentAsPDF();

            invoicePDFAttachment.setFileName(invoice.Name+'.pdf');
            invoicePDFAttachment.setInline(false);
            invoicePDFAttachment.setBody(pdfdata);  
            fileAttachments.add(invoicePDFAttachment);
        } 
        mail.setTemplateId(template[0].Id);
        mail.setSaveAsActivity(true);
        mail.setCcAddresses(additionalRecipients1);
        mail.setBccAddresses(new List<String>{Userinfo.getUserEmail()});
        mail.setFileAttachments(fileAttachments);
        mailList.add(mail);

        return mailList;   
    }
    
    public PageReference returnBack() {
        Account currentAccount = [SELECT ID,Name FROM Account WHERE Id =: ApexPages.currentPage().getParameters().get('id') ];
        PageReference accViewPage = new ApexPages.StandardController(currentAccount).view();
        accViewPage.setRedirect(true);
        return accViewPage;
    }
    
    public Class WrapInvoice{
        public boolean isSelected {get;set;}
        public Invoice__c invoice {get;set;}
        
        public WrapInvoice(boolean isSelected1,Invoice__c invoice1) {
            isSelected  = isSelected1;
            invoice = invoice1;
        }    
    }
}