global class ManageDateController {
	
	@AuraEnabled
	public static List<ProjectWrapper> getProjectWrapper(Id recId) {
		List<projectWrapper> projectWrapper = new List<projectWrapper>();

		Project__c projectRecord 	= [SELECT Id,Start_Date__c,End_Date__c FROM Project__c WHERE Id =:recId];
		projectWrapper.add(new ProjectWrapper(projectRecord,false,projectRecord.Start_Date__c,projectRecord.End_Date__c));
		return projectWrapper; 	
	}

	@AuraEnabled
	public static List<AssignmentWrapper> getAssignWrapper(Id recId) {
		List<AssignmentWrapper> assignWrapperList = new List<AssignmentWrapper>();
		Project__c projectRecord 	= [SELECT Id,Start_Date__c,End_Date__c FROM Project__c WHERE Id =:recId];
		for(Assignment__c assign : [SELECT Id,Name,End_Date__c,Start_Date__c,Status__c,Resource_Name__c From Assignment__c WHERE Project__c = :recId]){
			assignWrapperList.add(new AssignmentWrapper(assign,false,assign.Start_Date__c,assign.End_Date__c));
		}
		return assignWrapperList; 	
	}

	@AuraEnabled
	public static String updateProjectAssign(String projectListJson,String assignmentRecListJson) {
		String status = 'Success';
		List<Project__c> projectListToUpdate = new List<Project__c>();
		List<Assignment__c> assignmentListToUpdate = new List<Assignment__c>();

		List<ProjectWrapper> projectList 		= (List<ProjectWrapper>)JSON.deserialize(projectListJson, List<ProjectWrapper>.class);
		List<AssignmentWrapper> assignmentList 	= (List<AssignmentWrapper>)JSON.deserialize(assignmentRecListJson, List<AssignmentWrapper>.class);
		if(projectList[0].endDate != projectList[0].projectRecord.End_Date__c || projectList[0].startDate != projectList[0].projectRecord.Start_Date__c){
			projectList[0].projectRecord.End_Date__c = projectList[0].endDate;
			projectList[0].projectRecord.Start_Date__c = projectList[0].startDate;
			projectListToUpdate.add(projectList[0].projectRecord);
		}

		for(AssignmentWrapper assignWrapper :assignmentList){
			if(assignWrapper.assignRecord.Start_Date__c != assignWrapper.startDate || assignWrapper.assignRecord.End_Date__c != assignWrapper.endDate ){
				assignWrapper.assignRecord.Start_Date__c = assignWrapper.startDate;
				assignWrapper.assignRecord.End_Date__c   = assignWrapper.endDate;
				assignmentListToUpdate.add(assignWrapper.assignRecord);
			}
		}

		if(assignmentListToUpdate.size() > 0) {
			try{
				update assignmentListToUpdate;
			}
			catch(Exception exp){
				if(exp.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,'))
					status = String.valueOf(exp.getMessage().split('FIELD_CUSTOM_VALIDATION_EXCEPTION,')[1]);
			}
			
		}

		if(projectListToUpdate.size() > 0) {
			try{
				update projectListToUpdate;
			}
			catch(Exception exp){
				if(exp.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,'))
					status = String.valueOf(exp.getMessage().split('FIELD_CUSTOM_VALIDATION_EXCEPTION,')[1]);
			}
		}
		return status;
	}

	
	global class ProjectWrapper	{
		@AuraEnabled public Project__c projectRecord 							{get;set;}
		@AuraEnabled public Boolean  isChangeProject 							{get;set;}
		@AuraEnabled public Date   startDate                                    {get;set;}
		@AuraEnabled public Date   endDate                                     {get;set;}
		global ProjectWrapper(Project__c projectRecord,Boolean isChangeProject,Date startDate,Date endDate) {
	    	this.projectRecord 			= projectRecord;
	    	this.isChangeProject 		= isChangeProject;
	    	this.startDate 				= startDate;
	    	this.endDate				= endDate;
	    }
	}
	global class AssignmentWrapper	{
		@AuraEnabled public Assignment__c assignRecord 								{get;set;}
		@AuraEnabled public Boolean  isChangeAssignment 							{get;set;}
		@AuraEnabled public Date   startDate                                   		{get;set;}
		@AuraEnabled public Date   endDate                                     		{get;set;}
		global AssignmentWrapper(Assignment__c assignRecord,Boolean isChangeAssignment,Date startDate,Date endDate) {
	    	this.assignRecord 			= assignRecord;
	    	this.isChangeAssignment 	= isChangeAssignment;
	    	this.startDate 				= startDate;
	    	this.endDate				= endDate;
	    }
	}

}