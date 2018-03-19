@RestResource(urlMapping='/SyncStory/')
global with sharing class SyncStory {
    @HttpPost
    global static String SyncStoryRecord() {
        RestRequest req = RestContext.request;
        try {
            List<Story__c> storyList = [SELECT Scan_Running__c, Allow_Deletion__c, CodeScan_Status__c, CodeScan_Describe_Error__c FROM Story__c WHERE ID =: req.params.get('Story_Id')];
            if(storyList != null && storyList.size() > 0) {
                for(Story__c story : storyList) {
                    story.Scan_Running__c               = false; 
                    story.CodeScan_Status__c            = req.params.get('Status');  
                    story.CodeScan_Describe_Error__c    = req.params.get('Describe_Error'); 
                    story.Allow_Deletion__c             = false;
                } 
                update storyList ; 
                return 'Success';
            }
        }
        catch(Exception ex) {
          return 'Failure : '+ ex.getMessage();
        }  
        return 'Success';
   }
}