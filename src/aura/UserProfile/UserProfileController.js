({
	onLoad : function(component, event, helper) {
        //console.log();
        //console.log(component.get("v.recordId"));
        $A.util.removeClass(component.find("modelshow"),'slds-fade-in-open');
        $A.util.removeClass(component.find("bgfade"),'slds-backdrop--open');
        var dataCall = component.get("c.getUserDetails");
        dataCall.setParams({
            "profileUserId": window.location.pathname.split('/profile/')[1]
        });
        dataCall.setCallback(this, function(a){
            component.set("v.userDetails",a.getReturnValue());
            console.log(a.getReturnValue()); 
            if(a.getReturnValue() != null && a.getReturnValue().length > 0){
                component.set("v.userDetails",a.getReturnValue());
				console.log(a.getReturnValue());
            }
            //$('#loading').hide();
        });
        $A.enqueueAction(dataCall);
        
    },
	
    showModel: function(component, event, helper) {
        $A.util.addClass(component.find("modelshow"),'slds-fade-in-open');
        $A.util.addClass(component.find("bgfade"),'slds-backdrop--open');
    },
    closeError: function(component, event, helper) {
        $A.util.removeClass(component.find("modelshow"),'slds-fade-in-open');
        $A.util.removeClass(component.find("bgfade"),'slds-backdrop--open');
    },
    editRecord: function(component, event, helper) {
        //$A.util.addClass(component.find("secodDivId"),'outerDiv');
        //$A.util.addClass(component.find("firstDivId"),'outerDiv');
        //$A.util.removeClass(component.find("editBtns"),'outerDiv');
        component.set("v.editFlag",false);
    },
    
  
    
    uploadImage: function(component, event,helper) {
        var vv = document.getElementById('file').files[0];
        console.log(vv);
        helper.readFile(component,vv,helper);
        
    },
    addFollow: function(component, event, helper)
    {
        
        var action = component.get("c.addFollowUser");
        action.setParams({
            "parentId":  window.location.pathname.split('/profile/')[1]
        });
        console.log('javascript controller function called');
        action.setCallback(this, function(response) 
		{
			var state = response.getState();
			if (component.isValid() && state === "SUCCESS") 
			{
				console.log(response.getReturnValue());
                component.set("v.followFlag", true);
			}
		});
		$A.enqueueAction(action);
    },
    removeFollow: function(component, event, helper)
    {
        var action = component.get("c.removeFollowUser");
        action.setParams({
            "parentId":  window.location.pathname.split('/profile/')[1]
        });
        action.setCallback(this, function(response) 
		{
			var state = response.getState();
			if (component.isValid() && state === "SUCCESS") 
			{
				console.log(response.getReturnValue());
                component.set("v.followFlag", false);
			}
		});
		$A.enqueueAction(action);
    },
    showSpinner : function (component, event, helper) 
    {
        var spinner = component.find('spinner');
        $A.util.removeClass(spinner, 'slds-hide');
    },
    
    hideSpinner : function (component, event, helper) 
    {
       var spinner = component.find('spinner');
       $A.util.addClass(spinner, 'slds-hide');
    }
    
})