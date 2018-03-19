@isTest
private class ManageRatesUIController_Test {
	
	@isTest static void test_ManageRatesUIController() {
		List<Product2> prod =  TestDataFactory_Products.generateProducts('Test Product', 'Developer');
		insert prod;

		Id standardPriceBookId = Test.getStandardPricebookId();

		List<PricebookEntry> standardPrice = TestDataFactory_PriceBookEntries.generatePriceBookEntries(standardPriceBookId, prod[0].Id, 10000, true);
        insert standardPrice;
        
        List<PriceBook2> pb = TestDataFactory_PriceBooks.generatePriceBooks('Custom Test PriceBook', true, 'Base', 'Testing', 1);
		insert pb;
        
        List<PricebookEntry> customPrice = TestDataFactory_PriceBookEntries.generatePriceBookEntries(pb[0].Id, prod[0].Id, 12000, true);
        insert customPrice;

		Test.startTest();
			ManageRatesUIController.retrivePriceBookRec(pb[0].Id);
			String saveResult = ManageRatesUIController.clonePriceBookProducts(JSON.serialize(pb[0]), JSON.serialize(new List<PricebookEntry>{customPrice[0]}));
			System.assertNotEquals(saveResult, null);
		Test.stopTest();
	}
}