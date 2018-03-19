({
	doInit : function(component, event, helper) {
		helper.doInitHelper(component, event, helper);
	},
	openDialog: function(component, event, helper){
        helper.openDialogHelper(component,event,helper);
    },
    nextWeeks: function(component, event, helper){
    	component.set("v.direction","next");
        helper.doInitHelper(component,event,helper);
    },
    previousWeeks: function(component, event, helper){
    	component.set("v.direction","previous");
        helper.doInitHelper(component,event,helper);
    },
})