/**
@Name          : TimecardGridController_Test
@Dated         : 
@Author        :
@Description   : This is used to test TimecardGridController . 
*/
@isTest
public class TimecardGridController_Test {

    @isTest
    public static void unitTest(){
    
        test.startTest();
            List<User> userList = TestDataFactory_Users.generateUsersWith10KDeliveryPartnerProfile(true,1);
            insert userList;
            List<Contact> contactList = [SELECT Id, AccountId 
                                           FROM Contact 
                                           WHERE Id =: userList[0].ContactId];                       
            
            Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
            List<agreement__C> agreementList = TestDataFactory_Agreements.generateAgreements('Test Agreement', contactList[0].AccountId,
                                                                                             Constants.RECORDTYPEID_AGREEMENT_RETAINER, 'Active', 
                                                                                             Date.newInstance(System.Today().Year(), System.Today().Month() - 1, 1), 
                                                                                             Date.newInstance(System.Today().Year() + 1, System.Today().Month() - 1, 1), 1) ;
            agreementList[0].Rate_Structure__c = 'Monthly';
            insert agreementList;

            List<Rate__c> ratelist = TestDataFactory_Rates.generateRateForAgreement(agreementList[0].Id, Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS, 
                                                                                    Constants.ROLE_CONSULTANT, 100, 1);
            insert ratelist;
            
            List<Project__c> projectList = TestDataFactory_Projects.generateProjects(contactList[0].AccountId, 'Test Project', 1);
            insert projectList;

            List<Assignment__c> assignmentList = TestDataFactory_Assignments.generateAssignments(projectList[0].id, userList[0].ContactId, rateList[0].Id, 'Active', Constants.ROLE_CONSULTANT, Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS, true, 8, 2);
            assignmentList[1].Start_Date__c = assignmentList[1].Start_Date__c.addYears(1).addDays(7);
            assignmentList[1].End_Date__c   = assignmentList[1].End_Date__c.addYears(1).addDays(7);
            insert assignmentList ;
            System.runAs(userList[0]){

                List<Time_Entry__c> timeEntryLst = TestDataFactory_TimeEntries.generateTimeEntries(assignmentList[0].id, 'Test Description', System.today(), 2, 2);
                
                List<Assignment__c> lstactiveAss = TimecardGridController.getActiveAssignment(System.today());
                TimecardGridController.AssigAndTimeWrapper obj ;
                List<Story__c> storyRecList = TestDataFactory_Stories.generateStories('Test', projectList[0].Id, 'Draft', 'Medium', 1);
                storyRecList[0].Functional_Owner__c = userList[0].Id;
                storyRecList[0].Delivery_Owner__c = userList[0].Id;
                insert storyRecList;

                List<Task__c> taskRecList = TestDataFactory_Tasks.generateTasks('Test Task', 'Draft', storyRecList[0].Id,'Medium', 1);
                insert taskRecList;

                    Date today = TimecardGridController.getToDayDate();
                    TimecardGridController.getwrapp(String.valueOf(today.day()),String.valueOf(today.month()),String.valueOf(today.year()));
                    //TimecardGridController.submitSave(timeEntryLst);
                    System.assertNotEquals((TimecardGridController.getUserStories(projectList[0].Id)).size(), 0);
                    TimecardGridController.getStoryTasks(storyRecList[0].Id);
            }
        test.stopTest();
    }
}