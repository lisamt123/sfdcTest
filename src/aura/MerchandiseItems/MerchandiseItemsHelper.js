({
	getAllMerchandise : function(component, event, helper)
	{
		var action = component.get("c.getMerchandise");
		action.setCallback(this, function(response)
		{
			var state = response.getState();
			if(component.isValid() && state === "SUCCESS")
			{
				var merchantList = response.getReturnValue();
				var merchandiseList = [];
				for(var i = 0; i < merchantList.length; i++)
				{
					for(var j = 0; j < merchantList[i].Items__r.length; j++)
					{
						merchantList[i].Items__r[j].Quantity_Redeemed__c = 1;
					}
					merchandiseList.push(merchantList[i]);
				}
				component.set("v.MerchandiseList", merchandiseList);
			}
		});
		$A.enqueueAction(action);
	}
})