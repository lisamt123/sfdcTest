public with sharing class TestDataFactory_Projects {
    
    public static List<Project__c> generateProjects(Id accountId, String projectName, Integer numOfRecords) {
    	return generateProjectsInternal(accountId, projectName, numOfRecords);
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<Project__c> generateProjectsInternal(Id accountId, String projectName, Integer numOfRecords) {
    	List<Project__c> projectList = new List<Project__c>();
        
        for(Integer i = 0; i < numOfRecords; i++) {
            Project__c project = new Project__c();
            project.Name = projectName;
            project.Account__c = accountId;
            projectList.add(project); 
        } 
        
        return projectList;
    }
}