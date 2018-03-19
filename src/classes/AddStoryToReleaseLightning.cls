public without sharing class AddStoryToReleaseLightning {
	@AuraEnabled
	public static ResultWrapper retrieveReleaseList(Id recId) {
        List<OptionWrapper> releaseStatusPickValuesList 	= new List<OptionWrapper>();
		Schema.DescribeFieldResult fieldResult 			= Release__c.Status__c.getDescribe();
	   	List<Schema.PicklistEntry> ple 					= fieldResult.getPicklistValues();

	   	for(Schema.PicklistEntry f : ple)
	   		releaseStatusPickValuesList.add(new OptionWrapper(f.getLabel(), f.getValue()));

        ResultWrapper resultWrapper = new ResultWrapper();
		List<Story__c> storyList = [SELECT Id, Created_On_Heroku__c, Project__c FROM Story__c WHERE Id =: recId];
		if(storyList.size() > 0) {
			if(storyList[0].Project__c != null) {
				List<Connection__c> connectionList = [SELECT Id FROM Connection__c 
														WHERE Project__c =: storyList[0].Project__c 
														AND Primary_Development_Environment__c = true];
				if(connectionList.size() > 0)
					resultWrapper.source = connectionList[0].Id;
			}
			resultWrapper.story 					= storyList[0];
			resultWrapper.releaseStatusPickValues 	= releaseStatusPickValuesList;
			resultWrapper.isCreatedOnHeroku 		= storyList[0].Created_On_Heroku__c;
			if(storyList[0].Created_On_Heroku__c) {
				List<ManageArtifactsLightning.MetadataWrapper> metadataWrapper = ManageArtifactsLightning.retrieveStoryArtifacts(recId);
				if(metadataWrapper.size() == 0) { 
					resultWrapper.isCreatedOnHeroku = false;
					return resultWrapper;
				}
			}
			else 
				return resultWrapper;
		}

		List<OptionWrapper> releaseIdList = new List<OptionWrapper>();
		if(storyList.size() > 0) {
			List<Release__c> releaseList = [SELECT Id, Name FROM Release__c WHERE Project__c =: storyList[0].Project__c ];
			for(Release__c release : releaseList) {
				releaseIdList.add(new OptionWrapper(release.Id,release.Name));
			}
		}
		resultWrapper.releaseIdList 	= releaseIdList;
		return resultWrapper;
	}

	@AuraEnabled
	public static ResponseWrapper createRelease(Release__c releaseRec) {
		ResponseWrapper response = new ResponseWrapper();
		//New Record 
		List<Connection__c> connectionList = [SELECT Id, Status__c, Created_On_Heroku__c FROM Connection__c WHERE Id =: releaseRec.Source__c];
		if(connectionList.size() > 0) {
			if(connectionList[0].Status__c != 'Active' || !connectionList[0].Created_On_Heroku__c )
				response.message = 'The source connection for the selected release is not active, please select an active source connection.';
			else {
				insert releaseRec;
				response.releaseId 	= releaseRec.Id;
				response.status 	= 'Success';
			}
		}
		return response;
	}

	@AuraEnabled
	public static ResponseWrapper updateReleaseStoryArtifacts(String releaseId, String storyId) {
		ResponseWrapper response = new ResponseWrapper();
        Release__c release  = [SELECT Id, Name, Project__c, Project__r.Name, Status__c, Source__c, Source__r.Status__c, Source__r.Created_On_Heroku__c, Target__c, 
                                Target__r.Status__c, Target__r.Created_On_Heroku__c, Actual_Release_Date__c,Target_Release_Date__c, Created_On_Heroku__c 
                                FROM Release__c 
                                WHERE Id =: releaseId];
        String target = '';
        if(release.Target__c != null && release.Target__r.Status__c == 'Active' && release.Target__r.Created_On_Heroku__c) 
            target = release.Target__c;
        if(release.Source__c != null && release.Source__r.Status__c == 'Active' && release.Source__r.Created_On_Heroku__c) {
        	String requestJSONBody;
            String actualReleaseDate = release.Actual_Release_Date__c == null ? '' : release.Actual_Release_Date__c.format();
            String targetReleaseDate = release.Target_Release_Date__c == null ? '' : release.Target_Release_Date__c.format();
            requestJSONBody = '"Release_Id":"' 			+ release.Id + '",' +
                              '"Release_Name":"'		+ release.Name +'",'+
                              '"Project":"'				+ release.Project__c +'",'+
                              '"Source_Connection":"'	+ release.Source__c +'",'+
                              '"Target_Connection":"'	+ target +'",'+
                              '"Actual_Release_Date":"'	+ actualReleaseDate +'",'+
                              '"Target_Release_Date":"'	+ targetReleaseDate +'",'+
                              '"Status":"'				+ release.Status__c + '"';
                              
            HttpResponse res = RestRequestHandlerForHeroku.sendRequest('POST','Story_Releases_Migrate',requestJSONBody,storyId,release.Project__c,release.Project__r.Name);
            if(res.getStatusCode() == 200 ) {
                response = (ResponseWrapper) JSON.deserialize(EncodingUtil.urlDecode(res.getBody(), 'UTF-8'), ResponseWrapper.class);
                if(response.status == 'Success')
                	response.releaseId = release.Id;
                PageReference redUrl = new ApexPages.StandardController(release).view();
		        response.returnUrl = URL.getSalesforceBaseUrl().toExternalForm() + redUrl.getUrl();
		        system.debug('==========='+redUrl.getUrl());
                return response;
            } 
        }
        else
        	response.message = 'There is no active source connection for the selected release.';
        return response;
	}

	@AuraEnabled
	public static void updateReleaseAndStory(String releaseId, String storyId) {
		List<Story__c> storyList = [SELECT Id, Allow_Deletion__c, Created_On_Heroku__c FROM Story__c WHERE Id =: storyId];
		if(storyList.size() > 0) {
			storyList[0].Created_On_Heroku__c 	= true;
			storyList[0].Allow_Deletion__c 		= false;
			update storyList;
		}
		List<Release__c> releaseList = [SELECT Id, Allow_Deletion__c, Created_On_Heroku__c FROM Release__c WHERE Id =: releaseId];
		if(releaseList.size() > 0) {
			releaseList[0].Created_On_Heroku__c = true;
			update releaseList;
		}
	}

	public class ResultWrapper {
 		@AuraEnabled public String source 									{get;set;}
 		@AuraEnabled public Story__c story 									{get;set;}
 		@AuraEnabled public Boolean isCreatedOnHeroku						{get;set;}
 		@AuraEnabled public List<OptionWrapper> releaseIdList 				{get;set;}
 		@AuraEnabled public List<OptionWrapper> releaseStatusPickValues 	{get;set;}
	}

	public class ResponseWrapper {
		@AuraEnabled public String status 		{get;set;}
		@AuraEnabled public String returnUrl	{get;set;}
 		@AuraEnabled public String message 		{get;set;}
		@AuraEnabled public String releaseId 	{get;set;}
	}

	public class OptionWrapper {
 		@AuraEnabled public String value {get;set;}
 		@AuraEnabled public String label {get;set;}
 		public OptionWrapper(String value,String label) {
 			this.value = value;
 			this.label = label;
 		}
	}

	public class JSONResponseStoryReleases {
 		@AuraEnabled public List<String> releaseList 	{get;set;}
 		@AuraEnabled public String status 				{get;set;}
	}
}