({
    doInit : function(component, event, helper) {
        component.set("v.recordCount",0);
        helper.refreshConnectHelper(component,'',helper);
    },
    cancelClick : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    onChange : function(component, event, helper) {
        helper.removeHide(component);
        var artifactsTypeVar = component.find("ArtifactsType");
        component.set("v.selectedMetadata", artifactsTypeVar.get("v.value"));
        component.find("searchInText").set("v.value",'');
        component.find("searchInText2").set("v.value",'');
        component.set("v.recordCount",0);
        document.getElementById('outerDiv').scrollTop = 0;
        var selconnectionsVar = component.find("Connections");
        helper.refreshConnectHelper(component, selconnectionsVar.get("v.value"),helper);
    },
    onClickPlus : function(component, event, helper) {
        helper.removeHide(component);
        helper.toggleRow(component, event.target.id, true);
        helper.addHide(component);
    },
    onClickRemove : function(component, event, helper) {
        helper.removeHide(component);
        helper.toggleRow(component, event.target.id, false);
        helper.addHide(component);
    },
    showOptFirstSec : function(component, event, helper) {
        var searchText = component.find("searchInText").get("v.value").trim();
        if(searchText.length > 2 && event.getParams().keyCode == 13 || (searchText.length == 0 && (event.getParams().keyCode == 8 || event.getParams().keyCode == 46))) {
            helper.removeHide(component);
            component.set("v.recordCount",0);
            component.find("searchInText2").set("v.value",'');
            var selconnectionsVar = component.find("Connections");
            helper.refreshConnectHelper(component,selconnectionsVar.get("v.value"),helper);
        }
    },
    showOptSecondSec : function(component, event, helper) {
        var searchText = component.find("searchInText2").get("v.value").trim();
        if(searchText.length > 2 && event.getParams().keyCode == 13 || (searchText.length == 0 && (event.getParams().keyCode == 8 || event.getParams().keyCode == 46))) {
            helper.showOptionsHelper(component,"searchInText2", "secondSection",searchText);
        }
    },
    refreshClick : function(component, event, helper) {
        helper.removeHide(component);
        var selconnectionsVar = component.find("Connections");
        var selectedConnection = selconnectionsVar.get("v.value");
        var action = component.get("c.refreshArtifacts");
        action.setParams({"selectedConnection": selconnectionsVar.get("v.value")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (component.isValid() && state === "SUCCESS") {   
                component.set("v.message", "Request to refresh Artifacts has been placed successfully.");
                component.set("v.messageType", "success");
                component.set("v.messageTitle", "Success");
                helper.showMessage(component);
                helper.addHide(component);
            }
           
        });
        $A.enqueueAction(action);
        helper.getConnectionRefreshStatus(component,helper);
    },  
    refreshConnection : function(component, event, helper) {
        component.set("v.recordCount",0);
        component.set("v.selectedMetadata",'All');
        component.find("searchInText").set("v.value",'');
        component.find("searchInText2").set("v.value",'');
        helper.removeHide(component);
        var selconnectionsVar = component.find("Connections");
        helper.refreshConnectHelper(component, selconnectionsVar.get("v.value"),helper);
    },
    updateClick : function(component, event, helper) {
        var recID = component.get("v.recordId");
        var action = component.get("c.createStoryArtifacts");
        action.setParams({"recId" : recID, "mainMetadataWrapperStr": JSON.stringify(component.get("v.metadataNameMapList"))});
        helper.removeHide(component);
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {   
                component.set("v.message", "Artifacts updated successfully.");
                component.set("v.messageType", "success");
                component.set("v.messageTitle", "Success");
                helper.showMessage(component);
                helper.addHide(component);
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            }
            else {
                helper.addHide(component);
            }    
        });
        $A.enqueueAction(action);
   },
    hideMessage:function(component,helper) {
        helper.hideMessage(component);
    }
})