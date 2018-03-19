@isTest
private class SelectRateCardController_Test {
	static testMethod void test_method_one() {
		
	Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accountList    = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test Account', 'Prospect', 15, 
                                                                                'code coverage', 'internal', 'App Cloud;Sales Cloud', 'Enterprise', 
                                                                                'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                                                'code quality with code coverage above 75%', 'NDA aggrement', 'United States', 
                                                                                '501 test street', 'test city', 'Florida', '90001', null, null, 'Net 30', 
                                                                                'acc@testemail.com', 'TestA', 'HELLO WORLD', 'invoicingNotes', 
                                                                                'Partner Client', 1);
        insert accountList;

        List<Product2> prod =  TestDataFactory_Products.generateProducts('Test Product', 'Developer');
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

        Id msaRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('MSA Opportunity').getRecordTypeId();
        List<Opportunity> oppList = TestDataFactory_Opportunity.generateOpportunities(accountList[0].Id,msaRecordTypeId, 'Closed Won', system.today().addDays(2),system.today().addDays(-30),system.today().addDays(-2), 1);
        insert oppList;

        Test.startTest();
        	SelectRateCardController.getClosedOpportunity(oppList[0].Id);
        	SelectRateCardController.getPriceBook(oppList[0]);
        	SelectRateCardController.updateOpportunity(oppList[0].Id,pb[0].Id,pb[0].Name);
        Test.stopTest();
	}
}