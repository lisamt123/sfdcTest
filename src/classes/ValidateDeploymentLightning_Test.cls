@isTest
private class ValidateDeploymentLightning_Test {
    
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
    }
      
    @isTest static void use_testcase_one() {
        
        List<Release__c> releaseList = [Select Id From Release__c];
        System.assertEquals(2, releaseList.size());
       
        Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
        
        Test.startTest();
	    	String JSNStr = ValidateDeploymentLightning.init(releaseList[0].Id);
	    	
	    	ValidateDeploymentLightning.retriveDeploymentLogIssues('Test123ATOZ',releaseList[0].Id);
            //String checkOnly, Id releaseId,Boolean runAllTests,String testClassNames,String recentValidationId
	     	ValidateDeploymentLightning.deployMetadata('true',releaseList[0].Id,'','','');
	     	
	     	
	        
	        ValidateDeploymentLightning.LogResponse dlog = (ValidateDeploymentLightning.LogResponse) JSON.deserialize(JSNStr, ValidateDeploymentLightning.LogResponse.class);
	    	System.assert(dlog.logList.size() > 0);
        Test.stopTest();
    }
    
    @isTest static void use_testcase_two() {
        
        List<Release__c> releaseList = [Select Id,Created_On_Heroku__c From Release__c];
        releaseList[0].Created_On_Heroku__c = false;
        releaseList[0].Source__c = null;
        releaseList[0].Target__c = null;
        update releaseList;
        System.assertEquals(2, releaseList.size());
       
        Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
        
        Test.startTest();
	    	String JSNStr = ValidateDeploymentLightning.init(releaseList[0].Id);
	    	
	    	ValidateDeploymentLightning.retriveDeploymentLogIssues('Test123ATOZ',releaseList[0].Id);
            //String checkOnly, Id releaseId,Boolean runAllTests,String testClassNames,String recentValidationId
	     	ValidateDeploymentLightning.deployMetadata('true',releaseList[0].Id,'','','');
	        
	        ValidateDeploymentLightning.LogResponse dlog = (ValidateDeploymentLightning.LogResponse) JSON.deserialize(JSNStr, ValidateDeploymentLightning.LogResponse.class);
        Test.stopTest();
    }
    
    @isTest static void use_testcase_three() {
        
        List<Release__c> releaseList = [Select Id,Created_On_Heroku__c,Validation_Running__c,AsyncResultId__c From Release__c];
        releaseList[0].Validation_Running__c = true;
        releaseList[0].AsyncResultId__c = 'a0X2C000000E9zIUAS';
        update releaseList;
        System.assertEquals(2, releaseList.size());
       
        Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
        
        Test.startTest();
	     	ValidateDeploymentLightning.ValidationResponseWrapper wrap = ValidateDeploymentLightning.retrieveRelease(releaseList[0].Id);
	     	System.assertEquals(releaseList[0].Id,wrap.release.Id);
        Test.stopTest();
    }

    @isTest static void use_testcase_four() {
        
        List<Release__c> releaseList = [Select Id,Source__c,Target__c From Release__c];
        releaseList[0].Source__c = null;
        update releaseList;
        System.assertEquals(2, releaseList.size());
       
        Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
        
        Test.startTest();
            String JSNStr = ValidateDeploymentLightning.init(releaseList[0].Id);
            System.assertNotEquals(JSNStr,null);
        Test.stopTest();
    }

    @isTest static void use_testcase_five() {
        
        List<Release__c> releaseList = [Select Id,Source__c,Target__c From Release__c];
        releaseList[0].Target__c = null;
        update releaseList;
        System.assertEquals(2, releaseList.size());
       
        Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
        
        Test.startTest();
            String JSNStr = ValidateDeploymentLightning.init(releaseList[0].Id);
            System.assertNotEquals(JSNStr,null);
        Test.stopTest();
    }
    @isTest static void test_usecase_six() {
        
        List<Release__c> releaseList = [Select Id From Release__c];
        System.assertEquals(2, releaseList.size());
       
        Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
        Test.startTest();
            ValidateDeploymentLightning.manageRelease(releaseList[0].Id);
            ValidateDeploymentLightning.manageRelease(releaseList[1].Id);
            
            releaseList = [Select Id From Release__c WHERE Id=:releaseList[1].Id AND Created_On_Heroku__c=true];
            System.assertEquals(1, releaseList.size());
        Test.stopTest();
    }
}