({
	doInit:function(component,event,helper) {
        console.log("doinit in controller");
		var action = component.get("c.getInit");
		action.setParams(//
			{ "releaseId" : component.get("v.recordId")}
        );
		action.setCallback(this,function(response) {
			var state = response.getState();
            console.log(state);
			if(state == "SUCCESS"){
				var result = response.getReturnValue();
				var jsonObject=JSON.parse(result);
                //console.log("jsonObject.baseUrl");
                //console.log(jsonObject.baseUrl);
                component.set("v.releaseArtifactList", jsonObject.releaseArtifactList);
                component.set("v.releaseStoryList", jsonObject.releaseStoryList);
                component.set("v.baseUrl", jsonObject.baseUrl);
                helper.hideSpinner(component);
            }	
		});
		$A.enqueueAction(action);			
	},
    cancelClick : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },   
    toggel:function(component,event,helper) {
		var buttonClass = event.target.getAttribute("class");
    	var childElemList = document.getElementsByClassName("child"+buttonClass);
        for(var i=0; i<childElemList.length; i++) {
        	childElemList[i].classList.toggle('slds-hide');
        } 
        var img = document.getElementById(buttonClass).src;        
        if (img.includes("expand")) {
            document.getElementById(buttonClass).src  = img.replace('expand','collapse');
        }
         else {
           document.getElementById(buttonClass).src  = img.replace('collapse','expand');
       	}
    }
})