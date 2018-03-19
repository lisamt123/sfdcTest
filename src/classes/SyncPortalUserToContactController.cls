public without sharing class SyncPortalUserToContactController implements Queueable{

    set<Id> userIdSet;  
    
    public SyncPortalUserToContactController (set<Id> userIdSet) {
        this.userIdSet = userIdSet;
    }

    public void execute(QueueableContext context) {
    
        Map<Id, User> contactIdToUserMap = new Map<Id, User>();
        for(User u : [SELECT Id, ContactId, Email, FirstName, LastName
                      FROM User
                      WHERE Id IN: userIdSet]) {

            if(u.ContactId != null) {
                contactIdToUserMap.put(u.ContactId, u);
            }
        }

        List<Contact> contactUpdateList = new List<Contact>();
        Id userId;
        for(Contact con : [SELECT Id, Portal_User__c
                           FROM Contact
                           WHERE Id IN: contactIdToUserMap.keySet()]) {
            userId = contactIdToUserMap.get(con.Id).Id;
            if(con.Portal_User__c != userId) {
                con.Portal_User__c = userId;
                contactUpdateList.add(con);
            }
        }

        if(!contactUpdateList.isEmpty() && !Test.isRunningTest()) {
            system.debug('contact updated-queueable--->');
            update contactUpdateList;
        }
        
        
    }
}