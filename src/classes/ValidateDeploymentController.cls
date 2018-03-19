public with sharing class ValidateDeploymentController {
	public Release__c release 		{get;set;}
	public List<Log> logsList 		{get;set;}
	public String baseUrl			{get;set;}
	public boolean releaseExists    {get;set;}
	
	@TestVisible private Heroku_oAuth_Setting__mdt credentials;
    @TestVisible private Map<String, String> herokuEndpointsMap;
    @TestVisible private Manage_Artifacts_Setting__mdt defaultLimit;

	public ValidateDeploymentController(ApexPages.StandardController std) {
		
		Organization orgz = [SELECT IsSandbox FROM Organization LIMIT 1];
		credentials = [SELECT ID, QualifiedApiName, Callback_URL__c, Call_back_Url_Community__c, Consumer_Key__c, Consumer_Secret__c,
					  Heroku_URL__c  FROM Heroku_oAuth_Setting__mdt WHERE IsSandbox__c =: orgz.IsSandbox LIMIT 1];
		
		defaultLimit = [SELECT ID, QualifiedApiName, Limit__c  FROM Manage_Artifacts_Setting__mdt LIMIT 1];
										
		herokuEndpointsMap = new Map<String, String>();
		
		for(Heroku_Endpoint__mdt endpoint : [SELECT ID, QualifiedApiName, Endpoint__c FROM Heroku_Endpoint__mdt]){
			herokuEndpointsMap.put(endpoint.QualifiedApiName, endpoint.Endpoint__c);
		}
		
        release = [SELECT Id, Name, Project__c, Status__c, Source__c, Source__r.Status__c, Target__c, Actual_Release_Date__c,Target_Release_Date__c, 
        				Created_On_Heroku__c ,Target__r.Status__c,Validation_Running__c
        			FROM Release__c 
        			WHERE Id =: std.getRecord().Id];
        
        releaseExists = true;
        if(release.Created_On_Heroku__c == false) {
            releaseExists = false;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Release is not created on Heroku.'));
        }
        if(release.Source__c == null || release.Source__r.Status__c != 'Active') {
        	releaseExists = false;
        	ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'There is no active source connection for this release.'));
        }
        if(release.Target__c == null || release.Target__r.Status__c != 'Active') {
        	releaseExists = false;
        	ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'There is no active target connection for this release.'));
        }
        retriveDeploymentLogs();
        baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    }

	public void retriveDeploymentLogs(){
		
		String token = HerokuToken.headerToken();
		
		Http h = new Http();

		HttpRequest req = new HttpRequest();
		req.setEndpoint(credentials.Heroku_URL__c + herokuEndpointsMap.get('Deployment_Logs') + release.Id);
		req.setMethod('GET');
		req.setHeader('token',token);
		req.setHeader('Content-Type', 'application/json');
		req.setTimeOut(120000); 
		
		HttpResponse res = h.send(req);
		
		System.debug(res);
		System.debug(res.getBody());
		logsList = new List<Log>();
		if(res.getStatusCode() == 200 ) 
        {
            DeploymentLog dlog = (DeploymentLog) JSON.deserialize(EncodingUtil.urlDecode(res.getBody(), 'UTF-8'), DeploymentLog.class);
            //System.debug(dlog);
            
            if(dlog.Status == 'Success' && dlog.Log != null)
            {
            	logsList = dlog.Log;
            }
        }
	}
	
    public void validateDeployment() {
    	deploy(true);
    }

    public void deployMetadata() {
    	deploy(false);
    }

    public void deploy(Boolean checkOnly) {
    	String token = HerokuToken.headerToken();
    	
		Http h = new Http();

		HttpRequest req = new HttpRequest();
		req.setEndpoint(credentials.Heroku_URL__c + herokuEndpointsMap.get('Validate_Deployment') + release.Id);
		req.setMethod('POST');
		req.setHeader('Content-Type', 'application/json');
		req.setHeader('token',token);

		String requestJSONBody = '{"Source_Connection":"'+ release.Source__c +'",'+ 
		    					 '"Target_Connection":"'+ release.Target__c +'",'+
		    					 '"Check_Only":"' + checkOnly + '"}';

		req.setBody(requestJSONBody );
		req.setTimeOut(120000);

		HttpResponse res = h.send(req);

		//System.debug(res);
		//System.debug(res.getBody());
		
		if(res.getStatusCode() == 200 ) 
        {
            DeploymentLog dlog = (DeploymentLog) JSON.deserialize(EncodingUtil.urlDecode(res.getBody(), 'UTF-8'), DeploymentLog.class);
            //System.debug(dlog);
            
            if(dlog.Status == 'Success' )
            {
            	release.Validation_Running__c = true;
            }
        }
        update release; 
    }
    
    @remoteAction
    public static List<Log_Issue> retriveDeploymentLogIssues(String log_Id){

    	Organization orgz = [SELECT IsSandbox FROM Organization LIMIT 1];
		Heroku_oAuth_Setting__mdt credentials = [SELECT ID, QualifiedApiName, Callback_URL__c, Call_back_Url_Community__c, Consumer_Key__c, Consumer_Secret__c,
					  Heroku_URL__c  FROM Heroku_oAuth_Setting__mdt WHERE IsSandbox__c =: orgz.IsSandbox LIMIT 1];
		
		Map<String, String> herokuEndpointsMap = new Map<String, String>();
		
		for(Heroku_Endpoint__mdt endpoint : [SELECT ID, QualifiedApiName, Endpoint__c FROM Heroku_Endpoint__mdt]){
			herokuEndpointsMap.put(endpoint.QualifiedApiName, endpoint.Endpoint__c);
		}

		String token = HerokuToken.headerToken(); 
		
		Http h = new Http();
		
		HttpRequest req = new HttpRequest();
		req.setEndpoint(credentials.Heroku_URL__c + herokuEndpointsMap.get('Deployment_Issues') + log_Id);
		req.setMethod('GET');
		req.setHeader('token',token);
		req.setTimeOut(120000); 
		
		HttpResponse res = h.send(req);
		System.debug(res);
		System.debug(res.getBody()); 

		List<Log_Issue> logIssueList = new List<Log_Issue>();
		if(res.getStatusCode() == 200 ) 
        {
            DeploymentIssue dlogIssue = (DeploymentIssue) JSON.deserialize(EncodingUtil.urlDecode(res.getBody(), 'UTF-8'), DeploymentIssue.class);
            //System.debug(dlogIssue);
            
            if(dlogIssue.Status == 'Success' && dlogIssue.LogIssue != null)
            {
            	logIssueList = dlogIssue.LogIssue; 
            }
        }
        return logIssueList; 
	}
	
	public void releaseValidationStatus() {
        release = [SELECT Id, Name, Project__c, Status__c, Source__c, Source__r.Status__c, Target__c, Actual_Release_Date__c,Target_Release_Date__c, 
        			Created_On_Heroku__c ,Target__r.Status__c,Validation_Running__c
        			FROM Release__c 
        			WHERE Id =: release.Id];
    }
	
    public class DeploymentLog {
		public String Status {get;set;} 
		public List<Log> Log {get;set;} 
	}
	public class Log {
		//public List<Log_Issue> log_Issue {get;set;} 
		public String logId 	{get;set;} 
		public String status 	{get;set;} 
		public String logTime 	{get;set;}
		public String action 	{get;set;} 
	}
	
	public class DeploymentIssue {
		public String Status 			{get;set;} 
		public List<Log_Issue> LogIssue {get;set;} 
	}
	public class Log_Issue {
		public String description 	{get;set;} 
		public String type 			{get;set;} 
	}
}