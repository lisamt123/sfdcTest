@isTest
private class ContentDocumentLinksHelper_Test {
  
    static testMethod void insertExpertAchievementTest() {
        TestDataFactory factory = new TestDataFactory();
        List<Achievement__c> achievements = factory.generateAchievements(10);
        insert achievements;
    
        string before = 'Testing base 64 encode';            
        Blob beforeblob = Blob.valueOf(before);
        //Insert contentdocument data
        ContentVersion cv = new ContentVersion();
        cv.title = 'test content trigger';      
        cv.PathOnClient ='test';           
        cv.VersionData =beforeblob;          
        insert cv;         
                                            
        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];

        ContentDocumentLink newFileShare = new ContentDocumentLink();
        newFileShare.contentdocumentid = testcontent.contentdocumentid;
        newFileShare.LinkedEntityId = achievements[0].Id;
        newFileShare.ShareType= 'V';
        insert newFileShare;
    }
}