public with sharing class ProjectCodeScanResultController {
	
    public Project__c project	{get;set;}
    public List<Release_Log> logsList 	{get;set;}
	public String baseUrl		{get;set;}
	
	@TestVisible private Heroku_oAuth_Setting__mdt credentials;
    @TestVisible private Map<String, String> herokuEndpointsMap;
	 		
	public ProjectCodeScanResultController(ApexPages.StandardController std) {
	 	
	 	Organization orgz = [SELECT IsSandbox FROM Organization LIMIT 1];
		credentials = [SELECT ID, QualifiedApiName, Callback_URL__c, Call_back_Url_Community__c, Consumer_Key__c, Consumer_Secret__c,
					  Heroku_URL__c  FROM Heroku_oAuth_Setting__mdt WHERE IsSandbox__c =: orgz.IsSandbox LIMIT 1];
										
		herokuEndpointsMap = new Map<String, String>();
		
		for(Heroku_Endpoint__mdt endpoint : [SELECT ID, QualifiedApiName, Endpoint__c FROM Heroku_Endpoint__mdt]){
			herokuEndpointsMap.put(endpoint.QualifiedApiName, endpoint.Endpoint__c);
		}
		
	 	project = [Select Id, Name , (SELECT Id, Created_On_Heroku__c FROM Releases__r) FROM Project__c WHERE Id =: std.getRecord().Id];
	 	logsList = new List<Release_Log>();
	 	Boolean releaseOnHeroku = false;
    	
 		if(project.Releases__r.size() > 0){ 
	 		for(Release__c release : project.Releases__r){
	 			if(release.Created_On_Heroku__c == true){
	 				releaseOnHeroku = true;
	 			}
	 		} 
	 		if(releaseOnHeroku == true){
	 			retrieveProjectRelease();
	 		}
	 		else{
	 			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'No any release created on heroku for this project, please insert at least one release on heroku for this project.'));
	 		}
	 	}
	 	else{
	 		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'No release found for this project, please create at least one release for this project.'));
	 	}
	 	
	 	baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
	}
    
    public void retrieveProjectRelease(){
    	String token = HerokuToken.headerToken();
    	
    	Http h = new Http();

		HttpRequest req = new HttpRequest();
		req.setEndpoint(credentials.Heroku_URL__c + herokuEndpointsMap.get('Project_ReviewLogs') + project.Id);
		req.setMethod('GET');
		req.setHeader('token',token);
		req.setTimeOut(120000);
		
	
		HttpResponse res = h.send(req);
	
		System.debug(res);
		System.debug(res.getBody());
		
		if(res.getStatusCode() == 200 ) 
        {
            ReleaseWrapper dlog = (ReleaseWrapper) JSON.deserialize(EncodingUtil.urlDecode(res.getBody(), 'UTF-8'), ReleaseWrapper.class);
            //System.debug(dlog);
            
            if(dlog.Status == 'Success' && dlog.ReleaseLog != null)
            {
            	logsList = dlog.ReleaseLog;
            }
        }
    }
    
    @remoteAction
    public static List<Log> retriveReleaseReviewLogs(String releaseId){

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
		req.setEndpoint(credentials.Heroku_URL__c + herokuEndpointsMap.get('Release_ReviewLogs') + releaseId);
		req.setMethod('GET');
		req.setHeader('token',token);
		req.setHeader('Content-Type', 'application/json');  
		req.setTimeOut(120000);
		
		HttpResponse res = h.send(req); 

		//System.debug(res);
		//System.debug(res.getBody()); 
		
		List<Log> logList = new List<Log>();
		if(res.getStatusCode() == 200 ) 
        {
            ReviewLog dlog = (ReviewLog) JSON.deserialize(EncodingUtil.urlDecode(res.getBody(), 'UTF-8'), ReviewLog.class);
            //System.debug(dlog);
            
            if(dlog.Status == 'Success' && dlog.Log != null)
            {
            	logList = dlog.Log;
            }
        }
        return logList;
	}
	
	@remoteAction
    public static List<Log_Issue> retriveScanCodeResult(String scan_Id)
    {
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
		req.setEndpoint(credentials.Heroku_URL__c + herokuEndpointsMap.get('Release_ScanResult'));
		req.setMethod('POST');
		req.setHeader('token',token);
		req.setHeader('Content-Type', 'application/json');
		String requestJSONBody =   '{"scan_Id":"'+ scan_Id +'"}';
		req.setBody(requestJSONBody );
		req.setTimeOut(120000);
		
		HttpResponse res = h.send(req);
		//System.debug(res);
		//System.debug(res.getBody());
		
		List<Log_Issue> logIssueList = new List<Log_Issue>();
		if(res.getStatusCode() == 200 ) 
        {
            ReviewIssue scanLogIssue = (ReviewIssue) JSON.deserialize(EncodingUtil.urlDecode(res.getBody(), 'UTF-8'), ReviewIssue.class);
            //System.debug(scanLogIssue);
            
            if(scanLogIssue.Status == 'Success' && scanLogIssue.LogIssue != null)
            {
            	logIssueList = scanLogIssue.LogIssue; 
            }
        }
    	return logIssueList;
    }
	
    public class ReleaseWrapper{
		public String Status {get;set;} 
		public List<Release_Log> ReleaseLog {get;set;} 
	}
	public class Release_Log {
		public String releaseId {get;set;}  
		public String releaseName {get;set;} 
	}
	
	public class ReviewLog {
		public String Status {get;set;} 
		public List<Log> Log {get;set;} 
	}
	public class Log {  
		
		public String logClass { get;set;}
		public String logId {get;set {
				logId = value;
				logClass = logId.replace(' ','').replace('-','').replace(':','').replace('.','');
			} 
		} 
		public String status {get;set;} 
		public String logTime {get;set;} 

		
	}
	
	public class ReviewIssue {
		public String Status {get;set;} 
		public List<Log_Issue> LogIssue {get;set;} 
	}
	public class Log_Issue {
		public String description {get;set;} 
		public String type {get;set;} 
	}
}