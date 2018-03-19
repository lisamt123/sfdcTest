/*
    Author :- Akshat
    Trigger purpose :- Whenever we add the logo from file then the URL will be updated via helper in Achievement to display the logo everywhere
*/

trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert) {
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            ContentDocumentLinksHelper.processAfterInsert(Trigger.new);
        }
    }
}