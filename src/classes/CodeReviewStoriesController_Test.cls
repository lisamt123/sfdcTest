@isTest
private class CodeReviewStoriesController_Test {
   
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
        
        List<Story__c> storyList = TestDataFactory_Stories.generateStories('testStory', projectList[0].id,'','',1);
        insert storyList;
        
        /*List<Release__c> releaseList = TestDataFactory_Releases.generateReleases(projectList[0].Id, connectionList[0].Id, connectionList[0].Id, 'TestRelease', 'Planned', System.today(), System.today().addDays(2), 1);
        releaseList[0].Created_On_Heroku__c = true;
        insert releaseList;*/
    }
    
    @isTest static void test_usecase_one() {
        List<Story__c> storyList = [Select Id From Story__c];
        
        Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
        Test.startTest();
          ApexPages.StandardController standardController = new ApexPages.StandardController(storyList[0]);
          CodeReviewStoriesController review = new CodeReviewStoriesController(standardController);
          System.assertEquals(storyList[0].Id, review.story.Id);
          
          CodeReviewStoriesController.scanCodeResult('Test123ATOZ');
          review.scanCode();
          review.releaseScanStatusStory();          
        Test.stopTest();
    }
    
    @isTest static void test_usecase_two() {
        List<Story__c> storyList = [Select Id From Story__c];
        System.assertEquals(1, storyList.size());
        
        List<Connection__c> connectionList = [Select Id,Status__c From Connection__c];
        System.assertEquals(2, connectionList.size());
        connectionList[0].Status__c = 'Inactive';
        connectionList[1].Status__c = 'Inactive';
        update connectionList;
        
        Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
        Test.startTest();
            ApexPages.StandardController standardController = new ApexPages.StandardController(storyList[0]);
            CodeReviewStoriesController review = new CodeReviewStoriesController(standardController);
            review.retriveReviewLogs();
            System.assertEquals(storyList[0].Id, review.story.Id);
        Test.stopTest();
    }
}