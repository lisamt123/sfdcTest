public without sharing class EscalationTriggerHandler 
{
	public static void escalationManualShareEdit(List<Escalation__c> escalationList) 
	{
		List<Escalation__Share> escalationShareList = new List<Escalation__Share>();
		escalationList = [SELECT Id, CreatedById FROM Escalation__c WHERE Id IN : escalationList];
		for(Escalation__c escalation : escalationList)
		{
			Escalation__Share escalationShare = new Escalation__Share();
			escalationShare.ParentId = escalation.Id;
			escalationShare.UserOrGroupId = escalation.CreatedById;
			escalationShare.AccessLevel = 'Edit';
			escalationShare.RowCause = Schema.Escalation__Share.RowCause.Manual;
			escalationShareList.add(escalationShare);
		}
		if(!escalationShareList.isEmpty())
		{
			Database.SaveResult[] escalationShareInsertResult = Database.insert(escalationShareList,false);
		}
	}
}