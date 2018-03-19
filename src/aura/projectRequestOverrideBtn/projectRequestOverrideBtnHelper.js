({
        
    Intialise : function(component,event,helper) {
        var action = component.get("c.Intialise");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") { 
                var wrapperObject = response.getReturnValue();
                //Intialise the list with the null record
                var lstprd =[];
                lstprd.push(wrapperObject.PRD);
                component.set("v.ProjectRD",lstprd);
                //Adding the Role PickListValues
                component.set("v.RolePickValues",wrapperObject.RolePickValues);
                //Adding the LoggedInUserProjects
                component.set("v.lstActiveProjectsForCurrentUser", wrapperObject.ActiveProjects);  
                var rowValidationList =[];
                rowValidationList[0]= false;
                component.set("v.rowValidationList",rowValidationList);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });     
        $A.enqueueAction(action);
	},
    setPrdDates : function (component,event,helper){
        var project = component.get("v.Project");
        var lstprd = component.get("v.ProjectRD"); 
        //changing the start/End date for the first row
        for(var i=0;i<lstprd.length;i++){
            lstprd[i].Requested_Start_Date__c = project.Start_Date__c;
            lstprd[i].Requested_End_Date__c =  project.End_Date__c;
        }        
        component.set("v.ProjectRD",lstprd);
    },
    
    SetPRDRows : function (component,event,helper){
        var action = component.get("c.incrementPRDRow");
        var project = component.get("v.Project");
        action.setParams({ "project" : component.get("v.Project")});
		action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {   
                var lstprd = component.get("v.ProjectRD"); 
                lstprd.push(response.getReturnValue());
                component.set("v.ProjectRD",lstprd);
                var rowValidationList = component.get("v.rowValidationList");
                rowValidationList.push(false);                
                component.set("v.rowValidationList",rowValidationList);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });     
        $A.enqueueAction(action);
        
    },
    
    projectChange: function(component,event,helper){
        var selectedValue = component.find("projectSelectedID").get("v.value");
        console.log('Entered:');
        component.set("v.isDisable",false);
        var projectRD = component.get("v.ProjectRD");
        projectRD.splice(0,(projectRD.length)-1);
        component.set("v.ProjectRD",projectRD);

        if(selectedValue == 'idNone')
        {
            document.getElementById('ShowExpertsBtn').style.display = "none";
            document.getElementById('opPanel').style.display = "none";
            $A.util.removeClass(component.find("ProjectDetails"),'slds-show');
            $A.util.addClass(component.find("ProjectDetails"),'slds-hide');
            $A.util.removeClass(component.find("block2ID"),'slds-show');
            $A.util.addClass(component.find("block2ID"),'slds-hide');
            component.set("v.isDisable",true);
        }
        else if(selectedValue == 'idNewProject')
        {
            var project = component.get("v.Project");
            project.Name = '';
            project.End_Date__c = '';
            project.Start_Date__c = '';
            component.set("v.pRDescription", "");
            component.set("v.Project",JSON.parse(JSON.stringify(project)));
            $A.util.removeClass(component.find("ProjectDetails"),'slds-hide');
            $A.util.addClass(component.find("ProjectDetails"),'slds-show');
            $A.util.removeClass(component.find("block2ID"),'slds-hide');
            $A.util.addClass(component.find("block2ID"),'slds-show');
            document.getElementById('ShowExpertsBtn').style.display = "block";
        }
        else
        {
            var action = component.get("c.ProjectRecord");
            var projectRecordId = component.get("v.Project");
            $A.util.removeClass(component.find("ProjectDetails"),'slds-hide');
            $A.util.addClass(component.find("ProjectDetails"),'slds-show');
            $A.util.removeClass(component.find("block2ID"),'slds-hide');
            $A.util.addClass(component.find("block2ID"),'slds-show');
            document.getElementById('ShowExpertsBtn').style.display = "block";
            action.setParams({"selectedProjectRecordID" : selectedValue});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {                
                    component.set("v.Project",response.getReturnValue());
                    var prdList = component.get("v.ProjectRD");
                    var currentProject = component.get("v.Project");
                    if(prdList.length == 1){
                        prdList[0].Requested_Start_Date__c = currentProject.Start_Date__c;
                        prdList[0].Requested_End_Date__c = currentProject.End_Date__c;
                        component.set("v.ProjectRD", JSON.parse(JSON.stringify(prdList)));
                    }
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error at addNewProject");
                    }
                }
            }); 
            $A.enqueueAction(action);
           
        }
    },
    
    save : function(component,event,helper){
        component.set("v.isDisable",true);
        console.log('+++++++'+JSON.stringify(component.get("v.ProjectRD")));
        var isError = helper.validationCheck(component,event,helper);  
        if(isError){
            component.set("v.isDisable",false);
            helper.DisplayToast(component,event,helper,'Please fill all the fields which are marked as * and the Hours should be greater than 0 if selected','pester','error');
        }
        else{
            var action = component.get("c.insertprojectRecord");
            console.log(JSON.stringify('======='+component.get("v.ProjectRD")));
        	action.setParams({ 
                            "objProjectToInsert" : component.get("v.Project"),
            				"strProjectReqDetailToInsert" : JSON.stringify(component.get("v.ProjectRD")),
                			"pRDescription" : component.get("v.pRDescription")
                         });
        
        	action.setCallback(this, function(response) {
                component.set("v.isDisable",false);
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") { 
                    var saveResponse = response.getReturnValue();
                    if(saveResponse.isError){ 
                        helper.DisplayToast(component,event,helper,saveResponse.Error_SuccessMsg,'sticky','error');
                    }
                    else{ 
                        helper.hideModalBox(component, event, helper);
                        helper.DisplayToast(component,event,helper,'Request Submitted Sucessfully','pester','success');
                        helper.gotoRecord(component,event,helper,saveResponse.ProjectRequestId);
                    }                                  
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            }); 
        	$A.enqueueAction(action);
        }
        
    },
    
    //Commented out the Requeste Rate field as per the story: S-0024.
    //Add the below line inside the if condition under the for Loop
    //PRDs[i].Requested_Rate__c == null || PRDs[i].Requested_Rate__c == 0
    validationCheck: function(component,event,helper){
        var PRDs = component.get("v.ProjectRD");
        console.log('In Validation'+PRDs);
        var ProjectId = component.find("projectSelectedID").get("v.value");
        var projectRecord = component.get("v.Project");
        var pRDescription = component.get("v.pRDescription");
        var isError = false;  
        //checks the project Required fields 
        if((ProjectId == 'idNewProject' && (projectRecord.Name == '' || projectRecord.Start_Date__c == '' ||
                projectRecord.Start_Date__c == null || projectRecord.End_Date__c == '' ||
				projectRecord.End_Date__c == null || pRDescription == ' ' || pRDescription == null))
          ){
            isError = true;
        }
        else{
            for(var i=0; i<PRDs.length-1;i++){
                if(PRDs[i].Requested_Allocation__c == '')
                {
                    if(PRDs[i].Role__c == '' || PRDs[i].Requested_Start_Date__c == null ||
                      PRDs[i].Requested_End_Date__c == null || PRDs[i].Requested_Hours__c == null ||
                       PRDs[i].Requested_Hours__c == 0 || PRDs[i].Description__c == ''                
                       
                      ){
                        component.get("v.rowValidationList")[i]= true;                   
                        component.set("v.rowValidationList",JSON.parse(JSON.stringify(component.get("v.rowValidationList"))));                
                        var projectRds = component.get("v.ProjectRD");
                        component.set("v.ProjectRD",JSON.parse(JSON.stringify(projectRds)));                
                        isError = true;
                    }
                }
                else
                {   console.log(PRDs[i].Requested_Allocation__c);
                    if(PRDs[i].Role__c == '' || PRDs[i].Requested_Start_Date__c == null ||
                      PRDs[i].Requested_End_Date__c == null || PRDs[i].Requested_Allocation__c == 'None' || PRDs[i].Description__c == ''                
                       
                      ){
                        component.get("v.rowValidationList")[i]= true;                   
                        component.set("v.rowValidationList",JSON.parse(JSON.stringify(component.get("v.rowValidationList"))));                
                        var projectRds = component.get("v.ProjectRD");
                        component.set("v.ProjectRD",JSON.parse(JSON.stringify(projectRds)));                
                        isError = true;
                    }
                }
            }
        }    
        return isError;
    },
    hideModalBox : function(component,event,helper){
        component.find("projectSelectedID").set("v.value", "idNone");
        component.set("v.pRDescription", "");
        document.getElementById("backGroundSectionId").style.display = "none";
		document.getElementById("newProjectRequestSectionId").style.display = "none";
    },
    DisplayToast: function(component,event,helper,msg,mode,type){
        var context = component.get("v.context");
        if(context != undefined){
            alert('PageMessage'+msg);
        }
        else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "message": msg,
                "mode" : mode,
                "type" : type
            });
            toastEvent.fire();
        }
    },
    gotoRecord : function(component, event, helper,projectRequestId) {
        // Fire the event to navigate to the contact record
        var context = component.get("v.context");
        if(context != undefined){
            if(context == 'Theme4t' || context == 'Theme4d') {
                   //Page rendered in VF in S1 or LEX.
                   sforce.one.navigateToSObject(projectRequestId);
               } else {
                   //Page rendered in VF in Classic.                    
                   window.location.assign('/'+projectRequestId);
               }
        }
        else{
            var sObjectEvent = $A.get("e.force:navigateToSObject");
            sObjectEvent.setParams({
                "recordId":projectRequestId,
                "slideDevName": 'related'
            })
            sObjectEvent.fire();
        }
    }
    
})