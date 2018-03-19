public with sharing class TestDataFactory_Opportunity {
    
    public static List<Opportunity> generateOpportunities(Id accountId, Id recordTypeId, String stageName, Date closeDate, Date subscriptionStartDate, Date subscriptionEndDate, Integer numberOfOpportunities) {
		return generateOpportunitiesInternal(accountId, recordTypeId, stageName, closeDate, subscriptionStartDate, subscriptionEndDate, numberOfOpportunities);
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<Opportunity> generateOpportunitiesInternal(Id accountId, Id recordTypeId, String stageName, Date closeDate, Date subscriptionStartDate, Date subscriptionEndDate, Integer numberOfOpportunities) {
    	List<Opportunity> oppList = new  List<Opportunity>();
        for(integer i=0; i < numberOfOpportunities ; i++){
            Opportunity opp = new Opportunity();
            opp.RecordTypeId = recordTypeId;
            opp.AccountId = accountId;
            opp.StageName = stageName;
            opp.CloseDate =  closeDate;
            opp.Is_Closed_Through_Process__c = true;
            opp.Amount = 10;
            opp.Name = 'Test Opportunity' + i;
            opp.Subscription_Start_Date__c = subscriptionStartDate; 
			opp.Subscription_End_Date__c = subscriptionEndDate;
            oppList.add(opp);
        }
        return oppList;
    }
}