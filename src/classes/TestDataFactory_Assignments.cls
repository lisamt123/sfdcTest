public with sharing class TestDataFactory_Assignments {
	
	public static List<Assignment__c> generateAssignments(Id projectId, Id contactId, Id rateId, String status, String role, String assignmentType, Boolean billable, Integer plannedHours, Integer numOfRecords) {
    	return generateAssignmentsInternal(projectId, contactId, rateId, status, role, assignmentType, billable, plannedHours, numOfRecords);
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<Assignment__c> generateAssignmentsInternal(Id projectId, Id contactId, Id rateId, String status, String role, String assignmentType, Boolean billable, Integer plannedHours, Integer numOfRecords) {
    	List<Assignment__c> assignmentList = new List<Assignment__c>();
        
        for(Integer i = 0; i < numOfRecords; i++) {
            Assignment__c assignment        = new Assignment__c();
            assignment.Project__c           =  projectId;
            assignment.Resource__c          = contactId;
            assignment.Rate__c              = rateId;
            assignment.Status__c            = status;
            assignment.Role__c              = role;
            assignment.Assignment_Type__c   = assignmentType;
            assignment.Billable__c          = billable;
            assignment.Planned_Hours__c     = plannedHours;
            assignment.Start_Date__c        = Date.today();
            assignment.End_Date__c          = Date.today().addYears(1);

            assignmentList.add(assignment); 
        } 
        
        return assignmentList;
    }
}