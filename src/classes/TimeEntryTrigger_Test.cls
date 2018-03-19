@IsTest
public class TimeEntryTrigger_Test{
    static testMethod void test_usecase_one() {
        Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
                                                            'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                            'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
                                                            null, 'Net 30', 'test@test.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
                                                            1);
        insert accList;
        
        List<Contact> contactList = TestDataFactory_Contacts.generatecontacts(accList, 'Test contact', 'lastName', '', '', 1);
        insert contactList;
        
        List<Project__c> projectList = TestDataFactory_Projects.generateProjects(accList[0].Id, 'Test Project', 1);
        insert projectList;
        
        List<Assignment__c> assignmentList = TestDataFactory_Assignments.generateAssignments(projectList[0].Id, contactList[0].Id, null, 'Active', 'Developer', 'Named Resource', true, 250, 1);
        insert assignmentList;
        
        List<Story__c> storyList = TestDataFactory_Stories.generateStories('testStory', projectList[0].id,'Draft','Medium',1);
        storyList[0].Level_of_Effort__c=10;
        insert storyList;
        
        List<Task__c> taskRecList = TestDataFactory_Tasks.generateTasks('Test Task', 'Draft', storyList[0].Id,'Medium', 1);
                insert taskRecList;
                
        Test.startTest();
            
            
            List<Time_Entry__c> timeEntriesList = TestDataFactory_TimeEntries.generateTimeEntries(assignmentList[0].Id, 'Test', system.today().addDays(10), 8, 2);
            timeEntriesList[0].Story__c = storyList[0].Id;
            timeEntriesList[0].Task__c = taskRecList[0].Id;
            insert timeEntriesList;
            
            timeEntriesList[0].Hours__c = 5;
            update timeEntriesList;
            
            timeEntriesList[0].Date__c = system.today().addDays(310);
            update timeEntriesList;
            
            delete timeEntriesList;
            
            undelete timeEntriesList;
        Test.stopTest();
    }
}