({
    doInitHelper :function(component,helper) {
        var action = component.get("c.getCodeReviewFunctionality");
        action.setParams(
            {"recId": component.get("v.recordId")}
        );
        action.setCallback(this,function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                var logListWrapper  = JSON.parse(response.getReturnValue());
                var message         = logListWrapper.activeStatus;
                if (message == null) {
                    if(logListWrapper.logList.length != 0) {
                        component.set('v.wrapperLog',logListWrapper.logList);
                    }
                    component.set("v.objctAPIName",logListWrapper.objctAPIName);
                    component.set("v.objctLabel",logListWrapper.objctLabel);
                    component.set("v.isRefreshRunning",logListWrapper.isRefreshRunning);
                    if(logListWrapper.isRefreshRunning) {
                        helper.getStoryRefreshStatus(component,helper);
                    }
                }
                else {
                    component.set("v.showButtons",false);   
                    component.set("v.message", message);
                    component.set("v.messageType", "warning");
                    component.set("v.messageTitle", "Warning");
                    this.showMessage(component);                      
                }
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    doManageReleaseHelper :function(component,helper) {
        var releasAction = component.get("c.manageRelease");
        releasAction.setParams({ 'recId' : component.get("v.recordId")});
        releasAction.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") { 
                this.doInitHelper(component,helper);
            }
        });
        $A.enqueueAction(releasAction); 
    },
    doScanHelper :function(component,helper) {
        var action = component.get("c.scanCode");
        action.setParams(
            {"recId": component.get("v.recordId"),'objectName': component.get("v.objctAPIName")}
        );
        action.setCallback(this,function(response) {
            console.log(response);
            var state = response.getState();
            console.log(state);
            if(state == "SUCCESS") {
                var resultWrapper  = response.getReturnValue();
                if(resultWrapper.status == 'Success') {
                    component.set("v.message", "Your request to Scan has been sent Successfully.");
                    component.set("v.messageType", "success");
                    component.set("v.messageTitle", "Success");
                    this.showMessage(component);  
                    component.set("v.isRefreshRunning", true);
                    helper.getStoryRefreshStatus(component,helper);
                }
                else {
                    component.set("v.message", resultWrapper.message);
                    component.set("v.messageType", "warning");
                    component.set("v.messageTitle", "Warning");
                    this.showMessage(component);  
                }
                
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if(errors[0] && errors[0].message) { // To show other type of exceptions
                    component.set("v.message", errors[0].message);
                    component.set("v.messageType", "error");
                    component.set("v.messageTitle", "Error");
                    helper.showMessage(component);
                }
                if(errors[0] && errors[0].pageErrors) { // To show DML exceptions
                    component.set("v.message", errors[0].pageErrors[0].message);
                    component.set("v.messageType", "error");
                    component.set("v.messageTitle", "Error");
                    helper.showMessage(component);
                }
            }
            helper.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    //used to hide lightning spinner by adding class slds-hide to lightning:spinner 
    hideSpinner: function(component) {
        console.log("addhide");
        var spinnerMain =  component.find("Spinner");
        $A.util.addClass(spinnerMain, "slds-hide");
    },
    //used to show lightning spinner by removing class slds-hide to lightning:spnner   
    showSpinner: function(component) {
        console.log("removehide");
        var spinnerMain =  component.find("Spinner");
        $A.util.removeClass(spinnerMain, "slds-hide");
    },
    //used to show custom message
    showMessage:function(component) {
        document.getElementById("customMessage").classList.remove("slds-hide");
        setTimeout(function() { document.getElementById("customMessage").classList.add("slds-hide"); }, 5000);
    },
    //used to hide custom message
    hideMessage:function(component) {
        document.getElementById("customMessage").classList.add("slds-hide");
    },
    retriveScanLogIssues:function(component,helper,buttonClass) {
        $A.createComponent(
            "c:ScanResult",
            {
                "recordsLimit"  : '0',
                "objctAPIName"  : component.get("v.objctAPIName"),
                "logId"         : buttonClass,
                "recId"         : component.get("v.recordId")
            },
            function(newItem, status, errorMessage) {
                if (status === "SUCCESS") {
                    var targetCmp   = component.find('scanresult');
                    var body        = targetCmp.get("v.body");
                    body.push(newItem);
                    targetCmp.set("v.body", body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
                helper.hideSpinner(component);
            }
        );
    },
    getStoryRefreshStatus : function(component,helper)
    {
        var action = component.get("c.retrieveStory");
        action.setParams({"recId": component.get("v.recordId"),'objectName': component.get("v.objctAPIName")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {   
                if(response.getReturnValue().Scan_Running__c) {
                    component.set("v.isRefreshRunning", response.getReturnValue().Scan_Running__c);
                    helper.getStoryRefreshStatus(component,helper);
                }
                else {
                    component.set("v.isRefreshRunning", response.getReturnValue().Scan_Running__c);
                    this.showSpinner(component);
                    var rowList = document.getElementsByClassName('innerRow');
                    for(var i = 0;i < rowList.length ;i++) { 
                        rowList[i].remove(); 
                        i = -1;
                    }
                    this.doInitHelper(component,helper);
                }
            }
        });
        $A.enqueueAction(action);
    } 
})