({
    doInit : function(component, event, helper) {
        var startDate   = component.find("startId").get("v.value");
        var endDate     = component.find("endId").get("v.value");
        var projectName = component.find("projectId").get("v.value");
        
        if(component.get("v.allData") == null || component.get("v.allData").length == 0  ) {
            var action = component.get("c.getDefaultValues");
            action.setParams({'startDateString' : startDate,
                                'endDateString' : endDate,
                                'project'       : component.get("v.project"),
                                'assignIdSet'   : '[]'
                            });
            action.setCallback(this, function(a) {
                if(a.getReturnValue() != null && a.getReturnValue().length > 0) {
                    component.set("v.startDate",a.getReturnValue()[0].staretDate );
                    component.set("v.endDate",a.getReturnValue()[0].endDate );
                    component.set("v.projectOptions",a.getReturnValue()[0].projectOption ); 
                    component.set("v.project",'All Projects');
                    
                    if(a.getReturnValue()[0].projectOption == '---None---' || typeof a.getReturnValue()[0].project.Id == 'undefined')
                        component.set("v.errorMessage",'No Time Entries were found for the selected time frame.');
                    else {
                        component.set("v.errorMessage",null);
                        component.set("v.allData",a.getReturnValue());
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },
	onScripLoad : function(component, event, helper) {
        var startDate   = component.find("startId").get("v.value");
        var endDate     = component.find("endId").get("v.value");
        var projectName = component.find("projectId").get("v.value");
        if(startDate == endDate && startDate != '' && endDate != '') {   
            helper.showMessage('Error','Start date must be less then end date.');
            document.getElementById('tBodyId').display = 'none';
        }
        else if(startDate == '' || endDate == '') {   
            if(startDate == '' && endDate == '')
                helper.showMessage('Error','Start date and end date are required.');
            else if(startDate == '')
                helper.showMessage('Error','Start date is required.');
            else if(endDate == '')
                helper.showMessage('Error','End date is required.');
            document.getElementById('tBodyId').display = 'none';        
        }
        else if(startDate > endDate) {   
            helper.showMessage('Error','Start date must be less then end date.');
            document.getElementById('tBodyId').display = 'none';
        }
        
        else {
            var setId = component.get("v.assignSetId");
            if(event.target != undefined) {
                var buttonId = event.target.id;
                if(buttonId != 'reportBtn') {
                    if(setId.indexOf(event.target.id) != -1) {
                        setId.splice(setId.indexOf(event.target.id),1);
                    }
                    else {
                        setId.push(event.target.id);
                        component.set("v.assignSetId",setId);
                        setId.indexOf(event.target.id);
                    }    
                }
                else {
                    component.set("v.assignSetId",[]);
                    setId = component.get("v.assignSetId");
                }
            }
            else
                console.log('initial');

            component.set("v.message",'');
            var action = component.get("c.getDefaultValues");
            action.setParams({'startDateString' : startDate,
                                'endDateString' : endDate,
                                'project'       : projectName,
                                'assignIdSet'   : JSON.stringify(setId)
                            });
            action.setCallback(this, function(a) {
                component.set("v.allData",a.getReturnValue());
                if(typeof a.getReturnValue()[0].project.Id == 'undefined')
                    component.set("v.errorMessage",'No Time Entries were found for the selected time frame.');
                else
                    component.set("v.errorMessage",null);
                document.getElementById('tBodyId').display = 'none';
            });
            $A.enqueueAction(action);
        }
    },
    showSpinner: function(component, event, helper) {
    	helper.showSpinner(component, event, helper);
	},
    hideSpinner: function(component, event, helper) {
    	helper.hideSpinner(component, event, helper);
	},
    exportToPdfColapsed: function(component, event, helper) {
        helper.exportToPdfColapsed(component, event, helper);
    },
    exportToPdfExpended: function(component, event, helper) {
        helper.exportToPdfExpended(component, event, helper);
    },
})