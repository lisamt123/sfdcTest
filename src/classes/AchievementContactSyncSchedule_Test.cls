@isTest
private class AchievementContactSyncSchedule_Test {

    @isTest static void test_method_one() {
        TestDataFactory_CustomSettings.initializeEndpointURIsCustomSetting();

        Test.startTest();
            List<Contact> contactList = new List<Contact>();
            contactList.add(new Contact(LastName = 'Test', Webassessor_Email__c = 'test@test.test', Trailhead_User_Id__c = 'testtesttest',Last_Achievement_Sync__c = Datetime.now() - 7));
            insert contactList;
            String CRON_EXP = '0 30 * * * ?';
            Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
            AchievementContactSyncSchedule conSch = new AchievementContactSyncSchedule();
            system.schedule('Hourly Contact Sync Batch Schedule job', CRON_EXP, conSch);
        Test.stopTest();
    }
}