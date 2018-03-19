@isTest
private class StatusReportChartController_Test 
{
	
	@isTest static void test_method_one() 
	{
		TestDataFactory factory = new TestDataFactory();

		List<Account>accountList = factory.generateAccounts(1);
		insert accountList;

		List<Contact> contactList = factory.generateContactsForAccounts(accountList, 1);
		insert contactList;

		List<Project__c> projectList = factory.generateProjects(accountList[0].Id, 1);
		insert projectList;

		List<assignment__c> assignmentList = factory.generateAssignment(projectList[0].Id, 'Time & Materials', 1);
		insert assignmentList;

		List<time_entry__c> timeentryList = factory.generateTimeEntry(assignmentList[0].Id, 'Test', Date.today(), 8, 1);
		insert timeentryList;

		List<Status_Report__c> statusreportList = new List<Status_Report__c>();
		Status_Report__c statusReport = new Status_Report__c();

		statusReport.End_Date__c = Date.today()+10;
		statusReport.Issues_Risks__c = 'Test';
		statusReport.Key_Items_Completed_Last_Week__c = 'Test';
		statusReport.Key_Items_Scheduled_for_This_Week__c = 'Test';
		statusReport.Project__c = projectList[0].Id;
		statusReport.Start_Date__c = Date.today()-15;

		statusreportList.add(statusReport);
		insert statusreportList;

		Test.startTest();
			ApexPages.StandardController sc = new ApexPages.StandardController(statusreportList[0]);
			StatusReportChartController controller = new StatusReportChartController(sc);
			controller.getData();
			System.assertEquals(statusreportList.size(),1);
		Test.stopTest();	
	}
}