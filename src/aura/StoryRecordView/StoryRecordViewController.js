({
	doInit : function(component, event, helper) {
		console.log(component.get("v.recID"));
		console.log('View Modal');

	},
	showstoryRecordEdit : function(component, event, helper)
    {
    	console.log(component.get("v.recID"));
    	var recID = component.get("v.recID");
    	$('#notify2').hide();   
        $('#notify3').hide();
    	var action = component.get("c.getcurrentStory");
            action.setParams({ 'recordID' : recID });
            action.setCallback(this, function(response) 
            {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") 
                {   
                	component.set("v.storyRec", response.getReturnValue());
                	component.set("v.priority",response.getReturnValue()['Priority__c']);
                }
            });
    	$A.enqueueAction(action);

        var recView = component.find("storyRecordEdit");
        $A.util.removeClass(recView, "slds-fade-in-close");
        $A.util.addClass(recView, "slds-fade-in-open");
        this.hidestoryRecordView(component);
    },
    hidestoryRecordEdit : function(component, event, helper)
    {
        var recView = component.find("storyRecordEdit");
        $A.util.removeClass(recView, "slds-fade-in-open");
        $A.util.addClass(recView, "slds-fade-in-close");
    },
    closeEditModal : function(component, event, helper)
    {
    	var notifyid = event.getParam("notifyid");
        var err = event.getParam("err");
        var isSetTime = event.getParam("isSetTime");
        var type = event.getParam("type");
        if(type == "success")
        {
        	console.log('Close Edit Modal');
	        var recView = component.find("storyRecordEdit");
	        $A.util.removeClass(recView, "slds-fade-in-open");
	        $A.util.addClass(recView, "slds-fade-in-close");
        }
    	if(type == "error")
    	{
    		helper.showTost(component,notifyid,err,isSetTime,type);
    	}
    },
    hideNotify : function (component, event, helper){
        $('#notify2').hide();   
        $('#notify3').hide(); 
    },
})