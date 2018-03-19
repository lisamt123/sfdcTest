({
	doInit : function(component,helper) {
		var action = component.get("c.init");
		action.setParams(
			{"record_Id": component.get("v.recordId")}			
		);
		action.setCallback(this,function(response) {
			var state = response.getState();
			if(state == "SUCCESS"){
				var result = response.getReturnValue();
				component.set('v.objectLabel',result.objectLabel);	
				component.set('v.object_Api_Name',result.sObj_Api_Name);		
			}
		});
		$A.enqueueAction(action);	
	},
	
	delete : function(component,helper,recordName) {

		var action = component.get("c.delete_Record");
		action.setParams(
			{"record_Id": component.get("v.recordId")}
		);
		action.setCallback(this,function(response) {
			var state = response.getState();
			if(state == "SUCCESS"){
				var message = component.get("v.objectLabel") +" \"" + recordName + "\" was deleted.";
				this.showToast(component, event, helper,"success","Success!",message);
				this.navHome(component, event, helper, component.get("v.object_Api_Name"));  				
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

	openModel: function(component, event, helper) {
      component.set("v.isOpen", true);

    },
 
	closeModel: function(component, event, helper) { 
	  component.set("v.isOpen", false);
	},
 
	confirmDelete: function(component, event, helper) {
	  this.delete(component,helper,component.get("v.simpleRecord").Name);
	  component.set("v.isOpen", false);
	},

	showToast : function(component, event, helper, type, title,  message) {
	    var toastEvent = $A.get("e.force:showToast");
	    toastEvent.setParams({
	    	"type":type,
	        "title": title,
	        "message": message
	    });
	    toastEvent.fire();
	},

	navHome : function (component, event, helper, objectAPi_Name) {
	    var homeEvent = $A.get("e.force:navigateToObjectHome");
	    homeEvent.setParams({
	        "scope": objectAPi_Name
	    });
	    homeEvent.fire();
	}
})