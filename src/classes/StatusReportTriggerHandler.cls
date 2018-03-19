public without sharing class StatusReportTriggerHandler {
    
    //Update the Project's Project Health according to Status Report's Project Health
    public static void updateProjectHealth(List<Status_Report__c> oldRecords, List<Status_Report__c> newRecords){
      Map<Id, Status_Report__c> projectStatusReportMap = new Map<Id, Status_Report__c>();
      for (Integer i=0; i<newRecords.size(); i++){
      	if (oldRecords != null && oldRecords[i].Project_Health__c != newRecords[i].Project_Health__c) {
      	  projectStatusReportMap.put(newRecords[i].Project__c, newRecords[i]);
      	} else if (oldRecords == null) {
  		  projectStatusReportMap.put(newRecords[i].Project__c, newRecords[i]);
      	}
      }
      
      if (projectStatusReportMap.size() > 0) {
      	List<Project__c> updationProjects = new List<Project__c>();
      	for (Project__c project : [select Id,Project_Health__c FROM Project__c WHERE Id IN :projectStatusReportMap.keyset() ]) {
      	  project.Project_Health__c = (projectStatusReportMap.get(project.Id)).Project_Health__c;
      	  updationProjects.add(project);
      	}
      	
      	if (updationProjects.size() > 0) {
      		update updationProjects;
      	}
      }
    }
}