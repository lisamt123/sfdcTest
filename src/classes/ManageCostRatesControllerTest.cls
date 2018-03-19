@isTest
private class ManageCostRatesControllerTest 
{
	
	@isTest static void test_ManageCostRatesController() 
	{
        Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accountList    = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test Account', 'Prospect', 15, 
                                                                                'code coverage', 'internal', 'App Cloud;Sales Cloud', 'Enterprise', 
                                                                                'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                                                'code quality with code coverage above 75%', 'NDA aggrement', 'United States', 
                                                                                '501 test street', 'test city', 'Florida', '90001', null, null, 'Net 30', 
                                                                                'acc@testemail.com', 'TestA', 'HELLO WORLD', 'invoicingNotes', 
                                                                                'Partner Client', 1);
        insert accountList;
        List<Contact> contactList = TestDataFactory_Contacts.generatecontacts(accountList, 'Contact firstName', 'Contact lastName', 'contact@testemail.com', '', 1);
        insert contactList;
        List<Project__c> projectList = TestDataFactory_Projects.generateProjects(accountList[0].id, 'Test Project', 2);
        insert projectList;

        List<Agreement__c> agreementList = TestDataFactory_Agreements.generateAgreements('Test Agreement', accountList[0].id, 
                                                                                         Constants.RECORDTYPEID_AGREEMENT_DELIVERYPARTER, 
                                                                                         'Active', 
                                                                                         Date.newInstance(System.Today().Year(), System.Today().Month() - 1, 1), 
                                                                                         Date.newInstance(System.Today().Year() + 1, System.Today().Month() - 1, 1), 
                                                                                         2);

        insert agreementList;

        List<Rate__c> rateList = TestDataFactory_Rates.generateRateForAgreement(agreementList[0].id, 
                                                                                'Time & Materials', 
                                                                                Constants.ROLE_USER_EXPERIENCE, 4, 2);
       
        rateList[1].Role__c = Constants.ROLE_DEVELOPER;
        insert rateList;
        
        List<Project_Agreement__c> projectAgreementList = TestDataFactory_ProjectAgreements.generateProjectAgreements(projectList[0].Id, agreementList[0].Id, 1);
        insert projectAgreementList;

        List<Assignment__c> assignmentList = TestDataFactory_Assignments.generateAssignments(projectList[0].Id, contactList[0].Id, 
                                                                                             rateList[0].Id, Constants.ASSIGNMENT_STATUS_ACTIVE, Constants.ROLE_DEVELOPER, 
                                                                                             Constants.ASSIGNMENTTYPE_NAMEDRESOURCE, true, 
                                                                                             100, 2);
        assignmentList[0].Cost_Rate__c        = rateList[0].Id;
        assignmentList[1].Cost_Rate__c        = rateList[0].Id;
        assignmentList[1].Start_Date__c       = Date.today().addYears(1).addDays(1);
        assignmentList[1].End_Date__c         = Date.today().addYears(2);
        insert assignmentList;

        pagereference pg=Page.ManageAssignments;
        Test.setCurrentPageReference(pg);
        apexpages.currentpage().getparameters().put('id',assignmentList[0].id);
        ApexPages.StandardController sc = new ApexPages.StandardController(projectList.get(0));

        Test.startTest();
        	ManageCostRatesController mcrc = new ManageCostRatesController(sc);
        	pg=Page.ManageAssignments;
        	Test.setCurrentPageReference(pg);
        	System.currentPageReference().getParameters().put('projectId', projectList[0].Id);
        	System.currentPageReference().getParameters().put('isdtp', 'mn');
        	sc = new ApexPages.StandardController(projectList.get(0));
        	mcrc = new ManageCostRatesController(sc);
        	mcrc.agreementSelected();
        	mcrc.selectedIndex = 1;
        	mcrc.populateRateValue();
        	mcrc.save();
        	assignmentList = new List<Assignment__c>();
	        
            assignmentList = TestDataFactory_Assignments.generateAssignments(projectList[0].Id, contactList[0].Id, rateList[0].Id, 
                                                                                  Constants.ASSIGNMENT_STATUS_ACTIVE, Constants.ROLE_DEVELOPER, 
                                                                                  Constants.ASSIGNMENTTYPE_NAMEDRESOURCE, true, 100, 2);
            for(Assignment__c ass : assignmentList)
	        {
	        	ass.Cost_Rate__c = null;
	        	ass.Status__c = null;
	        }
            assignmentList[0].Start_Date__c       = Date.today().addYears(2).addDays(1);
            assignmentList[0].End_Date__c         = Date.today().addYears(3);
            assignmentList[1].Start_Date__c       = Date.today().addYears(3).addDays(1);
            assignmentList[1].End_Date__c         = Date.today().addYears(4);
	        insert assignmentList;
	        System.assertEquals(mcrc.selectedIndex, 1);
	        mcrc.save();
        	mcrc.cancel();
        Test.stopTest();
	}
}