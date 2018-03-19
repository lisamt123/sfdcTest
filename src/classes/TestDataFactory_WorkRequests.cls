public with sharing class TestDataFactory_WorkRequests {
    
    public static List<Project_Request__c> generateWorkRequests(String projectName, Id accountId, Date endDate, Id opportunityId, Id projectId, boolean recalculateSharingOnSave, Id contactId, Date startDate, String status, String statusDetail, String description, Integer numOfRecords) {
    	return generateWorkRequestsInternal(projectName, accountId, endDate, opportunityId, projectId, recalculateSharingOnSave, contactId, startDate, status, statusDetail, description, numOfRecords);
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<Project_Request__c> generateWorkRequestsInternal(String projectName, Id accountId, Date endDate, Id opportunityId, Id projectId, boolean recalculateSharingOnSave, Id contactId, Date startDate, String status, String statusDetail, String description, Integer numOfRecords) {
    	List<Project_Request__c> preqList = new List<Project_Request__c>();
        
        for(Integer i = 0; i < numOfRecords; i++) {
            Project_Request__c preq = new Project_Request__c();
            preq.Project_Name__c = projectName;
            preq.Account__c = accountId;
            preq.End_Date__c = endDate;
            preq.Opportunity__c = opportunityId;
            preq.Project__c = projectId;
            preq.Recalculate_Sharing_on_Save__c = recalculateSharingOnSave;
            preq.Request_Contact__c = contactId;
            preq.Start_Date__c = startDate;
            preq.Status__c = status;
            //preq.Status_Detail__c = statusDetail;
            preq.Description__c = description;
            preqList.add(preq);
        } 
        
        return preqList;
    }
}