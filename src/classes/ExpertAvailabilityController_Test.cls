@isTest
private class ExpertAvailabilityController_Test {
	
	@isTest static void test_method_one() {
		Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
                                                            'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                            'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
                                                            null, 'Net 30', 'acc@testemail.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
                                                            1);
        insert accList;
        
    	List<Contact> contactList = TestDataFactory_Contacts.generatecontacts(accList, 'Test contact', 'lastName','test1@testemail.com', '', 1);
        insert contactList;
	    	
    	List<Project__c> projectList = TestDataFactory_Projects.generateProjects(accList[0].Id, 'Test Project', 1);
        insert projectList;
        
        List<Agreement__c> agreementList = TestDataFactory_Agreements.generateAgreements('Test Agreement 1', accList[0].Id, Constants.RECORDTYPEID_AGREEMENT_RETAINER, 'Active', Date.newInstance(System.Today().Year(), System.Today().Month() - 1, 1), Date.newInstance(System.Today().Year() + 1, System.Today().Month() - 1, 1) , 1);
        insert agreementList;
        
        List<Rate__c> rateList = TestDataFactory_Rates.generateRateForAgreement(agreementList[0].id, Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS, Constants.ROLE_CONSULTANT, 100, 1);
        insert rateList;
        
        List<Assignment__c> assignmentList = TestDataFactory_Assignments.generateAssignments(projectList[0].Id, contactList[0].Id, rateList[0].Id, 'Active', 'Developer', 'Named Resource', true, 250, 1);
        insert assignmentList;
        
        List<Project_Request__c> preqList = TestDataFactory_WorkRequests.generateWorkRequests('Test', accList[0].Id, Date.today().addDays(50), null, projectList[0].Id, false, contactList[0].Id, Date.today().addDays(10), 'New', null, 'Project Request', 1);
        insert preqList;
	    	
    	List<User> userList = TestDataFactory_Users.generateUsers(contactList[0].Id, '10K Delivery Partner (License)', true, 1);
	    insert userList;

	    Test.startTest();
	    	System.runAs(userList[0]) {
	    		ExpertAvailabilityController.retrieveAvailability('',null,null);
	    		ExpertAvailabilityController.retrieveAvailability('next',null,null);
	    		ExpertAvailabilityController.retrieveAvailability('previous',null,null);
                List<Availability__c> availabilityList = [SELECT Id, Week__r.Week_Starts_On__c FROM Availability__c LIMIT 1];
                System.assertEquals(availabilityList.size(),1);
                AvailableHoursAvailibilityController.retrieveAvailability(availabilityList[0]);
                AvailableHoursAvailibilityController.retrieveIsDisabled(availabilityList[0]);
	    	}
	    Test.stopTest();
	}
}