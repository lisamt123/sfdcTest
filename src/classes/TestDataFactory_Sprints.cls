public with sharing class TestDataFactory_Sprints 
{
    public static List<Sprint__c> generateSprints(String sprintName, Id projectId, String status, Integer numOfRecords) {
		return generateSprintsInternal(sprintName, projectId, status, numOfRecords);
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<Sprint__c> generateSprintsInternal(String sprintName, Id projectId, String status, Integer numOfRecords) {
    	List<Sprint__c> spntList = new List<Sprint__c>();
        
        for(Integer i = 0; i < numOfRecords; i++) {
			Sprint__c spnt = new Sprint__c();
			spnt.Name = sprintName+i;
			spnt.Project__c = projectId; 
			spnt.Status__c= status;
            spntList.add(spnt);
        }
        
        return spntList;
    }
}