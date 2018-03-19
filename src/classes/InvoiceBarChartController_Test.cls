@isTest
private class InvoiceBarChartController_Test 
{
	@isTest static void test_InvoiceBarChartController() 
	{
		TestDataFactory factory = new TestDataFactory();

		List<Account> accountList = factory.generateAccounts(1);
		insert accountList;

		List<Invoice__c> invoiceList = factory.generateInvoices (accountList[0].Id, 'Test Invoice', 1);
		insert invoiceList;

		List<Agreement__c> agreementList = factory.generateRetainerAgreementsForAccounts(accountList, 1);
		insert agreementList;

		List<Rate__c> rateList = factory.generateRateForAgreement(agreementList[0].Id, Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS, 'Architect', 1);
		insert rateList;

		List<Invoice_Line_Item__c> invoiceLineItemList = factory.generateInvoiceLineItems (invoiceList[0].Id, rateList[0].Id, 1);
		insert invoiceLineItemList;

		invoiceList[0].Invoice_Generated_On__c = Date.today();
		update invoiceList;

		Test.startTest();
			ApexPages.StandardController sc = new ApexPages.StandardController(accountList[0]);
			InvoiceBarChartController controller = new InvoiceBarChartController(sc);
			controller.getMonthData();
			controller.getYearData();
			System.assertNotEquals(InvoiceBarChartController.accountId,null);
		Test.stopTest();
	}
}