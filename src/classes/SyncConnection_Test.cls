@isTest
private class SyncConnection_Test {
	
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
      	connectionList[0].Primary_Development_Environment__c = true;
      	
      	insert connectionList;

      	connectionList[0].Comparing_Connections__c = connectionList[1].Id;
      	connectionList[1].Comparing_Connections__c = connectionList[0].Id;

      	update connectionList;
	}	
	
	static testMethod void test_usecase_one() {

		List<Connection__c> connectionList = [SELECT Id FROM Connection__c];
		
		RestRequest req = new RestRequest(); 
		req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/syncConnection' ;
		req.addParameter('Connection_Id', connectionList[0].Id);
		req.addParameter('Task', 'MetadataDescribe');
		req.httpMethod = 'POST';
		RestContext.request = req;

		Test.startTest();
			String result = SyncConnection.syncConnectionRecord();
			System.assertEquals('Success', result);
		Test.stopTest();
	} 
	
	static testMethod void test_usecase_two() {

		List<Connection__c> connectionList = [SELECT Id FROM Connection__c];
		
		RestRequest req = new RestRequest();
		req.addParameter('refreshStstus','true');
		req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/syncConnection' ;
		req.addParameter('Connection_Id', connectionList[0].Id);
		req.addParameter('Task', 'MetadataDescribe');
		req.httpMethod = 'POST';
		RestContext.request = req;

		Test.startTest();
			String result = SyncConnection.syncConnectionRecord();
			System.assertEquals('Success', result);
		Test.stopTest();
	} 
	
	static testMethod void test_usecase_three() {

		List<Connection__c> connectionList = [SELECT Id FROM Connection__c];
		
		RestRequest req = new RestRequest();
		req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/syncConnection' ;
		req.addParameter('Connection_Id', connectionList[0].Id);
		req.addParameter('Task', 'CodeReview');
		req.addParameter('Status', 'Success');
		req.addParameter('Describe_Error', 'No violation found.');
		req.httpMethod = 'POST';
		RestContext.request = req;

		Test.startTest();
			String result = SyncConnection.syncConnectionRecord();
			System.assertEquals('Success', result);
		Test.stopTest();
	} 
	static testMethod void test_usecase_Four() {

		List<Connection__c> connectionList = [SELECT Id, Comparing_Connections__c  FROM Connection__c];
		System.assertEquals(connectionList.size(),2);
		System.assertEquals(connectionList[0].Comparing_Connections__c,connectionList[1].Id);
		System.assertEquals(connectionList[1].Comparing_Connections__c,connectionList[0].Id);
		
		RestRequest req = new RestRequest();
		req.addParameter('refreshStstus','true');
		req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/syncConnection' ;
		req.addParameter('Connection_Id', connectionList[0].Id);
		req.addParameter('targetConnection', connectionList[1].Id);
		req.addParameter('Task', 'ConnectionCompare');
		req.httpMethod = 'POST';
		RestContext.request = req;

		Test.startTest();
			String result = SyncConnection.syncConnectionRecord();
			System.assertEquals('Success', result);
		Test.stopTest();
	} 
}