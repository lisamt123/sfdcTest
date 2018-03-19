({
    doInitHelper : function(component, event, helper) {
        this.removeHide(component);
        var action = component.get("c.retrieveAvailability");
        action.setParams({'direction':component.get("v.direction"),'startDateString':component.get("v.startDateString"),'endDateString':component.get("v.endDateString")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var availabilityListLeftJS = response.getReturnValue().availabilityWrapperListFirst;
                for(var key in availabilityListLeftJS) 
                {
                    var number = availabilityListLeftJS[key].avail.Forecasted_Hours__c;
                    number = (Math.round(number * 4) / 4).toFixed(2);
                    availabilityListLeftJS[key].avail.Forecasted_Hours__c = number;

                    var number1 = availabilityListLeftJS[key].avail.Available_Hours__c;
                    number1 = (Math.round(number1 * 4) / 4).toFixed(2);
                    availabilityListLeftJS[key].avail.Available_Hours__c = number1;

                    var number2 = availabilityListLeftJS[key].avail.Hours_Worked__c;
                    number2 = (Math.round(number2 * 4) / 4).toFixed(2);
                    availabilityListLeftJS[key].avail.Hours_Worked__c = number2;
                }
                var availabilityListRightJS = response.getReturnValue().availabilityWrapperListSecond;
                for(var key in availabilityListRightJS) 
                {
                    var number = availabilityListRightJS[key].avail.Forecasted_Hours__c;
                    number = (Math.round(number * 4) / 4).toFixed(2);
                    availabilityListRightJS[key].avail.Forecasted_Hours__c = number;

                    var number1 = availabilityListRightJS[key].avail.Available_Hours__c;
                    number1 = (Math.round(number1 * 4) / 4).toFixed(2);
                    availabilityListRightJS[key].avail.Available_Hours__c = number1;

                    var number2 = availabilityListRightJS[key].avail.Hours_Worked__c;
                    number2 = (Math.round(number2 * 4) / 4).toFixed(2);
                    availabilityListRightJS[key].avail.Hours_Worked__c = number2;
                }
                component.set("v.disableNext",response.getReturnValue().disableNext);
                component.set("v.disablePrevious",response.getReturnValue().disablePrevious);
                component.set("v.availabilityListLeft",availabilityListLeftJS);
                component.set("v.availabilityListRight",availabilityListRightJS);
                component.set("v.startDateString",response.getReturnValue().startDateString);
                component.set("v.endDateString",response.getReturnValue().endDateString);
            }  
            this.addHide(component);              
        });
        $A.enqueueAction(action);
    },
    addHide : function(component) {
        var spinnerMain =  component.find("Spinner");
        $A.util.addClass(spinnerMain, "slds-hide");
    },
    
    removeHide: function(component) {
        var spinnerMain =  component.find("Spinner");
        $A.util.removeClass(spinnerMain, "slds-hide");
    }, 
    openDialogHelper :function(component,event,helper){  
        this.removeHide(component);
        var id = event.target.getAttribute('id');   
        this.addHide(component);
    },
})