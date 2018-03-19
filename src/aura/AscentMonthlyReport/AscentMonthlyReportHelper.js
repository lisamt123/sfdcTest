({
    doPicklistValue : function(component,helper) {
        var doInitAction = component.get("c.doInitAscMetric");
       	doInitAction.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") { 
                component.set("v.monthList",response.getReturnValue().monthList);
                component.set("v.MonthSelectAttr",response.getReturnValue().currentMonthName);
            }
            window.setTimeout(
                $A.getCallback( function() {
                    component.find("MonthSelectId").set("v.value",response.getReturnValue().currentMonthName);
            	})
            );
        });
        $A.enqueueAction(doInitAction);
    },
    
    doInitHelper: function(component,helper,selected) {
        var action = component.get("c.ascendMetricValues");
        action.setParams({ 'selectedMonthName' : selected});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                if((response.getReturnValue().ascMetricList).length > 0 ) {
                    component.set("v.ascendMetricList",response.getReturnValue().ascMetricList);
                    component.set("v.isEmpty", false);
                } else {
                    var emptyList = [];
                    component.set("v.ascendMetricList",emptyList);
                    component.set("v.isEmpty", true);
                }
                component.set("v.mainCheckbx", false);
            }
        });
        $A.enqueueAction(action);
    },
    sendAscentReport : function(component,event,helper) {
         var action = component.get("c.sendAscentReportEmail");
        action.setParams({"accountAscendMetricWrapper" : JSON.stringify(component.get("v.ascendMetricList"))});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                if(response.getReturnValue() == 'success') {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "success",
                        "message": "Successfully Sent Email."
                    });
                    toastEvent.fire();
                }
                else if(response.getReturnValue() == 'NotSelected'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "error",
                        "message": "Please select a record."
                    });
                    toastEvent.fire();
                }
                else if(response.getReturnValue() == 'No Contact Role'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "error",
                        "message": "No Contact Role found on Selected Record."
                    });
                    toastEvent.fire();
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "error",
                        "message": "Email on Contact Role is empty or not correct."
                    });
                    toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },
})