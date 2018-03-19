@RestResource(urlMapping='/SyncRelease/')
global with sharing class SyncRelease {
    @HttpPost
    global static String SyncReleaseRecord() {
        RestRequest req = RestContext.request;
        try {
            List<Release__c> releaseList = [SELECT Validation_Status__c, Allow_Deletion__c, CodeScan_Status__c, Scan_Running__c, 
                                                Validation_Running__c, CodeScan_Describe_Error__c, Validation_Describe_Error__c,AsyncResultId__c  
                                            FROM Release__c 
                                            WHERE ID =: req.params.get('Release_Id')];
            if(releaseList.size() > 0) {
                for( Release__c release :releaseList) {
                	if(req.params.get('Task') == 'CodeReview') {
                		release.CodeScan_Status__c            = req.params.get('Status');
                		release.Scan_Running__c               = false; 
                		release.CodeScan_Describe_Error__c    = req.params.get('Describe_Error'); 
                        release.Allow_Deletion__c             = false;
                		
                	}
                	if(req.params.get('Task') == 'DeploymentValidation') {
                		release.Validation_Status__c          = req.params.get('Status');
                		release.Validation_Running__c         = false; 
                        release.Allow_Deletion__c             = false;
                		release.Validation_Describe_Error__c  = req.params.get('Describe_Error'); 
                	}
                	if(req.params.get('Task') == 'ValidationProgress') {
                		release.AsyncResultId__c = req.params.get('asyncResultId'); 
                	}
                } 
                update releaseList;  
                return 'Success';
            }
        }
        catch(Exception ex) {
          return 'Failure : '+ ex.getMessage();
        }  
        return 'Success';
   }
}