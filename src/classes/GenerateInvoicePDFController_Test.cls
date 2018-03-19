@isTest
private class GenerateInvoicePDFController_Test {
    
    @isTest static void test_method_one() {
        TestDataFactory factory = new TestDataFactory();
        
        Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
                                          'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                          'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
                                          null, 'Net 30', 'test@test.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
                                          1);
        insert accList;

        List<Agreement__c> agreementList = TestDataFactory_Agreements.generateAgreements('Test Agreement 1', accList[0].Id, Constants.RECORDTYPEID_AGREEMENT_RETAINER, 'Active', Date.newInstance(System.Today().Year(), System.Today().Month() - 1, 1), Date.newInstance(System.Today().Year() + 1, System.Today().Month() - 1, 1) , 1);
        insert agreementList;

        List<Rate__c> rateList = TestDataFactory_Rates.generateRateForAgreement(agreementList[0].id, Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS, Constants.ROLE_CONSULTANT, 100, 1);
        insert rateList;

        List<Invoice__c> invoiceList = TestDataFactory_Invoices.generateInvoices(accList[0].Id, system.today(),system.today().addDays(-2), system.today(), 2, 1);
        invoiceList[0].Billing_Period_Start_Date__c = Date.today() -20 ;
        invoiceList[0].Billing_Period_End_Date__c = Date.today() -10 ;
        insert invoiceList;
        
        List<Invoice_Line_Item__c> InvoiceLineItemsList = TestDataFactory_InvoiceLineItems.generateInvoiceLineItems(invoiceList[0].Id, Constants.RECORDTYPEID_INVOICE_10KPRODUCTNVOICELINEITEM, null, 2, 30, 1);
        insert InvoiceLineItemsList;

        Apexpages.currentpage().getparameters().put('Id' , invoiceList[0].Id);

        Test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(invoiceList[0]);
            GenerateInvoicePDFController controller = new GenerateInvoicePDFController(sc);
            System.assertNotEquals(controller.strBillableStartDate,null);
        Test.stopTest();
    }
}