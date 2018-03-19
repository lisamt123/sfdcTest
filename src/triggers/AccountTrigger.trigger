trigger AccountTrigger on Account (before insert, before update,after insert,after update) 
{
    
    if(Trigger.isBefore && ( Trigger.isInsert || Trigger.isUpdate)){
        AccountTriggerHandler.populateCountryBasedISOCode(Trigger.new) ;
    }
    
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert)
        {
            AccountTriggerHandler.runAccountInvoiceRollupsUtility(Trigger.new);
        }
        if(Trigger.isUpdate)
        {   
            AccountTriggerHandler.updateAccountRelatedContact(Trigger.old, Trigger.new);
        }
    }
}