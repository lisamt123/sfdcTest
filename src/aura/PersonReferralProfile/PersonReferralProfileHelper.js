({
	getReferralRecords : function(component,recID) 
	{
        console.log('recID : '+recID);
        this.showSpinner(component);

        var action = component.get("c.getReferralCount");
        action.setParams({ 
        	'recordID' : recID
            });
        action.setCallback(this, function(response) 
        {
            var state = response.getState();
            console.log('Response received');
            if (component.isValid() && state === "SUCCESS") 
            {           
                console.log("getReferralRecords is success");
                console.log(response.getReturnValue());
                component.set("v.refwrap", response.getReturnValue()[0]);
                this.hideSpinner(component);
            }
        });
        $A.enqueueAction(action);
    },
    validateCurrentUser : function(component, event) {
		var dataCall = component.get("c.validateCurrentUser");
        dataCall.setParams({
            "profileUserId": window.location.pathname.split('/profile/')[1]
        });
        dataCall.setCallback(this, function(a){
        	console.log(a.getReturnValue()+"isCurrentUser");
            component.set("v.isCurrentUser", a.getReturnValue());
            this.hideSpinner(component);
        });
        $A.enqueueAction(dataCall);
	},
    showSpinner : function(component)
    {
        var myCmp = component.find("Spinner");
        $A.util.removeClass(myCmp, "hide");
    },

    hideSpinner : function(component)
    {
        var myCmp = component.find("Spinner");
        $A.util.addClass(myCmp, "hide");
    },
})