public with sharing class ViewReleaseMetadataController {
    public String baseUrl                           {get;set;}
    public Release__c release                       {get;set;}
    public Map<String, String> storyMap				{get;set;}
    public List<Artifacts> releaseArtifactList      {get;set;}
    public List<ReleaseStories> releaseStoryList    {get;set;}
    
    @TestVisible private Heroku_oAuth_Setting__mdt credentials;
    @TestVisible private Map<String, String> herokuEndpointsMap;
    
    //--------------Amit Jayaswal 23 Oct 2017-----------------------------
    
    public ViewReleaseMetadataController(ApexPages.StandardController std) 
    {
		herokuEndpointsMap  = new Map<String, String>();
        Organization orgz   = [SELECT IsSandbox FROM Organization LIMIT 1];
        credentials         = [SELECT ID, QualifiedApiName, Callback_URL__c, Call_back_Url_Community__c, Consumer_Key__c, Consumer_Secret__c, Heroku_URL__c  
                                FROM Heroku_oAuth_Setting__mdt 
                                WHERE IsSandbox__c =: orgz.IsSandbox LIMIT 1];
		
		for(Heroku_Endpoint__mdt endpoint : [SELECT ID, QualifiedApiName, Endpoint__c FROM Heroku_Endpoint__mdt]){
			herokuEndpointsMap.put(endpoint.QualifiedApiName, endpoint.Endpoint__c);
		}
		
        release = [SELECT Id, Name, Project__c, Status__c, Source__c, Source__r.Status__c, Target__c, Actual_Release_Date__c,Target_Release_Date__c, Created_On_Heroku__c 
                   FROM Release__c 
                   WHERE Id =: std.getRecord().Id];
        
        storyMap            = new Map<String, String>();         
        releaseStoryList    = new List<ReleaseStories>();
        releaseArtifactList = new List<Artifacts>();
        
        searchStory(release.Id);
        
        //System.debug('Story : ' + releaseStoryList);
        //System.debug('Artifact : ' + releaseArtifactList);
        
        if(releaseStoryList.size() > 0) {
        	Set<String> storyList = new Set<String>();
        	
        	for(ReleaseStories story : releaseStoryList)
        		storyList.add(story.storyId);
        	System.debug(storyList+ '================');
        	List<Story__c> releaseStory = [SELECT Id, Name FROM Story__c WHERE Id IN:storyList];
            System.debug(releaseStory.size()+'+++++++++++++++++++++++');
	        if(releaseStory != null) {
	        	for(Story__c story : releaseStory)
	        		storyMap.put(story.Id, Story.Name);
	        }
        }
        
        baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    }
    
    public void searchStory(String relId)
    {
        String token                = HerokuToken.headerToken();
        Set<String> selectedStory   = new Set<String>();
        Http h                      = new Http();
        HttpRequest req             = new HttpRequest();
        req.setEndpoint(credentials.Heroku_URL__c + herokuEndpointsMap.get('Release_StoriesArtifacts_Retrieve') + relId);
        req.setMethod('GET');
        req.setHeader('token',token); 
        req.setTimeOut(120000);
        HttpResponse res = h.send(req);
        
        //System.debug(res);
        //System.debug(res.getBody());
       
        if(res.getStatusCode() == 200 ) {
            ReleaseArtifactResponseJSON searchStory = (ReleaseArtifactResponseJSON) JSON.deserialize(EncodingUtil.urlDecode(res.getBody(), 'UTF-8'), ReleaseArtifactResponseJSON.class);
            if(searchStory.Status == 'Success') {
                for(ReleaseStories record : searchStory.ReleaseStories) {
					if(record.storyId != '') {
						if(record.artifacts[0].metadataType != '') {
                            record.artifacts.sort();
							releaseStoryList.add(record);
						}
						else {
							record.artifacts = new List<Artifacts>();
							releaseStoryList.add(record);
						}
					}
					else {
						if(record.artifacts[0].metadataType != '')
							releaseArtifactList = record.artifacts;
					}
				}
            }
        }
        releaseArtifactList.sort();
    }
	
	public class ReleaseArtifactResponseJSON {
        public String Status;
        public List<ReleaseStories> ReleaseStories;
    }

    public class ReleaseStories {
        public String storyId				{get;Set;}
        public List<Artifacts> artifacts	{get;Set;}
    }

    public class Artifacts implements Comparable {
        @AuraEnabled public String metadataType              {get;Set;}
        @AuraEnabled public List<MetadataName> metadataName  {get;set;} 

        public Integer compareTo(Object compareTo) {
            Artifacts other = (Artifacts) compareTo;
            if (this.metadataType > other.metadataType)
              return 1;
            else if (this.metadataType == other.metadataType)
              return 0;
            return -1;
        }
    }

    public class MetadataName {
        public String name          {get;set;}
        public String action        {get;set;}
        public String artifactId    {get;set;}
    }
    
    //--------------Amit Jayaswal 23 Oct 2017-----------------------------
}