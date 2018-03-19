@IsTest
public class SendMultipleInvoiceController_Test {

    @testSetup static void setupData() {
        Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
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
        insert accList;

        List<Contact> contactList           = TestDataFactory_Contacts.generatecontacts(accList, 'Test contact', 'lastName', '', '', 1);
        contactList[0].Email = 'nowhere@nowhere.com';
        insert contactList;

        accList[0].Primary_Billing_Contact__c = contactList[0].id;
        update accList;

        List<Agreement__c> agreementList    = TestDataFactory_Agreements.generateAgreements('Test Agreement 1', accList[0].Id, Constants.RECORDTYPEID_AGREEMENT_TIMEANDMATERIALS, 'Active', Date.newInstance(System.Today().Year(), System.Today().Month() - 1, 1), Date.newInstance(System.Today().Year() + 1, System.Today().Month() - 1, 1) , 1);
        agreementList[0].Rate_Structure__c = 'Monthly';
        agreementList[0].Status__c         = 'Active';
        agreementList[0].RecordTypeId = Constants.RECORDTYPEID_AGREEMENT_TIMEANDMATERIALS ;
        agreementList[0].Effective_Date__c = system.today();
        agreementList[0].Valid_Through__c = system.today().addDays(2);
        agreementList[0].Rate_Structure__c = null;
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
        invoiceList[1].RecordTypeId = Constants.RECORDTYPEID_INVOICE_DELIVERYPARTNERINVOICE;
        invoiceList[0].Billing_Period_Start_Date__c = Date.today() ;
        invoiceList[0].Billing_Period_End_Date__c = Date.today().addDays(21);
        invoiceList[1].Billing_Period_Start_Date__c = Date.today() ;
        invoiceList[1].Billing_Period_End_Date__c = Date.today().addDays(21);
        insert invoiceList;
    }

    @IsTest
    public static void SendInvoice_Success() {
    
        List<Account> accList = [SELECT Id,BillingCountry FROM Account] ;
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(accList[0]);
        SendMultipleInvoiceController controller = new SendMultipleInvoiceController(sc);
        
        for(SendMultipleInvoiceController.WrapInvoice wrap : controller.wrapinvoiceList){
            wrap.isSelected = true;
        }
        Date dt = datetime.now().date();
        String selectedDateString = dt.format() ;
        selectedDateString += ' - ' ;
        dt = datetime.now().addDays(10).date();
        selectedDateString += dt.format() ;
        controller.sendInvoice();
        controller.sendUpdatedInvoice(); 
        controller.getTypes();
        controller.selectedDateOption = selectedDateString;
        controller.retrieveInvoices();
        Test.stopTest();
        //system.assertEquals(response, SendMultipleInvoiceController.INVOICE_SENT_SUCCESSFULLY);
    } 

    @IsTest
    public static void SendInvoice_Success_Product() {
    
        
        List<Account> accList = [SELECT Id,BillingCountry,Additional_Invoice_Recipients__c FROM Account] ;
        accList[0].Additional_Invoice_Recipients__c = 'fsdfnj@dghh.com';
        update accList;

        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(accList[0]);
        SendMultipleInvoiceController controller = new SendMultipleInvoiceController(sc);
        for(SendMultipleInvoiceController.WrapInvoice wrap : controller.wrapinvoiceList){
            wrap.isSelected = true;
        }
        controller.sendInvoice();
        controller.sendUpdatedInvoice(); 
        Test.stopTest();

        //system.assertEquals(response, SendMultipleInvoiceController.INVOICE_SENT_SUCCESSFULLY);
    }

    /*@IsTest
    public static void SendInvoice_MissingAgreement() {
    
        TestDataFactory factory = new TestDataFactory();
        
        List<Account> accList = factory.generateAccounts(1);
        insert accList;

        List<Contact> contactList = factory.generateContactsForAccounts(accList, 1);
        contactList[0].Email = 'nowhere@nowhere.com';
        insert contactList;

        List<Agreement__c> agreementList = factory.generateRetainerAgreementsForAccounts(accList,1);
        agreementList[0].RecordTypeId = Constants.RECORDTYPEID_AGREEMENT_TIMEANDMATERIALS ;
        agreementList[0].Effective_Date__c = system.today();
        agreementList[0].Valid_Through__c = system.today().addDays(2);
        agreementList[0].Rate_Structure__c = null;
        agreementList[0].Billing_Contact__c = contactList[0].Id;
        insert agreementList;

        List<Rate__c> rateList = factory.generateRateForAgreement(agreementList[0].Id, Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS, Constants.ROLE_DEVELOPER, 1);
        insert rateList;

        List<Invoice__c> invoiceList = factory.generateInvoices(accList[0].Id, 'Test Invoice Name', 1);
        invoiceList[0].Agreement__c = agreementList[0].Id;
        insert invoiceList;

        List<Invoice_Line_Item__c> invoiceLinesList = factory.generateInvoiceLineItems(invoiceList[0].Id, rateList[0].Id, 1);
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(accList[0]);
        SendMultipleInvoiceController controller = new SendMultipleInvoiceController(sc);
        for(SendMultipleInvoiceController.WrapInvoice wrap : controller.wrapinvoiceList){
            wrap.isSelected = true;
        }
        controller.sendInvoice();
        controller.sendUpdatedInvoice(); 
        Test.stopTest();

        //system.assertEquals(response, SendMultipleInvoiceController.MISSING_AGREEMENT);
    }
    
    @IsTest
    public static void SendInvoice_MissingBillingContact() {
    
        TestDataFactory factory = new TestDataFactory();
        
        List<Account> accList = factory.generateAccounts(1);
        insert accList;

        List<Contact> contactList = factory.generateContactsForAccounts(accList, 1);
        contactList[0].Email = 'nowhere@nowhere.com';
        insert contactList;

        List<Agreement__c> agreementList = factory.generateRetainerAgreementsForAccounts(accList,1);
        agreementList[0].RecordTypeId = Constants.RECORDTYPEID_AGREEMENT_TIMEANDMATERIALS ;
        agreementList[0].Effective_Date__c = system.today();
        agreementList[0].Valid_Through__c = system.today().addDays(2);
        agreementList[0].Rate_Structure__c = null;
        agreementList[0].Billing_Contact__c = contactList[0].Id;
        insert agreementList;

        List<Rate__c> rateList = factory.generateRateForAgreement(agreementList[0].Id, Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS, Constants.ROLE_DEVELOPER, 1);
        insert rateList;

        List<Invoice__c> invoiceList = factory.generateInvoices(accList[0].Id, 'Test Invoice Name', 1);
        invoiceList[0].Agreement__c = agreementList[0].Id;
        insert invoiceList;

        List<Invoice_Line_Item__c> invoiceLinesList = factory.generateInvoiceLineItems(invoiceList[0].Id, rateList[0].Id, 1);
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(accList[0]);
        SendMultipleInvoiceController controller = new SendMultipleInvoiceController(sc);
        for(SendMultipleInvoiceController.WrapInvoice wrap : controller.wrapinvoiceList){
            wrap.isSelected = true;
        }
        controller.sendInvoice();
        controller.sendUpdatedInvoice(); 
        Test.stopTest();

        //system.assertEquals(response, SendMultipleInvoiceController.MISSING_BILLING_CONTACT);
    }

    @IsTest
    public static void SendInvoice_MissingBillingContactEmail() {
    
        TestDataFactory factory = new TestDataFactory();
        
        List<Account> accList = factory.generateAccounts(1);
        insert accList;

        List<Contact> contactList = factory.generateContactsForAccounts(accList, 1);
        contactList[0].Email = null;
        insert contactList;

        accList[0].Primary_Billing_Contact__c = contactList[0].id;
        update accList;

        List<Agreement__c> agreementList = factory.generateRetainerAgreementsForAccounts(accList,1);
        agreementList[0].RecordTypeId = Constants.RECORDTYPEID_AGREEMENT_TIMEANDMATERIALS ;
        agreementList[0].Effective_Date__c = system.today();
        agreementList[0].Valid_Through__c = system.today().addDays(2);
        agreementList[0].Rate_Structure__c = null;
        agreementList[0].Billing_Contact__c = contactList[0].Id;
        insert agreementList;

        List<Rate__c> rateList = factory.generateRateForAgreement(agreementList[0].Id, Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS, Constants.ROLE_DEVELOPER, 1);
        insert rateList;

        List<Invoice__c> invoiceList = factory.generateInvoices(accList[0].Id, 'Test Invoice Name', 1);
        invoiceList[0].Agreement__c = agreementList[0].Id;
        insert invoiceList;

        List<Invoice_Line_Item__c> invoiceLinesList = factory.generateInvoiceLineItems(invoiceList[0].Id, rateList[0].Id, 1);
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(accList[0]);
        SendMultipleInvoiceController controller = new SendMultipleInvoiceController(sc);
        for(SendMultipleInvoiceController.WrapInvoice wrap : controller.wrapinvoiceList){
            wrap.isSelected = true;
        }
        controller.sendInvoice();
        controller.sendUpdatedInvoice(); 
        Test.stopTest();

        //system.assertEquals(response, SendMultipleInvoiceController.MISSING_BILLING_CONTACT_EMAIL);
    }
    
    @IsTest
    public static void SendInvoice_InvoiceNotFound() {
    
        TestDataFactory factory = new TestDataFactory();
        
        List<Account> accList = factory.generateAccounts(1);
        insert accList;

        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(accList[0]);
        SendMultipleInvoiceController controller = new SendMultipleInvoiceController(sc);
        for(SendMultipleInvoiceController.WrapInvoice wrap : controller.wrapinvoiceList){
            wrap.isSelected = true;
        }
        controller.sendInvoice();
        controller.sendUpdatedInvoice(); 
        Test.stopTest();

        //system.assertEquals(response, SendMultipleInvoiceController.INVOICE_NOT_FOUND);
    }
    */
    @IsTest
    public static void SendInvoice_IncorrectEmailTemplate() {
    
        List<Account> accList = [SELECT Id,BillingCountry,Additional_Invoice_Recipients__c FROM Account] ;
        Test.startTest();
        ApexPages.CurrentPage().getParameters().put('id',accList[0].Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(accList[0]);
        SendMultipleInvoiceController controller = new SendMultipleInvoiceController(sc);
        for(SendMultipleInvoiceController.WrapInvoice wrap : controller.wrapinvoiceList){
            wrap.isSelected = true;
        }
        controller.sendInvoice();
        controller.sendUpdatedInvoice();
        controller.returnBack();
        Test.stopTest();

        //system.assertEquals(response, SendMultipleInvoiceController.ACCOUNT_TEMPLATE_NOT_FOUND);
    }
}