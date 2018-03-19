({
	doInit : function(component, event, helper) {
        //!isNaN(a[column]) && !isNaN(parseInt(a[column]))component.find("availableHours").get("v.value")
        if(!isNaN(component.find("availableHours").get("v.value")) && !isNaN(parseInt(component.find("availableHours").get("v.value")))) {
            var action = component.get("c.retrieveAvailability");
            action.setParams({'availability':component.get("v.availability")});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                }
            });
            $A.enqueueAction(action);
        }
	},
    setIsDisabled : function(component, event, helper) {

        var action = component.get("c.retrieveIsDisabled");
        action.setParams({'availability':component.get("v.availability")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.isDisabled",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
})