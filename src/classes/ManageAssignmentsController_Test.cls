@isTest
public class ManageAssignmentsController_Test{

    @isTest
    public static void ManageAssignmentsTest(){
         
        Id partnerClientrecordTypeId        = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList               = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
                                             'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                             'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
                                             null, 'Net 30', 'test@test.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
                                             1);
        insert accList;
        
        List<Contact> contactList           = TestDataFactory_Contacts.generatecontacts(accList, 'Test contact', 'lastName', '', '', 1);
        insert contactList;
        
         List<Project__c> projectList       = TestDataFactory_Projects.generateProjects(accList[0].Id, 'Test Project', 2);
         insert projectList;
        
        List<Agreement__c> agreementList    = TestDataFactory_Agreements.generateAgreements('Test Agreement 1', accList[0].Id, Constants.RECORDTYPEID_AGREEMENT_RETAINER, 'Active', Date.newInstance(System.Today().Year(), System.Today().Month() - 1, 1), Date.newInstance(System.Today().Year() + 1, System.Today().Month() - 1, 1) , 2);
         agreementList[0].Rate_Structure__c = 'Monthly';
         agreementList[1].Rate_Structure__c = 'Monthly';
         agreementList[0].Status__c         = 'Active';
         agreementList[1].Status__c         = 'Active';
         insert agreementList;

        List<Rate__c> rateList              = new List<Rate__c>();
        rateList.addAll(TestDataFactory_Rates.generateRateForAgreement(agreementList[0].id, Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS, Constants.ROLE_CONSULTANT, 100, 1));
        rateList.addAll(TestDataFactory_Rates.generateRateForAgreement(agreementList[0].id, Constants.ASSIGNMENTTYPE_NAMEDRESOURCE, Constants.ROLE_DEVELOPER, 100, 1));
        insert rateList;

        List<Project_Agreement__c> projectAggerementList = TestDataFactory_ProjectAgreements.generateProjectAgreements(projectList[0].Id, agreementList[0].Id,1);
        insert projectAggerementList;
        
        List<Assignment__c> assignmentList  = new List<Assignment__c>();
        assignmentList.addAll(TestDataFactory_Assignments.generateAssignments(projectList[0].Id, contactList[0].Id, rateList[0].Id, 
                                                                              Constants.ASSIGNMENT_STATUS_ACTIVE, Constants.ROLE_DEVELOPER, 
                                                                              Constants.ASSIGNMENTTYPE_NAMEDRESOURCE, true, 100, 1));
        assignmentList.addAll(TestDataFactory_Assignments.generateAssignments(projectList[0].Id, contactList[0].Id, rateList[0].Id, 
                                                                              Constants.ASSIGNMENT_STATUS_ACTIVE, Constants.ROLE_DEVELOPER, 
                                                                              Constants.ASSIGNMENTTYPE_NAMEDRESOURCE, true, 100, 1));
        assignmentList[0].Start_Date__c     = Date.today().addYears(1);
        assignmentList[0].End_Date__c       = Date.today().addYears(2);
        assignmentList[1].Start_Date__c     = Date.today().addYears(3);
        assignmentList[1].End_Date__c       = Date.today().addYears(4);
        insert assignmentList;

        Test.startTest();
            pagereference pg                = Page.ManageAssignments;
            Test.setCurrentPageReference(pg);
            apexpages.currentpage().getparameters().put('id',assignmentList[0].id);
            ApexPages.StandardController sc     = new ApexPages.StandardController(projectList.get(0));
            ManageAssignmentsController cntrlr  = new ManageAssignmentsController(sc);
            
            
            pg=Page.ManageAssignments;
            Test.setCurrentPageReference(pg);
            apexpages.currentpage().getparameters().put('projectId',projectList[0].id);
            
            sc      = new ApexPages.StandardController(projectList.get(0));
            cntrlr  = new ManageAssignmentsController(sc);
            
            cntrlr.save();
            cntrlr.cancel();
             
            cntrlr.selectedIndex = 1;  
            cntrlr.populateRateValue();
            cntrlr.agreementSelected();
            cntrlr.selectedIndex = 3;  
            cntrlr.resourceSelected();
            
            cntrlr.agreementSelected();
            system.assertEquals(cntrlr.assignmentWrapperList.size(), 4);
               
            cntrlr.selectedIndex = null;  
            cntrlr.flag = true;
            cntrlr.assignmentWrapperList[1].selectedRole =  Constants.ROLE_DEVELOPER;
            cntrlr.populateRateValue();
            
            cntrlr.selectedIndex = 3; 
            cntrlr.deleteRow();
            system.assertEquals(cntrlr.AssignmentWrapperList.size(),3);
            
            cntrlr.assignmentWrapperList[0].assignmentObj.assignment_type__c    = Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS;
            cntrlr.assignmentWrapperList[0].assignmentObj.status__c             = 'Active';
            cntrlr.assignmentWrapperList[1].assignmentObj.assignment_type__c    =  Constants.ASSIGNMENTTYPE_NAMEDRESOURCE;
            cntrlr.assignmentWrapperList[1].assignmentObj.status__c             = 'Active';       
            cntrlr.save();
            
            system.assert([select id from assignment__c where project__c        = :projectList[0].id].size()==2);
            
            cntrlr.selectedIndex = 1;
            cntrlr.deleteRow();
            cntrlr.save();
            
            system.assertEquals([select id from assignment__c where project__c        = :projectList[0].id].size(),2);
        Test.stopTest();
    }
}