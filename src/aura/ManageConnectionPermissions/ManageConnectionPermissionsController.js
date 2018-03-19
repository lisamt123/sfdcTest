({
	doInit: function(component, event, helper) {
		helper.getConnections(component);
	},
	cancelClick : function(component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	},
    savePermission : function(component, event, helper) {
        helper.saveConnectionPermission(component);
    },
	showLoading: function (cmp, event,helper) {
        helper.showLoadingHelper(cmp, event);
    },
    hideLoading: function (cmp, event,helper) {
        helper.hideLoadingHelper(cmp, event);
    },
    toggleAccordian: function(component, event, helper) {
    	helper.helperFun(component,event,event.getSource().get('v.name'));
    },
    toggleValidate: function(component, event, helper) {
        helper.showLoadingHelper(component, event);
        var indexes = event.target.getAttribute('value');
        var checkValue = event.target.checked ;
        var fields = indexes.split('_');
        var row = fields[0] ;
        var col = fields[1] ;
        var connectionWrapperList = component.get('v.connectionWrapperList');
        for(var i = 0; i < connectionWrapperList.length;i++) {
            for(var j = 0; j< connectionWrapperList[i].assignmentwrapperList.length; j++) {
                if(i == row && j == col) {
                    connectionWrapperList[i].assignmentwrapperList[j].validateReleaseTo = checkValue ;
                }
            }
        }
        component.set('v.connectionWrapperList',connectionWrapperList);
        helper.hideLoadingHelper(component, event);
    },
    toggleDeploy: function(component, event, helper) {
        helper.showLoadingHelper(component, event);
        var indexes = event.target.getAttribute('value');
        var checkValue = event.target.checked ;
        var fields = indexes.split('_');
        var row = fields[0] ;
        var col = fields[1] ;
        var connectionWrapperList = component.get('v.connectionWrapperList');
        for(var i = 0; i < connectionWrapperList.length;i++) {
            for(var j = 0; j< connectionWrapperList[i].assignmentwrapperList.length; j++) {
                if(i == row && j == col) {
                    connectionWrapperList[i].assignmentwrapperList[j].deployReleaseTo = checkValue ;
                }
            }
        }
        component.set('v.connectionWrapperList',connectionWrapperList);
        helper.hideLoadingHelper(component, event);
    },
})