@isTest
public class ManageDateController_Test	{
	 static testMethod void test_method_one() {
		Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
		List<Account> accountList    = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test Account', 'Prospect', 15, 
		                                                                    'code coverage', 'internal', 'App Cloud;Sales Cloud', 'Enterprise', 
		                                                                    'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
		                                                                    'code quality with code coverage above 75%', 'NDA aggrement', 'United States', 
		                                                                    '501 test street', 'test city', 'Florida', '90001', null, null, 'Net 30', 
		                                                                    'acc@testemail.com', 'TestA', 'HELLO WORLD', 'invoicingNotes', 
		                                                                    'Partner Client', 1);
		insert accountList;

		List<Contact> contactList           = TestDataFactory_Contacts.generatecontacts(accountList, 'Contact firstName', 'Contact lastName', 'contact@testemail.com', '', 1);
        insert contactList;
        List<Project__c> projectList        = TestDataFactory_Projects.generateProjects(accountList[0].id, 'Test Project', 2);
        insert projectList;
        List<Agreement__c> agreementList    = TestDataFactory_Agreements.generateAgreements('Test Agreement', accountList[0].id, 
                                                                                         Constants.RECORDTYPEID_AGREEMENT_RETAINER, 
                                                                                         'Active', 
                                                                                         Date.newInstance(System.Today().Year(), System.Today().Month() - 1, 1), 
                                                                                         Date.newInstance(System.Today().Year() + 1, System.Today().Month() - 1, 1), 
                                                                                         2);

        insert agreementList;
        List<Rate__c> rateList              = TestDataFactory_Rates.generateRateForAgreement(agreementList[0].id, 
                                                                                'Time & Materials', 
                                                                                Constants.ROLE_USER_EXPERIENCE, 4, 2);
        rateList[1].Assignment_Type__c      = 'Named Resource';
        rateList[1].RecordTypeId            = Constants.RECORDTYPEID_RATE_NAMED_RESOURCE;
        rateList[1].Role__c                 = Constants.ROLE_DEVELOPER;
        insert rateList;
        List<Project_Agreement__c> projectAgreementList = TestDataFactory_ProjectAgreements.generateProjectAgreements(projectList[0].Id, agreementList[0].Id,1);
        insert projectAgreementList;
        List<Assignment__c> assignmentList  = TestDataFactory_Assignments.generateAssignments(projectList[0].Id, contactList[0].Id, 
                                                                                             rateList[0].Id, Constants.ASSIGNMENT_STATUS_ACTIVE, Constants.ROLE_DEVELOPER, 
                                                                                             Constants.ASSIGNMENTTYPE_NAMEDRESOURCE, true, 
                                                                                             100, 2);
        assignmentList[1].Start_Date__c     = assignmentList[1].Start_Date__c.addYears(1).addDays(7);
        assignmentList[1].End_Date__c       = assignmentList[1].End_Date__c.addYears(1).addDays(7);
        assignmentList[1].Cost_Rate__c      = rateList[1].Id;
        assignmentList[0].Cost_Rate__c      = rateList[0].Id;
        insert assignmentList;

        List<ManageDateController.ProjectWrapper> projectWrapper = new List<ManageDateController.ProjectWrapper>();
        projectWrapper.add(new ManageDateController.ProjectWrapper(projectList[0],true,System.today(),System.today().addDays(5)));
        List<ManageDateController.AssignmentWrapper> assignmentWrapper = new List<ManageDateController.AssignmentWrapper>();
        assignmentWrapper.add(new ManageDateController.AssignmentWrapper(assignmentList[0],false,System.today(),System.today().addDays(5)));
        
        Test.startTest();
            ManageDateController.getProjectWrapper(projectList[0].Id);
            ManageDateController.getAssignWrapper(projectList[0].Id);
            ManageDateController.updateProjectAssign(JSON.serialize(projectWrapper),JSON.serialize(assignmentWrapper));
        Test.stopTest();
    }




}