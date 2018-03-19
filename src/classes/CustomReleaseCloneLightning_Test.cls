@isTest
private class CustomReleaseCloneLightning_Test {
	@testSetup static void testSetup() {
		Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
                                                            'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                            'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
                                                            null, 'Net 30', 'test@test.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
                                                            1);
        insert accList;
        
        List<Project__c> projectList = TestDataFactory_Projects.generateProjects(accList[0].Id, 'Test Project', 1);
        insert projectList;
        
        List<Connection__c> connectionList = TestDataFactory_Connections.generateConnections(Constants.RECORDTYPEID_CONNECTION_PRODICTION, projectList[0].Id, 'Active', null, 1);
        connectionList[0].Primary_Development_Environment__c = true;
        insert connectionList;
        
        List<Release__c> releaseList = TestDataFactory_Releases.generateReleases(projectList[0].Id, connectionList[0].Id, connectionList[0].Id, 'TestRelease', 'Planned', System.today(), System.today().addDays(2), 2);
        releaseList[0].Created_On_Heroku__c = false;
        releaseList[1].Created_On_Heroku__c = true;
        insert releaseList;
	}

	@isTest static void test_usecase_one() {
		List<Release__c> releaseList = [SELECT Id,Actual_Release_Date__c,Allow_Deletion__c,Created_On_Heroku__c,Name,Project__c,Source__c,Target__c FROM Release__c limit 1];
		if(releaseList.size() > 0) {
			Release__c releaseObj = releaseList[0];
			Test.startTest();
				Map<String,Object> fieldsValueMap = CustomReleaseCloneLightning.getRecordData('Release__c',releaseObj.Id,'Allow_Deletion__c,Created_On_Heroku__c');
				System.assertEquals(true,fieldsValueMap.containsKey('Name'));
			Test.stopTest();
		}
	}

	@isTest static void test_usecase_two() {
		List<Release__c> releaseList = [SELECT Id,Actual_Release_Date__c,Allow_Deletion__c,Created_On_Heroku__c,Name,Project__c,Source__c,Target__c FROM Release__c limit 2];
		if(releaseList.size() > 0) {
			Test.setMock(HttpCalloutMock.class,  new MockResponse_HerokuConnection());
			Test.startTest();
				CustomReleaseCloneLightning.cloning(releaseList[0].Id,releaseList[1].Id);
			Test.stopTest();
		}
	}
}