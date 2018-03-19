({
    doInit : function(component, event, helper) {
        helper.fetchRequestedExperts(component);
    },

    cancelClick : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    handleRoleChange : function(component, event, helper) {
        console.log('role : ', component.get("v.requestedExpert").Role__c);
        console.log('requestedExpert : ', component.get("v.requestedExpert"));
        helper.retriveRatePickVals(component);
    },

    approveRequestedExpert : function(component, event, helper) {
        console.log('role : ', component.get("v.requestedExpert").Role__c);
        console.log('requestedExpert : ', component.get("v.requestedExpert"));
        helper.saveRequestedExpert(component);
    },

    deleteRequestedExpert : function(component, event, helper) {
        var requestedExpertId = event.getSource().get("v.name");
        component.set("v.deleteRecId", requestedExpertId);
        var modalDiv = component.find("delModal");
        var backdropDiv = component.find("delBackdrop");
        $A.util.toggleClass(modalDiv, "slds-fade-in-open");
        $A.util.toggleClass(backdropDiv, "slds-backdrop_open");
    },

    editRequestedExpert : function(component, event, helper) {
        if(component.get("v.editComponent") != null) {
            console.log(component.get("v.editComponent").get("v.requestedExpert"));
            console.log(component.get("v.lastEditedRec"));
            if(JSON.stringify(component.get("v.editComponent").get("v.requestedExpert")) === JSON.stringify(component.get("v.lastEditedRec"))) {
                console.log('not changed');
                component.get("v.editComponent").destroy();
            } else {
                console.log('changed');
                var modalDiv = component.find("recChangedModal");
                var backdropDiv = component.find("recChangedBackdrop");
                $A.util.toggleClass(modalDiv, "slds-fade-in-open");
                $A.util.toggleClass(backdropDiv, "slds-backdrop_open");
            }
            
        }
        console.log('requestedExpert : ', event.getSource().get("v.name"));
        var requestedExpertId = event.getSource().get("v.name");
        console.log('Id : ', requestedExpertId);
        var requestedExpertList = component.get("v.requestedExpertList");
        var requestedExpertRec;
        var requestedRate;
        for(var key in requestedExpertList) {
            if(requestedExpertList[key].requestedExpert.Id == requestedExpertId) {
                requestedExpertRec = requestedExpertList[key].requestedExpert;
                requestedRate = requestedExpertList[key].rate;
            }
        }
        component.set("v.lastEditedRec", requestedExpertRec);
        var trList = component.find("editMode");
        if(typeof (trList.length) == "undefined") {
            $A.createComponent(
                "c:ManageRequestedExpert",
                {
                    "requestedExpert": requestedExpertRec,
                    "rolePickValues": component.get("v.rolePickValues"),
                    "regionPickValues": component.get("v.regionPickValues"),
                    "statusPickValues": component.get("v.statusPickValues"),
                    "ratePickValues": requestedRate,
                    "workRequest": component.get("v.workRequest")
                },
                function(newItem, status, errorMessage){
                    if (status === "SUCCESS") {
                        var targetCmp = component.find("editMode");
                        var body = targetCmp.get("v.body");
                        component.set("v.editComponent",newItem);
                        body.push(newItem);
                        targetCmp.set("v.body", body);
                    }
                    else if (status === "INCOMPLETE") {
                        console.log("No response from server or client is offline.")
                    }
                    else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                    }
                }
            );
        } else {
            var index = event.getSource().get("v.accesskey");
            $A.createComponent(
                "c:ManageRequestedExpert",
                {
                    "requestedExpert": requestedExpertRec,
                    "rolePickValues": component.get("v.rolePickValues"),
                    "regionPickValues": component.get("v.regionPickValues"),
                    "statusPickValues": component.get("v.statusPickValues"),
                    "ratePickValues": requestedRate,
                    "workRequest": component.get("v.workRequest")
                },
                function(newItem, status, errorMessage){
                    if (status === "SUCCESS") {
                        var targetCmp = component.find("editMode");
                        var body = targetCmp[index].get("v.body");
                        component.set("v.editComponent",newItem);
                        body.push(newItem);
                        targetCmp[index].set("v.body", body);
                    }
                    else if (status === "INCOMPLETE") {
                        console.log("No response from server or client is offline.")
                    }
                    else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                    }
                }
            );
        }
    },

    cancelDelete : function(component, event, helper) {
        var modalDiv = component.find("delModal");
        var backdropDiv = component.find("delBackdrop");
        $A.util.toggleClass(modalDiv, "slds-fade-in-open");
        $A.util.toggleClass(backdropDiv, "slds-backdrop_open");
    },

    abandonChanges : function(component, event, helper) {
        var modalDiv = component.find("recChangedModal");
        var backdropDiv = component.find("recChangedBackdrop");
        $A.util.toggleClass(modalDiv, "slds-fade-in-open");
        $A.util.toggleClass(backdropDiv, "slds-backdrop_open");
    },

    saveChanges : function(component, event, helper) {
        helper.saveChangesHelper(component);
    },

    removeExpert : function(component, event, helper) {
        helper.removeRequestedExpert(component, event, helper);
    },
    /*doInit : function(component, event, helper) {
        
        helper.doInitHelper(component,helper);
        helper.getOpportunityFields(component);
    },
    HandleNextClick : function(component,event,helper) {
        
    },
    
    showLoading: function (cmp, event) {
        var spinner = cmp.find("Spinner");
        $A.util.removeClass(spinner, "slds-hide");
        $A.util.addClass(spinner, "slds-show");
    },
    hideLoading: function (cmp, event) {
        var spinner = cmp.find("Spinner");
        $A.util.addClass(spinner, "slds-hide");
        $A.util.removeClass(spinner, "slds-show");
    },
    saveOppProduct: function (component,event,helper) {
        helper.saveOppProduct(component);
    }*/
})