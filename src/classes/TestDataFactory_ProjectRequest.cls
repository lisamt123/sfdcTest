public with sharing class TestDataFactory_ProjectRequest {

	public static List<Project_Request__c> generateProjectRequest(Id accountId, Date startDate, Date endDate, String workRequestName, Integer numberOfProjectRequest) {
		return generateProjectRequestInternal(accountId,startDate,endDate,workRequestName,numberOfProjectRequest);
	}

	private static List<Project_Request__c> generateProjectRequestInternal(Id accountId, Date startDate, Date endDate, String workRequestName, Integer numberOfProjectRequest) {
		List<Project_Request__c> projectRequestList = new List<Project_Request__c>();
        
        for(Integer i = 0; i < numberOfProjectRequest; i++) {
        	Project_Request__c projRequest = new Project_Request__c();
        	projRequest.Account__c = accountId ;
        	projRequest.Start_Date__c = startDate ;
        	projRequest.End_Date__c = endDate ;
        	projRequest.Name = workRequestName ;
        	projectRequestList.add(projRequest);
        }

        return projectRequestList ;
	}

}