@isTest
private class GrantPointsBatch_Test 
{
    @testSetup static void testSetup() {
        Id partnerClientrecordTypeId        = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList               = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
                                                            'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                            'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
                                                            null, 'Net 30', 'test@test.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
                                                            1);
        insert accList;

        List<Contact> contactList           = TestDataFactory_Contacts.generatecontacts(accList, 'Test contact', 'lastName', '', '', 1);
        insert contactList;

        List<User> userList                 = TestDataFactory_Users.generateUsers(contactList[0].Id, '10K Delivery Partner (License)', true, 1);
        insert userList;

        List<Project__c> projectList        = TestDataFactory_Projects.generateProjects(accList[0].Id, 'Test Project', 1);
        insert projectList;

        List<Story__c> storyList            = TestDataFactory_Stories.generateStories('testStory', projectList[0].id, 'Draft','Medium', 2);
        storyList[0].Status__c              = 'Completed';
        storyList[0].Level_of_Effort__c     = 60;
        storyList[0].Allow_Deletion__c      = true;
        storyList[0].Delivery_Owner__c      = userList[0].Id;
        storyList[1].Delivery_Owner__c      = userList[0].Id;
        storyList[1].Status__c              = 'Completed';
        storyList[1].Level_of_Effort__c     = 60;
        storyList[1].Allow_Deletion__c      = true;
        insert storyList;

        List<Task__c> taskList                   = TestDataFactory_Tasks.generateTasks('Demo Task', 'Draft', storyList[0].Id,'Medium', 1);
        taskList[0].Estimated_Level_of_Effort__c = 10;
        taskList[0].Estimated_Completion_Date__c = Date.today().addDays(2);
        taskList[0].Due_Date__c                  = Date.newInstance(2017, 07, 13) ;
        taskList[0].Status__c                    = 'Completed' ;
        taskList[0].Assigned_To_User__c          = userList[0].Id ;
        insert taskList;

    }

    @isTest static void test_GrantPointsBatch() 
    {
        List<Story__c> storyList            = [SELECT Id FROM Story__c];
        List<Project__c> projectList        = [SELECT Id from Project__c limit 1];
        List<Contact> contactList           = [SELECT Id from Contact limit 1];
        Id systemRecordTypeId               = Schema.SObjectType.Points_Rule__c.RecordTypeInfosByName.get('System Generated').RecordTypeId;
        List<Points_Rule__c> pointRuleList  = TestDataFactory_PointRules.generatePointRules(true, 'AND', 'Delivery_Owner__r.ContactId', 'Story__c', 10, systemRecordTypeId, 1);
        insert pointRuleList ;

        List<Points_Rule_Criteria__c> pointRuleCriteriaList = TestDataFactory_PointsRuleCriteria.generatePointRuleCriteria('Status__c', 'Completed', '=', pointRuleList[0].Id, 52);
        pointRuleCriteriaList[1].Field_API_Name__c          = 'Allow_Deletion__c';
        pointRuleCriteriaList[1].Field_Value__c             = 'True';
        pointRuleCriteriaList[1].Operator__c                = '=';

        pointRuleCriteriaList[2].Field_API_Name__c          = 'Level_of_Effort__c';
        pointRuleCriteriaList[2].Field_Value__c             = '50';
        pointRuleCriteriaList[2].Operator__c                = '>=';

        pointRuleCriteriaList[3].Field_API_Name__c          = 'Project__c';
        pointRuleCriteriaList[3].Field_Value__c             = projectList[0].Id;
        pointRuleCriteriaList[3].Operator__c                = '=';

        pointRuleCriteriaList[4].Field_API_Name__c          = 'CreatedDate';
        pointRuleCriteriaList[4].Field_Value__c             = '13/07/2017 11:46:01';
        pointRuleCriteriaList[4].Operator__c                = '>=';

        pointRuleCriteriaList[5].Field_API_Name__c          = 'CreatedDate';
        pointRuleCriteriaList[5].Field_Value__c             = 'LastModifiedDate';
        pointRuleCriteriaList[5].Operator__c                = '<=';

        pointRuleCriteriaList[9].Field_API_Name__c          = 'CreatedDate';
        pointRuleCriteriaList[9].Field_Value__c             = 'LastModifiedDate';
        pointRuleCriteriaList[9].Operator__c                = '>=';

        pointRuleCriteriaList[10].Field_API_Name__c         = 'CreatedDate';
        pointRuleCriteriaList[10].Field_Value__c            = 'LastModifiedDate';
        pointRuleCriteriaList[10].Operator__c               = '=';

        pointRuleCriteriaList[11].Field_API_Name__c         = 'CreatedDate';
        pointRuleCriteriaList[11].Field_Value__c            = 'LastModifiedDate';
        pointRuleCriteriaList[11].Operator__c               = '<';

        pointRuleCriteriaList[12].Field_API_Name__c         = 'CreatedDate';
        pointRuleCriteriaList[12].Field_Value__c            = 'LastModifiedDate';
        pointRuleCriteriaList[12].Operator__c               = '>';

        pointRuleCriteriaList[12].Field_API_Name__c         = 'CreatedDate';
        pointRuleCriteriaList[12].Field_Value__c            = 'LastModifiedDate';
        pointRuleCriteriaList[12].Operator__c               = '!=';

        pointRuleCriteriaList[6].Field_API_Name__c          = 'Status_Notes__c';
        pointRuleCriteriaList[6].Field_Value__c             = 'Story_Name__c';
        pointRuleCriteriaList[6].Operator__c                = '>=';

        pointRuleCriteriaList[7].Field_API_Name__c          = 'Status_Notes__c';
        pointRuleCriteriaList[7].Field_Value__c             = 'Story_Name__c';
        pointRuleCriteriaList[7].Operator__c                = '<=';

        pointRuleCriteriaList[8].Field_API_Name__c          = 'Status_Notes__c';
        pointRuleCriteriaList[8].Field_Value__c             = 'Story_Name__c';
        pointRuleCriteriaList[8].Operator__c                = '>';

        pointRuleCriteriaList[13].Field_API_Name__c         = 'Status_Notes__c';
        pointRuleCriteriaList[13].Field_Value__c            = 'Story_Name__c';
        pointRuleCriteriaList[13].Operator__c               = '=';

        pointRuleCriteriaList[14].Field_API_Name__c         = 'Status_Notes__c';
        pointRuleCriteriaList[14].Field_Value__c            = 'Story_Name__c';
        pointRuleCriteriaList[14].Operator__c               = '!=';

        pointRuleCriteriaList[15].Field_API_Name__c         = 'Status_Notes__c';
        pointRuleCriteriaList[15].Field_Value__c            = 'Story_Name__c';
        pointRuleCriteriaList[15].Operator__c               = '<';

        pointRuleCriteriaList[16].Field_API_Name__c         = 'Delivery_Owner__c';
        pointRuleCriteriaList[16].Field_Value__c            = 'Functional_Owner__c';
        pointRuleCriteriaList[16].Operator__c               = '>=';

        pointRuleCriteriaList[17].Field_API_Name__c         = 'Delivery_Owner__c';
        pointRuleCriteriaList[17].Field_Value__c            = 'Functional_Owner__c';
        pointRuleCriteriaList[17].Operator__c               = '<=';

        pointRuleCriteriaList[18].Field_API_Name__c         = 'Delivery_Owner__c';
        pointRuleCriteriaList[18].Field_Value__c            = 'Functional_Owner__c';
        pointRuleCriteriaList[18].Operator__c               = '>';

        pointRuleCriteriaList[19].Field_API_Name__c         = 'Delivery_Owner__c';
        pointRuleCriteriaList[19].Field_Value__c            = 'Functional_Owner__c';
        pointRuleCriteriaList[19].Operator__c               = '=';

        pointRuleCriteriaList[20].Field_API_Name__c         = 'Delivery_Owner__c';
        pointRuleCriteriaList[20].Field_Value__c            = 'Functional_Owner__c';
        pointRuleCriteriaList[20].Operator__c               = '!=';

        pointRuleCriteriaList[21].Field_API_Name__c         = 'Delivery_Owner__c';
        pointRuleCriteriaList[21].Field_Value__c            = 'Functional_Owner__c';
        pointRuleCriteriaList[21].Operator__c               = '<';

        pointRuleCriteriaList[22].Field_API_Name__c         = 'Level_of_Effort__c';
        pointRuleCriteriaList[22].Field_Value__c            = 'Total_Hours_Logged__c';
        pointRuleCriteriaList[22].Operator__c               = '>=';

        pointRuleCriteriaList[23].Field_API_Name__c         = 'Level_of_Effort__c';
        pointRuleCriteriaList[23].Field_Value__c            = 'Total_Hours_Logged__c';
        pointRuleCriteriaList[23].Operator__c               = '<=';

        pointRuleCriteriaList[24].Field_API_Name__c         = 'Level_of_Effort__c';
        pointRuleCriteriaList[24].Field_Value__c            = 'Total_Hours_Logged__c';
        pointRuleCriteriaList[24].Operator__c               = '>';

        pointRuleCriteriaList[25].Field_API_Name__c         = 'Level_of_Effort__c';
        pointRuleCriteriaList[25].Field_Value__c            = 'Total_Hours_Logged__c';
        pointRuleCriteriaList[25].Operator__c               = '=';

        pointRuleCriteriaList[26].Field_API_Name__c         = 'Level_of_Effort__c';
        pointRuleCriteriaList[26].Field_Value__c            = 'Total_Hours_Logged__c';
        pointRuleCriteriaList[26].Operator__c               = '!=';

        pointRuleCriteriaList[27].Field_API_Name__c         = 'Level_of_Effort__c';
        pointRuleCriteriaList[27].Field_Value__c            = 'Total_Hours_Logged__c';
        pointRuleCriteriaList[27].Operator__c               = '<';


        pointRuleCriteriaList[28].Field_API_Name__c          = 'Created_On_Heroku__c';
        pointRuleCriteriaList[28].Field_Value__c             = 'Delete_on_Heroku__c';
        pointRuleCriteriaList[28].Operator__c                = '>=';

        pointRuleCriteriaList[29].Field_API_Name__c          = 'Created_On_Heroku__c';
        pointRuleCriteriaList[29].Field_Value__c             = 'Delete_on_Heroku__c';
        pointRuleCriteriaList[29].Operator__c                = '<=';

        pointRuleCriteriaList[30].Field_API_Name__c          = 'Created_On_Heroku__c';
        pointRuleCriteriaList[30].Field_Value__c             = 'Delete_on_Heroku__c';
        pointRuleCriteriaList[30].Operator__c                = '>';

        pointRuleCriteriaList[31].Field_API_Name__c          = 'Created_On_Heroku__c';
        pointRuleCriteriaList[31].Field_Value__c             = 'Delete_on_Heroku__c';
        pointRuleCriteriaList[31].Operator__c                = '=';

        pointRuleCriteriaList[32].Field_API_Name__c          = 'Created_On_Heroku__c';
        pointRuleCriteriaList[32].Field_Value__c             = 'Delete_on_Heroku__c';
        pointRuleCriteriaList[32].Operator__c                = '!=';

        pointRuleCriteriaList[33].Field_API_Name__c          = 'Created_On_Heroku__c';
        pointRuleCriteriaList[33].Field_Value__c             = 'Delete_on_Heroku__c';
        pointRuleCriteriaList[33].Operator__c                = '<';

        pointRuleCriteriaList[34].Field_API_Name__c          = 'CreatedDate';
        pointRuleCriteriaList[34].Field_Value__c             = 'CreatedDate';
        pointRuleCriteriaList[34].Operator__c                = '<=';

        pointRuleCriteriaList[35].Field_API_Name__c          = 'CreatedDate';
        pointRuleCriteriaList[35].Field_Value__c             = 'CreatedDate';
        pointRuleCriteriaList[35].Operator__c                = '>=';

        pointRuleCriteriaList[36].Field_API_Name__c          = 'CreatedDate';
        pointRuleCriteriaList[36].Field_Value__c             = 'CreatedDate';
        pointRuleCriteriaList[36].Operator__c                = '=';

        pointRuleCriteriaList[37].Field_API_Name__c          = 'CreatedDate';
        pointRuleCriteriaList[37].Field_Value__c             = 'CreatedDate';
        pointRuleCriteriaList[37].Operator__c                = '<';

        pointRuleCriteriaList[38].Field_API_Name__c          = 'CreatedDate';
        pointRuleCriteriaList[38].Field_Value__c             = 'CreatedDate';
        pointRuleCriteriaList[38].Operator__c                = '>';

        pointRuleCriteriaList[39].Field_API_Name__c          = 'CreatedDate';
        pointRuleCriteriaList[39].Field_Value__c             = 'CreatedDate';
        pointRuleCriteriaList[39].Operator__c                = '!=';

        pointRuleCriteriaList[41].Field_API_Name__c          = 'Project__c';
        pointRuleCriteriaList[41].Field_Value__c             = 'Project__c';
        pointRuleCriteriaList[41].Operator__c                = '<=';

        pointRuleCriteriaList[42].Field_API_Name__c          = 'Project__c';
        pointRuleCriteriaList[42].Field_Value__c             = 'Project__c';
        pointRuleCriteriaList[42].Operator__c                = '>=';

        pointRuleCriteriaList[43].Field_API_Name__c          = 'Project__c';
        pointRuleCriteriaList[43].Field_Value__c             = 'Project__c';
        pointRuleCriteriaList[43].Operator__c                = '=';

        pointRuleCriteriaList[44].Field_API_Name__c          = 'Project__c';
        pointRuleCriteriaList[44].Field_Value__c             = 'Project__c';
        pointRuleCriteriaList[44].Operator__c                = '<';

        pointRuleCriteriaList[45].Field_API_Name__c          = 'Project__c';
        pointRuleCriteriaList[45].Field_Value__c             = 'Project__c';
        pointRuleCriteriaList[45].Operator__c                = '>';

        pointRuleCriteriaList[46].Field_API_Name__c          = 'Project__c';
        pointRuleCriteriaList[46].Field_Value__c             = 'Project__c';
        pointRuleCriteriaList[46].Operator__c                = '!=';

        insert pointRuleCriteriaList ;

        List<Points__c> pointsList                           = TestDataFactory_Points.generatePoints(storyList[0].Id, contactList[0].Id, 20, pointRuleList[0].Id, 1);
        insert pointsList;

        Test.startTest();
            GrantPointsBatchScheduler gpbs = new GrantPointsBatchScheduler();
            gpbs.execute(null);
            System.assertEquals(storyList.size(), 2);
        Test.stopTest();
    }


    @isTest static void test_GrantPointsBatch_two() 
    {
        List<Story__c> storyList            = [SELECT Id FROM Story__c];
        List<Project__c> projectList        = [SELECT Id from Project__c limit 1];
        List<Contact> contactList           = [SELECT Id from Contact limit 1];
        Id systemRecordTypeId               = Schema.SObjectType.Points_Rule__c.RecordTypeInfosByName.get('System Generated').RecordTypeId;
        List<Points_Rule__c> pointRuleList  = TestDataFactory_PointRules.generatePointRules(true, 'AND', 'Assigned_To_User__r.ContactId', 'Task__c', 10, systemRecordTypeId, 1);
        insert pointRuleList ;

        List<Points_Rule_Criteria__c> pointRuleCriteriaList = TestDataFactory_PointsRuleCriteria.generatePointRuleCriteria('Status__c', 'Completed', '=', pointRuleList[0].Id, 10);
        
        pointRuleCriteriaList[0].Field_API_Name__c          = 'Due_Date__c';
        pointRuleCriteriaList[0].Field_Value__c             = '13/07/2017';
        pointRuleCriteriaList[0].Operator__c                = '>=';

        pointRuleCriteriaList[1].Field_API_Name__c          = 'Due_Date__c';
        pointRuleCriteriaList[1].Field_Value__c             = 'Estimated_Completion_Date__c';
        pointRuleCriteriaList[1].Operator__c                = '<=';

        pointRuleCriteriaList[2].Field_API_Name__c          = 'Due_Date__c';
        pointRuleCriteriaList[2].Field_Value__c             = 'Estimated_Completion_Date__c';
        pointRuleCriteriaList[2].Operator__c                = '>=';

        pointRuleCriteriaList[3].Field_API_Name__c          = 'Due_Date__c';
        pointRuleCriteriaList[3].Field_Value__c             = 'Estimated_Completion_Date__c';
        pointRuleCriteriaList[3].Operator__c                = '=';

        pointRuleCriteriaList[4].Field_API_Name__c          = 'Due_Date__c';
        pointRuleCriteriaList[4].Field_Value__c             = 'Estimated_Completion_Date__c';
        pointRuleCriteriaList[4].Operator__c                = '<';

        pointRuleCriteriaList[5].Field_API_Name__c          = 'Due_Date__c';
        pointRuleCriteriaList[5].Field_Value__c             = 'Estimated_Completion_Date__c';
        pointRuleCriteriaList[5].Operator__c                = '>';

        pointRuleCriteriaList[6].Field_API_Name__c          = 'Due_Date__c';
        pointRuleCriteriaList[6].Field_Value__c             = 'Estimated_Completion_Date__c';
        pointRuleCriteriaList[6].Operator__c                = '!=';

        insert pointRuleCriteriaList ;

        List<Points__c> pointsList                          = TestDataFactory_Points.generatePoints(storyList[0].Id, contactList[0].Id, 20, pointRuleList[0].Id, 1);
        insert pointsList;

        Test.startTest();
            GrantPointsBatchScheduler gpbs = new GrantPointsBatchScheduler();
            gpbs.execute(null);
            System.assertEquals(storyList.size(), 2);
        Test.stopTest();
    }


    @isTest static void test_GrantPointsBatch_three() 
    {
        List<Story__c> storyList            = [SELECT Id FROM Story__c];
        List<Project__c> projectList        = [SELECT Id from Project__c limit 1];
        List<Contact> contactList           = [SELECT Id from Contact limit 1];
        Id systemRecordTypeId               = Schema.SObjectType.Points_Rule__c.RecordTypeInfosByName.get('System Generated').RecordTypeId;
        List<Points_Rule__c> pointRuleList  = TestDataFactory_PointRules.generatePointRules(true, 'AND', 'Assigned_To_User__r.ContactId', 'Task__c', 10, systemRecordTypeId, 1);
        insert pointRuleList ;

        List<Points_Rule_Criteria__c> pointRuleCriteriaList = TestDataFactory_PointsRuleCriteria.generatePointRuleCriteria('Status__c', 'Completed', '=', pointRuleList[0].Id, 1);
        
        pointRuleCriteriaList[0].Field_API_Name__c          = 'Due_Date__c';
        pointRuleCriteriaList[0].Field_Value__c             = 'Estimated_Completion_Date__c';
        pointRuleCriteriaList[0].Operator__c                = '<=';

        insert pointRuleCriteriaList ;

        List<Points__c> pointsList                          = TestDataFactory_Points.generatePoints(storyList[0].Id, contactList[0].Id, 20, pointRuleList[0].Id, 1);
        insert pointsList;

        Test.startTest();
            GrantPointsBatchScheduler gpbs = new GrantPointsBatchScheduler();
            gpbs.execute(null);
            System.assertEquals(storyList.size(), 2);
        Test.stopTest();
    }
}