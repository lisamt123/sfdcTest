trigger LeadTrigger on Lead (after insert, after update, before insert, before update ,after delete) {
    
    if(Trigger.isAfter) {
        
        if(Trigger.isInsert) {
            //LeadTriggerHandler.updateRefferalRecords();
            LeadTriggerHandler.updateWebAssessorleadId();
        }

        if(Trigger.isUpdate) {
            LeadTriggerHandler.updateRefferalRecords();
            LeadTriggerHandler.updateWebAssessorleadId();
            LeadTriggerHandler.createOldReferralRecords();
        }
        if(Trigger.isDelete) {
            LeadTriggerHandler.createOldReferralRecordsFromDeletedLeads();
        }
    }

    if(Trigger.isBefore) {
        if(Trigger.isInsert || Trigger.isUpdate) { 
            LeadTriggerHandler.populateReferralCode();
            LeadTriggerHandler.populateCountryBasedISOCode(Trigger.new) ;

        }
    }
}