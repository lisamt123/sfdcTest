@isTest
private class ManageReleaseArtifactsLightning_Test {
    
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
        
        List<Sprint__c> sprintList = TestDataFactory_Sprints.generateSprints('TestSprint', projectList[0].Id, 'In Progress', 1);
        insert sprintList;
        
        List<Story__c> storiesList = TestDataFactory_Stories.generateStories('Test Story', projectList[0].Id, 'Draft', 'Medium', 1);
        storiesList[0].Sprint__c = sprintList[0].Id;
        insert storiesList;
        
    }
    
    @isTest static void test_usecase_one() {
        List<Release__c> releaseList = [Select Id From Release__c];
        List<Story__c> storyList = [SELECT Id, Name, Project__c FROM Story__c];
        
        System.assertEquals(2, releaseList.size());
        System.assertEquals(1, storyList.size());
        
        Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
        Test.startTest();
            
            List<ManageReleaseArtifactsLightning.Artifacts> wrapLi = new List<ManageReleaseArtifactsLightning.Artifacts>();
            ManageReleaseArtifactsLightning.Artifacts wrap = new ManageReleaseArtifactsLightning.Artifacts();
            wrap.metadataType = 'ApexClass';
            wrap.metadataName = new List<ManageReleaseArtifactsLightning.MetadataName>();
            ManageReleaseArtifactsLightning.MetadataName w1 = new ManageReleaseArtifactsLightning.MetadataName();
            w1.name = 'ApexTest11';
	        w1.action = 'delete';
	        w1.artifactId = '123';
	        w1.storyName = storyList[0].Name;
            wrap.metadataName.add(w1);
            w1 = new ManageReleaseArtifactsLightning.MetadataName();
            w1.name = 'ApexTest12';
	        w1.action = 'delete';
	        w1.artifactId = '123';
	        w1.storyName = storyList[0].Name;
            wrap.metadataName.add(w1);
            w1 = new ManageReleaseArtifactsLightning.MetadataName();
            w1.name = 'ApexTest13';
	        w1.action = 'delete';
	        w1.artifactId = '123';
	        w1.storyName = storyList[0].Name;
            wrap.metadataName.add(w1);
            wrapLi.add(wrap);
            String strJSON = JSON.serialize(wrapLi);
            
            ManageReleaseArtifactsLightning.ManageReleaseArtifactsMainWrapper mainWrapperInstance = ManageReleaseArtifactsLightning.getManageReleaseArtifacts(releaseList[0].Id,'1000','Apex','All',strJSON,JSON.serialize(new List<String>()),'',true);
            System.assertEquals(1, mainWrapperInstance.StoryWrapperList.size());
            
            String mapWrapperListStr = JSON.serialize(mainWrapperInstance.wrapperListSelected);
            ManageReleaseArtifactsLightning.createArtifacts(releaseList[0].Id, mapWrapperListStr);
            String storyWrapperListStr = JSON.serialize(mainWrapperInstance.StoryWrapperList);
            
        Test.stopTest();
    }  
    
    @isTest static void test_usecase_two() {
        List<Release__c> releaseList = [Select Id From Release__c];
        List<Story__c> storyList = [SELECT Id, Name, Project__c FROM Story__c];
        
        System.assertEquals(2, releaseList.size());
        System.assertEquals(1, storyList.size());
        
        Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
        Test.startTest();
            
            List<ManageReleaseArtifactsLightning.Artifacts> wrapLi = new List<ManageReleaseArtifactsLightning.Artifacts>();
            ManageReleaseArtifactsLightning.Artifacts wrap = new ManageReleaseArtifactsLightning.Artifacts();
            wrap.metadataType = 'ApexClass';
            wrap.metadataName = new List<ManageReleaseArtifactsLightning.MetadataName>();
            ManageReleaseArtifactsLightning.MetadataName w1 = new ManageReleaseArtifactsLightning.MetadataName();
            w1.name = 'ApexTest11';
	        w1.action = 'delete';
	        w1.artifactId = '123';
	        w1.storyName = storyList[0].Name;
            wrap.metadataName.add(w1);
            w1 = new ManageReleaseArtifactsLightning.MetadataName();
            w1.name = 'ApexTest12';
	        w1.action = 'delete';
	        w1.artifactId = '123';
	        w1.storyName = storyList[0].Name;
            wrap.metadataName.add(w1);
            w1 = new ManageReleaseArtifactsLightning.MetadataName();
            w1.name = 'ApexTest13';
	        w1.action = 'delete';
	        w1.artifactId = '123';
	        w1.storyName = storyList[0].Name;
            wrap.metadataName.add(w1);
            wrapLi.add(wrap);
            String strJSON = JSON.serialize(wrapLi);
            
            ManageReleaseArtifactsLightning.ManageReleaseArtifactsMainWrapper mainWrapperInstance = ManageReleaseArtifactsLightning.getManageReleaseArtifacts(releaseList[0].Id,'1000','Apex','All',strJSON,JSON.serialize(new List<String>()),'',true);
            System.assertEquals(1, mainWrapperInstance.StoryWrapperList.size());
            
            String mapWrapperListStr = JSON.serialize(mainWrapperInstance.wrapperListSelected);
            ManageReleaseArtifactsLightning.createArtifacts(releaseList[0].Id, mapWrapperListStr);
            String storyWrapperListStr = JSON.serialize(mainWrapperInstance.StoryWrapperList);
            
            List<String> selectedStoryList = new List<String>();
            selectedStoryList.addAll(mainWrapperInstance.selectedStory);
            
            List<ManageReleaseArtifactsLightning.Artifacts> resultLi = ManageReleaseArtifactsLightning.createReleaseStory(releaseList[0].Id, storyList[0].Id, 'create');
            System.assert(resultLi.size() > 0);
        Test.stopTest();
    }
    
    @isTest static void test_usecase_three() {
        
        List<Release__c> releaseList = [Select Id From Release__c];
        System.assertEquals(2, releaseList.size());
       
        Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
        Test.startTest();
            ManageReleaseArtifactsLightning.manageRelease(releaseList[0].Id);
            ManageReleaseArtifactsLightning.manageRelease(releaseList[1].Id);
            
            releaseList = [Select Id From Release__c WHERE Id=:releaseList[1].Id AND Created_On_Heroku__c=true];
            System.assertEquals(1, releaseList.size());
        Test.stopTest();
    }

    @isTest static void test_usecase_four() {
        
        List<Release__c> releaseList = [Select Id From Release__c];
        System.assertEquals(2, releaseList.size());
       
        Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
        Test.startTest();
            String returnResopnse = ManageReleaseArtifactsLightning.refreshArtifacts(releaseList[1].Id);
            System.assertEquals(returnResopnse, 'Success');
            Release__c release = ManageReleaseArtifactsLightning.connectionRefreshStatus(releaseList[1].Id);
            
            System.assertNotEquals(null, release);
            System.assertEquals(true, release.Source__r.Refresh_Running__c);

        Test.stopTest();
    }

    @isTest static void test_usecase_five() {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
            List<Release__c> releaseList= [Select Id, project__c From Release__c Limit 1];
            List<String> storyIdList = new List<String>();
            for(Story__c storyObj : [Select Id From Story__c Where Project__c = :releaseList[0].project__c]) 
                storyIdList.add(storyObj.Id);
            ManageReleaseArtifactsLightning.updateStoryReleaseArtifacts(releaseList[0].Id,storyIdList);
        Test.stopTest();
    }
}