trigger RateTrigger on Rate__c (before insert, before update) {

    RateTriggerHandler handler = new RateTriggerHandler();

    if(Trigger.isBefore && Trigger.isInsert) {
        handler.onBeforeInsert(Trigger.new);
    }
    else if(Trigger.isBefore && Trigger.isUpdate) {
        handler.onBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    }
}