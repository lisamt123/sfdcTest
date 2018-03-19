({
	validateData : function(component, event, helper) {
		var isDataValid = true;
		
		if($A.util.isEmpty(component.find("priceb1").get("v.value"))) {
			isDataValid = false;
			var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "error",
                "message": "Name is required."
            });
            toastEvent.fire();
		}

		if(isDataValid) {
			this.cloneWithProducts(component, event, helper);
		}
	},
	cloneWithProducts : function(component, event, helper) {
		var action = component.get("c.clonePriceBookProducts");
		action.setParams({
			"priceBookRecJSON" : JSON.stringify(component.get("v.PriceBookRec")),
			"priceBookEntryListJSON": JSON.stringify(component.get("v.PriceBookEntriesList"))
		});
		action.setCallback(this, function(response) {
			var state = response.getState();
			if( component.isValid() && state === "SUCCESS") {
				var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
	                "type": "success",
	                "message": "Price Book cloned successfully."
	            });
	            toastEvent.fire();
	            var redirectEvent = $A.get("e.force:navigateToSObject");
				redirectEvent.setParams({
	                "recordId": response.getReturnValue(),
	                "slideDevName": "detail"
	            });
	            redirectEvent.fire();
		        component.destroy();
			}
			else if (state === "ERROR") {
                var errors = response.getError();
                if(errors[0] && errors[0].message) { // To show other type of exceptions
                	var toastEvent1 = $A.get("e.force:showToast");
		            toastEvent1.setParams({
		                "type": "error",
		                "message": errors[0].message
		            });
		            toastEvent1.fire();
                }
                if(errors[0] && errors[0].pageErrors) { // To show DML exceptions
                	var toastEvent2 = $A.get("e.force:showToast");
		            toastEvent2.setParams({
		                "type": "error",
		                "message": errors[0].pageErrors[0].message
		            });
		            toastEvent2.fire();
                }
            }
		});
		$A.enqueueAction(action);
	},
	retrivePriceBook : function(component, event, helper) {
		var priceBookId = component.get("v.PriceBookId");
		var action = component.get("c.retrivePriceBookRec");
		action.setParams({
			"priceBookId": priceBookId
		});
		action.setCallback(this, function(response) {
			var state = response.getState();
			if( component.isValid() && state === "SUCCESS") {
				var priceBookEntriesListJS = response.getReturnValue().priceBookEntriesList;
				for(var i = 0; i < priceBookEntriesListJS.length; i++) {
					priceBookEntriesListJS[i].Product2.IsActive = true;
				}
				component.set("v.PriceBookRec", response.getReturnValue().priceBookRec);
				component.set("v.PriceBookEntriesList", priceBookEntriesListJS);
				component.set("v.AccountTierPickValues", response.getReturnValue().accountTierPickValues);
			}
			else if (state === "ERROR") {
                var errors = response.getError();
                if(errors[0] && errors[0].message) { // To show other type of exceptions
                	var toastEvent1 = $A.get("e.force:showToast");
		            toastEvent1.setParams({
		                "type": "error",
		                "message": errors[0].message
		            });
		            toastEvent1.fire();
                }
                if(errors[0] && errors[0].pageErrors) { // To show DML exceptions
                	var toastEvent2 = $A.get("e.force:showToast");
		            toastEvent2.setParams({
		                "type": "error",
		                "message": errors[0].pageErrors[0].message
		            });
		            toastEvent2.fire();
                }
            }
		});
		$A.enqueueAction(action);
	},
})