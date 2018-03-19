@isTest
private class StoryTriggerHandler_Test 
{
    
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
        
        List<Sprint__c> sprintList = TestDataFactory_Sprints.generateSprints('TestSprint', projectList[0].Id, 'Planned', 1);
        sprintList[0].Assigned_Level_of_Effort__c=10;
        insert sprintList;
        
      	List<Connection__c> connectionList = TestDataFactory_Connections.generateConnections(Constants.RECORDTYPEID_CONNECTION_PRODICTION, projectList[0].Id, 'Active', null, 1);
      	connectionList[0].Status__c = 'Active';
        connectionList[0].Primary_Development_Environment__c = true;
      	insert connectionList;
      	
      	List<Release__c> releaseList = TestDataFactory_Releases.generateReleases(projectList[0].Id, connectionList[0].Id, connectionList[0].Id, 'TestRelease', 'Planned', System.today(), System.today().addDays(2), 1);
        releaseList[0].Created_On_Heroku__c = true;
        insert releaseList;
        
        List<Story__c> storyList = TestDataFactory_Stories.generateStories('testStory', projectList[0].id,'Draft','Medium',1);
        storyList[0].Level_of_Effort__c=10;
        storyList[0].Sprint__c = sprintList[0].Id;
        insert storyList;
    }

    @isTest static void test_method_one() 
    {
        Test.startTest();
            List<Story__c> storyList = [SELECT Id, Name, Project__c FROM Story__c];
            List<Sprint__c> sprintList;
            System.assertNotEquals(null,storyList);
            
            storyList[0].Status__c = 'In Progress';

            update storyList;

            sprintList  = [SELECT Id,Status__c FROM Sprint__c Limit 1];
            
            storyList[0].Sprint__c  = sprintList[0].Id ;
            update storyList;
            system.assertEquals(sprintList[0].Status__c ,'In Progress');
            
        Test.stopTest();
    }

    @isTest static void test_usecase_deleteStoryOne() {
        List<Story__c> storyList = [SELECT Id, Name, Project__c FROM Story__c];
        Test.startTest();
            storyList[0].Created_on_Heroku__c = true;
            update storyList ;
            Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
            
            try {
                delete storyList;
                System.assertEquals([SELECT Id, Name, Project__c FROM Story__c].size(),0);  
            }
                catch(Exception ex) {
            }
        Test.stopTest();
    }

    @isTest static void test_usecase_deleteStoryTwo() {
        List<Story__c> storyList = [SELECT Id, Name, Project__c FROM Story__c];
        Test.startTest();
            storyList[0].Scan_Running__c = true;
            update storyList;
            try {
                delete storyList;  
            }
                catch(Exception ex) {
            }
        Test.stopTest();
    }

    @isTest static void test_usecase_deleteStoryThree() {
        List<Story__c> storyList = [SELECT Id, Name, Project__c FROM Story__c];
        Test.startTest();
            storyList[0].Delete_on_Heroku__c = false;
            storyList[0].Allow_Deletion__c = false;
            update storyList;
            try {
                delete storyList;  
            }
                catch(Exception ex) {
            }
        Test.stopTest();
    }

}