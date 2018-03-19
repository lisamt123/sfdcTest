public with sharing class DeleteStatusReportController 
{
	@AuraEnabled
	public static DataWrapper deleteStatusReportRecord(String recId)
	{
		String currentUserId = UserInfo.getUserId();
		DataWrapper dataWarp = new DataWrapper();
		Status_Report__c statusReport = [SELECT Id, Project__c, Project__r.Project_Lead__c FROM Status_Report__c WHERE Id =: recId];
		if(currentUserId == statusReport.Project__r.Project_Lead__c)
		{
			Delete statusReport;
			dataWarp.projectId = statusReport.Project__c;
			dataWarp.isProjectLead = true;
		}
		else
		{
			dataWarp.projectId = statusReport.Project__c;
			dataWarp.isProjectLead = false;
		}
		return dataWarp;
	}

	public class DataWrapper
	{
		@AuraEnabled public String projectId;
		@AuraEnabled public Boolean isProjectLead;
	}
}