({
	doInit : function(component, event, helper) {
		helper.doInitHelper(component,helper);
	},
	cancelClick : function(component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	},
    hideSpinner : function(component) {
        var spinnerMain =  component.find("Spinner");
        $A.util.addClass(spinnerMain, "slds-hide");
    },
    showSpinner: function(component) {
        var spinnerMain =  component.find("Spinner");
        $A.util.removeClass(spinnerMain, "slds-hide");
    },
    retrieveConnectionsMetaData : function(component, event, helper) {
		helper.retrieveConnectionsMetaDataHelper(component,helper);
	},
	retrieveConnectionsMetaDataList : function(component, event, helper) {
		helper.retrieveConnectionsMetaDataListHelper(component,event,helper);
	},
	compareMetadata : function(component, event, helper) {
		helper.compareMetadataHelper(component,helper);
	},
	toggleAccordian: function(component, event, helper) {
    	helper.toggleAccordianhelper(component,event);
    },
    showDiference: function(component, event, helper) {
    	helper.showDiferencehelper(component,event,helper);
    },
})