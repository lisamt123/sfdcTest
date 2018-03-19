@isTest
private class MerchandiseStoreController_Test 
{
	@isTest static void test_MerchandiseStoreController() 
	{
		TestDataFactory factory = new TestDataFactory();

		List<User> userList = factory.createUsersWith10KDeliveryPartnerProfileNew(1);
        
        List<Merchandise__c> merchandiseRecList = TestDataFactory_Merchandise.generateMerchandise(50,'Test Description','Test Picture',3);
		insert merchandiseRecList;
        
        merchandiseRecList[1].Free_Merchandise__c = merchandiseRecList[0].Id;
        update merchandiseRecList[1];
		
        List<Item__c> itemList = TestDataFactory_Items.generateItems('L',merchandiseRecList[0].Id,3);
		itemList[1].Merchandise__c = merchandiseRecList[1].Id;
        itemList[2].Merchandise__c = merchandiseRecList[2].Id;
        insert itemList;
        
        List<Inventory_Order__c> inventoryOrderList = TestDataFactory_InventoryOrder.generateInventoryOrder(System.today(),'Placed',3);
		insert inventoryOrderList;
        
        List<Inventory__c> inventoryList = TestDataFactory_Inventory.generateInventory(itemList[0].Id,100,inventoryOrderList[0].Id,3);
		inventoryList[1].Item__c = itemList[1].Id;
        inventoryList[1].Inventory_Order__c = inventoryOrderList[1].Id;
        inventoryList[2].Item__c = itemList[2].Id;
        inventoryList[2].Inventory_Order__c = inventoryOrderList[2].Id;
        insert inventoryList;
        
        Item__c[] cartItems = new Item__c[] {};
		Merchandise__c[] merchandiseArray = new Merchandise__c[] {};
		merchandiseArray.add(merchandiseRecList[1]);
		cartItems.add(itemList[0]);
        String contactJSON = '{"contactDetail":{"Id":"'+userList[0].ContactId+'","MailingStreet":"502 JTM MALL","MailingCity":"Jaipur","MailingState":"Texas","MailingPostalCode":"30201","MailingCountry":"United States","Email":"dsaran@10kview.com","Phone":"7737621600","FirstName":"Devendra","LastName":"Saran","Lifetime_Points_Earned__c":400100,"Lifetime_Points_Redeemed__c":2270}}';
		MerchandiseStoreController.ItemGiftWrapper itemWrapperRec = new MerchandiseStoreController.ItemGiftWrapper(itemList[1],itemList[0]);
		Test.startTest();
			System.runAs(userList[0]){
				MerchandiseStoreController.getMerchandise();
				MerchandiseStoreController.getPoints();
				MerchandiseStoreController.getFreeItem(merchandiseRecList[1]);
				MerchandiseStoreController.upsertDraftOrder(cartItems,'Test', contactJSON,JSON.serialize(itemWrapperRec));
				MerchandiseStoreController.getItemWrapper(merchandiseRecList[1],itemList[1],merchandiseRecList[0],itemList[0]);
				MerchandiseStoreController.getFreeMerchandiseWrapper(merchandiseArray,contactJSON);
				
				List<Order__c> orderList = [SELECT Id, (SELECT Id, Item__c, Order__c, Quantity_Ordered__c FROM Order_Line_Items__r)FROM Order__c WHERE Status__c = 'Draft'];
				
				System.assertEquals(orderList.size(), 1);

				Order_Line_Item__c orderLineItem = new Order_Line_Item__c();
				orderLineItem.Id = orderList[0].Order_Line_Items__r[0].Id;
				orderLineItem.Quantity_Ordered__c = 5;
				update orderLineItem;
                
                Order_Line_Item__c orderLineItem2 = new Order_Line_Item__c();
				orderLineItem2.Id = orderList[0].Order_Line_Items__r[1].Id;
				orderLineItem2.Quantity_Ordered__c = 5;
				update orderLineItem2;
                
				MerchandiseStoreController.getPoints();
				List<Item__c> merchandiseList = [SELECT Id, Quantity_Redeemed__c FROM Item__c WHERE Id =: itemList[0].Id];
				System.assertEquals(merchandiseList[0].Quantity_Redeemed__c, 5);
				cartItems.add(itemList[2]);
                MerchandiseStoreController.upsertDraftOrder(cartItems,'Test', contactJSON,JSON.serialize(itemWrapperRec));
                MerchandiseStoreController.createOrder(cartItems, contactJSON);
                
                
                
			}
		Test.stopTest();
	}
	
}