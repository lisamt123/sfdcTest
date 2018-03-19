({
    checkFreeItem : function(component) {
        var currentMerchandise = component.get("v.CurrentMerchandiseItem");
        var action = component.get("c.getFreeItem");
        action.setParams({ 'currentMerchandise' : currentMerchandise});
        action.setCallback(this, function(response) {
            var state = response.getState();
            var oppRec = response.getReturnValue();
            if (component.isValid() && state === "SUCCESS") {
                console.log(response.getReturnValue());
                component.set("v.FreeMerchandise",response.getReturnValue())
                component.set("v.FreeMerchandiseItem",response.getReturnValue().Items__r[0]);
                var freeMerchandise = response.getReturnValue();
                
            }
        });
        $A.enqueueAction(action);
        
    },
})