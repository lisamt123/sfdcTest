trigger AssignmentTrigger on Assignment__c (after insert,after update,after delete,after undelete, before update, before insert) {

    //after insertion
    if(Trigger.isInsert && trigger.isAfter){
        AssignmentTriggerHandler.processInsert(trigger.new);
        AssignmentTriggerHandler.createWeekRecords(trigger.new,false,trigger.oldMap);
        
    }
    //after update
    if(Trigger.isUpdate && trigger.isAfter){
        AssignmentTriggerHandler.processUpdate(trigger.new);
        AssignmentTriggerHandler.expertToExpertFeedback(trigger.new);
    }
    //deleting all the shared records
    if(Trigger.isDelete && Trigger.isAfter){
        AssignmentTriggerHandler.processDelete(trigger.old);
    }
    //recreating share records on undelete
    if(Trigger.isUnDelete && Trigger.isAfter){
        AssignmentTriggerHandler.processInsert(trigger.new);
    }
    //before update
    if(Trigger.isBefore && Trigger.isUpdate) {
        //AssignmentTriggerHandler.preventRateChangeIfTimeEntryExist();
        AssignmentTriggerHandler.createWeekRecords(trigger.new,true,trigger.oldMap);
        AssignmentTriggerHandler.validationForOverlapAssignmentDates(trigger.new);
    }
    //before insert
    if(Trigger.isBefore && Trigger.isInsert) {
        AssignmentTriggerHandler.validationForOverlapAssignmentDates(trigger.new);
    }
    
}