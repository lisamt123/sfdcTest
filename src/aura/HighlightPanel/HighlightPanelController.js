({
	doInIt : function(component, event, helper) {
		helper.doInit(component,helper);
	},
	edit : function(component, event, helper) {
		var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
             "recordId": component.get("v.recordId")
        });
        editRecordEvent.fire();
	},
	delete : function(component, event, helper) {
		helper.openModel(component, event, helper);
	},
	closeModel: function(component, event, helper) {
	  helper.closeModel(component, event, helper);
	},
	confirmDelete : function(component, event, helper) {
		helper.confirmDelete(component, event, helper);
	},
	recordUpdated : function(component, event, helper) {

    var changeType = event.getParams().changeType;

    if (changeType === "ERROR") { /* handle error; do this first! */ }
    else if (changeType === "LOADED") { console.log("Record template initialized");/* handle record load */ }
    else if (changeType === "REMOVED") { /* handle record removal */ }
    else if (changeType === "CHANGED") { 
      /* handle record change; reloadRecord will cause you to lose your current record, including any changes you’ve made */ 
      component.find("forceRecord").reloadRecord();}
    },
    cloneWithProducts : function(component, event, helper) {
    	$A.createComponent(
	        "c:NewProduct",
	        {
	            "PriceBookId": component.get("v.recordId")
	        },
	        function(newItem, status, errorMessage){
	            if (status === "SUCCESS") {
	            	var targetCmp = component.find('ModalDialogNewProduct');
	                var body = targetCmp.get("v.body");
	                body.push(newItem);
	                targetCmp.set("v.body", body);
	            }
	            else if (status === "INCOMPLETE") {
	                console.log("No response from server or client is offline.")
	            }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
	            }
	        }
	    );
    }
})