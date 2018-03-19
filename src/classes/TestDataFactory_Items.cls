public with sharing class TestDataFactory_Items {
   
	public static List<Item__c> generateItems(String size, Id merchandiseId, Integer numOfRecords) {
		return generateItemInternal(size, merchandiseId, numOfRecords);
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<Item__c> generateItemInternal(String size, Id merchandiseId, Integer numOfRecords) {
    	List<Item__c> itemList = new List<Item__c>();
        
        for(Integer i = 0; i < numOfRecords; i++) {
			Item__c item = new Item__c();
			item.Size__c = size;
			item.Merchandise__c = merchandiseId;
			itemList.add(item);
        }
        
        return itemList;
    }
}