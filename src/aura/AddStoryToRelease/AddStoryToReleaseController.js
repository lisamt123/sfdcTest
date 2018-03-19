({
    doInit : function(component, event, helper) {
        helper.doInitHelper(component);
    },
    cancelClick : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    onGroup : function(component, event, helper) {
        var val = event.getSource().get("v.label");
        if(val == 'Create a New Release') {
            var release = component.get("v.release");
            release.Project__c  = component.get("v.story").Project__c;
            release.sobjectType = 'Release__c';
            release.Source__c   = component.get("v.source");
            component.set("v.release",release );
            component.set("v.isExitRelease", false);
            component.set("v.isNewRelease", true);
            //helper.hideSpinner(component);

        } else {
            component.set("v.isExitRelease", true);
            component.set("v.isNewRelease", false);
            helper.addReleaseOptions(component,"releaseList","v.releaseOptions");
        }
    },

    updateClick : function(component, event, helper) {
        var isValid = true;
        if(component.get("v.isNewRelease")) {
            if($A.util.isEmpty(component.find('relName').get("v.value"))) {
                component.set("v.message", "Release name is required.");
                component.set("v.messageType", "error");
                component.set("v.messageTitle", "Error");
                helper.showMessage(component);
                isValid = false;
            }
            else if($A.util.isEmpty(component.get('v.release').Project__c)) {
                component.set("v.message", "Project on release is required.");
                component.set("v.messageType", "error");
                component.set("v.messageTitle", "Error");
                helper.showMessage(component);
                isValid = false;
            }
            else if($A.util.isEmpty(component.get('v.release').Source__c)) {
                component.set("v.message", "Source on release is required.");
                component.set("v.messageType", "error");
                component.set("v.messageTitle", "Error");
                helper.showMessage(component);
                isValid = false;
            }
            if(isValid) {
                helper.addStoryToNewRelease(component, "demo");
            }
        } else {
            if(component.get("v.releaseId") != '') {
                helper.showSpinner(component);
                helper.addStoryToNewRelease(component, component.get("v.releaseId"));
            }
            else {
                component.set("v.message", "Please select a related or unrelated release before adding it to release.");
                component.set("v.messageType", "error");
                component.set("v.messageTitle", "Error");
                helper.showMessage(component);
            }
        }
    },
    hideSpinner : function(component) {
        var spinnerMain =  component.find("Spinner");
        $A.util.addClass(spinnerMain, "slds-hide");
    },
    showSpinner: function(component) {
        var spinnerMain =  component.find("Spinner");
        $A.util.removeClass(spinnerMain, "slds-hide");
    }
})