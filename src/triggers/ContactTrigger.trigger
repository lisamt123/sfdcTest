trigger ContactTrigger on Contact (before insert,after insert,after update,before update,after delete) 
{
    if(Trigger.isBefore)
    {
        ContactTriggerHandler conTriggerHandler = new ContactTriggerHandler();
        if(Trigger.isInsert)
        {
            conTriggerHandler.updateCreatedFromLead(Trigger.new);
            conTriggerHandler.populateReferralCode();
            ContactTriggerHandler.populateCountryBasedISOCode(Trigger.new) ;

        }
        if(Trigger.isUpdate) {
            conTriggerHandler.populateReferralCode();
            ContactTriggerHandler.populateCountryBasedISOCode(Trigger.new) ;
        }
    }
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert || Trigger.isUpdate)
        {
            ContactTriggerHandler conTriggerHandler = new ContactTriggerHandler();
            conTriggerHandler.updateWebAssessorContactId(Trigger.new,Trigger.oldMap);
        }
        if(Trigger.isUpdate) {
            ContactTriggerHandler.createOldReferralRecords();
        }
        if(Trigger.isDelete) {
            ContactTriggerHandler.createOldReferralRecordsFromDeletedContacts();
        }
    }

}