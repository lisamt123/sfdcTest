public with sharing class TestDataFactory_Stories {
    
    public static List<Story__c> generateStories(String storyName, Id projectId, String status, String priority, Integer numOfRecords) {
		return generateStoriesInternal(storyName, projectId, status, priority, numOfRecords);
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<Story__c> generateStoriesInternal(String storyName, Id projectId, String status, String priority, Integer numOfRecords) {
    	List<Story__c> storiesList = new List<Story__c>();
        
        for(Integer i = 0; i < numOfRecords; i++) {
        	
			Story__c stry           = new Story__c();
            stry.Story_Name__c      = storyName + String.valueOf(i);
            stry.Project__c         = projectId ;
            stry.Status__c          = status;
            stry.Priority__c        = priority ;
            stry.Level_of_Effort__c = 2 ;
            storiesList.add(stry);
        }
        
        return storiesList;
    }
}