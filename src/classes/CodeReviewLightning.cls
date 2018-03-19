// Code Review Lightning Controller for Story

public with sharing class CodeReviewLightning {
    @AuraEnabled
    public static String getCodeReviewFunctionality(String recId) {
        LogResponse mainLogResponse = new LogResponse();
        String storyKeyPrifix       = Schema.getGlobalDescribe().get('Story__c').getDescribe().getKeyPrefix();
        String releaseKeyPrifix     = Schema.getGlobalDescribe().get('Release__c').getDescribe().getKeyPrefix();
        String connectionKeyPrifix  = Schema.getGlobalDescribe().get('Connection__c').getDescribe().getKeyPrefix();
        String objectName           = '';
        String message              = '';
        if(recId.substring(0, 3) == storyKeyPrifix) {
            objectName  = 'Story__c';
            message     = 'There are no artifacts attached to this Story. Please add some Apex classes and/or triggers before running a code scan.';
        }
        else if (recId.substring(0, 3) == releaseKeyPrifix) {
            objectName  = 'Release__c';
            message     = 'There are no artifacts attached to this Release. Please add some Apex classes and/or triggers before running a code scan.';
        }
        else if (recId.substring(0, 3) == connectionKeyPrifix) {
            objectName  = 'Connection__c';
            message     = 'This connection is not authorized. Please authorize the connection before running a code scan.';
        }

        SObject record                  = retrieveStory(recId,objectName);
        List<Log> logsList              = new List<Log>();
        mainLogResponse.objctAPIName    = objectName;
        mainLogResponse.objctLabel      = objectName.replace('__c','');

        if((Boolean)record.get('Created_On_Heroku__c') != true) {
            mainLogResponse.activeStatus = message;
            return JSON.serialize(mainLogResponse);
        }
        else {
            if(objectName == 'Connection__c') {
                Connection__c connection = [SELECT Id, Status__c FROM Connection__c WHERE Id =: recId];
                if(connection.Status__c != 'Active') {
                    mainLogResponse.activeStatus = 'This connection is not active. Please authorize the connection before running a code scan.';
                    return JSON.serialize(mainLogResponse);
                }
            }
            if(objectName == 'Release__c') {
                List<Release__c> release = [SELECT Id, Source__c, Source__r.Status__c, Source__r.Created_On_Heroku__c, Target__c FROM Release__c WHERE Id =:recId];
                if(release[0].Source__c == null || release[0].Source__r.Status__c != 'Active' || !release[0].Source__r.Created_On_Heroku__c) {
                    mainLogResponse.activeStatus = 'There is no active source connection for this release.';
                    return JSON.serialize(mainLogResponse);
                }
            }
            logsList                            = retriveReviewLogs(record,objectName);
            mainLogResponse.logList             = logsList;
            mainLogResponse.isRefreshRunning    = (Boolean)record.get('Scan_Running__c');
            return JSON.serialize(mainLogResponse);
        }
    }
    
    @AuraEnabled
    public static Sobject retrieveStory(String recId,String objectName) {
        String querystring = 'SELECT Id, Scan_Running__c, Created_On_Heroku__c, Project__c, Project__r.Name FROM ' + objectName + ' WHERE Id =: recId';
        return Database.query(querystring);
    }

    @AuraEnabled
    public Static void manageRelease(String recId) {
        String releaseKeyPrifix = Schema.getGlobalDescribe().get('Release__c').getDescribe().getKeyPrefix();
        if (recId.substring(0, 3) == releaseKeyPrifix)
            ManageReleaseArtifactsLightning.manageRelease(recId);
    }
    
    public Static List<Log> retriveReviewLogs(Sobject record,String objectName) {
        List<Log> logsList = new List<Log>();
        String reqEndpoint = '';
        if(objectName == 'Story__c')
            reqEndpoint = 'Story_ReviewLogs';
        else if(objectName == 'Connection__c')
            reqEndpoint = 'Connection_ReviewLogs';
        else 
            reqEndpoint = 'Release_ReviewLogs';


        HttpResponse res = RestRequestHandlerForHeroku.sendRequest('POST',reqEndpoint,'',(String)record.Id,(String)record.get('Project__c'),(String)record.getSobject('Project__r').get('Name'));
        if(res.getStatusCode() == 200 ) {
            ReviewLog dlog = (ReviewLog) JSON.deserialize(res.getBody(), ReviewLog.class);
            if(dlog.Status == 'Success' && dlog.Log != null)
              logsList = dlog.Log;
        }
        return logsList;
    }
    
    @AuraEnabled
    public static List<LogIssue> retriveScanLogIssues(String logId,String objectName, String recordsLimit,String recId) {
        Sobject record                              = retrieveStory(recId,objectName);
        Manage_Artifacts_Setting__mdt defaultLimit  = [SELECT ID, QualifiedApiName, Limit__c  FROM Manage_Artifacts_Setting__mdt LIMIT 1];
        Integer recCount                            = Integer.valueOf(recordsLimit) + Integer.valueOf(defaultLimit.Limit__c);
        String reqEndpoint = '';
        if(objectName == 'Story__c')
            reqEndpoint = 'Story_ScanResult';
        else if(objectName == 'Connection__c')
            reqEndpoint = 'Connection_ScanResult';
        else 
            reqEndpoint = 'Release_ScanResult';

        List<RuleSetWrapper> ruleSetWrapperList = new List<RuleSetWrapper>();
        for(Code_Scan_Rule_Set__mdt rule : [SELECT Id, QualifiedApiName, Severity__c, State__c, Rule_Description__c FROM Code_Scan_Rule_Set__mdt]){
            RuleSetWrapper ruleInfo = new RuleSetWrapper();
            ruleInfo.ruleName       = rule.QualifiedApiName;
            ruleInfo.ruleSeverity  = rule.Severity__c;
            ruleSetWrapperList.add(ruleInfo);
        }

        String requestJSONBody = '"limit":"' + recCount + '",' +
                                 '"ruleList":' + JSON.serialize(ruleSetWrapperList);
        HttpResponse res = RestRequestHandlerForHeroku.sendRequest('POST',reqEndpoint,requestJSONBody,logId,(String)record.get('Project__c'),(String)record.getSobject('Project__r').get('Name'));
        List<LogIssue> logIssueList = new List<LogIssue>();
        if(res.getStatusCode() == 200 ){
            ReviewIssue scanLogIssue = (ReviewIssue) JSON.deserialize(res.getBody(), ReviewIssue.class);
            if(scanLogIssue.Status == 'Success' && scanLogIssue.LogIssue != null)
              logIssueList = scanLogIssue.LogIssue; 
        }
        return logIssueList;
    }
    
    @AuraEnabled
    public static CodeScan scanCode(Id recId,String objectName) {
        Sobject record = retrieveStory((String)recId,objectName);
        String reqEndpoint = '';
        if(objectName == 'Story__c')
            reqEndpoint = 'Story_CodeReview';
        else if(objectName == 'Connection__c')
            reqEndpoint = 'Connection_CodeReview';
        else 
            reqEndpoint = 'Release_CodeReview';
        List<RuleSetWrapper> ruleSetWrapperList = new List<RuleSetWrapper>();
        for(Code_Scan_Rule_Set__mdt rule : [SELECT Id, QualifiedApiName, Severity__c, State__c, Rule_Description__c FROM Code_Scan_Rule_Set__mdt]){
            RuleSetWrapper ruleInfo = new RuleSetWrapper();
            ruleInfo.ruleName   = rule.QualifiedApiName;
            ruleInfo.ruleState = rule.State__c;
            ruleSetWrapperList.add(ruleInfo);
        }

        String requestJSONBody = '"ruleList":' + JSON.serialize(ruleSetWrapperList);
        
        HttpResponse res = RestRequestHandlerForHeroku.sendRequest('POST',reqEndpoint,requestJSONBody,(String)recId,(String)record.get('Project__c'),(String)record.getSobject('Project__r').get('Name'));
        CodeScan dlog;
        if(res.getStatusCode() == 200 ) {
            dlog = (CodeScan) JSON.deserialize(res.getBody(), CodeScan.class);
            if(dlog.status == 'Success' )
                record.put('Scan_Running__c',true);
        }
        update record;
        return dlog;
    }

    public class RuleSetWrapper {
        @AuraEnabled public string ruleName         {get;set;}
        @AuraEnabled public string ruleState       {get;set;}
        @AuraEnabled public string ruleSeverity    {get;set;}
    }
    
    public class ReviewLog {
        @AuraEnabled public String Status {get;set;}
        @AuraEnabled public List<Log> Log {get;set;}
    }
    public class Log {
        @AuraEnabled public String logId    {get;set;}
        @AuraEnabled public String status   {get;set;}
        @AuraEnabled public String logTime  {get;set{
                logTime = value.replace(' ','T') + 'Z';
            }
        }
        @AuraEnabled public String communityUrl { get {
                return  Site.getPathPrefix().split('/s')[0];
            } set;
        }
    }
    public class ReviewIssue {
        @AuraEnabled public String Status;
        @AuraEnabled public List<LogIssue> LogIssue;
    }
    public class LogIssue {
        @AuraEnabled public String artifactType  {get;set;}
        @AuraEnabled public String artifactName  {get;set;}
        @AuraEnabled public String lineNo        {get;set;}
        @AuraEnabled public String severity      {get;set;}
        @AuraEnabled public String violation     {get;set;}  
    }
    public class CodeScan {
        @AuraEnabled public String status;
        @AuraEnabled public String message;
    }
    public class LogResponse {
        @AuraEnabled public List<Log> logList           {get;set;} 
        @AuraEnabled public Boolean isRefreshRunning    {get;set;}
        @AuraEnabled public String activeStatus         {get;set;} 
        @AuraEnabled public String objctAPIName         {get;set;} 
        @AuraEnabled public String objctLabel           {get;set;} 
    }
}