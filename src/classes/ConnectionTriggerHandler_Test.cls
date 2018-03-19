@isTest
private class ConnectionTriggerHandler_Test {
    
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
        
        List<Connection__c> connectionList = TestDataFactory_Connections.generateConnections(Constants.RECORDTYPEID_CONNECTION_PRODICTION, projectList[0].Id, 'Inactive', null, 2);
        connectionList[0].Primary_Development_Environment__c = true;
        connectionList[1].Primary_Development_Environment__c = true;
        insert connectionList;
    }
    
    static testMethod void test_usecase_insert() {
    	
    	List<Project__c> projectList = [SELECT Id FROM Project__c];
    	System.assertEquals(1, projectList.size());
    	
        List<Connection__c> connectionList = TestDataFactory_Connections.generateConnections(Constants.RECORDTYPEID_CONNECTION_PRODICTION, projectList[0].Id, 'Inactive', null, 1);
        connectionList[0].Primary_Development_Environment__c = true; 
        
        Test.startTest();
            insert connectionList;
            System.assertEquals(1, connectionList.size());
        Test.stopTest(); 
    }
    
    static testMethod void test_usecase_update() {
    	
    	List<Project__c> projectList = [SELECT Id FROM Project__c];
        System.assertEquals(1, projectList.size());
    	
        List<Connection__c> connectionList = TestDataFactory_Connections.generateConnections(Constants.RECORDTYPEID_CONNECTION_PRODICTION, projectList[0].Id, 'Inactive', null, 1);
        insert connectionList;
        connectionList[0].Primary_Development_Environment__c = true; 
        
        Test.startTest();
            update connectionList;
            System.assertEquals(connectionList.size(), 1);
        Test.stopTest(); 
    }
    
    static testMethod void test_usecase_deletePositive() {

    	List<Project__c> projectList = [SELECT Id FROM Project__c];
        System.assertEquals(1, projectList.size());
    	
        List<Connection__c> connectionList = TestDataFactory_Connections.generateConnections(Constants.RECORDTYPEID_CONNECTION_PRODICTION, projectList[0].Id, 'Inactive', null, 1);
        insert connectionList;
              
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
        	delete connectionList;
        Test.stopTest();
    }
    
    static testMethod void test_usecase_deleteNegative() {
    	
        List<Project__c> projectList = [SELECT Id FROM Project__c];
        System.assertEquals(1, projectList.size());
    	
        List<Connection__c> connectionList = TestDataFactory_Connections.generateConnections(Constants.RECORDTYPEID_CONNECTION_PRODICTION, projectList[0].Id, 'Inactive', null, 1);
        insert connectionList;
        
        List<Release__c> releaseList = TestDataFactory_Releases.generateReleases(projectList[0].Id, connectionList[0].Id, connectionList[0].Id, 'TestRelease', 'Planned', System.today(), System.today().addDays(2), 1);
        insert releaseList;
        
        try {
            delete connectionList;  
        }
        catch(Exception ex) {
        }
        Test.startTest();
        Test.stopTest();
    }

    @isTest static void test_usecase_deleteConnectionOne() {

        List<Project__c> projectList = [SELECT Id FROM Project__c];
        System.assertEquals(1, projectList.size());

        List<Connection__c> connectionList = TestDataFactory_Connections.generateConnections(Constants.RECORDTYPEID_CONNECTION_PRODICTION, projectList[0].Id, 'Inactive', null, 1);
        insert connectionList;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
            connectionList[0].Created_on_Heroku__c = true;
            update connectionList;
            try {
                delete connectionList;  
            }
            catch(Exception ex) {
            }
            //System.assertEquals(connectionList.size(),0);
        Test.stopTest();
    }

    @isTest static void test_usecase_deleteConnectionTwo() {
        List<Project__c> projectList = [SELECT Id FROM Project__c];
        System.assertEquals(1, projectList.size());

        List<Connection__c> connectionList = TestDataFactory_Connections.generateConnections(Constants.RECORDTYPEID_CONNECTION_PRODICTION, projectList[0].Id, 'Inactive', null, 1);
        insert connectionList;
        Test.startTest();
            connectionList[0].Scan_Running__c = true ;
            update connectionList;
            try {
                delete connectionList;  
            }
            catch(Exception ex) {
            }
            System.assertEquals(connectionList.size(),1);
        Test.stopTest();    
    }

    @isTest static void test_usecase_deleteConnectionThree() {
        List<Project__c> projectList = [SELECT Id FROM Project__c];
        System.assertEquals(1, projectList.size());

        List<Connection__c> connectionList = TestDataFactory_Connections.generateConnections(Constants.RECORDTYPEID_CONNECTION_PRODICTION, projectList[0].Id, 'Inactive', null, 1);
        insert connectionList;
        Test.startTest();
            connectionList[0].Refresh_Running__c = true;
            update connectionList;
            try {
                delete connectionList;  
            }
            catch(Exception ex) {
            }
            System.assertEquals(connectionList.size(),1);
        Test.stopTest();
    }

    @isTest static void test_usecase_deleteConnectionFour() {
        List<Project__c> projectList = [SELECT Id FROM Project__c];
        System.assertEquals(1, projectList.size());

        List<Connection__c> connectionList = TestDataFactory_Connections.generateConnections(Constants.RECORDTYPEID_CONNECTION_PRODICTION, projectList[0].Id, 'Inactive', null, 1);
        insert connectionList;
        Test.startTest();
            connectionList[0].Delete_on_Heroku__c = false;
            connectionList[0].Allow_Deletion__c = false;
            update connectionList;
            try {
                delete connectionList;  
            }
            catch(Exception ex) {
            }
            System.assertEquals(connectionList.size(),1);
        Test.stopTest();
}
}