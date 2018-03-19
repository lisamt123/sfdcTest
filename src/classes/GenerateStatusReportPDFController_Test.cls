@isTest
private class GenerateStatusReportPDFController_Test {
	
	@isTest static void test_method_one() {
		// Implement test code.
		TestDataFactory factory = new TestDataFactory();

		List<Account> accList = factory.generateAccounts(1);
                insert accList;

                List<Contact> contactList = factory.generateContactsForAccounts(accList, 1);
                contactList[0].Email = 'nowhere@nowhere.com';
                insert contactList;

                List<Project__c> projectList = factory.generateProjects(accList[0].Id,1);
                projectList[0].Primary_Client_Contact__c = contactList[0].Id;
                insert projectList;

                List<Status_Report__c> statusReportList = factory.generateStatusReports(1,projectList[0]);
                insert statusReportList;

                Test.startTest();
                        ApexPages.StandardController sc = new ApexPages.StandardController(statusReportList[0]);
                        GenerateStatusReportPDFController statusReportPDFController = new GenerateStatusReportPDFController(sc);
                        System.assertNotEquals(statusReportPDFController.projectDetailUrl,'');
                Test.stopTest();

	}
	
}