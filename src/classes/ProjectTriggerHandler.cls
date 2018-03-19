/**
@Name           : ProjectTriggerHandler
@Dated          : 27 June, 2016
@Author         :
@Description    : This class is Handler of ProjectTrigger, used to share Projects with community user.   
*/

public class ProjectTriggerHandler {
    
    //This methods creates sharing records for Account.
    public static void createSharingRecords(List<Project__c> projectList) {
        if(Trigger.isInsert || Trigger.isUndelete) {
            insertNewProjectShareRecords(projectList);    
        }
        else if(Trigger.isUpdate) {
            List<Project__c> listOfProjectWhichAccountAreChanged = new List<Project__c>();
            for(Project__c projectObj : projectList) {
                if(projectObj.Account__c != ((Project__c)Trigger.OldMap.get(projectObj.id)).Account__c || projectObj.Recalculate_Sharing_on_Save__c) {
                    listOfProjectWhichAccountAreChanged.add(projectObj);
                    projectObj.Recalculate_Sharing_on_Save__c = false;
                }
            }
            if(listOfProjectWhichAccountAreChanged.size() > 0) {
                deleteSharedRecords(listOfProjectWhichAccountAreChanged, true);
                insertNewProjectShareRecords(listOfProjectWhichAccountAreChanged);
            }     
        }
    }
    
    //This Method Create New Sharing Records
    private static void insertNewProjectShareRecords(List<Project__c> projectList) {
        List<Project__Share> sharingList = new List<Project__Share>();
        Map<Id, Set<Id>> userRoleMap = new Map<Id,Set<Id>>();
        Map<Id,List<Group>> groupListWithRoleIdMap = new Map<Id,List<Group>>();
            
        //let's create a Set of Account ids
        Set<Id> accountId = getAccountIds(projectList, false);

        //let's fill a Map with User role id according to the associate Account id.
        if(accountId.size() > 0) {
            userRoleMap = getUserRole(accountId);
        }
        
        //Fetching User according to the Role
        if(userRoleMap.size() > 0){
            groupListWithRoleIdMap = getGroupRecordsAccordingToRole(userRoleMap);
        }
        
        for(project__c projectObj : projectList){
            if(projectObj.Account__c !=null && userRoleMap.containsKey(projectObj.Account__c)){
                
                    for(Id userRoleId : userRoleMap.get(projectObj.Account__c)) {
                        if(groupListWithRoleIdMap.containsKey(userRoleId)) {
                            for(Group groupObj : groupListWithRoleIdMap.get(userRoleId)) {
                                 Project__Share projectRecord = new Project__Share();
                                 projectRecord.ParentId = projectObj.id;
                                 projectRecord.UserOrGroupId = groupObj.id;
                                 projectRecord.AccessLevel = 'Read';
                                 projectRecord.RowCause = Schema.Project__Share.RowCause.Customer__c;
                                 sharingList.add(projectRecord);   
                            }
                        }    
                   }    
            }
                 
        }
        try{
            if(sharingList.size() > 0){
                insert sharingList;
            }
        }catch(Exception e){
            System.debug('Project Share insert throw Exception:' + e.getMessage());
        }
        
    }
    
    //This methods delete sharing records for Customer. flag variable maintain direct delete and update delete functionality
    public static void deleteSharedRecords(List<Project__c> projectList, boolean deleteFlag){
        try{
            List<Project__Share> projectShareRecordForDelete = new List<Project__Share>();
            system.debug('deleteFlag: ' + deleteFlag);
            system.debug('projectList: ' + projectList);
            
            
            if(deleteFlag){
                Map<Id, Set<Id>> userRoleMap = new Map<Id,Set<Id>>();
                Map<Id,List<Group>> groupListWithRoleIdMap = new Map<Id,List<Group>>();
                Set<Id> allRolesUserOrGroupIds = new Set<Id>();    
                
                //let's create a Set of Account ids
                Set<Id> accountId = getAccountIds(projectList, true);
                
                //let's fill a Map with User role id according to the associate Account id.
                if(accountId.size()>0){
                    userRoleMap = getUserRole(accountId);
                }
                
                //Fetching User according to the Role
                if(userRoleMap.size()>0){
                    groupListWithRoleIdMap = getGroupRecordsAccordingToRole(userRoleMap);
                }
                
                for(project__c projectObj : projectList){
                    if(userRoleMap.containsKey(((Project__c)trigger.oldMap.get(projectObj.id)).Account__c)){              
                        for(Id userRoleId : userRoleMap.get(((Project__c)trigger.oldMap.get(projectObj.id)).Account__c)){
                            if(groupListWithRoleIdMap.containsKey(userRoleId)){
                                for(Group groupObj : groupListWithRoleIdMap.get(userRoleId)){
                                    allRolesUserOrGroupIds.add(groupObj.id);
                                }
                            }
                        }    
                    }
                }
                projectShareRecordForDelete = [SELECT id FROM Project__Share where ParentId in: projectList and UserOrGroupId in: allRolesUserOrGroupIds];
                    
            }else{
                projectShareRecordForDelete = [SELECT id FROM Project__Share where ParentId in: projectList];
            }
            if(projectShareRecordForDelete.size()>0)delete projectShareRecordForDelete;
        }catch(Exception ex){System.debug('Project Share delete throw Exception: ' + ex.getMessage());}
    } 
    
    //Fill Account ids
    private static Set<Id> getAccountIds(List<Project__c> projectList, boolean deleteFlag){
         Set<Id> accountIds = new Set<Id>();
         for(Project__c projectObj : projectList){
            if(projectObj.Account__c != null){
                if(deleteFlag == true){
                    accountIds.add(((Project__c)trigger.oldMap.get(projectObj.id)).Account__c);
                }else
                    accountIds.add(projectObj.Account__c);
            }     
        }
        return accountIds;
    } 
    
    //Fill User Role ids with Account ids
    private static Map<Id, Set<Id>> getUserRole(Set<Id> accountIds) {
        Map<Id, Set<Id>> accountRoleMap = new Map<Id,Set<Id>>();
        List<UserRole> userRoleList = [SELECT Id, Name, PortalAccountId, PortalRole, ParentRoleId
                                       FROM UserRole 
                                       WHERE PortalAccountId IN: accountIds 
                                             AND (PortalRole = 'Manager' OR PortalRole = 'Worker')];
                                   
        if(userRoleList.size() > 0) {
            for(UserRole userRoleObj : userRoleList) {
                Set<Id> userRoleObjSet = accountRoleMap.get(userRoleObj.portalAccountId);
                if(userRoleObjSet == null){
                    accountRoleMap.put(userRoleObj.PortalAccountId, new Set<Id>());  
                }
                accountRoleMap.get(userRoleObj.PortalAccountId).add(userRoleObj.id);    
            }
        }
        return accountRoleMap;
    }
    
    //Fill Group List accourding to Its Role
    private static Map<Id, List<Group>> getGroupRecordsAccordingToRole(Map<Id,Set<Id>> userRoleMap) {
        
        Set<Id> userRoleIds =  new Set<Id>();
        for(Id accountId : userRoleMap.keySet()){
            userRoleIds.addAll(userRoleMap.get(accountId));
        }   
        //List<User> userList = [SELECT id, name, userRoleid from User where userRoleid in: userRoleMap .values()];
        List<Group> groupList = [SELECT id, RelatedId, Type FROM Group where RelatedId in : userRoleIds and type = 'RoleAndSubordinates'];
        Map<Id, List<Group>> groupListWithRoleIdMap = new Map<Id, List<Group>>();
        if(groupList.size() > 0) {
            for(Group groupObj : groupList) {
                List<Group> groupOtherList =  groupListWithRoleIdMap.get(groupObj.RelatedId);
                if(groupOtherList == null) {
                    groupOtherList = new List<Group>();
                }
                groupOtherList.add(groupObj);
                groupListWithRoleIdMap.put(groupObj.RelatedId, groupOtherList);
            }
        }
        return groupListWithRoleIdMap;
    }

    public static void copyClientProjectDeliveryRequirements(List<Project__c> projectList)
    {
        List<Project__c> projectListToUpdate = new List<Project__c>();
        for(Project__c project : [SELECT Id, Account__c, Account__r.Delivery_Standards__c, Account__r.Documentation_Provided__c, Account__r.If_How_To_Log_Time_In_Their_System__c, 
                                        Account__r.Preferred_Meeting_Tool__c, Account__r.Project_And_Requirement_Management_Tools__c, Account__r.Required_Security_Personnel_Information__c, 
                                        Required_Security_Personnel_Information__c, Project_And_Requirement_Management_Tools__c, Preferred_Meeting_Tool__c, If_How_To_Log_Time_In_Their_System__c, 
                                        Documentation_Provided__c, Delivery_Standards__c 
                                    FROM Project__c 
                                    WHERE Id IN : projectList]){
            if(project.Account__c != null)
            {
                if(project.Account__r.Delivery_Standards__c != null)
                {
                    project.Delivery_Standards__c = project.Account__r.Delivery_Standards__c;
                }
                if(project.Account__r.Documentation_Provided__c != null)
                {
                    project.Documentation_Provided__c = project.Account__r.Documentation_Provided__c;
                }
                if(project.Account__r.If_How_To_Log_Time_In_Their_System__c != null)
                {
                    project.If_How_To_Log_Time_In_Their_System__c = project.Account__r.If_How_To_Log_Time_In_Their_System__c;
                }
                if(project.Account__r.Preferred_Meeting_Tool__c != null)
                {
                    project.Preferred_Meeting_Tool__c = project.Account__r.Preferred_Meeting_Tool__c;
                }
                if(project.Account__r.Project_And_Requirement_Management_Tools__c != null)
                {
                    project.Project_And_Requirement_Management_Tools__c = project.Account__r.Project_And_Requirement_Management_Tools__c;
                }
                if(project.Account__r.Required_Security_Personnel_Information__c != null)
                {
                    project.Required_Security_Personnel_Information__c = project.Account__r.Required_Security_Personnel_Information__c;
                }
                projectListToUpdate.add(project);
            }
        }

        if(!projectListToUpdate.isEmpty())
        {
            update projectListToUpdate;
        }
    }
}