public with sharing class TestDataFactory_ExpertAchievements {
    
    public static List<Expert_Achievement__c> generateExpertAchievements(String status, Id leadId, String holderName, boolean createdFromSync, Id contactId, Date certificationDate, Id achievementId, Integer numOfRecords) {
		return generateExpertAchievementsInternal(status, leadId, holderName, createdFromSync, contactId, certificationDate, achievementId, numOfRecords);
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<Expert_Achievement__c> generateExpertAchievementsInternal(String status, Id leadId, String holderName, boolean createdFromSync, Id contactId, Date certificationDate, Id achievementId, Integer numOfRecords) {
    	List<Expert_Achievement__c> exAchievementsList = new List<Expert_Achievement__c>();
        
        for(Integer i = 0; i < numOfRecords; i++) {
        	Expert_Achievement__c each = new Expert_Achievement__c();
        	each.Status__c = status;
        	each.Lead__c = leadId;
        	each.Holder_Name__c = holderName;
        	each.Created_From_Sync__c = createdFromSync;
        	each.Contact__c = contactId;
        	each.Certification_Date__c = certificationDate;
        	each.Achievement__c = achievementId;
			exAchievementsList.add(each);
        }
        
        return exAchievementsList;
    }
}