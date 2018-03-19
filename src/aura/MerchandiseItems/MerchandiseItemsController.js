({
	doInit : function(component, event, helper) 
	{
		helper.getAllMerchandise(component, event, helper);
	},
	handlesingleItem : function(component, event, helper)
	{
		var indx = event.target.getAttribute("data-index");
		var merchandiseList = component.get("v.MerchandiseList");
		var cartList = component.get("v.CartItems");
		var currentMerchantItemId = merchandiseList[indx];
		for(var i = 0; i < currentMerchantItemId.Items__r.length; i++)
		{
			for(var j = 0; j < cartList.length; j++)
			{
				if(currentMerchantItemId.Items__r[i].Id == cartList[j].Id)
				{
					currentMerchantItemId.Items__r[i].Quantity_Redeemed__c = cartList[j].Quantity_Redeemed__c;
					break;
				}
			}
		}
		component.set("v.CurrentMerchandise", currentMerchantItemId);
		$A.createComponent(
	        "c:MerchandiseItem",
	        {
	            "title": component.get("v.CurrentMerchandise").Name,
	            "CurrentMerchandiseItem": component.get("v.CurrentMerchandise"),
	            "RemainingPoints" : component.get("v.availablePoints"),
	            "CartItems" : component.get("v.CartItems")
	        },
	        function(newItem, status, errorMessage){
	            if (status === "SUCCESS") {
	            	var targetCmp = component.find('ModalDialogPlaceholder');
	                var body = targetCmp.get("v.body");
	                body.push(newItem);
	                targetCmp.set("v.body", body);
	            }
	            else if (status === "INCOMPLETE") {
	                console.log("No response from server or client is offline.")
	            }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
	            }
	        }
	    );
	},

	handleComponentEvent : function(component, event, helper)
	{
		var cartItems = component.get("v.CartItems");
		var cartMerchandises = component.get("v.CartMerchandises");
		var merchantItem = event.getParam("CartMerchandiseItem");
		var merchandise = event.getParam("CartMerchandise");
		var freeMerchandise = event.getParam("freeMerchandise");
		var freeMerchandiseItem = event.getParam("freeMerchandiseItem");
		var freeGiftItemWrapper = event.getParam("freeGiftItemWrapper");
		var isNew = true;
		var isNewMerchandise = true;
		var totalPoints = 0;
		for(var m = 0; m < cartMerchandises.length; m++)
		{
			if(cartMerchandises[m].Id == merchandise.Id)
			{
				cartMerchandises[m] = merchandise;
				isNewMerchandise = false;
			}
		}
		for(var i=0; i<cartItems.length ; i++ ) {
			if(cartItems[i].Id == merchantItem.Id) {
				cartItems[i] = merchantItem;
				component.set("v.CartItems", cartItems);
				isNew = false;
			}
		}
		if(isNewMerchandise)
		{
			cartMerchandises.push(merchandise);
			component.set("v.CartMerchandises",cartMerchandises);
		}
		if(isNew){
			cartItems.push(merchantItem);
			component.set("v.CartItems", cartItems);
		}

		cartItems = component.get("v.CartItems");
		cartMerchandises = component.get("v.CartMerchandises");
		var cartItemsArray = [];
		for(var k = 0; k < cartItems.length; k++)
		{
			var reletedMerchandise;
			for(var j = 0; j < cartMerchandises.length; j++)
			{
				if(cartItems[k].Merchandise__c == cartMerchandises[j].Id)
				{
					reletedMerchandise = cartMerchandises[j];
					break;
				}
			}
			cartItemsArray.push(cartItems[k]);
			totalPoints += reletedMerchandise.Point_Value__c * cartItems[k].Quantity_Redeemed__c;
		}
		
		component.set("v.cartPoints", parseInt(totalPoints));
		var action = component.get("c.upsertDraftOrder");
		action.setParams({
			"cartItemsList" : cartItemsArray,
			"isSubmitted" : "Drafted",
			"contactRecJSON" : "DummyContactRec",
			"freeGiftItemWrapper" : freeGiftItemWrapper
		});
		action.setCallback(this, function(response)
		{
			var state = response.getState();
			if(component.isValid() && state === "SUCCESS")
			{
				//console.log(response.getReturnValue());
			}
		});
		$A.enqueueAction(action);
	}
})