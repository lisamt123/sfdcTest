({
    doInit : function(component, event, helper) {
        var remainingPoints = component.get("v.RemainingPoints");
        var currentMerchandise = component.get("v.CurrentMerchandiseItem");
        component.set("v.submitBoolean", true);
        if(remainingPoints < currentMerchandise.Point_Value__c)
        {
            component.set("v.selectBoolean", true);
            var toastEvent1 = $A.get("e.force:showToast");
            toastEvent1.setParams({
                "type": "error",
                "message": "You don't have enough points for this."
            });
            toastEvent1.fire();
        }
        else
        {
            var cartItems = component.get("v.CartItems");
            var cartItemsIdSet = [];
            for(var r = 0; r < cartItems.length; r++)
            {
                cartItemsIdSet.push(cartItems[r].Id);
            }
            for(var k = 0; k < currentMerchandise.Items__r.length; k++)
            {
                if(!cartItemsIdSet.includes(currentMerchandise.Items__r[k].Id))
                {
                    currentMerchandise.Items__r[k].Quantity_Redeemed__c = 1;
                }
            }
            if(currentMerchandise.Display_Sizes__c && currentMerchandise.Allow_Orders_for_Sold_Out_Items__c)
            {
                component.set("v.isDisplaySizes", true);
                component.set("v.isAllowOrder", true);
                var sizeArray = ["Select","S","M","L","XL","XXL"];
                component.set("v.sizeArray", sizeArray);
            }
            else if(currentMerchandise.Display_Sizes__c)
            {
                var theOrder = ["Select","S","M","L","XL","XXL"];
                var sizeArray1 = ["Select"];
                component.set("v.isDisplaySizes", true);
                component.set("v.isAllowOrder", false);
                for(var i = 0; i < currentMerchandise.Items__r.length; i++)
                {
                    sizeArray1.push(currentMerchandise.Items__r[i].Size__c);
                }
                var orderedArray = [];
                for (var j = 0; j < theOrder.length; j++) {
                    if (sizeArray1.indexOf(theOrder[j]) > -1) {
                        orderedArray.push(theOrder[j]);
                    }
                }
                component.set("v.sizeArray", orderedArray);
            }
            else
            {
                component.set("v.CurrentItem",currentMerchandise.Items__r[0]);
                component.set("v.isSizeSelected", true);
                component.set("v.submitBoolean",false);
            }
        }

        if(currentMerchandise.Free_Merchandise__c != null && currentMerchandise.Free_Merchandise__c != 'undefined')
            helper.checkFreeItem(component);
    },
    
    defaultCloseAction : function(component, event, helper) {
        component.destroy();

    },
    addToCart : function(component, event, helper) {
        var isAddToCart = true;
        if(!component.get("v.isSizeSelected"))
        {
            isAddToCart = false;
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "error",
                "message": "Please select size to proceed."
            });
            toastEvent.fire();
        }
        else if(component.get("v.CurrentItem").Quantity_Redeemed__c == 0)
        {
            isAddToCart = false;
            var toastEvent1 = $A.get("e.force:showToast");
            toastEvent1.setParams({
                "type": "error",
                "message": "Please select quantity to proceed."
            });
            toastEvent1.fire();
        }
        if(isAddToCart)
        {
            var FreeMerchandiseItem = component.get("v.FreeMerchandiseItem");
            var FreeMerchandise = component.get("v.FreeMerchandise");
            var CartMerchandiseItem = component.get("v.CartMerchandiseItem");
            var CartMerchandise = component.get("v.CartMerchandise");
            var status = component.get("v.CurrentMerchandiseItem").Free_Merchandise__c;
            if(status != null && status != 'undefined' && status != ''){
                if(FreeMerchandise.Display_Sizes__c){
                    $A.createComponent(
                        "c:FreeMerchandiseItem",
                        {
                            "CartMerchandiseItem": component.get("v.CurrentItem"),
                            "CartMerchandise": component.get("v.CurrentMerchandiseItem"),
                            "componentParentRefrence" : component
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
                }
                else{
                    var action = component.get("c.getItemWrapper");
                    action.setParams({ 'currentMerchandise' : CartMerchandise , 'currentMerchandiseItem' : CartMerchandiseItem,'FreeMerchandise' : FreeMerchandise,'FreeMerchandiseItem' : FreeMerchandiseItem});
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        var itemGiftWrapper = response.getReturnValue();
                        if (component.isValid() && state === "SUCCESS") {
                            var event = component.getEvent("addToCart");
                            event.setParams({"freeGiftItemWrapper":JSON.stringify(response.getReturnValue()),"CartMerchandiseItem": component.get("v.CurrentItem"), "CartMerchandise": component.get("v.CurrentMerchandiseItem")});
                            event.fire();
                            component.destroy();
                        }
                    });
                    $A.enqueueAction(action);
                }
                
            }
            else{
                var event = component.getEvent("addToCart");
                event.setParams({"freeGiftItemWrapper":"No Free Item","CartMerchandiseItem": component.get("v.CurrentItem"), "CartMerchandise": component.get("v.CurrentMerchandiseItem")});
                event.fire();
                component.destroy();

            }
		}
    },
    updateAvailablePoints : function(component,event) {
        var maxVal = parseInt(event.target.getAttribute("max"));
        var minVal = parseInt(event.target.getAttribute("min"));
        var currentVal = parseInt(event.target.value);
        var merchantItem = component.get("v.CurrentMerchandiseItem");
        var currentItem = component.get("v.CurrentItem");
        if(currentVal < minVal || currentVal > maxVal)
        {
            currentItem.Quantity_Redeemed__c = maxVal;
        }
        else if(Number.isNaN(currentVal)) {
            currentItem.Quantity_Redeemed__c = minVal;
        }
        component.set("v.CurrentItem",currentItem);
        var cartItems = component.get("v.CartItems");
        var currentItem = component.get("v.CurrentItem");
        var oldQuantity = 0;
        for(var i=0; i<cartItems.length ; i++ ) {
            if(cartItems[i].Id == currentItem.Id)
                oldQuantity = cartItems[i].Quantity_Redeemed__c;
        }
        var quantity = currentItem.Quantity_Redeemed__c;
        currentItem.Quantity_Redeemed__c = parseInt(quantity);
        component.set("v.CurrentItem",currentItem);
        quantity -= oldQuantity;
        var pointsRequired = quantity * merchantItem.Point_Value__c;
        var remainingPoints = component.get("v.RemainingPoints");
        if(pointsRequired > remainingPoints){
            currentItem.Quantity_Redeemed__c = Math.floor((component.get("v.RemainingPoints") + (oldQuantity * merchantItem.Point_Value__c)) / merchantItem.Point_Value__c);
            component.set("v.CurrentItem",currentItem);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "error",
                "message": "You don't have sufficient points to order this quantity for this item."
            });
            toastEvent.fire();
        }
        else {
            component.set("v.submitBoolean",false);
        }
    },
    sizeChange : function(component, event, helper)
    {
        var currentMerchandise = component.get("v.CurrentMerchandiseItem");
        var selectedSize = component.find("sizePick").get("v.value");
        if(selectedSize == "Select")
        {
            component.set("v.isSizeSelected", false);
            component.set("v.submitBoolean",true);
        }
        else
        {
            for(var i = 0; i < currentMerchandise.Items__r.length; i++)
            {
                if(currentMerchandise.Items__r[i].Size__c == selectedSize)
                {
                    component.set("v.CurrentItem",currentMerchandise.Items__r[i]);
                    break;
                }
            }
            component.set("v.isSizeSelected", true);
            component.set("v.submitBoolean",false);
        }
    }
})