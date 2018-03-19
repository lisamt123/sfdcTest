public with sharing class TestDataFactory_InventoryOrder {
   
	public static List<Inventory_Order__c> generateInventoryOrder(Date orderDate,String status, Integer numOfRecords) {
		return generateInventoryOrderInternal(orderDate, status, numOfRecords);
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<Inventory_Order__c> generateInventoryOrderInternal(Date orderDate, String status, Integer numOfRecords) {
    	List<Inventory_Order__c> orderList = new List<Inventory_Order__c>();
        
        for(Integer i = 0; i < numOfRecords; i++) {
			Inventory_Order__c order = new Inventory_Order__c();
			order.Order_Date__c = orderDate;
			order.Status__c = status;
			orderList.add(order);
        }
        
        return orderList;
    }
}