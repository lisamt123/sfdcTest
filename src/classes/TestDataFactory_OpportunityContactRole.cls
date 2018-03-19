public with sharing class TestDataFactory_OpportunityContactRole {
	public static List<OpportunityContactRole> generateOpportunityContactRole(Id opportunityId, Id contactId, String Role, Integer numberOfRows) {
		return generateOpportunityContactRoleInternal(opportunityId, contactId, Role, numberOfRows);
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<OpportunityContactRole> generateOpportunityContactRoleInternal(Id opportunityId, Id contactId, String Role, Integer numberOfRows) {
    	List<OpportunityContactRole> oppList = new  List<OpportunityContactRole>();
        for(integer i=0; i < numberOfRows ; i++){
            OpportunityContactRole opp = new OpportunityContactRole();
            opp.OpportunityId = opportunityId;
            opp.ContactId = contactId;
            opp.Role = Role;
            oppList.add(opp);
        }
        return oppList;
    }
}