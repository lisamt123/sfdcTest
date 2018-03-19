public with sharing class AttachmentToFileTriggerHandler {

    public static void deleteAttachment() {
        System.debug('System Entry.......................one');
        List<Attachment> attList = new List<Attachment>();
        
        for(Attachment att : [SELECT Id,ParentId FROM Attachment WHERE Id IN : Trigger.newMap.keySet()])
            if(String.valueof(att.parentId).substring(0,3) != '00X')
                attList.add(att);
        
        delete attList;
        System.debug('System Entry.......................two');
    }
    
    public static void convertIntoFile(List<Attachment> attachmentList) {
        System.debug('System Entry.......................three');
        attachmentList = [SELECT Id, Name, Body, OwnerId, ParentId FROM Attachment WHERE Id IN : attachmentList];
        
        Set<Id> taskIdSet = new Set<Id>();
        Map<Id, Task> taskIdMap = new Map<Id, Task>();
        
        Set<Id> eventIdSet = new Set<Id>();
        Map<Id, Event> eventIdMap = new Map<Id, Event>();

        Set<Id> inboundEmailIdSet = new Set<Id>();
        Map<Id, EmailMessage> inboundEmailIdMap = new Map<Id, EmailMessage>();
        
        for(Attachment att : attachmentList){
            if(String.valueof(att.parentId).substring(0,3) == '00T'){
                taskIdSet.add(att.parentId);
            }
            if(String.valueof(att.parentId).substring(0,3) == '00U'){
                eventIdSet.add(att.parentId);
            }
            if(String.valueof(att.parentId).substring(0,3) == '02s'){
                inboundEmailIdSet.add(att.parentId);
            }
        }
        
        if(taskIdSet.size() > 0){
            List<Task> taskList = [SELECT Id, whoId, WhatId FROM Task WHERE Id IN : taskIdSet];
            for(Task t : taskList){
                taskIdMap.put(t.Id, t);
            }
        }
        
        if(eventIdSet.size() > 0){
            List<Event> eventList = [SELECT Id, whoId, WhatId FROM Event WHERE Id IN : eventIdSet];
            for(Event e : eventList){
                eventIdMap.put(e.Id, e);
            }
        }

        if(inboundEmailIdSet.size() > 0){
            List<EmailMessage> emailMessageList = [SELECT Id,RelatedToId FROM EmailMessage WHERE Id IN : inboundEmailIdSet];
            for(EmailMessage emailMessage : emailMessageList){
                inboundEmailIdMap.put(emailMessage.Id, emailMessage);
            }
        }
        
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        List<ContentDocumentLink> contentDocsLinkList = new List<ContentDocumentLink>();
        
        Map<String,ID> versionToParentMap = new Map<String,ID>(); 
        
        Map<ContentVersion,ID> versionToParentMap2 = new Map<ContentVersion,ID>(); 
        Map<ID,ID> versionToParentMap3 = new Map<ID,ID> (); 
        
        for(Attachment att : attachmentList) {    
            if(String.valueof(att.parentId).substring(0,3) != '00X'){
                ContentVersion cv = new ContentVersion();    
                cv.Title = att.Name;
                cv.PathOnClient = att.Name;
                cv.VersionData = att.body;
                cv.ContentLocation = 'S';
                cv.Origin = 'H';   
                
                if(taskIdMap.containsKey(att.ParentId)){
                    cv.Description = att.Id +'###'+att.ParentId +'###'+taskIdMap.get(att.ParentId).whoId;
                }
                else if(eventIdMap.containsKey(att.ParentId)){
                    cv.Description = att.Id +'###'+att.ParentId +'###'+eventIdMap.get(att.ParentId).whoId;
                }
                else if(inboundEmailIdMap.containsKey(att.ParentId)){
                    cv.Description = att.Id +'###'+inboundEmailIdMap.get(att.ParentId).RelatedToId;
                }
                else{
                    cv.Description = att.Id +'###'+att.ParentId;
                }
                
                contentVersionList.add(cv);
            }
        }
    
        insert contentVersionList;
        
        List<ContentVersion> afterInsertCVList = [select Id, ContentDocumentId, Title ,VersionData,Description from ContentVersion where Id IN : contentVersionList ];
        //system.debug('afterInsertCVListafterInsertCVListafterInsertCVList'+afterInsertCVList);
        for( ContentVersion cv : afterInsertCVList ){
            String parentId;
            String gParentId;
            If(cv.Description.contains('###')){
                List<String> parentIds = cv.description.split('###'); 
                
                If(parentIds != null && parentIds.size() == 2){
                    parentId = parentIds[1];
                    ContentDocumentLink cl1 = new ContentDocumentLink(LinkedEntityId = parentId, ContentDocumentId = cv.ContentDocumentId, ShareType = 'I');
                    contentDocsLinkList.add(cl1); 
                }
                If(parentIds != null && parentIds.size() == 3){
                    parentId = parentIds[1];
                    gParentId = parentIds[2];
                    ContentDocumentLink cl1 = new ContentDocumentLink(LinkedEntityId = parentId, ContentDocumentId = cv.ContentDocumentId, ShareType = 'I');
                    contentDocsLinkList.add(cl1); 
                    ContentDocumentLink cl2 = new ContentDocumentLink(LinkedEntityId = gParentId, ContentDocumentId = cv.ContentDocumentId, ShareType = 'I');
                    contentDocsLinkList.add(cl2); 
                }   
            }
            cv.Description = null;
        }
        update afterInsertCVList;
        insert contentDocsLinkList;
        System.debug('System Entry.......................four');
    }
}