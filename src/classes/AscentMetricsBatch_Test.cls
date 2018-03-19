/*
    @Description    AscentMetricsBatch tEST Class
    @createdate     11Jan 2018
*/

@isTest
private class AscentMetricsBatch_Test {
    @isTest static void test_method_positive1() {
        Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accountList    = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test Account', 'Prospect', 15, 
                                                                                'code coverage', 'internal', 'App Cloud;Sales Cloud', 'Enterprise', 
                                                                                'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                                                'code quality with code coverage above 75%', 'NDA aggrement', 'United States', 
                                                                                '501 test street', 'test city', 'Florida', '90001', null, null, 'Net 30', 
                                                                                'acc@testemail.com', 'TestA', 'HELLO WORLD', 'invoicingNotes', 
                                                                                'Partner Client', 1);
        accountList[0].current_Tier__c = 'K2';                                                                  
        insert accountList;
        
        List<Agreement__c> agreementList = TestDataFactory_Agreements.generateAgreements('Test Agreement', accountList[0].id, 
                                                                                         Constants.RECORDTYPEID_AGREEMENT_RETAINER, 
                                                                                         'Active', 
                                                                                         Date.newInstance(System.Today().Year(), System.Today().Month() - 1, 1), 
                                                                                         Date.newInstance(System.Today().Year() + 1, System.Today().Month() - 1, 1), 
                                                                                         1);
        agreementList[0].Rate_Structure__c = 'Monthly';
        insert agreementList;
        
        List<Project__c> projectList = TestDataFactory_Projects.generateProjects(accountList[0].id, 'Test Project', 1);
        insert projectList;
        
        List<Project_Agreement__c> projectAgreementList = TestDataFactory_ProjectAgreements.generateProjectAgreements(projectList[0].Id, agreementList[0].Id,1);
        insert projectAgreementList;
        

        agreementList[0].Payment_Terms__c = 'Net 15';
        agreementList[0].RecordTypeId = Constants.RECORDTYPEID_AGREEMENT_DELIVERYPARTER;
        update agreementList;
        
        List<Rate__c> rateList         = TestDataFactory_Rates.generateRateForAgreement(agreementList[0].id, 
                                                                                Constants.ASSIGNMENTTYPE_NAMEDRESOURCE, 
                                                                                Constants.ROLE_CONSULTANT, 4, 1);
        rateList[0].Hours_Per_Month__c = 2;
        rateList[0].Monthly_Rate__c = 2;
        insert rateList;
        
        List<Contact> contactList = TestDataFactory_Contacts.generatecontacts(accountList, 'Contact firstName', 'Contact lastName', 'contact@testemail.com', '', 1);
        insert contactList;
        
        
        List<Assignment__c> assignmentList = TestDataFactory_Assignments.generateAssignments(projectList[0].Id, contactList[0].Id, 
                                                                                             rateList[0].Id, Constants.ASSIGNMENT_STATUS_ACTIVE, Constants.ROLE_CONSULTANT, 
                                                                                             Constants.ASSIGNMENTTYPE_NAMEDRESOURCE, true, 
                                                                                             100, 1);
        assignmentList[0].Billable__c = true;
        assignmentList[0].Cost_Rate__c = rateList[0].Id;
        assignmentList[0].Role__c = Constants.ROLE_CONSULTANT ; 
        insert assignmentList;

        system.debug('ASSIGNMENT !!!! : ' + assignmentList);
        
        List<time_entry__c> timeEntries = TestDataFactory_TimeEntries.generateTimeEntries(assignmentList[0].Id, 
                                                                                          'Test Time Entry', Date.today(), 
                                                                                          5.5, 1);
        
        insert timeEntries;
        
        Test.startTest();
          AscentMetricsBatch invoiceBatch = new AscentMetricsBatch();
                Database.executeBatch(invoiceBatch,1);
        Test.stopTest();
    }
    
    @isTest static void test_method_positive2() {
        Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accountList    = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test Account', 'Prospect', 15, 
                                                                                'code coverage', 'internal', 'App Cloud;Sales Cloud', 'Enterprise', 
                                                                                'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                                                'code quality with code coverage above 75%', 'NDA aggrement', 'United States', 
                                                                                '501 test street', 'test city', 'Florida', '90001', null, null, 'Net 30', 
                                                                                'acc@testemail.com', 'TestA', 'HELLO WORLD', 'invoicingNotes', 
                                                                                'Partner Client', 1);
        accountList[0].current_Tier__c = 'K2';                                                                  
        insert accountList;
        
        List<Agreement__c> agreementList = TestDataFactory_Agreements.generateAgreements('Test Agreement', accountList[0].id, 
                                                                                         Constants.RECORDTYPEID_AGREEMENT_RETAINER, 
                                                                                         'Active', 
                                                                                         Date.newInstance(System.Today().Year(), System.Today().Month() - 1, 1), 
                                                                                         Date.newInstance(System.Today().Year() + 1, System.Today().Month() - 1, 1), 
                                                                                         1);
        agreementList[0].Rate_Structure__c = 'Monthly';
        insert agreementList;
        
        List<Project__c> projectList = TestDataFactory_Projects.generateProjects(accountList[0].id, 'Test Project', 1);
        insert projectList;
        
        List<Project_Agreement__c> projectAgreementList = TestDataFactory_ProjectAgreements.generateProjectAgreements(projectList[0].Id, agreementList[0].Id,1);
        insert projectAgreementList;
        

        agreementList[0].Payment_Terms__c = 'Net 15';
        agreementList[0].RecordTypeId = Constants.RECORDTYPEID_AGREEMENT_DELIVERYPARTER;
        update agreementList;
        
        List<Rate__c> rateList         = TestDataFactory_Rates.generateRateForAgreement(agreementList[0].id, 
                                                                                Constants.ASSIGNMENTTYPE_NAMEDRESOURCE, 
                                                                                Constants.ROLE_CONSULTANT, 4, 1);
        rateList[0].Hours_Per_Month__c = 2;
        rateList[0].Monthly_Rate__c = 2;
        insert rateList;
        
        List<Contact> contactList = TestDataFactory_Contacts.generatecontacts(accountList, 'Contact firstName', 'Contact lastName', 'contact@testemail.com', '', 1);
        insert contactList;
        
        
        List<Assignment__c> assignmentList = TestDataFactory_Assignments.generateAssignments(projectList[0].Id, contactList[0].Id, 
                                                                                             rateList[0].Id, Constants.ASSIGNMENT_STATUS_ACTIVE, Constants.ROLE_CONSULTANT, 
                                                                                             Constants.ASSIGNMENTTYPE_NAMEDRESOURCE, true, 
                                                                                             100, 1);
        assignmentList[0].Billable__c = true;
        assignmentList[0].Cost_Rate__c = rateList[0].Id;
        assignmentList[0].Role__c = Constants.ROLE_CONSULTANT ; 
        insert assignmentList;

        system.debug('ASSIGNMENT !!!! : ' + assignmentList);
        
        Date monthStartDate = Date.newInstance(date.today().year(), date.today().month(), 1);
        Date monthEndDate = Date.newInstance(date.today().year(), date.today().month()+1, 1)-1;
                
        List<Ascent_Metrics__c> ascMetricList = TestDataFactory_AscentMetrics.generateAscMetric(accountList[0].Id,monthStartDate,monthEndDate,0.00, 0.00,1);
        insert ascMetricList ;
        
        List<time_entry__c> timeEntries = TestDataFactory_TimeEntries.generateTimeEntries(assignmentList[0].Id, 
                                                                                          'Test Time Entry', Date.today(), 
                                                                                          5.5, 1);
        
        insert timeEntries;
        Test.startTest();
          AscentMetricsBatch invoiceBatch = new AscentMetricsBatch();
                Database.executeBatch(invoiceBatch,1);
        Test.stopTest();
    }
}