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
	doInitHelper : function(component,helper) {
		var action = component.get("c.retrieveCodeScanProperties");
		action.setParams({"recId":component.get("v.recordId")});
		action.setCallback(this,function(response) {
			var state = response.getState();
            if(state == "SUCCESS") {
            	component.set("v.rulesetWrapperList",response.getReturnValue());
            	this.updateList(component,component.get('v.shortBy'));
            	this.hideSpinner(component);
			}
            else if (state === "ERROR") {
                this.showErrorMessage(component,response,helper);
            }
		});
		$A.enqueueAction(action);
	},
	updateProjectScanRulesHelper : function (component,helper) {
		var action = component.get("c.updateCodeScanProperties");
		action.setParams({
			"recId"						: component.get("v.recordId"),
			"ruleSetWrapperListJSON"	: JSON.stringify(component.get("v.rulesetWrapperList"))
		});
		action.setCallback(this,function(response) {
			var state = response.getState();
            if(state == "SUCCESS") {
            	var toastEvent = $A.get("e.force:showToast");
            	if(response.getReturnValue() == 'Success') {
            		toastEvent.setParams({
		                "type": "success",
		                "message": "Code scan rules updated successfully."
		            });
            		toastEvent.fire();
            	}
            		
        		$A.get("e.force:closeQuickAction").fire();
			}
            else if (state === "ERROR") {
                this.showErrorMessage(component,response,helper);
            }
		});
		$A.enqueueAction(action);

	},
	sortColumnHelper : function(component,event) {
    	var childNodes	= event.target.childNodes;
    	var column 		= event.target.getAttribute("id");
        component.set('v.shortBy',column);
        if(childNodes.length == 1 || childNodes.length >= 1 && childNodes[1].getAttribute('class') == 'down') {

            var symbol = document.createElement('i');
            this.updateColumnHeaders();
            component.set('v.sortOrder','up')
            symbol.setAttribute("class", "up");
            symbol.setAttribute("Style", "pointer-events: none;");
            event.target.appendChild(symbol);
        }
        else {

            var symbol = document.createElement('i');
            this.updateColumnHeaders();
            symbol.setAttribute("class", "down");
            component.set('v.sortOrder','down')
            symbol.setAttribute("Style", "pointer-events: none;");
            event.target.appendChild(symbol);
        }
        this.updateList(component,column);

    },
    updateList : function(component,column) {
        var recordList = component.get('{!v.rulesetWrapperList}');
        recordList.sort(function(a,b) {
            var first   = !isNaN(a[column]) && !isNaN(parseInt(a[column])) ? parseInt(a[column]) : a[column].toLowerCase();
            var second  = !isNaN(b[column]) && !isNaN(parseInt(b[column])) ? parseInt(b[column]) : b[column].toLowerCase();

            if(component.get('v.sortOrder') == 'up') {
                if ( first < second )
                    return -1;
                if ( first > second )
                    return 1;
                return 0;
            }
            else {
                if ( first > second )
                    return -1;
                if ( first < second )
                    return 1;
                return 0;
            }
        });
        component.set('{!v.rulesetWrapperList}',recordList);
    },
    updateColumnHeaders : function() {
    	var headers = document.getElementsByClassName('shortable');
    	for(var count = 0 ; count < headers.length ; count++) {
    		headers[count].innerHTML = headers[count].childNodes[0].textContent;
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