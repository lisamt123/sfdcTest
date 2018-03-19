public with sharing class TestDataFactory_PriceBookEntries {
	public static List<PricebookEntry> generatePriceBookEntries(String priceBookId, String productId, Integer unitPrice, Boolean isActive) {
		return generatePriceBookEntriesInternal(priceBookId, productId, unitPrice, isActive);
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<PricebookEntry> generatePriceBookEntriesInternal(String priceBookId, String productId, Integer unitPrice, Boolean isActive) {
    	List<PricebookEntry> priceBookEntriesList = new List<PricebookEntry>();
        
            PricebookEntry priceBookEntriesRec = new PricebookEntry();
            priceBookEntriesRec.Pricebook2Id = priceBookId;
            priceBookEntriesRec.Product2Id = productId;
            priceBookEntriesRec.UnitPrice = unitPrice;
            priceBookEntriesRec.IsActive = isActive;
            
            priceBookEntriesList.add(priceBookEntriesRec);
        
        return priceBookEntriesList;
    }  
}