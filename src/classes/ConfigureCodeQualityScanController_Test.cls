@isTest
private class ConfigureCodeQualityScanController_Test {
	
	@testSetup static void setupData() {
		Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
                                                            'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                            'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
                                                            null, 'Net 30', 'test@test.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
                                                            1);
        insert accList;

        List<Contact> contactList           = TestDataFactory_Contacts.generatecontacts(accList, 'Test contact', 'lastName', '', '', 1);
        insert contactList;

        List<Project__c> projectList = TestDataFactory_Projects.generateProjects(accList[0].Id, 'Test Project', 2);
        insert projectList;
	}

	@isTest static void test_method_one() {
		List<Project__c> projectList = [SELECT Id from Project__c limit 1];
		if(projectList.size() > 0) {
			Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
			Test.startTest();
				List<ConfigureCodeQualityScanController.RuleSetWrapper> ruleWrapperList = ConfigureCodeQualityScanController.retrieveCodeScanProperties(projectList[0].Id);
				String ruleSetWrapperListJSON = JSON.serialize(ruleWrapperList);
				String returnMsg = ConfigureCodeQualityScanController.updateCodeScanProperties(projectList[0].Id,ruleSetWrapperListJSON);
				System.assertEquals('Success',returnMsg);
			Test.stopTest();	
		}
		
	}

}