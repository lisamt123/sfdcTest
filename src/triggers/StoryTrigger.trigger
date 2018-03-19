trigger StoryTrigger on Story__c (before delete,before update,before insert, after insert, after update) 
{
    if(Trigger.isAfter){
        if(Trigger.isUpdate)
        {
            StoryTriggerHandler.updateSprintStatus();
            StoryTriggerHandler.updateSprintLOE();
        }
        if(Trigger.isInsert)
        {
            StoryTriggerHandler.updateTotalHourLogged(Trigger.new,true);
            StoryTriggerHandler.updateSprintLOE();
        }
    }
    if(Trigger.isBefore) {
    	if(Trigger.isDelete){
    		StoryTriggerHandler.deleteStoryInfoFromHeroku(); 
    	}  
    }

    if(Trigger.isBefore && Trigger.isInsert){
        StoryTriggerHandler.updateStoryLOE(Trigger.new);
    }

    if(Trigger.isBefore && Trigger.isUpdate){
        StoryTriggerHandler.updateTotalHourLogged(Trigger.new,false);
        StoryTriggerHandler.updateStoryLOE(Trigger.new);
    }
}