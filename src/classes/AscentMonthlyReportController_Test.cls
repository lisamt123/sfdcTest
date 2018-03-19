@isTest
public class AscentMonthlyReportController_Test {
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
        oppList[0].Start_Date__c = System.today().addDays(-75);
        oppList[0].End_Date__c = System.today().addDays(307);
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
        invoiceList[0].Billing_Period_Start_Date__c = Date.today() -20 ;
        invoiceList[0].Billing_Period_End_Date__c = Date.today() -10 ;
        insert invoiceList;

        List<Invoice_Line_Item__c> invoiceLineItemList = TestDataFactory_InvoiceLineItems.generateInvoiceLineItems(invoiceList[0].Id, Constants.RECORDTYPEID_INVOICE_10KPRODUCTNVOICELINEITEM, rateList[0].id, 2, 30, 1);
        insert invoiceLineItemList;
		System.assertEquals(1,invoiceLineItemList.size());
        
        List<Contact> contactList = TestDataFactory_Contacts.generatecontacts(accountList, 'Test contact', 'lastName', '', '', 1);
        insert contactList;

        List<Product2> prod =  TestDataFactory_Products.generateProducts('Developer - Time & Materials', 'Developer');
        insert prod;

        Id standardPriceBookId = Test.getStandardPricebookId();

        List<PricebookEntry> standardPrice = TestDataFactory_PriceBookEntries.generatePriceBookEntries(standardPriceBookId, prod[0].Id, 10000, true);
        insert standardPrice;
        
        Id servicesRecordTypeId = Schema.SObjectType.Pricebook2.getRecordTypeInfosByName().get('Services Price Book').getRecordTypeId();
        List<PriceBook2> pb = TestDataFactory_PriceBooks.generatePriceBooks('Custom Test PriceBook', true, 'Base', 'Testing', 1);
        pb[0].RecordTypeId = servicesRecordTypeId;
        insert pb;
        
        List<PricebookEntry> customPrice = TestDataFactory_PriceBookEntries.generatePriceBookEntries(pb[0].Id, prod[0].Id, 12000, true);
        insert customPrice;

        Date monthStartDate = Date.newInstance(date.today().year(), 2, 1);
        Date monthEndDate = Date.newInstance(date.today().year(), 3, 1)-1;
        List<Ascent_Metrics__c> ascMetricList = TestDataFactory_AscentMetrics.generateAscMetric(accountList[0].Id,monthStartDate,monthEndDate,1200.00, 0.00,1);
        insert ascMetricList ;
       
        List<OpportunityContactRole> oppListContactRole = TestDataFactory_OpportunityContactRole.generateOpportunityContactRole(oppList[0].Id,contactList[0].Id,'Test',1);
        insert oppListContactRole;
        
        List<OpportunityLineItem> oppLineItemList = TestDataFactory_OpportunityLineItem.generateOpportunityLineItem(oppList[0].Id, 5, customPrice[0].Id, customPrice[0].UnitPrice, 2);
        insert oppLineItemList ;

        List<AscentMonthlyReportController.ContactOppRoleWrapper>  contactRoleWrapperList = new List<AscentMonthlyReportController.ContactOppRoleWrapper>();
        contactRoleWrapperList.add(new AscentMonthlyReportController.ContactOppRoleWrapper(contactList[0].Name,contactList[0].Id));
        List<AscentMonthlyReportController.AccountAscendMetricWrapper> accountAscendMetricWrapperList = new List<AscentMonthlyReportController.AccountAscendMetricWrapper>();      
        accountAscendMetricWrapperList.add(new AscentMonthlyReportController.AccountAscendMetricWrapper(true,ascMetricList[0],contactRoleWrapperList,2,System.today()));
        
        
        Test.startTest();
        	AscentMonthlyReportController.doInitAscMetric();
        	AscentMonthlyReportController.ascendMetricValues('Febuary '+Date.today().year());
            AscentMonthlyReportController.sendAscentReportEmail(JSON.serialize(accountAscendMetricWrapperList));
            AscentMonthlyReportController.viewPdf(ascMetricList[0].Id);
        Test.stopTest();
    }
}