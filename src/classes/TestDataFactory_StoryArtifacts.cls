public with sharing class TestDataFactory_StoryArtifacts {
    
    /* Commented By Ak due deete objct  Story_Artifact__c
    public static List<Story_Artifact__c> generateStoryArtifacts(Id storyId, String metadataName, String metadataType, Integer numOfRecords) {
        return generateStoryArtifactsInternal(storyId, metadataName, metadataType, numOfRecords);
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<Story_Artifact__c> generateStoryArtifactsInternal(Id storyId, String metadataName, String metadataType, Integer numOfRecords) {
        
        List<Story_Artifact__c> storyArtifactList = new List<Story_Artifact__c>();
        
        for(Integer i = 0; i < numOfRecords; i++) {
            
            Story_Artifact__c storyArtifact = new Story_Artifact__c();
            storyArtifact.Story__c = storyId;
            storyArtifact.Metadata_Name__c = metadataName+''+i;
            storyArtifact.Metadata_Type__c = metadataType; 

            storyArtifactList.add(storyArtifact);
        }
        
        return storyArtifactList; 
        
    }
    */
}