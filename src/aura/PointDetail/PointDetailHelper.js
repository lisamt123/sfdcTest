({
	getAllPoints : function(component, event, helper) {
		var action = component.get("c.retPoints");
		action.setCallback(this, function(response) {
			var state = response.getState();
			if( component.isValid() && state === "SUCCESS") {
				console.log(response.getReturnValue());
				component.set("v.PointsList", response.getReturnValue().pointWrapList);
				component.set("v.totalPoints", response.getReturnValue().totPoint);
				component.set("v.redeemedPoints", response.getReturnValue().redPoint);
			}
		});
		$A.enqueueAction(action);
	}
})