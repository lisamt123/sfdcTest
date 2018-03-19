({
	showMessage:function(component) {
        document.getElementById("customMessage").classList.remove("slds-hide");
        setTimeout(function(){ 
            if(document.getElementById("customMessage") != null)
                document.getElementById("customMessage").classList.add("slds-hide");
        }, 5000);
    },
    hideSpinner : function(component) {
        var spinnerMain =  component.find("Spinner");
        $A.util.addClass(spinnerMain, "slds-hide");
    },
    showSpinner: function(component) {
        var spinnerMain =  component.find("Spinner");
        $A.util.removeClass(spinnerMain, "slds-hide");
    },
    doInitHelper : function(component, event, helper) {
    	var action = component.get("c.retrieveConnectionData");
		action.setParams( {
			"recId" : component.get("v.recordId"),
		});
		action.setCallback(this,function(response) {
			var state = response.getState();
            if(state == "SUCCESS") {
            	component.set('v.repoList',response.getReturnValue().repoResponseWrapper);
            	component.set('v.accessToken',response.getReturnValue().accessToken);
			}
            else if (state === "ERROR") {
                this.showErrorMessage(component,response,helper);
            }
            this.hideSpinner(component);
		});
		$A.enqueueAction(action);
    },
    onGroupHelper : function(component, event, helper) {
    	var repoUrl = event.getSource().get('v.class');
    	var action = component.get("c.retrieveConnectionMetaDataInfo");
		action.setParams( {
			"selectedRepo" : repoUrl,
			"access_token" : component.get("v.accessToken")
		});
		action.setCallback(this,function(response) {
			var state = response.getState();
            if(state == "SUCCESS") {
            	if(response.getReturnValue().message == 'SUCCESS') {
            		component.set("v.selectedRepo",event.getSource().get('v.labelClass'));
            		component.set("v.message", 'Selected repository is a salesforce repository');
                    component.set("v.messageType", "success");
                    component.set("v.messageTitle", "Success");
                    helper.showMessage(component); 
            	}
            	else {
            		component.set("v.selectedRepo",'');
            		component.set("v.message", 'Selected repository is not a salesforce repository');
                    component.set("v.messageType", "warning");
                    component.set("v.messageTitle", "Warning");
                    helper.showMessage(component); 
            	}
			}
            else if (state === "ERROR") {
                this.showErrorMessage(component,response,helper);
            }
            this.hideSpinner(component);
		});
		$A.enqueueAction(action);
    },
    updateConnectionHelper : function(component, event, helper) {
    	if(component.get("v.selectedRepo") != '') {
    		this.showSpinner(component);
    		var action = component.get("c.updateGitConnection");
			action.setParams( {
				"selectedRepo" 	: component.get("v.selectedRepo"),
				"recId" 		: component.get("v.recordId"),
				"access_token" 	: component.get("v.accessToken")
			});
			action.setCallback(this,function(response) {
				var state = response.getState();
	            if(state == "SUCCESS") {
	            	if(response.getReturnValue() == 'success') {
	            		component.set("v.message", 'Request to configure connection has been placed successfully.');
	                    component.set("v.messageType", "success");
	                    component.set("v.messageTitle", "Success");
	                    helper.showMessage(component);
	            	}
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                      "recordId": component.get('v.recordId'),
                    });
                    navEvt.fire();
				}
	            else if (state === "ERROR") {
	                this.showErrorMessage(component,response,helper);
	            }
	            this.hideSpinner(component);
			});
			$A.enqueueAction(action);
    	}
    },
    showErrorMessage : function(component,response,helper) {
        var errors = response.getError();
        if (errors) {
            errors.forEach( function (error) {

                if (error.message) {
                    component.set("v.message", error.message);
                    component.set("v.messageType", "error");
                    component.set("v.messageTitle", "Error");
                    helper.showMessage(component);                    
                }

                if (error.pageErrors) {
                    error.pageErrors.forEach( function(pageError) {
                        component.set("v.message", pageError.message);
                        component.set("v.messageType", "error");
                        component.set("v.messageTitle", "Error");
                        helper.showMessage(component);                   
                    });                 
                }

                if (error.fieldErrors) {
                    for (var fieldName in error.fieldErrors) {
                        error.fieldErrors[fieldName].forEach( function (errorList) { 
                            component.set("v.message", errorList.message + " Field Error on " + fieldName + " : ");
                            component.set("v.messageType", "error");
                            component.set("v.messageTitle", "Error");
                            helper.showMessage(component);                         
                        });                                
                    };                   
                } 
            }); 
        }
    },
})