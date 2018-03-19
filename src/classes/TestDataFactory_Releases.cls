public with sharing class TestDataFactory_Releases {
    
    public static List<Release__c> generateReleases(Id projectId, Id sourceConnectionId, Id targetConnectionId, String name, String status, Date Actual_Release_Date, Date Target_Release_Date, Integer noOfProjects) {
		return generateReleasesInternal(projectId, sourceConnectionId, targetConnectionId, name, status, Actual_Release_Date, Target_Release_Date, noOfProjects);
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<Release__c> generateReleasesInternal(Id projectId, Id sourceConnectionId, Id targetConnectionId, String name, String status, Date Actual_Release_Date, Date Target_Release_Date, Integer noOfProjects) {
    	List<Release__c> releaseList = new List<Release__c>();
        
        for(Integer i = 0; i < noOfProjects; i++) {
        	Release__c rel = new Release__c();
        	rel.Name = name;
        	rel.Project__c = projectId; 
        	rel.Source__c = sourceConnectionId; 
        	rel.Target__c = targetConnectionId; 
        	rel.Status__c = status; 
        	rel.Actual_Release_Date__c = Actual_Release_Date;
        	rel.Target_Release_Date__c = Target_Release_Date;
        	
            releaseList.add(rel);
        }
        
        return releaseList;
    }
}