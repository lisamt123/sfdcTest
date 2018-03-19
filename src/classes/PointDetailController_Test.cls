@isTest
private class PointDetailController_Test {
	
	@isTest static void test_PointDetailController() {
		
		Test.startTest();
			List<User> userList = TestDataFactory_Users.generateUsersWith10KDeliveryPartnerProfile(true, 1);
			insert userList;
		Test.stopTest();
		
		Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
		List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
    														'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
    														'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
    														null, 'Net 30', 'test@test.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
    														1);
        insert accList;
        
        List<Contact> contactList = TestDataFactory_Contacts.generatecontacts(accList, 'Test contact', 'lastName', '', '', 1);
        insert contactList;
        
        List<Project__c> projectList = TestDataFactory_Projects.generateProjects(accList[0].Id, 'Test Project', 1);
        insert projectList;
        
        List<Story__c> storiesList = TestDataFactory_Stories.generateStories('Test Story', projectList[0].Id, 'Completed', 'Medium', 2);
        storiesList[0].Delivery_Owner__c = userList[0].Id;
        storiesList[1].Delivery_Owner__c = userList[0].Id;
        insert storiesList;
        
        Id systemRecordTypeId = Schema.SObjectType.Points_Rule__c.RecordTypeInfosByName.get('System Generated').RecordTypeId;
        
        List<Points_Rule__c> pointRuleRecList = TestDataFactory_PointRules.generatePointRules(true, 'AND', 'Delivery_Owner__r.ContactId', 'Story__c', 10, systemRecordTypeId, 2);
        System.debug('pointRuleRecList'+pointRuleRecList);
        pointRuleRecList[0].My_Points_Display_Name__c = 'Project__r.Name';
        insert pointRuleRecList;
        
        List<Points_Rule_Criteria__c> pointRuleCriteriaList = TestDataFactory_PointsRuleCriteria.generatePointRuleCriteria('Status__c', 'Completed', '=', pointRuleRecList[0].Id, 1);
        insert pointRuleCriteriaList;
        
        List<Points__c> pointList = TestDataFactory_Points.generatePoints(storiesList[0].Id, userList[0].ContactId, 20, pointRuleRecList[0].Id, 1);
        pointList.addAll(TestDataFactory_Points.generatePoints(storiesList[1].Id, userList[0].ContactId, 20, pointRuleRecList[0].Id, 1));
        insert pointList;

		System.runAs(userList[0]) {
			//Test.startTest();
				PointDetailController.retPoints();
                pointRuleRecList[0].My_Points_Display_Name__c = 'Test Name';
                update pointRuleRecList;
                PointDetailController.retPoints();
                pointRuleRecList[0].My_Points_Display_Name__c = 'Project__c';
                update pointRuleRecList;
                PointDetailController.retPoints();
				Contact con = [SELECT Id, Lifetime_Points_Earned__c, Lifetime_Points_Redeemed__c FROM Contact WHERE Id =: userList[0].ContactId];
				System.assertEquals(con.Lifetime_Points_Earned__c, 40);
			//Test.stopTest();
		}
	}
}