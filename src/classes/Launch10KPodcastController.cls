public without sharing class Launch10KPodcastController{
    public List<X10K_Launch_Episode__c> launchEpisodeList{get;set;}
    
    public Launch10KPodcastController() {
        launchEpisodeList = new List<X10K_Launch_Episode__c>();
        launchEpisodeList = [Select Id,Name,Episode_Id__c,Episode_Description__c,Episode_Number__c From X10K_Launch_Episode__c ORDER BY Episode_Number__c DESC LIMIT 10000];
    }
}