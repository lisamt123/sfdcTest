trigger CaseTrigger on Case (after insert, before insert) {

	CaseTriggerHandler handler = new CaseTriggerHandler();

	if(Trigger.isAfter && Trigger.isInsert) {
		
		handler.onAfterInsert(Trigger.new, Trigger.newMap);
	}
	
	if(Trigger.isBefore && Trigger.isInsert) {
		
		handler.onBeforeInsert(Trigger.new);
	}
}