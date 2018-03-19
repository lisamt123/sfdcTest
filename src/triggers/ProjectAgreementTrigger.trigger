trigger ProjectAgreementTrigger on Project_Agreement__c (before insert) {
    
    if(trigger.isInsert && trigger.isBefore) {
        ProjectAgreementTriggerHandler.preventOverlappingAgreements(Trigger.new);
    }
}