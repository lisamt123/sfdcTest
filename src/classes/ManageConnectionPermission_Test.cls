@isTest
private class ManageConnectionPermission_Test {
	
	@testSetup static void setupData() {
		Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
                                                            'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                            'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
                                                            null, 'Net 30', 'test@test.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
                                                            1);
        insert accList;
        
        List<Contact> contactList           = TestDataFactory_Contacts.generatecontacts(accList, 'Test contact', 'lastName', '', '', 1);
        insert contactList;

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

        List<Project__c> projectList = TestDataFactory_Projects.generateProjects(accList[0].Id, 'Test Project', 1);
        insert projectList;

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

        List<Connection__c> connectionList = TestDataFactory_Connections.generateConnections(Constants.RECORDTYPEID_CONNECTION_PRODICTION, projectList[0].Id, 'Active', null, 1);
        connectionList[0].Status__c = 'Active';
        connectionList[0].Primary_Development_Environment__c = true;
        connectionList[0].Created_On_Heroku__c = true;
        insert connectionList;

    }

	@isTest static void test_method_one() {
		List<Project__c> projectList = [Select Id from Project__c limit 1];
		Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
		Test.startTest();
			List<ManageConnectionPermissionController.ConnectionWrapper> connectionWrapperlist = ManageConnectionPermissionController.getProjectConnectionList(projectList[0].Id, null);
			System.assertEquals(1, connectionWrapperlist.size());
		Test.stopTest();

	}
	
	@isTest static void test_method_two() {
		List<Project__c> projectList = [Select Id from Project__c limit 1];
		List<Connection__c> connectionList = [Select Id from Connection__c where Project__c =: projectList[0].Id];
		Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
		Test.startTest();
			List<ManageConnectionPermissionController.ConnectionWrapper> connectionWrapperlist = ManageConnectionPermissionController.getProjectConnectionList(projectList[0].Id, connectionList[0].Id);
			System.assertEquals(1, connectionWrapperlist.size());
		Test.stopTest();
	}

	@isTest static void test_method_three() {
		List<Project__c> projectList = [Select Id from Project__c limit 1];
		List<Connection__c> connectionList = [Select Id,RecordTypeId from Connection__c where Project__c =: projectList[0].Id];
		List<Assignment__c> assignmentList = [Select Id from Assignment__c where Project__c =: projectList[0].Id];
		RecordType recType = [SELECT Id, Name FROM RecordType WHERE Id =: connectionList[0].RecordTypeId] ;
		List<ManageConnectionPermissionController.ConnectionWrapper> connWrapperList = new List<ManageConnectionPermissionController.ConnectionWrapper>();
		List<ManageConnectionPermissionController.AssignmentWrapper> assignmentWrapperList = new List<ManageConnectionPermissionController.AssignmentWrapper>();
		ManageConnectionPermissionController.AssignmentWrapper wrapperObj = new ManageConnectionPermissionController.AssignmentWrapper();
		wrapperObj.assignment = assignmentList[0];
		wrapperObj.validateReleaseTo = true ;
		wrapperObj.deployReleaseTo = true ;
		assignmentWrapperList.add(wrapperObj);
		ManageConnectionPermissionController.ConnectionWrapper connWrapper = new ManageConnectionPermissionController.ConnectionWrapper(connectionList[0],recType.Name,assignmentWrapperList);
		connWrapperList.add(connWrapper);
		String wrapperString = JSON.serialize(connWrapperList);
		Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
		Test.startTest();
			String message = ManageConnectionPermissionController.saveConnectionPermissions(projectList[0].Id, wrapperString);
			System.assertEquals('Permission successfully added to Project.',message);
		Test.stopTest();
	}

	@isTest static void test_method_four() {
		List<Project__c> projectList = [Select Id from Project__c limit 1];
		List<Connection__c> connectionList = [Select Id,RecordTypeId from Connection__c where Project__c =: projectList[0].Id];
		Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
		Test.startTest();
			ManageConnectionPermissionController.ConnectionWrapper connWrapper = ManageConnectionPermissionController.getConnectionAssignments(connectionList[0].Id);
			System.assertEquals(1,connWrapper.assignmentwrapperList.size());
		Test.stopTest();	
	}

	@isTest static void test_method_five() {
		List<Project__c> projectList = [Select Id from Project__c limit 1];
		List<Connection__c> connectionList = [Select Id,RecordTypeId from Connection__c where Project__c =: projectList[0].Id];
		List<Assignment__c> assignmentList = [Select Id from Assignment__c where Project__c =: projectList[0].Id];
		Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
		List<ManageConnectionPermissionController.AssignmentWrapper> assignmentWrapperList = new List<ManageConnectionPermissionController.AssignmentWrapper>();
		ManageConnectionPermissionController.AssignmentWrapper wrapperObj = new ManageConnectionPermissionController.AssignmentWrapper();
		wrapperObj.assignment = assignmentList[0];
		wrapperObj.validateReleaseTo = true ;
		wrapperObj.deployReleaseTo = true;
		assignmentWrapperList.add(wrapperObj);
		String wrapperString = JSON.serialize(assignmentWrapperList);
		Test.startTest();
			String message = ManageConnectionPermissionController.saveConnectionWisePermissions(connectionList[0].Id, wrapperString);
			System.assertEquals('Permission successfully added to Connection.',message);
		Test.stopTest(); 
	}
	
}