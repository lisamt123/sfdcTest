({
	doInit : function(component, event, helper) {
        helper.getProjectAssignWrapper(component);
        helper.doInitHelper(component,helper);
    },
    cancelClick : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    saveClick : function(component,event,helper) {
        helper.updateProjectAssign(component);
    },
    HandleNextClick : function(component,event,helper) {
    	
    },
    showLoading: function (cmp, event) {
        var spinner = cmp.find("Spinner");
        $A.util.removeClass(spinner, "slds-hide");
        $A.util.addClass(spinner, "slds-show");
    },
    hideLoading: function (cmp, event) {
        var spinner = cmp.find("Spinner");
        $A.util.addClass(spinner, "slds-hide");
        $A.util.removeClass(spinner, "slds-show");
    },
    copyEndDatesAssignment: function(cmp,event) {
        var endDate = cmp.find("endDate").get("v.value");
        for(var assigncmp in cmp.find("endDateassign")){
            cmp.find("endDateassign")[assigncmp].set("v.value",endDate)
        }
        
        
    }
})