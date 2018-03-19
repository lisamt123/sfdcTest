public with sharing class TestDataFactory_RateCard {
	public static List<Rate_Card__c> generateRateCard(String rateCardName, Id opportunityId, String region, String role, Integer numberOfRateCard) {
		return generateRateCardInternal(rateCardName,opportunityId,region,role,numberOfRateCard);
	}

	private static List<Rate_Card__c> generateRateCardInternal(String rateCardName, Id opportunityId, String region, String role, Integer numberOfRateCard) {
		List<Rate_Card__c> rateCardList = new List<Rate_Card__c>();
        
        for(Integer i = 0; i < numberOfRateCard; i++) {
        	Rate_Card__c rateCard = new Rate_Card__c();
        	rateCard.Region__c = region ;
        	rateCard.Role__c = role ;
        	rateCard.Opportunity__c = opportunityId;
        	rateCard.Name = rateCardName ;
        	rateCardList.add(rateCard);
        }

        return rateCardList ;
	}
}