public with sharing class TestDataFactory_ProjectRequestDetail {
	public static List<Project_Request_Detail__c> generateProjectRequestDetail(Id projectRequestId, Integer numberOfProjectRequestDetail) {
		return generateProjectRequestDetailInternal(projectRequestId,numberOfProjectRequestDetail);
	}

	private static List<Project_Request_Detail__c> generateProjectRequestDetailInternal(Id projectRequestId, Integer numberOfProjectRequestDetail) {
		List<Project_Request_Detail__c> projectRequestDetailList = new List<Project_Request_Detail__c>();
        
        for(Integer i = 0; i < numberOfProjectRequestDetail; i++) {
        	Project_Request_Detail__c projRequestDetail = new Project_Request_Detail__c() ;
        	projRequestDetail.Project_Request__c = projectRequestId ;
        	projectRequestDetailList.add(projRequestDetail);
        }

        return projectRequestDetailList ;
	}
}