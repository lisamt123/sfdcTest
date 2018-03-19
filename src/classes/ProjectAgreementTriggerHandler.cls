public class ProjectAgreementTriggerHandler {
    

    public static void preventOverlappingAgreements(List<Project_Agreement__c> projectAgreements){
        Map<Id, Set<Id>> projectAgreementMap = new Map<Id, Set<Id>>();
        Map<Id, Map<Id,Project_Agreement__c>> projectAgreementTriggerData = new Map<Id, Map<Id,Project_Agreement__c>>();
        Set<Id> agreementSet = new Set<Id>();
        for(Project_Agreement__c projectAgreement: projectAgreements){
        
            List<Project_Agreement__c> projectAgreementList;
            
            if(!projectAgreementMap.containsKey(projectAgreement.Project__c)){
                projectAgreementMap.put(projectAgreement.Project__c, new Set<Id>()); //projectAgreementList
                projectAgreementTriggerData.put(projectAgreement.Project__c, new Map<Id, Project_Agreement__c>());
            }
            
            //Check if any project is going to be inserted with Duplicate Agreement? If Yes, then add Error
            if(projectAgreementMap.get(projectAgreement.Project__c).contains(projectAgreement.Agreement__c)){
                 projectAgreement.addError(Constants.ERROR_DUPLICATE_AGREEMENT_FOR_PROJECT);
                 return;
            }
            
            projectAgreementMap.get(projectAgreement.Project__c).add(projectAgreement.Agreement__c);
            projectAgreementTriggerData.get(projectAgreement.Project__c).put(projectAgreement.Agreement__c, projectAgreement);
            agreementSet.add(projectAgreement.Agreement__c);
        }
        
            
        //checking if records that coming in bulk for same project and are overlapping with each other.
        Map<Id, Agreement__c> agreementMap = new Map<Id, Agreement__c>([SELECT Id, Name, Effective_Date__c, Valid_Through__c
                                                                        FROM Agreement__c
                                                                        WHERE Id IN: agreementSet]);
        if(agreementMap !=null && agreementMap.size()>0){
             for(Integer i=0 ; i < projectAgreements.size(); i++){
                 Agreement__c agreementRecord1 = agreementMap.get(projectAgreements.get(i).Agreement__c);
                 for(Integer j = 0 ; j < projectAgreements.size(); j++){
                     if(projectAgreements.get(i).Project__c == projectAgreements.get(j).Project__c &&
                       (projectAgreements.get(i).Agreement__c != projectAgreements.get(j).Agreement__c)){
                         
                         Agreement__c agreementRecord2 = agreementMap.get(projectAgreements.get(j).Agreement__c);
                         //checking for overlapping.
                         if((agreementRecord1.Effective_Date__c <= agreementRecord2.Effective_Date__c && agreementRecord1.Valid_Through__c >= agreementRecord2.Effective_Date__c) 
                           || (agreementRecord1.Effective_Date__c <= agreementRecord2.Valid_Through__c && agreementRecord1.Valid_Through__c >= agreementRecord2.Effective_Date__c) ){
                            projectAgreementTriggerData.get(projectAgreements.get(i).Project__c).get(projectAgreements.get(i).Agreement__c).addError('The dates on this Agreement are overlapping with <a href=\'/'+ agreementRecord2.Id +'\' target=\'_blank\'>' + agreementRecord2.name + '</a> Project Agreement. Overlaps are not allowed, please adjust the dates or select a new Agreement.',false);
                         }
                     }
                 }
             }
        }
         
    
        //Fetch old Project Agreements of Projects.
        Map<Id, List<Project_Agreement__c>> projectAgreementListMap = getProjectAgreementsMap(projectAgreementMap.keySet());
        
        if(!projectAgreementListMap.isEmpty()) {
            Set<Id> agreementIdSet = new Set<Id>();
            for(Id key : projectAgreementMap.keySet()) {
                agreementIdSet.addAll(projectAgreementMap.get(key)); 
            }

            Map<Id, Agreement__c> newAgreementsMap = new Map<Id, Agreement__c>([SELECT Id, Name, Effective_Date__c, Valid_Through__c
                                                                                FROM Agreement__c
                                                                                WHERE Id IN: agreementIdSet]);
            
            for(Id projectId : projectAgreementListMap.keySet()){
                for(Project_Agreement__c projectAgreement : projectAgreementListMap.get(projectId)){
                    Agreement__c oldAgreement = projectAgreement.Agreement__r;
                    for(Id agreementId: projectAgreementMap.get(projectId)){
                                            
                       Agreement__c agreement = newAgreementsMap.get(agreementId);
                       //checking for overlapping.
                       if((oldAgreement.Effective_Date__c <= agreement.Effective_Date__c && oldAgreement.Valid_Through__c >= agreement.Effective_Date__c) 
                          || (oldAgreement.Effective_Date__c <= agreement.Valid_Through__c && oldAgreement.Valid_Through__c >= agreement.Effective_Date__c) ){
                            projectAgreementTriggerData.get(projectId).get(agreementId).addError('The dates on this Agreement are overlapping with <a href=\'/'+ projectAgreement.Id +'\' target=\'_blank\'>' + projectAgreement.name + '</a> Project Agreement. Overlaps are not allowed, please adjust the dates or select a new Agreement.',false);
                        }
                    }    
                }
            }
        }
    }
    
    //this methods returns Map of Project and their all existing project agreements.
    private static Map<Id, List<Project_Agreement__c>> getProjectAgreementsMap(Set<Id> projectIds) {
         Map<Id, Project_Agreement__c> projectAgreementMap = new Map<Id, Project_Agreement__c>([SELECT Id, Name, Agreement__c, Project__c, Agreement__r.Effective_Date__c,
                                                                                                       Agreement__r.Valid_Through__c, Agreement__r.Name   
                                                                                                FROM Project_Agreement__c
                                                                                                WHERE Project__c IN: projectIds]);

         Map<Id, List<Project_Agreement__c>> projectAgreementListMap = new  Map<Id, List<Project_Agreement__c>>();
         
         if(projectAgreementMap != null && projectAgreementMap.size() > 0){
            for(Project_Agreement__c projectAgreement : projectAgreementMap.values()){
                
                //Filling project Agreements Map
                if(!projectAgreementListMap.containsKey(projectAgreement.Project__c)){
                    projectAgreementListMap.put(projectAgreement.Project__c,new List<Project_Agreement__c>());
                }
                projectAgreementListMap.get(projectAgreement.Project__c).add(projectAgreement);
            }
         }
         return projectAgreementListMap ;
    }
}