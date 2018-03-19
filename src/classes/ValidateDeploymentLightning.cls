public without sharing class ValidateDeploymentLightning {
    
    @AuraEnabled
    public static String init(Id releaseId) {
        Release__c release  = retrieveRelease(releaseId).release;
        LogResponse obj     = new LogResponse();
        if((release.Source__c == null || release.Source__r.Status__c != 'Active') && (release.Target__c == null || release.Target__r.Status__c != 'Active')) {
            obj.activeStatus = 'There are no active source and target connection for this release.';
            return JSON.serialize(obj);
        }
        if(release.Source__c == null || release.Source__r.Status__c != 'Active') {
            obj.activeStatus = 'There is no active source connection for this release.';
            return JSON.serialize(obj);
        }
        if(release.Target__c == null || release.Target__r.Status__c != 'Active') {
            obj.activeStatus = 'There is no active target connection for this release.';
            return JSON.serialize(obj);
        }
        if(release.Created_On_Heroku__c == false || release.Created_On_Heroku__c == null) {
            obj.activeStatus = 'There are no artifacts attached to this Release. Please add some artifacts before running a Validation/Deployment.'; 
            return JSON.serialize(obj);
        }
        
        obj = retriveDeploymentLogs(release);

        Map<String,String> connectionIdAndNameMap = new Map<String,String>();
        for(Connection__c connection : [SELECT Id, Name FROM Connection__c WHERE Project__c =: release.Project__c])
            connectionIdAndNameMap.put(connection.Id,connection.Name);
        obj.connectionIdAndNameMap  = connectionIdAndNameMap;
        return JSON.serialize(obj);
    }

    @AuraEnabled
    public Static void manageRelease(Id recId) {
        List<Release__c> release = [SELECT Id, Source__c, Source__r.Status__c, Target__c, Target__r.Status__c FROM Release__c WHERE Id =:recId];
        if(release.size() > 0 && release[0].Source__c != null && release[0].Target__c != null && release[0].Target__r.Status__c == 'Active' && release[0].Source__r.Status__c == 'Active')
            ManageReleaseArtifactsLightning.manageRelease(recId);
    }

    @AuraEnabled
    public static ValidationResponseWrapper retrieveRelease(Id releaseId) {
        ValidationResponseWrapper response      = new ValidationResponseWrapper();
        Release__c release                      = [SELECT Id, Name, Project__c, Project__r.Name, Status__c, Source__c, Source__r.Status__c, 
                                                        Actual_Release_Date__c, Target_Release_Date__c, Created_On_Heroku__c ,  Target__c,
                                                        Target__r.Status__c,Validation_Running__c, AsyncResultId__c, Validation_Status__c,
                                                        Validation_Describe_Error__c
                                                    FROM Release__c 
                                                    WHERE Id =: releaseId];
        if(release.Validation_Running__c && release.AsyncResultId__c != null && release.AsyncResultId__c != '') {
            HttpResponse res = RestRequestHandlerForHeroku.sendRequest('POST','Release_Validate_Progress','',release.AsyncResultId__c,release.Project__c,release.Project__r.Name);
            if(res.getStatusCode() == 200 ) {
                ValidationResponseWrapper dlog = (ValidationResponseWrapper) JSON.deserialize(res.getBody(), ValidationResponseWrapper.class);
                if(dlog.status == 'Success')
                    response = dlog;
            }
        }
        response.release = release;
        return response;
    }

    public static LogResponse retriveDeploymentLogs(Release__c release) {
        User currentUser    = [SELECT Id, Name, ContactId FROM User WHERE Id =: UserInfo.getUserId() ];
        String requestBody  = '"contact_Id":"'  + currentUser.ContactId + '",'+
                              '"project_Id":"'  + release.Project__c + '",'+
                              '"target":"'      + release.Target__c + '"';
        
        HttpResponse res = RestRequestHandlerForHeroku.sendRequest('POST','Deployment_Logs',requestBody,release.Id,release.Project__c,release.Project__r.Name);
        LogResponse response = new LogResponse();
        if(res.getStatusCode() == 200 ) {
            DeploymentLog dlog = (DeploymentLog) JSON.deserialize(res.getBody(), DeploymentLog.class);
            if(dlog.Status == 'Success' && dlog.Log != null) {
                response.logList            = dlog.Log;
                response.validateRelease    = dlog.validateRelease == '' ? 'true' :dlog.validateRelease;
                response.deployRelease      = dlog.deployRelease  == '' ? 'true' :dlog.deployRelease;
                response.enableQuickDeploy  = false;
                response.testLevel          = dlog.testLevel;
                if(dlog.Log.size() > 0 && dlog.Log[0].status == 'Succeeded' && dlog.Log[0].action == 'Validate')
                    if(dlog.targetRecentDeployTime == '' || Datetime.valueOf(dlog.Log[0].logTime.replace('T',' ').replace('Z','')) > Datetime.valueOf(dlog.targetRecentDeployTime))
                        response.enableQuickDeploy = true;
                if(dlog.Log.size() > 0 && dlog.Log[0].status != 'Succeeded'  && dlog.Log[0].status != 'InProgress') {
                    dlog.validationProgress.colorTheme1 = 'red';
                    dlog.validationProgress.colorTheme2 = 'red';
                }
                response.validationProgress  = dlog.validationProgress;
                response.specifiedTests      = dlog.specifiedTests;
                response.isRefreshRunning    = release.Validation_Running__c;
            }
        }
        return response;
    }

    @AuraEnabled
    public static DeploymentIssue retriveDeploymentLogIssues(String log_Id,String recId) {
        Release__c release = [SELECT Id, Name, Project__c, Project__r.Name FROM Release__c WHERE Id =: recId];
        HttpResponse res = RestRequestHandlerForHeroku.sendRequest('POST','Deployment_Issues','',log_Id,release.Project__c,release.Project__r.Name);
        DeploymentIssue dlogIssue = new DeploymentIssue();
        if(res.getStatusCode() == 200 ) {
            dlogIssue = (DeploymentIssue) JSON.deserialize(res.getBody(), DeploymentIssue.class);
            if(dlogIssue.Status == 'Success' && dlogIssue.LogIssue != null) {
                if(dlogIssue.metadataList.size() > 0) {
                    dlogIssue.metadataList.sort();
                    for(MetadataWrapper metadataWrapper : dlogIssue.metadataList)
                        metadataWrapper.metadataName.sort();
                }
                return dlogIssue; 
            }

        }
        return new DeploymentIssue();
    }
    
    @AuraEnabled
    public static Validation deployMetadata(String checkOnly, Id releaseId,String testCase,String testClassNames,String recentValidationId) {
        
        String testLevel                        = testCase == null || testCase == '' ? 'Default' : testCase ;                           // 07 Nov 2017 - Amit jayaswal
        List<String> apexTestList               = testClassNames.replace(' ','').split(',');            // 07 Nov 2017 - Amit jayaswal
        String apexTestListJSON                 = JSON.serialize(apexTestList); // 07 Nov 2017 - Amit jayaswal
        Release__c release                      = [SELECT Id, Name, Project__c, Project__r.Name, Status__c, Source__c, Source__r.Status__c, 
                                                        Actual_Release_Date__c, Target_Release_Date__c, Created_On_Heroku__c ,  Target__c,
                                                        Target__r.Status__c,Validation_Running__c, AsyncResultId__c, Validation_Status__c,
                                                        Validation_Describe_Error__c
                                                    FROM Release__c 
                                                    WHERE Id =: releaseId];
        String requestJSONBody = '"Source_Connection":"'   + release.Source__c + '",' + 
                                 '"Target_Connection":"'    + release.Target__c + '",' +
                                 '"Check_Only":"'           + checkOnly + '",' +
                                 '"recentValidationId":"'   + recentValidationId + '",' +
                                 '"testLevel":"'            + testLevel + '",' +
                                 '"apexTestList":'          + apexTestListJSON;

        Validation dlog;
        HttpResponse res = RestRequestHandlerForHeroku.sendRequest('POST','Validate_Deployment',requestJSONBody,release.Id,release.Project__c,release.Project__r.Name);
        if(res.getStatusCode() == 200 ) {
            dlog = (Validation) JSON.deserialize(res.getBody(), Validation.class);
            if(dlog.status == 'Success' ) {
                release.Validation_Running__c           = true;
                release.Validation_Status__c            = 'In Progress';
                if(checkOnly == 'true')
                    release.Validation_Describe_Error__c    = 'Validation in progress.';
                else
                    release.Validation_Describe_Error__c    = 'Deployement in progress.';
                if(checkOnly != 'cancelDeploy')
                    release.AsyncResultId__c = null; // 28 Nov 2017 - Amit jayaswal
                else 
                    release.Validation_Status__c = 'Canceling';
                update release;
            }
        }
        return dlog;
    }
    
    public class DeploymentLog {
        @AuraEnabled public String Status                           {get;set;} 
        @AuraEnabled public String testLevel                        {get;set;} 
        @AuraEnabled public List<Log> Log                           {get;set;} 
        @AuraEnabled public String validateRelease                  {get;set;}
        @AuraEnabled public String deployRelease                    {get;set;}
        @AuraEnabled public String targetRecentDeployTime           {get;set;}
        @AuraEnabled public ValidationProgress validationProgress   {get;set;}
        @AuraEnabled public List<String> specifiedTests				{get;set;}  
    }
    public class Log {
        @AuraEnabled public String logId            {get;set;} 
        @AuraEnabled public String status           {get;set;} 
        @AuraEnabled public String action           {get;set;}
        @AuraEnabled public String sourceConnection {get;set;}
        @AuraEnabled public String targetConnection {get;set;} 
        @AuraEnabled public String asyncResultId    {get;set;} // 08 Nov 2017 - Amit jayaswal
        @AuraEnabled public String testsEnabled     {get;set;} // 20 Dec 2017 - Amit jayaswal
        @AuraEnabled public String logTime          {get;set{
                logTime = value.replace(' ','T') + 'Z';
            }
        }
        @AuraEnabled public String communityUrl     {get{
                return Site.getPathPrefix().split('/s')[0];
            } set;
        } 
    }
    public class LogResponse {
        @AuraEnabled public List<Log> logList                           {get;set;} 
        @AuraEnabled public Boolean isRefreshRunning                    {get;set;}
        @AuraEnabled public String testLevel                            {get;set;} 
        @AuraEnabled public String validateRelease                      {get;set;}
        @AuraEnabled public String deployRelease                        {get;set;}
        @AuraEnabled public Boolean enableQuickDeploy                   {get;set;}
        @AuraEnabled public String activeStatus                         {get;set;} 
        @AuraEnabled public ValidationProgress validationProgress       {get;set;}
        @AuraEnabled public Map<String,String> connectionIdAndNameMap   {get;set;}
        @AuraEnabled public List<String> specifiedTests                 {get;set;}  

    }
    public class DeploymentIssue {
        @AuraEnabled public String Status                           {get;set;} 
        @AuraEnabled public String testLevel                        {get;set;} 
        @AuraEnabled public List<Log_Issue> LogIssue                {get;set;} 
        @AuraEnabled public ValidationProgress validationProgress   {get;set;}
        @AuraEnabled public List<MetadataWrapper> metadataList      {get;set;} // Update 18 Dec 2017 AMIT JAYASWAL
        @AuraEnabled public List<String> specifiedTests             {get;set;} 
    }
    
    // Update 18 Dec 2017 AMIT JAYASWAL
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

    public class MetadataName implements Comparable{
        @AuraEnabled public String name         {get;set;}
        @AuraEnabled public String action       {get;set;}

        public Integer compareTo(Object compareTo) {
            MetadataName other = (MetadataName) compareTo;
            if (this.name > other.name)
              return 1;
            else if (this.name == other.name)
              return 0;
            return -1;
        }
    }

    public class Log_Issue {
        @AuraEnabled public String description  {get;set;} 
        @AuraEnabled public String type         {get;set;} 
    }
    public class Validation {
        @AuraEnabled public String status;
        @AuraEnabled public String message;
    }
    public class ValidationProgress {
        @AuraEnabled public Integer numberComponentsTotal       {get;set;}
        @AuraEnabled public Integer numberTestErrors            {get;set;}
        @AuraEnabled public Integer numberComponentErrors       {get;set;}
        @AuraEnabled public Integer numberTestsTotal            {get;set;}
        @AuraEnabled public Integer numberTestsCompleted        {get;set;}
        @AuraEnabled public Integer numberComponentsDeployed    {get;set;}
        @AuraEnabled public Integer pollTime				    {get;set;}
        @AuraEnabled public String colorTheme1                  {get{ 
                if(colorTheme1 == null){
                    if(numberComponentErrors > 0 )
                        colorTheme1 = 'red';
                    else if(numberComponentsDeployed > 0) 
                        colorTheme1 = 'green';
                }
                return colorTheme1;
            }set;
        }
        @AuraEnabled public String colorTheme2                  {get{
                if(colorTheme2 == null){
                    if(numberTestErrors > 0 )
                        colorTheme2 = 'red';
                    else if(numberTestsCompleted > 0) 
                        colorTheme2 = 'green';
                }
                return colorTheme2;
            }set;
        }
    }
    public class ValidationResponseWrapper {
        @AuraEnabled public ValidationProgress validationProgress   {get;set;}
        @AuraEnabled public String runningStatus                    {get;set;}
        @AuraEnabled public String status                           {get;set;}
        @AuraEnabled public Release__c release                      {get;set;}
    }
}