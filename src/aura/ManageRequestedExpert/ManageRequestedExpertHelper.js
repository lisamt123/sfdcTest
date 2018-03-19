({
	retriveRatePickVals: function(component) {
        var action = component.get("c.getRatePickVals");
        action.setParams({ 
            'role' : component.get("v.requestedExpert").Role__c,
            'region' : component.get("v.requestedExpert").Region__c,
            'workRequest' : component.get("v.workRequest")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                console.log('Rates : ', response.getReturnValue());
                component.set("v.ratePickValues", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
})