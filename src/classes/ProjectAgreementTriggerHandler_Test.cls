@isTest
public class ProjectAgreementTriggerHandler_Test{

    @isTest
    public static void preventOverlappingProjectAgreementsTest() {
    
        TestDataFactory factory = new TestDataFactory();
        
        List<Account> accountList = factory.generateAccounts(1);
        insert accountList;
        
        List<Agreement__c> agreementList = factory.generateRetainerAgreementsForAccounts(accountList, 2);
        agreementList[0].Valid_Through__c = System.Today();
        agreementList[0].Valid_Through__c = System.Today().addDays(10); 
        agreementList[1].Effective_Date__c = System.Today().addDays(2);
        agreementList[1].Valid_Through__c = System.Today().addDays(5); 
        insert agreementList;

        List<Project__c> projectList = factory.generateProjects(accountList[0].Id, 1);
        insert projectList;
        
        List<Project_Agreement__c> projectAgreementList = new List<Project_Agreement__c>();
        projectAgreementList.add(factory.generateProjectAgreements(projectList[0].Id, agreementList[0].Id));
        projectAgreementList.add(factory.generateProjectAgreements(projectList[0].Id, agreementList[0].Id));
        database.insert(projectAgreementList,false);
        
        projectAgreementList.clear();
        projectAgreementList.add(factory.generateProjectAgreements(projectList[0].Id, agreementList[1].Id));
        database.insert(projectAgreementList,false);

        //system.assertEquals([SELECT Id FROM project_agreement__c WHERE project__c =: projectList[0].Id].size(),1);
        
        projectAgreementList.clear();
        projectAgreementList.add(factory.generateProjectAgreements(projectList[0].Id, agreementList[0].Id));
        projectAgreementList.add(factory.generateProjectAgreements(projectList[0].Id, agreementList[1].Id));
        database.insert(projectAgreementList,false);
        
        //system.assertEquals([SELECT Id FROM project_agreement__c WHERE project__c =: projectList[0].Id].size(),1);
    }

}