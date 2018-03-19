@isTest
private class RefreshArtifactsController_Test {
	
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
        
      	List<Connection__c> connectionList = TestDataFactory_Connections.generateConnections(Constants.RECORDTYPEID_CONNECTION_PRODICTION, projectList[0].Id, 'Inactive', null, 1);
      	connectionList.addAll(TestDataFactory_Connections.generateConnections(Constants.RECORDTYPEID_CONNECTION_SANDBOX, projectList[0].Id, 'Inactive', null, 1));
      	connectionList.addAll(TestDataFactory_Connections.generateConnections(Constants.RECORDTYPEID_CONNECTION_OTHER, projectList[0].Id, 'Inactive', 'https://login.salesforce.com', 1));
      	insert connectionList;
    }
    
    @isTest static void test_usecase_one() {
    	
        List<Connection__c> connectionList = [Select Id, Name, RecordTypeId, Created_On_Heroku__c, Metadata_Describe_Error__c,Organization_URL__c FROM Connection__c ];
        System.assertEquals(3, connectionList.size());
        
        Test.setCurrentPage(new PageReference('/apex/ReleaseArtifacts'));
        ApexPages.StandardController standardController = new ApexPages.StandardController(connectionList[1]);
        Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
        RefreshArtifactsController controller = new RefreshArtifactsController(standardController);
        System.assertEquals(controller.responseMessage,'Please Authorize the connection before refreshing.');
        Test.startTest();
        
            controller.refreshArtifacts(); 
            System.assertEquals('Success',controller.responseMessage);
            controller.redirectBackToConnection();
            
        Test.stopTest();
    }
}