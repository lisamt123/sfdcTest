({
	doInit : function(component,helper) {
		var action = component.get("c.init");
		action.setParams(
			{"releaseId": component.get("v.recordId")}
		);
		action.setCallback(this,function(response) {
			var state = response.getState();
			if(state == "SUCCESS"){
				var result      = response.getReturnValue();
				var jsonObject  =JSON.parse(result);
				var message     = jsonObject.activeStatus;
				if (message == null) {
					if(jsonObject.logList.length != 0) {
                        component.set('v.connectionIdAndNameMap',jsonObject.connectionIdAndNameMap);
                        component.set('v.wrapperLog',jsonObject.logList);
                        if(jsonObject.validateRelease == 'true') 
                            component.set('v.showValidate',true);
                        else
                            component.set('v.showValidate',false);
                        if(jsonObject.deployRelease == 'true')
                            component.set('v.showDeploy',true);
                        else
                            component.set('v.showDeploy',false);
                        if(component.get('v.showDeploy') && jsonObject.logList[0].status == 'Succeeded' && jsonObject.logList[0].action == 'Validate' && jsonObject.logList[0].testsEnabled == 'true' && jsonObject.enableQuickDeploy)
                            component.set('v.showQuickDeploy',false);
                        else
                            component.set('v.showQuickDeploy',true);
                        var errorString = '';
                        if(!component.get('v.showValidate') && !component.set('v.showDeploy'))
                            errorString = 'You don\'t have the permission to validate and deploye anything on the target Connection of this Release.';
                        else if(!component.get('v.showValidate'))
                            errorString = 'You don\'t have the permission to validate anything on the target Connection of this Release.';
                        else if(!component.get('v.showDeploy'))
                            errorString = 'You don\'t have the permission to deploy anything on the target Connection of this Release.';
                        if(errorString != '') {
                            component.set("v.message", errorString);
                            component.set("v.messageType", "warning");
                            component.set("v.messageTitle", "Warning");
                            this.showMessage(component);
                        }
					}
                    this.updateTestOptions(component,jsonObject.testLevel,jsonObject.specifiedTests);
					component.set("v.isRefreshRunning", jsonObject.isRefreshRunning);
                    if(jsonObject.isRefreshRunning) {
                        var validationProgress = {
                            "numberComponentsTotal"    : 0,
                            "numberComponentsDeployed" : 0,
                            "numberComponentErrors"    : 0,
                            "numberTestsTotal"         : 0,
                            "numberTestsCompleted"     : 0,
                            "numberTestErrors"         : 0,
                            "pollTime"                 : 0,
                            "colorTheme1"              : '',
                            "colorTheme2"              : '',
                        };
                        component.set("v.validationProgress",validationProgress);
                    }
                    else
                        component.set("v.validationProgress", jsonObject.validationProgress);
					if(jsonObject.isRefreshRunning)
						this.getReleaseRefreshStatus(component,helper);
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
    doManageReleaseHelper : function(component,helper) {
        var releasAction = component.get("c.manageRelease");
        releasAction.setParams({ 'recId' : component.get("v.recordId")});
        releasAction.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {   
                this.doInit(component,helper);
            }
        });
        $A.enqueueAction(releasAction); 
    },
    updateTestOptions :  function(component,actionType,testClasses) {
        if(actionType == 'Default') {
            component.find('r0').set('v.value',true);
        }
        else if(actionType == 'Run Local Tests') {
            component.find('r1').set('v.value',true);
        }
        else if(actionType == 'Run All Tests') {
            component.find('r2').set('v.value',true);
        }
        else if(actionType == 'Run Specified Tests') {
            component.find('r3').set('v.value',true);
            component.set("v.runAllTests", true);
            var testClassNames = '';
            setTimeout(function() {
                component.find("comments").focus();
                testClasses.forEach(function(item,index) {
                    console.log(index);
                    console.log(item);
                    testClassNames += testClassNames == '' ? item : ',' + item ;
                });
                component.set("v.testClassesNames",testClassNames);
            },100);
        }
    },
	//used to hide lightning spinner by adding class slds-hide to lightning:spinner 
    hideSpinner : function(component) {
		var spinnerMain =  component.find("Spinner");
        $A.util.addClass(spinnerMain, "slds-hide");
	},
	//used to show lightning spinner by removing class slds-hide to lightning:spnner   
    showSpinner : function(component) {
		var spinnerMain =  component.find("Spinner");
        $A.util.removeClass(spinnerMain, "slds-hide");
	},
    //used to show custom message
    showMessage : function(component) {
        document.getElementById("customMessage").classList.remove("slds-hide");
    	setTimeout(function(){ 
    		if(document.getElementById("customMessage") != null){
    			document.getElementById("customMessage").classList.add("slds-hide");
			}
		}, 5000);
    },
    retriveDeploymentLogIssues : function(component,helper,buttonId,buttonClass) {
    	var action = component.get("c.retriveDeploymentLogIssues");
		action.setParams({
                "log_Id": buttonId,
                "recId" : component.get("v.recordId")
            }
		);
		action.setCallback(this,function(response) {
			var state = response.getState();
			if(state == "SUCCESS"){
				var result = response.getReturnValue();
                console.log(result.metadataList);
                result.metadataList.forEach(function(item,index) {
                    item.metadataName.forEach(function(field,index1) {
                        result.metadataList[index].metadataName[index1].name = decodeURIComponent(field.name);
                    });
                });
                $A.createComponent(
                    "c:ValidateResult",
                    {
                        "validationIssueList"   : result.LogIssue,
                        "validationProgress"    : result.validationProgress,
                        "metadataWrapperList"   : result.metadataList,
                        "status"                : buttonClass,
                        "testClassesList"       : result.specifiedTests,
                        "testLevel"             : result.testLevel,
                    },
                    function(newItem, status, errorMessage) {
                        if (status === "SUCCESS") {
                            var targetCmp   = component.find('validationresult');
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
			}
		});
		$A.enqueueAction(action);
    },
    getReleaseRefreshStatus : function(component,helper) {
        var action = component.get("c.retrieveRelease");
        action.setParams({"releaseId": component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {   
                var result = response.getReturnValue();
                
                component.set("v.isRefreshRunning", response.getReturnValue().release.Validation_Running__c);
                if(response.getReturnValue().runningStatus != null && response.getReturnValue().runningStatus != '' && response.getReturnValue().release.Validation_Status__c != 'Canceling' && component.get("v.runningStatus") != 'Canceling') {
                    component.set("v.runningStatus",response.getReturnValue().runningStatus);
                    component.set("v.validationProgress",response.getReturnValue().validationProgress);
                    component.set("v.asyncResultId",response.getReturnValue().release.AsyncResultId__c);
                }

                if(component.get("v.isRefreshRunning")) {
                    helper.getReleaseRefreshStatus(component,helper);
                    component.set("v.asyncResultId",response.getReturnValue().release.AsyncResultId__c);
                    if(response.getReturnValue().release.Validation_Describe_Error__c.contains('Validation'))
                        component.set("v.actionType",'Validation')
                    else
                        component.set("v.actionType",'Deployment')
                }
                else {
                    this.showSpinner(component);
                    component.set("v.asyncResultId",'');
                    this.doInit(component,helper);
                }
            }
           
        });
        $A.enqueueAction(action);
    },
    showResultMessage : function(component,helper,resultWrapper) {
        if(resultWrapper.status == 'Success') {
            component.set("v.isRefreshRunning", true);
            component.set("v.message", resultWrapper.message);
            component.set("v.messageType", "success");
            component.set("v.messageTitle", "Success");
            helper.showMessage(component);
            helper.getReleaseRefreshStatus(component,helper);
        }
        else {
            component.set("v.message", resultWrapper.message);
            component.set("v.messageType", "warning");
            component.set("v.messageTitle", "Warning");
            this.showMessage(component);  
        }
    },
    validateHelper : function(component,helper,actionType) {
        var runAllTests     = component.get("v.runAllTests");
        var testClassNames  = runAllTests ? document.getElementsByClassName('uiInputTextArea')[0].value.trim() : '';
        if(runAllTests && testClassNames == '') {
            component.set("v.message", "Please provide the name of at least one test class." );
            component.set("v.messageType", "warning");
            component.set("v.messageTitle", "Warning");
            helper.showMessage(component);
        }
        else {
            helper.deployHelper(component,helper,actionType,testClassNames,'',true);
        }
    },
    deployHelper : function(component,helper,actionType,testClassNames,recentValidationId,resetProgress) {
        helper.showSpinner(component);
        if(resetProgress) {
            component.set("v.runningStatus",'Waiting');
            var validationProgress                      = component.get("v.validationProgress");
            validationProgress.numberComponentsTotal    = 0;
            validationProgress.numberComponentsDeployed = 0;
            validationProgress.numberComponentErrors    = 0;
            validationProgress.numberTestsTotal         = 0;
            validationProgress.numberTestsCompleted     = 0;
            validationProgress.numberTestErrors         = 0;
            validationProgress.pollTime                 = 0;
            validationProgress.colorTheme1              = '';
            validationProgress.colorTheme2              = '';
            component.set("v.validationProgress",validationProgress);
        }
        else
            component.set("v.runningStatus",'Canceling');
        var testCase = '';
        var radioList = document.getElementsByName('others');
        for(var count = 0 ; count < radioList.length ; count++) {
            if(radioList[count].checked) 
                testCase = radioList[count].className;
        }
        if(testCase.indexOf('Default') != -1)
            testCase = 'Default';
        else if (testCase.indexOf('Run Local Tests') != -1) 
            testCase = 'Run Local Tests';
        else if (testCase.indexOf('Run All Tests') != -1) 
            testCase = 'Run All Tests';
        else if (testCase.indexOf('Run Specified Tests') != -1) 
            testCase = 'Run Specified Tests';
        var action = component.get("c.deployMetadata");
        action.setParams({
            "checkOnly"          : actionType,
            "releaseId"          : component.get("v.recordId"),
            "testCase"           : testCase,
            "testClassNames"     : testClassNames,
            "recentValidationId" : recentValidationId
        });
        action.setCallback(this,function(response) {
            var state   = response.getState();
            var result  = response.getReturnValue();
                console.log('====='+result);

            if(state == "SUCCESS")
                helper.showResultMessage(component,helper,result);
            else
                console.log("failed");
            helper.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    updateDivHeight : function(component) {
        var divHeight = (document.getElementById("modal-content-id-1").offsetHeight - 200);
        if( divHeight > 350)
            component.set('v.divHeight',divHeight);
        component.set('v.divWidth',document.getElementById('artifactsListContainer').clientWidth);
    }
})