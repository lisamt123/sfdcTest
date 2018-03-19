({
	doInit : function(component, event, helper) {
		//calling helper doInit method to load avilable artifacts
		helper.doManageReleaseHelper(component,helper);
		//helper.doInit(component,helper);
	},
	cancelClick : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
	onGroup : function(component, event) {
		var selectedLabel = event.getSource().get("v.class");
		if(selectedLabel == 'Run Specified Tests') {
			component.set("v.runAllTests", true);
			setTimeout(function() {
				component.find("comments").focus();
			},100);
		}
		else
			component.set("v.runAllTests", false);
	},
	validate : function(component,event,helper) {
		component.set("v.actionType",'Validation')
		helper.validateHelper(component,helper,'true');
	},
	deploy : function(component,event,helper) {
		component.set("v.actionType",'Deployment')
		helper.validateHelper(component,helper,'false');
	},
	quickDeploy : function(component,event,helper) {
		component.set("v.actionType",'Deployment')
		var object = component.get('v.wrapperLog');
		helper.deployHelper(component,helper,'quicklyDeploy','',object[0].asyncResultId,true);
	},
	cancelDeploy : function(component,event,helper) {
		var object = component.get('v.wrapperLog');
		component.set("v.releaseStatus","Canceling");
		helper.deployHelper(component,helper,'cancelDeploy','',component.get("v.asyncResultId"),false);
	},
	toggel : function(component,event,helper) {
		var buttonId 	= event.target.getAttribute("id");
		var buttonClass	= event.target.getAttribute("class");
		var img 		= event.target.getAttribute("src"); 
        helper.showSpinner(component);
        helper.retriveDeploymentLogIssues(component,helper,buttonId,buttonClass);
    },
	hideMessage : function(component,event,helper) {
        helper.hideMessage(component);
    }
})