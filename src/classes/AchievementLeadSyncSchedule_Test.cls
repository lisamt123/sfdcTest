@isTest
private class AchievementLeadSyncSchedule_Test {
    @isTest static void test_method_one() {
        
        TestDataFactory_CustomSettings.initializeEndpointURIsCustomSetting();

        Test.startTest();
            List<Lead> leadsList = new List<Lead>();
            leadsList.add(new Lead(LastName = 'Test', Company = 'test' ,Webassessor_Email__c = 'test@test.test', Trailhead_User_Id__c = 'testtesttest',Last_Achievement_Sync__c = Datetime.now() - 1));
            insert leadsList;
            String CRON_EXP = '0 0 * * * ?';
            Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
            AchievementLeadSyncSchedule leadSch = new AchievementLeadSyncSchedule();
            system.schedule('Hourly Lead Sync Batch Schedule job for testing', CRON_EXP, leadSch);
        Test.stopTest();
    }
}