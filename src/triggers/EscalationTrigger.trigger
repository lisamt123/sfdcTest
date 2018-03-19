trigger EscalationTrigger on Escalation__c (after insert) 
{
	if(Trigger.isAfter)
	{
		if(Trigger.isInsert)
		{
			EscalationTriggerHandler.escalationManualShareEdit(Trigger.new);
		}
	}
}