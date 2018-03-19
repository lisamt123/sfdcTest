({
	cancelClick : function(component, event, helper) {
        var refreshEvent = component.getEvent("refreshReleaseArtifacts");
        refreshEvent.fire();
        component.destroy();
    },
    updateSelectedStoryChkbk : function(component, event, helper) {
        var checkList = component.find("storyInputSelected");
        if(typeof (checkList.length) == "undefined") {
            if(checkList.get("v.value"))
            	component.set("v.isUpdate",true);
            else
            	component.set("v.isUpdate",false);
        } 
        else {
        	var flag = false;
            for(var chk in checkList)
                if(checkList[chk].get("v.value"))
                	flag = true;
            component.set("v.isUpdate",flag);
        }
    },
    updateReleaseStoryArtifacts : function(component, event, helper) {
        var action = component.get("c.updateStoryReleaseArtifacts");
        var storyId = [];
        var checkList = component.find("storyInputSelected");
        if(typeof (checkList.length) == "undefined") {
            if(checkList.get("v.value"))
            	storyId.push(checkList.get("v.label"));
        } 
        else {
        	var flag = false;
            for(var chk in checkList)
                if(checkList[chk].get("v.value"))
                	storyId.push(checkList[chk].get("v.label"));
            component.set("v.isUpdate",flag);
        }
        console.log('=========='+component.get("v.releaseId"));
        console.log('=========='+storyId[0]);
        action.setParams({
        	"recId" 		: component.get("v.releaseId"),
        	"storyIdList" 	: storyId
        });
        action.setCallback(this,function(response) {
        	var state = response.getState();
        	if (component.isValid() && state === "SUCCESS") { 
                console.log(response.getReturnValue());
                var refreshEvent = component.getEvent("refreshReleaseArtifacts");
                refreshEvent.fire();
                component.destroy();
            }
            else if (state === "ERROR") {
                helper.showErrorMessage(component,response);
            }
        });
        $A.enqueueAction(action);
    },
})