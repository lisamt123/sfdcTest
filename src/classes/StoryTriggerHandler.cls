public with sharing class StoryTriggerHandler {
	
	public static void deleteStoryInfoFromHeroku() {
        List<String> storyIdList = new List<String>();
        for(Story__c story: (List<Story__c>)Trigger.old) {
            if(story.Scan_Running__c) 
                story.addError('Story can\'t be deleted while code scan is in progress.' );
            else if(!story.Delete_on_Heroku__c && !story.Allow_Deletion__c && story.Created_on_Heroku__c) 
                story.addError('This Story has been included in a Release or has stored results from a code scan, and cannot be deleted. Contact a 10K Administrator if you need assistance deleting this Story.' );
            else if(story.Created_on_Heroku__c)
                storyIdList.add(story.Id);
        }

        String projectId    = '';
        String projectName  = '';
        for(Story__c story: [SELECT Id, Project__c, Project__r.Name FROM Story__c WHERE Id IN:storyIdList]) {
            if(projectId == '' || story.Project__c == projectId) {
                projectId   = story.Project__c;
                projectName = story.Project__r.Name;
            }
            else {
                projectId   = null;
                projectName = null;
            }
        }

        if(storyIdList.size() > 0)
            removeStoriesFromHeroku(storyIdList,projectId,projectName);
	}

    @future(callout=true)
    public static void removeStoriesFromHeroku(List<String> storyIdList,String projectId,String projectName) {
        DeleteRecordsFromHeroku.removeRecordsFromHeroku(storyIdList,projectId,projectName);
    }

    public static void updateSprintStatus() {
        Set<Id> sprintIdSet = new Set<Id>();

        for(Story__c story : (List<Story__c>)Trigger.new) {
            if( story.Sprint__c != null)
                sprintIdSet.add(story.Sprint__c);
        }

        List<Sprint__c> sprintList = new List<Sprint__c>();
        for(Sprint__c sprint : [SELECT Id, Status__c, 
                                       (SELECT Id, Status__c
                                        FROM Stories__r)
                                FROM Sprint__c 
                                WHERE Id IN: sprintIdSet]) {
            String status = '';
            Integer count = 0;

            for(Story__c story : sprint.Stories__r) {
                if(story.Status__c == 'In Progress' || story.Status__c == 'Ready for Review') {
                    status = 'In Progress';
                }
            }

            if(status != '') {
                sprint.Status__c = status;
            }

            sprintList.add(sprint);
        }

        if(sprintList.size() > 0) {
            update sprintList;
        }
    }

    public static void updateSprintLOE() {
        Set<Id> sprintIdSet = new Set<Id>();
        for(Story__c story : (List<Story__c>) Trigger.new) {
           
            /* Modified By Akshat to work when also when Level Of Effort --> Null or 0 
            
            if(story.Level_of_Effort__c != null && story.Level_of_Effort__c > 0 && (Trigger.oldMap == null || story.Level_of_Effort__c != Trigger.oldMap.get(story.Id).get('Level_of_Effort__c'))) {
                sprintIdSet.add(story.Sprint__c);
            } */
            
            if((Trigger.oldMap == null || (story.Level_of_Effort__c != Trigger.oldMap.get(story.Id).get('Level_of_Effort__c'))) ) {
                sprintIdSet.add(story.Sprint__c);
            }
            else if(story.Sprint__c != Trigger.oldMap.get(story.Id).get('Sprint__c')){
                if(story.Sprint__c != null )
                    sprintIdSet.add(story.Sprint__c);
                if(Trigger.oldMap.get(story.Id).get('Sprint__c') != null ){
                    sprintIdSet.add((Id)Trigger.oldMap.get(story.Id).get('Sprint__c'));
                }
            }
            //%%
            System.debug(sprintIdSet);
            //%%
            
        }
        List<Sprint__c> sprintList = [SELECT Id,Assigned_Level_of_Effort__c, 
                                        (SELECT Id,Level_of_Effort__c 
                                        FROM Stories__r)
                                    FROM Sprint__c
                                    WHERE Id IN: sprintIdSet];
        List<Sprint__c> sprintListToUpdate = new List<Sprint__c>();
        for(Sprint__c sprint : sprintList ) {
            Decimal totalLOE = 0.0;
            for(Story__c story : sprint.Stories__r) {
                if(story.Level_of_Effort__c != null && story.Level_of_Effort__c > 0) {
                    totalLOE += story.Level_of_Effort__c ;
                }
            }
            sprint.Assigned_Level_of_Effort__c = totalLOE;
            //if(totalLOE > 0 || totalLOE == 0) //  rempve for update in case in stroy effort is negative , zero or positive
            sprintListToUpdate.add(sprint);
        }
        
        if(sprintListToUpdate.size() > 0) {
            update sprintListToUpdate;
        }
    }

    public static void updateTotalHourLogged(List<Story__c> storyIdList,Boolean newRecord){
        List<Story__c> updateStoryList = new List<Story__c>();
        Map<String,Decimal> storyHoursMap = new Map<String,Decimal>();
        for(Time_Entry__c timeEntry : [SELECT Name , Hours__c,Story__c FROM Time_Entry__c WHERE Story__c IN : storyIdList AND Hours__c != null AND Hours__c > 0]) {
            if(!storyHoursMap.containsKey(timeEntry.Story__c ))
                storyHoursMap.put(timeEntry.Story__c ,0);
            Decimal totalHours = storyHoursMap.get(timeEntry.Story__c ) + timeEntry.Hours__c;
            storyHoursMap.put(timeEntry.Story__c ,totalHours);
        }  
        if(!newRecord) {
            for(Story__C story : storyIdList) {
                if(storyHoursMap.get(story.Id) != null) {
                    if(storyHoursMap.get(story.Id) != story.Total_Hours_Logged__c)
                        story.Total_Hours_Logged__c = storyHoursMap.get(story.Id);
                }
                else
                    story.Total_Hours_Logged__c = 0;
            }
        }
        else{
            for(Story__C story : [SELECT Id,Name,Total_Hours_Logged__c FROM Story__c WHERE Id IN : storyIdList]) {
                if(storyHoursMap.get(story.Id) != null) {
                    if(storyHoursMap.get(story.Id) != story.Total_Hours_Logged__c)
                        story.Total_Hours_Logged__c = storyHoursMap.get(story.Id);
                }
                else
                   story.Total_Hours_Logged__c = 0; 

                updateStoryList.add(story);    
            }

            if(updateStoryList.size() > 0)
                update updateStoryList;
        }
        
    }

    public static void updateStoryLOE(List<Story__c> storyIdList){
        List<String> pickListValuesList= new List<String>();
        Set<String> statusNextList= new Set<String>();
        Set<Id> projectIdSet= new Set<Id>();
        Boolean status = false;
        Map<Id,Set<String>> projectIdtoStoryStatus = new Map<Id,Set<String>>();
        Schema.DescribeFieldResult fieldResult = Story__c.Status__c.getDescribe();
        for( Schema.PicklistEntry pickListVal : fieldResult.getPicklistValues()){
            pickListValuesList.add(pickListVal.getLabel());
        }

        for(Story__c story : storyIdList)
            projectIdSet.add(story.Project__c);
        
        for(Project__c project : [SELECT Id,Story_LOE_Required_Starting_At__c FROM Project__c WHERE Id IN :projectIdSet]){
            for(String pickValue : pickListValuesList){
                    if(pickValue == project.Story_LOE_Required_Starting_At__c)
                        status = true;
                    
                    if(status)
                        statusNextList.add(pickValue);
            }
            projectIdtoStoryStatus.put(project.Id,statusNextList);
        }

        for(Story__c story :storyIdList){
            if((Trigger.isUpdate && ((story__c)Trigger.oldMap.get(story.id)).Status__c != story.Status__c || Trigger.isInsert) && story.Level_of_Effort__c == null || Integer.valueOf(story.Level_of_Effort__c) == 0) {
                if(projectIdtoStoryStatus.get(story.project__c).contains(story.Status__c))
                    story.Status__c.adderror('LOE is required to change the Status');
            }
        }
    }
}