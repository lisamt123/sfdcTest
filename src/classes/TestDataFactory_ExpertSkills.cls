public with sharing class TestDataFactory_ExpertSkills {
    
    public static List<Expert_Skill__c> generateExpertSkills(Id contactId, Id leadId, Id skillId, Integer numOfRecords) {
		return generateExpertSkillsInternal(contactId, leadId, skillId, numOfRecords);
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<Expert_Skill__c> generateExpertSkillsInternal(Id contactId, Id leadId, Id skillId, Integer numOfRecords) {
    	List<Expert_Skill__c> expertSkillsList = new List<Expert_Skill__c>();
        
        for(Integer i = 0; i < numOfRecords; i++) {
        	Expert_Skill__c esk = new Expert_Skill__c();
        	esk.Contact__c = contactId;
        	esk.Lead__c = leadId;
        	esk.Skill__c = skillId;
			expertSkillsList.add(esk);
        }
        
        return expertSkillsList;
    }
}