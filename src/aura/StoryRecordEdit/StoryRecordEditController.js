({
	doInit : function(component, event, helper) {
		console.log(component.get("v.recID"));
		console.log('Edit Modal');
	},
	hidestoryRecordEdit : function(component, event, helper)
    {
        var recView = component.find("storyRecordEdit");
        $A.util.removeClass(recView, "slds-fade-in-open");
        $A.util.addClass(recView, "slds-fade-in-close");
    },
    saveRec : function(component, event, helper)
    {
        var selectedbutton = event.currentTarget;
        var buttonId = selectedbutton.dataset.modalid;
        console.log(buttonId);
    	console.log('saving record');
    	var storyObj = component.get("v.storyRec");
    	var success = false;
    	var storyObj1 = {};
        for(var key in storyObj){
            /*if(!(key == 'Project__r' || key == 'Sprint__r' || key == 'Epic__r')){*/
                storyObj1[key] = storyObj[key];
            /*}*/           
        }
        storyObj1.sobjectType = 'Story__c';
        storyObj1.Priority__c = component.find('Priority__c').get("v.value");
        storyObj1.Description__c = component.find('Description__c').get("v.value");
        storyObj1.Test_Scenarios__c = component.find('Test_Scenarios__c').get("v.value");
        storyObj1.Level_of_Effort__c = component.find('Level_of_Effort__c').get("v.value");
        storyObj1.Technical_Design_Notes__c = component.find('Technical_Design_Notes__c').get("v.value");
        
        console.log(storyObj1.Description__c);
        console.log(storyObj1.Technical_Design_Notes__c);
        console.log(storyObj1.Test_Scenarios__c);
        
        /*storyObj1.Epic__c = storyObj['Epic__c'];
        storyObj1.Functional_Owner__c = storyObj['Functional_Owner__c'];
        storyObj1.Project__c = storyObj['Project__c'];
        storyObj1.Sprint__c = storyObj['Sprint__c'];*/

        console.log(storyObj);
        console.log(storyObj1);
    	var action = component.get("c.submitSave");
            action.setParams({ 'stryObj' : storyObj1 });
            action.setCallback(this, function(response) 
            {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") 
                {   
                    component.set("v.storyRec", response.getReturnValue());
                    var closeModalEvent = component.getEvent("closeEditModalEvent");
                    if(buttonId == "storyRecordSaveClose")
                    {
                        closeModalEvent.setParams({
                            "notifyid" : "notify2",
                            "err" : "Story Record Updated Successfully.",
                            "isSetTime" : true,
                            "type" : "success"
                        });
                    }
                    else
                    {
                        closeModalEvent.setParams({
                            "notifyid" : "notify3",
                            "err" : "Story Record Updated Successfully.",
                            "isSetTime" : true,
                            "type" : "success"
                        });
                    }
                    
                    closeModalEvent.fire();
                    //this.showTost(component,"notify","Story Record Updated SuccessFully.", true, "success");
                    console.log('current Story');
                    success = true;
                }
                else if (component.isValid() && state === "ERROR") 
                { 
	                var errors = response.getError();
	                console.log(JSON.stringify(errors));
	                var err = JSON.stringify(errors);
	                var ind = err.indexOf('message');
	                err = 'Story Record Updated Abort. ' + err.substring(err.indexOf('message')+10,err.indexOf("}",err.indexOf('message'))-1);
	                component.set("v.ErrorMessge", err); 
	                var closeModalEvent = component.getEvent("closeEditModalEvent");
                    closeModalEvent.setParams({
			            "notifyid" : "notify3",
			            "err" : err,
			            "isSetTime" : false,
			            "type" : "error"
			        });
                    closeModalEvent.fire();
	                //this.showTost(component,"notify",err, false, "error");
            	}
            });
        $A.enqueueAction(action);
        /*if(success == true)
        {
        	
        }*/
        
    },
    showTost : function(component, notifyid, err, isSetTime, type){
        component.set("v.ErrorMessge", err); 
        if(type == "success" ){
            if($('#'+notifyid).hasClass('slds-theme--error'))
                $('#'+notifyid).removeClass('slds-theme--error');
            $('#'+notifyid).addClass('slds-theme--success');
        }
        if(type == 'error'){
            if($('#'+notifyid).hasClass('slds-theme--success'))
                $('#'+notifyid).removeClass('slds-theme--success');
            $('#'+notifyid).addClass('slds-theme--error');
        }
        
        $('#'+notifyid).show();
        if(isSetTime)
        	setTimeout(function(){ $('#'+notifyid).hide(); }, 5000);//show for 5 sec
    },
    handleAccountIdUpdate : function(component, event, helper) {       
        // Get the param from the Event
        var valueId = event.getParam("sObjectId");
        var fieldAPIName = event.getParam("fieldAPIName");
        
        //get current index
        //var index = component.get("v.index");
        if(valueId != '' && valueId != undefined){
            var story = component.get("v.storyRec");
            if(fieldAPIName == 'Epic__c'){
                story.Epic__c = valueId;
            }
            if(fieldAPIName == 'Functional_Owner__c'){
                story.Functional_Owner__c = valueId;
            }
            if(fieldAPIName == 'Project__c'){
                story.Project__c = valueId;	
            }
            if(fieldAPIName == 'Sprint__c'){
                story.Sprint__c = valueId;
            }
            component.set("v.storyRec", story);
        } 
    }, 
    /*this is handler method used to clear lookup field value */
    handleAccountIdClear : function(component, event, helper) {
        
        // Get the param from the Event
        var valueId = null ;
        var fieldAPIName = event.getParam("fieldAPIName");
        
        //get current index
        //var index = component.get("v.index");
        
         
            var story = component.get("v.storyRec");
            if(fieldAPIName == 'Epic__c'){
                story.Epic__c = valueId;
            }
            if(fieldAPIName == 'Functional_Owner__c'){
                story.Functional_Owner__c = valueId;
            }
            if(fieldAPIName == 'Project__c'){
                story.Project__c = valueId;	
            }
            if(fieldAPIName == 'Sprint__c'){
                story.Sprint__c = valueId;
            }
            component.set("v.storyRec", story);
    },  
    closeModal : function(component, event, helper)
    {
        var closeModalEvent = component.getEvent("closeEditModalEvent");
        closeModalEvent.setParams({
            "notifyid" : "notifyNone",
            "err" : "Modal closed Successfully.",
            "isSetTime" : true,
            "type" : "success"
        });
        closeModalEvent.fire();
    }
})