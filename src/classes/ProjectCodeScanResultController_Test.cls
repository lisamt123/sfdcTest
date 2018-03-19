@isTest
private class ProjectCodeScanResultController_Test { 
	
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
        
      	List<Connection__c> connectionList = TestDataFactory_Connections.generateConnections(Constants.RECORDTYPEID_CONNECTION_PRODICTION, projectList[0].Id, 'Active', null, 2);
      	connectionList[0].Status__c = 'Active';
        connectionList[0].Primary_Development_Environment__c = true;
      	insert connectionList;
      	
      	List<Release__c> releaseList = TestDataFactory_Releases.generateReleases(projectList[0].Id, connectionList[0].Id, connectionList[0].Id, 'TestRelease', 'Planned', System.today(), System.today().addDays(2), 1);
        releaseList[0].Created_On_Heroku__c = true;
        insert releaseList;
	}
	
	@isTest static void test_usecase_one() {
		
		List<Project__c> projectList = [Select Id From Project__c];
		System.assertEquals(1, projectList.size());
        
        Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
        Test.startTest();
            ApexPages.StandardController standardController1 = new ApexPages.StandardController(projectList[0]);
	        ProjectCodeScanResultController review1 = new ProjectCodeScanResultController(standardController1);
	        System.assertEquals(projectList[0].Id, review1.project.Id);
	        
	        System.assert(review1.logsList.size() > 0);
        Test.stopTest();
	}
	
	@isTest static void test_usecase_two() {
		
		List<Project__c> projectList = [Select Id From Project__c];
        List<Release__c> releaseList = [Select Id From Release__c];
        System.assertEquals(1, projectList.size());
        System.assertEquals(1, releaseList.size());
        
        Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
        Test.startTest();
			ApexPages.StandardController standardController2 = new ApexPages.StandardController(projectList[0]);
	        ProjectCodeScanResultController review2 = new ProjectCodeScanResultController(standardController2);
	        System.assertEquals(projectList[0].Id, review2.project.Id);
	        
	        ProjectCodeScanResultController.retriveReleaseReviewLogs(releaseList[0].Id);
	        ProjectCodeScanResultController.retriveScanCodeResult('Test123AQZP');
	        System.assert(review2.logsList.size() > 0);
        Test.stopTest();
	}
}