public with sharing class ManageReleaseArtifactsController {
    
    public Id selectedSprint                                            {get;set;}
    public Release__c release                                           {get;set;}
    public boolean connectionExist										{get;set;}
    public String finalResult                                           {get;set;}
    public List<SelectOption> sprintList                                {get;set;}
    public List<StoryWrapper> storyWrapperList                          {get;set;}
    public Set<String> selectedStory                                    {get;set;}
    public String responseMessage;
    
    @TestVisible private Heroku_oAuth_Setting__mdt credentials;
    @TestVisible private Map<String, String> herokuEndpointsMap;
    
    public ManageReleaseArtifactsController(ApexPages.StandardController std) {
    	
		herokuEndpointsMap    = new Map<String, String>();
        Organization orgz     = [SELECT IsSandbox FROM Organization LIMIT 1];
        credentials           = [SELECT ID, QualifiedApiName, Callback_URL__c, Call_back_Url_Community__c, Consumer_Key__c, Consumer_Secret__c,Heroku_URL__c  
                                FROM Heroku_oAuth_Setting__mdt 
                                WHERE IsSandbox__c =: orgz.IsSandbox LIMIT 1];
		
		for(Heroku_Endpoint__mdt endpoint : [SELECT ID, QualifiedApiName, Endpoint__c FROM Heroku_Endpoint__mdt]) {
			herokuEndpointsMap.put(endpoint.QualifiedApiName, endpoint.Endpoint__c);
		}
        
        storyWrapperList    = new List<StoryWrapper>();
        release             = [SELECT Id, Name, Project__c, Status__c, Source__c, Source__r.Status__c, Target__c, Actual_Release_Date__c,Target_Release_Date__c, Created_On_Heroku__c 
                                FROM Release__c 
                                WHERE Id =: std.getRecord().Id];
        
        selectedStory       = searchStory(release.Id,credentials, herokuEndpointsMap);
        
        sprintList = new List<SelectOption>();
        List<Project__c> projectsList = [SELECT Id, Name, 
                                        (SELECT Id, Name,Status__c FROM Sprints__r ORDER BY Projected_End_Date__c DESC LIMIT 999)
                                        FROM Project__c WHERE Id =: release.Project__c ];
        sprintList.add(new SelectOption('','--None--'));
        if(projectsList.size() > 0) {
            for(Sprint__c sprint : projectsList[0].Sprints__r) {
                sprintList.add(new SelectOption(sprint.Id,sprint.Name));
                if(sprint.Status__c == 'In Progress' && selectedSprint == null)
                    selectedSprint = sprint.Id;
            }
        }
        retrieveStories();

        if(release != null && release.Source__c == null || release.Source__r.Status__c != 'Active') {
        	connectionExist = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'No active development connection found for this release, please add an active source.'));
        }
        else
        	connectionExist = true;
    }
    
    public Set<String> searchStory(String relId, Heroku_oAuth_Setting__mdt credentials, Map<String, String> herokuEndpointsMap) {
        String token                = HerokuToken.headerToken();
        Set<String> selectedStory   = new Set<String>();
        Http h                      = new Http();
        HttpRequest req             = new HttpRequest();

        req.setEndpoint(credentials.Heroku_URL__c + herokuEndpointsMap.get('Release_StoriesArtifacts_Retrieve') + relId);
        req.setMethod('GET');
        req.setHeader('token',token); 
        req.setTimeOut(120000);
        HttpResponse res = h.send(req);
        //system.debug('========='+res);
        //system.debug('========='+res.getBody());
        List<Artifacts> selectedMetadaList = new List<Artifacts>();
        if(res.getStatusCode() == 200 ) {
            ReleaseArtifactResponseJSON searchStory = (ReleaseArtifactResponseJSON) JSON.deserialize(EncodingUtil.urlDecode(res.getBody(), 'UTF-8'), ReleaseArtifactResponseJSON.class);
            if(searchStory.Status == 'Success') {
                if(searchStory.ReleaseStories != null) {
                    for(Integer index = 0; index < searchStory.releaseStories.size() ; index++) {
                        if(searchStory.releaseStories[index].storyId != null && searchStory.releaseStories[index].storyId != '') {
                            selectedStory.add(searchStory.releaseStories[index].storyId);
                            searchStory.releaseStories.remove(index);
                            index--;
                        }
                    }
                }
            }
            finalResult = JSON.serialize(searchStory);
        }
        return selectedStory;
    }
     
    @remoteAction
    public static MetadataLightningWrapper getConnectionMetadata(Id recId,String recordsLimit,String searchText,String selectedMetadataType, String selectedMetadaListJson) {
        Map<String, String> herokuEndpointsMap  = new Map<String, String>();
        Release__c release                      = [SELECT Id, Name, Project__c, Status__c, Source__c, Source__r.Status__c, Target__c, Actual_Release_Date__c,Target_Release_Date__c, Created_On_Heroku__c 
                                                    FROM Release__c 
                                                    WHERE Id =: recId];
        Organization orgz                       = [SELECT IsSandbox FROM Organization LIMIT 1];
        Heroku_oAuth_Setting__mdt credentials   = [SELECT ID, QualifiedApiName, Heroku_URL__c  
                                                    FROM Heroku_oAuth_Setting__mdt 
                                                    WHERE IsSandbox__c =: orgz.IsSandbox LIMIT 1];
                                        
        
        for(Heroku_Endpoint__mdt endpoint : [SELECT ID, QualifiedApiName, Endpoint__c FROM Heroku_Endpoint__mdt]) {
            herokuEndpointsMap.put(endpoint.QualifiedApiName, endpoint.Endpoint__c);
        }
        
        Manage_Artifacts_Setting__mdt defaultLimit = [SELECT ID, QualifiedApiName, Limit__c  FROM Manage_Artifacts_Setting__mdt LIMIT 1];
        
        //--Retrieving existing story Artifacts.
        List<Artifacts> wrapperListSelected = new List<Artifacts>();
        if(selectedMetadaListJson != null && selectedMetadaListJson != '' && selectedMetadaListJson != '[]') {
            wrapperListSelected = (List<Artifacts>)JSON.deserialize(selectedMetadaListJson,List<Artifacts>.class);
        }
        
        Map<String,Set<String>> storyArtifactsMap = new Map<String,Set<String>>(); 

        for(Artifacts wrapperObj : wrapperListSelected) {
            if(wrapperObj.metadataType != null && wrapperObj.metadataType != '') {
                if(!storyArtifactsMap.containsKey(wrapperObj.metadataType))
                    storyArtifactsMap.put(wrapperObj.metadataType,new Set<String>());
                Set<String> artifactsSet = new Set<String>();
                if(wrapperObj.metadataName != null) {
                    for(MetadataName nameWrap : wrapperObj.metadataName) {
                        artifactsSet.add(wrapperObj.metadataType + '##' +nameWrap.name);
                    }
                    storyArtifactsMap.get(wrapperObj.metadataType).addAll(artifactsSet);
                }
            }
        }

        String token            = HerokuToken.headerToken();
        Integer recCount        = Integer.valueOf(recordsLimit) + Integer.valueOf(defaultLimit.Limit__c);
        String requestJSONBody = '{"type":"'+ (selectedMetadataType == 'All' ? '' : selectedMetadataType) +'",'+ 
                                 '"name":"'+ (searchText == null ? '' : searchText) +'",'+
                                 '"limit":"'+ recCount  +'"}';
        
        Http h          = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(credentials.Heroku_URL__c + herokuEndpointsMap.get('Connection_Metadata') + release.Source__c);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('token',token);
        req.setBody(requestJSONBody );
        req.setTimeOut(120000);
        HttpResponse res = h.send(req);
        
        //system.debug(res);
        //system.debug(res.getBody());
        
        List<Artifacts> wrapperList = new List<Artifacts>(); 
        if(res.getStatusCode() == 200) {
            MetadataResponse response = (MetadataResponse) JSON.deserialize(EncodingUtil.urlDecode(res.getBody(), 'UTF-8'), MetadataResponse.class);
            //--Getting artifacts list from response.
            if(response.Status == 'Success' && response.metadataList != null) 
                wrapperList = response.metadataList;
        }
        wrapperList.sort();
        List<SelectOptionCustom> metadataOption = new List<SelectOptionCustom>();
        metadataOption.add(new SelectOptionCustom('All','All'));
        for(Integer index = 0;index < wrapperList.size() ;index++) {
            //--Setting metadata options.
            if(wrapperList[index].metadataType != null)
                metadataOption.add(new SelectOptionCustom(wrapperList[index].metadataType,wrapperList[index].metadataType));

            if(wrapperList[index].metadataName.size() > 0 && wrapperList[index].metadataName[0].name == '') {
                wrapperList.remove(index);
                index--;
                continue;
            }
            
            if(storyArtifactsMap.containsKey(wrapperList[index].metadataType)) {
                Set<MetadataName> metadataNameSet = new Set<MetadataName>(wrapperList[index].metadataName);
                for(MetadataName metadataName: wrapperList[index].metadataName) {
                    if(storyArtifactsMap.get(wrapperList[index].metadataType).contains(wrapperList[index].metadataType + '##' + metadataName.name))
                        metadataNameSet.remove(metadataName);
                }
                wrapperList[index].metadataName = new List<MetadataName>(metadataNameSet);
            }
        }  
        
        wrapperListSelected.sort();
        wrapperList.sort();
        return new MetadataLightningWrapper(wrapperListSelected,wrapperList,metadataOption);
    }

    public void updateSelectedStorySet() {
        for(StoryWrapper storyWrapper: storyWrapperList) {
            if(storyWrapper.selected)
                selectedStory.add(storyWrapper.story.Id);
            else if(!storyWrapper.selected && selectedStory.contains(storyWrapper.story.Id))
                selectedStory.remove(storyWrapper.story.Id);
        }
    }

    public void retrieveStories() {
        updateSelectedStorySet();
        List<Story__c> storiesList = [SELECT Id, Name, Status__c FROM Story__c WHERE Sprint__c =:  selectedSprint AND Sprint__c != null];
        storyWrapperList = new List<StoryWrapper>();
        for(Story__c story : storiesList) {
            if(selectedStory.contains(story.Id))
                storyWrapperList.add(new StoryWrapper(true,story));
            else
                storyWrapperList.add(new StoryWrapper(false,story));
        }
    }

    public PageReference manageRelease()
    {
        //selectStories();
        String token    = HerokuToken.headerToken();
        Http h          = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('token',token);
        String requestJSONBody;
        String actualReleaseDate = release.Actual_Release_Date__c == null ? '' : release.Actual_Release_Date__c.format();
        String targetReleaseDate = release.Target_Release_Date__c == null ? '' : release.Target_Release_Date__c.format();
        if(release.Created_On_Heroku__c) {
            req.setEndpoint(credentials.Heroku_URL__c + herokuEndpointsMap.get('Release_Update') + release.Id);
            req.setMethod('PUT');
            requestJSONBody = '{"Release_Name":"' + release.Name + '",' +
                              '"Project":"'+ release.Project__c +'",'+
                              '"Source_Connection":"'+ release.Source__c +'",'+
                              '"Target_Connection":"'+ release.Target__c +'",'+
                              '"Actual_Release_Date":"'+ actualReleaseDate +'",'+
                              '"Target_Release_Date":"'+ targetReleaseDate +'",'+
                              '"Status":"'+ release.Status__c  +'"}';
        }
        else {
            req.setEndpoint(credentials.Heroku_URL__c + herokuEndpointsMap.get('Release_Create'));
            req.setMethod('POST');
            requestJSONBody = '{"Release_Id":"' + release.Id + '",' +
                              '"Release_Name":"'+ release.Name +'",'+ 
                              '"Project":"'+ release.Project__c +'",'+
                              '"Source_Connection":"'+ release.Source__c +'",'+
                              '"Target_Connection":"'+ release.Target__c +'",'+
                              '"Actual_Release_Date":"'+ actualReleaseDate +'",'+
                              '"Target_Release_Date":"'+ targetReleaseDate +'",'+
                              '"Status":"'+ release.Status__c  +'"}';
        }                 
        req.setBody(requestJSONBody);
        req.setTimeOut(120000);
        HttpResponse res = h.send(req);
        
        //System.debug(res);
        //System.debug('Release : '+res.getBody());
        
        if(res.getStatusCode() == 200 ) {
            ResponseWrapper response = (ResponseWrapper) JSON.deserialize(EncodingUtil.urlDecode(res.getBody(), 'UTF-8'), ResponseWrapper.class);
            responseMessage = response.message;
            
            if(!release.Created_On_Heroku__c && response.status == 'Success') {
                release.Created_On_Heroku__c = true;
                update release;
            }
        }
        return null;
    }

	@remoteAction
    public static String createArtifacts(Id recId, String mainArtifactsStr, String selectedStories) { 
    	
        Map<String, String> herokuEndpointsMap  = new Map<String, String>();
        Organization orgz                       = [SELECT IsSandbox FROM Organization LIMIT 1];
        Heroku_oAuth_Setting__mdt credentials   = [SELECT ID, QualifiedApiName, Heroku_URL__c  
                                                    FROM Heroku_oAuth_Setting__mdt 
                                                    WHERE IsSandbox__c =: orgz.IsSandbox LIMIT 1];
        
        for(Heroku_Endpoint__mdt endpoint : [SELECT ID, QualifiedApiName, Endpoint__c FROM Heroku_Endpoint__mdt]) {
            herokuEndpointsMap.put(endpoint.QualifiedApiName, endpoint.Endpoint__c);
        }
    	
        List<Artifacts> metadataBundleWrapper = (Artifacts[])JSON.deserialize(mainArtifactsStr, list<Artifacts>.class);

        List<ArtifactWrapper> artifactWrapperList = new List<ArtifactWrapper>();
        for(Artifacts metadataWrapper : metadataBundleWrapper) {
            for(MetadataName nameWrapp : metadataWrapper.metadataName) {
                artifactWrapperList.add(new ArtifactWrapper(nameWrapp.artifactId,nameWrapp.action));
            }
        }

    	List<String> storiesIdList = (String[])JSON.deserialize(selectedStories, list<String>.class);
        List<ArtifactWrapper> artifactWrapper = new List<ArtifactWrapper>();

        String token    = HerokuToken.headerToken();
        Http h          = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(credentials.Heroku_URL__c + herokuEndpointsMap.get('Release_StoriesArtifacts_Create') + recId);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('token',token); 

        String requestJSONBody = JSON.serialize(new ReleaseArtifactRequestWrapper(artifactWrapperList, storiesIdList));

        req.setBody(requestJSONBody );
        req.setTimeOut(120000);

        HttpResponse res = h.send(req);
        //System.debug(res);
        //System.debug('======Retrieve======='+res.getBody());
        if(res.getStatusCode() == 200 ) {
            ResponseWrapper response = (ResponseWrapper)JSON.deserialize(EncodingUtil.urlDecode(res.getBody(), 'UTF-8'), ResponseWrapper.class);
            if(response.status == 'Success') {
                if(response.storyList != null && response.storyList.size()>0) {
                    List<Story__c> storyList = [SELECT Id, Created_On_Heroku__c FROM Story__c WHERE Id IN: response.storyList AND Created_On_Heroku__c = false];
                    if(storyList != null && storyList.size() > 0) {
                        for(Story__c story : storyList)
                            story.Created_On_Heroku__c = true;
                        update storyList;
                    }
                }
            }
        } 
        return 'Success';
    }

    public class ResponseWrapper {
        public String message;
        public List<String> storyList;
        public String status;
    }

    public class ArtifactWrapper {
        String artifact_Id;
        String action;
        public ArtifactWrapper(String artifact_Id, String action) {
            this.artifact_Id = artifact_Id;
            this.action = action;
        }
    }

    public class ReleaseArtifactRequestWrapper {
        public List<ArtifactWrapper> Release_Artifacts;
        public List<String> Release_Stories;
        
        public ReleaseArtifactRequestWrapper(List<ArtifactWrapper> Release_Artifacts, List<String> Release_Stories) {
            this.Release_Artifacts  = Release_Artifacts;
            this.Release_Stories    = Release_Stories;
        }
    }

    public class MetadataResponse {
        public String Status;
        public List<Artifacts> metadataList;
    }
    public class StoryWrapper {
        public Boolean selected {get;set;}
        public Story__c story   {get;set;}

        public StoryWrapper(Boolean selected, Story__c story) {
            this.selected   = selected;
            this.story      = story;
        }
    }

    public Class MetadataLightningWrapper {
        public string selectedMetadataType              {get;set;}
        public List<Artifacts> wrapperList              {get;set;}
        public List<Artifacts> wrapperListSelected      {get;set;}
        public List<SelectOptionCustom> metadataOption  {get;set;}
        
        public MetadataLightningWrapper (List<Artifacts> wrapperListSelected,List<Artifacts> wrapperList ,List<SelectOptionCustom> metadataOption) {
            this.wrapperListSelected    = wrapperListSelected;
            this.wrapperList            = wrapperList;
            this.metadataOption         = metadataOption;
        }
    }

    public Class SelectOptionCustom {
        public String label {get;set;}
        public String value {get;set;}
        
        public SelectOptionCustom(String value,String label) {
            this.value = value;
            this.label = label;
        }
    }

    //-------------------------

    public class ReleaseArtifactResponseJSON {
        public String Status;
        public List<ReleaseStories> ReleaseStories;
    }

    public class ReleaseStories {
        public String storyId;
        public List<Artifacts> artifacts;
    }

    public class Artifacts implements Comparable {
        public String metadataType              {get;Set;}
        public List<MetadataName> metadataName  {get;set;} 

        public Integer compareTo(Object compareTo) {
            Artifacts other = (Artifacts) compareTo;
            if (this.metadataType > other.metadataType)
              return 1;
            else if (this.metadataType == other.metadataType)
              return 0;
            return -1;
        }
    }

    public class MetadataName implements Comparable {
        public String name          {get;set;}
        public String action        {get;set;}
        public String artifactId    {get;set;}

        public MetadataName(String name, String artifactId  , String action) {
            this.name       = name;
            this.action     = action;
            this.artifactId = artifactId  ;
        }

        public Integer compareTo(Object compareTo) {
            MetadataName other = (MetadataName) compareTo;
            if (this.name > other.name)
              return 1;
            else if (this.name == other.name)
              return 0;
            return -1;
        }
    }
}