({
	    doInitHelper: function(component,helper) {
    },
    getOpportunityFields : function(component) {
        var action = component.get("c.getClosedOpportunity");
        var recordId = component.get("v.recordId");
        action.setParams({ 'recId' : recordId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") { 
            	var oppRec = response.getReturnValue();
                if (oppRec.StageName == 'Closed Won' || oppRec.StageName == 'Closed Lost') {
                	var toastEvent = $A.get("e.force:showToast");
                	toastEvent.setParams({
                   	 	"type": "error",
                    	"message": "You can't modify the Rate Card of a Closed Opportunity"
                	});
                	toastEvent.fire();
                	$A.get("e.force:closeQuickAction").fire();
                }
                else {
                    component.set("v.OppRec",response.getReturnValue());
                    component.set("v.priceBookSelectedId",oppRec.Selected_Price_Book__c);
                	this.getPriceBook(component);
                }
            }
        });
        $A.enqueueAction(action);
    },
    getPriceBook : function(component) {
    	var action = component.get("c.getPriceBook");
        var OpportunityRec = component.get("v.OppRec");
        action.setParams({'oppRec' : OpportunityRec});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                console.log('price book',response.getReturnValue()); 
            	var priceBookRecList = response.getReturnValue();
                var isClient = false;
                var isPartner = false;
                for(var key in priceBookRecList) {
                    if(priceBookRecList[key].Type__c == 'Client') {
                        isClient = true;
                    } else if(priceBookRecList[key].Type__c == 'Partner') {
                        isPartner = true;
                    }
                }
                component.set("v.priceBookList",priceBookRecList);
                component.set("v.isClient",isClient);
                component.set("v.isPartner",isPartner);
            }
        });
        $A.enqueueAction(action);
    },
    updateOppPriceField : function(component,event) {

		var priceBookId = event.getSource().get('v.value');
        var priceBookName = event.getSource().get('v.label');
		var action = component.get("c.updateOpportunity");
		var recordId = component.get("v.recordId");
        action.setParams({ 'recId' : recordId,'priceBookRecId' : priceBookId,'priceBookRecName' : priceBookName});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
				var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "message": "Rate Card has been successfully updated."
                });
                toastEvent.fire();

                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
    },

})