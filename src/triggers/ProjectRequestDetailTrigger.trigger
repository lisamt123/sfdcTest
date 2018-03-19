trigger ProjectRequestDetailTrigger on Project_Request_Detail__c (after insert, after update,after delete,after undelete) {
    
    ProjectRequestDetailTriggerHandler objProjectRequestDetailHandler = new ProjectRequestDetailTriggerHandler();
    
    if(trigger.isAfter) {
    	
    	if(trigger.isInsert && RecursionHelperHandler.isAfterInsert) {
    		RecursionHelperHandler.isAfterInsert = false;
    		objProjectRequestDetailHandler.onAfterInsert(Trigger.new, Trigger.oldMap);		
    	}
    	
    	if(trigger.isUpdate && RecursionHelperHandler.isAfterUpdate) { 
            System.debug('trigger.isUpdate'+trigger.isUpdate);
    		RecursionHelperHandler.isAfterUpdate = false;
    		objProjectRequestDetailHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);    		
    	}

        if(trigger.isDelete) {
            objProjectRequestDetailHandler.onAfterDelete(Trigger.old);
        }
        if(trigger.isUndelete) {
            objProjectRequestDetailHandler.onAfterUnDelete(Trigger.new);
        } 	
    }       
}