public class ViewReleaseMetadataLightning {
    
    @AuraEnabled
    public Static String getInit(String releaseId)
    {
        Release__c release = [SELECT Id, Name, Project__c, Project__r.Name, Status__c, Source__c, Source__r.Status__c, Target__c, Actual_Release_Date__c,
                                    Target_Release_Date__c, Created_On_Heroku__c 
                                FROM Release__c 
                   			    WHERE Id =: releaseId]; 

        ReleaseStuff obj = searchStory(release);
        //System.debug(obj);
        return JSON.serialize(obj);
    }
    
    public static ReleaseStuff searchStory(Release__c release) {
        Map<String, String> storyMap            = new Map<String, String>();         
        List<ReleaseStories> releaseStoryList   = new List<ReleaseStories>();
        List<Artifacts> releaseArtifactList     = new List<Artifacts>();
        List<Stories> storyList                 = new List<Stories>();
        Set<String> selectedStory               = new Set<String>();

        HttpResponse res = RestRequestHandlerForHeroku.sendRequest('POST','Release_StoriesArtifacts_Retrieve','',release.Id,release.Project__c,release.Project__r.Name);
       
        if(res.getStatusCode() == 200 ) {
            ReleaseArtifactResponseJSON searchStory = (ReleaseArtifactResponseJSON) JSON.deserialize(res.getBody(), ReleaseArtifactResponseJSON.class);
            if(searchStory.Status == 'Success') {
                for(ReleaseStories record : searchStory.ReleaseStories) {
					if(record.storyId != '') {
						if(record.artifacts[0].metadataType != '')
							releaseStoryList.add(record);
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
        
        if(releaseStoryList.size() > 0) {
        	List<String> storyIdList = new List<String>();
        	for(ReleaseStories story : releaseStoryList)
        		storyIdList.add(story.storyId);
        	List<Story__c> releaseStory = [SELECT Id, Name FROM Story__c WHERE Id IN:storyIdList];
	        if(releaseStory != null) {
	        	for(Story__c story : releaseStory)
	        		storyMap.put(story.Id, Story.Name);
	        	for(ReleaseStories story : releaseStoryList) {
                    story.artifacts.sort();
                    Stories newStory     = new Stories();
                    newStory.storyId     = story.storyId;
                    newStory.storyName   = storyMap.get(story.storyId);
	        		newStory.artifacts   = story.artifacts;
	        		storyList.add(newStory);
	        	}
	        }
        }

        releaseArtifactList.sort();
        ReleaseStuff obj        = new ReleaseStuff();
        obj.releaseArtifactList = releaseArtifactList;
        obj.releaseStoryList    = storyList;
        return obj;
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
        @AuraEnabled public String name          {get;set;}
        @AuraEnabled public String action        {get;set;}
        @AuraEnabled public String artifactId    {get;set;}
    }
    
    public class ReleaseStuff {
    	@AuraEnabled public String baseUrl                          {get{return  Site.getPathPrefix().split('/s')[0];} set;}
        @AuraEnabled public List<Artifacts> releaseArtifactList		{get;set;}
        @AuraEnabled public List<Stories>  releaseStoryList  	    {get;set;}
    }
    
    public class Stories {
        @AuraEnabled public String storyId				{get;Set;}
        @AuraEnabled public String storyName			{get;Set;}
        @AuraEnabled public List<Artifacts> artifacts	{get;Set;}
    }
}