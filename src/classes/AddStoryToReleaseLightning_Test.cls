@isTest
private class AddStoryToReleaseLightning_Test 
{
	@testSetUp static void createData() {
        
        TestDataFactory_CustomSettings.createConnectedAppCustomSetting();
        
        Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
                                                            'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                            'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
                                                            null, 'Net 30', 'test@test.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
                                                            1);
        insert accList;
        
        List<Project__c> projectList = TestDataFactory_Projects.generateProjects(accList[0].Id, 'Test Project', 1);
        insert projectList;
        
        List<Connection__c> connectionList = TestDataFactory_Connections.generateConnections(Constants.RECORDTYPEID_CONNECTION_PRODICTION, projectList[0].Id, 'Active', null, 2);
        connectionList[0].Primary_Development_Environment__c = true;
        connectionList[0].Status__c = 'Active' ;
        connectionList[1].Status__c = 'Active' ;
        connectionList[0].Created_On_Heroku__c = true ;
        connectionList[1].Created_On_Heroku__c = false ;
        insert connectionList;
        
        List<Story__c> storiesList = TestDataFactory_Stories.generateStories('Test Story', projectList[0].Id, 'Draft', 'Medium', 1);
        storiesList[0].Created_On_Heroku__c = true;
        insert storiesList;

        List<Release__c> releaseList = TestDataFactory_Releases.generateReleases(projectList[0].Id, connectionList[0].Id, connectionList[1].Id, 'Test Release', 'Planned', Date.today().addDays(1), Date.today().addDays(6), 1);
        releaseList[0].Target__c = connectionList[0].Id ;
        insert releaseList;
    }

    @isTest static void test_retrieveReleaseList() {
   		List<Story__c> storyList = [SELECT Id, Name, Project__c FROM Story__c];
    	Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
    		AddStoryToReleaseLightning.ResultWrapper resultWrapper = AddStoryToReleaseLightning.retrieveReleaseList(storyList[0].Id);
    		if(resultWrapper != null) {
    			System.assertEquals(resultWrapper.story.Id,storyList[0].Id);
    		}
    	Test.stopTest();
    }
	
	@isTest static void test_createRelease() {
		List<Project__c> projectList = [SELECT Id, Name FROM Project__c limit 1];
		List<Connection__c> connectionList = [SELECT Id, Status__c, Created_On_Heroku__c FROM Connection__c limit 2];
		List<Release__c> releaseList = TestDataFactory_Releases.generateReleases(projectList[0].Id, connectionList[0].Id, connectionList[1].Id, 'Test Release', 'Planned', Date.today().addDays(1), Date.today().addDays(6), 1);
		Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
    		AddStoryToReleaseLightning.ResponseWrapper responseWrapper = AddStoryToReleaseLightning.createRelease(releaseList[0]);
    		if(responseWrapper != null) {
    			System.assertEquals(!String.isBlank(responseWrapper.releaseId),true);
    		}
    	Test.stopTest();
	}

	@isTest static void test_updateReleaseStoryArtifacts() {
		List<Release__c> releaseList = [SELECT Id, Name, Source__c FROM Release__c limit 1];
		List<Story__c> storyList = [SELECT Id, Name, Project__c FROM Story__c];
		Test.startTest();
    		Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
    		AddStoryToReleaseLightning.ResponseWrapper responseWrapper = AddStoryToReleaseLightning.updateReleaseStoryArtifacts(releaseList[0].Id, storyList[0].Id);
    		if(responseWrapper != null) {
    			System.assertEquals(responseWrapper.status,'Success');
    		}
    	Test.stopTest();
	}

	@isTest static void test_updateReleaseAndStory() {
		List<Release__c> releaseList = [SELECT Id, Name, Source__c FROM Release__c limit 1];
		List<Story__c> storyList = [SELECT Id, Name, Project__c FROM Story__c];
		Test.startTest();
    		AddStoryToReleaseLightning.updateReleaseAndStory(releaseList[0].Id, storyList[0].Id);
    	Test.stopTest();
	}
}