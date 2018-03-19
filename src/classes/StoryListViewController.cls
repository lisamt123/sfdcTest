public with sharing class StoryListViewController 
{
	@AuraEnabled
    public static List<Story__c> getAllStories(String recordID){
    	
    	String recID = recordID;
        System.debug(recID);
        List<Story__c> storyList = new List<Story__c>();
        if(recID == null || recID == '' || recID == 'undefined')
        {
            storyList = [SELECT id, CreatedById, Name, Story_Name__c, Sprint__c, Sprint__r.Name, Sprint__r.Project__c, Status__c, Project__c, Project__r.name, 
                Epic__c, Epic__r.Name, Epic__r.Project__c, Level_of_Effort__c, Priority__c, Functional_Owner__c, Functional_Owner__r.Name,
                Description__c, Test_Scenarios__c, Technical_Design_Notes__c FROM Story__c ORDER BY Id ASC LIMIT 10];
        }
        else
        {
            storyList = [SELECT id, CreatedById, Name, Story_Name__c, Sprint__c, Sprint__r.Name, Sprint__r.Project__c, Status__c, Project__c, Project__r.name, 
                Epic__c, Epic__r.Name, Epic__r.Project__c, Level_of_Effort__c, Priority__c, Functional_Owner__c, Functional_Owner__r.Name,
                Description__c, Test_Scenarios__c, Technical_Design_Notes__c FROM Story__c WHERE Id >: recID ORDER BY Id ASC LIMIT 10];
        }
        return storyList;
    }
}