@isTest
public class AgreementTriggerHandler_Test {

    @isTest
    public static void preventOverlappingAgreementsTest() {
    
        TestDataFactory factory = new TestDataFactory();
        
        List<Account> accountList = factory.generateAccounts(1);
        insert accountList;
        
        List<Agreement__c> agreementList = factory.generateRetainerAgreementsForAccounts(accountList, 2);
        agreementList[0].Effective_Date__c = System.Today().addDays(-5);
        agreementList[0].Valid_Through__c = System.Today().addDays(-1); 
        agreementList[1].Effective_Date__c = System.Today();
        agreementList[1].Valid_Through__c = System.Today().addDays(5); 
        insert agreementList;

        List<Opportunity> oppList =TestDataFactory_Opportunity.generateOpportunities(accountList[0].Id, Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('MSA Opportunity').getRecordTypeId(), 'Qualification', Date.today().addDays(6), Date.today(), Date.today().addDays(4), 1);
        insert oppList ;

        List<Opportunity> oppList_two =TestDataFactory_Opportunity.generateOpportunities(accountList[0].Id, Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Services Opportunity').getRecordTypeId(), 'Qualification', Date.today().addDays(6), Date.today(), Date.today().addDays(4), 1);
        oppList_two[0].MSA_Opportunity__c = oppList[0].Id ;
        insert oppList_two ;

        List<Agreement__c> agreementList_two = TestDataFactory_Agreements.generateAgreements('Test Agreement', accountList[0].Id, Schema.SObjectType.Agreement__c.getRecordTypeInfosByName().get('MSA').getRecordTypeId(), 'Active', Date.today(), Date.today().addDays(6), 1);
        agreementList_two[0].Opportunity__c = oppList[0].Id ;
        insert agreementList_two;

        List<Project__c> projectList = factory.generateProjects(accountList[0].Id, 1);
        insert projectList;
        
        List<Project_Agreement__c> projectAgreementList = new List<Project_Agreement__c>();
        projectAgreementList.add(factory.generateProjectAgreements(projectList[0].Id, agreementList[0].Id));
        projectAgreementList.add(factory.generateProjectAgreements(projectList[0].Id, agreementList[1].Id));
        insert projectAgreementList;

        /*Test.startTest();
        agreementList[0].Effective_Date__c = System.Today();
        agreementList[0].Valid_Through__c = System.Today().addDays(10);
        database.update(agreementList, false);
        Test.stopTest();

        system.assert([SELECT Id, Effective_Date__c FROM Agreement__c WHERE Id =: agreementList[0].Id].Effective_Date__c != system.today()); */
    }

}