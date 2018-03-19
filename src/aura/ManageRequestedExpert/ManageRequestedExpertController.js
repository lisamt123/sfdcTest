({
	closeEdit : function(component, event, helper) {
		component.destroy();
	},

	saveEdit : function(component, event, helper) {
		console.log('requestedExpert : ', component.get("v.requestedExpert"));
	},

	handleRoleChange : function(component, event, helper) {
        console.log('role : ', component.get("v.requestedExpert").Role__c);
        console.log('requestedExpert : ', component.get("v.requestedExpert"));
        helper.retriveRatePickVals(component);
    },
})