({
	verifyCartItemsQuantity : function(component, event, helper) 
	{
		var cartItems = component.get("v.CartItems");
		var cartItemsArray = [];
		for(var k = 0; k < cartItems.length; k++)
		{
			cartItemsArray.push(cartItems[k]);
		}
		var contactRecToUpdate = JSON.stringify(component.get("v.ContactRec").contactDetail);
		var action = component.get("c.createOrder");
		action.setParams({
			"cartItemsList" : cartItemsArray,
			"contactRec" : contactRecToUpdate
		});
		action.setCallback(this, function(response)
		{
			var state = response.getState();
			if(component.isValid() && state === "SUCCESS")
			{
				var thirdStage = component.find("thirdStage");
				$A.util.addClass(thirdStage,'slds-is-complete');
				$A.util.removeClass(thirdStage,'slds-is-current');
				component.set("v.submitDisabled", true);
			}
		});
		$A.enqueueAction(action);
	}
})