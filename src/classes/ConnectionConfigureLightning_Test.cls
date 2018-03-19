@isTest
private class ConnectionConfigureLightning_Test {
	
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
        connectionList[0].Created_On_Heroku__c = true;
      	insert connectionList;
      	
    }

    @isTest static void test_usecase_one() {
    	List<Connection__c> connectionList = [Select Id,Status__c From Connection__c];
        System.assertEquals(2, connectionList.size());
        Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
        Test.startTest();

	        ConnectionConfigureLightning.ResponseResultWrapper wrapperResponse = ConnectionConfigureLightning.retrieveConnectionData(connectionList[0].Id);
	        System.assertEquals(wrapperResponse.message,null);

	        wrapperResponse = ConnectionConfigureLightning.retrieveConnectionMetaDataInfo('aparbriskminds/12feb',connectionList[0].Id);
	        System.assertEquals(wrapperResponse.message,'SUCCESS');

	        String resp = ConnectionConfigureLightning.updateGitConnection('aparbriskminds/12feb',connectionList[0].Id,'ApexClass');
	        System.assertEquals(resp,'success');

        Test.stopTest();
    }
	
}