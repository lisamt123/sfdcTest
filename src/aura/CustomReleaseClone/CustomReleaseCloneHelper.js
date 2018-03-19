({
	handleDestroy : function(component) {
		var requiredId ;
		var fullUrl = window.location.href ;
		var splitUrl;
		if(fullUrl.includes('community')) {
			splitUrl        = window.location.pathname.split("/") ;
			var idPos       = splitUrl.length - 1 ;
			requiredId      = splitUrl[idPos];
		}else{
			splitUrl        = window.location.href.split("sObject/") ;
			if(splitUrl[1] !== 'undefined' || splitUrl[1] != null) {
				var requiredUrl = splitUrl[1].split('/');
				requiredId      = requiredUrl[0];
			}
		}
		
		var recordId = component.get("v.recordId");
		var action   = component.get('c.cloning');
		action.setParams({ 'release_Id' : requiredId,'clonedFromReleaseId' : recordId});
        action.setCallback(this,function(response) {
			if (component.isValid() && state === "SUCCESS") { 
                
            }
		});
		$A.enqueueAction(action);
		var dismissAction = $A.get("e.force:closeQuickAction");
       	dismissAction.fire();
    }
})