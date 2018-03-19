trigger OpportunityTrigger on Opportunity (after update,after insert,before insert,before update) {
    
    //update Scenario
    if(Trigger.isAfter && Trigger.isUpdate) {
        OpportunityTriggerHandler.createProject(trigger.newMap);
        OpportunityTriggerHandler.onAfterUpdate(trigger.newMap,trigger.oldMap);
    }   
    //insert Scenario
    if(Trigger.isAfter && Trigger.isInsert) {
        OpportunityTriggerHandler.createProject(trigger.newMap);
        OpportunityTriggerHandler.onAfterInsert(trigger.new);
    }
    //before update
    if(Trigger.isBefore && Trigger.isUpdate) {
        OpportunityTriggerHandler.checkLinkedServiceOpportunityForWorkRequest(trigger.newMap,trigger.oldMap);
        OpportunityTriggerHandler.validationForOverlapOpportunityMSADates(trigger.new);
        OpportunityTriggerHandler.applicableMsaAgreement(trigger.new);
    }
    //before insert
    if(Trigger.isBefore && Trigger.isInsert) {
        OpportunityTriggerHandler.applicableMsaAgreement(trigger.new);
        OpportunityTriggerHandler.validationForOverlapOpportunityMSADates(trigger.new);
    }  
     
}