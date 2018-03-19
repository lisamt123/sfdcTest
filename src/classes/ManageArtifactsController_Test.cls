@isTest
private class ManageArtifactsController_Test 
{
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
        
        List<Connection__c> connectionList = TestDataFactory_Connections.generateConnections(Constants.RECORDTYPEID_CONNECTION_PRODICTION, projectList[0].Id, 'Active', null, 1);
        connectionList[0].Primary_Development_Environment__c = true;
        insert connectionList;
        
        List<Story__c> storiesList = TestDataFactory_Stories.generateStories('Test Story', projectList[0].Id, 'Draft', 'Medium', 1);
        insert storiesList;
    }
    
    @isTest static void test_usecase_one() {
        List<Story__c> storyList = [SELECT Id, Name, Project__c FROM Story__c];
        List<Connection__c> connectionList = [SELECT Id, Name FROM Connection__c];
        System.assertEquals(1, storyList.size());
        System.assertEquals(1, connectionList.size());
        
        ApexPages.StandardController standardController = new ApexPages.StandardController(storyList[0]);
        ManageArtifactsController controller = new ManageArtifactsController(standardController);
        System.assertEquals(1, controller.connectionOption.size());
        System.assertEquals(connectionList[0].Id, controller.selectedConnection);
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
            
            List<ManageArtifactsController.MetadataWrapper> wrapLi = new List<ManageArtifactsController.MetadataWrapper>();
            ManageArtifactsController.MetadataWrapper wrap = new ManageArtifactsController.MetadataWrapper();
            wrap.metadataType = 'ApexClass';
            
            /* Commented and Added By AK
            
            wrap.metadataName.add('ApexTest11');
            wrap.metadataName.add('ApexTest2');
            wrap.metadataName.add('ApexTest3');
            wrapLi.add(wrap);*/
            
            List<ManageArtifactsController.MetadataName> wrapMetadataNameLi = new List<ManageArtifactsController.MetadataName>();
            wrapMetadataNameLi.add(new ManageArtifactsController.MetadataName('ApexTest11','ApexClass',''));
            wrapMetadataNameLi.add(new ManageArtifactsController.MetadataName('ApexTest2','ApexClass',''));
            wrapMetadataNameLi.add(new ManageArtifactsController.MetadataName('ApexTest3','ApexClass',''));
            
            wrap.metadataName = wrapMetadataNameLi;
            
            String strJSON = JSON.serialize(wrapLi);
            
            ManageArtifactsController.MetadataBundleWrapper result = ManageArtifactsController.getConnectionMetadata(storyList[0].Id,connectionList[0].Id,'1000','Test', 'All', strJSON);
            System.assertNotEquals(null, result.wrapperList);
            System.assert(result.wrapperList.size() > 0);
            
        Test.stopTest();
    }
    
    @isTest static void test_usecase_two() {
        List<Story__c> storyList = [SELECT Id, Name, Project__c FROM Story__c];
        List<Connection__c> connectionList = [SELECT Id, Name FROM Connection__c];
        System.assertEquals(1, storyList.size());
        System.assertEquals(1, connectionList.size());
        
        ApexPages.StandardController standardController = new ApexPages.StandardController(storyList[0]);
        ManageArtifactsController controller = new ManageArtifactsController(standardController);
        System.assertEquals(1, controller.connectionOption.size());
        System.assertEquals(connectionList[0].Id, controller.selectedConnection);
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
            
            List<ManageArtifactsController.MetadataWrapper> wrapLi = new List<ManageArtifactsController.MetadataWrapper>();
            ManageArtifactsController.MetadataWrapper wrap = new ManageArtifactsController.MetadataWrapper();
            wrap.metadataType = 'ApexClass';
            
            /* Commented and Added By AK
            
            wrap.metadataName.add('ApexTest11');
            wrap.metadataName.add('ApexTest2');
            wrap.metadataName.add('ApexTest3');
            wrapLi.add(wrap);*/
            
            List<ManageArtifactsController.MetadataName> wrapMetadataNameLi = new List<ManageArtifactsController.MetadataName>();
            wrapMetadataNameLi.add(new ManageArtifactsController.MetadataName('ApexTest11','ApexClass',''));
            wrapMetadataNameLi.add(new ManageArtifactsController.MetadataName('ApexTest2','ApexClass',''));
            wrapMetadataNameLi.add(new ManageArtifactsController.MetadataName('ApexTest3','ApexClass',''));
            
            wrap.metadataName = wrapMetadataNameLi;
            String strJSON = JSON.serialize(wrapLi);
            
            ManageArtifactsController.MetadataBundleWrapper result = ManageArtifactsController.getConnectionMetadata(storyList[0].Id,connectionList[0].Id,'1000','Test', 'All', strJSON);
            System.assertNotEquals(null, result.wrapperList);
            System.assert(result.wrapperList.size() > 0);
            ManageArtifactsController.createStoryArtifacts(storyList[0].Id, strJSON);
            
            /* List<Story_Artifact__c> storyArtifactList = [SELECT Id FROM Story_Artifact__c WHERE Story__c=:storyList[0].Id];
            System.assertEquals(3, storyArtifactList.size()); */
            
        Test.stopTest();
    }
    
    @isTest static void test_usecase_three() {

        List<Story__c> storyList = [SELECT Id, Name, Project__c FROM Story__c];
        List<Connection__c> connectionList = [SELECT Id, Name FROM Connection__c];
        System.assertEquals(1, storyList.size());
        System.assertEquals(1, connectionList.size());
        
        /* List<Story_Artifact__c> storyArtifactList = TestDataFactory_StoryArtifacts.generateStoryArtifacts(storyList[0].Id, 'Page1', 'ApexPage', 2);
        insert storyArtifactList; */
        
        ApexPages.StandardController standardController = new ApexPages.StandardController(storyList[0]);
        ManageArtifactsController controller = new ManageArtifactsController(standardController);
        System.assertEquals(1, controller.connectionOption.size());
        System.assertEquals(connectionList[0].Id, controller.selectedConnection);
        
        Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
        
        List<ManageArtifactsController.MetadataWrapper> wrapLi = new List<ManageArtifactsController.MetadataWrapper>();
        ManageArtifactsController.MetadataWrapper wrap = new ManageArtifactsController.MetadataWrapper();
        wrap.metadataType = 'ApexClass';
        
        List<ManageArtifactsController.MetadataName> wrapMetadataNameLi = new List<ManageArtifactsController.MetadataName>();
        wrapMetadataNameLi.add(new ManageArtifactsController.MetadataName('ApexTest11','ApexClass',''));
        wrapMetadataNameLi.add(new ManageArtifactsController.MetadataName('ApexTest2','ApexClass',''));
        wrapMetadataNameLi.add(new ManageArtifactsController.MetadataName('ApexTest3','ApexClass',''));
        
        wrap.metadataName = wrapMetadataNameLi;
        wrapLi.add(wrap);
        wrap = new ManageArtifactsController.MetadataWrapper();
        wrap.metadataType = 'ApexPage';
        wrapMetadataNameLi = new List<ManageArtifactsController.MetadataName>();
        wrapMetadataNameLi.add(new ManageArtifactsController.MetadataName('ApexTest11','ApexPage',''));
        wrapMetadataNameLi.add(new ManageArtifactsController.MetadataName('ApexTest2','ApexPage',''));
        wrapMetadataNameLi.add(new ManageArtifactsController.MetadataName('ApexTest3','ApexPage',''));
        
        wrap.metadataName = wrapMetadataNameLi;
        wrap.metadataName.sort();
        wrapLi.add(wrap);
        String strJSON = JSON.serialize(wrapLi);
        
        Test.startTest();
        
	        ManageArtifactsController.MetadataBundleWrapper result = ManageArtifactsController.getConnectionMetadata(storyList[0].Id,connectionList[0].Id,'1000','Test', 'All', strJSON);
	        System.assertNotEquals(null, result.wrapperList);
	        System.assert(result.wrapperList.size() > 0);
	        
	        controller.refreshArtifacts();
	        //ManageArtifactsController.createStoryArtifacts(storyList[0].Id, strJSON);
        Test.stopTest();
    }
}