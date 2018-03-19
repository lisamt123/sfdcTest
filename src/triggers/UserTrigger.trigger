trigger UserTrigger on User (before insert, before update, after insert, after update) {

    UserTriggerHandler handler = new UserTriggerHandler();

	if(Trigger.isBefore && Trigger.isInsert) {
        handler.onBeforeInsert(Trigger.new);
    }

    if(Trigger.isBefore && Trigger.isUpdate) {
        handler.onBeforeUpdate(Trigger.newMap, Trigger.new, Trigger.oldMap, Trigger.old);
    }    

    if(Trigger.isAfter && Trigger.isInsert) {
        handler.onAfterInsert(Trigger.newMap, Trigger.new);
    }

    if(Trigger.isAfter && Trigger.isUpdate) {
        handler.onAfterUpdate(Trigger.newMap, Trigger.new, Trigger.oldMap, Trigger.old);
    }
}