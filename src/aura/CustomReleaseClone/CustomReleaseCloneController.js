({
	doInit : function(component, event, helper) {
		var windowHash  = window.location.href;
		sObjectName     = component.get("v.sObjectName");
		recordId        = component.get("v.recordId");
		var fieldToSkip = component.get('v.fieldToSkip');
		var action      = component.get("c.getRecordData");
        action.setParams({ 'sObjectName' : sObjectName,'recordId' : recordId,'fieldToSkip' : fieldToSkip});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") { 
                var createRecordEvent = $A.get("e.force:createRecord");
			    var childComp = createRecordEvent.setParams({
			        "entityApiName": sObjectName,
			        "defaultFieldValues": response.getReturnValue(),
			        "panelOnDestroyCallback": function(event) {
			        	if(windowHash == window.location.href) {
			        		var dismissAction = $A.get("e.force:closeQuickAction");
        		            dismissAction.fire();
			        	} else {
			        		helper.handleDestroy(component);
			        	}
		            }
			    });
			    createRecordEvent.fire();
			    var buttons;
			    var timeInterval = setInterval(function() { 
			    	buttons = document.getElementsByClassName('forceActionButton');
			    	if(typeof buttons == 'object' && buttons.length > 1 ) {
			    		document.getElementsByClassName('forceActionButton')[1].style.display = 'none';
			    		clearInterval(timeInterval);
			    	}
			    }, 100);
            }else if(state == 'INCOMPLETE') {

            }else if(state == 'ERROR') {
            	var errors = response.getError();
            }
        });
        $A.enqueueAction(action);
	},
	
})