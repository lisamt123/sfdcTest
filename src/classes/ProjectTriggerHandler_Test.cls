@isTest
private class ProjectTriggerHandler_Test {
	
	@isTest static void CustomerAssignedToNewProject() {
		TestDataFactory factory = new TestDataFactory();

		//Generate a new Community User, and create an Account and Contact for that person as well
		List<User> userList = factory.createUsersWith10KCustomerProfile(1);
		insert userList;

		//Fetch the Contact that is associated with our Community Contact that was inserted
		List<Contact> contactList = [SELECT Id, AccountId 
									 FROM Contact 
									 WHERE Id =: userList[0].ContactId];
		system.assertEquals(contactList.size(), 1);

		//Before we start, verify that there are no Project Share records
		List<Project__Share> projectShares = [SELECT Id, AccessLevel, ParentId, RowCause, UserOrGroupId 
											  FROM Project__Share
                                              WHERE RowCause = 'Customer__c'];
        system.assertEquals(projectShares.size(), 0);

		//Insert a new Project for the Contact's Account, which will write two Shares for that Account into the Project__Share table
		Test.startTest();
		List<Project__c> projectList = factory.generateProjects(contactList[0].AccountId, 1);
		projectList[0].Account__c = contactList[0].AccountId;
		insert projectList;
		Test.stopTest();

		//Verify the Project__Share records were written correctly
		projectShares = [SELECT Id, AccessLevel, ParentId, RowCause, UserOrGroupId 
						 FROM Project__Share
                         WHERE RowCause = 'Customer__c'];
		system.debug('HERE are the Project Shares post insert : ' + projectShares);
        system.assertEquals(projectShares.size(), 2);
		system.assertEquals(projectShares[0].ParentId, projectList[0].Id);
	}

	@isTest static void CustomerChangedOnExistingProject() {
		TestDataFactory factory = new TestDataFactory();

		//Generate a new Community User, and create an Account and Contact for that person as well
		List<User> userList = factory.createUsersWith10KCustomerProfile(2);
		insert userList;

		Set<Id> contactIdSet = new Set<Id>();
		for(User u : userList) {
			contactIdSet.add(u.ContactId);
		}

		//Fetch the Contact that is associated with our Community Contact that was inserted
		List<Contact> contactList = [SELECT Id, AccountId 
									 FROM Contact 
									 WHERE Id =: contactIdSet];

		//Insert a new Project for the Contact's Account, which will write two Shares for that Account into the Project__Share table
		List<Project__c> projectList = factory.generateProjects(contactList[0].AccountId, 1);
		projectList[0].Account__c = contactList[0].AccountId;
		insert projectList;

		//Store a set of the UserOrGroupIds so we can verify they are removed when the Account is changed
		Set<Id> originalUserOrGroupIdSet = new Set<Id>();
		for(Project__Share projectShare : [SELECT Id, AccessLevel, ParentId, RowCause, UserOrGroupId 
										   FROM Project__Share
                                           WHERE RowCause = 'Customer__c']) {
			originalUserOrGroupIdSet.add(projectShare.UserOrGroupId);
		}
		system.assertEquals(originalUserOrGroupIdSet.size(), 2);
		
		//Now that we know the initial setup worked correctly, create another Community User (with a new Account and Contact)
		List<User> newUserList = factory.createUsersWith10KCustomerProfile(1);
		insert newUserList;

		//Fetch the new Contact that was just created
		List<Contact> newContactList = [SELECT Id, AccountId 
										FROM Contact 
										WHERE Id =: newUserList[0].ContactId];
		
		//Now switch the Account on the Project, which will remove the old Shares and write new ones
		Test.startTest();
		projectList[0].Account__c = newContactList[0].AccountId;
		update projectList;
		Test.stopTest();

		//Verify the old Shares have been removed, and the new Shares are correctly in place
		Set<Id> newUserOrGroupIdSet = new Set<Id>();
		for(Project__Share projectShare : [SELECT Id, AccessLevel, ParentId, RowCause, UserOrGroupId 
										   FROM Project__Share
                                           WHERE RowCause = 'Customer__c']) {
			if(!originalUserOrGroupIdSet.contains(projectShare.UserOrGroupId)) {
				newUserOrGroupIdSet.add(projectShare.UserOrGroupId);
			}
		}
		system.assertEquals(newUserOrGroupIdSet.size(), 2);
	}

	@isTest static void ProjectSharesMaintainedOnDeleteAndUndelete() {
		TestDataFactory factory = new TestDataFactory();

		//Generate two new Community User, and create an Account and Contact for each as well
		List<User> userList = factory.createUsersWith10KCustomerProfile(2);
		insert userList;

		Set<Id> contactIdSet = new Set<Id>();
		for(User u : userList) {
			contactIdSet.add(u.ContactId);
		}

		//Fetch the Contacts that are associated with our Community Contacts that were inserted
		List<Contact> contactList = [SELECT Id, AccountId 
									 FROM Contact 
									 WHERE Id =: contactIdSet];

		//Insert one Project for each Contact's Account, which will write two Shares per Account into the Project__Share table
		List<Project__c> projectList = new List<Project__c>();
		projectList.addAll(factory.generateProjects(contactList[0].AccountId, 1));
		projectList[0].Account__c = contactList[0].AccountId;
		projectList.addAll(factory.generateProjects(contactList[1].AccountId, 1));
		projectList[1].Account__c = contactList[1].AccountId;
		insert projectList;

		//Store a set of the UserOrGroupIds so we can verify they are removed when the Account is changed
		Set<Id> originalUserOrGroupIdSet = new Set<Id>();
		for(Project__Share projectShare : [SELECT Id, AccessLevel, ParentId, RowCause, UserOrGroupId 
										   FROM Project__Share
                                           WHERE RowCause = 'Customer__c']) {
			originalUserOrGroupIdSet.add(projectShare.UserOrGroupId);
		}
		system.assertEquals(originalUserOrGroupIdSet.size(), 4);

		//Now delete the Project, which should delete the Shares for that Project as well
		delete projectList;

		//Verify that there are no Project Share records after the Project has been deleted
		List<Project__Share> projectShares = [SELECT Id, AccessLevel, ParentId, RowCause, UserOrGroupId 
											  FROM Project__Share
                                              WHERE RowCause = 'Customer__c'];
		system.assertEquals(projectShares.size(), 0);

		//Now restore both the Projects from the Recycle Bin
		undelete projectList;

		//Verify the Shares have been restored
		projectShares = [SELECT Id, AccessLevel, ParentId, RowCause, UserOrGroupId 
						 FROM Project__Share
                         WHERE RowCause = 'Customer__c'];
		system.assertEquals(projectShares.size(), 4);

		// Now delete one of the Projects, and make sure only 2 Share records survive
		delete projectList[0];

		projectShares = [SELECT Id, AccessLevel, ParentId, RowCause, UserOrGroupId 
						 FROM Project__Share
                         WHERE RowCause = 'Customer__c'];
		system.assertEquals(projectShares.size(), 2);
	}
}