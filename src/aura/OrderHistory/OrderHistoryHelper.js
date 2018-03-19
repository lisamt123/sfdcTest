({
	orderHistory : function(component, event, helper) 
	{
		var action = component.get("c.getOrderHistory");
		action.setCallback(this, function(response)
		{
			var state = response.getState();
			if(component.isValid() && state === "SUCCESS")
			{
				if(response.getReturnValue() != null || response.getReturnValue().length > 0)
				{
					component.set("v.OrderList",response.getReturnValue());
				}
				else
				{
					component.set("v.NoOrders",true);
				}
			}
		});
		$A.enqueueAction(action);
	}
})