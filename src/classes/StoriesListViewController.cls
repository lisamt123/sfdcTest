public with sharing class StoriesListViewController {  
    
    public static Set<id> projectsId;  
    @AuraEnabled
    public static List<Story__c> getAllStories(){
    
        List<Story__c> storyList = new List<Story__c>();
            storyList = [SELECT id, CreatedById, Name, Story_Name__c, Sprint__c, Sprint__r.Name, Sprint__r.Project__c, Status__c, Project__c, Project__r.Name, 
                Epic__c, Epic__r.Name, Epic__r.Epic_Name__c, Epic__r.Project__c, Level_of_Effort__c, Priority__c, Functional_Owner__c, Functional_Owner__r.Name 
                FROM Story__c ORDER BY Id ASC];
        return storyList;
    }
    @AuraEnabled
    public static List<Project__c> getProjects(){
        List<Story__c> storyLst = [SELECT id, Name, Sprint__c, Story_Name__c, Status__c, Project__c, Project__r.name
                                   FROM Story__c];
        Set<id> setProjects = new Set<id>();
        for(Story__c stry : storyLst ){
            setProjects.add(stry.Project__c);   
        }
        projectsId = new set<id>();
        projectsId = setProjects ;
        return [Select Id, OwnerId, Name FROM Project__c where id in :setProjects];
    }
    @AuraEnabled
    public static  List<Sprint__c> getSprints(){
        return [SELECT Id, Name, Project__c FROM Sprint__c where Project__c in : projectsId ];
    }
    @AuraEnabled
    public static  String getCurrUserId(){
        return UserInfo.getUserId();
    }
    @AuraEnabled
    public static List<String> getStatusPickList(){
        //add on 25/10
        Schema.DescribeFieldResult fieldResult = Story__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        List<String> StatusList = new List<String>();
        
        for( Schema.PicklistEntry f : ple){
          StatusList.add(f.getLabel());
        }       
        return StatusList;    
    } 
      
    @AuraEnabled 
    public static Story__c submitSave(Story__c stryObj){ 
        system.debug('--------'+stryObj);   
        system.debug('save ---->' + stryObj);
        Story__c storyObject = new Story__c();        
        storyObject =(Story__c)stryObj;
        upsert storyObject ; 
        //upsert stryObj;
        system.debug(storyObject);
        return storyObject;
    } 
     @AuraEnabled 
    public static Story__c submitCreate(Story__c stryObj){ 
        system.debug('--------'+stryObj);   
        system.debug('save ---->' + stryObj);
        Story__c storyObject = new Story__c();        
        storyObject =(Story__c)stryObj;
        upsert storyObject ; 
        //upsert stryObj;
        system.debug(storyObject);
        return [SELECT id, CreatedById, Name, Story_Name__c, Sprint__c, Sprint__r.Name, Sprint__r.Project__c, Status__c, Project__c, Project__r.name, 
                Epic__c, Epic__r.Name, Epic__r.Project__c, Level_of_Effort__c, Priority__c, Functional_Owner__c, Functional_Owner__r.Name,
                Description__c, Test_Scenarios__c, Technical_Design_Notes__c FROM Story__c where id=:storyObject.id];
    }     
     @AuraEnabled 
    public static void submitDelete(Story__c stryObj){ 
        system.debug('--------'+stryObj);   
        system.debug('save ---->' + stryObj);
        Story__c storyObject = new Story__c();        
        storyObject =(Story__c)stryObj;
        delete storyObject ; 
        //upsert stryObj;
        system.debug(storyObject);
    }  
    @AuraEnabled
    public static Story__c getcurrentStory(String recordID)
    {
        String recID = recordID;

        return [SELECT id, CreatedById, Name, Story_Name__c, Sprint__c, Sprint__r.Name, Sprint__r.Project__c, Status__c, Project__c, Project__r.Name, 
                Epic__c, Epic__r.Id, Epic__r.Name, Epic__r.Project__c, Level_of_Effort__c, Priority__c, Functional_Owner__c, Functional_Owner__r.Name,
                Description__c, Test_Scenarios__c, Technical_Design_Notes__c FROM Story__c WHERE Id =: recID LIMIT 1];
    }
    @AuraEnabled
    public static List<Story__c> getfilteredStory(String project, String sprint, String epic, List<String> status, String userid, String usertype)
    {
        String projectId        = project;
        String sprintId         = sprint;
        String epicId           = epic;
        List<String> statusList = status;
        String currentuserId    = userid;
        String usertypeFilter   = usertype;
        List<Story__c> storyList = new List<Story__c>();

        System.debug(projectId+'=='+sprintId+'=='+epicId+'=='+statusList+'=='+currentuserId+'=='+usertypeFilter);
        String query = 'SELECT id, CreatedById, Name, Story_Name__c, Sprint__c, Sprint__r.Name, Sprint__r.Project__c, Status__c, Project__c, Project__r.Name, Epic__c,'+
                        ' Epic__r.Id, Epic__r.Name, Epic__r.Project__c, Level_of_Effort__c, Priority__c, Functional_Owner__c, Functional_Owner__r.Name FROM Story__c';
        if(projectId != 'all' || sprintId != 'all' || epicId != 'all' || currentuserId != 'all' || statusList.size() > 0)
        {
            query += ' WHERE ';
        }
        if(projectId != 'all')
        {
            query += ' Project__c =: projectId';
        }
        if(sprintId != 'all')
        {
            if(projectId != 'all')
                query += ' AND Sprint__c =: sprintId';
            else
                query += ' Sprint__c =: sprintId';
        }
        if(epicId != 'all')
        {
            if(sprintId != 'all' || projectId != 'all')
                query += ' AND Epic__c =: epicId';
            else
                query += ' Epic__c =: epicId';
        }
        if(currentuserId != 'all')
        {
            if(sprintId != 'all' || projectId != 'all' || epicId != 'all')
            {
                if(usertypeFilter == 'My Stories - Functional Owner')
                    query += ' AND Functional_Owner__c =: currentuserId';
                else if(usertypeFilter == 'My Stories - Delivery Owner')
                    query += ' AND Delivery_Owner__c =: currentuserId';
                else
                    query += ' AND QA_Owner__c =: currentuserId';
            }
            else
            {
                if(usertypeFilter == 'My Stories - Functional Owner')
                    query += ' Functional_Owner__c =: currentuserId';
                else if(usertypeFilter == 'My Stories - Delivery Owner')
                    query += ' Delivery_Owner__c =: currentuserId';
                else
                    query += ' QA_Owner__c =: currentuserId';
            }
        }
        if(statusList.size() > 0)
        {
            if(sprintId != 'all' || projectId != 'all' || epicId != 'all' || currentuserId != 'all')
            {
                query += ' AND Status__c IN : statusList';
            }
            else
            {
                query += ' Status__c IN : statusList';
            }
        }
        System.debug(query);
        
        return Database.query(query);
    }
}