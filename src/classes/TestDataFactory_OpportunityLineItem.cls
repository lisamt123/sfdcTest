public with sharing class TestDataFactory_OpportunityLineItem {
	public static List<OpportunityLineItem> generateOpportunityLineItem(Id opportunityId, Integer Quantity, Id PricebookEntryId, Decimal PriceBookEntryUnitPrice, Integer numberOfRows) {
		return generateOpportunityLineItemInternal(opportunityId, Quantity, PricebookEntryId, PriceBookEntryUnitPrice, numberOfRows);
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<OpportunityLineItem> generateOpportunityLineItemInternal(Id opportunityId, Integer Quantity, Id PricebookEntryId, Decimal PriceBookEntryUnitPrice, Integer numberOfRows) {
    	List<OpportunityLineItem> oppList = new  List<OpportunityLineItem>();
        for(integer i=0; i < numberOfRows ; i++){
            OpportunityLineItem opp = new OpportunityLineItem();
            opp.OpportunityId = opportunityId;
            opp.PricebookEntryId = PricebookEntryId;
            opp.Quantity = Quantity;
            opp.TotalPrice = Quantity * PriceBookEntryUnitPrice ;
            oppList.add(opp);
        }
        return oppList;
    }
}