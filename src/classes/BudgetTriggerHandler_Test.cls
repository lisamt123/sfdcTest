@isTest
public with sharing class BudgetTriggerHandler_Test {
    
            
    @isTest static void test_method_one() {
        Test.startTest();
            Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
            List<Account> accountList    = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test Account', 'Prospect', 15, 
                                                                                    'code coverage', 'internal', 'App Cloud;Sales Cloud', 'Enterprise', 
                                                                                    'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                                                    'code quality with code coverage above 75%', 'NDA aggrement', 'United States', 
                                                                                    '501 test street', 'test city', 'Florida', '90001', null, null, 'Net 30', 
                                                                                    'acc@testemail.com', 'TestA', 'HELLO WORLD', 'invoicingNotes', 
                                                                                    'Partner Client', 1);
            
            insert accountList;
            List<Contact> contactList = TestDataFactory_Contacts.generatecontacts(accountList, 'Contact firstName', 'Contact lastName', 'contact@testemail.com', '', 5);
            insert contactList;
            List<Project__c> projectList = TestDataFactory_Projects.generateProjects(accountList[0].Id, 'Test Project', 5);
            insert projectList;
            List<Agreement__c> agreementList = TestDataFactory_Agreements.generateAgreements('Test Agreement', accountList[0].id, 
                                                                                             Constants.RECORDTYPEID_AGREEMENT_RETAINER, 
                                                                                             'Active', 
                                                                                             Date.newInstance(System.Today().Year(), System.Today().Month() - 1, 1), 
                                                                                             Date.newInstance(System.Today().Year() + 1, System.Today().Month() - 1, 1), 
                                                                                             1);

            insert agreementList;

            List<Rate__c> rateList = TestDataFactory_Rates.generateRateForAgreement(agreementList[0].id, 'Time & Materials', 
                                                                                    Constants.ROLE_USER_EXPERIENCE, 4, 1);
            insert rateList;

            List<Assignment__c> assignmentList = TestDataFactory_Assignments.generateAssignments(projectList[0].Id, contactList[0].Id, 
                                                                                                 rateList[0].Id, Constants.ASSIGNMENT_STATUS_ACTIVE, Constants.ROLE_DEVELOPER, 
                                                                                                 Constants.ASSIGNMENTTYPE_NAMEDRESOURCE, true, 
                                                                                                 100, 1);
            insert assignmentList;

            List<Time_Entry__c> timeEntryList = TestDataFactory_TimeEntries.generateTimeEntries(assignmentList[0].Id, 'Test time description', date.Today(), 4, 1);
            insert timeEntryList;

        Test.stopTest();
    }
}