({
	fetchRequestedExperts: function(component) {
        var action = component.get("c.getRequestedExperts");
        var recordId = component.get("v.recordId");
        action.setParams({ 'recId' : recordId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.rolePickValues", response.getReturnValue().role);
                component.set("v.regionPickValues", response.getReturnValue().region);
                component.set("v.statusPickValues", response.getReturnValue().status);
                component.set("v.ratePickValues", response.getReturnValue().rate);
                component.set("v.requestedExpertList", response.getReturnValue().requestedExpertList);
                component.set("v.workRequest", response.getReturnValue().workRequest);
                var requestedExpert = component.get("v.requestedExpert");
                requestedExpert.Requested_Start_Date__c   = response.getReturnValue().workRequest.Start_Date__c;
                requestedExpert.Requested_End_Date__c     = response.getReturnValue().workRequest.End_Date__c;
                requestedExpert.Status__c                 = 'New';
                component.set("v.requestedExpert", requestedExpert);
            }
        });
        $A.enqueueAction(action);
    },

    saveRequestedExpert: function(component) {
        var action = component.get("c.approveRequestedExperts");
        var requestedExpert = component.get("v.requestedExpert");
        var recordId = component.get("v.recordId");
        action.setParams({ 
            'recId' : recordId,
            'workRequest' : component.get("v.workRequest"),
            'requestedExpert' : JSON.stringify(requestedExpert)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.requestedExpertList", response.getReturnValue());
                var requestedExpert = component.get("v.requestedExpert");
                var ratePickValues  = component.get("v.ratePickValues");
                var ratePickVal = [];
                ratePickVal.push(ratePickValues[0]);
                requestedExpert.Requested_Start_Date__c   = component.get("v.workRequest").Start_Date__c;
                requestedExpert.Requested_End_Date__c     = component.get("v.workRequest").End_Date__c;
                requestedExpert.Status__c                 = 'New';
                requestedExpert.Role__c                   = '';
                requestedExpert.Region__c                 = '';
                requestedExpert.Requested_Rate__c         = '';
                requestedExpert.Requested_Allocation__c   = 0;
                requestedExpert.Requested_Hours__c        = 0;
                component.set("v.requestedExpert", requestedExpert);
                component.set("v.ratePickValues", ratePickVal);
            }
        });
        $A.enqueueAction(action);
    },

    removeRequestedExpert: function(component, event, helper) {
        var requestedExpertId = component.get("v.deleteRecId");
        var action = component.get("c.delRequestedExpert");
        var recordId = component.get("v.recordId");
        action.setParams({ 
            'delRecId' : requestedExpertId,
            'recId' : recordId,
            'workRequest' : component.get("v.workRequest")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.requestedExpertList", response.getReturnValue());
                var modalDiv = component.find("delModal");
                var backdropDiv = component.find("delBackdrop");
                $A.util.toggleClass(modalDiv, "slds-fade-in-open");
                $A.util.toggleClass(backdropDiv, "slds-backdrop_open");
            }
        });
        $A.enqueueAction(action);
    },

    retriveRatePickVals: function(component) {
        var action = component.get("c.getRatePickVals");
        action.setParams({ 
            'role' : component.get("v.requestedExpert").Role__c,
            'region' : component.get("v.requestedExpert").Region__c,
            'workRequest' : component.get("v.workRequest")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                console.log('Rates : ', response.getReturnValue());
                component.set("v.ratePickValues", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },

    saveChangesHelper: function(component) {
        var editedRecord = component.get("v.editComponent").get("v.requestedExpert");
        console.log(editedRecord);
    },
    /*getOpportunityFields : function(component) {
        var action = component.get("c.getOpenOpportunity");
        var recordId = component.get("v.recordId");
        action.setParams({ 'recId' : recordId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            var oppRec = response.getReturnValue();
            if (component.isValid() && state === "SUCCESS") {
                if (oppRec.Pricebook2Id == "" || oppRec.Pricebook2Id == null) {
                	var toastEvent = $A.get("e.force:showToast");
                	toastEvent.setParams({
                   	 	"type": "error",
                    	"message": "MSA Opportunity and MSA Agreement must be selected before managing Products."
                	});
                	toastEvent.fire();
                	$A.get("e.force:closeQuickAction").fire();
                }
                else{
                    component.set("v.priceBookId",oppRec.Pricebook2Id);
                    component.set("v.MsarecordId",oppRec.MSA_Opportunity__c);
                	this.getProductRateCardOpportunity(component);
            	}
            }
        });
        $A.enqueueAction(action);
    },
    getProductRateCardOpportunity : function(component) {
        var recordId    = component.get("v.recordId");
        var msaOppRecId = component.get("v.MsarecordId");
        var action = component.get("c.getProductRateCardOpportunity");
        action.setParams({ 'recId' : recordId,'msaOppRecId' : msaOppRecId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
            	var oppRec = response.getReturnValue();
                component.set("v.OpportunityProduct",oppRec.oppProductList);
                component.set("v.OpportunityRateCard",oppRec.oppRateCardList);
            }
        });
        $A.enqueueAction(action);
    },
    
    saveOppProduct: function(component) {
        var priceBookId = component.get("v.priceBookId");
        var recordId = component.get("v.recordId");
    	var action = component.get("c.createOppProduct");
    	action.setParams({	"opportunityProduct" : JSON.stringify(component.get("v.OpportunityProduct")),
    						"opportunityRateCard": JSON.stringify(component.get("v.OpportunityRateCard")),
                            "priceBookId"        : priceBookId,
                            "recordId"           : recordId
						});
        
		action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
            	var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "success",
                        "message": "Successfully Updated Products."
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();
            }
        });
 		$A.enqueueAction(action);
	}*/
    
})