@isTest
private class CustomLookupComponentController_Test {
	
	@isTest static void test_method_one() {
		// Implement test code
		Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
    														'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
    														'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
    														null, 'Net 30', 'test@test.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
    														1);
        insert accList;
        Test.startTest();
         	List<CustomLookupComponentController.Result> result = CustomLookupComponentController.lookup('Test','Account','','');
         	result = CustomLookupComponentController.initialData('Account','','');
         	String accountName = CustomLookupComponentController.populateRecordName(accList[0].Id,'Account');
         	System.assertEquals('Test1',accountName);
        Test.stopTest();

	}
}