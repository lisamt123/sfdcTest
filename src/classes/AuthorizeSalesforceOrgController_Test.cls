@isTest
private class AuthorizeSalesforceOrgController_Test {
    
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
    	
        List<Connection__c> connectionList  = [Select Id, RecordTypeId From Connection__c WHERE RecordTypeId=:Constants.RECORDTYPEID_CONNECTION_PRODICTION];
        System.assertEquals(1, connectionList.size());
        
        Test.setCurrentPage(new PageReference('/apex/AuthorizeSalesforceOrg'));
        ApexPages.StandardController standardController = new ApexPages.StandardController(connectionList[0]);
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
        AuthorizeSalesforceOrgController controller = new AuthorizeSalesforceOrgController(standardController);
          
        Test.startTest();
            PageReference page = controller.retrieveAuthCode(); 
            System.assertNotEquals(null, page);
            
            Test.setCurrentPage(page); 
            controller.code = 'Test';
            
            controller.retrieveTokens();
            System.assertEquals(true,controller.isUpdate);
            
            boolean isLightningView = controller.isLightningExperience();
            System.assertEquals(false,isLightningView);
        Test.stopTest();
    }
    
    @isTest static void test_usecase_two() {

        List<Connection__c> connectionList  = [Select Id, RecordTypeId From Connection__c WHERE RecordTypeId=:Constants.RECORDTYPEID_CONNECTION_SANDBOX];
        System.assertEquals(1, connectionList.size());
        Test.setCurrentPage(new PageReference('/apex/AuthorizeSalesforceOrg'));
        ApexPages.StandardController standardController = new ApexPages.StandardController(connectionList[0]);
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
        
        ApexPages.currentPage().getParameters().put('code','Test');
        String stateJson = JSON.serialize(new AuthorizeSalesforceOrgController.StateWrapper('https://login.salesforce.com',connectionList[0].Id));
        ApexPages.currentPage().getParameters().put('state', stateJson);
        
        AuthorizeSalesforceOrgController controller = new AuthorizeSalesforceOrgController(standardController);
        
        Test.startTest();
        	PageReference page = controller.retrieveAuthCode(); 
            System.assertNotEquals(null, page);
            
            controller.retrieveTokens();
            System.assertEquals(true,controller.isUpdate);
            
        	Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
            PageReference newPage = controller.updateConnection();
            
            List<Connection__c> conResList = [Select Id, RecordTypeId, Created_On_Heroku__c From Connection__c WHERE Created_On_Heroku__c = true AND Id=:connectionList[0].Id];
            System.assertEquals(1,conResList.size());
        Test.stopTest();
    }
    
    @isTest static void test_usecase_three() {

        List<Connection__c> connectionList  = [Select Id, RecordTypeId From Connection__c WHERE RecordTypeId=:Constants.RECORDTYPEID_CONNECTION_OTHER];
        System.assertEquals(1, connectionList.size());
        Test.setCurrentPage(new PageReference('/apex/AuthorizeSalesforceOrg'));
        ApexPages.StandardController standardController = new ApexPages.StandardController(connectionList[0]);
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
        
        ApexPages.currentPage().getParameters().put('code','Test');
        String stateJson = JSON.serialize(new AuthorizeSalesforceOrgController.StateWrapper('https://login.salesforce.com',connectionList[0].Id));
        ApexPages.currentPage().getParameters().put('state', stateJson);
        
        AuthorizeSalesforceOrgController controller = new AuthorizeSalesforceOrgController(standardController);
        
        Test.startTest();
        	PageReference page = controller.retrieveAuthCode(); 
            System.assertNotEquals(null, page);
            
            controller.retrieveTokens();
            System.assertEquals(true,controller.isUpdate);
            
        	Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
            PageReference newPage = controller.updateConnection();
            
            List<Connection__c> conResList = [Select Id, RecordTypeId, Created_On_Heroku__c From Connection__c WHERE Created_On_Heroku__c = true AND Id=:connectionList[0].Id];
            System.assertEquals(1,conResList.size());
        Test.stopTest();
    }
    
    @isTest static void test_usecase_four() {

        List<Connection__c> connectionList  = [Select Id, RecordTypeId, Created_On_Heroku__c From Connection__c WHERE RecordTypeId=:Constants.RECORDTYPEID_CONNECTION_OTHER];
        System.assertEquals(1, connectionList.size());
        connectionList[0].Created_On_Heroku__c = true;
        update connectionList;
        
        Test.setCurrentPage(new PageReference('/apex/AuthorizeSalesforceOrg'));
        ApexPages.StandardController standardController = new ApexPages.StandardController(connectionList[0]);
        Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
        
        ApexPages.currentPage().getParameters().put('code','Test');
        String stateJson = JSON.serialize(new AuthorizeSalesforceOrgController.StateWrapper('https://login.salesforce.com',connectionList[0].Id));
        ApexPages.currentPage().getParameters().put('state', stateJson);
        
        AuthorizeSalesforceOrgController controller = new AuthorizeSalesforceOrgController(standardController);
        
        Test.startTest();
        	PageReference page = controller.retrieveAuthCode(); 
            System.assertNotEquals(null, page);
            
            controller.retrieveTokens();
            System.assertEquals(true,controller.isUpdate);
            
        	Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
            PageReference newPage = controller.updateConnection();
            List<Connection__c> conResList = [Select Id, RecordTypeId, Created_On_Heroku__c From Connection__c WHERE Created_On_Heroku__c = true AND Id=:connectionList[0].Id];
            System.assertEquals(1,conResList.size());
        Test.stopTest();
    }
}