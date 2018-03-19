@isTest
private class UserTriggerHandler_Test {
    
    static testMethod void test_usecase_one() {
    	
    	Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
                                                            'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                            'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
                                                            null, 'Net 30', 'acc@testemail.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
                                                            1);
        insert accList;
        
    	List<Contact> contactList = TestDataFactory_Contacts.generatecontacts(accList, 'Test contact', 'lastName','test1@testemail.com', '', 1);
    	contactList.addAll(TestDataFactory_Contacts.generatecontacts(accList, 'Test contact2', 'lastName','test2@testemail.com', '', 1));
        insert contactList;
        System.assertEquals(2, contactList.size());
        
        Test.startTest();
	    	List<User> userList = TestDataFactory_Users.generateUsers(contactList[0].Id, '10K Services Client (License)', true, 1);
	    	userList.addAll(TestDataFactory_Users.generateUsers(contactList[1].Id, '10K Services Client (License)', true, 1));
	    	insert userList;
    	Test.stopTest();
    	
    	List<User> userResultList = [SELECT Id,Is_Portal_User__c FROM User WHERE IsActive=true AND (ContactId = :contactList[0].Id OR ContactId = :contactList[1].Id)];
    	System.assertEquals(2, userResultList.size());
    	
    	List<Contact> contactResultList = [SELECT Id, Portal_User__c FROM Contact WHERE Portal_User__c = :userResultList[0].Id OR Portal_User__c = :userResultList[1].Id];
    	System.assertEquals(2, userResultList.size());
    }
    
    static testMethod void test_usecase_two() {
    	
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
	    	
	    Test.startTest();
	    	List<User> userList = TestDataFactory_Users.generateUsers(contactList[0].Id, '10K Services Client (License)', true, 1);
		    insert userList;
    	Test.stopTest();
    	
    	List<User> userResultList = [SELECT Id,Is_Portal_User__c FROM User WHERE IsActive=true AND ContactId = :contactList[0].Id];
    	System.assertEquals(1, userResultList.size());
    	
    	List<Contact> contactResultList = [SELECT Id, Portal_User__c FROM Contact WHERE Portal_User__c = :userResultList[0].Id];
    	System.assertEquals(1, userResultList.size());
    	
    	System.runAs(userResultList[0]) {
    		
	    	List<Project__c> projectResultList = [SELECT Id, Recalculate_Sharing_on_Save__c FROM Project__c WHERE Id=:projectList[0].Id];
	        System.assertEquals(1, projectResultList.size());
    	}
    }
    
    static testMethod void test_usecase_three() {
    	
    	Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
                                                            'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                            'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
                                                            null, 'Net 30', 'acc@testemail.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
                                                            1);
        insert accList;
        
    	List<Contact> contactList = TestDataFactory_Contacts.generatecontacts(accList, 'Test contact', 'lastName','test1@testemail.com', '', 1);
        insert contactList;
        System.assertEquals(1, contactList.size());
        
        List<User> userList = TestDataFactory_Users.generateUsers(contactList[0].Id, '10K Services Client (License)', true, 1);
	    insert userList;
	    
	    List<PermissionSet> permissionSetList = [Select Id, Name From PermissionSet WHERE Name = 'Community_Accounts_and_Contacts'];
        System.assertEquals(1, permissionSetList.size());
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        System.RunAs(usr) {
        	
	        Test.startTest();
		        PermissionSetAssignment permissionSetAssign = new PermissionSetAssignment(PermissionSetId = permissionSetList[0].Id, AssigneeId = userList[0].Id);
		        insert permissionSetAssign; 
		        
		        List<Profile> newProfileLi = [Select Id, Name, UserLicenseId, UserLicense.Name FROM Profile WHERE Name = '10K Services Client (Login)'];
		        System.assertEquals(1, newProfileLi.size());
		        //Now update the user
		        userList[0].ProfileId = newProfileLi[0].Id;
		        update userList;
		        System.assertEquals(newProfileLi[0].Id, userList[0].ProfileId);
	    	Test.stopTest();
        }
    }
    
    static testMethod void test_usecase_four() {
    	
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
	    
	    List<User> userList = TestDataFactory_Users.generateUsers(contactList[0].Id, '10K Services Client (License)', true, 1);
	    insert userList;
	    	
	    Test.startTest();	    	
		    System.enqueueJob(new RecalculateSharingController(new set<Id>{projectList[0].id},new set<Id>{assignmentList[0].id} ,new set<Id>(), new set<Id>{preqList[0].Id} ));
        	System.enqueueJob(new SyncPortalUserToContactController(new set<Id>{userList[0].id}));
        	
        	List<Contact> contactResultList = [SELECT Id FROM Contact WHERE Id=:contactList[0].Id AND Portal_User__c=:userList[0].Id];
        	System.assertEquals(1, contactResultList.size());
    	Test.stopTest();
    }
    
    static testMethod void test_usecase_five() {
    	
    	List<User> userList = TestDataFactory_Users.generateUsersWith10KCustomerProfile(true, 5);
	    insert userList;
	    System.assertEquals(5, userList.size());
    }

    static testMethod void test_usecase_six() {
        
        List<User> userList2 = TestDataFactory_Users.generateUsersWith10KDeliveryPartnerProfile(true, 5);
        insert userList2;
        System.assertEquals(5, userList2.size());
    }
}