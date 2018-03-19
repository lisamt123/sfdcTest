public with sharing class ReleaseTriggerHandler {
	
	public static void deleteReleaseInfoFromHeroku() {
		List<String> releaseIdList = new List<String>();
		for(Release__c release: (List<Release__c>)Trigger.old) {
            if(release.Scan_Running__c) 
                release.addError('Release can\'t be deleted while code scan is in progress.' );
            else if(release.Validation_Running__c) 
                release.addError('Release can\'t be deleted while a validation/deployment is in progress.' );
            else if(!release.Delete_on_Heroku__c && !release.Allow_Deletion__c && release.Created_on_Heroku__c) 
                release.addError('This Release has a validation/deployment history or has stored results from a code scan, and cannot be deleted. Contact a 10K Administrator if you need assistance deleting this Release.' );
			else if(release.Created_on_Heroku__c)
                releaseIdList.add(release.Id);
        }

        String projectId    = '';
        String projectName  = '';
        for(Release__c release: [SELECT Id, Project__c, Project__r.Name FROM Release__c WHERE Id IN: releaseIdList]) {
            if(projectId == '' || release.Project__c == projectId) {
                projectId   = release.Project__c;
                projectName = release.Project__r.Name;
            }
            else {
                projectId   = null;
                projectName = null;
            }
        }

        if(releaseIdList.size() > 0)
            removeReleaseFromHeroku(releaseIdList,projectId,projectName);
	}

	@future(callout=true)
    public static void removeReleaseFromHeroku(List<String> releaseIdList,String projectId,String projectName) {
        DeleteRecordsFromHeroku.removeRecordsFromHeroku(releaseIdList,projectId,projectName);
    }

	public static void updateClonedFrom() {
		for(Release__c release : (List<Release__c>)Trigger.new) { 
			if(release.isClone()) {
				release.Validation_Status__c = null;
				release.Validation_Describe_Error__c = null;
				release.CodeScan_Status__c = null;
				release.CodeScan_Describe_Error__c = null;  
				release.Allow_Deletion__c = true;  
			}
		}
	}

	public static void cloneReleaseOnHeroku() {
		for(Release__c release : (List<Release__c>)Trigger.new)
			if(release.isClone())
				cloneRelease(release.Id,release.getCloneSourceId());
	}

	@future(callout=true)
	public static void cloneRelease(Id release_Id,Id clonedFromReleaseId) { 
    	String token                           = HerokuToken.headerToken();
    	Organization orgz                      = [SELECT IsSandbox FROM Organization LIMIT 1];
		Heroku_oAuth_Setting__mdt credentials  = [SELECT ID, QualifiedApiName, Heroku_URL__c  FROM Heroku_oAuth_Setting__mdt WHERE IsSandbox__c =: orgz.IsSandbox LIMIT 1];
		Map<String, String> herokuEndpointsMap = new Map<String, String>();
		
		for(Heroku_Endpoint__mdt endpoint : [SELECT ID, QualifiedApiName, Endpoint__c FROM Heroku_Endpoint__mdt])
			herokuEndpointsMap.put(endpoint.QualifiedApiName, endpoint.Endpoint__c);
		User currentUser = [SELECT Id, Name, ContactId FROM User WHERE Id =: UserInfo.getUserId() ];
        List<Contact> contactList = [SELECT Id, Account.Name, AccountId FROM Contact WHERE Id =: currentUser.ContactId ];
        Http h          = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(credentials.Heroku_URL__c + herokuEndpointsMap.get('Release_Clone'));
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('token',token);

        String requestJSONBody = '{"Release_Id_OLD":"'+ clonedFromReleaseId +'",'+ 
                   				 '"Release_Id_NEW":"' + release_Id +'",'+
                                 '"User_Id":"'      + currentUser.Id +'",'+
                                 '"User_Name":"'    + currentUser.Name +'",'+
                                 '"Account_Id":"'   + (contactList.size() > 0 ? contactList[0].AccountId : null) +'",'+
                                 '"Account_Name":"' + (contactList.size() > 0 ? contactList[0].Account.Name : null)  +'"}';

        req.setBody(requestJSONBody );
        req.setTimeOut(120000);
        
        HttpResponse res = h.send(req);
        System.debug(res);
        System.debug(res.getBody());
    }
}