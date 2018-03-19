({ //<aura:handler name="init" value="{!this}" action="{!c.doInit}" />
	doInit : function(component, event, helper) {
		helper.doInitHelper(component, event, helper);
	},
	cancelClick : function(component, event, helper) {
		component.destroy();
	},
})