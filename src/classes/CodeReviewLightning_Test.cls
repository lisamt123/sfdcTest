@isTest
private class CodeReviewLightning_Test {
	
	@testSetup static void setupData() {
		
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
      	connectionList[0].Status__c = 'Active';
        connectionList[0].Primary_Development_Environment__c = true;
        connectionList[0].Created_On_Heroku__c = true;
      	insert connectionList;
      	
      	List<Release__c> releaseList = TestDataFactory_Releases.generateReleases(projectList[0].Id, connectionList[0].Id, connectionList[0].Id, 'TestRelease', 'Planned', System.today(), System.today().addDays(2), 2);
        releaseList[0].Created_On_Heroku__c = true;
        releaseList[1].Created_On_Heroku__c = false;
        insert releaseList;
        
        List<Story__c> storyList = TestDataFactory_Stories.generateStories('testStory', projectList[0].id,'','',1);
        insert storyList;
	}
	
	@isTest static void use_testcase_one() {
		
		List<Release__c> releaseList = [Select Id From Release__c];
		System.assertEquals(2, releaseList.size());
		
        Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
        Test.startTest();
            String jsnSTR = CodeReviewLightning.getCodeReviewFunctionality(releaseList[0].Id);
            CodeReviewLightning.LogResponse mainLogResponse = (CodeReviewLightning.LogResponse) JSON.deserialize(jsnSTR, CodeReviewLightning.LogResponse.class);
            CodeReviewLightning.retriveScanLogIssues('Test123ACQ','Release__c','0',releaseList[0].Id);
            CodeReviewLightning.scanCode(releaseList[0].Id,'Release__c');
          
            System.assert(mainLogResponse.logList.size() > 0);
        Test.stopTest();
	}
	
	@isTest static void use_testcase_two() {
		
		List<Story__c> storyList = [Select Id From Story__c];
		System.assertEquals(1, storyList.size());
        
        Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
        Test.startTest();
			String jsnSTR = CodeReviewLightning.getCodeReviewFunctionality(storyList[0].Id);
          	CodeReviewLightning.LogResponse mainLogResponse = (CodeReviewLightning.LogResponse) JSON.deserialize(jsnSTR, CodeReviewLightning.LogResponse.class);
	          
          	CodeReviewLightning.retriveScanLogIssues('Test123ACQ','Story__c','0',storyList[0].Id);
          	CodeReviewLightning.scanCode(storyList[0].Id,'Story__c');
	          
          	System.assert(mainLogResponse.objctAPIName == 'Story__c');
        Test.stopTest();
	}
    @isTest static void use_testcase_three() {
    
        List<Connection__c> connectionList = [Select Id From Connection__c];
        System.assertEquals(1, connectionList.size());
    
        Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
        Test.startTest();
        String jsnSTR = CodeReviewLightning.getCodeReviewFunctionality(connectionList[0].Id);
            CodeReviewLightning.LogResponse mainLogResponse = (CodeReviewLightning.LogResponse) JSON.deserialize(jsnSTR, CodeReviewLightning.LogResponse.class);
            
            CodeReviewLightning.retriveScanLogIssues('Test123ACQ','Connection__c','0',connectionList[0].Id);
            CodeReviewLightning.scanCode(connectionList[0].Id,'Connection__c');
            
            System.assert(mainLogResponse.objctAPIName == 'Connection__c');
        Test.stopTest();
    }
    @isTest static void test_usecase_four() {
        
        List<Release__c> releaseList = [Select Id From Release__c];
        System.assertEquals(2, releaseList.size());
       
        Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
        Test.startTest();
            CodeReviewLightning.manageRelease(releaseList[0].Id);
            CodeReviewLightning.manageRelease(releaseList[1].Id);
            
            releaseList = [Select Id From Release__c WHERE Id=:releaseList[1].Id AND Created_On_Heroku__c = true];
            System.assertEquals(1, releaseList.size());
        Test.stopTest();
    }
}