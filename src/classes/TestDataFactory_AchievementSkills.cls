public with sharing class TestDataFactory_AchievementSkills {
	
	public static List<Achievement_Skill__c> generateAchievementSkills(Id achievementId, Id skillId, Integer numOfRecords) {
		return generateAchievementSkillsInternal(achievementId, skillId, numOfRecords);
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<Achievement_Skill__c> generateAchievementSkillsInternal(Id achievementId, Id skillId, Integer numOfRecords) {
    	List<Achievement_Skill__c> achievementSkillsList = new List<Achievement_Skill__c>();
        
        for(Integer i = 0; i < numOfRecords; i++) {
        	Achievement_Skill__c ask = new Achievement_Skill__c();
        	ask.Achievement__c = achievementId;
        	ask.Skill__c = skillId;
			achievementSkillsList.add(ask);
        }
        
        return achievementSkillsList;
    }
}