({
	showSpinner : function (component, event, helper)  {
        var spinnerMain =  component.find("Spinner");
        $A.util.removeClass(spinnerMain, "slds-hide");
	},
  
    hideSpinner : function (component, event, helper) {
        var spinnerMain =  component.find("Spinner");
        $A.util.addClass(spinnerMain, "slds-hide");
    },
  	exportToPdfColapsed: function (component, event, helper) {
        var startDate   = component.find("startId").get("v.value");
        var endDate     = component.find("endId").get("v.value");
        var projectName = component.find("projectId").get("v.value");
        window.open('/10kcommunity/ExportTimeEntryData?sDate=' + startDate + '&eDate=' + endDate + '&project=' + projectName + '&Expended=false');    
  	},
  	exportToPdfExpended: function (component, event, helper) {
        var startDate   = component.find("startId").get("v.value");
        var endDate     = component.find("endId").get("v.value");
        var projectName = component.find("projectId").get("v.value");
        window.open('/10kcommunity/ExportTimeEntryData?sDate=' + startDate + '&eDate=' + endDate + '&project=' + projectName + '&Expended=true');    
  	},
    showMessage : function(type,message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "message": message
        });
        toastEvent.fire();
    },
})