trigger AttachmentToFileTrigger on Attachment (after insert,before delete) {
	if(Trigger.isAfter) {
        if(Trigger.isInsert) {
           AttachmentToFileTriggerHandler.deleteAttachment();
        }
    }
    if(Trigger.isBefore) {
        if(Trigger.isDelete) {
           AttachmentToFileTriggerHandler.convertIntoFile(Trigger.old);
        }
    }
}