({
    doInit : function(component, event, helper)
    {
        var obj = component.get("v.Value");
        if(!$A.util.isEmpty(obj)){
            var action = component.get("c.populateRecordName");
            action.setParams({
                "recordId": component.get("v.Value"),
                "sObjectAPIName": component.get("v.sObjectAPIName")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    component.set("v.searchString", response.getReturnValue());
                    var lookupList = component.find("lookuplist");
                    $A.util.addClass(lookupList, 'slds-hide');
                    $A.util.removeClass(lookupList, 'slds-show');
                    var inputElement = component.find('lookup');
                    $A.util.addClass(inputElement, 'slds-hide');
                    $A.util.removeClass(inputElement, 'slds-show');
                    var lookupPill = component.find("lookup-pill");
                    $A.util.removeClass(lookupPill, 'slds-hide');
                    $A.util.addClass(lookupPill, 'slds-show');
                    var lookupDiv = component.find('lookup-div');
                    $A.util.addClass(lookupDiv, 'slds-has-selection');
                }
            });
            $A.enqueueAction(action);
        }
    },
    search: function(cmp, event, helper) {
        helper.doSearch(cmp);
    },
    select: function(cmp, event, helper) {
        helper.handleSelection(cmp, event);
    },
    clear: function(cmp, event, helper) {
        helper.clearSelection(cmp);
    },
    clearAllSelection : function(cmp, event, helper) {
        if(cmp.get("v.isDisabled"))
            helper.clearSelection(cmp);
    },
    InitialValues : function(cmp, event, helper) 
    {
        helper.initialSelection(cmp, event, helper);
    },
    createRecord : function (component, event, helper) 
    {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": component.get("v.sObjectAPIName")
        });
        createRecordEvent.fire();
    },
    onBlur: function(component, event, helper) 
    {
        event.stopPropagation();
        helper.onInputBlur(component, event, helper);
    }
})