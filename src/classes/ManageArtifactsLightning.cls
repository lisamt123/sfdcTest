public without sharing class ManageArtifactsLightning {
    
    @AuraEnabled
    public static MetadataLightningWrapper getMetadataFunctionality(Id recId,string selectedConnection,String recordsLimit,String searchText,String selectedMetadataType,String selectedMetadaListJson ) {
        selectedConnection              = selectedConnection == '' ? null : selectedConnection;
        Boolean alreagyHasConnection    = false;
        if(selectedConnection != null && selectedConnection.trim() != '')
            alreagyHasConnection = true;
        List<MetadataWrapper> wrapperListSelected = new List<MetadataWrapper>();
        if(selectedMetadaListJson != null && selectedMetadaListJson != '' && selectedMetadaListJson != '[]')
            wrapperListSelected = (List<MetadataWrapper>)JSON.deserialize(selectedMetadaListJson,List<MetadataWrapper>.class);
        else 
            wrapperListSelected = retrieveStoryArtifacts(recId);

        //--Retrieving existing story Artifacts.
        Map<String,Set<String>> storyArtifactsMap = new Map<String,Set<String>>(); 

        for(MetadataWrapper wrapperObj : wrapperListSelected) {
            if(wrapperObj.metadataType != null && wrapperObj.metadataType != '') {
                if(!storyArtifactsMap.containsKey(wrapperObj.metadataType))
                    storyArtifactsMap.put(wrapperObj.metadataType,new Set<String>());
                Set<String> artifactsSet = new Set<String>();
                if(wrapperObj.metadataName != null) {
                    for(MetadataName nameWrap : wrapperObj.metadataName)
                        artifactsSet.add(wrapperObj.metadataType + '##' +nameWrap.name);
                    storyArtifactsMap.get(wrapperObj.metadataType).addAll(artifactsSet);
                }
            }
        }

        Story__c story = new Story__c(); 
        List<SelectOptionCustom> connectionOption = new List<SelectOptionCustom>();
        List<SelectOptionCustom> metadataOption = new List<SelectOptionCustom>();
        
        //string selectedConnection ;
        
        for(Story__c tempStory : [SELECT Id, Name, Project__c  FROM Story__c  WHERE Id =: recId])
            story = tempStory ;
        if(!alreagyHasConnection) {
            for(Project__c project : [SELECT Id,(SELECT Id, Name, Status__c, Primary_Development_Environment__c FROM Connections__r WHERE Status__c = 'Active' ORDER BY CreatedDate ASC) FROM Project__c WHERE Id =: story.Project__c ]) {
                if(project.Connections__r != null && project.Connections__r.size() > 0) {
                    for(Connection__c con : project.Connections__r) {
                        connectionOption.add(new SelectOptionCustom(con.Id, con.Name));
                        if(con.Primary_Development_Environment__c == true)
                            selectedConnection = con.Id;
                    }
                    if(selectedConnection == null)
                        selectedConnection = project.Connections__r[0].Id;
                }
            } 
        } 

        Connection__c isRefresh = new Connection__c();
        if(selectedConnection != null && selectedConnection.trim() != '')
            isRefresh = [SELECT Id, Refresh_Running__c, Metadata_Last_Described__c, Project__c, Project__r.Name  
                        FROM Connection__c 
                        WHERE Id =: selectedConnection ];
        
        Manage_Artifacts_Setting__mdt defaultLimit  = [SELECT ID, QualifiedApiName, Limit__c  FROM Manage_Artifacts_Setting__mdt LIMIT 1];
        Integer recCount                            = Integer.valueOf(recordsLimit) + Integer.valueOf(defaultLimit.Limit__c);
        String requestJSONBody  = '"type":"'  + (selectedMetadataType == 'All' ? '' : selectedMetadataType) +'",'+ 
                                  '"name":"'  + (searchText == null ? '' : searchText) +'",'+
                                  '"limit":"' + recCount +'"';
        HttpResponse res = RestRequestHandlerForHeroku.sendRequest('POST','Connection_Metadata',requestJSONBody,selectedConnection,isRefresh.Project__c,isRefresh.Project__r.Name);
        
        List<MetadataWrapper> wrapperList = new List<MetadataWrapper>(); 
        if(res.getStatusCode() == 200) {
            
            MetadataResponse response = (MetadataResponse) JSON.deserialize(res.getBody(), MetadataResponse.class);
            if(response.Status == 'Success' && response.metadataList != null)
                wrapperList = response.metadataList;
        }
        wrapperList.sort();
        If(selectedConnection != null && selectedConnection != '')
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
        return new MetadataLightningWrapper(isRefresh,recCount,story,connectionOption,metadataOption,selectedConnection, wrapperListSelected,wrapperList);
    }
    
    //---------------------------New 04 Oct 2017-----------------------------
    @AuraEnabled
    public static void createStoryArtifacts(Id recId,String mainMetadataWrapperStr) {
        List<MetadataWrapper> metadataBundleWrapper = (MetadataWrapper[])JSON.deserialize(mainMetadataWrapperStr, list<MetadataWrapper>.class);

        List<ArtifactWrapper> artifactsIdList = new List<ArtifactWrapper>();
        for(MetadataWrapper metadataWrapper : metadataBundleWrapper)
            for(MetadataName nameWrapp : metadataWrapper.metadataName)
                artifactsIdList.add(new ArtifactWrapper(nameWrapp.artifactId,nameWrapp.action));

        Story__c story = [SELECT Id, Project__c, Project__r.Name, Created_On_Heroku__c FROM Story__c WHERE Id =: recId];
        String Heroku_existence;
        if(story.Created_On_Heroku__c == true)
            Heroku_existence = 'true';
        else
            Heroku_existence = 'false'; 
        
        String requestJSONBody  = '"Heroku_existence":"' + Heroku_existence +'",'+ 
                                  '"Story_Artifacts":'   + JSON.serialize(artifactsIdList);
        
        HttpResponse res = RestRequestHandlerForHeroku.sendRequest('POST','Story_Artifacts_Create',requestJSONBody,recId,story.Project__c,story.Project__r.Name);
        if(res.getStatusCode() == 200) {
            ArtifactResponsetJSON response = (ArtifactResponsetJSON) JSON.deserialize(res.getBody(), ArtifactResponsetJSON.class);
            if(response.status == 'Success' ) {
                if(story.Created_On_Heroku__c == false) {
                    story.Created_On_Heroku__c = true;
                    update story;
                }
                List<Connection__c> connectionlist = [SELECT Id, Allow_Deletion__c FROM Connection__c WHERE Id IN: response.connectionIdList];
                if(connectionlist.size() > 0) {
                    for(Connection__c connection :connectionlist) {
                        connection.Allow_Deletion__c = false;
                    }
                    update connectionlist;
                }
            }
        }
    }
    
    public static List<MetadataWrapper> retrieveStoryArtifacts(Id recId) {
        Story__c story = [SELECT Id, Project__c, Project__r.Name, Created_On_Heroku__c FROM Story__c WHERE Id =: recId];
        HttpResponse res = RestRequestHandlerForHeroku.sendRequest('POST','Story_Artifacts_Retrieve','',recId,story.Project__c,story.Project__r.Name);
        List<MetadataWrapper> wrapperList = new List<MetadataWrapper>(); 
        if(res.getStatusCode() == 200) {
            MetadataResponse response = (MetadataResponse) JSON.deserialize(res.getBody(), MetadataResponse.class);
            //--Getting artifacts list from response.
            if(response.Status == 'Success' && response.metadataList != null && response.metadataList.size() > 0 && response.metadataList[0].metadataType != '')
                wrapperList = response.metadataList;
        }
        wrapperList.sort();
        return wrapperList;
    }
    //---------------------------New 04 Oct 2017-----------------------------

    @AuraEnabled
    public static Connection__c connectionRefreshStatus(String currentConnection) {
        Connection__c conn = [SELECT Id, Name, Project__c, Project__r.Name, Refresh_Running__c, Metadata_Last_Described__c 
                                FROM Connection__c 
                                WHERE Id =: currentConnection];
        return conn;
    }
    
    @AuraEnabled
    public static string refreshArtifacts(String selectedConnection) {
        Connection__c connection  = [SELECT Id, Name, RecordTypeId, Refresh_Running__c, Created_On_Heroku__c, 
                                        Metadata_Describe_Error__c, Organization_URL__c, Project__c, Project__r.Name 
                                    FROM Connection__c 
                                    WHERE Id =: selectedConnection];
        String connectionType;
        if(connection.RecordTypeId != Constants.RECORDTYPEID_CONNECTION_GITHUB) 
            connectionType = 'Salesforce';
        else 
            connectionType = 'Github';
        String requestJSONBody =  '"Action":"Refresh",'+
                                  '"Connection_Type":"' + connectionType + '"';
        HttpResponse res = RestRequestHandlerForHeroku.sendRequest('PUT','Connection_Update',requestJSONBody,selectedConnection,connection.Project__c,connection.Project__r.Name);
        String returnResopnse;
        if(res.getStatusCode() == 200 ) {
            ConnectionResponseWrapper response = (ConnectionResponseWrapper) JSON.deserialize(res.getBody(), ConnectionResponseWrapper.class);
            if(response.status == 'Success') {
                connection.Refresh_Running__c = true;
                connection.Metadata_Describe_Error__c = '';
                returnResopnse = 'Success';
            }
            else {
                connection.Metadata_Describe_Error__c = response.message;
                connection.Refresh_Running__c = false;
                returnResopnse = response.message;
            }
            update connection;
        }
        return returnResopnse ;
    }
    
    public Class MetadataLightningWrapper {
        @AuraEnabled public Story__c story                              {get;set;}
        @AuraEnabled public Connection__c isRefresh                     {get;set;}
        @AuraEnabled public Integer recCount                            {get;set;}
        @AuraEnabled public List<SelectOptionCustom> connectionOption   {get;set;}
        @AuraEnabled public List<SelectOptionCustom> metadataOption     {get;set;}
        @AuraEnabled public string selectedConnection                   {get;set;}
        @AuraEnabled public List<MetadataWrapper> wrapperListSelected   {get;set;}
        @AuraEnabled public List<MetadataWrapper> wrapperList           {get;set;}
        
        public MetadataLightningWrapper (Connection__c isRefresh,Integer recCount,Story__c story,List<SelectOptionCustom> connectionOption,List<SelectOptionCustom> metadataOption,string selectedConnection,List<MetadataWrapper> wrapperListSelected,List<MetadataWrapper> wrapperList ) {
            this.story                  = story;
            this.recCount               = recCount;
            this.connectionOption       = connectionOption;
            this.metadataOption         = metadataOption;
            this.selectedConnection     = selectedConnection;
            this.wrapperListSelected    = wrapperListSelected;
            this.wrapperList            = wrapperList;
            this.isRefresh              = isRefresh;
        }
    }

    public class SelectOptionCustom {
        @AuraEnabled public String label{get;set;}
        @AuraEnabled public String value{get;set;}
        
        public SelectOptionCustom(String value,String label){
            this.value = value;
            this.label = label;
        }
    }
    
    public class MetadataWrapper implements Comparable {
        @AuraEnabled public List<MetadataName> metadataName   {get;set;}
        @AuraEnabled public String metadataType               {get;set;}

        public Integer compareTo(Object compareTo) {
            MetadataWrapper other = (MetadataWrapper) compareTo;
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

        public MetadataName(String name,String action,String artifactId) {
            this.name       = name;
            this.action     = action;
            this.artifactId = artifactId;

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
    
    public class MetadataResponse {
        @AuraEnabled public String Status;
        @AuraEnabled public List<MetadataWrapper> metadataList;
    }
    
    public class ConnectionResponseWrapper {
        @AuraEnabled public String message;
        @AuraEnabled public String status;
    }

    //---------------------------New 04 Oct 2017-----------------------------
    class ArtifactWrapper {
        @AuraEnabled public String artifact_Id;
        @AuraEnabled public String action;

        public ArtifactWrapper(String artifact_Id, String action) {
            this.artifact_Id = artifact_Id;
            this.action = action;
        }
    }
    
    public class ArtifactResponsetJSON {
        @AuraEnabled public String message;  //Story Artifact updated successfully.
        @AuraEnabled public String status;   //Success
        @AuraEnabled public List<String> connectionIdList;   //[111aXXX, 222aYYY, 333aZZZ]
    }
}