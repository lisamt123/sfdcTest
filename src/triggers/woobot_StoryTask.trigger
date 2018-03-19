trigger woobot_StoryTask on Task__c (after insert, after update, after delete) {
    woobot.GenericTriggerHandler.afterTriggerHandler(!Trigger.isDelete ? Trigger.new : null, !Trigger.isInsert ? Trigger.oldMap : null);
}