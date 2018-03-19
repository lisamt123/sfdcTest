({
	doInit : function(component, event, helper) {
        helper.doPicklistValue(component,helper);
        helper.doInitHelper(component,helper,'');
        document.title = "Ascent Monthly Reports | Salesforce";
    },
    
	onMonthChange : function(component, event, helper) {
        var selected = component.find("MonthSelectId").get("v.value");
        helper.doInitHelper(component,helper,selected);
    },
    
    noneSelect : function (component, event, helper) {
        var isNone          = component.get("v.mainCheckbx");
        var tempAttr        = component.get("v.ascendMetricList");
        
        for(var key in tempAttr) {
            tempAttr[key].isSelected = isNone;
        }
        component.set("v.ascendMetricList", tempAttr);
	},

    oneSelect : function (component, event, helper) {
        var accentMatricList = component.get("v.ascendMetricList");
        var countChecker    = 0;
        for(var chk in accentMatricList) {
            if(accentMatricList[chk].isSelected == true) {
                countChecker++;
            }
        }
        if(accentMatricList.length == countChecker){
        	component.set("v.mainCheckbx", true);    
        }
        else{
            component.set("v.mainCheckbx", false);
        }
    },

    sendAscentReport : function(component,event,helper) {
        helper.sendAscentReport(component,event,helper);
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
    gotoURL : function (component, event, helper) {
       var whichOne = event.getSource().get("v.value");
       console.log(whichOne);
         var action = component.get("c.viewPdf");
          action.setParams({ 'Id' : whichOne});
            action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                window.open(response.getReturnValue(), '_blank'); 
                //component.set("v.monthList",response.getReturnValue().monthList);
                //component.set("v.MonthSelectAttr",response.getReturnValue().currentMonthName);
            }
        });
        $A.enqueueAction(action);

        

        /*var urlEvent = $A.get("e.force:navigateToURL");
        console.log(urlEvent);
        urlEvent.setParams({
            "url": "/apex/pdfPage",
            "target": "_blank"

        });
        urlEvent.fire();*/
    },
})