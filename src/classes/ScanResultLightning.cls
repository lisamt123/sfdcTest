public with sharing class ScanResultLightning {
    public class ReviewIssue {
        @AuraEnabled public String Status;
        @AuraEnabled public List<LogIssue> LogIssue;
    }
    public class LogIssue {
        @AuraEnabled public String artifactType  {get;set;}
        @AuraEnabled public String artifactName  {get;set;}
        @AuraEnabled public String lineNo        {get;set;}
        @AuraEnabled public String violation     {get;set;}  
    }
}