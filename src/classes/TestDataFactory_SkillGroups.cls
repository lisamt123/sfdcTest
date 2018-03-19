public with sharing class TestDataFactory_SkillGroups {
    
    public static List<Skill_Group__c> generateSkillGroups(String groupName, Integer numOfRecords) {
		return generateSkillGroupsInternal(groupName, numOfRecords);
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<Skill_Group__c> generateSkillGroupsInternal(String groupName, Integer numOfRecords) {
    	List<Skill_Group__c> skillGroupsList = new List<Skill_Group__c>();
        
        for(Integer i = 0; i < numOfRecords; i++) {
        	Skill_Group__c sg = new Skill_Group__c();
        	sg.Name = groupName;
			skillGroupsList.add(sg);
        }
        
        return skillGroupsList;
    }
}