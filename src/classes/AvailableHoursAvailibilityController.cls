public without sharing class AvailableHoursAvailibilityController {
	@AuraEnabled
	public static void retrieveAvailability(Availability__c availability) {
		update availability;
	}
	@AuraEnabled
	public static Boolean retrieveIsDisabled(Availability__c availability) {
		if(availability.Week__r.Week_Starts_On__c < Date.today())
			return true;
		else 
			return false;
	}
}