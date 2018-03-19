public with sharing class GenerateStatusReportPDFController {

    public Status_Report__c selectedStatusReport {get;set;}
    public String projectDetailUrl {get;set;}

    public GenerateStatusReportPDFController(ApexPages.StandardController stdController) {
        //this.mysObject = (sObject)stdController.getRecord();
        for(Status_Report__c statusReport : [SELECT Id, Start_Date__c, End_Date__c,Project__c, Project__r.Account_Name__c, Project__r.Name, CreatedDate,
                                                Project__r.Primary_Client_Contact_Name__c, Project__r.Project_Health__c, Questions_Concerns__c,
                                                Key_Items_Completed_Last_Week__c, Key_Items_Scheduled_for_This_Week__c, Upcoming_Holidays_PTO__c, 
                                                Project_Lead__c,Project_Health__c
                                            FROM Status_Report__c
                                            WHERE Id =: stdController.getRecord().Id ]){
            selectedStatusReport    = statusReport;
            

        }
        List<Project__c> projectList = [SELECT Id FROM Project__c WHERE Id =: selectedStatusReport.Project__c];
        if(projectList.size() > 0) {
            PageReference statusReportPage = new ApexPages.StandardController(projectList[0]).view();
            projectDetailUrl = System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + statusReportPage.getUrl();
        }
        else {
            projectDetailUrl = '';
        }
            
    }
}