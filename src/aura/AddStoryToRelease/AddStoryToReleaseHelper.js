({
    showMessage:function(component) {
        document.getElementById("customMessage").classList.remove("slds-hide");
        setTimeout(function(){ 
            if(document.getElementById("customMessage") != null)
                document.getElementById("customMessage").classList.add("slds-hide");
        }, 5000);
    },
    hideSpinner : function(component) {
        var spinnerMain =  component.find("Spinner");
        $A.util.addClass(spinnerMain, "slds-hide");
    },
    showSpinner: function(component) {
        var spinnerMain =  component.find("Spinner");
        $A.util.removeClass(spinnerMain, "slds-hide");
    },
    doInitHelper : function(component) {
        var action = component.get("c.retrieveReleaseList");
        action.setParams({'recId':component.get("v.recordId")});
        action.setCallback(this,function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result',result);
                component.set("v.isCreatedOnHeroku",result.isCreatedOnHeroku);
                component.set("v.statusOption",result.releaseStatusPickValues); 
                if(result.isCreatedOnHeroku) {
                    component.set("v.releaseOptions",result.releaseIdList);
                    component.set("v.source",result.source);
                }
                else {
                    component.set("v.message", 'No artifacts attached to this story, please add artifacts before adding it to release.');
                    component.set("v.messageType", "error");
                    component.set("v.messageTitle", "Error");
                    this.showMessage(component);
                }
                component.set("v.story",result.story);
                if(component.get("v.isExitRelease")) {
                    this.addReleaseOptions(component,"releaseList","v.releaseOptions");
                }
                this.hideSpinner(component);
            }
            else if (state === "ERROR") {
                this.showErrorMessage(component,response);
            }
        });
        $A.enqueueAction(action);
    },
    addReleaseOptions : function(component,listId,options) {
        var metadataOptionArray = component.get(options);
        var metadataOpts = [];
        metadataOpts.push({ "class": "optionClass", label: "None", value: "", selected: "true" });
        for (var i = 0; i < metadataOptionArray.length; i++) {
            metadataOpts.push({ "class": "optionClass", label: metadataOptionArray[i].label, value: metadataOptionArray[i].value });
        }
        component.find(listId).set("v.options", metadataOpts);
    },
    addStoryToNewRelease : function (component, releaseId) {
        if(releaseId == 'demo') {
            var action = component.get("c.createRelease");
            action.setParams({
                "releaseRec": component.get("v.release")
            });
            var releaseObj = component.get("v.release");
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") { 
                    if(response.getReturnValue().status == 'Success') {
                        this.updateReleaseStoryArtifacts(component,response.getReturnValue().releaseId,releaseObj.Name);
                    }
                    else {
                        component.set("v.message", response.getReturnValue().message);
                        component.set("v.messageType", "error");
                        component.set("v.messageTitle", "Error");
                        this.showMessage(component);
                    }
                }
                else if (state === "ERROR") {
                    this.showErrorMessage(component,response);
                }
                this.hideSpinner(component);
            });
            $A.enqueueAction(action);
        }
        else {
            var metadataOptionArray = component.get('v.releaseOptions');
            var releaseName;
            for (var i = 0; i < metadataOptionArray.length; i++) {
                if(metadataOptionArray[i].value == releaseId){
                    releaseName = metadataOptionArray[i].label ;
                    break;
                }
            } 
            this.updateReleaseStoryArtifacts(component,releaseId,releaseName);
        }
    },
    updateReleaseStoryArtifacts : function(component,releaseId,releaseName) {
         var action = component.get("c.updateReleaseStoryArtifacts");
            action.setParams({
                "releaseId" : releaseId,
                "storyId"   : component.get("v.recordId")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") { 
                    if(response.getReturnValue().status == 'Success') {
                        
                        var toastEvent = $A.get("e.force:showToast");
                        var fullUrl = window.location.href ;
                        var detailUrl = response.getReturnValue().returnUrl;
                        toastEvent.setParams({
                            "type": "success",    
                            "title": "Success!",
                            "message": "Story successfully added to Release {0}",
                            "messageTemplate": 'Story successfully added to Release {0}',
                            "messageTemplateData": [{
                                                        url: detailUrl ,
                                                        label: releaseName,
                                                    }]
                        });
                        toastEvent.fire();
                        this.updateReleaseAndStory(component,releaseId,component.get("v.recordId"));
                        setTimeout(function(){
                            $A.get("e.force:closeQuickAction").fire();
                        },1000);
                    }
                    else {
                        component.set("v.message", response.getReturnValue().message);
                        component.set("v.messageType", "error");
                        component.set("v.messageTitle", "Error");
                    }
                    this.hideSpinner(component);
                }
                else if (state === "ERROR") {
                    this.showErrorMessage(component,response);
                }
            });
            $A.enqueueAction(action);
    },
    showErrorMessage : function(component,response) {
        var errors = response.getError();
        if (errors) {
            errors.forEach( function (error) {

                if (error.message) {
                    component.set("v.message", error.message);
                    component.set("v.messageType", "error");
                    component.set("v.messageTitle", "Error");
                    this.showMessage(component);                    
                }

                if (error.pageErrors) {
                    error.pageErrors.forEach( function(pageError) {
                        component.set("v.message", pageError.message);
                        component.set("v.messageType", "error");
                        component.set("v.messageTitle", "Error");
                        this.showMessage(component);                   
                    });                 
                }

                if (error.fieldErrors) {
                    for (var fieldName in error.fieldErrors) {
                        error.fieldErrors[fieldName].forEach( function (errorList) { 
                            component.set("v.message", errorList.message + " Field Error on " + fieldName + " : ");
                            component.set("v.messageType", "error");
                            component.set("v.messageTitle", "Error");
                            this.showMessage(component);                         
                        });                                
                    };                   
                } 
            }); 
        }
    },
    updateReleaseAndStory : function(component,releaseId,storyId) {
        var action = component.get("c.updateReleaseAndStory");
        action.setParams({
            "releaseId":releaseId,
            "storyId":storyId,
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") { 
                console.log(state);
            }
            else if (state === "ERROR") {
                this.showErrorMessage(component,response);
            }
        });
        $A.enqueueAction(action);
    }
})