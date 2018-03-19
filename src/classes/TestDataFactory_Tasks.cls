/* apar sharma 13dec */
public with sharing class TestDataFactory_Tasks {
    
    public static List<Task__c> generateTasks(String taskName, String status, Id storyId,String priority, Integer numOfRecords) {
        return generateTasksInternal(taskName, status, storyId, priority, numOfRecords);
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<Task__c> generateTasksInternal(String taskName, String status, Id storyId,String priority, Integer numOfRecords) {
        List<Task__c> taskList = new List<Task__c>();
        for(integer i = 0; i < numOfRecords ; i ++) {
        	Task__c taskRec                         = new Task__c();
        	taskRec.Task_Name__c                    = taskName;
        	taskRec.Status__c                       = status;
        	taskRec.Story__c                        = storyId;
        	taskRec.Priority__c                     = priority;
            taskRec.Estimated_Level_of_Effort__c    = 2;
        	taskList.add(taskRec);
        }
        
        return taskList ;
    }
}