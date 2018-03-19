@isTest
private class OrderHistoryController_Test {
	
	@isTest static void test_OrderHistoryController() 
	{
		TestDataFactory factory = new TestDataFactory();
		List<User> userList = factory.createUsersWith10KDeliveryPartnerProfileNew(1);

		Merchandise__c merchandiseRec = new Merchandise__c();
		merchandiseRec.Name = 'Test Merchandise';
		merchandiseRec.Point_Value__c = 50;
		merchandiseRec.Description__c = 'Test Description';
		merchandiseRec.Picture__c = 'Test Picture';
		merchandiseRec.Display_Sizes__c = True;
		insert merchandiseRec;

		Item__c merchantItem = new Item__c(Size__c = 'L', Merchandise__c = merchandiseRec.Id);
		insert merchantItem;

		Order__c order = new Order__c(Contact__c = userList[0].ContactId, Status__c = 'Submitted');
		insert order;

		Order_Line_Item__c orderLineItem = new Order_Line_Item__c();
		orderLineItem.Item__c = merchantItem.Id;
		orderLineItem.Order__c = order.Id;
		orderLineItem.Quantity_Ordered__c = 5;
		insert orderLineItem;

		Test.startTest();
			System.runAs(userList[0]){
				List<Order__c> orderList = OrderHistoryController.getOrderHistory();
				System.assertEquals(orderList.size(),1);
				OrderHistoryController.getOrderDetails(order.Id);
			}
		Test.stopTest();
	}
}