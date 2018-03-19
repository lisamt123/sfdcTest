/**
@Name           : ProjectTrigger
@Dated          : 27 June, 2016
@Author         :
@Description    :    
*/

trigger ProjectTrigger on Project__c (after insert, before update, after delete, after undelete) {
    //After Insertion
    if(Trigger.isInsert && trigger.isAfter){
        ProjectTriggerHandler.createSharingRecords(trigger.new);
        ProjectTriggerHandler.copyClientProjectDeliveryRequirements(Trigger.new);
    }
    //After Update
    if(Trigger.isUpdate && trigger.isBefore){
        ProjectTriggerHandler.createSharingRecords(trigger.new);
    }
    //Deleting all the Shared Records
    if(Trigger.isDelete && Trigger.isAfter){
        ProjectTriggerHandler.deleteSharedRecords(trigger.old, false);
    }
    //Recreating Share Records on Undelete
    if(Trigger.isUnDelete && Trigger.isAfter){
        ProjectTriggerHandler.createSharingRecords(trigger.new);
    }   
}