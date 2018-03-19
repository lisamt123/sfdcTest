trigger woobot_Story on Story__c (after insert, after update, after delete) {
    woobot.GenericTriggerHandler.afterTriggerHandler(!Trigger.isDelete ? Trigger.new : null, !Trigger.isInsert ? Trigger.oldMap : null);
}