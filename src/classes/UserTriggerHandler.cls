public with sharing class UserTriggerHandler {
    
    Set<Id> portalUserIds;
    
    public void onBeforeInsert(List<User> newUserList) {
        maintainUserFields(newUserList);
    }

    public void onBeforeUpdate(Map<Id, User> newUserMap, List<User> newUserList, Map<Id, User> oldUserMap, List<User> oldUserList) {
    	//maintainUserPermissionSet(newUserMap.keySet());
    	maintainUserPermissionSet();
        maintainUserFields(newUserList);
    }

    public void onAfterInsert(Map<Id, User> newUserMap, List<User> newUserList) {
        portalUserIds = new set<Id>();
        syncCommunityUserIdToContact(newUserMap.keySet());
        recalculateSharing(newUserList, newUserMap.keySet());
    }

    public void onAfterUpdate(Map<Id, User> newUserMap, List<User> newUserList, Map<Id, User> oldUserMap, List<User> oldUserList) {
        portalUserIds = new set<Id>();
        syncCommunityUserIdToContact(newUserMap.keySet());
        recalculateSharing(newUserList, newUserMap.keySet());
    }

    private void maintainUserFields(List<User> newUserList) {
        for(User u : newUserList) {
            u.Is_Portal_User__c = u.IsPortalEnabled;
        }
    }

    private void syncCommunityUserIdToContact(Set<Id> userIdSet) {
        if(system.isBatch() || system.isFuture()) {
           //queueable
           portalUserIds = userIdSet;
        }
        else{
            syncCommunityUserToContact(userIdSet);
        }
    }
    
    //To maintain permission set prior to user license change
    private void maintainUserPermissionSet() {
    	Map<Id, Profile> allProfiles = new Map<Id, Profile>([SELECT Id, UserLicenseId FROM Profile ]);
    	Set<Id> userIds = new Set<Id>();
    	//Only if license is changed for user, we have to maintain the permission sets
    	for(User user :(List<User>)Trigger.new) {
    		User oldUser = (User)Trigger.oldMap.get(user.Id);
    		if(allProfiles.get(user.ProfileId).UserLicenseId != allProfiles.get(oldUser.ProfileId).UserLicenseId) {
    			userIds.add(user.Id);		
    		}	
    	}
    	
    	if(userIds.size() > 0) {
	    	//We have to only maintain PermissionSet for community users 
	    	List<PermissionSetAssignment> permissionAssignments = [ SELECT PermissionSetId, AssigneeId FROM PermissionSetAssignment
	    															WHERE AssigneeId IN :userIds AND Assignee.ContactId != null AND
	    														    PermissionSetId IN (Select Id From PermissionSet WHERE IsOwnedByProfile = false)
	    														  ]; 
	    	if(permissionAssignments.size() > 0) {
		    	String permissionSetInfo = JSON.serialize(permissionAssignments);  
		    	//Now pass this info to future method so that we can again assign Permission set   
                if(System.isBatch() || System.isFuture() || System.isQueueable())
                {
                    reAssignPermissionSetToUserBatch(permissionSetInfo);    
                }
                else
                {
                    reAssignPermissionSetToUser(permissionSetInfo); 
                }
	    	}
    	}
    }

    @future
    private static void syncCommunityUserToContact(Set<Id> userIdSet) {
        
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

        if(!contactUpdateList.isEmpty()) {
            system.debug('contact updated---->');
            update contactUpdateList;
        }
    }
    
    private void recalculateSharing(List<User> userList, Set<Id> userIdSet){
    
        Map<Id,Id> userToContactMap = new Map<Id,Id>();
        set<Id> userIds = new set<Id>();
        set<Id> accountIds = new set<Id>();
        set<Id> contactIds = new set<Id>();
         
        for(User userObj : userList){
            //filter users
            if(userObj.isPortalEnabled && userObj.contactId !=null){
                if(Trigger.isUpdate && userObj.isActive != ((User)Trigger.oldMap.get(userObj.id)).isActive){
                    userIds.add(userObj.id);
                }    
                if(Trigger.isInsert){   
                    userIds.add(userObj.id);      
                }    
            }
        }
        
        // let's query user's fields and fill map of contact and their account id.
        for(User userObj : [select id,name,contactid,contact.accountid, Profile.UserLicense.Name from user 
                            where id in :userIds and (Profile.UserLicense.Name = 'Customer Community Plus' OR Profile.UserLicense.Name = 'Customer Community Plus Login')]){
                            
            accountIds.add(userObj.contact.accountid);  
            contactIds.add(userObj.contactId);
        }
        
        set<Id> projectIds = new set<Id>();
        set<Id> assignmentIds = new set<Id>();
        set<Id> setProjectRequestIDs = new set<Id>();
        
        //Getting projects tied to account
        if(accountIds.size()>0){
            List<Project__c> projectList = [select id from project__c where account__c in : accountIds];
            if(projectList !=null && projectList.size()>0){
                for(Project__c project : projectList){
                    projectIds.add(project.Id);
                }  
            }    
        }   
        
        //getting assignments and projects tied to contact
        if(contactIds.size()>0) {
           List<Assignment__c> assignmentList = [select id,Project__c from assignment__c where resource__C in : contactIds];
           if(assignmentList !=null && assignmentList.size()>0){
               for(Assignment__c assignment : assignmentList){
                    assignmentIds.add(assignment.Id);
                    projectIds.add(assignment.Project__c);
               }
           }
           
            List<Project_Request__c> lstProjectRequestRecords = [Select Id from Project_Request__c Where Request_Contact__c IN :contactIds];
        
            if(lstProjectRequestRecords != null && lstProjectRequestRecords.size() > 0) {
                
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
        
                if(!contactUpdateList.isEmpty()) {
                    system.debug('contact updated---->');
                    update contactUpdateList;
                }
        
                for(Project_Request__c objProjectRequest : lstProjectRequestRecords) {
                
                    setProjectRequestIDs.add(objProjectRequest.Id);
                }
            }           
        } 

        //updating projects tied to account and contact
        if(!(System.isBatch() || System.isFuture()) && projectIds.size() > 0){
            updateProjects(projectIds);
        } 

        //updating assignments tied to contact
        if(!(System.isBatch() || System.isFuture()) && assignmentIds.size() > 0){
            updateAssignments(assignmentIds);
        }

        if(!(System.isBatch() || System.isFuture()) && setProjectRequestIDs.size() > 0) {
            
            updateProjectRequestRecords(setProjectRequestIDs);
        }
        
        //queueing jobs
        if(System.isBatch() || System.isFuture() && (projectIds.size() > 0 || assignmentIds.size() > 0 || portalUserIds.size() > 0 )){
            system.debug('queueing job- --->');
            if(!Test.isRunningTest()){
                System.enqueueJob(new RecalculateSharingController(projectIds, assignmentIds,portalUserIds, setProjectRequestIDs));
            }
        }
    }
    

    @future
    private static void updateProjects(set<Id> projectIds){
        //setting checkbox to 'True'
        system.debug('its entered #####-------->');
        List<Project__c> projectList = new List<Project__c>();
        for(Project__c projectObj : [select id,name, Recalculate_Sharing_on_Save__c from project__c where id in :projectIds]){           
            
            projectObj.Recalculate_Sharing_on_Save__c = true;
            projectList.add(projectObj); 
        } 
        if(projectList.size()>0){   
            try{
                system.debug('---> list to update' + projectList);
                update projectList;
            }catch(Exception exp){
                system.debug('Exception caught ---->' + exp.getMessage());
            }
        }         
    }
    
    @future
    private static void updateAssignments(set<Id> assignmentIds){
        system.debug('its entered #####---aasss----->');
        //setting checkbox to 'True'
        List<Assignment__c> assignmentList = new List<Assignment__c>();
        for(Assignment__c assignmentObj : [select id, Recalculate_Sharing_on_Save__c from assignment__c where id in :assignmentIds]){           
            assignmentObj.Recalculate_Sharing_on_Save__c = true;
            assignmentList.add(assignmentObj); 
        } 
        if(assignmentList.size()>0){   
            try{
                system.debug('---> assignment list to update' + assignmentList);
                update assignmentList;
            }catch(Exception exp){
                system.debug('Exception caught ---->' + exp.getMessage());
            }
        } 
    }
    
    @future
    private static void updateProjectRequestRecords(set<Id> setProjectRequestIDs){
    
        system.debug('#####----Entered---ProjectRequest---Updation-->');            
        
        List<Project_Request__c> lstProjectRequestRecordsToUpdate = new List<Project_Request__c>();
        
        for(Project_Request__c objProjectRequest : [Select Id, Recalculate_Sharing_on_Save__c From Project_Request__c where Id IN :setProjectRequestIDs]) {   
            
            Project_Request__c objProjectRequestToUpdate = new Project_Request__c(Id = objProjectRequest.Id, Recalculate_Sharing_on_Save__c = true);
            lstProjectRequestRecordsToUpdate.add(objProjectRequestToUpdate); 
        } 
        
        if(!lstProjectRequestRecordsToUpdate.isEmpty()) {  
        
            try {           
                system.debug('#####----lstProjectRequestRecords to update-->' +lstProjectRequestRecordsToUpdate);
                update lstProjectRequestRecordsToUpdate;
            }               
            catch(Exception exp) {          
                system.debug('#####----Exception caught ---->' +exp.getMessage());
            }
        } 
    }
    
    
    @future
    private static void reAssignPermissionSetToUser(String permissionSetInfo) {
    	List<PermissionSetAssignment> permissionSetAssignmentList = (List<PermissionSetAssignment>)JSON.deserialize(permissionSetInfo, List<PermissionSetAssignment>.class);
    	List<PermissionSetAssignment> permissionSetToMaintainList = new List<PermissionSetAssignment>();
    	for(PermissionSetAssignment permissionSetAssignment :permissionSetAssignmentList) {
    		permissionSetToMaintainList.add(new PermissionSetAssignment(PermissionSetId = permissionSetAssignment.PermissionSetId, AssigneeId = permissionSetAssignment.AssigneeId));		
    	}
    	try {
    		insert permissionSetToMaintainList;
    	}catch(DMLException ex) {
    		//Nothing to do here 
    		System.debug(ex.getMessage());
    	}	
    }

    private static void reAssignPermissionSetToUserBatch(String permissionSetInfo) {
        List<PermissionSetAssignment> permissionSetAssignmentList = (List<PermissionSetAssignment>)JSON.deserialize(permissionSetInfo, List<PermissionSetAssignment>.class);
        List<PermissionSetAssignment> permissionSetToMaintainList = new List<PermissionSetAssignment>();
        for(PermissionSetAssignment permissionSetAssignment :permissionSetAssignmentList) {
            permissionSetToMaintainList.add(new PermissionSetAssignment(PermissionSetId = permissionSetAssignment.PermissionSetId, AssigneeId = permissionSetAssignment.AssigneeId));       
        }
        try {
            insert permissionSetToMaintainList;
        }catch(DMLException ex) {
            //Nothing to do here 
            System.debug(ex.getMessage());
        }   
    }
}