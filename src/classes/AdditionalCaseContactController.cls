public with sharing class AdditionalCaseContactController 
{
	@AuraEnabled
    public static Case retriveCase(String caseIdValue)
    {
        String caseId = caseIdValue;
        return [SELECT Id, AccountId, Additional_Case_Contact_1__c, Additional_Case_Contact_1__r.Name, Additional_Case_Contact_2__c, Additional_Case_Contact_2__r.Name, 
        		Additional_Case_Contact_3__c, Additional_Case_Contact_3__r.Name, Additional_Case_Contact_4__c, Additional_Case_Contact_4__r.Name, Additional_Case_Contact_5__c, Additional_Case_Contact_5__r.Name 
        			FROM Case 
        			WHERE Id =: caseId];
        
    }

	@AuraEnabled
    public static Case updateAdditionalCaseContacts(Case caseRec)
    {
        Case caseObj = new Case();
        System.debug(caseObj);
        caseObj = (Case)caseRec;
        update caseObj;
        return [SELECT Id, AccountId, Additional_Case_Contact_1__c, Additional_Case_Contact_1__r.Name, Additional_Case_Contact_2__c, Additional_Case_Contact_2__r.Name, 
        		Additional_Case_Contact_3__c, Additional_Case_Contact_3__r.Name, Additional_Case_Contact_4__c, Additional_Case_Contact_4__r.Name, Additional_Case_Contact_5__c, Additional_Case_Contact_5__r.Name 
        			FROM Case 
        			WHERE Id =: caseObj.Id];
    }
}