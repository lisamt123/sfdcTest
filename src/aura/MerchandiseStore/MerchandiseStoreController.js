({
	doInit : function(component, event, helper) 
	{
		var action = component.get("c.getPoints");
		action.setCallback(this, function(response)
		{
			var state = response.getState();
			if(component.isValid() && state === "SUCCESS")
			{
				if(response.getReturnValue() != null)
				{
					var totalPoints = response.getReturnValue().contactDetail.Lifetime_Points_Earned__c - response.getReturnValue().contactDetail.Lifetime_Points_Redeemed__c;
					var cartItems = [];
					var cartPoints = 0;
					for(var i = 0; i < (response.getReturnValue().oldCartItems).length; i++)
					{
						(response.getReturnValue().oldCartItems)[i].oldCartItem.Quantity_Redeemed__c = (response.getReturnValue().oldCartItems)[i].quantityOrdered;
						cartItems.push((response.getReturnValue().oldCartItems)[i].oldCartItem);
						cartPoints += (response.getReturnValue().oldCartItems)[i].relatedMerchandisePointValue * (response.getReturnValue().oldCartItems)[i].quantityOrdered;
					}
					totalPoints = totalPoints + cartPoints;
					if((response.getReturnValue().oldCartItems).length > 0)
					{
						var toastEvent = $A.get("e.force:showToast");
					    toastEvent.setParams({
					        "type": "success",
					        "message": "The items you selected in your prior session have been restored in your cart."
					    });
					    toastEvent.fire();
					}
					component.set("v.CartItems", cartItems);
					component.set("v.ContactRec", response.getReturnValue());
					component.set("v.allMerchandise",response.getReturnValue().allMerchandise);
					component.set("v.CartMerchandises", response.getReturnValue().cartMerchandise);
					component.set("v.cartPoints", parseInt(cartPoints));
					component.set("v.availablePoints", parseInt(totalPoints));
				}
			}
		});
		$A.enqueueAction(action);
	},
	verifyOrder : function(component, event, helper)
	{
		component.set("v.buttonBoolean",true);
		var firstStage = component.find("firstStage");
		$A.util.addClass(firstStage,'slds-is-complete');
		$A.util.removeClass(firstStage,'slds-is-current');
		var secondStage = component.find("secondStage");
		$A.util.addClass(secondStage,'slds-is-current');
		$A.util.removeClass(secondStage,'slds-is-incomplete');
	},
	completeOrder : function(component, event, helper)
	{
		var action = component.get("c.getFreeMerchandiseWrapper");
        action.setParams({ 'cartMerchandise' : component.get("v.CartMerchandises")  ,'contactRecJson' : JSON.stringify(component.get("v.ContactRec").contactDetail) });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
            	component.set("v.FreeMerchandiseLineItemWrapper",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);

		var secondStage = component.find("secondStage");
		$A.util.addClass(secondStage,'slds-is-complete');
		$A.util.removeClass(secondStage,'slds-is-current');
		var thirdStage = component.find("thirdStage");
		$A.util.addClass(thirdStage,'slds-is-current');
		$A.util.removeClass(thirdStage,'slds-is-incomplete');
		component.set("v.submitBoolean",true);
	},
	backToStore : function(component, event, helper)
	{
		component.set("v.buttonBoolean",false);
		component.set("v.submitBoolean",false);
		var firstStage = component.find("firstStage");
		$A.util.addClass(firstStage,'slds-is-current');
		$A.util.removeClass(firstStage,'slds-is-complete');
		var secondStage = component.find("secondStage");
		$A.util.addClass(secondStage,'slds-is-incomplete');
		$A.util.removeClass(secondStage,'slds-is-current');
	},
	backToMerchandiseStore : function(component, event, helper)
	{
		component.set("v.buttonBoolean",true);
		component.set("v.submitBoolean",false);
		var secondStage = component.find("secondStage");
		$A.util.addClass(secondStage,'slds-is-current');
		$A.util.removeClass(secondStage,'slds-is-complete');
		var thirdStage = component.find("thirdStage");
		$A.util.addClass(thirdStage,'slds-is-incomplete');
		$A.util.removeClass(thirdStage,'slds-is-current');		
	},
	submitOrder : function(component, event, helper)
	{
		$A.createComponent(
	        "c:SubmitOrder",
	        {
	            "CartItems": component.get("v.CartItems"),
	            "billTotal": component.get("v.cartPoints"),
	            "ContactRec": component.get("v.ContactRec"),
	            "CartMerchandises": component.get("v.CartMerchandises"),
	            "FreeMerchandiseLineItemWrapper" : component.get("v.FreeMerchandiseLineItemWrapper")
	        },
	        function(newItem, status, errorMessage){
	            if (status === "SUCCESS") {
	            	var targetCmp = component.find('component-container');
	            	targetCmp.set("v.body", []);
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
	    var thirdStage = component.find("thirdStage");
		$A.util.addClass(thirdStage,'slds-is-complete');
		$A.util.removeClass(thirdStage,'slds-is-current');
		var fourthStage = component.find("fourthStage");
		$A.util.addClass(fourthStage,'slds-is-complete');
		$A.util.removeClass(fourthStage,'slds-is-incomplete');
		var returnStoreBtn = component.find("returnStoreBtn");
		$A.util.addClass(returnStoreBtn,'slds-hide');
		var submitOrderBtn = component.find("submitOrderBtn");
		$A.util.addClass(submitOrderBtn,'slds-hide');
		helper.verifyCartItemsQuantity(component, event, helper);
	},
	showLoading: function (cmp, event) {
        var spinner = cmp.find("Spinner");
        $A.util.removeClass(spinner, "slds-hide");
        $A.util.addClass(spinner, "slds-show");
    },
    hideLoading: function (cmp, event) {
        var spinner = cmp.find("Spinner");
        $A.util.addClass(spinner, "slds-hide");
        $A.util.removeClass(spinner, "slds-show");
    }
})