({
	doInit : function(component, event, helper) 
	{
		var action = component.get("c.getOrderDetails");
		action.setParams({
			"orderId" : component.get("v.OrderId")
		});
		action.setCallback(this, function(response)
		{
			var state = response.getState();
			if(component.isValid() && state === "SUCCESS")
			{
				console.log(response.getReturnValue());
				component.set("v.OrderLineItems", response.getReturnValue());
			}
		});
		$A.enqueueAction(action);
	},

	defaultCloseAction : function(component, event, helper)
	{
		component.destroy();
	}
})