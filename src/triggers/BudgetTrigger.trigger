trigger BudgetTrigger on Budget__c (after insert, after update, after delete, after undelete) {

	
	if(Trigger.isAfter) {
	    if(Trigger.isInsert || Trigger.isUndelete ) {
	      	//BudgetTriggerHandler.updateAvailabilityHours(Trigger.new,true);
	      	BudgetTriggerHandler.updateTimeEntries(Trigger.new);
	    }
	    if(Trigger.isUpdate) {
	      	//BudgetTriggerHandler.updateAvailabilityHours(Trigger.new,false);
	    }
	    if(Trigger.isDelete) {
	     	// BudgetTriggerHandler.updateAvailabilityHours(Trigger.old,true);
	    }
    }

}