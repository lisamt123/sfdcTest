({
	checkFreeItem : function(component) {
        var currentMerchandise = component.get("v.CartMerchandise");
        var action = component.get("c.getFreeItem");
        action.setParams({ 'currentMerchandise' : currentMerchandise});
        action.setCallback(this, function(response) {
            var state = response.getState();
            var oppRec = response.getReturnValue();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.FreeMerchandise",response.getReturnValue())
                var freeMerchandise = response.getReturnValue();
                if(freeMerchandise.Display_Sizes__c)
                {
                    var theOrder = ["Select","S","M","L","XL","XXL"];
                    var sizeArray1 = ["Select"];
                    component.set("v.isDisplaySizes", true);
                    component.set("v.isAllowOrder", false);
                    for(var i = 0; i < response.getReturnValue().Items__r.length; i++)
                    {
                        sizeArray1.push(freeMerchandise.Items__r[i].Size__c);
                    }
                    var orderedArray = [];
                    for (var j = 0; j < theOrder.length; j++) {
                        if (sizeArray1.indexOf(theOrder[j]) > -1) {
                            orderedArray.push(theOrder[j]);
                        }
                    }
                    component.set("v.sizeArray", orderedArray);
                }
            }
        });
        $A.enqueueAction(action);
        
    },
})