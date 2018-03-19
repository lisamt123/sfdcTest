({
    doInit : function(component, event, helper) {
        helper.checkFreeItem(component);
        var freeMerchandise = component.get("v.FreeMerchandise");
    },
    defaultCloseAction : function(component, event, helper) {
        component.destroy();
    },
    sizeChange : function(component, event, helper)
    {
        var FreeMerchandise = component.get("v.FreeMerchandise");
        var selectedSize = component.find("sizePick").get("v.value");
        if(selectedSize == "Select")
        {
            component.set("v.isSizeSelected", false);
            component.set("v.submitBoolean",true);
        }
        else
        {
            for(var i = 0; i < FreeMerchandise.Items__r.length; i++)
            {
                if(FreeMerchandise.Items__r[i].Size__c == selectedSize)
                {
                    component.set("v.FreeMerchandiseItem",FreeMerchandise.Items__r[i]);
                    break;
                }
            }
            component.set("v.isSizeSelected", true);
            component.set("v.submitBoolean",false);
        }
    },
    addAsGift : function(component,event,helper){
        
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
        if(isAddToCart) {
            var FreeMerchandiseItem = component.get("v.FreeMerchandiseItem");
            var FreeMerchandise	= component.get("v.FreeMerchandise");
            var CartMerchandiseItem = component.get("v.CartMerchandiseItem");
            var CartMerchandise = component.get("v.CartMerchandise");
            var componentParentRefrence = component.get("v.componentParentRefrence");
            var action = component.get("c.getItemWrapper");
            action.setParams({ 'currentMerchandise' : CartMerchandise , 'currentMerchandiseItem' : CartMerchandiseItem,'FreeMerchandise' : FreeMerchandise,'FreeMerchandiseItem' : FreeMerchandiseItem});
            action.setCallback(this, function(response) {
                var state = response.getState();
                var itemGiftWrapper = response.getReturnValue();
                if (component.isValid() && state === "SUCCESS") {
                    var event = component.getEvent("addToCart");
                    event.setParams({"freeGiftItemWrapper": JSON.stringify(response.getReturnValue()),"CartMerchandiseItem": component.get("v.CartMerchandiseItem"), "CartMerchandise": component.get("v.CartMerchandise"),"freeMerchandise" : component.get("v.FreeMerchandise"),"freeMerchandiseItem" : component.get("v.FreeMerchandiseItem") });
                    event.fire();
                    componentParentRefrence.destroy();
                }
                 });
            $A.enqueueAction(action);
        }
    },
})