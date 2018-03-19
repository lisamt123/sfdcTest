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
    showDiferencehelper: function(component,event,helper) {
    	console.log(event.target.parentElement);
    	var artifactsName = event.target.parentElement.getAttribute('class').split('##');
    	helper.showSpinner(component);
        $A.createComponent(
        	
            "c:DifferenceViewer",
            {

                "metadataType"  	: artifactsName[0],
                "sourceArtifact"	: artifactsName[1],
                "targetArtifact"	: artifactsName[2],
                "sourceConnection" 	: component.get("v.connectionOptionOne"),
                "targetConnection" 	: component.get("v.connectionOptionTwo"),
            },
            function(newItem, status, errorMessage) {
                if (status === "SUCCESS") {
                    var targetCmp   = component.find('diffViewer');
                    var body        = targetCmp.get("v.body");
                    body.push(newItem);
                    targetCmp.set("v.body", body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
                helper.hideSpinner(component);
            }
        );
    },
	doInitHelper : function(component,helper) {
		var action = component.get("c.retrieveConnectionData");
		action.setParams({"recId":component.get("v.recordId")});
		action.setCallback(this,function(response) {
			var state = response.getState();
            if(state == "SUCCESS") {
            	component.set("v.connectionOptions",response.getReturnValue());
            	if(component.get("v.connectionOptionOne") == '')
            		component.set("v.connectionOptionOne",component.get("v.recordId"));
            	this.hideSpinner(component);
			}
            else if (state === "ERROR") {
                this.showErrorMessage(component,response,helper);
            }
            this.hideSpinner(component);
		});
		$A.enqueueAction(action);
	},
	retrieveConnectionsMetaDataHelper : function(component,helper) {
		if(component.get("v.connectionOptionOne") != '' && component.get("v.connectionOptionTwo") != '') {
			this.showSpinner(component);
			component.set("v.selectedMetadata",'');
			var action = component.get("c.retrieveConnectionMetaData");
			action.setParams({
				"recId"					: component.get("v.connectionOptionOne"),
				"secondConnection" 		: component.get("v.connectionOptionTwo")
			});
			action.setCallback(this,function(response) {
				var state = response.getState(); 
	            if(state == "SUCCESS") {
	            	component.set("v.metadataOptions",response.getReturnValue().metadataList.sort());
	            	component.set("v.runningStatus",response.getReturnValue().runningStatus);
	            	component.set("v.lastComparedAt",response.getReturnValue().logTime);
	            	console.log('=========='+response.getReturnValue().runningStatus);
	            	console.log('=========='+response.getReturnValue().logTime);
	            	if(response.getReturnValue().runningStatus == 'InProgress')
	            		helper.retrieveConnection(component,helper);
                    if(response.getReturnValue().runningStatus == 'NotFound')
                        component.set("v.metadataOptions",'[]');
	            	this.hideSpinner(component);
				}
	            else if (state === "ERROR") {
	                this.showErrorMessage(component,response,helper);
	                this.hideSpinner(component);
	            }
			});
			$A.enqueueAction(action);
		}
	},
	retrieveConnectionsMetaDataListHelper : function(component,event,helper) {
		if(component.get("v.connectionOptionOne") != '' && component.get("v.connectionOptionTwo") != '') {
			
			if(component.get("v.selectedMetadata") == event.getSource().get('v.title')) {
				component.set("v.selectedMetadata",'');
			}
			else {
				component.set("v.metadataResult",'[]');
				this.showSpinner(component);
				component.set("v.selectedMetadata",event.getSource().get('v.title'));
				var action = component.get("c.retrieveConnectionMetaDataList");
				action.setParams({
					"recId"					: component.get("v.connectionOptionOne"),
					"secondConnection" 		: component.get("v.connectionOptionTwo"),
					"metadataType"			: event.getSource().get('v.title')
				});
				action.setCallback(this,function(response) {
					var state = response.getState();
		            if(state == "SUCCESS") {
		            	component.set("v.metadataResult",response.getReturnValue().artifactList);
		            	this.sortMetadataResult(component);
		            	this.hideSpinner(component);
					}
		            else if (state === "ERROR") {
		                this.showErrorMessage(component,response,helper);
		                this.hideSpinner(component);
		            }
				});
				$A.enqueueAction(action);
			}
		}
	},
	sortMetadataResult : function(component) {
		var recordList = component.get('{!v.metadataResult}');
        recordList.sort(function(a,b) {
            var column1     = a['artifactSource'] != '' && typeof a['artifactSource'] != 'undefined' ? 'artifactSource' : 'artifactTarget';
        	var column2     = b['artifactSource'] != '' && typeof b['artifactSource'] != 'undefined' ? 'artifactSource' : 'artifactTarget';
            var first       = !isNaN(a[column1]) && !isNaN(parseInt(a[column1])) ? parseInt(a[column1]) : a[column1].toLowerCase();
            var second      = !isNaN(b[column2]) && !isNaN(parseInt(b[column2])) ? parseInt(b[column2]) : b[column2].toLowerCase();

            if ( first < second )
                return -1;
            if ( first > second )
                return 1;
            return 0;
        });
        component.set('{!v.metadataResult}',recordList);
	},
	retrieveConnection : function(component,helper) {
		var action = component.get("c.retrieveConnection");
		action.setParams({"recId":component.get("v.connectionOptionOne")});
		action.setCallback(this,function(response) {
			var state = response.getState();
            if(state == "SUCCESS") {
            	console.log(response.getReturnValue().Comparing_Connections__c);
            	if(typeof response.getReturnValue().Comparing_Connections__c != 'undefined' && response.getReturnValue().Comparing_Connections__c.indexOf(component.get("v.connectionOptionTwo")) != -1) {
            		setTimeout(function() {
            			try {
						    helper.retrieveConnection(component,helper);
						}
						catch(err) {
						    console.log(err.message);
						}
            			
            		},1000);
            	}
            	else
            		helper.retrieveConnectionsMetaDataHelper(component,helper);
			}
            else if (state === "ERROR") {
                this.showErrorMessage(component,response,helper);
            }
		});
		$A.enqueueAction(action);
	},
	compareMetadataHelper :function(component,helper) {
		var action = component.get("c.compareMetadataType");
		action.setParams({
			"recId"					: component.get("v.connectionOptionOne"),
			"secondConnection" 		: component.get("v.connectionOptionTwo")
		});
		action.setCallback(this,function(response) {
			var state = response.getState();
	            if(state == "SUCCESS") {
	            	component.set("v.runningStatus",'InProgress');
	            	this.retrieveConnection(component,helper);
	            	this.hideSpinner(component);
				}
	            else if (state === "ERROR") {
	                this.showErrorMessage(component,response,helper);
	            }
		});
		$A.enqueueAction(action);
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