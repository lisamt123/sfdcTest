public with sharing class CaseTriggerHandler {
    
    public void onAfterInsert(List<Case> newCaseList, Map<Id, Case> newCaseMap) {
        forceAssignmentRulesOnNewCases(newCaseMap.keyset());
    }
    
    public void onBeforeInsert(List<Case> newCaseList) {
        
        associateCasesProperly(newCaseList, null);
        filterEmailToCaseTraffic(newCaseList);
    }
    
    private void forceAssignmentRulesOnNewCases(set<id> caseIds) {
        Set<Id> caseIdSet = new Set<Id>();
        Set<Id> caseListToBeDeleted = new Set<Id>();
        List<Case> caseList = new List<Case>();
        caseList = [SELECT Id, Is_Checked_For_Delete__c FROM Case WHERE Id IN: caseIds];
        
        for(Case c : caseList) {
            if(c.Is_Checked_For_Delete__c)
            {
                caseListToBeDeleted.add(c.Id);
                System.debug(caseListToBeDeleted);
            }
            else
            {
                caseIdSet.add(c.Id);
            }
        }
        if(!caseListToBeDeleted.isEmpty())
        {
            deleteInFuture(caseListToBeDeleted);
        }
        List<Case> updateCaseList = new List<Case>();
        
        If(!caseIdSet.isEmpty()){
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.AssignmentRuleHeader.useDefaultRule = true;
            dmo.EmailHeader.triggerAutoResponseEmail = true;
          
            for(Case c : [SELECT Id FROM Case WHERE Id IN: caseIdSet]) {
                c.setOptions(dmo);
                updateCaseList.add(c);
                update updateCaseList;
            }
        }
    }
    
    @future
    private static void deleteInFuture(set<id> caseIds) {
        List<Case> caseList = [SELECT Id, Is_Checked_For_Delete__c FROM Case WHERE Id IN: caseIds];
        
        if(!caseList.isEmpty())
        {
            delete caseList;
        }
    } 
    
    private void associateCasesProperly(List<Case> lstCases, Map<Id, Case> oldCaseMap) {
        
        Set<String> setCaseSuppliedEmails = new Set<String>();
        List<Case> lstCaseToUpdate = new List<Case>();
        Map<String, Id> mapEmailToContactId = new Map<String, Id>();
        Map<Id, Id> mapContactIdToAccountId = new Map<Id, Id>();
        
        for(Case objCase : lstCases) {
            
            if(Trigger.isInsert && (!string.isBlank(objCase.SuppliedEmail) && ((objCase.ContactId == null) || (objCase.AccountId == null)))) {
                
                setCaseSuppliedEmails.add(objCase.SuppliedEmail);           
            }
        }
        
        if(!setCaseSuppliedEmails.isEmpty()) {
            
            for(Contact objContact : [SELECT Id, AccountId, Email FROM Contact 
                                      WHERE Email != null AND Email IN :setCaseSuppliedEmails                                
                                      ORDER BY Email, CreatedDate ASC]) {
                
                if(!mapEmailToContactId.containsKey(objContact.Email)) {
                    
                    mapEmailToContactId.put(objContact.Email, objContact.Id);
                    mapContactIdToAccountId.put(objContact.Id, objContact.AccountId);
                }   
            }
            
            for(Case objCase : lstCases) {
            
                if(Trigger.isInsert && (!string.isBlank(objCase.SuppliedEmail) && ((objCase.ContactId == null) || (objCase.AccountId == null)))) {
                
                    if(!mapEmailToContactId.keySet().isEmpty() && mapEmailToContactId.get(objCase.SuppliedEmail) != null) {
                        
                        if(objCase.ContactId != null) {
                        
                            objCase.AccountId = mapContactIdToAccountId.get(objCase.ContactId);
                        }
                        else {
                            
                            objCase.ContactId = mapEmailToContactId.get(objCase.SuppliedEmail);
                            
                            objCase.AccountId = mapContactIdToAccountId.get(mapEmailToContactId.get(objCase.SuppliedEmail));
                        }
                    }
                    else {
                        
                        objCase.Notify_DoubleClick_Support__c = true;
                    }   
                }               
            }
        }
    }

    private void filterEmailToCaseTraffic(List<Case> caseListToBeFiltered)
    {
        List<User> userList = [SELECT Id, Email, Contact.Email FROM User WHERE Authorized_DFP_Case_Creator__c = true];
        Id caseRecordTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get('DoubleClick for Salesforce').RecordTypeId;
        Boolean addToIgnoreList;
        for(Case caseRec : caseListToBeFiltered)
        {
            if(caseRec.RecordTypeId == caseRecordTypeId && caseRec.Origin == 'Email')
            {
                addToIgnoreList = true;
                for(User thisUser : userList)
                {
                    if(caseRec.SuppliedEmail == thisUser.Email || caseRec.SuppliedEmail == thisUser.Contact.Email)
                    {
                        addToIgnoreList = false;
                    }
                }
                if((caseRec.Subject).contains('10K Case number') || caseRec.SuppliedEmail == 'noreply@salesforce.com')
                {
                    addToIgnoreList = true;
                }
                if(addToIgnoreList)
                {
                    caseRec.Is_Checked_For_Delete__c = true;
                }
            }
        }
    }
}