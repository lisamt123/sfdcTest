@isTest
private class GenerateInvoiceController_Test {
	@isTest static void test_GenerateInvoiceController() {
		GenerateInvoiceController controller = new GenerateInvoiceController();
		Test.startTest();
			controller.executeBatch();
			controller.retrieveJobs();
			System.assertEquals(controller.classNameMap.size() > 0 ,true);

			String hour = String.valueOf(Datetime.now().hour());
            String min = String.valueOf(Datetime.now().minute()); 
            String ss = String.valueOf(Datetime.now().second());
            String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
            System.schedule('ScheduledJob ' + String.valueOf(Math.random()), nextFireTime, new GenerateInvoicesSchedule());
		Test.stopTest();
	}
}