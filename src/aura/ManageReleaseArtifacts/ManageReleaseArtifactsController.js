({
	doInit : function(component, event, helper) {
        helper.doManageReleaseHelper(component);
        //helper.doInitHelper(component,true);
	},

    refreshComp : function(component, event, helper) {
        helper.removeHide(component);
        console.log('executed');
        component.set("v.isUpdate",false);
        component.set("v.recordCount",0);
        var emptyList = [];
        component.set("v.metadataNameMapList",emptyList);
        component.set("v.selectedStorySet",emptyList);
        helper.doInitHelper(component,true);
    },

    cancelClick : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    sortColumn : function(component, event, helper) {
        helper.sortColumnHelper(component,event,helper);
    },
    onChangeSprint : function(component, event, helper) {
        helper.removeHide(component);
    	var selectedSprintVar = component.find("currentSprints");
        component.set("v.selectedSprint",selectedSprintVar.get("v.value"));
    	helper.processSprintRetrieveStories(component,selectedSprintVar,helper);
    },
    onChangeMetadata : function(component, event, helper) {
    	helper.removeHide(component);
        var artifactsTypeVar = component.find("MetadataType");
        component.set("v.selectedMetadata", artifactsTypeVar.get("v.value"));
        component.find("searchInText").set("v.value",'');
        component.find("searchInText2").set("v.value",'');
        component.set("v.recordCount",0);
        document.getElementById('outerDiv').scrollTop = 0;
        var selconnectionsVar = component.find("Connections");
        helper.doInitHelper(component,true);
	},
    onChangeMetadataOPtionType : function(component, event, helper) {
        helper.removeHide(component);
        var metadataOptionType = component.find("MetadataOptionType");
        var searchText = component.get("v.cssString","");
        component.set("v.recordCount",0);
        component.set('v.flag',true);
        if(metadataOptionType.get("v.value") == 'metadata') {
            component.set("v.addMetadata", true);
            setTimeout(function(){ 
                component.set("v.cssString","");
                var scroll = document.getElementById('outerDiv');
                var prevLeft = 0;
                if(component.get("v.addMetadata")) {
                    scroll.onscroll = function(ev) {
                        var currentLeft = scroll.scrollLeft;
                        if(prevLeft != currentLeft) {
                            prevLeft = currentLeft;
                        }
                        else {
                            var total = scroll.scrollTop + scroll.clientHeight;
                            if(Math.ceil(total) >= document.getElementById('innerDiv').clientHeight) {
                                helper.removeHide(component);
                                component.find("searchInText2").set("v.value",'');
                                var artifactsTypeVar = component.find("MetadataType");
                                component.set("v.selectedMetadata", artifactsTypeVar.get("v.value"));
                                helper.doInitHelper(component);
                            } 
                        }
                    }
                }
                helper.doInitHelper(component,false);
            }, 100);
        }
        else {
            component.set("v.addMetadata", false);
            setTimeout(function(){ 
                component.set("v.cssString","");
                helper.doInitHelper(component,false);
            }, 100);
        }
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
    updateSelectedStorySet : function(component, event, helper) {
        var selectedStories = component.get("v.selectedStorySet");
        if(event.getSource().get('v.value')) 
            selectedStories.push(event.getSource().get('v.name'));
        else {
            var idIndex = selectedStories.indexOf(event.getSource().get('v.name'));
            if(idIndex != -1)
                selectedStories.splice(idIndex,1);
        }
        helper.removeHide(component);
        helper.updateStoriesHelper(component,event);
        //component.set("v.selectedStorySet",selectedStories);
    },
    showOptFirstSec : function(component, event, helper) {
        var searchText = component.find("searchInText").get("v.value").trim();
        if(searchText.length > 2 && event.getParams().keyCode == 13 || (searchText.length == 0 && (event.getParams().keyCode == 8 || event.getParams().keyCode == 46))) {
            helper.removeHide(component);
            component.set("v.recordCount",0);
            component.find("searchInText2").set("v.value",'');
            var recID = component.get("v.recordId");
            var selconnectionsVar = component.find("Connections");
            helper.doInitHelper(component, true);
        }
    },
    showOptSecondSec : function(component, event, helper) {
        var searchText = component.find("searchInText2").get("v.value").trim();
        if(searchText.length > 2 && event.getParams().keyCode == 13 || (searchText.length == 0 && (event.getParams().keyCode == 8 || event.getParams().keyCode == 46))) {
            helper.showOptionsHelper(component,"searchInText2", "secondSection",searchText);
        }
    },
    refreshClick : function(component, event, helper) {
        helper.removeHide(component); console.log('---------'+component.get("v.recordId"));
        var action = component.get("c.refreshArtifacts");
        action.setParams({"recId": component.get("v.recordId")});
        action.setCallback(this, function(response) 
        {
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
    updateArtifactsJs : function(component, event, helper){
        helper.removeHide(component);
        helper.updateArtifactsHelper(component);
    },
    hideMessage:function(component,event,helper) {
        helper.hideMessage(component);
    }
})