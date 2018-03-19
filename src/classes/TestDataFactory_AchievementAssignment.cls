public with sharing class TestDataFactory_AchievementAssignment {
    
    public static List<Achievement_Assignment__c> generateAchievementAssignment(Id achievementId, Integer numOfRecords) {
        return generateAchievementAssignmentInternal(achievementId, numOfRecords);
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<Achievement_Assignment__c> generateAchievementAssignmentInternal(Id achievementId, Integer numOfRecords) {
        List<Achievement_Assignment__c> achievementAssignmentsList = new List<Achievement_Assignment__c>();
        
        for(Integer i = 0; i < numOfRecords; i++) {
            Achievement_Assignment__c ask = new Achievement_Assignment__c();
            ask.Achievement__c = achievementId;
            achievementAssignmentsList.add(ask);
        }
        
        return achievementAssignmentsList;
    }
}