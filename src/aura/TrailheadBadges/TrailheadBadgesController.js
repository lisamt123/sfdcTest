({
	onLoad : function(component, event, helper) {
		var dataCall = component.get("c.getAchivements");
        dataCall.setParams({
            "profileUserId": window.location.pathname.split('/profile/')[1]
        });
        dataCall.setCallback(this, function(a){
            if(a.getReturnValue() != null && a.getReturnValue().length > 0){
                console.log('--bedges--');
                component.set("v.badgesURL",a.getReturnValue());
                component.set("v.TotalBadges",a.getReturnValue().length);
            }
            else{
                component.set("v.TotalBadges",0);
                helper.validateCurrentUser(component, event);
            }
        });
        $A.enqueueAction(dataCall);
    }
	
})