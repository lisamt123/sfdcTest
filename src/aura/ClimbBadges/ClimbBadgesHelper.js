({
	validateCurrentUser : function(component, event) {
		var dataCall = component.get("c.validateCurrentUser");
        dataCall.setParams({
            "profileUserId": window.location.pathname.split('/profile/')[1]
        });
        dataCall.setCallback(this, function(a){
        	var state = a.getState();console.log(state);console.log(a.getReturnValue());
            if(a.getReturnValue() == 'true'){
            	component.set("v.ErrorMsg",'You don\'t have any Climb Badges, go earn some!');
            }
            else{
                component.set("v.ErrorMsg",a.getReturnValue() +' does not have any Climb Badges.');
            }
        });
        $A.enqueueAction(dataCall);
	}
})