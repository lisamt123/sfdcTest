public with sharing class EventAndTaskTriggerHandler {
	public static void deleteRelatedAttachments() {
		delete [SELECT Id FROM Attachment WHERE ParentId IN : trigger.new];
	}
}