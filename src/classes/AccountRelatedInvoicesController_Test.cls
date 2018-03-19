@isTest
public class AccountRelatedInvoicesController_Test {
    static testMethod void test_method_one() {
        
    Id partnerClientrecordTypeId = Constants.RECORDTYPEID_Account_DeliveryPartner;
        List<Account> accountList    = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test Account', 'Prospect', 15, 
                                                                                'code coverage', 'internal', 'App Cloud;Sales Cloud', 'Enterprise', 
                                                                                'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                                                'code quality with code coverage above 75%', 'NDA aggrement', 'United States', 
                                                                                '501 test street', 'test city', 'Florida', '90001', null, null, 'Net 30', 
                                                                                'acc@testemail.com', 'TestA', 'HELLO WORLD', 'invoicingNotes', 
                                                                                'Partner Client', 1);
        
        accountList[0].Current_Tier__c = 'K2';
        insert accountList;
        Id msaRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('MSA Opportunity').getRecordTypeId();
         List<Opportunity> oppList = TestDataFactory_Opportunity.generateOpportunities(accountList[0].Id,msaRecordTypeId, 'Closed Won', system.today().addDays(2),system.today().addDays(-30),system.today().addDays(-2), 1);
        oppList[0].Start_Date__c = System.today();
        oppList[0].End_Date__c = System.today().addDays(7);
        insert oppList;
        
        

         List<Agreement__c> agreementList = TestDataFactory_Agreements.generateAgreements('Test Agreement', accountList[0].id, 
                                                                                         Constants.RECORDTYPEID_AGREEMENT_RETAINER, 
                                                                                         'Active', 
                                                                                         Date.newInstance(System.Today().Year(), System.Today().Month() - 1, 1), 
                                                                                         Date.newInstance(System.Today().Year() + 1, System.Today().Month() - 1, 1), 
                                                                                         1);

        insert agreementList;
        
        List<Rate__c> rateList           = TestDataFactory_Rates.generateRateForAgreement(agreementList[0].id, 
                                                                                'Time & Materials', 
                                                                                Constants.ROLE_USER_EXPERIENCE, 20, 1);
       
        insert rateList;

        List<Invoice__c> invoiceList = TestDataFactory_Invoices.generateInvoices(accountList[0].Id, system.today(),system.today().addDays(-2), system.today(), 2, 1);
        invoiceList[0].Type__c = 'Actual';
        //invoiceList[0].Outstanding_Balance__c = 500;
        invoiceList[0].Billing_Period_Start_Date__c =  Date.newInstance(date.today().year(), 2, 1);
        invoiceList[0].Billing_Period_End_Date__c = Date.newInstance(date.today().year(), 3, 1)-1;
        insert invoiceList;

        List<Invoice_Line_Item__c> invoiceLineItemList = TestDataFactory_InvoiceLineItems.generateInvoiceLineItems(invoiceList[0].Id, Constants.RECORDTYPEID_INVOICE_10KPRODUCTNVOICELINEITEM, rateList[0].id, 2, 30, 1);
        insert invoiceLineItemList;
        System.assertEquals(1,invoiceLineItemList.size());
		
        List<Contact> contactList = TestDataFactory_Contacts.generatecontacts(accountList, 'Test contact', 'lastName', '', '', 1);
        insert contactList;
        
        Date monthStartDate = Date.newInstance(date.today().year(), 2, 1);
        Date monthEndDate = Date.newInstance(date.today().year(), 3, 1)-1;
        List<Ascent_Metrics__c> ascMetricList = TestDataFactory_AscentMetrics.generateAscMetric(accountList[0].Id,monthStartDate,monthEndDate,1200.00, 0.00,1);
        ascMetricList[0].Next_Tier__c = 'Everest';
        insert ascMetricList ;
        
        Test.startTest();
        
        	AccountRelatedInvoicesController controller = new AccountRelatedInvoicesController();
        controller.ascentRecordId = ascMetricList[0].id;
        controller.accId= accountList[0].id;
        controller.statusValue = true;
            controller.getInvoiceList();
        Test.stopTest();
    }

}