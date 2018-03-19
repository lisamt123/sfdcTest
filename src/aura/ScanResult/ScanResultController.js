({
	doInit :function(component, event, helper) {
        helper.retriveScanLogIssues(component,helper);
    },
	cancelClick : function(component, event, helper) {
        component.destroy();
    },
    sortColumn : function(component, event, helper) {
    	helper.sortColumnHelper(component,event,helper);
    },
})