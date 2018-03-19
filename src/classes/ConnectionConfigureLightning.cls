public with sharing class ConnectionConfigureLightning {

	@AuraEnabled
    public static ResponseResultWrapper retrieveConnectionData(String recId) { 
    	ResponseResultWrapper responseWrapperResult = new ResponseResultWrapper();
    	Connection__c selectedConnection = [SELECT Id, Project__c, Project__r.Name FROM Connection__c WHERE Id =: recId];

        HttpResponse res = RestRequestHandlerForHeroku.sendRequest('POST','Connection_AccessToken','',recId,selectedConnection.Project__c,selectedConnection.Project__r.Name);

        if(res.getStatusCode() == 200) {
            ResponseWrapper result = (ResponseWrapper) JSON.deserialize(res.getBody(), ResponseWrapper.class);
            if(result != null && result.accessToken != null && result.accessToken != '') {
            	responseWrapperResult.accessToken = result.accessToken;
            	Map<String, String> herokuEndpointsMap  = new Map<String, String>();
		        for(Heroku_Endpoint__mdt endpoint : [SELECT ID, QualifiedApiName, Endpoint__c FROM Heroku_Endpoint__mdt])
		            herokuEndpointsMap.put(endpoint.QualifiedApiName, endpoint.Endpoint__c);

	            HttpResponse response = sendRequest(herokuEndpointsMap.get('Github_Repo_Endpoint'),result.accessToken);
	            System.debug(response);
	            System.debug(response.getBody());
	            if(response.getStatusCode() == 200) {
	                List<RepoResponseWrapper> repoResponseWrapper = (List<RepoResponseWrapper>)JSON.deserialize(response.getBody(), List<RepoResponseWrapper>.class);
	                System.debug('responseWrapper - '+repoResponseWrapper);
	                responseWrapperResult.repoResponseWrapper = repoResponseWrapper;
	            }
	            else {
	                System.debug('Issue while getting response - '+response.getStatusCode());
	            }
	        }
	        else {
	            System.debug('No Access Token');
	        }
        }
        return responseWrapperResult;

     	/**/
    }

    @AuraEnabled
    public static ResponseResultWrapper retrieveConnectionMetaDataInfo(String selectedRepo,String access_token) {
    	ResponseResultWrapper responseWrapper = new ResponseResultWrapper();
    	String message;
    	 if(access_token != null && selectedRepo != null) {
            String endpoint = selectedRepo + '/contents/src/package.xml';
            HttpResponse response = sendRequest(endpoint,access_token);
            System.debug(response.getBody());
            if(response.getStatusCode() == 200) {
                message = 'SUCCESS';
            }
            else
                message = 'Not';
        }else
            message = 'Not';
        responseWrapper.message = message;
        return responseWrapper;
    }

    @AuraEnabled
    public static String updateGitConnection(String selectedRepo,String recId, String access_token) {
    	Connection__c selectedConnection = [SELECT Id, Project__c, Project__r.Name, Created_On_Heroku__c, Refresh_Running__c, Metadata_Describe_Error__c
    	 									FROM Connection__c WHERE Id =: recId];
    	HttpResponse res;
    	String requestJSONBody =  '"Organization_Id":"",'+
                                  '"Connection_Type":"Github",'+
                                  '"project":"'                     + selectedConnection.Project__c + '",'+
                                  '"repo":"'						+ selectedRepo +'",'+
                                  '"Development_Environment_URL":"' + System.URL.getSalesforceBaseUrl().toExternalForm() +'",'+
                                  '"Site_URL":"'                    + Label.Site_URL + '",'+
                                  '"Access_Token":"'                + access_token + '",'+ 
                                  '"Organization_URL":"",'+
                                  '"Refresh_Token":""';
        if(selectedConnection.Created_On_Heroku__c) {
            requestJSONBody +=',"Action":"Update"';
            res = RestRequestHandlerForHeroku.sendRequest('PUT','Connection_Update',requestJSONBody,selectedConnection.Id,selectedConnection.Project__c,selectedConnection.Project__r.Name);
        }
        else {
            requestJSONBody += ',"Connection_Id":"'+ selectedConnection.Id + '"';
            res = RestRequestHandlerForHeroku.sendRequest('POST','Connection_Create',requestJSONBody,'',selectedConnection.Project__c,selectedConnection.Project__r.Name);
        }
       	if(res != null && res.getStatusCode() == 200 ) {
       		selectedConnection.Refresh_Running__c           = true;
            selectedConnection.Metadata_Describe_Error__c   = '';
            selectedConnection.Git_Repo__c 					= selectedRepo;
            update selectedConnection;
       	}
       	return 'success';
    }

    public static HttpResponse sendRequest(String epoint,String access_token) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(epoint);
        request.setHeader('Authorization', 'token ' + access_token);
        request.setHeader('Accept', 'application/vnd.github.machine-man-preview+json');
        request.setMethod('GET');
        request.setTimeOut(120000);
        Http http = new Http();
        HttpResponse response = http.send(request);
        return response ;
    }

    public class ResponseResultWrapper {
    	@AuraEnabled public String accessToken 								{get;set;}
    	@AuraEnabled public String message									{get;set;}	
    	@AuraEnabled public List<RepoResponseWrapper> repoResponseWrapper 	{get;set;}
    }

    public class RepoResponseWrapper {
        @AuraEnabled public String name 		{get;set;}
        @AuraEnabled public String full_name 	{get;set;}
        @AuraEnabled public String url 			{get;set;}
        @AuraEnabled public String contents_url {get;set;}
    }

    public class ResponseWrapper {
     	public String status;
     	public String accessToken;
     	public String message;
    }
}