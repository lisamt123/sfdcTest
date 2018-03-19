({
	doInit : function(component, event, helper) {
		helper.doInitHelper(component,helper);
	},
	cancelClick : function(component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	},
	sortColumn : function(component, event, helper) {
    	helper.sortColumnHelper(component,event);
    },
    updateProjectScanRules : function(component, event, helper) {
    	helper.updateProjectScanRulesHelper(component,helper);
    },
    hideSpinner : function(component) {
        var spinnerMain =  component.find("Spinner");
        $A.util.addClass(spinnerMain, "slds-hide");
    },
    showSpinner: function(component) {
        var spinnerMain =  component.find("Spinner");
        $A.util.removeClass(spinnerMain, "slds-hide");
    },
})