trigger TaskCustomTrigger on Task (after insert, after update) {
	if(Trigger.isAfter) {
		if(Trigger.isUpdate || Trigger.isInsert) {
			EventAndTaskTriggerHandler.deleteRelatedAttachments();
		}
	}
}