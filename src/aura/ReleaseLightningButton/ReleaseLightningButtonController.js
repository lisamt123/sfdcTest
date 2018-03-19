({
	toggelComponent : function(component, event, helper) {
		
		component.set("v.truthy" , true);

		var buttonId = event.getSource().getLocalId();
		if(buttonId == 'validate') {
			component.set("v.heading" , 'Validate Release');
			component.set("v.innerComp" , 'validate');
		}
		else if(buttonId == 'artifacts') {
			component.set("v.heading" , 'Manage Release Artifacts');
			component.set("v.innerComp" , 'artifacts');
		}
	},
	closeModel : function(component, event, helper) {
		component.set("v.truthy" , false);
	},
	/*showSpinner : function (component, event, helper) {
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : true });
        evt.fire();    
    },
    hideSpinner : function (component, event, helper) {
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : false });
        evt.fire();  */  
    }
})