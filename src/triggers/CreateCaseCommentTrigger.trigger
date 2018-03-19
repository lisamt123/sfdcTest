trigger CreateCaseCommentTrigger on EmailMessage (after insert) 
{
	List<EmailMessage> emailsList = new List<EmailMessage>();
	for(EmailMessage email : Trigger.new)
	{
		if(email.Incoming)
		{
			emailsList.add(email);
		}
	}
	CreateCaseCommentTriggerHandler.copyEmailMessagesToCaseComments(emailsList);
}