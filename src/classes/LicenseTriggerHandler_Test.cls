@isTest
private class LicenseTriggerHandler_Test {
	
	@testSetup static void testSetup () {
		Id partnerClientrecordTypeId        = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList               = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
                                                            'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                            'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
                                                            null, 'Net 30', 'test@test.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
                                                            1);
        insert accList;

        List<Contact> contactList           = TestDataFactory_Contacts.generatecontacts(accList, 'Test contact', 'lastName', '', '', 1);
        insert contactList;

        List<User> userList                 = TestDataFactory_Users.generateUsers(contactList[0].Id, '10K Delivery Partner (License)', true, 1);
        insert userList;
        Id licenseRecordTypeId = Schema.getGlobalDescribe().get('sfLma__License__c').getDescribe().getRecordTypeInfosByName().get('Active').getRecordTypeId();
		List<sfLma__License__c> licenseList = TestDataFactory_License.generateLicense(accList[0].Id, contactList[0].Id, licenseRecordTypeId, 'Active', 1);
		licenseList[0].sfLma__Package_License_ID__c = 'Testing' ;
		licenseList[0].sfLma__Seats__c = -1 ;
		insert licenseList ;
        
	}

	@isTest static void test_method_one() {
		List<Account> accList = [SELECT Id from Account];
		List<Contact> contactList = [SELECT Id from Contact];
		Id licenseRecordTypeId = Schema.getGlobalDescribe().get('sfLma__License__c').getDescribe().getRecordTypeInfosByName().get('Active').getRecordTypeId();
		List<sfLma__License__c> licenseList = TestDataFactory_License.generateLicense(accList[0].Id, contactList[0].Id, licenseRecordTypeId, 'Active', 1);
		licenseList[0].sfLma__Account__c = null ;
		licenseList[0].sfLma__Contact__c = null ;
		licenseList[0].sfLma__Package_License_ID__c = 'Testing' ;
		licenseList[0].sfLma__Seats__c = -1 ;
		Test.startTest();
			insert licenseList ;
		Test.stopTest();
		List<sfLma__License__c> licenseFetchList = [SELECT Id,sfLma__Account__c,sfLma__Contact__c FROM sfLma__License__c where Id IN:licenseList];
		System.assertNotEquals(null,licenseFetchList[0].sfLma__Account__c);
		System.assertNotEquals(null,licenseFetchList[0].sfLma__Contact__c);
	}
	
}