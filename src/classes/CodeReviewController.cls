public with sharing class CodeReviewController {
    public Release__c release       {get;set;}
    public List<Log> logsList       {get;set;}
    public String baseUrl           {get;set;}
    public boolean releaseExists    {get;set;}
    
    @TestVisible private Heroku_oAuth_Setting__mdt credentials;
    @TestVisible private Map<String, String> herokuEndpointsMap;
    @TestVisible private Manage_Artifacts_Setting__mdt defaultLimit;

    public CodeReviewController(ApexPages.StandardController std) {
        
        Organization orgz = [SELECT IsSandbox FROM Organization LIMIT 1];
        credentials = [SELECT ID, QualifiedApiName, Callback_URL__c, Call_back_Url_Community__c, Consumer_Key__c, Consumer_Secret__c,
                      Heroku_URL__c  FROM Heroku_oAuth_Setting__mdt WHERE IsSandbox__c =: orgz.IsSandbox LIMIT 1];
                      
        defaultLimit = [SELECT ID, QualifiedApiName, Limit__c  FROM Manage_Artifacts_Setting__mdt LIMIT 1];
                                        
        herokuEndpointsMap = new Map<String, String>();
        
        for(Heroku_Endpoint__mdt endpoint : [SELECT ID, QualifiedApiName, Endpoint__c FROM Heroku_Endpoint__mdt]){
            herokuEndpointsMap.put(endpoint.QualifiedApiName, endpoint.Endpoint__c);
        }
        
        release = [SELECT Id, Name, Project__c, Status__c, Source__c, Source__r.Status__c, Target__c, Actual_Release_Date__c,Target_Release_Date__c, 
                        Created_On_Heroku__c ,Target__r.Status__c, Scan_Running__c
                    FROM Release__c 
                    WHERE Id =: std.getRecord().Id];
        //logsList = new List<Log>();
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
        
        retriveReviewLogs();
        
        baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    }

    public void retriveReviewLogs(){
        
        String token = HerokuToken.headerToken();
        
        Http h = new Http();

        HttpRequest req = new HttpRequest();
        req.setEndpoint(credentials.Heroku_URL__c + herokuEndpointsMap.get('Release_ReviewLogs') + release.Id);
        req.setMethod('GET');
        req.setHeader('token',token);
        req.setHeader('Content-Type', 'application/json');
        req.setTimeOut(120000);
        
        HttpResponse res = h.send(req); 

        //System.debug(res);
        //System.debug(res.getBody()); 
        logsList = new List<Log>();
        
        if(res.getStatusCode() == 200 ) 
        {
            ReviewLog dlog = (ReviewLog) JSON.deserialize(EncodingUtil.urlDecode(res.getBody(), 'UTF-8'), ReviewLog.class);
            System.debug(dlog);
            
            if(dlog.Status == 'Success' && dlog.Log != null && dlog.Log.size() > 0)
            {
                logsList = dlog.Log;
            }
        }
    }

    public void scanCode() {
        String token = HerokuToken.headerToken();
        
        Http h = new Http();
    
        HttpRequest req = new HttpRequest();
        req.setEndpoint(credentials.Heroku_URL__c + herokuEndpointsMap.get('Release_CodeReview') + release.Id);
        req.setMethod('GET');
        req.setHeader('token',token);
        req.setTimeOut(120000);
    
        HttpResponse res = h.send(req);
    
        //System.debug(res);
        //System.debug(res.getBody());
        
        if(res.getStatusCode() == 200 ) 
        {
            ReviewLog dlog = (ReviewLog) JSON.deserialize(EncodingUtil.urlDecode(res.getBody(), 'UTF-8'), ReviewLog.class);
            //System.debug(dlog);
            
            if(dlog.Status == 'Success' )
            {
                release.Scan_Running__c = true;
            }
        }
        update release;
    }
    
    @remoteAction
    public static List<Log_Issue> scanCodeResult(String scan_Id)
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
        req.setEndpoint(credentials.Heroku_URL__c + herokuEndpointsMap.get('Release_ScanResult') + scan_Id);
        req.setMethod('GET');
        req.setHeader('token',token);
        req.setTimeOut(120000);
        
        HttpResponse res = h.send(req);
        //System.debug(res);
        System.debug(res.getBody());
        
        List<Log_Issue> logIssueList = new List<Log_Issue>();
        if(res.getStatusCode() == 200 ) 
        {
            ReviewIssue scanLogIssue = (ReviewIssue) JSON.deserialize(EncodingUtil.urlDecode(res.getBody(), 'UTF-8'), ReviewIssue.class);
            //System.debug(scanLogIssue);
            
            if(scanLogIssue.Status == 'Success' && scanLogIssue.LogIssue != null && scanLogIssue.LogIssue.size() > 0)
            {
                logIssueList = scanLogIssue.LogIssue; 
            }
        }
        return logIssueList;
    }
   
    public void releaseScanStatus() {           
        release = [SELECT Id, Name, Project__c, Status__c, Source__c, Source__r.Status__c, Target__c, Actual_Release_Date__c,Target_Release_Date__c, 
                    Created_On_Heroku__c ,Target__r.Status__c, Scan_Running__c
                    FROM Release__c 
                    WHERE Id =: release.Id];
    }
    
    public class ReviewLog {
        public String Status {get;set;} 
        public List<Log> Log {get;set;} 
    }
    public class Log {
        //public List<Log_Issue> log_Issue {get;set;} 
        public String logId     {get;set;} 
        public String status    {get;set;} 
        public String logTime   {get;set;} 
    }
    
    public class ReviewIssue {
        public String Status            {get;set;} 
        public List<Log_Issue> LogIssue {get;set;} 
    }
    public class Log_Issue {
        public String artifactType  {get;set;}
        public String artifactName  {get;set;}
        public String lineNo        {get;set;}
        public String violation     {get;set;}  
    }
}