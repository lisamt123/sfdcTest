@isTest
private class DeleteStatusReportController_Test 
{
	@isTest static void test_method_one() 
	{
		Test.startTest();
      	
		    TestDataFactory dataFactory = new TestDataFactory();
		    List<User> userList = dataFactory.createUsersWith10KDeliveryPartnerProfileNew(1);
		    insert userList;
		    
		    System.runAs(userList[0]){
			    List<Account> accounts = dataFactory.generateAccounts(1);
			    insert accounts;
			
			    List<Project__c> projects = dataFactory.generateProjects(accounts[0].Id, 1);
			    insert projects; 

			    List<Status_Report__c> statusReports = dataFactory.generateStatusReports(1, projects[0]);
			    insert statusReports;
		  
		    	DeleteStatusReportController.deleteStatusReportRecord(statusReports[0].Id);
		    	List<Status_Report__c> statusReportList = [SELECT Id FROM Status_Report__c];
		    	System.assertEquals(statusReportList.size(),1);
		    	projects[0].Project_Lead__c = userList[0].Id;
			  	update projects;
			  	DeleteStatusReportController.deleteStatusReportRecord(statusReports[0].Id);
			  	statusReportList = [SELECT Id FROM Status_Report__c];
		    	System.assertEquals(statusReportList.size(),0);
		    }
      
      	Test.stopTest();
	}
}