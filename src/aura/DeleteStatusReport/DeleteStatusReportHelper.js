({
	doInitHelper : function(component) 
	{
		console.log('Record Id : '+component.get("v.recordId"));
		var action = component.get("c.deleteStatusReportRecord");
		action.setParams({
			"recId": component.get("v.recordId")
		});
		action.setCallback(this, function(response){
			var state = response.getState();
			if(component.isValid() && state === "SUCCESS")
			{
				component.set("v.isLeadUser", response.getReturnValue().isProjectLead);
				if(response.getReturnValue().isProjectLead)
				{
					setTimeout(function(){ 
						var address = '/detail/'+response.getReturnValue().projectId;
					    var urlEvent = $A.get("e.force:navigateToURL");
					    urlEvent.setParams({
					      "url": address,
					      "isredirect" :false
					    });
					    urlEvent.fire();
					 }, 3000);
				}
			}
		});
		$A.enqueueAction(action);
	}
})