({
	getConnections: function(component) {
		var connectionAction = component.get("c.getProjectConnectionList");
		var projectId = component.get("v.recordId");
		connectionAction.setParams({'projectId': projectId,'connectionId': null});
		connectionAction.setCallback(this, function(response) {
			var state = response.getState();
			if(component.isValid() && state == "SUCCESS") {
				var connectionAssignmentWrappper = response.getReturnValue();
				//console.log(JSON.stringify(response.getReturnValue()));
				if (typeof connectionAssignmentWrappper !== "undefined" || connectionAssignmentWrappper !== null){	
					component.set('v.connectionWrapperList',connectionAssignmentWrappper);
					
				}else {
					var toastEvent = $A.get("e.force:showToast");
		            toastEvent.setParams({
		                "type": "error",
		                "message": "No connections available for this project."
		            });
		            toastEvent.fire();	
				}
				component.set('v.toShow','slds-show');
			}else if(state == "INCOMPLETE") {
				console.log('Fetching data from server is incomplete');
			}else if(state == "ERROR"){
				var errors = response.getError();
				if(errors) {
					if(errors[0] && errors[0].message) {
						component.set("v.message", "No active Source connection found for this Release, please add an active Source connection.");
                    	component.set("v.messageType", "warning");
                    	component.set("v.messageTitle", "Warning");
                    	this.showMessage(component);
					}
				}
			}
			
		});
		$A.enqueueAction(connectionAction);

	},
	saveConnectionPermission: function(component) {
		var connectionWrapperList = component.get('v.connectionWrapperList');
		connectionWrapperList = JSON.stringify(connectionWrapperList);
		//console.log('connectionWrapperList - '+connectionWrapperList);
		var action = component.get('c.saveConnectionPermissions');
		var projectId = component.get("v.recordId");
		action.setParams({'projectId': projectId,'connectionList' : connectionWrapperList});
		action.setCallback(this, function(response) {
			var state = response.getState();
			if(component.isValid() && state == "SUCCESS") {
				var saveResponse = response.getReturnValue();
				
            	
            	component.set("v.messageTitle", "Connection Success");
            	
				var toastEvent = $A.get("e.force:showToast");
				if (typeof saveResponse !== "undefined" || saveResponse !== null){
					toastEvent.setParams({
		                "type": "success",
		                "message": "Connection permissions successfully updated."
		            });
		   			//component.set("v.message", saveResponse);
		   			//component.set("v.messageType", "SUCCESS");          
				}else {
					toastEvent.setParams({
		                "type": "error",
		                "message": 'Error while saving the data'
		            });
		   			//component.set("v.message", 'Error while saving the data');
		   			//component.set("v.messageType", "Error"); 
				}
	            
	            toastEvent.fire();
	            //this.showMessage(component);
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
	showMessage:function(component) {
        document.getElementById("customMessage").classList.remove("slds-hide");
        setTimeout(function(){ 
            if(document.getElementById("customMessage") != null)
                document.getElementById("customMessage").classList.add("slds-hide");
        }, 5000);
    },
    helperFun : function(component,event,secId) {
	  var accOne = component.find('articleOne');
	  var accTwo = component.find('articleTwo');
	  var accThree = component.find('articleThree');
	  for(var i = 0 ; i < accOne.length ; i++) {
	  	if(i == secId) {
	  		$A.util.toggleClass(accOne[i], 'slds-show');  
         	$A.util.toggleClass(accOne[i], 'slds-hide');

         	$A.util.toggleClass(accTwo[i], 'slds-show');  
         	$A.util.toggleClass(accTwo[i], 'slds-hide');

         	$A.util.toggleClass(accThree[i], 'slds-show');  
         	$A.util.toggleClass(accThree[i], 'slds-hide');

        }
	  }
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
})