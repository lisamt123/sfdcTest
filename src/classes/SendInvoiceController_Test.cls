@IsTest
public class SendInvoiceController_Test {

    @testSetup static void setupData() {
        Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Delivery Partner').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
                                                            'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                            'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
                                                            null, 'Net 30', 'test@test.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
                                                            1);
        accList[0].Bank_Name__c = 'test bank' ;
        accList[0].Routing_Number__c = '1234' ;
        accList[0].Account_Number__c = '5678' ;
        accList[0].BillingCountry = 'United States' ;
        accList[0].Taxpayer_Identification_Number_TIN__c = '321' ; 
        accList[0].Custom_Invoice_Email_Template__c = 'TestEmailVFTemplate' ;
        accList[0].Bank_Address__c = 'xyz' ;
        accList[0].Indian_Financial_Services_Code__c = 'ABC' ;
        accList[0].BillingCountryCode = 'US';
        accList[0].BillingStateCode = 'FL' ;
        insert accList;
        
        List<Contact> contactList           = TestDataFactory_Contacts.generatecontacts(accList, 'Test contact', 'lastName', '', '', 1);
        contactList[0].Email = 'nowhere@nowhere.com';
        insert contactList;

        accList[0].Primary_Billing_Contact__c = contactList[0].id;
        update accList;
        System.debug('accList - '+accList);
        List<Agreement__c> agreementList    = TestDataFactory_Agreements.generateAgreements('Test Agreement 1', accList[0].Id, Constants.RECORDTYPEID_AGREEMENT_TIMEANDMATERIALS, 'Active', Date.newInstance(System.Today().Year(), System.Today().Month() - 1, 1), Date.newInstance(System.Today().Year() + 1, System.Today().Month() - 1, 1) , 1);
        agreementList[0].Rate_Structure__c = 'Monthly';
        agreementList[0].Status__c         = 'Active';
        agreementList[0].RecordTypeId = Constants.RECORDTYPEID_AGREEMENT_TIMEANDMATERIALS ;
        agreementList[0].Effective_Date__c = system.today();
        agreementList[0].Valid_Through__c = system.today().addDays(2);
        agreementList[0].Rate_Structure__c = null;
        agreementList[0].Custom_Invoice_Email_Template__c = 'TestEmailVFTemplate';
        insert agreementList;
        agreementList[0].Additional_Invoice_Recipients__c = 'fsdfnj@dghh.com, hgdff@jhgh.com';
        agreementList[0].Billing_Contact__c = contactList[0].Id;
        update agreementList;



        List<Rate__c> rateList              = new List<Rate__c>();
        rateList.addAll(TestDataFactory_Rates.generateRateForAgreement(agreementList[0].id, Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS, Constants.ROLE_CONSULTANT, 100, 1));
        rateList.addAll(TestDataFactory_Rates.generateRateForAgreement(agreementList[0].id, Constants.ASSIGNMENTTYPE_NAMEDRESOURCE, Constants.ROLE_DEVELOPER, 100, 1));
        insert rateList;
        List<Invoice__c> invoiceList = TestDataFactory_Invoices.generateInvoices(accList[0].Id, Date.today().addDays(2), Date.today().addDays(-1), Date.today(), 2.1, 2);
        invoiceList[0].Agreement__c = agreementList[0].Id;
        invoiceList[0].RecordTypeId = Constants.RECORDTYPEID_INVOICE_10KSERVICESINVOICE;
        invoiceList[0].Type__c = 'Draft';
        invoiceList[1].Type__c = 'Draft';
        invoiceList[1].Agreement__c = agreementList[0].Id;
        invoiceList[1].RecordTypeId = Constants.RECORDTYPEID_INVOICE_DELIVERYPARTNERINVOICE;
        invoiceList[0].Billing_Period_Start_Date__c = Date.today() ;
        invoiceList[0].Billing_Period_End_Date__c = Date.today().addDays(21);
        invoiceList[1].Billing_Period_Start_Date__c = Date.today() ;
        invoiceList[1].Billing_Period_End_Date__c = Date.today().addDays(21);
        insert invoiceList;

        invoiceList = TestDataFactory_Invoices.generateInvoices(accList[0].Id, Date.today().addDays(2), Date.today().addDays(-1), Date.today(), 2.1, 1);
        invoiceList[0].Agreement__c = agreementList[0].Id;
        invoiceList[0].RecordTypeId = Constants.RECORDTYPEID_INVOICE_10KPRODUCTINVOICE;
        invoiceList[0].Type__c = 'Draft';
        invoiceList[0].Billing_Period_Start_Date__c = Date.today() ;
        invoiceList[0].Billing_Period_End_Date__c = Date.today().addDays(21);
        insert invoiceList;
    }

    @testSetup static void setUpTemplate() {
        string templateText = '<messaging:emailTemplate subject="{!relatedTo.Name}" '+
                              'recipientType="User" relatedToType="Invoice__c">'+
                              '<messaging:htmlEmailBody ><ul><li>test content</li></ul>'+
                              '</messaging:htmlEmailBody></messaging:emailTemplate>';
        EmailTemplate template = new EmailTemplate(DeveloperName = 'TestEmailVFTemplate',
                                                   TemplateType= 'Visualforce',
                                                   FolderId = UserInfo.getUserId(),
        Name = 'TestEmailVFTemplate',
        IsActive = true);
        template.Markup=templateText;
        insert template;
    }

    @IsTest
    public static void SendInvoice_Success() {
        Id delieveryPartnerId = Constants.RECORDTYPEID_INVOICE_DELIVERYPARTNERINVOICE;
        List<Invoice__c> invoiceList = [SELECT Id FROM Invoice__c];

        List<Account> accList = [SELECT Id,BillingCountry FROM Account];
        Test.startTest();
        SendInvoiceController.sendInvoice(invoiceList[0].Id);
        String response = SendInvoiceController.sendUpdatedInvoice(invoiceList[0].Id);
        SendInvoiceController.sendInvoice(invoiceList[1].Id);
        String response_two = SendInvoiceController.sendUpdatedInvoice(invoiceList[1].Id);
        Test.stopTest();

        system.assertEquals(response, SendInvoiceController.INVOICE_SENT_SUCCESSFULLY);
    }

    @IsTest
    public static void SendInvoice_Success_Product() {
        List<Agreement__c> agreementList = [SELECT Id,Custom_Invoice_Email_Template__c FROM Agreement__c];
        List<Account> accList = [SELECT Id,Additional_Invoice_Recipients__c FROM Account];
        accList[0].Additional_Invoice_Recipients__c = 'fsdfnj@dghh.com';
        update accList;
        
        Id productRecordId = Constants.RECORDTYPEID_INVOICE_10KPRODUCTINVOICE;
        List<Invoice__c> invoiceList = [SELECT Id FROM Invoice__c WHERE RecordTypeId =: productRecordId];
        Test.startTest();
        SendInvoiceController.sendInvoice(invoiceList[0].Id);
        String response = SendInvoiceController.sendUpdatedInvoice(invoiceList[0].Id);
        Test.stopTest();

        system.assertEquals(response, SendInvoiceController.INVOICE_SENT_SUCCESSFULLY);
    }

    @IsTest
    public static void SendInvoice_MissingAgreement() {
    
        List<Invoice__c> invoiceList = [SELECT Id,Agreement__c FROM Invoice__c];
        invoiceList[0].Agreement__c = null;
        update invoiceList;

        Test.startTest();
        String response = SendInvoiceController.sendInvoice(invoiceList[0].Id);
        Test.stopTest();

        system.assertEquals(response, SendInvoiceController.MISSING_AGREEMENT);
    }

    @IsTest
    public static void SendInvoice_MissingBillingContact() {
        List<Agreement__c> agreementList = [SELECT Id,Billing_Contact__c FROM Agreement__c];
        agreementList[0].Billing_Contact__c = null ;
        update agreementList;
        
        List<Invoice__c> invoiceList = [SELECT Id FROM Invoice__c];
        Test.startTest();
        String response = SendInvoiceController.sendInvoice(invoiceList[0].Id);
        Test.stopTest();

        system.assertEquals(response, SendInvoiceController.MISSING_BILLING_CONTACT);
    }

    @IsTest
    public static void SendInvoice_MissingBillingContactEmail() {
    
        
        List<Contact> contactList = [SELECT Id,Email FROM Contact] ;
        contactList[0].Email = null;
        update contactList ;
        
        List<Invoice__c> invoiceList = [SELECT Id FROM Invoice__c];
        Test.startTest();
        String response = SendInvoiceController.sendInvoice(invoiceList[0].Id);
        Test.stopTest();

        system.assertEquals(response, SendInvoiceController.MISSING_BILLING_CONTACT_EMAIL);
    }
    
    @IsTest
    public static void SendInvoice_InvoiceNotFound() {
    
        List<Account> accList = [SELECT Id FROM Account];
        Test.startTest();
        String response = SendInvoiceController.sendInvoice(accList[0].Id);
        Test.stopTest();

        system.assertEquals(response, SendInvoiceController.INVOICE_NOT_FOUND);
    }

    @IsTest
    public static void SendInvoice_IncorrectEmailTemplate() {
        
        List<Account> accList = [SELECT Id FROM Account] ;
        List<Agreement__c> agreementList = TestDataFactory_Agreements.generateAgreements('Test Agreement 1', accList[0].Id, Constants.RECORDTYPEID_AGREEMENT_TIMEANDMATERIALS, 'Active', Date.newInstance(System.Today().Year(), System.Today().Month() - 1, 1), Date.newInstance(System.Today().Year() + 1, System.Today().Month() - 1, 1) , 1);
        agreementList[0].RecordTypeId = Constants.RECORDTYPEID_AGREEMENT_TIMEANDMATERIALS ;
        agreementList[0].Custom_Invoice_Email_Template__c = 'HELLO WORLD';
        agreementList[0].Effective_Date__c = system.today();
        agreementList[0].Valid_Through__c = system.today().addDays(2);
        agreementList[0].Rate_Structure__c = null;
        insert agreementList;

        List<Rate__c> rateList = TestDataFactory_Rates.generateRateForAgreement(agreementList[0].id, Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS, Constants.ROLE_DEVELOPER, 100, 1);
        insert rateList;

        List<Invoice__c> invoiceList = TestDataFactory_Invoices.generateInvoices(accList[0].Id, Date.today().addDays(2), Date.today().addDays(-1), Date.today(), 2.1, 1);
        invoiceList[0].Agreement__c = agreementList[0].Id;
        insert invoiceList;

        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(invoiceList[0]);
        SendInvoiceController controller = new SendInvoiceController(sc);
        SendInvoiceController.sendInvoice(invoiceList[0].Id);
        SendInvoiceController.templateId = null ;
        String response = SendInvoiceController.sendUpdatedInvoice(invoiceList[0].Id);
        controller.returnBack();
        Test.stopTest();
    }

    @IsTest
    public static void SendInvoice_Success_two() {
        Id delieveryPartnerId = Constants.RECORDTYPEID_INVOICE_DELIVERYPARTNERINVOICE;
        List<Invoice__c> invoiceList = [SELECT Id FROM Invoice__c WHERE RecordTypeId =: delieveryPartnerId];
        System.debug('invoiceList - '+invoiceList);
        List<Account> accList = [SELECT Id,BillingCountry FROM Account];
        accList[0].BillingCountry = 'India' ;
        accList[0].Bank_Name__c = 'TEst bank' ;
        accList[0].Routing_Number__c = '123' ;
        accList[0].Account_Number__c = '446' ;
        accList[0].BillingStateCode = 'UP' ;
        accList[0].BillingCountryCode = 'IN';
        update accList;
        Test.startTest();
        SendInvoiceController.sendInvoice(invoiceList[0].Id);
        String response = SendInvoiceController.sendUpdatedInvoice(invoiceList[0].Id);
        Test.stopTest();

        system.assertEquals(response, SendInvoiceController.INVOICE_SENT_SUCCESSFULLY);
    }

    @IsTest
    public static void SendInvoice_Success_three() {
        Id delieveryPartnerId = Constants.RECORDTYPEID_INVOICE_DELIVERYPARTNERINVOICE;
        List<Invoice__c> invoiceList = [SELECT Id FROM Invoice__c WHERE RecordTypeId =: delieveryPartnerId];
        System.debug('invoiceList - '+invoiceList);
        List<Account> accList = [SELECT Id,BillingCountry FROM Account];
        accList[0].BillingCountry = 'Brazil' ;
        accList[0].Bank_Name__c = 'TEst bank' ;
        accList[0].Routing_Number__c = '123' ;
        accList[0].Account_Number__c = '446' ;
        accList[0].BillingStateCode = 'PR' ;
        accList[0].BillingCountryCode = 'BR';
        update accList;
        Test.startTest();
        SendInvoiceController.sendInvoice(invoiceList[0].Id);
        String response = SendInvoiceController.sendUpdatedInvoice(invoiceList[0].Id);
        Test.stopTest();

        system.assertEquals(response, SendInvoiceController.INVOICE_SENT_SUCCESSFULLY);
    }
}