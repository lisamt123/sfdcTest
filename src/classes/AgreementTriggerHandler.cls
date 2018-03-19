public class AgreementTriggerHandler{

    /*
    
    public static void preventOverlappingAgreements(){
        
        Map<Id, Agreement__c> agreementIdToAgreementMap = new Map<Id, Agreement__c>();
            
        //For the Agreements being updated, isolate the ones that have a changed Effective Date or Valid Through date
        for(Agreement__c agreement : (List<Agreement__c>) Trigger.new) {
            if((agreement.Effective_Date__c != null && agreement.Effective_Date__c != ((Agreement__c)trigger.oldMap.get(agreement.Id)).Effective_Date__c) ||
               (agreement.Valid_Through__c != null && agreement.Valid_Through__c != ((Agreement__c)trigger.oldMap.get(agreement.Id)).Valid_Through__c)) {
                
                agreementIdToAgreementMap.put(agreement.Id, agreement);
            }
        }
    
        //Only proceed with the Agreements that have had one of their dates modified
        if(agreementIdToAgreementMap !=null && agreementIdToAgreementMap.size() > 0) {

            //Fetch all the Projects that the Agreements are tied to
            Map<Id, Set<Id>>  agreementIdToProjectIdSetMap = new Map<Id, Set<Id>>();
            Set<Id> projectIdSet = new Set<Id>();
            for(Project_Agreement__c projectAgreement : [SELECT Id, Name, Agreement__c, Project__c ,Agreement__r.Effective_Date__c,
                                                                Agreement__r.Valid_Through__c, Agreement__r.Name 
                                                         FROM Project_Agreement__c
                                                         WHERE Agreement__c IN: agreementIdToAgreementMap.KeySet()]) {
                
                projectIdSet.add(projectAgreement.Project__c);

                //Build up a map of all the Project Ids related to these Agreements, keyed by Agreement Id
                if(!agreementIdToProjectIdSetMap.containsKey(projectAgreement.Agreement__c)) {
                    agreementIdToProjectIdSetMap.put(projectAgreement.Agreement__c, new Set<Id>());
                }
                agreementIdToProjectIdSetMap.get(projectAgreement.Agreement__c).add(projectAgreement.Project__c);
            }
            
            //Now that we have the Project Ids, go get all the Agreements for all those Projects
            Map<Id, List<Project_Agreement__c>> projectIdToProjectAgreementsMap = new Map<Id, List<Project_Agreement__c>>();
            for(Project_Agreement__c projectAgreement : [SELECT Id, Name, Agreement__c, Project__c, Project__r.Name,
                                                                Agreement__r.Effective_Date__c,
                                                                Agreement__r.Valid_Through__c, Agreement__r.Name   
                                                         FROM Project_Agreement__c
                                                         WHERE Project__c IN: projectIdSet]) {

                if(!projectIdToProjectAgreementsMap.containsKey(projectAgreement.Project__c)) {
                    projectIdToProjectAgreementsMap.put(projectAgreement.Project__c, new List<Project_Agreement__c>());
                }
                projectIdToProjectAgreementsMap.get(projectAgreement.Project__c).add(projectAgreement);
            }

            //Go through each of the Agreements that are being modified, and see if the updated dates cause overlap issues on the Projects
            Agreement__c agreement;
            for(Id agreementId : agreementIdToAgreementMap.KeySet()) {
                String agreementErrors = '';
                //checking that agreement is linked to a project or not.
                if(agreementIdToProjectIdSetMap!=null && agreementIdToProjectIdSetMap.containsKey(agreementId)){
                    for(Id projectId : agreementIdToProjectIdSetMap.get(agreementId)) {
    
                        for(Project_Agreement__c projectAgreement : projectIdToProjectAgreementsMap.get(projectId)) {
                            
                            agreement = agreementIdToAgreementMap.get(agreementId);
                            
                            if(projectAgreement.Agreement__c != agreementId) {
    
                                if((projectAgreement.Agreement__r.Effective_Date__c <= agreement.Effective_Date__c && projectAgreement.Agreement__r.Valid_Through__c >= agreement.Effective_Date__c) 
                                   || (projectAgreement.Agreement__r.Effective_Date__c <= agreement.Valid_Through__c && projectAgreement.Agreement__r.Valid_Through__c >= agreement.Effective_Date__c)) {
                                    agreementErrors +='<a href=\'/'+ projectAgreement.Project__r.Id +'\' target=\'_blank\'>' + projectAgreement.Project__r.Name + '</a> &nbsp';
                                }
                            }    
                        }
                    }
                }
                if(!String.isBlank(agreementErrors) && agreementErrors.length() > 1) {
                    String errorMessage = ' The new dates on this Agreement cause Agreement Dates to overlap on the following Projects:<br/> ' + agreementErrors;
                    agreementIdToAgreementMap.get(agreementId).addError(errorMessage, false);
                }
            }
        }     
    } 
    
    */

    public static void setDefaultAgreementFields() {

        Set<Id> accountIdsSet = new Set<Id>();
        for(Agreement__c agreement : (List<Agreement__c>)Trigger.new) {
            if(agreement.Account__c != null) {
                accountIdsSet.add(agreement.Account__c);
            }
        }

        Map<Id, Account> accountMap = new Map<Id,Account>([SELECT Id, Primary_Billing_Contact__c, Payment_Terms__c,Additional_Invoice_Recipients__c,
                                                                Invoicing_Notes__c, Custom_Invoice_Email_Template__c
                                                           FROM Account
                                                           WHERE Id IN: accountIdsSet]);

        for(Agreement__c agreement : (List<Agreement__c>)Trigger.new) {
            if(agreement.Account__c != null) {
                if(accountMap.KeySet().contains(agreement.Account__c)) {
                    agreement.Billing_Contact__c                        = accountMap.get(agreement.Account__c).Primary_Billing_Contact__c;
                    agreement.Payment_Terms__c                          = accountMap.get(agreement.Account__c).Payment_Terms__c;
                    agreement.Additional_Invoice_Recipients__c          = accountMap.get(agreement.Account__c).Additional_Invoice_Recipients__c;
                    agreement.Invoicing_Notes__c                        = accountMap.get(agreement.Account__c).Invoicing_Notes__c;
                    agreement.Custom_Invoice_Email_Template__c          = accountMap.get(agreement.Account__c).Custom_Invoice_Email_Template__c;
                }
            }
        }
    }

    public static void setRelatedOpportunityAgreementFields(List<Agreement__c> agreementTriggerList) {
        Id serviceRecordTypeId        = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Services Opportunity').getRecordTypeId();
        Id msaOpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('MSA Opportunity').getRecordTypeId();
        Id msaAgreementRecordTypeId   = Schema.SObjectType.Agreement__c.getRecordTypeInfosByName().get('MSA').getRecordTypeId();
        Set<Id> msaOpportunityIdSet   = new Set<Id>();
        Map<Id,Agreement__c> msaOpportunityMsaAgreementMap = new Map<Id,Agreement__c>();
        for(Agreement__c agreement : agreementTriggerList) {
            if(agreement.Opportunity__c != null && agreement.RecordTypeId == msaAgreementRecordTypeId)
                msaOpportunityIdSet.add(agreement.Opportunity__c);
                msaOpportunityMsaAgreementMap.put(agreement.Opportunity__c,agreement);
        }
        List<Opportunity> serviceOpportunityList = new List<Opportunity>();
        for(Opportunity opp : [SELECT Id, MSA_Opportunity__c, MSA_Agreement__c 
                                FROM Opportunity 
                                WHERE RecordTypeId =: serviceRecordTypeId 
                                AND MSA_Opportunity__c IN :msaOpportunityIdSet]) {
            if(opp.MSA_Agreement__c == null) {
                if(msaOpportunityMsaAgreementMap.containsKey(opp.MSA_Opportunity__c)) {
                    if(msaOpportunityMsaAgreementMap.get(opp.MSA_Opportunity__c) != null) {
                        Agreement__c agreementObj = msaOpportunityMsaAgreementMap.get(opp.MSA_Opportunity__c) ;
                        opp.MSA_Agreement__c      = agreementObj.Id ;
                        serviceOpportunityList.add(opp);
                    }
                }
            }
        }
        if(!serviceOpportunityList.isEmpty())
            update serviceOpportunityList ;
    }
}