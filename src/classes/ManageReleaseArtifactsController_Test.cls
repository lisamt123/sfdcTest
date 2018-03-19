@isTest
private class ManageReleaseArtifactsController_Test {
    
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
        connectionList[0].Primary_Development_Environment__c = true;
        insert connectionList;
        
        List<Release__c> releaseList = TestDataFactory_Releases.generateReleases(projectList[0].Id, connectionList[0].Id, connectionList[0].Id, 'TestRelease', 'Planned', System.today(), System.today().addDays(2), 2);
        releaseList[0].Created_On_Heroku__c = true;
        releaseList[1].Created_On_Heroku__c = false;
        insert releaseList;
        
        List<Sprint__c> sprintList = TestDataFactory_Sprints.generateSprints('TestSprint', projectList[0].Id, 'In Progress', 1);
        insert sprintList;
        
        List<Story__c> storiesList = TestDataFactory_Stories.generateStories('Test Story', projectList[0].Id, 'Draft', 'Medium', 1);
        storiesList[0].Sprint__c = sprintList[0].Id;
        insert storiesList;
        
        /* List<Story_Artifact__c> storyArtifactList = TestDataFactory_StoryArtifacts.generateStoryArtifacts(storiesList[0].Id, 'Page1', 'ApexPage', 1);
        insert storyArtifactList; */ 
    }
    
    @isTest static void test_usecase_one() {
        List<Release__c> releaseList = [Select Id From Release__c];
        List<Sprint__c> sprintList = [SELECT Id, Name FROM Sprint__c];
        List<Story__c> storyList = [SELECT Id, Name, Project__c FROM Story__c];
        
        System.assertEquals(2, releaseList.size());
        System.assertEquals(1, sprintList.size());
        System.assertEquals(1, storyList.size());
        
        Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
        Test.startTest();
            ApexPages.StandardController standardController = new ApexPages.StandardController(releaseList[0]);
            ManageReleaseArtifactsController artifact = new ManageReleaseArtifactsController(standardController);
            artifact.selectedSprint = sprintList[0].Id;
            artifact.retrieveStories();
            System.assertEquals(1, artifact.StoryWrapperList.size());
            
            artifact.StoryWrapperList[0].selected = true;
            // Commeneted by  Method does not exist or incorrect signature: void manageStory() from the type ManageReleaseArtifactsController at line 55 column 22  
            // artifact.manageStory();
            artifact.manageRelease();
            
            List<ManageReleaseArtifactsController.Artifacts> wrapLi = new List<ManageReleaseArtifactsController.Artifacts>();
	        ManageReleaseArtifactsController.Artifacts wrap = new ManageReleaseArtifactsController.Artifacts();
	        wrap.metadataType = 'ApexClass';
	        
	        List<ManageReleaseArtifactsController.MetadataName> wrapMetadataNameLi = new List<ManageReleaseArtifactsController.MetadataName>();
	        wrapMetadataNameLi.add(new ManageReleaseArtifactsController.MetadataName('ApexTest11','ApexClass',''));
	        wrapMetadataNameLi.add(new ManageReleaseArtifactsController.MetadataName('ApexTest2','ApexClass',''));
	        wrapMetadataNameLi.add(new ManageReleaseArtifactsController.MetadataName('ApexTest3','ApexClass',''));
	        
	        wrap.metadataName = wrapMetadataNameLi;
	        wrapLi.add(wrap);
	        wrap = new ManageReleaseArtifactsController.Artifacts();
	        wrap.metadataType = 'ApexPage';
	        wrapMetadataNameLi = new List<ManageReleaseArtifactsController.MetadataName>();
	        wrapMetadataNameLi.add(new ManageReleaseArtifactsController.MetadataName('ApexTest11','ApexPage',''));
	        wrapMetadataNameLi.add(new ManageReleaseArtifactsController.MetadataName('ApexTest2','ApexPage',''));
	        wrapMetadataNameLi.add(new ManageReleaseArtifactsController.MetadataName('ApexTest3','ApexPage',''));
	        
	        wrap.metadataName = wrapMetadataNameLi;
	        wrap.metadataName.sort();
	        wrapLi.add(wrap);
	        String strJSON = JSON.serialize(wrapLi);
            
            ManageReleaseArtifactsController.MetadataLightningWrapper mainWrapperInstance = ManageReleaseArtifactsController.getConnectionMetadata(releaseList[0].Id,'1000','','', strJSON);
            
            String mapWrapperListStr = JSON.serialize(mainWrapperInstance.wrapperListSelected);
            String storyListStr = JSON.serialize(new List<String>{storyList[0].Id});
            ManageReleaseArtifactsController.createArtifacts(releaseList[0].Id,mapWrapperListStr, storyListStr);
            
           /* List<Story_Artifact__c> storyArtifactResultList1 = [SELECT Id FROM Story_Artifact__c WHERE Story__c=:storyList[0].Id];
            System.assertEquals(1, storyArtifactResultList1.size()); */
            
        Test.stopTest();
    }  
    
    @isTest static void test_usecase_two() {
        List<Release__c> releaseList = [Select Id From Release__c];
        List<Sprint__c> sprintList = [SELECT Id, Name FROM Sprint__c];
        List<Story__c> storyList = [SELECT Id, Name, Project__c FROM Story__c];
        
        System.assertEquals(2, releaseList.size());
        System.assertEquals(1, sprintList.size());
        System.assertEquals(1, storyList.size());
       
        Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
        Test.startTest();
            ApexPages.StandardController standardController = new ApexPages.StandardController(releaseList[1]);
            ManageReleaseArtifactsController artifact = new ManageReleaseArtifactsController(standardController);
            artifact.manageRelease();
            
           /* List<Story_Artifact__c> storyArtifactResultList1 = [SELECT Id FROM Story_Artifact__c WHERE Story__c=:storyList[0].Id];
            System.assertEquals(1, storyArtifactResultList1.size()); */

        Test.stopTest();
    }
    
    @isTest static void test_usecase_three() {
        
        List<Project__c> projectList = [Select Id From Project__c];
        System.assertEquals(1, projectList.size());
        
        List<Release__c> releaseList = TestDataFactory_Releases.generateReleases(projectList[0].Id, null, null, 'TestRelease', 'Planned', System.today(), System.today().addDays(2), 1);
        releaseList[0].Created_On_Heroku__c = true;
        insert releaseList;
       
        Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
        Test.startTest();
            ApexPages.StandardController standardController = new ApexPages.StandardController(releaseList[0]);
            ManageReleaseArtifactsController artifact = new ManageReleaseArtifactsController(standardController);
            System.assertEquals(false, artifact.connectionExist);
        Test.stopTest();
    }
}