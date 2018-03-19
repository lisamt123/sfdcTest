public with sharing class TestDataFactory_TimeEntries {
    
    public static List<Time_Entry__c> generateTimeEntries(Id assignmentId, String description, Date dateValue, Decimal hour, Integer numOfRecords) {
		return generateRateForTimeEntriesInternal(assignmentId, description, dateValue, hour, numOfRecords);
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<Time_Entry__c> generateRateForTimeEntriesInternal(Id assignmentId, String description, Date dateValue, Decimal hour, Integer numOfRecords) {
    	List<Time_Entry__c> timeEntriesList = new List<Time_Entry__c>();
        
        for(integer i = 0; i < numOfRecords ; i ++) {
            Time_Entry__c timeEntry = new Time_Entry__c();
            timeEntry.assignment__C = assignmentId;
            timeEntry.description__c = description;
            timeEntry.date__C = dateValue;
            timeEntry.Hours__c = hour;
            timeEntriesList.add(timeEntry);
        }
        
        return timeEntriesList ;
    }
}