public class AscentMonthlyReportController {
    
    @AuraEnabled
    public static MonthListWrapper doInitAscMetric(){
        Integer year = date.today().year();
        List<String> monthList = new List<String>{'January '+year,'Febuary '+year,'March '+year,'April '+year,'May '+year,'June '+year,
                                                    'July '+year,'August '+year,'September '+year,'October '+year,'November '+year,'December '+year};
        
        String currentMonthName = monthNumberTofullName(date.today().Month());
        MonthListWrapper monthWrapWithCurrentMonth = new MonthListWrapper(monthList,currentMonthName);
        return monthWrapWithCurrentMonth;
    }

    public class MonthListWrapper    {
        @AuraEnabled public List<String> monthList     {get;set;}
        @AuraEnabled public String currentMonthName    {get;set;}
        public MonthListWrapper(List<String> monthList,String currentMonthName) {
            this.monthList = monthList;
            this.currentMonthName= currentMonthName;
        }
    }
    
    @AuraEnabled
    public static MainResponseWrapper ascendMetricValues(String selectedMonthName){
        Integer selectMonthNum = date.today().Month();
        If(selectedMonthName != null && selectedMonthName != ''){
            selectMonthNum = monthfullNameToNumber(selectedMonthName);
        }
        Date monthStartDate = Date.newInstance(date.today().year(), selectMonthNum, 1);
        Date monthEndDate   = Date.newInstance(date.today().year(), selectMonthNum + 1, 1)-1;
        
        List<AccountAscendMetricWrapper> accAscMetricWrapper = new List<AccountAscendMetricWrapper>();
        Set<Id> accIds      = new Set<Id>();
        Set<Id> oppMSAIds   = new Set<Id>();
        Map<Id,List<ContactOppRoleWrapper>> accIdWithSetContactMap = new Map<Id,List<ContactOppRoleWrapper>>();
        Map<Id,Integer> accIdWithDraftInvoiceMap = new Map<Id,Integer>();
        Map<Id,Date> metricIdWithDateMap = new Map<Id,Date>();
        Map<Id,Opportunity> oppMsaAccIdToMsaIdMap = new Map<Id,Opportunity>();
        
        List<Ascent_Metrics__c> metricList = [SELECT Id, Account__c, Account__r.Current_Tier__c, Account__r.RecordTypeId, Account__r.Name, 
                                                    Account__r.Total_Outstanding_Invoices__c, Account__r.Total_Outstanding_Overdue_Invoices__c, 
                                                    IsDeleted, Name, Amount_Invoiced_YTD__c, Current_Tier__c, Hours_Invoiced_YTD__c, Month_End_Date__c, 
                                                    Month_Start_Date__c, Next_Tier__c 
                                                FROM Ascent_Metrics__c 
                                                WHERE Month_Start_Date__c =: monthStartDate 
                                                AND Month_End_Date__c =: monthEndDate 
                                                AND Account__r.RecordTypeId != : Constants.RECORDTYPEID_Account_DeliveryPartner 
                                                AND Account__r.Current_Tier__c != null 
                                                AND Account__r.Current_Tier__c != 'Base'];
        
        // Processing metric List to Account Ids for MSA opp Query
        for(Ascent_Metrics__c ascMetric : metricList){
            accIds.add(ascMetric.Account__c);
        }

        

        for(Account acc :[SELECT Id, (SELECT ActivityDate,WhatId FROM ActivityHistories ORDER BY ActivityDate DESC LIMIT 200) FROM Account WHERE Id IN:accIds]) {
            for(ActivityHistory actHistory :  acc.getSObjects('ActivityHistories')){
                if(!metricIdWithDateMap.containsKey(actHistory.WhatId))
                    metricIdWithDateMap.put(actHistory.WhatId,actHistory.ActivityDate);
            }
        
        }

        List<Account> accountList = [SELECT Id,
                                        (SELECT Id FROM Invoices__r 
                                        WHERE  Type__c = 'Draft') 
                                        FROM Account 
                                        WHERE Id 
                                        IN:accIds];    
        
        System.debug('accountList>>>'+accountList);
        for(Account acc: accountList){
            System.debug('invoiceList>>>'+acc.Invoices__r.size());
            if(!accIdWithDraftInvoiceMap.containsKey(acc.Id)){
                if(!acc.Invoices__r.isEmpty())
                    accIdWithDraftInvoiceMap.put(acc.Id,acc.Invoices__r.size());
                else
                   accIdWithDraftInvoiceMap.put(acc.Id,0); 
            }
                
        }
        // Processing MSA Opportunity for opportunityIds
        for(Opportunity oppMSAtype : [SELECT Id, Name, AccountId 
                                        FROM Opportunity 
                                        WHERE RecordTypeId =: Constants.RECORDTYPEID_OPPORTUNITY_MSA 
                                        AND AccountId IN: accIds 
                                        AND Start_Date__c <=: monthStartDate AND End_Date__c >=: monthEndDate]) {
            oppMSAIds.add(oppMSAtype.Id);
            oppMsaAccIdToMsaIdMap.put(oppMSAtype.AccountId,oppMSAtype);
        }
        // Processing metric List to create wrapper in every contains key condition with contact roles
        Set<String> contactIDSet = new Set<String>();
        for(OpportunityContactRole oppConRole : [SELECT Id, OpportunityId, Opportunity.AccountId, ContactId, Contact.Name, Role 
                                                    FROM OpportunityContactRole WHERE OpportunityId =: oppMSAIds]) {
            if(!contactIDSet.contains(oppConRole.Opportunity.AccountId+'#'+oppConRole.ContactId)) {
                if(accIdWithSetContactMap.containsKey(oppConRole.Opportunity.AccountId)) {
                    accIdWithSetContactMap.get(oppConRole.Opportunity.AccountId).add(new ContactOppRoleWrapper(oppConRole.Contact.Name,oppConRole.ContactId));
                } else {
                    accIdWithSetContactMap.put(oppConRole.Opportunity.AccountId, new List<ContactOppRoleWrapper>{ new ContactOppRoleWrapper(oppConRole.Contact.Name,oppConRole.ContactId)});
                }
                contactIDSet.add(oppConRole.Opportunity.AccountId+'#'+oppConRole.ContactId);
            }
        }
        
        // Processing metric List to create wrapper in every contains key condition with contact roles
        for(Ascent_Metrics__c ascMetric : metricList) {
            if(oppMsaAccIdToMsaIdMap.containsKey(ascMetric.Account__c)) {
                if(accIdWithSetContactMap.containsKey(ascMetric.Account__c)) {
                    accAscMetricWrapper.add(new AccountAscendMetricWrapper(false, ascMetric, accIdWithSetContactMap.get(ascMetric.Account__c),accIdWithDraftInvoiceMap.get(ascMetric.Account__c),metricIdWithDateMap.get(ascMetric.Id)));
                } else {
                    accAscMetricWrapper.add(new AccountAscendMetricWrapper(false, ascMetric, new List<ContactOppRoleWrapper>(),accIdWithDraftInvoiceMap.get(ascMetric.Account__c),metricIdWithDateMap.get(ascMetric.Id)));
                }
            }
        }
        MainResponseWrapper reponseWrapper = new MainResponseWrapper(accAscMetricWrapper);
        return reponseWrapper;
    }

    @AuraEnabled
    public static String sendAscentReportEmail(String accountAscendMetricWrapper) {
        String status                   = 'NotSelected'; 
        OrgWideEmailAddress[] owea      = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :Label.Invoice_Reminders_Sent_From];
        EmailTemplate[] template        = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = 'Ascent_Report_Template'];
        String userEmailAddress         = UserInfo.getUserEmail();
        List<String> ccEmailAddresses   = new List<String>{userEmailAddress, 'delivery@10kview.com'};
        Set<Id> accIdSet                = new Set<Id>();
        List<AccountAscendMetricWrapper> assignWrap     = (List<AccountAscendMetricWrapper>)JSON.deserialize(accountAscendMetricWrapper, List<AccountAscendMetricWrapper>.class);
        List<Messaging.SingleEmailMessage> emailList1   = new List<Messaging.SingleEmailMessage>();
        for(AccountAscendMetricWrapper accountAscendMetricRec : assignWrap) {
            accIdSet.add(accountAscendMetricRec.ascMetric.Account__c);
        }
        
        List<Invoice__c> invoiceList = [SELECT Id, Account__c, Billing_Period_Start_Date__c, Billing_Period_End_Date__c, Name, Outstanding_Balance__c, 
                                            Invoice_Generated_On__c, Due_Date__c, Total_Invoice_Amount__c 
                                        FROM Invoice__c 
                                        WHERE Account__c IN :accIdSet
                                        And Type__c = 'Actual'  
                                        AND  Outstanding_Balance__c > 0];    
        Blob pdfData;
        for(AccountAscendMetricWrapper accountAscendMetricRec : assignWrap) {
            List<Messaging.EmailFileAttachment> fileAttachments = new List<Messaging.EmailFileAttachment>();
            if(accountAscendMetricRec.isSelected) {
                System.debug(invoiceList+'------'+accountAscendMetricRec.ascMetric.Account__c);
                for(Invoice__c invoice : invoiceList) {
                    if(invoice.Account__c == accountAscendMetricRec.ascMetric.Account__c) {
                        PageReference invoicePDFPageRef = Page.GenerateInvoicePDF;
                        invoicePDFPageRef.getParameters().put('id', invoice.Id);
                       
                        Messaging.EmailFileAttachment invoicePDFAttachment = new Messaging.EmailFileAttachment(); 

                        pdfData = Test.isRunningTest() ? Blob.valueOf('UNIT.TEST') : invoicePDFPageRef.getcontentAsPDF();

                        invoicePDFAttachment.setFileName(invoice.Name+'.pdf');
                        invoicePDFAttachment.setInline(false);
                        invoicePDFAttachment.setBody(pdfData);  
                        fileAttachments.add(invoicePDFAttachment);
                    }
                }
                if(accountAscendMetricRec.contactRolesValues.size() > 0) {
                    for(ContactOppRoleWrapper contactRoleRec : accountAscendMetricRec.contactRolesValues) {
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

                        email.setWhatId(accountAscendMetricRec.ascMetric.Id);
                        email.setTemplateId(template[0].Id);
                        email.setTargetObjectId(contactRoleRec.ContactId);
                        email.setCcAddresses(ccEmailAddresses);
                        email.setBccSender(false);
                        email.setUseSignature(false);
                        email.setTreatTargetObjectAsRecipient(true); 

                        if ( owea.size() > 0 ) 
                        {
                            email.setOrgWideEmailAddressId(owea.get(0).Id);
                        }
                        email.setFileAttachments(fileAttachments);
                        emailList1.add(email);
                    }
                }
                else{
                    status = 'No Contact Role';
                }
            }
        }
        
        if(emailList1.size() > 0){
            try
            {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(emailList1);
                System.debug('results>>>'+results);
                if(results[0].success) 
                    status = 'success';
                else
                    status = 'fail';
            }
            catch(Exception ex){
                status = 'fail';
            }

        }
        
        return status;
    }

    @AuraEnabled
    public static String viewPdf(String Id) {
        PageReference pageRef = Page.GenerateAscentMonthlyReportPdf;
        pageRef.getParameters().put('Id', Id);
        pageRef.setRedirect(false);
        String exportBaseURl = Url.getSalesforceBaseURl().toExternalForm()+'/'+ pageRef.getUrl();
        return exportBaseURl;
    }
    
    public class MainResponseWrapper    {
        @AuraEnabled public List<AccountAscendMetricWrapper>  ascMetricList     {get;set;}
        public MainResponseWrapper(List<AccountAscendMetricWrapper>  ascMetricList) {
            this.ascMetricList = ascMetricList;
        }
    }
    
    public class AccountAscendMetricWrapper {
        @AuraEnabled public Boolean  isSelected                             {get;set;}
        @AuraEnabled public Ascent_Metrics__c  ascMetric                    {get;set;}
        @AuraEnabled public List<ContactOppRoleWrapper> contactRolesValues  {get;set;}
        @AuraEnabled public Integer totalDraftInvoice                       {get;set;}
        @AuraEnabled public Date sentDate                                   {get;set;}
        public  AccountAscendMetricWrapper(Boolean  isSelected, Ascent_Metrics__c  ascMetric, List<ContactOppRoleWrapper> contactRolesValues,Integer totalDraftInvoice,Date sentDate) {
            this.isSelected = isSelected;
            this.ascMetric = ascMetric;
            this.contactRolesValues = contactRolesValues;
            this.totalDraftInvoice = totalDraftInvoice;
            this.sentDate = sentDate;
        }
    }
    public class ContactOppRoleWrapper {
        @AuraEnabled public String contactName                          {get;set;}
        @AuraEnabled public string contactId                            {get;set;}
        public  ContactOppRoleWrapper(string contactName, String contactId) {
            this.contactName = contactName;
            this.contactId = contactId;
        }
    }
    
    private static Integer monthfullNameToNumber(String monthName){
        Integer year = date.today().year();
        Map<String, Integer> monthMap = new Map<String, Integer>{'January '+year => 1,'Febuary '+year => 2,'March '+year => 3,
                                                                 'April '+year => 4,'May '+year => 5,'June '+year => 6, 
                                                                 'July '+year => 7, 'August '+year => 8,'September '+year => 9,
                                                                 'October '+year => 10,'November '+year => 11,'December '+year => 12};
        return monthMap.get(monthName);
    }
    private static String monthNumberTofullName(Integer monthNum){
        Integer year = date.today().year();
        Map<Integer, String> monthMap = new Map<Integer,String>{1 => 'January '+year,2 => 'Febuary '+year,3 => 'March '+year,
                                                                4 => 'April '+year,5 => 'May '+year,6 => 'June '+year, 
                                                                7 => 'July '+year,8 => 'August '+year,9 => 'September '+year,
                                                                10 => 'October '+year,11 => 'November '+year,12 => 'December '+year};
        return monthMap.get(monthNum);
    }
}