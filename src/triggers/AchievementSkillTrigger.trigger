trigger AchievementSkillTrigger on Achievement_Skill__c (after insert) {
	if(Trigger.isAfter) {
		if(Trigger.isInsert) {
			AchievementSkillTriggerHandler.updateExpertSkills(Trigger.new);
		}
	}
}