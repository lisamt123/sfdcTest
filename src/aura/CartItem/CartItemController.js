({
	doInit : function(component, event, helper) 
	{
		component.set("v.oldRedeemedValue",component.get("v.item").Quantity_Redeemed__c);
	},
	confirmDelete : function(component, event, helper) {
		var modalDiv = component.find("delModal");
		var backdropDiv = component.find("delBackdrop");
		$A.util.toggleClass(modalDiv, "slds-fade-in-open");
		$A.util.toggleClass(backdropDiv, "slds-backdrop_open");
	},
	cancelDelete : function(component, event, helper) {
		var modalDiv = component.find("delModal");
		var backdropDiv = component.find("delBackdrop");
		$A.util.toggleClass(modalDiv, "slds-fade-in-open");
		$A.util.toggleClass(backdropDiv, "slds-backdrop_open");
	},
	removeItem : function(component, event, helper) {
		component.set("v.totalPoints", parseInt(component.get("v.totalPoints") - (component.get("v.merchant").Point_Value__c * component.get("v.item").Quantity_Redeemed__c)));
		var cartItems = component.get("v.CartItems");

		var newcartItems = [];
		for(var key in cartItems)
		{
			console.log(cartItems[key].Id);
			if(component.get("v.item").Id != cartItems[key].Id)
			{
				newcartItems.push(cartItems[key]);
			}
		}
		component.set("v.CartItems", newcartItems);
		var action = component.get("c.upsertDraftOrder");
		action.setParams({
			"cartItemsList" : newcartItems,
			"isSubmitted" : "Drafted",
			"contactRecJSON" : "DummyContactRec",
			"freeGiftItemWrapper"   : "removeOrder"
		});
		action.setCallback(this, function(response)
		{
			var state = response.getState();
			if(component.isValid() && state === "SUCCESS")
			{
                //component.destroy();
			}
		});
		$A.enqueueAction(action);
	},
	updateAvailablePoints : function(component,event) {
		var item = component.get("v.item");
		var remainingPt = parseInt(component.get("v.RemainingPoints"));
		var totalPts = parseInt(component.get("v.totalPoints"));
		var merchantvalue = parseInt(component.get("v.merchant").Point_Value__c);
		if($A.util.isEmpty(item.Quantity_Redeemed__c)) {
            item.Quantity_Redeemed__c  = 1;
        }
        component.set("v.item",item);
        component.set("v.totalPoints", parseInt(component.get("v.totalPoints") + component.get("v.merchant").Point_Value__c * (component.get("v.item").Quantity_Redeemed__c > component.get("v.oldRedeemedValue") ?  component.get("v.item").Quantity_Redeemed__c - component.get("v.oldRedeemedValue") : component.get("v.item").Quantity_Redeemed__c - component.get("v.oldRedeemedValue")))); 
		if(0 > component.get("v.RemainingPoints")){
			item.Quantity_Redeemed__c = Math.floor((remainingPt + (component.get("v.oldRedeemedValue") * merchantvalue)) / merchantvalue);
			var changedQty = parseInt(component.get("v.oldRedeemedValue") - item.Quantity_Redeemed__c);
			component.set("v.item",item);
        	component.set("v.totalPoints", parseInt((totalPts - (changedQty * merchantvalue))));// + component.get("v.merchant").Point_Value__c * (component.get("v.item").Quantity_Redeemed__c > component.get("v.oldRedeemedValue") ?  component.get("v.item").Quantity_Redeemed__c - component.get("v.oldRedeemedValue") : component.get("v.item").Quantity_Redeemed__c - component.get("v.oldRedeemedValue"))));
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "error",
                "message": "You don't have sufficient points to order this quantity for this item."
            });
            toastEvent.fire();
        }
         
        component.set("v.oldRedeemedValue", component.get("v.item").Quantity_Redeemed__c);
    }
})