({
	doInit : function(component, event, helper) {
		
		var caseIdVal = window.location.pathname.split('/case/')[1];
		caseIdVal = caseIdVal.split('/')[0];
		var action = component.get("c.retriveCase");
		action.setParams({"caseIdValue" : caseIdVal});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS")
            {
            	component.set("v.caseRec", response.getReturnValue());
            	console.log(response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},
	updateAdditionalContacts : function(component, event, helper)
	{
		var caseRec = component.get("v.caseRec");
        var caseRec1 = {};
		for(var key in caseRec){
			console.log(key);
			if(key != 'Additional_Case_Contact_1__r' && key != 'Additional_Case_Contact_2__r' && key != 'Additional_Case_Contact_3__r' && key != 'Additional_Case_Contact_4__r' && key != 'Additional_Case_Contact_5__r')
            {
                caseRec1[key] = caseRec[key];
            }
        }
		caseRec1.sobjectType = "Case";
		console.log(caseRec1);
		var action = component.get("c.updateAdditionalCaseContacts");
            action.setParams({ 'caseRec' : caseRec1 });
            action.setCallback(this, function(response) 
            {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") 
                {
                	component.set("v.caseRec", response.getReturnValue());
                	helper.showToast(component, event, 'Success', 'Your changes have been saved successfully.', 'success');
                }
            });
            $A.enqueueAction(action);
	},
	handleContactIdUpdate : function(component, event, helper) 
	{       
        var valueId = event.getParam("sObjectId");
        var fieldAPIName = event.getParam("fieldAPIName");
        
        if(valueId != '' && valueId != undefined)
        {
            var caseRec = component.get("v.caseRec");
            if(fieldAPIName == 'Contact__1'){
                caseRec.Additional_Case_Contact_1__c = valueId;
                console.log("Value Set"+caseRec.Additional_Case_Contact_1__c);
            }
            if(fieldAPIName == 'Contact__2'){
                caseRec.Additional_Case_Contact_2__c = valueId;
            }
            if(fieldAPIName == 'Contact__3'){
                caseRec.Additional_Case_Contact_3__c = valueId;	
            }
            if(fieldAPIName == 'Contact__4'){
                caseRec.Additional_Case_Contact_4__c = valueId;
            }
            if(fieldAPIName == 'Contact__5'){
                caseRec.Additional_Case_Contact_5__c = valueId;
            }
            component.set("v.caseRec", caseRec);
        } 
    }, 
    handleContactIdClear : function(component, event, helper) 
    {
        var valueId = null ;
        var fieldAPIName = event.getParam("fieldAPIName");
         
            var caseRec = component.get("v.caseRec");
            if(fieldAPIName == 'Contact__1'){
                caseRec.Additional_Case_Contact_1__c = valueId;
            }
            if(fieldAPIName == 'Contact__2'){
                caseRec.Additional_Case_Contact_2__c = valueId;
            }
            if(fieldAPIName == 'Contact__3'){
                caseRec.Additional_Case_Contact_3__c = valueId;	
            }
            if(fieldAPIName == 'Contact__4'){
                caseRec.Additional_Case_Contact_4__c = valueId;
            }
            if(fieldAPIName == 'Contact__5'){
                caseRec.Additional_Case_Contact_5__c = valueId;
            }
            component.set("v.caseRec", caseRec);
    }, 
})