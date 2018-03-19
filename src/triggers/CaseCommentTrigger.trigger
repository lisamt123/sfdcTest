trigger CaseCommentTrigger on CaseComment (after insert) 
{
	if(Trigger.isAfter)
	{
		if(Trigger.isInsert)
		{
			CaseCommentTriggerHandler.updateFirstResponseDate(Trigger.new);
		}
	}
}