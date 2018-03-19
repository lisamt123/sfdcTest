trigger LicenseTrigger on sfLma__License__c (after insert, after update) {
	if(Trigger.isAfter) {
		if(Trigger.isInsert || Trigger.isUpdate) {
			if(!System.isFuture())
				LicenseTriggerHandler.setAccountAndContact(Trigger.new);
		}
	}
}