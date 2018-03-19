({
	doInitHelper: function(component,helper) {
    },
	getProjectAssignWrapper : function(component) {
		var action = component.get("c.getProjectWrapper");
        var recordId = component.get("v.recordId");
        action.setParams({ 'recId' : recordId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.projectList",response.getReturnValue());
                this.assignmentWrapper(component);
            }
        });
        $A.enqueueAction(action);
	},
    assignmentWrapper : function(component) {
        var action = component.get("c.getAssignWrapper");
        var recordId = component.get("v.recordId");
        action.setParams({ 'recId' : recordId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.assignmentRecList",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);

    },
    updateProjectAssign : function(component) {
        var action = component.get("c.updateProjectAssign");
        action.setParams({ "projectListJson" : JSON.stringify(component.get("v.projectList")),
                           "assignmentRecListJson" : JSON.stringify(component.get("v.assignmentRecList"))
                        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                if(response.getReturnValue()!='Success') {
                    component.set("v.message",response.getReturnValue());
                    component.set("v.messageType", "error");
                    component.set("v.messageTitle", "Error");
                    this.showMessage(component);
               }
               else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "Success",
                        "message":"Updated Successfully" 
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
               }

            }
        });
        $A.enqueueAction(action);
    },

     showMessage : function(component) {
        document.getElementById("customMessage").classList.remove("slds-hide");
        setTimeout(function(){ 
            if(document.getElementById("customMessage") != null){
                document.getElementById("customMessage").classList.add("slds-hide");
            }
        }, 5000);
    },
})