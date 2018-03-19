public without sharing class ProjectRequestOverrideController {
    
    //Wrapper Class used to fetch the all the required things on load.
    public class onloadWrapperController{
        @AuraEnabled
        public List<String> RolePickValues {get;set;}
        @AuraEnabled
        public List<Project__c> ActiveProjects {get;set;}
        @AuraEnabled
        public Project_Request_Detail__c PRD {get;set;}
        
        public onloadWrapperController(List<Project__C> Active,List<String> lstStr,Project_Request_Detail__c objPrd ){
            this.RolePickValues = lstStr;
            this.ActiveProjects = Active;
            this.PRD = objPrd;
        }
    }
    
    @AuraEnabled
    public static onloadWrapperController Intialise(){
        List<String> lstRoleValues = ProjectRequestOverrideController.pickListValues();
        List<Project__c> ActiveProjects = ProjectRequestOverrideController.ActiveProjectsOfLoggedInUser();
        Project_Request_Detail__c ObjPrd = ProjectRequestOverrideController.incrementPRDRow(new Project__c());
        onloadWrapperController objWrapper = new onloadWrapperController(ActiveProjects,lstRoleValues,ObjPrd);
        return objWrapper;
    }
    
    @AuraEnabled
    public static List<String> pickListValues(){
        List<String> lstoptions = new List<string>();
        Schema.DescribeFieldResult fieldResult = Project_Request_Detail__c.Role__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        lstoptions.add('None');
        for( Schema.PicklistEntry f : ple)
        {
           lstoptions.add(f.getValue());
        }       
        return lstoptions;
    }
    
    @AuraEnabled
    public static List<project__c> ActiveProjectsOfLoggedInUser(){
        User objCurrentLoggedInUser = [Select Id, ContactId, Contact.AccountId From User Where Id = :userInfo.getUserId()];
        return [Select Id, Name, Account__c, Status__c, OwnerId From Project__c Where Account__c = :objCurrentLoggedInUser.Contact.AccountId AND Status__c = 'Open'];
    }
    
    @AuraEnabled
    public static Project__C ProjectRecord(Id selectedProjectRecordID){
        return [Select Id, Name,Start_Date__c,End_Date__c From Project__c Where Id =: selectedProjectRecordID];
    }
    
    @AuraEnabled
    public static Project_Request_Detail__c incrementPRDRow(Project__c project){
        if(project != null &&(project.Start_Date__c != null && project.End_Date__c != null))
        {
            return new Project_Request_Detail__c(Role__c = '', Requested_Start_Date__c = project.Start_Date__c, Requested_End_Date__c = project.End_Date__c, Requested_Allocation__c=10, Description__c='', Requested_Hours__c= 0, Requested_Rate__c = 0.00);
        }
        else{
            return new Project_Request_Detail__c(Role__c = '', Requested_Start_Date__c = Date.today(), Requested_End_Date__c = Date.today(), Requested_Allocation__c=10, Description__c='', Requested_Hours__c= 0, Requested_Rate__c = 0.00);
        }
    }
    
    @AuraEnabled
    public static saveResponse insertprojectRecord(Project__c objProjectToInsert, String strProjectReqDetailToInsert,string pRDescription){
        
        Savepoint sp1 = Database.setSavepoint();
        
        Project_Request__c objProjectRequestToInsert = new Project_Request__c();
		List<Project_Request_Detail__c> listToInsertPRD = new List<Project_Request_Detail__c>();
        system.debug('Project-------------:'+objProjectToInsert);
        system.debug('Prd--------:'+strProjectReqDetailToInsert);
        User objCurrentLoggedInUser = [Select Id, ContactId, Contact.AccountId,contact.Account.ownerId From User Where Id = :userInfo.getUserId()];
        objProjectToInsert.Account__c =  objCurrentLoggedInUser.Contact.AccountId;
        objProjectToInsert.Status__c = 'Open';
        //deserialise the string
        List<Project_Request_Detail__c> lstProjectReqDetailToInsert = (List<Project_Request_Detail__c>)JSON.deserializeStrict(strProjectReqDetailToInsert, List<Project_Request_Detail__c>.class);    
        system.debug('----------------------'+lstProjectReqDetailToInsert);
        try{
            //commenting this as project record is being created by S-0081. we are not creating the project Record
            /*if(objProjectToInsert.id == null){
                insert objProjectToInsert;
            }*/
            
            
            if(objCurrentLoggedInUser.ContactId != null) {
                            
                //objProjectRequestToInsert.Project__c = objProjectToInsert.Id;
                objProjectRequestToInsert.Project_Name__c = objProjectToInsert.Name;
                objProjectRequestToInsert.Account__c = objCurrentLoggedInUser.Contact.AccountId;
                objProjectRequestToInsert.Request_Contact__c = objCurrentLoggedInUser.ContactId;
                objProjectRequestToInsert.Start_Date__c = objProjectToInsert.Start_Date__c;
                objProjectRequestToInsert.End_Date__c = objProjectToInsert.End_Date__c;
            }
            else
            {
                //objProjectRequestToInsert.Project__c = objProjectToInsert.Id;
                objProjectRequestToInsert.Project_Name__c = objProjectToInsert.Name;
            }
            objProjectRequestToInsert.Description__c = pRDescription;
            objProjectRequestToInsert.OwnerId = objCurrentLoggedInUser.Contact.Account.ownerId;
            
            insert objProjectRequestToInsert;
                
            if(objProjectRequestToInsert != null) {
                            
                for(Project_Request_Detail__c objProjectRequestDetail : lstProjectReqDetailToInsert){                                                                                
                               
                    objProjectRequestDetail.Project_Request__c = objProjectRequestToInsert.Id;
                    
                    listToInsertPRD.add(objProjectRequestDetail);
                }
                listToInsertPRD.remove(listToInsertPRD.size()-1);
                system.debug('PRD Inserted--------------------:'+ listToInsertPRD);
                    
                if(!listToInsertPRD.isEmpty()) {
                    insert listToInsertPRD;
                    system.debug('PRD Inserted:'+ listToInsertPRD);
                    return new saveResponse(false,'Request Successfuly Submitted',objProjectRequestToInsert.Id);
                
                    //return performRedirectionToDetailViewPage(objProjectRequestToInsert.Id);
                }
            }
            
        }
        catch(Exception e)
        {
            System.debug('Project Request Detail Records not Created:');
            Database.RollBack(sp1);
            return new saveResponse(true,e.getMessage(),null);
        }
        if(objProjectRequestToInsert.Id != null)
        	return new saveResponse(false,'Project Request Created',objProjectRequestToInsert.Id);
        else 
            return null;
            
    }
    
    public class saveResponse {
        @AuraEnabled
        public Boolean isError {get;set;}
        @AuraEnabled
        public String Error_SuccessMsg {get;set;}
        @AuraEnabled 
        public Id ProjectRequestId {get;set;}
        
        public saveResponse(Boolean isError, String msg, Id prId){
            this.isError = isError;
            this.Error_SuccessMsg = msg;
            this.ProjectRequestId = prId;
        }
    }
    
}