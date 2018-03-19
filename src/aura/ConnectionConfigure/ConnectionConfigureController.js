({
    doInit : function(component, event, helper) {
        helper.doInitHelper(component,event,helper);
    },
    cancelClick : function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": component.get('v.recordId')
        });
        navEvt.fire();
    },
    onGroup : function(component, event, helper) {
        helper.onGroupHelper(component,event,helper);
    }, 
    updateConnection : function(component, event, helper) {
        helper.updateConnectionHelper(component,event,helper);
    }, 
})