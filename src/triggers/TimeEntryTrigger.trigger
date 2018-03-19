trigger TimeEntryTrigger on Time_Entry__c (before insert, before update,after insert, after update, after delete, after undelete) {
  if(Trigger.isAfter) {
    if(Trigger.isInsert || Trigger.isUndelete ) {
      TimeEntryTriggerHandler.updateBudgetHoursWorked(Trigger.new,true);
      TimeEntryTriggerHandler.updateLoggedHoursStoryAndTask(Trigger.new,true);
    }
    if(Trigger.isUpdate) {
      TimeEntryTriggerHandler.updateBudgetHoursWorked(Trigger.new,false);
      TimeEntryTriggerHandler.updateLoggedHoursStoryAndTask(Trigger.new,false);
    }
    if(Trigger.isDelete) {
      TimeEntryTriggerHandler.updateBudgetHoursWorked(Trigger.old,true);
      TimeEntryTriggerHandler.updateLoggedHoursStoryAndTask(Trigger.old,true);
    }
  }
  if(Trigger.isBefore) {
    if(Trigger.isInsert ) {
      TimeEntryTriggerHandler.updateTimeEntries(Trigger.new,true);
    }
    if(Trigger.isUpdate) {
      TimeEntryTriggerHandler.updateTimeEntries(Trigger.new,false);
    }
  }
}