({
	cancelClick : function(component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	},
	showLoading: function (cmp, event,helper) {
        helper.showLoadingHelper(cmp, event);
    },
    hideLoading: function (cmp, event,helper) {
        helper.hideLoadingHelper(cmp, event);
    },
    doInit: function(component, event, helper) {
    	helper.getAssignments(component);
    },
    toggleValidate: function(component, event, helper) {
        helper.showLoadingHelper(component, event);
        var index = event.target.getAttribute('value');
        var checkValue = event.target.checked ;
        var assignmentWrapperList = component.get('v.connectionAssignmentsList');
        for(var i = 0; i < assignmentWrapperList.length;i++) {
            if(i == index) {
                assignmentWrapperList[i].validateReleaseTo = checkValue ;
            }
        }
        component.set('v.connectionAssignmentsList',assignmentWrapperList);
        helper.hideLoadingHelper(component, event);
    },
    toggleDeploy: function(component, event, helper) {
        helper.showLoadingHelper(component, event);
        var index = event.target.getAttribute('value');
        var checkValue = event.target.checked ;
        var assignmentWrapperList = component.get('v.connectionAssignmentsList');
        for(var i = 0; i < assignmentWrapperList.length;i++) {
            if(i == index) {
                assignmentWrapperList[i].deployReleaseTo = checkValue ;
            }
        }
        component.set('v.connectionAssignmentsList',assignmentWrapperList);
        helper.hideLoadingHelper(component, event);
    },
    savePermission : function(component, event, helper) {
        console.log('here in save');
        helper.saveConnectionPermission(component);
    },
})