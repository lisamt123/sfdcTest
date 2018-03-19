({
    doInit : function(component, event, helper) {
        helper.doManageReleaseHelper(component,helper);
        //helper.doInitHelper(component,helper);
    },
    cancelClick : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    toggel : function(component,event,helper) {
        var buttonClass = event.target.getAttribute("class");
        helper.showSpinner(component);
        helper.retriveScanLogIssues(component,helper,buttonClass);
    },
    doScan : function(component,event,helper) {
        helper.showSpinner(component);
        helper.doScanHelper(component,helper);
    }
})