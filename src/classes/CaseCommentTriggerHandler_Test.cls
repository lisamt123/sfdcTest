@isTest
private class CaseCommentTriggerHandler_Test 
{
	@isTest static void test_method_one() 
	{
		final Id RECORDTYPEID_CASE = Schema.SObjectType.Case.RecordTypeInfosByName.get('DoubleClick for Salesforce').RecordTypeId;
		Case caseRec = new Case(Subject='blah');
		caseRec.RecordTypeId = RECORDTYPEID_CASE;
        insert caseRec;
        TestDataFactory factory = new TestDataFactory();   
        List<User> userList = factory.createUsersWith10KDeliveryPartnerProfileNew(1);
        userList[0].DoubleClick_for_Salesforce_Support_Team__c = true;
        Insert userList;
        Test.startTest();
        	CaseComment caseCommentRec = new CaseComment();
	        caseCommentRec.CommentBody 	= 'Test';
	        caseCommentRec.ParentId 	= caseRec.Id;
	        caseCommentRec.CreatedById  = userList[0].Id;
	        insert caseCommentRec;
	        List<CaseComment> comments = [select Id,CommentBody from CaseComment where ParentId=:caseRec.Id];
	        System.assert(comments.size() == 1);
		Test.stopTest();        
	}
}