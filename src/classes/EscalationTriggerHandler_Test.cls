@isTest
private class EscalationTriggerHandler_Test 
{
	@isTest static void test_EscalationTriggerHandler() 
	{
		Escalation__c escalation = new Escalation__c(Type__c = 'Technical', Subject__c = 'I have a problem');
		insert escalation;
		Test.startTest();
			Escalation__Share escalationShare = [SELECT Id, ParentId FROM Escalation__Share LIMIT 1];
			System.assertEquals(escalationShare.ParentId, escalation.Id);
		Test.stopTest();
	}
}