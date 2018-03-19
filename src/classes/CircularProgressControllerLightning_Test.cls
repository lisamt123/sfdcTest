@isTest
private class CircularProgressControllerLightning_Test {
	
	@testSetup static void methodName() {
        
        List<Opportunity> oppList = TestDataFactory_Opportunity.generateOpportunities(null,Constants.RECORDTYPEID_OPPORTUNITY_PRODUCT, 'In Progress', Date.today().addMonths(2),system.today().addDays(-30),system.today().addDays(-2), 1);
        oppList[0].Amount = 80;
        oppList[0].Probability=60;
        insert oppList;
	}
 
    @isTest
    static void testUsingFields(){
        Opportunity opp = [SELECT Id, Amount, ExpectedRevenue FROM Opportunity];
        String retVal = CircularProgressControllerLightning.computePercentage('Opportunity',Opp.id,'Amount','ExpectedRevenue');
        
        CircularProgressControllerLightning.WrapperJSON retPOJO = (CircularProgressControllerLightning.WrapperJSON)JSON.deserialize(retVal, CircularProgressControllerLightning.WrapperJSON.class);
        System.assertEquals(retPOJO.actual, 48) ;
        System.assertEquals(retPOJO.total, 80) ;
        System.assertEquals(retPOJO.val, 60) ;
    }
    
    @isTest
    static void testUsingSingleField(){
        Opportunity opp = [SELECT Id, Amount, ExpectedRevenue FROM Opportunity];
        String retVal = CircularProgressControllerLightning.computePercentage('Opportunity',Opp.id,'','Amount');
        
        CircularProgressControllerLightning.WrapperJSON retPOJO = (CircularProgressControllerLightning.WrapperJSON)JSON.deserialize(retVal, CircularProgressControllerLightning.WrapperJSON.class);
        System.assertEquals(retPOJO.actual, 80) ;
        System.assertEquals(retPOJO.total, null) ;
        System.assertEquals(retPOJO.val, 80) ;
    }
}