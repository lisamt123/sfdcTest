@isTest
private class StatusReportTriggerHandlerTest {

    static testMethod void myUnitTest() {
    	
      Test.startTest();
      
	    TestDataFactory dataFactory = new TestDataFactory();
	    List<Account> accounts = dataFactory.generateAccounts(1);
	    insert accounts;
	
	    List<Project__c> projects = dataFactory.generateProjects(accounts[0].Id, 1);
	    insert projects; 
	  
	    List<Status_Report__c> statusReports = dataFactory.generateStatusReports(1, projects[0]);
	    insert statusReports;
	  
	    statusReports[0].Project_Health__c = 'Red';
	    update statusReports[0];
	    System.assertEquals('Red', statusReports[0].Project_Health__c);
      
      Test.stopTest();
    }
}