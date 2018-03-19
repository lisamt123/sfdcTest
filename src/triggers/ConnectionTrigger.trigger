trigger ConnectionTrigger on Connection__c (before delete, before insert, before update) {
    if(Trigger.isBefore) {
    	if(Trigger.isDelete){
    		ConnectionTriggerHandler.deleteConnectionInfoFromHeroku(); 
    	}  
    	if(Trigger.isInsert){
    		ConnectionTriggerHandler.checkPrimaryDevelopmentEnvironment(); 
    	}  
    	if(Trigger.isUpdate){
    		ConnectionTriggerHandler.checkPrimaryDevelopmentEnvironment(); 
    	}  
    }
}