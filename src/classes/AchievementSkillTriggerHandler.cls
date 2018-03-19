public with sharing class AchievementSkillTriggerHandler {
	public static void updateExpertSkills(List<Achievement_Skill__c> achievementSkillList) {
		
		Set<Id> achievementIdset = new Set<Id>();
		for(Achievement_Skill__c achievementSkill : achievementSkillList) {
			achievementIdset.add(achievementSkill.Achievement__c);
		}
		if(achievementIdset.size() > 0) {
			List<Expert_Achievement__c> expertAchievementList = new List<Expert_Achievement__c>();
			List<Expert_Achievement__c> leadExpertAchievementList = new List<Expert_Achievement__c>();
			for(Expert_Achievement__c expertAchievement: [SELECT Id,Contact__c,Lead__c,Achievement__c FROM Expert_Achievement__c WHERE Achievement__c IN: achievementIdset]) {
				if(expertAchievement.Contact__c != null) {
					expertAchievementList.add(expertAchievement);
				}
				if(expertAchievement.Lead__c != null) {
					leadExpertAchievementList.add(expertAchievement);
				}
			}
			if(expertAchievementList.size() > 0) {
				ExpertAchievementTriggerHandler.insertExpertSkillsForExpertAchievements(expertAchievementList,Trigger.newMap.keySet());
			}
			if(leadExpertAchievementList.size() > 0) {
				ExpertAchievementTriggerHandler.insertExpertSkillsForLeadExpertAchievements(leadExpertAchievementList,Trigger.newMap.keySet());
			}
		}
		
	}
}