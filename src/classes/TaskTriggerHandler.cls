public with sharing class TaskTriggerHandler {

    public void onAfterInsert(List<Task__c> newTaskList, Map<Id, Task__c> newTaskMap) {
        updateStoryStatus(newTaskList);
    }

    public void onAfterUpdate(List<Task__c> newTaskList, Map<Id, Task__c> newTaskMap, List<Task__c> oldTaskList, Map<Id, Task__c> oldTaskMap) {
        updateStoryStatus(newTaskList);
    }

    private void updateStoryStatus(List<Task__c> taskList) {
        Set<Id> storyIdSet = new Set<Id>();
        
        for(Task__c task : taskList) {
            if(task.Story__c != null) {
                storyIdSet.add(task.Story__c);
            }
        }

        List<Story__c> storyList = new List<Story__c>();

        for(Story__c story : [SELECT Id, Status__c,Level_of_Effort__c,
                                     (SELECT Id, Status__c
                                      FROM Tasks__r)
                              FROM Story__c
                              WHERE Id IN: storyIdSet]) {

            for(Task__c task : story.Tasks__r) {
                if(task.Status__c == 'In Progress' && (story.Status__c == 'Draft' || story.Status__c == 'Backlog' || story.Status__c == 'Ready for Work')) {
                    story.Status__c = 'In Progress';
                    /*if(story.Level_of_Effort__c != null || story.Level_of_Effort__c != 0)*/
                        storyList.add(story);
                    /*else
                        task.Status__c.adderror('Story related to this task also required LOE');  */
                    break;
                }
            }
        }

        if(storyList.size() > 0) {
            update storyList;
        }


        /*
        for(Task__c task : (List<Task__c>)Trigger.new) {
            if(task.Story__c != null) {
                storyIdSet.add(task.Story__c);
            }
        }

        List<Story__c> storyList = new List<Story__c>();
        
        for(Story__c story : [SELECT Id, Status__c,
                                     (SELECT Id, Status__c
                                      FROM Tasks__r)
                              FROM Story__c 
                              WHERE Id IN: storyIdSet]) {
            String status = '';
            Integer count = 0;
            
            for(Task__c task : story.Tasks__r) {
                
                if(task.Status__c == 'Blocked') {
                    status = 'Blocked';
                    break;
                }

                if(task.Status__c == 'In Progress') {
                    status = 'In Progress';
                }
                
                if(task.Status__c == 'Ready for Work' && status != 'In Progress') {
                    status = 'Backlog';
                }
                
                if(task.Status__c == 'Completed' || task.Status__c == 'Ready for Review') {
                    count++;
                }
            }

            if(count == story.Tasks__r.size()) {
                status = 'Ready for Review';
            }

            story.Status__c = status;
            storyList.add(story);
        }

        if(storyList.size() > 0) {
            update storyList;
        }
        */
    }

    public static void updateTotalHourLogged(List<Task__c> taskIdList,Boolean newRecord){
        List<Task__c> updatetaskList = new List<Task__c>();
        Map<String,Decimal> taskHoursMap = new Map<String,Decimal>();
        for(Time_Entry__c timeEntry : [SELECT Name , Hours__c,Task__c FROM Time_Entry__c WHERE Task__c IN : taskIdList AND Hours__c != null AND Hours__c > 0]) {
            if(!taskHoursMap.containsKey(timeEntry.Task__c ))
                taskHoursMap.put(timeEntry.Task__c ,0);
            Decimal totalHours = taskHoursMap.get(timeEntry.Task__c ) + timeEntry.Hours__c;
            taskHoursMap.put(timeEntry.Task__c ,totalHours);
        }  
        if(!newRecord) {
            for(Task__c task : taskIdList) {
                if(taskHoursMap.get(task.Id) != null) {
                    if(taskHoursMap.get(task.Id) != task.Total_Hours_Logged__c)
                        task.Total_Hours_Logged__c = taskHoursMap.get(task.Id);
                }
                else
                    task.Total_Hours_Logged__c = 0;
            }
        }
        else{
            for(Task__c task : [SELECT Id,Name,Total_Hours_Logged__c FROM Task__c WHERE Id IN : taskIdList]) {
                if(taskHoursMap.get(task.Id) != null) {
                    if(taskHoursMap.get(task.Id) != task.Total_Hours_Logged__c)
                        task.Total_Hours_Logged__c = taskHoursMap.get(task.Id);
                }
                else
                   task.Total_Hours_Logged__c = 0; 

                updatetaskList.add(task);    
            }

            if(updatetaskList.size() > 0)
                update updatetaskList;
        }
    }

    public static void updateTaskLOE(List<Task__c> taskIdList){
        List<String> pickListValuesList= new List<String>();
        List<Id> storyIdList = new List<Id>();
        Set<String> statusNextList= new Set<String>();
        Map<Id,Boolean> storyToTaskLOE = new Map<Id,Boolean>();
        Boolean status = false;
        Map<Id,String> projectIdtotaskStatus = new Map<Id,String>();
        Schema.DescribeFieldResult fieldResult = Task__c.Status__c.getDescribe();
        for(Schema.PicklistEntry pickListVal : fieldResult.getPicklistValues()){
            pickListValuesList.add(pickListVal.getLabel());
        }

        for(Task__c task : taskIdList)
            storyIdList.add(task.story__c);
        
        for(Story__c story : [SELECT id,Status__c,Level_of_Effort__c,Project__r.Task_LOE_Required_Starting_At__c,Project__c From Story__c Where Id IN :storyIdList]){
            projectIdtotaskStatus.put(story.Id,story.Project__r.Task_LOE_Required_Starting_At__c);
            System.debug('story level of effort'+story.Level_of_Effort__c);
            if(story.Level_of_Effort__c != null && Integer.valueOf(story.Level_of_Effort__c) != 0)
                storyToTaskLOE.put(story.Id,true);
            else
                storyToTaskLOE.put(story.Id,false);
        }
        
        for(Task__c task :taskIdList){
            if(Trigger.isUpdate && ((task__c)Trigger.oldMap.get(task.id)).Status__c != task.Status__c || Trigger.isInsert){
                if(task.Estimated_Level_of_Effort__c == null || Integer.valueOf(task.Estimated_Level_of_Effort__c) == 0) {
                    for(String pickValue : pickListValuesList){
                        if(pickValue == projectIdtotaskStatus.get(task.story__c))
                            status = true;
                        
                        if(status)
                            statusNextList.add(pickValue);
                    }
                    
                    if(statusNextList.contains(task.Status__c)){
                        task.Status__c.adderror('LOE is required to change the Status');
                    }
                }
                else{
                    if(task.Status__c == 'In Progress') {
                        if(!storyToTaskLOE.get(task.story__c)){
                            task.Status__c.adderror('Story related to this task also required LOE');
                        }
                    }
                }
            }
        }
    }
}