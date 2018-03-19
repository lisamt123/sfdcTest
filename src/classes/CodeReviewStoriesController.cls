// Code Review COntroller for Story

public with sharing class CodeReviewStoriesController {
    public Story__c story                   {get;set;}
    public List<Log> logsList               {get;set;}
    public String baseUrl                   {get;set;}
    public boolean connectionExist          {get;set;}
    public boolean herokuExist              {get;set;}
    
    public CodeReviewStoriesController(ApexPages.StandardController std) {
    	logsList = new List<Log>();
        story   = [SELECT Id, Name, Scan_Running__c, Created_On_Heroku__c,Project__c 
                    FROM Story__c 
                    WHERE Id =: std.getRecord().Id];
        
        
        for(Project__c project : [SELECT Id,
                                    (SELECT Id, Name, Status__c, Primary_Development_Environment__c 
                                    FROM Connections__r 
                                    WHERE Status__c = 'Active' 
                                    ORDER BY CreatedDate ASC) 
                                FROM Project__c 
                                WHERE Id =: story.Project__c ]) {
            if(project.Connections__r != null && project.Connections__r.size() > 0) {
                connectionExist = true;
            }
            else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No active connection found for the Project of this Story.'));
            }
        }
        
        If(story.Created_On_Heroku__c != true) {
            herokuExist = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'This story does not exist on Heroku'));
        }
        else {
            herokuExist = true;
            retriveReviewLogs();
        }
        baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    }
    
    public void retriveReviewLogs() {

        Map<String, String> herokuEndpointsMap  = new Map<String, String>();
        Organization orgz                       = [SELECT IsSandbox FROM Organization LIMIT 1];
        Heroku_oAuth_Setting__mdt credentials   = [SELECT ID, QualifiedApiName, Heroku_URL__c  
                                                    FROM Heroku_oAuth_Setting__mdt 
                                                    WHERE IsSandbox__c =: orgz.IsSandbox LIMIT 1];
        
        for(Heroku_Endpoint__mdt endpoint : [SELECT ID, QualifiedApiName, Endpoint__c FROM Heroku_Endpoint__mdt]) {
            herokuEndpointsMap.put(endpoint.QualifiedApiName, endpoint.Endpoint__c);
        }
    
        String token    = HerokuToken.headerToken();
        Http h          = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(credentials.Heroku_URL__c + herokuEndpointsMap.get('Story_ReviewLogs') + story.Id);
        req.setMethod('GET');
        req.setHeader('token',token); 
        req.setTimeOut(120000);
        HttpResponse res = h.send(req); 
        
        if(res.getStatusCode() == 200 ) {
            ReviewLog dlog = (ReviewLog) JSON.deserialize(EncodingUtil.urlDecode(res.getBody(), 'UTF-8'), ReviewLog.class);
            //System.debug(dlog);
            if(dlog.Status == 'Success' && dlog.Log != null)
              logsList = dlog.Log;
        }
        
    }
    
    @remoteAction
    public static List<LogIssue> scanCodeResult(String scan_Id) {

        Map<String, String> herokuEndpointsMap  = new Map<String, String>();
        Organization orgz                       = [SELECT IsSandbox FROM Organization LIMIT 1];
        Heroku_oAuth_Setting__mdt credentials   = [SELECT ID, QualifiedApiName, Heroku_URL__c  
                                                    FROM Heroku_oAuth_Setting__mdt 
                                                    WHERE IsSandbox__c =: orgz.IsSandbox LIMIT 1];
        
        for(Heroku_Endpoint__mdt endpoint : [SELECT ID, QualifiedApiName, Endpoint__c FROM Heroku_Endpoint__mdt]) {
            herokuEndpointsMap.put(endpoint.QualifiedApiName, endpoint.Endpoint__c);
        }

        String token    = HerokuToken.headerToken();
        Http h          = new Http();
        HttpRequest req = new HttpRequest();
         req.setEndpoint(credentials.Heroku_URL__c + herokuEndpointsMap.get('Story_ScanResult') + scan_Id);
        req.setMethod('GET');
        req.setHeader('token',token); 
        req.setTimeOut(120000);
        
        HttpResponse res = h.send(req);
        System.debug(res);
        System.debug(res.getBody());
                
        List<LogIssue> logIssueList = new List<LogIssue>();
        if(res.getStatusCode() == 200 ){
            ReviewIssue scanLogIssue = (ReviewIssue) JSON.deserialize(EncodingUtil.urlDecode(res.getBody(), 'UTF-8'), ReviewIssue.class);
            //System.debug(scanLogIssue);
            if(scanLogIssue.Status == 'Success' && scanLogIssue.LogIssue != null)
              logIssueList = scanLogIssue.LogIssue; 
        }
          return logIssueList;
    }
    
    public void scanCode() {

        Map<String, String> herokuEndpointsMap  = new Map<String, String>();
        Organization orgz                       = [SELECT IsSandbox FROM Organization LIMIT 1];
        Heroku_oAuth_Setting__mdt credentials   = [SELECT ID, QualifiedApiName, Heroku_URL__c  
                                                    FROM Heroku_oAuth_Setting__mdt 
                                                    WHERE IsSandbox__c =: orgz.IsSandbox LIMIT 1];
        
        for(Heroku_Endpoint__mdt endpoint : [SELECT ID, QualifiedApiName, Endpoint__c FROM Heroku_Endpoint__mdt]) {
            herokuEndpointsMap.put(endpoint.QualifiedApiName, endpoint.Endpoint__c);
        }

        String token    = HerokuToken.headerToken();
        Http h          = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(credentials.Heroku_URL__c + herokuEndpointsMap.get('Story_CodeReview') + story.Id);
        req.setMethod('GET');
        req.setHeader('token',token); 
        req.setTimeOut(120000);
        
        HttpResponse res = h.send(req);
        System.debug(res);
        System.debug(res.getBody());
        
        if(res.getStatusCode() == 200 ) 
        {
            CodeScan dlog = (CodeScan) JSON.deserialize(EncodingUtil.urlDecode(res.getBody(), 'UTF-8'), CodeScan.class);
            //System.debug(dlog);
            if(dlog.Status == 'Success' )
              story.Scan_Running__c = true;
        }
        update story;
    }
    
    
    public void releaseScanStatusStory() {      
        story = [SELECT Id, Name, Scan_Running__c, Created_On_Heroku__c,Project__c  FROM Story__c WHERE Id =: story.Id];
    }
    
    
    public class ReviewLog {
        public String Status {get;set;}
        public List<Log> Log {get;set;}
    }
    public class Log {
        public String logId     {get;set;}
        public String status    {get;set;}
        public String logTime   {get;set;}
    }
    public class ReviewIssue {
        public String Status;
        public List<LogIssue> LogIssue;
    }
    public class LogIssue {
        public String artifactType  {get;set;}
        public String artifactName  {get;set;}
        public String lineNo        {get;set;}
        public String violation     {get;set;}  
    }
    public class CodeScan {
        public String Status;
    }
}