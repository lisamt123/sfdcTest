({
	onLoad : function(component, event, helper) {
		console.log(component.get("v.userContactInfo"));
	},
    saveDetails:function(component, event, helper) {
        var dataCall = component.get("c.saveUserDetails");
        dataCall.setParams({
            "updatedList": JSON.stringify(component.get("v.userContactInfo"))
        });
        dataCall.setCallback(this, function(a){
            component.set("v.userContactInfo",a.getReturnValue());
            console.log(a.getReturnValue());
            component.set("v.closeEdit",true);           
                
        });
        $A.enqueueAction(dataCall);
    },
    hideEdit: function(component, event, helper) {
        component.set("v.closeEdit",true);
    },
})