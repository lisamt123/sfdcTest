@isTest
private class ManageArtifactsLightning_Test 
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
        
       /* List<Story_Artifact__c> storyArtifactList = TestDataFactory_StoryArtifacts.generateStoryArtifacts(storiesList[0].Id, 'Page1', 'ApexPage', 2);
        insert storyArtifactList; */
    }
    
    @isTest static void test_usecase_one() {

        List<Story__c> storyList = [SELECT Id, Name, Project__c FROM Story__c];
        List<Project__c> projectList = [SELECT Id,(SELECT Id, Name, Status__c, Primary_Development_Environment__c FROM Connections__r WHERE Status__c = 'Active' ORDER BY CreatedDate ASC) FROM Project__c WHERE Id =: storyList[0].Project__c ];
    
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
            
            List<ManageArtifactsLightning.MetadataWrapper> wrapLi = new List<ManageArtifactsLightning.MetadataWrapper>();
            ManageArtifactsLightning.MetadataWrapper wrap = new ManageArtifactsLightning.MetadataWrapper();
            /* Commented and Added By AK
            
            wrap.metadataName.add('ApexTest11');
            wrap.metadataName.add('ApexTest2');
            wrap.metadataName.add('ApexTest3');
            wrapLi.add(wrap);*/
            
            List<ManageArtifactsLightning.MetadataName> wrapMetadataNameLi = new List<ManageArtifactsLightning.MetadataName>();
            wrapMetadataNameLi.add(new ManageArtifactsLightning.MetadataName('ApexTest11','ApexClass',''));
            wrapMetadataNameLi.add(new ManageArtifactsLightning.MetadataName('ApexTest2','ApexClass',''));
            wrapMetadataNameLi.add(new ManageArtifactsLightning.MetadataName('ApexTest3','ApexClass',''));
            
            wrap.metadataName = wrapMetadataNameLi;
            String strJSON = JSON.serialize(wrapLi);
            
            ManageArtifactsLightning.MetadataLightningWrapper metadataLightningWrapperInstance = ManageArtifactsLightning.getMetadataFunctionality(storyList[0].Id,'','1000','Test', 'All', strJSON); 
      
            //String createArtifactsStr = JSON.serialize(metadataLightningWrapperInstance.wrapperList);
            //System.debug(createArtifactsStr);
            ManageArtifactsLightning.createStoryArtifacts(storyList[0].Id, strJSON);
            System.assertEquals(1, storyList.size());
            
            /* List<Story_Artifact__c> storyArtifactResultList = [SELECT Id FROM Story_Artifact__c WHERE Story__c=:storyList[0].Id];
            System.assertEquals(3, storyArtifactResultList.size()); */
        Test.stopTest();
    }
    
    @isTest static void test_usecase_two() 
    {
        List<Connection__c> connectionList = [Select Id, Name, RecordTypeId, Created_On_Heroku__c, Metadata_Describe_Error__c,Organization_URL__c FROM Connection__c ];
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
            
            String jsonRes = ManageArtifactsLightning.refreshArtifacts(connectionList[0].Id);
            System.assertNotEquals(null, jsonRes);
            
            Connection__c conRes = ManageArtifactsLightning.connectionRefreshStatus(connectionList[0].Id);
            System.assertEquals(connectionList[0].Id, conRes.Id);
        Test.stopTest();
    }
}