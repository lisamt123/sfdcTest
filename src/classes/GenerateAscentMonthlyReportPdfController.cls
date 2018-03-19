public class GenerateAscentMonthlyReportPdfController{
	public Ascent_Metrics__c ascendMetricRec {get;Set;}
	public Map<Id,List<String>> accIdWithSetContactMap {get;set;}
	public String allContactName {get;set;}
	public GenerateAscentMonthlyReportPdfController(){
		Id ascendMetricId = apexpages.currentpage().getparameters().get('id');
		Set<Id> oppMSAIds   = new Set<Id>();
		ascendMetricRec = [SELECT Id, Account__c, Account__r.Current_Tier__c, Account__r.Owner.Name, Account__r.RecordTypeId, Account__r.Name, 
                                                    Account__r.Total_Outstanding_Invoices__c, Account__r.Total_Outstanding_Overdue_Invoices__c, 
                                                    IsDeleted, Name, Amount_Invoiced_YTD__c, Current_Tier__c, Hours_Invoiced_YTD__c, Month_End_Date__c, 
                                                    Month_Start_Date__c, Next_Tier__c 
                                                FROM Ascent_Metrics__c WHERE Id = :ascendMetricId];
		for(Opportunity oppMSAtype : [SELECT Id, Name, AccountId 
                                        FROM Opportunity 
                                        WHERE RecordTypeId =: Constants.RECORDTYPEID_OPPORTUNITY_MSA 
                                        AND AccountId =: ascendMetricRec.Account__c 
                                        AND Start_Date__c <=: ascendMetricRec.Month_Start_Date__c AND End_Date__c >=: ascendMetricRec.Month_End_Date__c]) {
            oppMSAIds.add(oppMSAtype.Id);
        }
        // Processing metric List to create wrapper in every contains key condition with contact roles
        accIdWithSetContactMap = new Map<Id,List<String>>();
        
        Set<String> contactIDSet = new Set<String>();
        for(OpportunityContactRole oppConRole : [SELECT Id, OpportunityId, Opportunity.AccountId, ContactId, Contact.FirstName, Role 
                                                    FROM OpportunityContactRole WHERE OpportunityId =: oppMSAIds]) {
            if(!contactIDSet.contains(oppConRole.Opportunity.AccountId+'#'+oppConRole.ContactId)) {
                if(accIdWithSetContactMap.containsKey(oppConRole.Opportunity.AccountId)) {
                    accIdWithSetContactMap.get(oppConRole.Opportunity.AccountId).add(oppConRole.Contact.FirstName);
                } else {
                    accIdWithSetContactMap.put(oppConRole.Opportunity.AccountId, new List<String>{(oppConRole.Contact.FirstName)});
                }
                contactIDSet.add(oppConRole.Opportunity.AccountId+'#'+oppConRole.ContactId);
            }
        }

        allContactName = '';
        if(accIdWithSetContactMap.containsKey(ascendMetricRec.Account__c) && accIdWithSetContactMap.get(ascendMetricRec.Account__c).size() > 0){
        	if(accIdWithSetContactMap.get(ascendMetricRec.Account__c).size() > 1){
        		for(String contactName : accIdWithSetContactMap.get(ascendMetricRec.Account__c)){
        			allContactName += contactName+',';
        		}	
        	}
        	else{
        		allContactName = accIdWithSetContactMap.get(ascendMetricRec.Account__c)[0] + ',';
        	}
        }
        
	}



}