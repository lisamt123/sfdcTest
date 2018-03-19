public with sharing class MerchandiseStoreController 
{
	@AuraEnabled
	public static List<Merchandise__c> getMerchandise()
	{
		List<Merchandise__c> merchandiseList = [SELECT Id, Free_Merchandise__c,Name, Cost__c, Description__c, Estimated_Shipping_Cost__c, Picture__c, Point_Value__c, 
													Allow_Orders_for_Sold_Out_Items__c, Display_Sizes__c, 
														(SELECT Id, Name, Merchandise__r.Name, Merchandise__r.Display_Sizes__c, Merchandise__r.Point_Value__c, Quantity_On_Hand__c, Quantity_Redeemed__c, Total_Quantity__c, Size__c 
														FROM Items__r)
													FROM Merchandise__c 
													WHERE Point_Value__c != null 
													AND Omit_from_Store__c != True];

		List<Merchandise__c> merchandiseWrapperList = new List<Merchandise__c>();
		for(Merchandise__c merchant : merchandiseList)
		{
			if((merchant.Items__r).size() > 0)
			{
				Boolean merchandiseValidForDisplay = false;
				for(Item__c item : merchant.Items__r)
				{
					if((merchant.Allow_Orders_for_Sold_Out_Items__c && merchant.Display_Sizes__c) || item.Quantity_On_Hand__c > 0)
					{
						merchandiseValidForDisplay = true;
					}
				}
				if(merchandiseValidForDisplay)
					merchandiseWrapperList.add(merchant);
			}
		}
		return merchandiseWrapperList;
	}

	@AuraEnabled
	public static UserContactWrapp getPoints()
	{
		String contactId;
		List<User> userList = [SELECT Id, ContactId FROM USER WHERE Id=: UserInfo.getUserId()];
		List<Contact> contactList = [SELECT Id, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Email, Phone, FirstName, LastName, Lifetime_Points_Earned__c, Lifetime_Points_Redeemed__c, AccountId FROM Contact WHERE Id =:userList[0].ContactId];
		if(!contactList.isEmpty()){
			List<Account> accountList = [SELECT ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry FROM Account WHERE Id =: contactList[0].AccountId];
			contactList[0].MailingStreet 		= accountList[0].ShippingStreet;
			contactList[0].MailingCity 			= accountList[0].ShippingCity;
			contactList[0].MailingState 		= accountList[0].ShippingState;
			contactList[0].MailingPostalCode 	= accountList[0].ShippingPostalCode;
			contactList[0].MailingCountry 		= accountList[0].ShippingCountry;
			UserContactWrapp contactWrap = new UserContactWrapp();
			contactWrap.contactDetail = contactList[0];
			contactId = contactList[0].Id;

			List<CartQuantityWrap> oldCartItemsList = new List<CartQuantityWrap>();
			Map<String,Integer> merchantIdToQuantityMap = new Map<String,Integer>();
			Map<Id,Order_Line_Item__c> itemIdtoOliMap = new Map<Id,Order_Line_Item__c>();
			Map<Id,Order_Line_Item__c> freeoliIdtoOliMap = new Map<Id,Order_Line_Item__c>();
			List<Order_Line_Item__c> oliListToBeDeleted = new List<Order_Line_Item__c>();
			Set<Id> merchandiseIdSet = new Set<Id>();
			List<Order__c> orderList = [SELECT Id, Status__c,
										(SELECT Free_Order_Line_Item__c, Id, Order__c, Item__c, Item__r.Merchandise__c, Quantity_Ordered__c 
											FROM Order_Line_Items__r) 
										FROM Order__c 
										WHERE Status__c = 'Draft' 
										AND Contact__c =: contactId];
            
			if(!orderList.isEmpty())
			{
                for(Order_Line_Item__c oli : orderList[0].Order_Line_Items__r)
				{	
					if(oli.Quantity_Ordered__c != null && oli.Free_Order_Line_Item__c == null){
						merchantIdToQuantityMap.put(oli.Item__c, Integer.valueOf(String.valueOf(oli.Quantity_Ordered__c)));
						itemIdtoOliMap.put(oli.Item__c,oli);
						merchandiseIdSet.add(oli.Item__r.Merchandise__c);
					}
					
					

					if(oli.Free_Order_Line_Item__c != null){
						freeoliIdtoOliMap.put(oli.Free_Order_Line_Item__c ,oli);
					}
					
				}
			}

			List<Merchandise__c> oldCartMerchantList = new List<Merchandise__c>();
			List<Order_Line_Item__c> orderLineItemFreeList = new List<Order_Line_Item__c>();
			if(!merchantIdToQuantityMap.isEmpty())
			{
				List<Merchandise__c> oldCartItemsLst = [SELECT Id,Free_Merchandise__c, Name, Cost__c, Description__c, Estimated_Shipping_Cost__c, Picture__c, Point_Value__c, 
														Allow_Orders_for_Sold_Out_Items__c, Display_Sizes__c, 
															(SELECT Id, Name, Quantity_On_Hand__c, Quantity_Redeemed__c, Total_Quantity__c, Size__c 
															FROM Items__r) 
														FROM Merchandise__c 
														WHERE Id IN : merchandiseIdSet];
														//
				Map<Id,List<Item__c>> freeMerchandiseIdToItemsMap = new Map<Id,List<Item__c>>();										
				for(Merchandise__c oldCartMerchandise : [SELECT Id,Free_Merchandise__c, Name, Cost__c, Description__c, Estimated_Shipping_Cost__c, Picture__c, Point_Value__c, 
														Allow_Orders_for_Sold_Out_Items__c, Display_Sizes__c, 
															(SELECT Id, Name, Quantity_On_Hand__c, Quantity_Redeemed__c, Total_Quantity__c, Size__c 
															FROM Items__r) 
														FROM Merchandise__c ]) {
					freeMerchandiseIdToItemsMap.put(oldCartMerchandise.Id, oldCartMerchandise.Items__r);
				}
				for(Merchandise__c oldCartMerchandise : oldCartItemsLst)
				{
					oldCartMerchantList.add(oldCartMerchandise);
					for(Item__c oldCartItem : oldCartMerchandise.Items__r)
					{
						if(merchantIdToQuantityMap.containsKey(oldCartItem.Id))
						{
							CartQuantityWrap cartQuantity = new CartQuantityWrap();
							cartQuantity.oldCartItem = oldCartItem;
							cartQuantity.relatedMerchandisePointValue = Integer.valueOf(oldCartMerchandise.Point_Value__c);
							cartQuantity.quantityOrdered = merchantIdToQuantityMap.get(oldCartItem.Id);
							oldCartItemsList.add(cartQuantity);
						}

						if(itemIdtoOliMap.containskey(oldCartItem.Id)){
							if(oldCartMerchandise.Free_Merchandise__c == null && freeoliIdtoOliMap.containsKey(itemIdtoOliMap.get(oldCartItem.Id).Id)){
								oliListToBeDeleted.add(freeoliIdtoOliMap.get(itemIdtoOliMap.get(oldCartItem.Id).Id));
							}
							if(oldCartMerchandise.Free_Merchandise__c != null && !freeoliIdtoOliMap.containsKey(itemIdtoOliMap.get(oldCartItem.Id).Id)){
								Order_Line_Item__c orderLineItemFree = new Order_Line_Item__c();
								for(Item__c item : freeMerchandiseIdToItemsMap.get(oldCartMerchandise.Free_Merchandise__c)){
									if(item.Quantity_On_Hand__c > 0){
										orderLineItemFree.Item__c = item.Id;
										break;
									}
								}
								orderLineItemFree.Order__c = itemIdtoOliMap.get(oldCartItem.Id).Order__c;
								orderLineItemFree.Free_Order_Line_Item__c =  itemIdtoOliMap.get(oldCartItem.Id).Id;
								orderLineItemFree.Quantity_Ordered__c = itemIdtoOliMap.get(oldCartItem.Id).Quantity_Ordered__c;
								orderLineItemFree.Total_Points_Redeemed_Text__c = 0;
								orderLineItemFreeList.add(orderLineItemFree);
							}
						}
					}
				}
			}
			if(!oliListToBeDeleted.isEmpty()){
				Delete oliListToBeDeleted;
			}
			if(!orderLineItemFreeList.isEmpty())
				insert orderLineItemFreeList;

			contactWrap.oldCartItems = oldCartItemsList;
			contactWrap.cartMerchandise = oldCartMerchantList;
			contactWrap.allMerchandise  = getMerchandise();
			return contactWrap;
		}
		else{
			return null;
		}
	}

	@AuraEnabled
	public static String createOrder(Item__c[] cartItemsList, String contactRec) 
	{
		upsertDraftOrder(cartItemsList, 'Submitted', contactRec,'orderSubmited');
		return 'Success';
	}

	@AuraEnabled
	public static List<Merchandise__c> upsertDraftOrder(Item__c[] cartItemsList, String isSubmitted, String contactRecJSON,String freeGiftItemWrapper)
	{
		List<Order_Line_Item__c> orderLineItemFreeList = new List<Order_Line_Item__c>();
		ItemGiftWrapper freeGiftItemWrapperRec ;
		if(freeGiftItemWrapper != 'orderSubmited' && freeGiftItemWrapper != 'No Free Item' && freeGiftItemWrapper != 'removeOrder')
			 freeGiftItemWrapperRec = (ItemGiftWrapper)JSON.deserialize(freeGiftItemWrapper, ItemGiftWrapper.class);
		
		String contactId;
		String orderId;
		List<User> userList = [SELECT Id, ContactId FROM USER WHERE Id=: UserInfo.getUserId()];
		List<Contact> contactList = [SELECT Id, Lifetime_Points_Earned__c, Lifetime_Points_Redeemed__c FROM Contact WHERE Id =:userList[0].ContactId];
		if(contactList.size() > 0){
			contactId = contactList[0].Id;
		}
		List<Item__c> cartItems = new List<Item__c>();
		Map<String,Item__c> merchantItemsMap = new Map<String,Item__c>();
        
		for(object obj : cartItemsList)
		{
			cartItems.add((Item__c)obj);
			merchantItemsMap.put(((Item__c)obj).Id, (Item__c)obj);
		}
		List<Order__c> orderList = [SELECT Id, Status__c,
										(SELECT Id, Item__c,Free_Order_Line_Item__c, Quantity_Ordered__c 
											FROM Order_Line_Items__r) 
										FROM Order__c 
										WHERE Status__c = 'Draft' 
										AND Contact__c =: contactId LIMIT 1];

		Map<Id, Order_Line_Item__c> idToOrderLineItemMap = new Map<Id, Order_Line_Item__c>();
        Map<Id, Order_Line_Item__c> idToOrderLineItemMapParent = new Map<Id, Order_Line_Item__c>();
		if(!orderList.isEmpty())
		{
			for(Order_Line_Item__c oli : orderList[0].Order_Line_Items__r){
				if(oli.Free_Order_Line_Item__c != null)
					idToOrderLineItemMap.put(oli.Free_Order_Line_Item__c,oli);
			}
            for(Order_Line_Item__c oli : orderList[0].Order_Line_Items__r){
                idToOrderLineItemMapParent.put(oli.Id,oli);
            }
		}

		List<Order_Line_Item__c> oliListToBeDeleted = new List<Order_Line_Item__c>();
		List<Order_Line_Item__c> oliListToBeUpserted = new List<Order_Line_Item__c>();
		List<Order_Line_Item__c> oliListToBeInsert = new List<Order_Line_Item__c>();
		Map<String, Order_Line_Item__c> oliMap = new Map<String, Order_Line_Item__c>();

		if(!orderList.isEmpty())
		{
			orderId = orderList[0].Id;
			for(Order_Line_Item__c oli : orderList[0].Order_Line_Items__r)
			{
				if(!merchantItemsMap.containsKey(oli.Item__c) && oli.Free_Order_Line_Item__c == null && freeGiftItemWrapper == 'removeOrder')
				{
					oliListToBeDeleted.add(oli);
				}
				else if(idToOrderLineItemMap.containsKey(oli.Free_Order_Line_Item__c) && oli.Free_Order_Line_Item__c != null && !merchantItemsMap.containsKey(idToOrderLineItemMapParent.get(oli.Free_Order_Line_Item__c).Item__c) && freeGiftItemWrapper == 'removeOrder')
				{	
					oliListToBeDeleted.add(idToOrderLineItemMap.get(oli.Free_Order_Line_Item__c));
				}
				else
				{
					if(!idToOrderLineItemMap.containsKey(oli.Free_Order_Line_Item__c))
						oliMap.put(oli.Item__c, oli);
				}
			}

			for(Item__c merchant : cartItems)
			{
				if(oliMap.containsKey(merchant.Id))
				{
					oliMap.get(merchant.Id).Quantity_Ordered__c  = merchant.Quantity_Redeemed__c;
					if(idToOrderLineItemMap.containsKey(oliMap.get(merchant.Id).Id)){
						idToOrderLineItemMap.get(oliMap.get(merchant.Id).Id).Quantity_Ordered__c = merchant.Quantity_Redeemed__c;
						oliListToBeUpserted.add(idToOrderLineItemMap.get(oliMap.get(merchant.Id).Id));
					}
					oliListToBeUpserted.add(oliMap.get(merchant.Id));
				}
				else
				{
					if(freeGiftItemWrapper != 'orderSubmited'){
						oliListToBeInsert.clear();
						Order_Line_Item__c orderLineItem = new Order_Line_Item__c();
						orderLineItem.Item__c = merchant.Id;
						orderLineItem.Order__c = orderId;
						orderLineItem.Quantity_Ordered__c = merchant.Quantity_Redeemed__c;
						oliListToBeInsert.add(orderLineItem);
						if(!oliListToBeInsert.isEmpty())
							insert oliListToBeInsert;

						if(freeGiftItemWrapper != 'No Free Item'){
							Order_Line_Item__c orderLineItemFree = new Order_Line_Item__c();
							orderLineItemFree.Item__c = freeGiftItemWrapperRec.freeMerchandiseItem.Id;
							orderLineItemFree.Order__c = orderId;
							orderLineItemFree.Free_Order_Line_Item__c =  oliListToBeInsert[0].Id;
							orderLineItemFree.Quantity_Ordered__c = oliListToBeInsert[0].Quantity_Ordered__c;
							orderLineItemFree.Total_Points_Redeemed_Text__c = 0;
							orderLineItemFreeList.add(orderLineItemFree);
						}

						if(!orderLineItemFreeList.isEmpty())
							upsert orderLineItemFreeList;
					}

				}
			}
			if(isSubmitted == 'Submitted'){
				Contact updatedCon = (Contact)JSON.deserialize(contactRecJSON,Contact.class);
				orderList[0].Status__c 		= 'Submitted';
				orderList[0].First_Name__c 	= updatedCon.FirstName;
				orderList[0].Last_Name__c 	= updatedCon.LastName;
				orderList[0].Email__c 		= updatedCon.Email;
				orderList[0].Phone__c 		= updatedCon.Phone;
				orderList[0].Street__c 		= updatedCon.MailingStreet;
				orderList[0].City__c 		= updatedCon.MailingCity;
				orderList[0].State__c 		= updatedCon.MailingState;
				orderList[0].Country__c 	= updatedCon.MailingCountry;
				orderList[0].ZipCode__c 	= updatedCon.MailingPostalCode;
				upsert orderList;
			}
			if(!oliListToBeDeleted.isEmpty()) 
				delete oliListToBeDeleted;
			if(!oliListToBeUpserted.isEmpty()) 
				upsert oliListToBeUpserted;
		}
		else
		{
			Order__c order = new Order__c(Contact__c = contactId, Status__c = 'Draft');
			insert order;
			List<Order_Line_Item__c> orderLineItemList = new List<Order_Line_Item__c>();
			
			for(Item__c merchant : cartItems) {
				Order_Line_Item__c orderLineItem = new Order_Line_Item__c();
				orderLineItem.Item__c = merchant.Id;
				orderLineItem.Order__c = order.Id;
				orderLineItem.Quantity_Ordered__c = merchant.Quantity_Redeemed__c;
				orderLineItemList.add(orderLineItem);
			}
			if(!orderLineItemList.isEmpty()) 
				insert orderLineItemList;

			
			if(freeGiftItemWrapper != 'No Free Item'){
				Order_Line_Item__c orderLineItemFree = new Order_Line_Item__c();
				orderLineItemFree.Item__c = freeGiftItemWrapperRec.freeMerchandiseItem.Id;
				orderLineItemFree.Order__c = order.Id;
				orderLineItemFree.Free_Order_Line_Item__c =  orderLineItemList[0].Id;
				orderLineItemFree.Quantity_Ordered__c = orderLineItemList[0].Quantity_Ordered__c;
				orderLineItemFree.Total_Points_Redeemed_Text__c = 0;
				orderLineItemFreeList.add(orderLineItemFree);
			}
			if(!orderLineItemFreeList.isEmpty()) 
				insert orderLineItemFreeList;
		}
		
		List<Merchandise__c> merchandiseList = getMerchandise();
		return merchandiseList;
	}

	@AuraEnabled
	public static Merchandise__c getFreeItem(Merchandise__c currentMerchandise) {
		Merchandise__c merchandise = [SELECT Id, Name, Cost__c, Description__c,Free_Merchandise__c, Estimated_Shipping_Cost__c, Picture__c, Point_Value__c, 
													Allow_Orders_for_Sold_Out_Items__c, Display_Sizes__c 
													FROM Merchandise__c 
													WHERE Point_Value__c != null 
													AND Id = :currentMerchandise.Id];
        
        
        Merchandise__c freeMerchandise	= [SELECT Id, Name,Cost__c, Description__c,Free_Merchandise__c, Estimated_Shipping_Cost__c, Picture__c, Point_Value__c, 
													Allow_Orders_for_Sold_Out_Items__c, Display_Sizes__c, 
														(SELECT Id, Name, Quantity_On_Hand__c, Quantity_Redeemed__c, Total_Quantity__c, Size__c 
														FROM Items__r)
													FROM Merchandise__c 
													WHERE Point_Value__c != null 
													AND Id = :merchandise.Free_Merchandise__c];
        
		return freeMerchandise; 		
	}
    
    @AuraEnabled
    public static ItemGiftWrapper getItemWrapper(Merchandise__c currentMerchandise,Item__c currentMerchandiseItem,Merchandise__c FreeMerchandise,Item__c FreeMerchandiseItem){
        ItemGiftWrapper itemgiftWrapper = new ItemGiftWrapper(currentMerchandiseItem,freeMerchandiseItem);
        return itemgiftWrapper;
    }

    @AuraEnabled 
    public static List<FreeMerchandiseLineItemWrapper> getFreeMerchandiseWrapper(Merchandise__c[] cartMerchandise, String contactRecJson) {
    	List<FreeMerchandiseLineItemWrapper> freeMerchantLineItemList	= new List<FreeMerchandiseLineItemWrapper>();
    	Map<Id,Item__c> itemMap 										= new Map<Id,Item__c>();
    	Map<Id,Order_Line_Item__c> oliMap 								= new Map<Id,Order_Line_Item__c>();
    	Contact contactRec 												= (Contact)JSON.deserialize(contactRecJSON,Contact.class);
    	List<Order__c> orderList = [SELECT Id, Status__c,
										(SELECT Id, Item__c,Free_Order_Line_Item__c, Quantity_Ordered__c 
											FROM Order_Line_Items__r) 
										FROM Order__c 
										WHERE Status__c = 'Draft' 
										AND Contact__c =: contactRec.Id LIMIT 1];

		List<Merchandise__c> allMerchandise =  getMerchandise();

		for(Merchandise__c merchant : allMerchandise){
			for(Item__c item : merchant.Items__r){
				itemMap.put(item.Id,item);
			}
		}

		for(Order_Line_Item__c oli : orderList[0].Order_Line_Items__r)
			oliMap.put(oli.Id,oli);

		for(Order_Line_Item__c oliItem : orderList[0].Order_Line_Items__r) {
			if(oliItem.Free_Order_Line_Item__c != null)
				freeMerchantLineItemList.add(new FreeMerchandiseLineItemWrapper(itemMap.get(oliMap.get(oliItem.Free_Order_Line_Item__c).Item__c),oliItem,itemMap.get(oliItem.Item__c)));
		}

		return freeMerchantLineItemList;
	}

	public class UserContactWrapp{
        @AuraEnabled public Contact contactDetail{get;set;}
        @AuraEnabled public List<CartQuantityWrap> oldCartItems {get; set;}
        @AuraEnabled public List<Merchandise__c> cartMerchandise {get; set;}
        @AuraEnabled public List<Merchandise__c> allMerchandise {get; set;}
    }
    public class CartQuantityWrap{
    	@AuraEnabled public Item__c oldCartItem {get; set;}
    	@AuraEnabled public Integer relatedMerchandisePointValue {get; set;}
        @AuraEnabled public Integer quantityOrdered {get; set;}
    }

    public class ItemGiftWrapper{
    	@AuraEnabled public Item__c currentMerchandiseItem 			{get;set;}
		@AuraEnabled public Item__c freeMerchandiseItem 				{get;set;}
		public ItemGiftWrapper(Item__c currentMerchandiseItem,Item__c freeMerchandiseItem) {
	    	this.currentMerchandiseItem 	= currentMerchandiseItem;
	    	this.freeMerchandiseItem 	= freeMerchandiseItem;
	    }
    }

    public class FreeMerchandiseLineItemWrapper{
    	@AuraEnabled public Item__c merchantItem 									{get;set;}
    	@AuraEnabled public Order_Line_Item__c freeMerchantLineItem 				{get;set;}
		@AuraEnabled public Item__c freeMerchantItem 								{get;set;}
		public FreeMerchandiseLineItemWrapper(Item__c merchantItem,Order_Line_Item__c freeMerchantLineItem,Item__c freeMerchantItem) {
	    	this.merchantItem 			= merchantItem; 
	    	this.freeMerchantLineItem 	= freeMerchantLineItem;
	    	this.freeMerchantItem 		= freeMerchantItem;

	    }
    } 
}