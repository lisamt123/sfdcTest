public with sharing class ManageArtifactsController {

    public Story__c story                                               {get;set;}
    public String returnResopnse                                        {get;set;}
    public String selectedConnection                                    {get;set;}
    public boolean connectionExist                                      {get;set;}
    public boolean refreshRunning                                       {get;set;}
    public Connection__c primaryConnection                              {get;set;}
    public List<SelectOption> connectionOption                          {get;set;}
    public List<SelectOption> metadataOption                            {get;set;}
    
    @TestVisible private Heroku_oAuth_Setting__mdt credentials;
    @TestVisible private Map<String, String> herokuEndpointsMap;

    public ManageArtifactsController(ApexPages.StandardController stdController) {
    	
    	refreshRunning     = false;
    	primaryConnection  = new Connection__c();
        herokuEndpointsMap = new Map<String, String>();
    	Organization orgz  = [SELECT IsSandbox FROM Organization LIMIT 1];
		credentials        = [SELECT ID, QualifiedApiName, Callback_URL__c, Call_back_Url_Community__c, Consumer_Key__c, Consumer_Secret__c,
					           Heroku_URL__c  FROM Heroku_oAuth_Setting__mdt WHERE IsSandbox__c =: orgz.IsSandbox LIMIT 1];
		
		for(Heroku_Endpoint__mdt endpoint : [SELECT ID, QualifiedApiName, Endpoint__c FROM Heroku_Endpoint__mdt]){
			herokuEndpointsMap.put(endpoint.QualifiedApiName, endpoint.Endpoint__c);
		}
		
        for(Story__c story : [SELECT Id, Name, Project__c
                                FROM Story__c 
                                WHERE Id =: stdController.getRecord().Id]) {
            this.story = story;
        }
        connectionOption    = new List<SelectOption>();
        
        for(Project__c project : [SELECT Id,(SELECT Id, Name, Status__c, Primary_Development_Environment__c FROM Connections__r WHERE Status__c = 'Active' ORDER BY CreatedDate ASC) FROM Project__c WHERE Id =: story.Project__c ]) {
            if(project.Connections__r != null && project.Connections__r.size() > 0){
            	connectionExist = true;
            	for(Connection__c con : project.Connections__r) {
					connectionOption.add(new SelectOption(con.Id, con.Name));
					if(con.Primary_Development_Environment__c == true){
						selectedConnection = con.Id;
					}
	            }
				if(selectedConnection == null) {
					selectedConnection = project.Connections__r[0].Id;
				}
            }
            else{
            	connectionExist = false;
            	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No active connection found for the Project of this Story, please add an active connection.'));
            }
        }
        
        connectionRefreshStatus();
    }

    @remoteAction
    public static MetadataBundleWrapper getConnectionMetadata(Id recId,string selectedConnection,String recordsLimit,String searchText,String selectedMetadataType,String selectedMetadaListJson) {
    	
    	Organization orgz = [SELECT IsSandbox FROM Organization LIMIT 1];
        Heroku_oAuth_Setting__mdt credentials = [SELECT ID, QualifiedApiName, Heroku_URL__c  FROM Heroku_oAuth_Setting__mdt WHERE IsSandbox__c =: orgz.IsSandbox LIMIT 1];
                                        
        Map<String, String> herokuEndpointsMap  = new Map<String, String>();
        
        for(Heroku_Endpoint__mdt endpoint : [SELECT ID, QualifiedApiName, Endpoint__c FROM Heroku_Endpoint__mdt]){
            herokuEndpointsMap.put(endpoint.QualifiedApiName, endpoint.Endpoint__c);
        }
        
        selectedConnection = selectedConnection == '' ? null : selectedConnection;
        //--Retrieving existing story Artifacts.
        List<MetadataWrapper> wrapperListSelected = new List<MetadataWrapper>();
        if(selectedMetadaListJson != null && selectedMetadaListJson != '' && selectedMetadaListJson != '[]')
            wrapperListSelected = (List<MetadataWrapper>)JSON.deserialize(selectedMetadaListJson,List<MetadataWrapper>.class);
        else 
            wrapperListSelected = retrieveStoryArtifacts(recId, credentials, herokuEndpointsMap);

        Map<String,Set<String>> storyArtifactsMap = new Map<String,Set<String>>(); 

        for(MetadataWrapper wrapperObj : wrapperListSelected) {
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
        
        Manage_Artifacts_Setting__mdt defaultLimit = [SELECT ID, QualifiedApiName, Limit__c  FROM Manage_Artifacts_Setting__mdt LIMIT 1];
        
        String token = HerokuToken.headerToken();
        Integer recCount = Integer.valueOf(recordsLimit) + Integer.valueOf(defaultLimit.Limit__c);
        String requestJSONBody = '{"type":"'+ (selectedMetadataType == 'All' ? '' : selectedMetadataType) +'",'+ 
                                 '"name":"'+ (searchText == null ? '' : searchText) +'",'+
                                 '"limit":"'+ recCount  +'"}';
        
        Http h = new Http();
        //--Requesting heroku for artifacts.
        HttpRequest req = new HttpRequest();
        req.setEndpoint(credentials.Heroku_URL__c + herokuEndpointsMap.get('Connection_Metadata') + selectedConnection);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('token',token);
        req.setBody(requestJSONBody );
        req.setTimeOut(120000);
        HttpResponse res = h.send(req);
        
        //system.debug(res);
        //system.debug('Metadata======='+res.getBody());
        
        List<MetadataWrapper> wrapperList = new List<MetadataWrapper>(); 
        if(res.getStatusCode() == 200) {
            MetadataResponse response = (MetadataResponse) JSON.deserialize(EncodingUtil.urlDecode(res.getBody(), 'UTF-8'), MetadataResponse.class);
            System.debug('========'+response);
            if(response.Status == 'Success' && response.metadataList != null) {
                //--Getting artifacts list from response.
                wrapperList = response.metadataList;
            }
        }

        wrapperList.sort();
        List<SelectOptionCustom> metadataOption = new List<SelectOptionCustom>();
        If(selectedConnection != null && selectedConnection != '')
            metadataOption.add(new SelectOptionCustom('All','All'));
        for(Integer index = 0;index < wrapperList.size() ;index++) {

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
        system.debug('====================='+wrapperList.size());
        Connection__c selectedConnectionObj = new Connection__c();
        if(selectedConnection != null && selectedConnection.trim() != '') {
            selectedConnectionObj = [SELECT Id,Refresh_Running__c,Metadata_Last_Described__c FROM Connection__c WHERE Id =: selectedConnection ];
        }
        return new MetadataBundleWrapper(selectedConnectionObj,wrapperListSelected,wrapperList,metadataOption);
    }

	public void refreshArtifacts() {  
    
    	String token = HerokuToken.headerToken();
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(credentials.Heroku_URL__c + herokuEndpointsMap.get('Connection_Update') + selectedConnection);
        req.setMethod('PUT');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('token',token);
        String requestJSONBody =  '{"Access_Token":"",'+ 
                                  '"Action":"Refresh",'+
                                  '"Organization_Id":"",'+
                                  '"Organization_URL":"",'+
                                  '"project":"",'+
                                  '"Refresh_Token":"",'+
                                  '"Development_Environment_URL":"",'+
                                  '"Site_URL":""}';        
        req.setBody(requestJSONBody);
        req.setTimeOut(120000);
        HttpResponse res = h.send(req);
        //System.debug(res);
        //System.debug(res.getBody());
        returnResopnse = '';
        if(res.getStatusCode() == 200 ) {
            ConnectionResponseWrapper response = (ConnectionResponseWrapper) JSON.deserialize(EncodingUtil.urlDecode(res.getBody(), 'UTF-8'), ConnectionResponseWrapper.class);
            Connection__c connection  = [SELECT Id, Name, RecordTypeId, Created_On_Heroku__c,Refresh_Running__c, Metadata_Describe_Error__c,Organization_URL__c
                            FROM Connection__c 
                            WHERE Id =: selectedConnection];
            if(!connection.Created_On_Heroku__c && response.status == 'Success') {
                connection.Created_On_Heroku__c = true;
                connection.Refresh_Running__c = true;
                //refreshRunning = true;
            }
            if(response.status == 'Success') {
                connection.Metadata_Describe_Error__c = '';
                connection.Refresh_Running__c = true;
                returnResopnse = 'Success';
                //refreshRunning = true;
            }
            else {
                connection.Metadata_Describe_Error__c = response.message;
                connection.Refresh_Running__c = false;
                //refreshRunning = false;
                returnResopnse = response.message;
            }
            update connection;
        }
    }
    
    //---------------------------New 04 Oct 2017-----------------------------
    @remoteAction
    public static String createStoryArtifacts(Id recId,String mainMetadataWrapperStr) {
    	
    	Organization orgz = [SELECT IsSandbox FROM Organization LIMIT 1];
        Heroku_oAuth_Setting__mdt credentials = [SELECT ID, QualifiedApiName, Heroku_URL__c  FROM Heroku_oAuth_Setting__mdt WHERE IsSandbox__c =: orgz.IsSandbox LIMIT 1];
                                        
        Map<String, String> herokuEndpointsMap  = new Map<String, String>();
        
        for(Heroku_Endpoint__mdt endpoint : [SELECT ID, QualifiedApiName, Endpoint__c FROM Heroku_Endpoint__mdt]){
            herokuEndpointsMap.put(endpoint.QualifiedApiName, endpoint.Endpoint__c);
        }
        
        List<MetadataWrapper> metadataBundleWrapper = (MetadataWrapper[])JSON.deserialize(mainMetadataWrapperStr, list<MetadataWrapper>.class);

        List<ArtifactWrapper> artifactsIdList = new List<ArtifactWrapper>();
        for(MetadataWrapper metadataWrapper : metadataBundleWrapper) {
            for(MetadataName nameWrapp : metadataWrapper.metadataName) {
                artifactsIdList.add(new ArtifactWrapper(nameWrapp.artifactId,nameWrapp.action));
            }
        }

        Story__c story = [SELECT Id, Created_On_Heroku__c FROM Story__c WHERE Id =: recId];

		String Heroku_existence;
		if(story.Created_On_Heroku__c == true){
			Heroku_existence = 'true';
		}
		else{
			Heroku_existence = 'false'; 
		}
		
		String token = HerokuToken.headerToken();
		
		Http h = new Http();
		
		HttpRequest req = new HttpRequest();
		req.setEndpoint(credentials.Heroku_URL__c + herokuEndpointsMap.get('Story_Artifacts_Create') + recId);
		req.setMethod('POST');
		req.setHeader('Content-Type', 'application/json');
		req.setHeader('token',token); 
		
		String requestJSONBody = JSON.serialize(new ArtifactRequestJSON(Heroku_existence, artifactsIdList));
		
		req.setBody(requestJSONBody );
		req.setTimeOut(120000);
		
		HttpResponse res = h.send(req); 
		//System.debug(res);
		System.debug(res.getBody());
		
		if(res.getStatusCode() == 200) {
			ConnectionResponseWrapper response = (ConnectionResponseWrapper) JSON.deserialize(EncodingUtil.urlDecode(res.getBody(), 'UTF-8'), ConnectionResponseWrapper.class);
            if(response.status == 'Success' && story.Created_On_Heroku__c == false) {
				story.Created_On_Heroku__c = true;
                update story;
            }
            return 'Success';
		}
        return null;

    }
    
    public static List<MetadataWrapper> retrieveStoryArtifacts(Id recId, Heroku_oAuth_Setting__mdt credentials, Map<String, String> herokuEndpointsMap) {
    	String token = HerokuToken.headerToken();

		Http h = new Http();
		
		HttpRequest req = new HttpRequest();
		req.setEndpoint(credentials.Heroku_URL__c + herokuEndpointsMap.get('Story_Artifacts_Retrieve') + recId);
		req.setMethod('GET');
		req.setHeader('token',token); 
		req.setTimeOut(120000);
		
		HttpResponse res = h.send(req);
		//System.debug(res);
		System.debug(res.getBody());
		List<MetadataWrapper> wrapperList = new List<MetadataWrapper>(); 
        if(res.getStatusCode() == 200) {
            
            MetadataResponse response = (MetadataResponse) JSON.deserialize(EncodingUtil.urlDecode(res.getBody(), 'UTF-8'), MetadataResponse.class);
            if(response.Status == 'Success' && response.metadataList != null && response.metadataList.size() > 0 && response.metadataList[0].metadataType != ''){
                //--Getting artifacts list from response.
                wrapperList = response.metadataList;
            }
        }
        wrapperList.sort();
        return wrapperList;
    }
    //---------------------------New 04 Oct 2017-----------------------------

    public void connectionRefreshStatus() {
        if(selectedConnection != null && selectedConnection != '') { 
            Connection__c connection  = [SELECT Refresh_Running__c,Metadata_Last_Described__c 
                                        FROM Connection__c 
                                        WHERE Id =: selectedConnection];
            refreshRunning = connection.Refresh_Running__c;
            primaryConnection = connection;
        }
    }
    
    public class MetadataResponse {
        public String Status;
        public List<MetadataWrapper> metadataList;
    }
    
    public class MetadataWrapper implements Comparable {
        public List<MetadataName> metadataName  {get;set;} 
        public String metadataType              {get;Set;}

        public Integer compareTo(Object compareTo)
        {
            MetadataWrapper other = (MetadataWrapper) compareTo;
            if (this.metadataType > other.metadataType)
              return 1;
            else if (this.metadataType == other.metadataType)
              return 0;
            return -1;
        }
    }

    public class MetadataName implements Comparable{
        public String name          {get;set;}
        public String artifactId    {get;set;}
        public String action        {get;set;}

        public MetadataName(String name, String artifactId  , String action) {
            this.name       = name;
            this.artifactId = artifactId  ;
            this.action     = action;
        }

        public Integer compareTo(Object compareTo)
        {
            MetadataName other = (MetadataName) compareTo;
            if (this.name > other.name)
              return 1;
            else if (this.name == other.name)
              return 0;
            return -1;
        }
    }

    public class MetadataBundleWrapper {
        public List<MetadataWrapper> wrapperListSelected    {get;set;}
        public List<MetadataWrapper> wrapperList            {get;set;}
        public string selectedMetadataType                  {get;set;}
        public List<SelectOptionCustom> metadataOption      {get;set;}
        public Connection__c selectedConnection             {get;set;}
        
        public MetadataBundleWrapper (Connection__c selectedConnection,List<MetadataWrapper> wrapperListSelected,List<MetadataWrapper> wrapperList ,List<SelectOptionCustom> metadataOption) {
            this.wrapperListSelected    = wrapperListSelected;
            this.wrapperList            = wrapperList;
            this.metadataOption         = metadataOption;
            this.selectedConnection     = selectedConnection;
        }
    }

    public Class SelectOptionCustom {
        public String label{get;set;}
        public String value{get;set;}
        
        public SelectOptionCustom(String value,String label){
            this.value = value;
            this.label = label;
        }
    }
    
    public class ConnectionResponseWrapper { 
        public String message;
        public String status;
    }
    
    //---------------------------New 04 Oct 2017-----------------------------
    public class ArtifactRequestJSON {
	    public String Heroku_existence;
	    public List<ArtifactWrapper> Story_Artifacts;
		
	    public ArtifactRequestJSON(String Heroku_existence, List<ArtifactWrapper> Story_Artifacts){
	        this.Heroku_existence = Heroku_existence;
	        this.Story_Artifacts= Story_Artifacts;
	    }
	}

    class ArtifactWrapper {
        public String artifact_Id;
        public String action;

        public ArtifactWrapper(String artifact_Id, String action) {
            this.artifact_Id = artifact_Id;
            this.action = action;
        }
    }
    //---------------------------New 04 Oct 2017-----------------------------
    
}