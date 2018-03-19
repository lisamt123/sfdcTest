@isTest
private class TaskTriggerHandler_Test {
    
    @isTest 
    static void test_method_one() {
        Test.startTest();

            List<Task__c> taskList = createData();
            List<Story__c> storyList ;
            System.assertNotEquals(null,taskList);
            taskList[0].Status__c = 'Ready For Work';
            update taskList;

            storyList = [SELECT Id,Status__c FROM Story__c Limit 1];
            system.assertEquals(storyList[0].Status__c ,'Draft');
        	storyList[0].Level_of_Effort__c = 5;
        	update storyList;

            taskList[0].Status__c = 'In Progress';
            update taskList;

            storyList = [SELECT Id,Status__c FROM Story__c Limit 1];
            system.assertEquals(storyList[0].Status__c ,'In Progress');

          

            /*
            taskList[0].Status__c = 'Blocked';
            update taskList;

            storyList = [SELECT Id,Status__c FROM Story__c Limit 1];
            system.assertEquals(storyList[0].Status__c ,'Blocked');

            taskList[0].Status__c = 'Completed';
            update taskList;

            storyList = [SELECT Id,Status__c FROM Story__c Limit 1];
            system.assertEquals(storyList[0].Status__c ,'Ready for Review');
            */
        Test.stopTest();
    }

    public static List<Task__c> createData() {
        TestDataFactory dataFactory = new TestDataFactory();
        List<Account> accountsList = dataFactory.generateAccounts(1);
        insert accountsList;

        List<Project__c> projectList = dataFactory.generateProjects(accountsList[0].Id, 1);
        projectList[0].Story_LOE_Required_Starting_At__c = 'Ready for Review';
        projectList[0].Task_LOE_Required_Starting_At__c = 'Ready for Review';
        insert projectList;
        
       

        List<Story__c> storyList = new List<Story__c>();
        storyList.add(new Story__c(Story_Name__c = 'Test Story', Project__c = projectList[0].Id, Status__c = 'Draft', Priority__c = 'Medium'));
        insert storyList;
        
        List<Contact> contactList = dataFactory.generateContactsForAccounts(accountsList, 1);
        contactList[0].Email='Test@gmail.com';
        insert contactList ;

         List<Assignment__c> assignmentList = TestDataFactory_Assignments.generateAssignments(projectList[0].Id, contactList[0].Id, null, 'Active', 'Developer', 'Named Resource', true, 250, 1);
        insert assignmentList;
        
        List<Task__c> taskList = new List<Task__c>();
        taskList.add(new Task__c(Task_Name__c = 'Task 1',Story__c = storyList[0].Id, Status__c = 'Draft',Priority__c = 'Medium' ));
        taskList[0].Estimated_Level_of_Effort__c = 5;
        insert taskList;

          List<Time_Entry__c> timeEntriesList = TestDataFactory_TimeEntries.generateTimeEntries(assignmentList[0].Id, 'Test', system.today().addDays(10), 8, 2);
            timeEntriesList[0].Story__c = storyList[0].Id;
            timeEntriesList[0].Task__c = taskList[0].Id;

            insert timeEntriesList;

        return taskList;
    }
}