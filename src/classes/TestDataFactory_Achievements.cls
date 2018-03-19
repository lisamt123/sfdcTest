public with sharing class TestDataFactory_Achievements {
    
    public static List<Achievement__c> generateAchievements(Id recordTypeId, String achivementName, String achievementCategory, String type, Date expirationDate, boolean isHidden, boolean isInternal, String workBadgeURL, String trailLogoUrl, String overrideUrl, Integer numOfRecords) {
        return generateAchievementsInternal(recordTypeId, achivementName, achievementCategory, type, expirationDate, isHidden, isInternal, workBadgeURL, trailLogoUrl, overrideUrl, numOfRecords);
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<Achievement__c> generateAchievementsInternal(Id recordTypeId, String achivementName, String achievementCategory, String type, Date expirationDate, boolean isHidden, boolean isInternal, String workBadgeURL, String trailLogoUrl, String overrideUrl, Integer numOfRecords) {
        List<Achievement__c> achievementsList = new List<Achievement__c>();
        
        for(Integer i = 0; i < numOfRecords; i++) {
            Achievement__c ach = new Achievement__c();
            ach.Name = achivementName;
            ach.RecordTypeId = recordTypeId;
            ach.Achievement_Category__c = achievementCategory;
            //ach.Type__c = type;
            ach.Expiration_Date__c = expirationDate;
            ach.Hidden__c = isHidden;
            ach.Is_Internal__c = isInternal;
            ach.Work_Badge_Image_URL__c = workBadgeURL;
            ach.Trailhead_Logo_Url__c = trailLogoUrl;
            ach.Override_URL__c = overrideUrl;
            achievementsList.add(ach);
        }
        
        return achievementsList;
    }
}