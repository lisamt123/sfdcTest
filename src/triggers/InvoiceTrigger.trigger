trigger InvoiceTrigger on Invoice__c (before insert, before update, after update, after delete, after undelete) {
	
	InvoiceTriggerHandler objInvoiceTriggerHandler = new InvoiceTriggerHandler();
	
	if(trigger.isBefore) {
        
        if(trigger.isInsert) {
             
            objInvoiceTriggerHandler.onBeforeInsert(Trigger.new);        
        }
        if(trigger.isUpdate) {
            InvoiceTriggerHandler.invoiceValidationRule(Trigger.new, Trigger.oldMap);
            InvoiceTriggerHandler.calculateProfitMargin(Trigger.new); 
        }
	}
	
	if(trigger.isAfter) {
        
        if(trigger.isUpdate) { 
            
            objInvoiceTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
            InvoiceTriggerHandler.notifyAccountsPrimaryContact(Trigger.new, Trigger.oldMap);
            InvoiceTriggerHandler.updateUniqueKeyof_InvoiceLineItems(Trigger.oldMap , Trigger.newMap);
        }
        
        if(trigger.isDelete) {
            
            objInvoiceTriggerHandler.onAfterDelete(Trigger.oldMap);
        }
        
        if(trigger.isUnDelete) {
            
            objInvoiceTriggerHandler.onAfterUnDelete(Trigger.new);
        }
    }    
}