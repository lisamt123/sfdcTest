trigger AgreementTrigger on Agreement__c (before update, before insert, after insert, after update) {
 
    if(Trigger.isBefore && Trigger.isUpdate) {
        //AgreementTriggerHandler.preventOverlappingAgreements();
    }

    if(Trigger.isBefore && Trigger.isInsert) {
    	AgreementTriggerHandler.setDefaultAgreementFields();
    }

    if(Trigger.isAfter && Trigger.isInsert) {
    	System.debug('enters in agreement trigger');
    	AgreementTriggerHandler.setRelatedOpportunityAgreementFields(Trigger.new);	
    }
}