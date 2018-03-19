trigger ProjectRequestTrigger on Project_Request__c (after insert, after update, after delete, after undelete, before update) {
    
    ProjectRequestTriggerHandler objProjectRequestHandler = new ProjectRequestTriggerHandler();
    
    if(trigger.isAfter) {
        
        if(trigger.isInsert) {
             
            objProjectRequestHandler.onAfterInsert(Trigger.new, Trigger.oldMap);        
        }
        
        if(trigger.isUpdate) { 
            
            objProjectRequestHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);            
        }
        
        if(trigger.isDelete) {
            
            objProjectRequestHandler.onAfterDelete(Trigger.old);
        }
        
        if(trigger.isUnDelete) {
            
            objProjectRequestHandler.onAfterUnDelete(Trigger.new);
        }
    }
}