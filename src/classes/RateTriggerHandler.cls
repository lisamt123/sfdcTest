public with sharing class RateTriggerHandler {
    
    private static final String RATE_CHANGE_NOT_ALLOWED = 'You cannot modify the financial details of a Rate once it is associatd to an Invoice Line Item.';

    public void onBeforeInsert(List<Rate__c> newRateList) {
        setRetainerSequenceNumber(newRateList, null);
    }

    public void onBeforeUpdate(List<Rate__c> newRateList, Map<Id, Rate__c> newRateMap, 
                               List<Rate__c> oldRateList, Map<Id, Rate__c> oldRateMap) {
        preventRateChangesIfInvoiced(newRateMap, oldRateMap);
    }

    private void setRetainerSequenceNumber(List<Rate__c> newRateList, Map<Id, Rate__c> oldRateMap) {

        //Isolate a unique set of the Agreements that we're inserting new Rates for
        Set<Id> agreementIdSet = new Set<Id>();
        for(Rate__c rate : newRateList) {
            agreementIdSet.add(rate.Agreement__c);
        }

        //Build a Map of the largest current sequence number for each Agreement + Role combination
        Map<String, Integer> agreementRoleToSequenceMap = new Map<String, Integer>();
        String mapKey = '';
        for(Agreement__c agreement : [SELECT Id,
                                             (SELECT Id, Retainer_Sequence_Number__c, Role__c, Agreement__c, Assignment_Type__c
                                              FROM Rates__r)
                                      FROM Agreement__c
                                      WHERE Id IN: agreementIdSet]) {
            
            for(Rate__c rate : agreement.Rates__r) {
                mapKey = rate.Agreement__c + rate.Assignment_Type__c + rate.Role__c;
                if(!agreementRoleToSequenceMap.containsKey(mapKey) || rate.Retainer_Sequence_Number__c > agreementRoleToSequenceMap.get(mapKey)) {
                    agreementRoleToSequenceMap.put(mapKey, Integer.valueOf(rate.Retainer_Sequence_Number__c));
                }
            }
        }

        //For the newly created Rates, either set the sequence number to 1 if there are no other Rates for that Role, or
        //set it to one more than the largest value available in the map for that Agreement + Role combination
        for(Rate__c rate : newRateList) {
            mapKey = rate.Agreement__c + rate.Assignment_Type__c + rate.Role__c;
            if(rate.Assignment_Type__c == Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS || rate.Assignment_Type__c == Constants.ASSIGNMENTTYPE_RETAINEDCAPACITY) {
                rate.Retainer_Sequence_Number__c = null;
            }
            else if(rate.Assignment_Type__c == Constants.ASSIGNMENTTYPE_NAMEDRESOURCE) {
                mapKey = rate.Agreement__c + rate.Assignment_Type__c + rate.Role__c;
                if(!agreementRoleToSequenceMap.containsKey(mapKey)) {
                    rate.Retainer_Sequence_Number__c = 1;
                }
                else {
                    rate.Retainer_Sequence_Number__c = agreementRoleToSequenceMap.get(mapKey) + 1;
                }

                //Keep the map updated with the new largest sequence number to deal with multiple Rates for the same
                //Agreement + Role combination in the same trigger
                agreementRoleToSequenceMap.put(mapKey, Integer.valueOf(rate.Retainer_Sequence_Number__c));
            }
        }
    }
    
    // This method prevents changes in rete object if any invoice line item exists for that record.
    private static void preventRateChangesIfInvoiced(Map<Id, Rate__c> newRateMap, Map<Id, Rate__c> oldRateMap) {

        List<Rate__c> rateList = new  List<Rate__c>();
        List<RateFieldRestriction__c> restrictedFields = RateFieldRestriction__c.getAll().values();

        if(restrictedFields != null && restrictedFields.size() > 0){
            Set<String> allRateFields = new Set<String>();
            String field;

            allRateFields  = Utils.getFieldsForObject('Rate__c');
            
            for(Rate__c rate : newRateMap.values()) {
                for(RateFieldRestriction__c rec : restrictedFields) {
                    field = rec.RestrictedFieldApiName__c;
                    
                    if(!String.isBlank(field) && allRateFields!=null && allRateFields.contains(field.toLowerCase().trim())) {
                        if(rate.get(field.trim()) != null && rate.get(field.trim()) != oldRateMap.get(rate.Id).get(field.trim())) {
                            rateList.add(rate);
                            break;  
                        }
                    }
                }
            }
        }

        //If we found Rates that had values in restricted fields changed, determine if any of those have Invoice Line Items tied to them
        if(rateList !=null && rateList.size()>0) {
            Map<Id, Integer> rateIdToInvoiceLineItemCountMap = new Map<Id, Integer>();
        
            //Build a map to indiciate how many Invoice Line Items are tied to each Rate
            for(Rate__c rate : [SELECT Id,
                                       (SELECT Id FROM Invoice_Line_Items__r)
                                FROM Rate__c 
                                WHERE Id IN: rateList]) {
                
                rateIdToInvoiceLineItemCountMap.put(rate.Id, rate.Invoice_Line_Items__r != null ? rate.Invoice_Line_Items__r.size() : 0);
            }
            
            // checking if any Invoice line item exists or not
            if(rateIdToInvoiceLineItemCountMap != null && rateIdToInvoiceLineItemCountMap.size() > 0) {
                for(Rate__c rate : rateList) {
                    if(rateIdToInvoiceLineItemCountMap.containskey(rate.Id) && rateIdToInvoiceLineItemCountMap.get(rate.Id) > 0) {
                        newRateMap.get(rate.Id).addError(RATE_CHANGE_NOT_ALLOWED, false);
                    }
                }     
            }
        }
    }
}