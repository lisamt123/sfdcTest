trigger TaskTrigger on Task__c (after insert,before insert,before update, after update) {

	TaskTriggerHandler handler = new TaskTriggerHandler();

	if(Trigger.isAfter && Trigger.isInsert) {
		handler.onAfterInsert(Trigger.new, Trigger.newMap);
		TaskTriggerHandler.updateTotalHourLogged(Trigger.new,true);
	}

	if(Trigger.isBefore && Trigger.isInsert){
		TaskTriggerHandler.updateTaskLOE(Trigger.new);
	}

	if(Trigger.isBefore && Trigger.isUpdate) {
		TaskTriggerHandler.updateTaskLOE(Trigger.new);
		TaskTriggerHandler.updateTotalHourLogged(Trigger.new,false);
	}

	if(Trigger.isAfter && Trigger.isUpdate) {
		handler.onAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
	}
}