public class SendStatusReportController {

    public static final String MISSING_CONTACT_EMAIL                = 'The Contact on the Status Report has no Email Address';
    public static final String STATUS_REPORT_SENT_SUCCESSFULLY      = 'Status Report sent successfully';

    @TestVisible private Status_Report__c statusReport ;

    public String returnURL {Get;set;}
    public Boolean isLightningExperience {get; set;}


    public SendStatusReportController(ApexPages.StandardController std) {
        statusReport = (Status_Report__c) std.getRecord();
        isLightningExperience = false;
        if(Apexpages.currentPage().getParameters().get('sfdcIFrameOrigin') != null)
            isLightningExperience = true;
    }

    @RemoteAction
    public static String sendStatusReport(Id statusReportId){
        Status_Report__c selectedStatusReport;
        for(Status_Report__c statusReport : [SELECT Id, Name, Start_Date__c, End_Date__c, Project__r.Account__r.Name, Project__r.Name, CreatedDate,
                                                Project__r.Primary_Client_Contact__r.Email, Project__r.Project_Health__c, Issues_Risks__c,
                                                Project__r.Primary_Client_Contact__c, Sent_to_Client_On__c
                                            FROM Status_Report__c
                                            WHERE Id =: statusReportId ]){
            selectedStatusReport = statusReport;
        }

        Map<String,EmailTemplate> emailTemplateMap = new Map<String,EmailTemplate>();
        
        for(EmailTemplate selectedEmailTemplate : [SELECT Id, DeveloperName FROM EmailTemplate LIMIT 500]) {
            emailTemplateMap.put(selectedEmailTemplate.DeveloperName, selectedEmailTemplate);
        }
        if(selectedStatusReport.Project__r.Primary_Client_Contact__r.Email == null) {
            return MISSING_CONTACT_EMAIL;
        }
        else {
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(selectedStatusReport.Project__r.Primary_Client_Contact__c);
            mail.setWhatId(selectedStatusReport.Id);
            mail.setSaveAsActivity(true);
            mail.setTemplateId(emailTemplateMap.get(Label.Status_Report_Email_Template).Id);
            mail.setCcAddresses(new List<String>{Userinfo.getUserEmail(),Label.Project_Status_Email});
            
            List<Messaging.EmailFileAttachment> fileAttachments = new List<Messaging.EmailFileAttachment>();
            PageReference selectedStatusReportPDFPageRef = new PageReference('/apex/GenerateStatusReportPDF?id=' + selectedStatusReport.Id);
           
            Messaging.EmailFileAttachment selectedStatusReportPDFAttachment = new Messaging.EmailFileAttachment(); 

            Blob pdfData = Test.isRunningTest() ? Blob.valueOf('UNIT.TEST') : selectedStatusReportPDFPageRef.getcontentAsPDF();

            selectedStatusReportPDFAttachment.setFileName(selectedStatusReport.Name+'.pdf');
            selectedStatusReportPDFAttachment.setBody(pdfdata);  
            fileAttachments.add(selectedStatusReportPDFAttachment);

            mail.setFileAttachments(fileAttachments);
            mailList.add(mail);

            List<Messaging.SendEmailResult> results = Messaging.sendEmail(mailList);

            if(!results.get(0).isSuccess()) {
                System.StatusCode statusCode = results.get(0).getErrors()[0].getStatusCode();
                return results.get(0).getErrors()[0].getMessage();
            }
        }
        if(selectedStatusReport.Sent_to_Client_On__c == null) {
            selectedStatusReport.Sent_to_Client_On__c = Date.today();
        }
        update selectedStatusReport;
        return STATUS_REPORT_SENT_SUCCESSFULLY;
    }

    public PageReference returnBack() {
        Status_Report__c currentStatusReport = [SELECT ID, Sent_to_Client_On__c FROM Status_Report__c WHERE Id =: statusReport.Id ];
        PageReference statusReportPage = new ApexPages.StandardController(currentStatusReport ).view();
        returnURL = System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + statusReportPage.getUrl();
        return null;
    }
}