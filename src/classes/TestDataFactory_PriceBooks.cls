public with sharing class TestDataFactory_PriceBooks {
	public static List<Pricebook2> generatePriceBooks(String name, Boolean isActive, String accountTier, String description, Integer noOfRecords) {
		return generatePriceBooksInternal(name, isActive, accountTier, description, noOfRecords);
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<Pricebook2> generatePriceBooksInternal(String name, Boolean isActive, String accountTier, String description, Integer noOfRecords) {
    	List<Pricebook2> priceBooksList = new List<Pricebook2>();
        
        for(Integer i = 0; i < noOfRecords; i++) {
            Pricebook2 priceBooksRec = new Pricebook2();
            priceBooksRec.Name = name+i;
            priceBooksRec.IsActive = isActive;
            priceBooksRec.Account_Tier__c = accountTier;
            priceBooksRec.Description = description;
            
            priceBooksList.add(priceBooksRec);
        }
        return priceBooksList;
    }  
}