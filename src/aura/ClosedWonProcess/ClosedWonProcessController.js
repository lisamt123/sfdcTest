({
	doInit : function(component, event, helper) {
        helper.doInitHelper(component,helper);
        helper.getOpportunityFields(component);
    },
    cancelClick : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    HandleNextClick : function(component,event,helper) {
        helper.checkSection(component,event,helper);
    },

    toggel : function(component,event,helper) {
        var buttonClass = event.target.getAttribute("class");
        var buttonId    = event.target.getAttribute("id");
        var img         = event.target.getAttribute("src"); 
        if (img.includes("expand")) {
            document.getElementById(buttonId).src  = img.replace('expand','collapse');
            helper.retriveProject(component,event,helper,buttonId,buttonClass);
        }
         else {
           document.getElementById(buttonId).src  = img.replace('collapse','expand');
           var rowList = document.getElementsByClassName(buttonId);
           for(var i = 0;i < rowList.length ;i++) { 
                rowList[i].remove(); 
                i = -1;
            }
        }
    },
    
    onSelectChange : function(component,event,helper) {
        var selectCmp = component.find("agreementList");
        var selectCmpList = selectCmp.get("v.value").split(";");
        component.set("v.agreementId",selectCmpList);
        if(selectCmpList.length > 0){
            for(var i=0;i<selectCmpList.length;i++){
                if(selectCmpList[i] == 'None') {
                    component.find("noneOption").set("v.value",false);
                } 
            } 
        }

        
        if(selectCmp.get("v.value") == 'None') {
            component.set("v.nextButton",false);
        }
        else{

            component.set("v.nextButton",true);
        }
    },
    
    Change : function (component, event, helper) {
        var getID = component.get("v.agreementRecList");
        var checkvalue=component.find("check").get("v.value");        
        var chk = component.find("chx"); 
        if(checkvalue==true){
            for(var i=0;i<chk.length;i++){
                chk[i].set("v.value",true);
            }
        }
        else{ 
            for(var i=0;i<chk.length;i++){
                chk[i].set("v.value",false);
            }
        }
    },
    
    noneSelect : function (component, event, helper) {
        var agreementIdSet  = component.get("v.AgreementIdSet");
        var isNone          = component.get("v.isNone");
        var checkList       = component.find("chx");
        agreementIdSet      = [];
        component.set("v.AgreementIdSet", agreementIdSet);
        component.set("v.isNone", event.getSource().get('v.value'));
        if(typeof (checkList.length) == "undefined") {
            checkList.set("v.value", false);
        } else {
            for(var chk in checkList) {
                checkList[chk].set("v.value", false);
            }
        }
        component.set("v.nextButton",false);
    },

    oneSelect : function (component, event, helper) {
        var agreementIdSet  = component.get("v.AgreementIdSet");
        var isNone          = component.get("v.isNone");
        var allUnChecked    = true;
        var currentAgId     = event.getSource().get('v.text');
        var checkList       = component.find("chx");
        component.set("v.isNone", false);
        if(event.getSource().get('v.value')) {
            agreementIdSet.push(currentAgId);
        } else {
            var index = agreementIdSet.indexOf(currentAgId);
            if (index !== -1) {
                agreementIdSet.splice(index, 1);
            }
        }
        if(typeof (checkList.length) == "undefined") {
            if(checkList.get("v.value")) {
                allUnChecked = false;
            }
        } else {
            for(var chk in checkList) {
                if(checkList[chk].get("v.value")) {
                    allUnChecked = false;
                }
            }
        }
        if(allUnChecked) {
            component.set("v.isNone", true);
            component.set("v.nextButton",false);
        } else {
            component.set("v.nextButton",true);
        }
        component.set("v.AgreementIdSet", agreementIdSet);
    },

    saveWithoutReplacement : function (component, event, helper) {
        helper.convertOpportunityProducts(component, event, helper);
    },

    saveWithReplacement : function (component, event, helper) {
        var assignmentList = component.get("v.agreementAssignment");
        var isValid = true;
        for(var key in assignmentList) {
            if($A.util.isEmpty(assignmentList[key].selectedRole)) {
                isValid = false;
                break;
            }
        }
        if(isValid) {
            helper.saveWithReplacementHelper(component, event, helper);
        } else {
            component.set("v.message", "Role is required and can\'t be left blank.");
            component.set("v.messageType", "error");
            component.set("v.messageTitle", "Error");
            helper.showMessage(component);
        }
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
    }
})