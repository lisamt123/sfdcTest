trigger ReleaseTrigger on Release__c (before delete, before insert,after insert) {
	if(Trigger.isBefore) {
		if(Trigger.isInsert) {
			ReleaseTriggerHandler.updateClonedFrom();
		}
	}
	if(Trigger.isAfter) {
		if(Trigger.isInsert) {
			ReleaseTriggerHandler.cloneReleaseOnHeroku();
		}
	}
	if(Trigger.isBefore) {
    	if(Trigger.isDelete){
    		ReleaseTriggerHandler.deleteReleaseInfoFromHeroku(); 
    	}  
    }
}