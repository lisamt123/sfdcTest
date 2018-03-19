@isTest
private class CommunityUsersLLCProfileBatch_Test 
{
	@isTest static void test_CommunityUsersLLCProfileBatch() 
	{
		Test.startTest();
			TestDataFactory factory = new TestDataFactory();
			Profile communityUserProfile = [SELECT Id FROM Profile WHERE Name = '10K Delivery Partner (Login)'];
			List<User> userList = factory.createUsersWith10KDeliveryPartnerProfileNew(1);
			userList[0].ProfileId = communityUserProfile.Id;
			insert userList;

			Profile_Names__c profileName = new Profile_Names__c();
			profileName.Name = '10K Delivery Partner';
			profileName.License_Profile_Name__c = '10K Delivery Partner (License)';
			profileName.Login_Profile_Name__c = '10K Delivery Partner (Login)';
			insert profileName;

			Profile_Names__c profileName1 = new Profile_Names__c();
			profileName1.Name = '10K Services Client';
			profileName1.License_Profile_Name__c = '10K Services Client (License)';
			profileName1.Login_Profile_Name__c = '10K Services Client (Login)';
			insert profileName1;

			Profile_Names__c profileName2 = new Profile_Names__c();
			profileName2.Name = '10K Product Client';
			profileName2.License_Profile_Name__c = '10K Product Client (License)';
			profileName2.Login_Profile_Name__c = '10K Product Client (Login)';
			insert profileName2;

			List<User> userRecList = [SELECT Id, ProfileId FROM User WHERE Id =: userList[0].Id];
			System.assertEquals(userRecList[0].ProfileId,communityUserProfile.Id);

			CommunityUsersLLCProfileBatchScheduler cullcpbs = new CommunityUsersLLCProfileBatchScheduler();
			cullcpbs.execute(null);
			String hour = String.valueOf(Datetime.now().hour());
            String min = String.valueOf(Datetime.now().minute()); 
            String ss = String.valueOf(Datetime.now().second());
            String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
            System.schedule('ScheduledJob ' + String.valueOf(Math.random()), nextFireTime, new UpdateUserLicenseSchedulable(userList));
		Test.stopTest();
	}
}