public with sharing class TestDataFactory_Inventory {
   
	public static List<Inventory__c> generateInventory(Id merchantItemId,Integer quantityPurchasedValue,Id inventoryOrderId, Integer numOfRecords) {
		return generateInventoryInternal(merchantItemId, quantityPurchasedValue,inventoryOrderId ,numOfRecords);
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<Inventory__c> generateInventoryInternal(Id merchantItemId,Integer quantityPurchasedValue,Id inventoryOrderId, Integer numOfRecords) {
    	List<Inventory__c> inventoryRecList = new List<Inventory__c>();
        
        for(Integer i = 0; i < numOfRecords; i++) {
			Inventory__c inventoryRec = new Inventory__c();
			inventoryRec.Item__c = merchantItemId;
			inventoryRec.Quantity_Purchased_value__c = quantityPurchasedValue;
			inventoryRec.Inventory_Order__c = inventoryOrderId;
			inventoryRecList.add(inventoryRec);
        }
        
        return inventoryRecList;
    }
}