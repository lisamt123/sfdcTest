@isTest
private class ExpertAvailabilityBatchSchedular_Test {
	
	@isTest static void test_method_one() {
		Test.startTest();
			List<User> userList = TestDataFactory_Users.generateUsersWith10KDeliveryPartnerProfile(true, 1);
			insert userList;
			System.runAs(userList[0]) {
				String hour = String.valueOf(Datetime.now().hour());
	            String min = String.valueOf(Datetime.now().minute()); 
	            String ss = String.valueOf(Datetime.now().second());
	            String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
	            System.schedule('ScheduledJob ' + String.valueOf(Math.random()), nextFireTime, new ExpertAvailabilityBatchSchedular());
			}
		Test.stopTest();
	}
	
}