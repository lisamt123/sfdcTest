trigger ExpertAchievementTrigger on Expert_Achievement__c (before insert,after insert,after delete,after undelete,after update) {
    
    if(Trigger.isAfter) {
    	if(Trigger.isInsert ) {
    		ExpertAchievementTriggerHandler.updateAchievementCountOnLead(Trigger.new);
    		List<Expert_Achievement__c> newExpertAchievements = new List<Expert_Achievement__c>();
    		List<Expert_Achievement__c> newLeadExpertAchievements = new List<Expert_Achievement__c>();
    		for(Expert_Achievement__c ea : Trigger.new)
    		{
    			if(ea.Contact__c != null)
    			{
    				newExpertAchievements.add(ea);
    			}
    			if(ea.Lead__c != null)
    			{
    				newLeadExpertAchievements.add(ea);
    			}
    		}
    		if(!newExpertAchievements.isEmpty())
    		{
    			ExpertAchievementTriggerHandler.insertExpertSkillsForExpertAchievements(newExpertAchievements,null);
    		}
    		if(!newLeadExpertAchievements.isEmpty())
    		{
    			ExpertAchievementTriggerHandler.insertExpertSkillsForLeadExpertAchievements(newLeadExpertAchievements,null);
    		}
	    }
    	if(Trigger.isDelete || Trigger.isUndelete ) {
	        ExpertAchievementTriggerHandler.updateAchievementCountOnLead(Trigger.old);
	    }
    }
    if(Trigger.isBefore){
    	if(Trigger.isInsert){
    		List<Expert_Achievement__c> newExpertAchievementsForContact = new List<Expert_Achievement__c>();
    		List<Expert_Achievement__c> newExpertAchievementsForLead = new List<Expert_Achievement__c>();
    		for(Expert_Achievement__c eaRec : Trigger.new)
    		{
    			if(eaRec.Contact__c != null)
    			{
    				newExpertAchievementsForContact.add(eaRec);
    			}
    			if(eaRec.Lead__c != null)
    			{
    				newExpertAchievementsForLead.add(eaRec);
    			}
    		}
    		if(!newExpertAchievementsForContact.isEmpty())
    		{
    			ExpertAchievementTriggerHandler.preventDuplicateInsertionForContact(newExpertAchievementsForContact);
    		}
    		if(!newExpertAchievementsForLead.isEmpty())
    		{
    			ExpertAchievementTriggerHandler.preventDuplicateInsertionForLead(newExpertAchievementsForLead);
    		}
    	}
    }
}