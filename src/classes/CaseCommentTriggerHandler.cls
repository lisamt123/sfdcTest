public with sharing class CaseCommentTriggerHandler 
{
	public static void updateFirstResponseDate(List<CaseComment> caseCommentList) 
	{
		List<CaseComment> commentList = caseCommentList;

		Set<Id> userIdSet = new Set<Id>();
		Set<Id> caseIdSet = new Set<Id>();
        for(CaseComment comment : commentList)
        {
            caseIdSet.add(comment.ParentId);
        }

        commentList = [SELECT Id, CreatedDate, CreatedById, ParentId 
                        FROM CaseComment 
                        WHERE ParentId IN: caseIdSet  
                        ORDER BY CreatedDate ASC];

        for(CaseComment comment : commentList)
        {
            userIdSet.add(comment.CreatedById);
        }
        
        List<Case> caseList = [SELECT Id, First_Response_Date_Time__c, RecordTypeId 
                                FROM Case 
                                WHERE Id IN: caseIdSet];

        List<User> userList = [SELECT Id, DoubleClick_for_Salesforce_Support_Team__c 
                                FROM User 
                                WHERE Id IN: userIdSet 
                                AND DoubleClick_for_Salesforce_Support_Team__c = true];

        List<Case> caseListToBeUpdated = new List<Case>();
        final Id RECORDTYPEID_CASE = Schema.SObjectType.Case.RecordTypeInfosByName.get('DoubleClick for Salesforce').RecordTypeId;
        for(Case caseRec : caseList)
        {
        	if(caseRec.RecordTypeId == RECORDTYPEID_CASE)
        	{
	            for(CaseComment comment : commentList)
	            {
	                if(caseRec.Id == comment.ParentId && caseRec.First_Response_Date_Time__c == null)
	                {
	                    for(User userRec : userList)
	                    {
	                        if(comment.CreatedById == userRec.Id)
	                        {
	                            caseRec.First_Response_Date_Time__c = comment.CreatedDate;
	                            caseListToBeUpdated.add(caseRec);
	                        }
	                    }
	                }
	            }
	        }
        }
        if(!caseListToBeUpdated.isEmpty())
        {
            update caseListToBeUpdated;
        }
	}
}