public with sharing class TestDataFactory_AccountPlannings {
    
    public static List<Account_Plan__c> generateAccountPlannings(String name, Id accountId, String year, Integer numOfRecords) {
		return generateAccountPlanningsInternal(name, accountId, year, numOfRecords);
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<Account_Plan__c> generateAccountPlanningsInternal(String name, Id accountId, String year, Integer numOfRecords) {
    	List<Account_Plan__c> accountPlanningsList = new List<Account_Plan__c>();
        
        for(Integer i = 0; i < numOfRecords; i++) {
			Account_Plan__c accountPlanning = new Account_Plan__c();
			accountPlanning.Name = name;
			accountPlanning.Account__c = accountId;
			accountPlanning.Year__c = year;
            accountPlanningsList.add(accountPlanning);
        }
        
        return accountPlanningsList;
    }
}