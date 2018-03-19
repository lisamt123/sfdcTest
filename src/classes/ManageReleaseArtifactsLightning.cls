global without sharing class ManageReleaseArtifactsLightning {
    
    @AuraEnabled
    public static ManageReleaseArtifactsMainWrapper getManageReleaseArtifacts(Id recId,String recordsLimit,String searchText,String selectedMetadataType,String selectedMetadaListJson,String selectedStoryString,String selectedSprint,Boolean forceQuery) {
        Set<String> selectedStory       = new Set<String>();
        Release__c release              = [SELECT Id, Name, Project__c, Project__R.Name, Status__c, Source__c, Source__r.Status__c, Target__c, Actual_Release_Date__c,
                                                Target_Release_Date__c, Created_On_Heroku__c, Source__r.Refresh_Running__c, Source__r.Metadata_Last_Described__c
                                            FROM Release__c 
                                            WHERE Id =: recId];
        List<Project__c> projectsList   = [SELECT Id, Name, 
                                                (SELECT Id, Name,Status__c 
                                                FROM Sprints__r 
                                                ORDER BY Projected_End_Date__c DESC LIMIT 249)  
                                            FROM Project__c WHERE Id =: release.Project__c ];
        Set<Id> sprintIdSet             = new Set<Id>(); 
        List<SelectOptionCustom> sprintList = new List<SelectOptionCustom>();
        sprintList.add(new SelectOptionCustom('','--None--'));
        //String selectedSprint = '';
        if(projectsList.size() > 0 ) {
            for(Sprint__c sprint : projectsList[0].Sprints__r) {
                sprintList.add(new SelectOptionCustom(sprint.Id,sprint.Name));
                sprintIdSet.add(sprint.Id);
                if(sprint.Status__c == 'In Progress' && selectedSprint == '')
                    if(selectedSprint == '')
                        selectedSprint = sprint.Id;
            }
        }
        Map<Id,Story__c> storyMap = new Map<Id,Story__c>([SELECT Id, Name, Status__c , Sprint__c, Story_Name__c 
                                                            FROM Story__c 
                                                            WHERE Sprint__c IN: sprintIdSet]);
        List<Artifacts> wrapperListSelected = new List<Artifacts>();
        if(selectedMetadaListJson != null && selectedMetadaListJson != '' && selectedMetadaListJson != '[]')
            wrapperListSelected = (List<Artifacts>)JSON.deserialize(selectedMetadaListJson,List<Artifacts>.class);

        if(selectedStoryString != null && selectedStoryString != '' && selectedStoryString != '[]')
            selectedStory = new Set<String>((String[])JSON.deserialize(selectedStoryString, list<String>.class));

        Map<String,String> storyAndArtifactsMap = new Map<String,String>();
        Map<String,String> storyIdAndArtifactsMap = new Map<String,String>();
        ReleaseArtifactResponseJSON searchStory = searchStory(recId);
        if(searchStory.Status == 'Success') {
            if(searchStory.ReleaseStories != null) {
                for(ReleaseStories story : searchStory.releaseStories) {
                    selectedStory.add(story.storyId);
                    if(story.storyId != null && story.storyId != '' && storyMap.containsKey(story.storyId)) {
                        for(Artifacts artifact :story.Artifacts) {
                            if(artifact.metadataType != '') {
                                for(MetadataName metadataName : artifact.metadataName) {
                                    if(!storyAndArtifactsMap.containsKey(artifact.metadataType + '#' + metadataName.name)) {
                                        storyAndArtifactsMap.put(artifact.metadataType + '#' + metadataName.name,storyMap.get(story.storyId).Name);
                                        storyIdAndArtifactsMap.put(artifact.metadataType + '#' + metadataName.name,story.storyId);
                                    }
                                    else {
                                        storyAndArtifactsMap.put(artifact.metadataType + '#' + metadataName.name, storyAndArtifactsMap.get(artifact.metadataType + '#' + metadataName.name) + ', ' + storyMap.get(story.storyId).Name);
                                        storyIdAndArtifactsMap.put(artifact.metadataType + '#' + metadataName.name, storyIdAndArtifactsMap.get(artifact.metadataType + '#' + metadataName.name) + ',' + story.storyId);
                                    }
                                }
                            }
                        }
                    }
                    if(story.storyId == '' && selectedMetadaListJson == '[]' && forceQuery)
                        wrapperListSelected.addAll(story.Artifacts);
                }
            }
        }

        //Set<storyAnd
        for(Artifacts artifact :wrapperListSelected) {
            for(MetadataName metadataName : artifact.metadataName) {
                if(storyAndArtifactsMap.containsKey(artifact.metadataType + '#' + metadataName.name))
                    metadataName.storyName = storyAndArtifactsMap.get(artifact.metadataType + '#' + metadataName.name);
            }
        }

        Map<String,Set<String>> storyArtifactsMap = new Map<String,Set<String>>(); 
        Set<String> artifactsSetComplete = new Set<String>();
        for(Artifacts wrapperObj : wrapperListSelected) {
            if(wrapperObj.metadataType != null && wrapperObj.metadataType != '') {
                if(!storyArtifactsMap.containsKey(wrapperObj.metadataType))
                    storyArtifactsMap.put(wrapperObj.metadataType,new Set<String>());
                Set<String> artifactsSet = new Set<String>();
                if(wrapperObj.metadataName != null) {
                    for(MetadataName nameWrap : wrapperObj.metadataName)
                        artifactsSet.add(wrapperObj.metadataType + '#' +nameWrap.name);
                    storyArtifactsMap.get(wrapperObj.metadataType).addAll(artifactsSet);
                    artifactsSetComplete.addAll(artifactsSet);
                }
            }
        }

        if(selectedMetadaListJson != '[]') {
            for(Artifacts wrapperObj : (List<Artifacts>)JSON.deserialize(selectedMetadaListJson,List<Artifacts>.class)) {
                if(wrapperObj.metadataType != null && wrapperObj.metadataType != '') {
                    if(!storyArtifactsMap.containsKey(wrapperObj.metadataType))
                        storyArtifactsMap.put(wrapperObj.metadataType,new Set<String>());
                    Set<String> artifactsSet = new Set<String>();
                    if(wrapperObj.metadataName != null) {
                        for(MetadataName nameWrap : wrapperObj.metadataName)
                            artifactsSet.add(wrapperObj.metadataType + '#' +nameWrap.name);
                        storyArtifactsMap.get(wrapperObj.metadataType).addAll(artifactsSet);
                        artifactsSetComplete.addAll(artifactsSet);
                    }
                }
            }
        }

        Set<String> storyIdSetToUpdate = new Set<String>();
        for(String artifactTypeAndName : storyIdAndArtifactsMap.keySet()) {
            if(!artifactsSetComplete.contains(artifactTypeAndName))
                storyIdSetToUpdate.addAll(storyIdAndArtifactsMap.get(artifactTypeAndName).split(','));
        }

        List<StoryWrapper> storyWrapperListToUpdate = new List<StoryWrapper>();
        for(String storyId : storyIdSetToUpdate)
            storyWrapperListToUpdate.add(new StoryWrapper(false,storyMap.get(storyId)));
        // Filling the story Wrapper here     
        List<Artifacts> wrapperList             = new List<Artifacts>(); 
        List<SelectOptionCustom> metadataOption = new List<SelectOptionCustom>();
        List<StoryWrapper> storyWrapperList     = retrieveStories(selectedSprint,JSON.serialize(new List<String>(selectedStory)));
        
        Integer recCount = 0;
        if(release != null && release.Source__c != null && release.Source__r.Status__c == 'Active') {
            Manage_Artifacts_Setting__mdt defaultLimit = [SELECT ID, QualifiedApiName, Limit__c  FROM Manage_Artifacts_Setting__mdt LIMIT 1];
            recCount                = Integer.valueOf(recordsLimit) + Integer.valueOf(defaultLimit.Limit__c);
            String requestJSONBody  = '"type":"'       + (selectedMetadataType == 'All' ? '' : selectedMetadataType) +'",'+ 
                                     '"name":"'         + (searchText == null ? '' : searchText) +'",'+
                                     '"limit":"'        + recCount +'"';
            
            HttpResponse res = RestRequestHandlerForHeroku.sendRequest('POST','Connection_Metadata',requestJSONBody,release.Source__c,release.Project__c,release.Project__r.Name);
            //system.debug(res.getBody());
            if(res.getStatusCode() == 200) {
                //wrapperList = (List<MetadataWrapper>)JSON.deserialize(res.getBody(), List<MetadataWrapper>.class);
                MetadataResponse response = (MetadataResponse) JSON.deserialize(res.getBody(), MetadataResponse.class);
                if(response.Status == 'Success' && response.metadataList != null)
                    wrapperList = response.metadataList;
            }
            wrapperList.sort();
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
                        if(storyArtifactsMap.get(wrapperList[index].metadataType).contains(wrapperList[index].metadataType + '#' + metadataName.name))
                            metadataNameSet.remove(metadataName);
                    }
                    wrapperList[index].metadataName = new List<MetadataName>(metadataNameSet);
                }
            }  

            wrapperListSelected.sort();
            wrapperList.sort();
        }
        return new ManageReleaseArtifactsMainWrapper(selectedStory,recCount,release,sprintList,selectedSprint,storyWrapperList,metadataOption,wrapperListSelected,wrapperList,storyWrapperListToUpdate);
    }

    public static ReleaseArtifactResponseJSON searchStory(String relId) {
        Release__c release = connectionRefreshStatus(relId);
        HttpResponse res = RestRequestHandlerForHeroku.sendRequest('POST','Release_StoriesArtifacts_Retrieve','',relId,release.Project__c,release.Project__r.Name);
        List<Artifacts> selectedMetadaList = new List<Artifacts>();
        if(res.getStatusCode() == 200 )  {
            ReleaseArtifactResponseJSON searchStory = (ReleaseArtifactResponseJSON) JSON.deserialize(res.getBody(), ReleaseArtifactResponseJSON.class);
            if(searchStory.Status == 'Success')
                return searchStory;
        }
        return null;
    }

    @AuraEnabled
    public static List<StoryWrapper> retrieveStories(string selectedSprint,String selectedStoryString) {
        
        Set<String> selectedStorySet            = new Set<String>((String[])JSON.deserialize(selectedStoryString, list<String>.class));
        List<StoryWrapper> newStoryWrapperList  = new List<StoryWrapper>();
        List<Story__c> storiesList              = [SELECT Id, Name, Status__c , Sprint__c, Story_Name__c 
                                                    FROM Story__c 
                                                    WHERE Sprint__c =: selectedSprint AND Sprint__c != null];
        
        for(Story__c story : storiesList) {
            if(selectedStorySet.contains(story.Id))
                newStoryWrapperList.add(new StoryWrapper(true,story));
            else
                newStoryWrapperList.add(new StoryWrapper(false,story));
        }
        return newStoryWrapperList;
    }
    
    
    @AuraEnabled
    public Static void manageRelease(Id recId) {
        Release__c release  = [SELECT Id, Name, Project__c, Project__r.Name, Status__c, Source__c, Source__r.Status__c, Source__r.Created_On_Heroku__c, Target__c, 
                                Target__r.Status__c, Target__r.Created_On_Heroku__c, Actual_Release_Date__c,Target_Release_Date__c, Created_On_Heroku__c 
                                FROM Release__c 
                                WHERE Id =: recId];
        String target = '';
        if(release.Target__c != null && release.Target__r.Status__c == 'Active' && release.Target__r.Created_On_Heroku__c) 
            target = release.Target__c;
        if(release.Source__c != null && release.Source__r.Status__c == 'Active' && release.Source__r.Created_On_Heroku__c) {
            String requestJSONBody;
            String actualReleaseDate = release.Actual_Release_Date__c == null ? '' : release.Actual_Release_Date__c.format();
            String targetReleaseDate = release.Target_Release_Date__c == null ? '' : release.Target_Release_Date__c.format();
            HttpResponse res;
            if(release.Created_On_Heroku__c) {
                requestJSONBody = '"Release_Name":"'       + release.Name + '",' +
                                  '"Project":"'             + release.Project__c +'",'+
                                  '"Source_Connection":"'   + release.Source__c +'",'+
                                  '"Target_Connection":"'   + target +'",'+
                                  '"Actual_Release_Date":"' + actualReleaseDate +'",'+
                                  '"Target_Release_Date":"' + targetReleaseDate +'",'+
                                  '"Status":"'              + release.Status__c +'"';
                res = RestRequestHandlerForHeroku.sendRequest('PUT','Release_Update',requestJSONBody,release.Id,release.Project__c,release.Project__r.Name);
            }
            else {
                requestJSONBody = '"Release_Id":"'         + release.Id + '",' +
                                  '"Release_Name":"'        + release.Name +'",'+ 
                                  '"Project":"'             + release.Project__c +'",'+
                                  '"Source_Connection":"'   + release.Source__c +'",'+
                                  '"Target_Connection":"'   + target +'",'+
                                  '"Actual_Release_Date":"' + actualReleaseDate +'",'+
                                  '"Target_Release_Date":"' + targetReleaseDate +'",'+
                                  '"Status":"'              + release.Status__c  +'"';
                res = RestRequestHandlerForHeroku.sendRequest('POST','Release_Create',requestJSONBody,'',release.Project__c,release.Project__r.Name);
            }                 
            if(res != null && res.getStatusCode() == 200 ) {
                ResponseWrapper response = (ResponseWrapper) JSON.deserialize(res.getBody(), ResponseWrapper.class);
                if(!release.Created_On_Heroku__c && response.status == 'Success') {
                    release.Created_On_Heroku__c = true;
                    update release;
                    List<Connection__c> connectionlist = [SELECT Id, Allow_Deletion__c FROM Connection__c WHERE Id =: release.Source__c];
                    if(connectionlist.size() > 0) {
                        for(Connection__c connection :connectionlist) {
                            connection.Allow_Deletion__c = false;
                        }
                        update connectionlist;
                    }
                }
            } 
        }
    }

    @AuraEnabled
    public static String updateStoryReleaseArtifacts(Id recId, List<String> storyIdList) { 
        Release__c release = connectionRefreshStatus(recId);
        String requestJSONBody = '"Release_Stories" : ' + JSON.serialize(storyIdList);
        HttpResponse res = RestRequestHandlerForHeroku.sendRequest('POST','Release_UpdateStoryArtifactsOnRelease',requestJSONBody,release.Id,release.Project__c,release.Project__r.Name);
        return 'Success';
    }
    
    @AuraEnabled
    public static String createArtifacts(Id recId, String mapWrapperListJSON) { 
        Release__c release = connectionRefreshStatus(recId);
        List<Artifacts> metadataBundleWrapper       = (Artifacts[])JSON.deserialize(mapWrapperListJSON, list<Artifacts>.class);
        List<ArtifactWrapper> artifactWrapperList   = new List<ArtifactWrapper>();
        for(Artifacts metadataWrapper : metadataBundleWrapper)
            for(MetadataName nameWrapp : metadataWrapper.metadataName)
                artifactWrapperList.add(new ArtifactWrapper(nameWrapp.artifactId,nameWrapp.action));

        String requestJSONBody = '"Release_Artifacts":' + JSON.serialize(artifactWrapperList);
        HttpResponse res = RestRequestHandlerForHeroku.sendRequest('POST','Release_Artifact',requestJSONBody,release.Id,release.Project__c,release.Project__r.Name);
        if(res.getStatusCode() == 200 ) {
            ArtifactResponsetJSON response = (ArtifactResponsetJSON)JSON.deserialize(res.getBody(), ArtifactResponsetJSON.class);
            if(response.status == 'Success') {
                List<Connection__c> connectionlist = [SELECT Id, Allow_Deletion__c FROM Connection__c WHERE Id IN: response.connectionIdList];
                if(connectionlist.size() > 0) {
                    for(Connection__c connection :connectionlist) {
                        connection.Allow_Deletion__c = false;
                    }
                    update connectionlist;
                }
            }
        }
        return 'Success';
    }

    @AuraEnabled
    public static List<Artifacts> createReleaseStory(Id recId, String storyId, String action) { 
        Release__c release = connectionRefreshStatus(recId);
        String requestJSONBody = '"storyId":"' + storyId +'",'+ 
                                 '"action":"'  + action +'"';

        HttpResponse res = RestRequestHandlerForHeroku.sendRequest('POST','Release_Story',requestJSONBody,release.Id,release.Project__c,release.Project__r.Name);
        List<Artifacts> wrapperListSelected = new List<Artifacts>();
        if(res.getStatusCode() == 200 ) {
            MetadataResponse response = (MetadataResponse)JSON.deserialize(res.getBody(), MetadataResponse.class);
            if(response.status == 'Success' && action == 'create') {
                if(response.metadataList.size() > 0 && response.metadataList[0].metadataType != '')
                    wrapperListSelected = response.metadataList;
                List<Story__c> storyList = [SELECT Id, Name, Allow_Deletion__c, Created_On_Heroku__c FROM Story__c WHERE Id =: storyId];
                if(storyList != null && storyList.size() > 0) {
                    for(Story__c story : storyList) {
                        story.Created_On_Heroku__c  = true;
                        story.Allow_Deletion__c     = false;
                    }
                    update storyList;
                    for(Artifacts artifact :wrapperListSelected) {
                        for(MetadataName metadataName : artifact.metadataName) {
                            metadataName.storyName = storyList[0].name;
                        }
                    }
                }
            }
        }
        return wrapperListSelected;
    }
    
    // -----updates 05 Dec 2017 : AMIT JAYASWAL----------
    @AuraEnabled
    public static string refreshArtifacts(Id recId) {
        Release__c release  = connectionRefreshStatus(recId);
        return ManageArtifactsLightning.refreshArtifacts(release.Source__c);
    }

    @AuraEnabled
    public static Release__c connectionRefreshStatus(Id recId) {
        Release__c release  = [SELECT Id, Name, Project__c, Project__r.Name, Status__c, Source__c, Source__r.Refresh_Running__c, Target__c,
                                    Source__r.Metadata_Last_Described__c, Source__r.Status__c, Actual_Release_Date__c,Target_Release_Date__c, Created_On_Heroku__c
                               FROM Release__c  WHERE Id =: recId];
        return release;
    }
    
    // -----updates 05 Dec 2017 : AMIT JAYASWAL----------
    
    public Class ManageReleaseArtifactsMainWrapper {
        @AuraEnabled public Integer recCount                            {get;set;}
        @AuraEnabled public Release__c release                          {get;set;}
        @AuraEnabled public String selectedSprint                       {get;set;}
        @AuraEnabled public List<SelectOptionCustom> sprintList         {get;set;}
        @AuraEnabled public Set<String> selectedStory                   {get;set;}
        @AuraEnabled public List<StoryWrapper> storyWrapperList         {get;set;}
        @AuraEnabled public List<SelectOptionCustom> metadataOption     {get;set;}
        @AuraEnabled public List<Artifacts> wrapperListSelected         {get;set;}
        @AuraEnabled public List<Artifacts> wrapperList                 {get;set;}
        @AuraEnabled public List<StoryWrapper> storyWrapperListToUpdate {get;set;}

        public ManageReleaseArtifactsMainWrapper(Set<String> selectedStory,Integer recCount,Release__c release,List<SelectOptionCustom> sprintList,string selectedSprint,List<StoryWrapper> StoryWrapperList,List<SelectOptionCustom> metadataOption,List<Artifacts> wrapperListSelected,List<Artifacts> wrapperList,List<StoryWrapper> storyWrapperListToUpdate) {
            this.recCount                   = recCount;
            this.release                    = release;
            this.sprintList                 = sprintList;
            this.selectedSprint             = selectedSprint ;
            this.storyWrapperList           = storyWrapperList;
            this.metadataOption             = metadataOption;
            this.wrapperListSelected        = wrapperListSelected;
            this.wrapperList                = wrapperList;
            this.selectedStory              = selectedStory;
            this.storyWrapperListToUpdate   = storyWrapperListToUpdate;
        }
    }
    
     public Class SelectOptionCustom {
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}
        
        public SelectOptionCustom(String value,String label) {
            this.value = value;
            this.label = label;
        }
    }
    
    public class StoryWrapper {
        @AuraEnabled public Boolean selected {get;set;}
        @AuraEnabled public Story__c story   {get;set;}

        public StoryWrapper(Boolean selected, Story__c story) {
            this.selected   = selected;
            this.story      = story;
        }
    }
    
    public class MetadataResponse {
        @AuraEnabled public String Status;
        @AuraEnabled public List<Artifacts> metadataList;
    }

    public class ReleaseArtifactResponseJSON {
        @AuraEnabled public String Status;
        @AuraEnabled public List<ReleaseStories> ReleaseStories;
    }

    public class ReleaseStories {
        @AuraEnabled public String storyId;
        @AuraEnabled public List<Artifacts> artifacts;
    }

    public class Artifacts implements Comparable {
        @AuraEnabled public String metadataType             {get;Set;}
        @AuraEnabled public List<MetadataName> metadataName {get;set;} 

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
        @AuraEnabled public String name         {get;set;}
        @AuraEnabled public String action       {get;set;}
        @AuraEnabled public String artifactId   {get;set;}
        @AuraEnabled public String storyName    {get;set;}

        public Integer compareTo(Object compareTo) {
            MetadataName other = (MetadataName) compareTo;
            if (this.name > other.name)
              return 1;
            else if (this.name == other.name)
              return 0;
            return -1;
        }
    }

    public class ResponseWrapper {
        @AuraEnabled public String message;
        @AuraEnabled public List<String> storyList;
        @AuraEnabled public String status;
    }

    public class ArtifactWrapper {
        String artifact_Id;
        String action;
        public ArtifactWrapper(String artifact_Id, String action) {
            this.artifact_Id = artifact_Id;
            this.action = action;
        }
    }

    public class ArtifactResponsetJSON {
        @AuraEnabled public String message;  //Release Artifact updated successfully.
        @AuraEnabled public String status;   //Success
        @AuraEnabled public List<String> connectionIdList;   //[111aXXX, 222aYYY, 333aZZZ]
    }
}