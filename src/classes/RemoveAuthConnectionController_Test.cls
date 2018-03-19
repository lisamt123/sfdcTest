@isTest
private class RemoveAuthConnectionController_Test {
  
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
        
      	List<Connection__c> connectionList = TestDataFactory_Connections.generateConnections(Constants.RECORDTYPEID_CONNECTION_PRODICTION, projectList[0].Id, 'Inactive', null, 1);
      	insert connectionList;
  	}
  	
  	static testMethod void test_usecase_one() {
  		
  		List<Connection__c> connectionList = [Select Id From Connection__c];
  		System.assertEquals(1, connectionList.size());
  		
	    ApexPages.StandardController sc = new ApexPages.StandardController(connectionList[0]);
	    RemoveAuthConnectionController cntrlr = new RemoveAuthConnectionController(sc);
	    
	    Test.startTest();
			cntrlr.returnBack();
	    	System.assertEquals(connectionList[0].Id,cntrlr.connection.Id);
	    Test.stopTest();
  	}
  	
  	static testMethod void test_usecase_two() {
  		
  		List<Connection__c> connectionList = [Select Id From Connection__c];
	    ApexPages.StandardController sc = new ApexPages.StandardController(connectionList[0]);
	    RemoveAuthConnectionController cntrlr = new RemoveAuthConnectionController(sc);
	    
	    Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
	    
	    Test.startTest();
	      	RemoveAuthConnectionController.removeAuth(connectionList[0].Id);
	      	Connection__c con = [SELECT Id, Status__c FROM Connection__c WHERE Id =:connectionList[0].Id];
	      	System.assertEquals(con.Status__c,'Disabled');
	    Test.stopTest();
  	}
}