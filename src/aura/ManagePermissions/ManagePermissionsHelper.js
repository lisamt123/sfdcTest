({
	getAssignments : function(component) {
		var assignmentAction = component.get("c.getConnectionAssignments");
		var connectionId = component.get("v.recordId");
		assignmentAction.setParams({'connectionId': connectionId});
		assignmentAction.setCallback(this, function(response) {
			var state = response.getState();
			if(component.isValid() && state == 'SUCCESS') {
				var connectionAssignmentWrappper = response.getReturnValue();
				console.log(JSON.stringify(response.getReturnValue()));
				if(connectionAssignmentWrappper !== 'undefined' || connectionAssignmentWrappper !== null) {
					component.set('v.connectionAssignmentsList',connectionAssignmentWrappper.assignmentwrapperList);
				}else{
					var toastEvent = $A.get("e.force:showToast");
		            toastEvent.setParams({
		                "type": "error",
		                "message": "No Assignment available for this connection."
		            });
		            toastEvent.fire();

				}
			}else if(state == 'INCOMPLETE') {
				console.log('Fetching data from server is incomplete');
			}else if(state == 'ERROR') {
				var errors = response.getError();
				if(errors) {
					if(errors[0] && errors[0].message) {
						component.set("v.message", "No active Assignemnts found for this Connection, please add an active Assignment.");
                    	component.set("v.messageType", "warning");
                    	component.set("v.messageTitle", "Warning");
                    	this.showMessage(component);
					}
				}
			}
		});
		$A.enqueueAction(assignmentAction);
	},
	showMessage:function(component) {
        document.getElementById("customMessage").classList.remove("slds-hide");
        setTimeout(function(){ 
            if(document.getElementById("customMessage") != null)
                document.getElementById("customMessage").classList.add("slds-hide");
        }, 5000);
    },
    showLoadingHelper: function (cmp, event) {
        var spinner = cmp.find("Spinner");
        $A.util.removeClass(spinner, "slds-hide");
        $A.util.addClass(spinner, "slds-show");
    },
    hideLoadingHelper: function (cmp, event) {
        var spinner = cmp.find("Spinner");
        $A.util.addClass(spinner, "slds-hide");
        $A.util.removeClass(spinner, "slds-show");
    },
    saveConnectionPermission: function(component) {
		var assignmentWrapperList = component.get('v.connectionAssignmentsList');
		assignmentWrapperList = JSON.stringify(assignmentWrapperList);
		var action = component.get('c.saveConnectionWisePermissions');
		var connectionId = component.get("v.recordId");
		action.setParams({'connectionId': connectionId,'assignmentWrapperList' : assignmentWrapperList});
		action.setCallback(this, function(response) {
			var state = response.getState();
			if(component.isValid() && state == "SUCCESS") {
				var saveResponse = response.getReturnValue();
				var toastEvent = $A.get("e.force:showToast");
				if (typeof saveResponse !== "undefined" || saveResponse !== null){
					toastEvent.setParams({
		                "type": "success",
		                "message": "Connection permissions successfully updated."
		            });
				}else {
					toastEvent.setParams({
		                "type": "error",
		                "message": 'Error while saving the data'
		            });
				}
	            
	            toastEvent.fire();
	            $A.get("e.force:closeQuickAction").fire();
			}else if(state == "INCOMPLETE") {
				console.log("Process is incomplete");
			}else if(state == "ERROR") {
				var errors = response.getError();
				if(errors) {
					if(errors[0] && errors[0].message) {
						component.set("v.message", errors[0].message);
                    	component.set("v.messageType", "warning");
                    	component.set("v.messageTitle", "Warning");
                    	this.showMessage(component);
					}
				}
			}
		});
		$A.enqueueAction(action);

    },
})