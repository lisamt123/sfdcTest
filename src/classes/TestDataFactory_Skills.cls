public with sharing class TestDataFactory_Skills {
    
    public static List<ProfileSkill> generateSkills(String skillName, Id skillCategoryId, Id skillGroupId, Id skillTypeId, Integer numOfRecords) {
		return generateProfileSkillsInternal(skillName, skillCategoryId, skillGroupId, skillTypeId, numOfRecords);
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<ProfileSkill> generateProfileSkillsInternal(String skillName, Id skillCategoryId, Id skillGroupId, Id skillTypeId, Integer numOfRecords) {
    	List<ProfileSkill> profileSkillList = new List<ProfileSkill>();
        
        for(Integer i = 0; i < numOfRecords; i++) {
        	ProfileSkill psk = new ProfileSkill();
        	psk.Name = skillName;
        	psk.Skill_Category__c = skillCategoryId;
        	psk.Skill_Group__c = skillGroupId;
        	psk.Skill_Type__c = skillTypeId;
			profileSkillList.add(psk);
        }
        
        return profileSkillList;
    }
}