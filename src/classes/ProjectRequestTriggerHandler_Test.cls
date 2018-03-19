@isTest
private class ProjectRequestTriggerHandler_Test {

    static testMethod void test_method_one() {
	
		TestDataFactory objTestDataFactory = new TestDataFactory();
		Test.startTest();
        List<Account> lstAccounts = objTestDataFactory.generateAccounts(1);
        insert lstAccounts;
        
        List<Contact> lstContacts = objTestDataFactory.generateContactsForAccounts(lstAccounts, 1);
        lstContacts[0].Email = 'testEmail@test.com';
        insert lstContacts;        
        
        List<Project_Request__c> lstProjectRequests = new List<Project_Request__c>();
        
       

        Project_Request__c objProjectRequest1 = objTestDataFactory.generateProjectRequestRecord(lstAccounts[0].Id, 'New', lstContacts[0].Id, 'TestProjectWithNewStatus', system.today());
    	objProjectRequest1.Name = 'test1';
    	objProjectRequest1.Start_Date__c = system.today();
    	lstProjectRequests.add(objProjectRequest1);
    	
    	Project_Request__c objProjectRequest2 = objTestDataFactory.generateProjectRequestRecord(lstAccounts[0].Id, 'Resource Plan Complete', lstContacts[0].Id, 'TestProjectWithUReviewStatus', system.today());
    	objProjectRequest2.Start_Date__c = system.today();
    	objProjectRequest2.Name = 'test1';
    	lstProjectRequests.add(objProjectRequest2);
    	
    	Project_Request__c objProjectRequest3 = objTestDataFactory.generateProjectRequestRecord(lstAccounts[0].Id, 'Ready for Staffing', lstContacts[0].Id, 'TestProjectWithPContractStatus', system.today());
    	objProjectRequest3.Start_Date__c = system.today();
    	objProjectRequest3.Name = 'test1';
    	lstProjectRequests.add(objProjectRequest3);
    	
    	Project_Request__c objProjectRequest4 = objTestDataFactory.generateProjectRequestRecord(lstAccounts[0].Id, 'Completed', lstContacts[0].Id, 'TestProjectWithCFullStatus', system.today());
    	
    	objProjectRequest4.Start_Date__c = system.today();
    	objProjectRequest4.Name = 'test1';
    	lstProjectRequests.add(objProjectRequest4);
    	
    	Project_Request__c objProjectRequest5 = objTestDataFactory.generateProjectRequestRecord(lstAccounts[0].Id, 'Canceled ', lstContacts[0].Id, 'TestProjectWithCUnFullStatus', system.today());
    	
    	objProjectRequest5.Start_Date__c = system.today();
    	objProjectRequest5.Name = 'test1';
    	lstProjectRequests.add(objProjectRequest5);
    	
    	/*Project_Request__c objProjectRequest6 = objTestDataFactory.generateProjectRequestRecord(lstAccounts[0].Id, 'Closed', lstContacts[0].Id, 'TestProjectWithCPartFullStatus', system.today());
    	objProjectRequest6.Status_Detail__c = 'Partially Fulfilled';
    	objProjectRequest6.Start_Date__c = system.today();
    	lstProjectRequests.add(objProjectRequest6); 
    	
    	Project_Request__c objProjectRequest7 = objTestDataFactory.generateProjectRequestRecord(lstAccounts[0].Id, 'New', lstContacts[0].Id, 'TestProjectWithNewStatus', system.today());
    	objProjectRequest7.Start_Date__c = system.today();
    	lstProjectRequests.add(objProjectRequest7);*/
    	
    	insert lstProjectRequests;
    	Test.stopTest();
    	
    /*	List<Project_Request__c> lstProjectRequestRecord = [Select Id, Opportunity__c, Project__c, Opportunity__r.Name, Opportunity__r.CloseDate, Opportunity__r.Amount, Opportunity__r.StageName, Opportunity__r.AccountId From Project_Request__c Where Id = :lstProjectRequests[0].Id];
    	system.assertEquals(lstProjectRequestRecord[0].Opportunity__r.CloseDate, system.today().addDays(14));
    	system.assertEquals(lstProjectRequestRecord[0].Opportunity__r.Amount, 0.0);
    	system.assertEquals(lstProjectRequestRecord[0].Opportunity__r.StageName, 'Qualification');
    	system.assertEquals(lstProjectRequestRecord[0].Opportunity__r.AccountId, lstAccounts[0].Id);
    	system.assertEquals(lstProjectRequestRecord[0].Opportunity__r.Name, lstAccounts[0].Name+' - '+lstProjectRequests[0].Project_Name__c);
    	system.assertEquals(lstProjectRequestRecord[0].Project__c, null);
    	
    	List<Project_Request__c> lstProjectRequestRecord1 = [Select Id, Opportunity__c, Project__c, Project__r.Name, Project__r.Account__c, Project__r.Status__c, Project__r.Opportunity__c, Opportunity__r.Name, Opportunity__r.CloseDate, Opportunity__r.Amount, Opportunity__r.StageName, Opportunity__r.AccountId From Project_Request__c Where Id = :lstProjectRequests[3].Id];
    	
    	system.assertEquals(lstProjectRequestRecord1[0].Opportunity__r.CloseDate, system.today().addDays(14));
    	system.assertEquals(lstProjectRequestRecord1[0].Opportunity__r.Amount, 0.0);
    	system.assertEquals(lstProjectRequestRecord1[0].Opportunity__r.StageName, 'Closed Won');
    	system.assertEquals(lstProjectRequestRecord1[0].Opportunity__r.AccountId, lstAccounts[0].Id);
    	system.assertNotEquals(lstProjectRequestRecord1[0].Project__c, null);
    	system.assertEquals(lstProjectRequestRecord1[0].Project__r.Name, lstAccounts[0].Name+' - '+lstProjectRequests[3].Project_Name__c);
    	system.assertEquals(lstProjectRequestRecord1[0].Project__r.Account__c, lstAccounts[0].Id);
    	system.assertEquals(lstProjectRequestRecord1[0].Project__r.Status__c, 'Projected');
    	system.assertNotEquals(lstProjectRequestRecord1[0].Project__r.Opportunity__c, null);
    	
    	List<Project_Request__c> lstProjectRequestRecord2 = [Select Id, Opportunity__c, Project__c, Project__r.Name, Project__r.Account__c, Project__r.Status__c, Project__r.Opportunity__c, Opportunity__r.Name, Opportunity__r.CloseDate, Opportunity__r.Amount, Opportunity__r.StageName, Opportunity__r.AccountId From Project_Request__c Where Id = :lstProjectRequests[6].Id];
    	
    	system.assertEquals(lstProjectRequestRecord2[0].Opportunity__r.CloseDate, system.today().addDays(14));
    	system.assertEquals(lstProjectRequestRecord2[0].Opportunity__r.Amount, 0.0);
    	system.assertEquals(lstProjectRequestRecord2[0].Opportunity__r.StageName, 'Qualification');
    	system.assertEquals(lstProjectRequestRecord2[0].Opportunity__r.AccountId, lstAccounts[0].Id);
    
    	lstProjectRequests[6].Status__c = 'Under Review';
    	update lstProjectRequests;
    	
    	List<Project_Request__c> lstProjectRequestRecord3 = [Select Id, Opportunity__c, Project__c, Project__r.Name, Project__r.Account__c, Project__r.Status__c, Project__r.Opportunity__c, Opportunity__r.Name, Opportunity__r.CloseDate, Opportunity__r.Amount, Opportunity__r.StageName, Opportunity__r.AccountId From Project_Request__c Where Id = :lstProjectRequests[6].Id];
    	
    	system.assertEquals(lstProjectRequestRecord3[0].Opportunity__r.CloseDate, system.today().addDays(14));
    	system.assertEquals(lstProjectRequestRecord3[0].Opportunity__r.Amount, 0.0);
    	system.assertEquals(lstProjectRequestRecord3[0].Opportunity__r.StageName, 'Needs Analysis');
    	system.assertEquals(lstProjectRequestRecord3[0].Opportunity__r.AccountId, lstAccounts[0].Id);*/
    }
    
    static testMethod void test_method_two() {
	
		TestDataFactory objTestDataFactory = new TestDataFactory();
		
        Test.startTest();
        //Generate a new Community User, and create an Account and Contact for that person as well
		List<User> userList = objTestDataFactory.createUsersWith10KCustomerProfile(1);
		insert userList;

		//Fetch the Contact that is associated with our Community Contact that was inserted
		List<Contact> contactList = [SELECT Id, AccountId 
									 FROM Contact 
									 WHERE Id =: userList[0].ContactId];
									 
	 	contactList[0].Email = 'testEmail@test.com';
	 	update contactList;
	 	
		system.assertEquals(contactList.size(), 1);

		//Before we start, verify that there are no Project_Request__Share records
		List<Project_Request__Share> projectRequestShares = [SELECT Id, AccessLevel, ParentId, RowCause, UserOrGroupId 
											 		  		 FROM Project_Request__Share
                                              		  		 WHERE RowCause = 'Customer__c'];
        system.assertEquals(projectRequestShares.size(), 0);
    	
    	List<Project_Request__c> lstProjectRequests = new List<Project_Request__c>();
        
        Project_Request__c objProjectRequest1 = objTestDataFactory.generateProjectRequestRecord(contactList[0].AccountId, 'New', contactList[0].Id, 'TestProjectWithNewStatus', system.today());
    	objProjectRequest1.Account__c = contactList[0].AccountId;
    	objProjectRequest1.Start_Date__c = system.today();
    	objProjectRequest1.Name = 'test1';
    	lstProjectRequests.add(objProjectRequest1);
    	
    	insert lstProjectRequests;
    	
    	//Verify the Project_Request__Share records were written correctly
		projectRequestShares = [SELECT Id, AccessLevel, ParentId, RowCause, UserOrGroupId 
						 		FROM Project_Request__Share
                         		WHERE RowCause = 'Customer__c'];

        system.assertEquals(projectRequestShares.size(), 2);
		system.assertEquals(projectRequestShares[0].ParentId, lstProjectRequests[0].Id);

		Test.stopTest();
    }
    
    /*static testMethod void test_method_three() {
		
		TestDataFactory objTestDataFactory = new TestDataFactory();
		
		List<User> userList = objTestDataFactory.createUsersWith10KCustomerProfile(2);
		insert userList;

		Set<Id> contactIdSet = new Set<Id>();
		for(User u : userList) {
			contactIdSet.add(u.ContactId);
		}

		//Fetch the Contact that is associated with our Community Contact that was inserted
		List<Contact> contactList = [SELECT Id, AccountId 
									 FROM Contact 
									 WHERE Id In: contactIdSet];

		List<Project_Request__c> lstProjectRequests = new List<Project_Request__c>();
        
        Project_Request__c objProjectRequest1 = objTestDataFactory.generateProjectRequestRecord(contactList[0].AccountId, 'New', contactList[0].Id, 'TestProjectWithNewStatus', system.today());
    	objProjectRequest1.Account__c = contactList[0].AccountId;
    	objProjectRequest1.Start_Date__c = system.today();
    	lstProjectRequests.add(objProjectRequest1);
    	
    	insert lstProjectRequests;

		//Store a set of the UserOrGroupIds so we can verify they are removed when the Account is changed
		Set<Id> originalUserOrGroupIdSet = new Set<Id>();
		for(Project_Request__Share objProjectRequestShare : [SELECT Id, AccessLevel, ParentId, RowCause, UserOrGroupId 
										   					 FROM Project_Request__Share
                                           					 WHERE RowCause = 'Customer__c']) {
			originalUserOrGroupIdSet.add(objProjectRequestShare.UserOrGroupId);
		}
		system.assertEquals(originalUserOrGroupIdSet.size(), 2);
		
		//Now that we know the initial setup worked correctly, create another Community User (with a new Account and Contact)
		List<User> newUserList = objTestDataFactory.createUsersWith10KCustomerProfile(1);
		insert newUserList;
 
		//Fetch the new Contact that was just created
		List<Contact> newContactList = [SELECT Id, AccountId 
										FROM Contact 
										WHERE Id =: userList[1].ContactId];
		
		contactList[0].AccountId = newContactList[0].AccountId;
		update contactList;
		
		List<Opportunity> lstOpportunities = objTestDataFactory.generateOpportunities(newContactList[0].AccountId, 'Qualification', system.today(), 1);
		insert lstOpportunities;
		
		//Now switch the Account on the Project, which will remove the old Shares and write new ones
		Test.startTest();
		lstProjectRequests[0].Account__c = newContactList[0].AccountId;
		lstProjectRequests[0].Request_Contact__c = newContactList[0].Id;
		lstProjectRequests[0].Opportunity__c = lstOpportunities[0].Id;
		update lstProjectRequests;
		Test.stopTest();

		//Verify the old Shares have been removed, and the new Shares are correctly in place
		Set<Id> newUserOrGroupIdSet = new Set<Id>();
		for(Project_Request__Share objProjectRequestShare : [SELECT Id, AccessLevel, ParentId, RowCause, UserOrGroupId 
										   					 FROM Project_Request__Share
                                           					 WHERE RowCause = 'Customer__c']) {
			if(!originalUserOrGroupIdSet.contains(objProjectRequestShare.UserOrGroupId)) {
				newUserOrGroupIdSet.add(objProjectRequestShare.UserOrGroupId);
			}
		}
    }*/
    
    static testMethod void test_method_four() {
		
		TestDataFactory objTestDataFactory = new TestDataFactory();
		
		List<User> userList = objTestDataFactory.createUsersWith10KCustomerProfile(2);
		insert userList;

		Set<Id> contactIdSet = new Set<Id>();
		for(User u : userList) {
			contactIdSet.add(u.ContactId);
		}

		//Fetch the Contact that is associated with our Community Contact that was inserted
		List<Contact> contactList = [SELECT Id, AccountId 
									 FROM Contact 
									 WHERE Id =: contactIdSet];


		List<Project_Request__c> lstProjectRequests = new List<Project_Request__c>();
        
        Project_Request__c objProjectRequest1 = objTestDataFactory.generateProjectRequestRecord(contactList[0].AccountId, 'New', contactList[0].Id, 'TestProjectWithNewStatus', system.today());
    	objProjectRequest1.Account__c = contactList[0].AccountId;
    	objProjectRequest1.Start_Date__c = system.today();
    	objProjectRequest1.Name = 'test';
    	lstProjectRequests.add(objProjectRequest1);
    	
    	Test.startTest();

    	insert lstProjectRequests;
    	contactList[1].Portal_User__c = userList[1].Id;
    	contactList[1].AccountId = lstProjectRequests[0].Account__c;
    	update contactList[1];

    	lstProjectRequests[0].Name = 'test123';
    	//lstProjectRequests[0].Account__c = contactList[1].AccountId;
    	//lstProjectRequests[0].Opportunity__c = null;
    	//lstProjectRequests[0].Request_Contact__c = contactList[1].Id;
    	update lstProjectRequests;
    	
    	delete lstProjectRequests;
    	system.assertEquals([SELECT id FROM Project_Request__Share where ParentId = :lstProjectRequests[0].Id].size(), 0);
    	
    	undelete lstProjectRequests;
    	system.assertEquals([SELECT id FROM Project_Request__Share where ParentId = :lstProjectRequests[0].Id And RowCause = 'Customer__c'].size(), 2);

    	Test.stopTest();
    }
    
    static testMethod void test_method_five() {
        
        TestDataFactory objTestDataFactory = new TestDataFactory();
        
        List<User> userList = objTestDataFactory.createUsersWith10KCustomerProfile(2);
        insert userList;

        Set<Id> contactIdSet = new Set<Id>();
        for(User u : userList) {
            contactIdSet.add(u.ContactId);
        }

        //Fetch the Contact that is associated with our Community Contact that was inserted
        List<Contact> contactList = [SELECT Id, AccountId 
                                     FROM Contact 
                                     WHERE Id =: contactIdSet];


        List<Project_Request__c> lstProjectRequests = new List<Project_Request__c>();
        
        Project_Request__c objProjectRequest1 = objTestDataFactory.generateProjectRequestRecord(contactList[0].AccountId, 'New', contactList[0].Id, 'TestProjectWithNewStatus', system.today());
        objProjectRequest1.Account__c = contactList[0].AccountId;
        objProjectRequest1.Start_Date__c = system.today();
        objProjectRequest1.Name = 'test';
        lstProjectRequests.add(objProjectRequest1);
        
        Test.startTest();

        insert lstProjectRequests;
        contactList[1].Portal_User__c = userList[1].Id;
        contactList[1].AccountId = lstProjectRequests[0].Account__c;
        update contactList[1];

        lstProjectRequests[0].Name = 'test';
        lstProjectRequests[0].Account__c = contactList[1].AccountId;
        lstProjectRequests[0].Opportunity__c = null;
        lstProjectRequests[0].Request_Contact__c = contactList[1].Id;
        update lstProjectRequests;
        
        delete lstProjectRequests;
        system.assertEquals([SELECT id FROM Project_Request__Share where ParentId = :lstProjectRequests[0].Id].size(), 0);
        
        undelete lstProjectRequests;
        system.assertEquals([SELECT id FROM Project_Request__Share where ParentId = :lstProjectRequests[0].Id And RowCause = 'Customer__c'].size(), 2);

        Test.stopTest();
    }
    
    /*static testMethod void test_method_five() {
		
		TestDataFactory objTestDataFactory = new TestDataFactory();
		
		List<User> userList = objTestDataFactory.createUsersWith10KCustomerProfile(2);
		insert userList;

		Set<Id> contactIdSet = new Set<Id>();
		for(User u : userList) {
			contactIdSet.add(u.ContactId);
		}

		//Fetch the Contact that is associated with our Community Contact that was inserted
		List<Contact> contactList = [SELECT Id, AccountId 
									 FROM Contact 
									 WHERE Id In: contactIdSet];
		
		contactList[0].Portal_User__c = userList[0].Id;
		update contactList;
		
		List<Project_Request__c> lstProjectRequests = new List<Project_Request__c>();
        
        Project_Request__c objProjectRequest1 = objTestDataFactory.generateProjectRequestRecord(contactList[0].AccountId, 'New', contactList[0].Id, 'TestProjectWithNewStatus', system.today());
    	objProjectRequest1.Account__c = contactList[0].AccountId;
    	objProjectRequest1.Start_Date__c = system.today();
    	objProjectRequest1.Request_Contact__c = contactList[0].Id;
    	lstProjectRequests.add(objProjectRequest1);
    	
    	insert lstProjectRequests;

		//Store a set of the UserOrGroupIds so we can verify they are removed when the Account is changed
		Set<Id> originalUserOrGroupIdSet = new Set<Id>();
		for(Project_Request__Share objProjectRequestShare : [SELECT Id, AccessLevel, ParentId, RowCause, UserOrGroupId 
										   					 FROM Project_Request__Share
                                           					 WHERE RowCause = 'Customer__c']) {
			originalUserOrGroupIdSet.add(objProjectRequestShare.UserOrGroupId);
		}
		//system.assertEquals(originalUserOrGroupIdSet.size(), 3);
		
		//Now that we know the initial setup worked correctly, create another Community User (with a new Account and Contact)
		List<User> newUserList = objTestDataFactory.createUsersWith10KCustomerProfile(1);
		insert newUserList;
 
		//Fetch the new Contact that was just created
		List<Contact> newContactList = [SELECT Id, AccountId 
										FROM Contact 
										WHERE Id =: userList[1].ContactId];
		
		contactList[0].AccountId = newContactList[0].AccountId;
		contactList[0].Portal_User__c = newUserList[0].Id;
		update contactList;
		
		List<Opportunity> lstOpportunities = objTestDataFactory.generateOpportunities(newContactList[0].AccountId, 'Qualification', system.today(), 1);
		insert lstOpportunities;
		
		//Now switch the Account on the Project, which will remove the old Shares and write new ones
		Test.startTest();
		lstProjectRequests[0].Account__c = newContactList[0].AccountId;
		lstProjectRequests[0].Request_Contact__c = newContactList[0].Id;
		//lstProjectRequests[0].Opportunity__c = lstOpportunities[0].Id;
		update lstProjectRequests;
		Test.stopTest();

		//Verify the old Shares have been removed, and the new Shares are correctly in place
		Set<Id> newUserOrGroupIdSet = new Set<Id>();
		for(Project_Request__Share objProjectRequestShare : [SELECT Id, AccessLevel, ParentId, RowCause, UserOrGroupId 
										   					 FROM Project_Request__Share
                                           					 WHERE RowCause = 'Customer__c']) {
			if(!originalUserOrGroupIdSet.contains(objProjectRequestShare.UserOrGroupId)) {
				newUserOrGroupIdSet.add(objProjectRequestShare.UserOrGroupId);
			}
		}
    }*/
}