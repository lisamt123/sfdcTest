({
	doInit : function(component, event, helper) {
        
        helper.doInitHelper(component,helper);
        helper.getOpportunityFields(component);
    },
    cancelClick : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    HandleNextClick : function(component,event,helper) {
    	
    },
    updateOppPriceBookField : function(component,event,helper) {
        helper.updateOppPriceField(component,event);
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
    }
})