@isTest
private class ReleaseTriggerHandler_Test {
	
	@testSetup static void setupData() {
		
		Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
		List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
    														'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
    														'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
    														null, 'Net 30', 'test@test.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
    														1);
        insert accList;
        
        List<Project__c> projectList = TestDataFactory_Projects.generateProjects(accList[0].Id, 'Test Project', 1);
        insert projectList;
        
      	List<Connection__c> connectionList = TestDataFactory_Connections.generateConnections(Constants.RECORDTYPEID_CONNECTION_PRODICTION, projectList[0].Id, 'Active', null, 2);
      	connectionList[0].Primary_Development_Environment__c = true;
      	insert connectionList;
      	
      	List<Release__c> releaseList = TestDataFactory_Releases.generateReleases(projectList[0].Id, connectionList[0].Id, connectionList[0].Id, 'TestRelease', 'Planned', System.today(), System.today().addDays(2), 2);
        insert releaseList;
	}
	
	@isTest static void test_usecase_one() {
		
		List<Release__c> releaseList = [Select Id,Project__c,Source__c,Target__c,Target_Release_Date__c,Validation_Status__c,Created_On_Heroku__c,Actual_Release_Date__c 
                                        From Release__c];
       	System.assertEquals(2, releaseList.size());
        Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
        Test.startTest();
            Release__c release = releaseList[0].clone(false, true, false, false);
            release.Id = null;
            insert release;
            System.assertEquals(false, release.Created_On_Heroku__c);

        Test.stopTest();
	}

  @isTest static void test_usecase_deleteReleaseOne() {
    List<Release__c> releaseList = [Select Id,Project__c,Source__c,Target__c,Target_Release_Date__c,Validation_Status__c,Created_On_Heroku__c,Actual_Release_Date__c 
                                        From Release__c];
    Test.startTest();
      releaseList[0].Created_on_Heroku__c = true;
      update releaseList;
      Test.setMock(HttpCalloutMock.class, new MockResponse_HerokuConnection());
      delete releaseList;
      System.assertEquals([Select Id From Release__c].size(),0) ;
    Test.stopTest();
  }

  @isTest static void test_usecase_deleteReleaseTwo() {
    List<Release__c> releaseList = [Select Id,Project__c,Source__c,Target__c,Target_Release_Date__c,Validation_Status__c,Created_On_Heroku__c,Actual_Release_Date__c 
                                        From Release__c];
    Test.startTest();
      releaseList[0].Scan_Running__c = true;
      update releaseList;
      try {
          delete releaseList;  
      }
      catch(Exception ex) {
      }
    Test.stopTest();
  }

  @isTest static void test_usecase_deleteReleaseThree() {
    List<Release__c> releaseList = [Select Id,Project__c,Source__c,Target__c,Target_Release_Date__c,Validation_Status__c,Created_On_Heroku__c,Actual_Release_Date__c 
                                        From Release__c];
    Test.startTest();
      releaseList[0].Validation_Running__c = true;
      update releaseList;
      try {
          delete releaseList;  
      }
      catch(Exception ex) {
      }
    Test.stopTest();
  }

  @isTest static void test_usecase_deleteReleaseFour() {
    List<Release__c> releaseList = [Select Id,Project__c,Source__c,Target__c,Target_Release_Date__c,Validation_Status__c,Created_On_Heroku__c,Actual_Release_Date__c 
                                        From Release__c];
    Test.startTest();
      releaseList[0].Delete_on_Heroku__c = false;
      releaseList[0].Allow_Deletion__c = false;
      update releaseList;
      try {
          delete releaseList;  
      }
      catch(Exception ex) {
      }
    Test.stopTest();
  }

}