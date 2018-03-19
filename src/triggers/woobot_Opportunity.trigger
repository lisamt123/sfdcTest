trigger woobot_Opportunity on Opportunity (after insert, after update, after delete) {
    woobot.GenericTriggerHandler.afterTriggerHandler(!Trigger.isDelete ? Trigger.new : null, !Trigger.isInsert ? Trigger.oldMap : null);
}