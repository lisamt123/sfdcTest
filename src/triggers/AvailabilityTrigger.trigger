trigger AvailabilityTrigger on Availability__c ( after update) {

	if (Trigger.isAfter) {
		if (Trigger.isUpdate ) {
			AvailabilityTriggerHandler.weekHourRollupUpdate(Trigger.new, Trigger.oldMap);
		}
	}
}