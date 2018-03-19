public without sharing class AvailabilityTriggerHandler {

	public static void weekHourRollupUpdate(List<Availability__c> availabilityList,Map<Id,Availability__c> oldAvailabilityMap) {
		Set<Id> weekIds = new Set<Id>();
		List<Availability__c> availabilityListToUpdate = new List<Availability__c>();
    	for(Availability__c item : availabilityList){
    		if(item.Week__c != null && ((Availability__c)oldAvailabilityMap.get(item.Id)).Week__c != item.Week__c)
				weekIds.add(item.Week__c);				
			if(item.Week__c == null && item.Available_Hours__c != null ) {
				Availability__c availability 		= new Availability__c();
				availability.Id 					= item.Id;
				availability.Available_Hours__c 	= null;
				availabilityListToUpdate.add(availability);
			}
		}
		if (availabilityListToUpdate.size() > 0)
			update availabilityListToUpdate;
		//if (weekIds.size() > 0 )
			//BudgetTriggerHandler.updateAvailability(weekIds , Trigger.newMap.keySet());
    }   
}