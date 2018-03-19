@isTest
public class AssignmentTriggerHandler_Test{

    @isTest
    public static void InsertAssignmentTest(){
    
        List<User> userList = TestDataFactory_Users.generateUsersWith10KCustomerProfile(true,2) ;
        insert userList;
        //Fetch the Contact that is associated with our Community Contact that was inserted
        List<Contact> contactList = [SELECT Id, AccountId 
                                       FROM Contact 
                                       WHERE Id =: userList[0].ContactId or Id=: userList[1].ContactId];
                       
        system.assertEquals(contactList.size(),2);
        
        List<Project__c> projectList = TestDataFactory_Projects.generateProjects(contactList[0].AccountId, 'Test Project', 1);
        insert projectList;
        
        List<agreement__C> agreementList = TestDataFactory_Agreements.generateAgreements('Test Agreement', contactList[0].AccountId,
                                                                                             Constants.RECORDTYPEID_AGREEMENT_RETAINER, 'Active', 
                                                                                             Date.newInstance(System.Today().Year(), System.Today().Month() - 1, 1), 
                                                                                             Date.newInstance(System.Today().Year() + 1, System.Today().Month() - 1, 1), 1) ;
        agreementList[0].Rate_Structure__c = 'Monthly';
        insert agreementList;

        List<Rate__c> ratelist = TestDataFactory_Rates.generateRateForAgreement(agreementList[0].Id, Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS, 
                                                                                    Constants.ROLE_CONSULTANT, 100, 1);
        insert ratelist;

        List<Assignment__c> assignmentList = TestDataFactory_Assignments.generateAssignments(projectList[0].id, contactList[0].id, rateList[0].Id, 
                                                        'Active', Constants.ROLE_DEVELOPER, 
                                                        Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS,  true, 4, 
                                                        2);
        assignmentList[1].Start_Date__c = assignmentList[1].Start_Date__c.addYears(1).addDays(7);
        assignmentList[1].End_Date__c = assignmentList[1].End_Date__c.addYears(1).addDays(7);
         
        insert assignmentList ;
        //verify sharing inserted
        system.assert([select id from project__share where parentId =: projectList[0].id and userOrGroupId =:userList[0].id].size()>0);
        
        //updating contact
        assignmentList[0].resource__c = contactList[1].id;
        assignmentList[0].Status__c = 'Closed';
        update assignmentList;
        assignmentList[0].Status__c = 'Active';
        update assignmentList;
        projectList[0].Status__c = 'Completed';
        update projectList;
        delete assignmentList ;
        //verify sharing deleted
        system.assertEquals([select id from project__share where parentId =: projectList[0].id and userOrGroupId =: userList[1].id].size(),0);
     
        undelete assignmentList; 
        
       // verify recreation of sharing.
        system.assert([select id from project__share where parentId =: projectList[0].id and userOrGroupId =: userList[1].id].size()>0);
     
    }
    
    @isTest
    private static void preventRateChangeIfTimeEntryExistTest() {
        TestDataFactory factory = new TestDataFactory();
        
        List<User> userList = TestDataFactory_Users.generateUsersWith10KCustomerProfile(true,2) ;
        List<Contact> contactList = [SELECT Id, AccountId 
                                       FROM Contact 
                                       WHERE Id =: userList[0].ContactId or Id=: userList[1].ContactId];
                       
        system.assertEquals(contactList.size(),2);
        List<Project__c> projectList = TestDataFactory_Projects.generateProjects(contactList[0].AccountId, 'Test Project', 1);
        projectList[0].Start_Date__c = System.today().addDays(-2);
        projectList[0].End_Date__c = System.today().addDays(5).addYears(10);
        projectList[0].Status__c = 'Open';
        insert projectList;
        List<agreement__C> agreementList = TestDataFactory_Agreements.generateAgreements('Test Agreement', contactList[0].AccountId,
                                                                                             Constants.RECORDTYPEID_AGREEMENT_RETAINER, 'Active', 
                                                                                             Date.newInstance(System.Today().Year(), System.Today().Month() - 1, 1), 
                                                                                             Date.newInstance(System.Today().Year() + 1, System.Today().Month() - 1, 1), 1) ;
        agreementList[0].Rate_Structure__c = 'Monthly';
        insert agreementList;

        List<Opportunity> oppList =TestDataFactory_Opportunity.generateOpportunities(contactList[0].AccountId, Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('MSA Opportunity').getRecordTypeId(), 'Qualification', Date.today().addDays(6), Date.today(), Date.today().addDays(4), 1);
        insert oppList ;

        List<Opportunity> oppList_two =TestDataFactory_Opportunity.generateOpportunities(contactList[0].AccountId, Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Services Opportunity').getRecordTypeId(), 'Qualification', Date.today().addDays(6), Date.today(), Date.today().addDays(4), 1);
        oppList_two[0].MSA_Opportunity__c = oppList[0].Id ;
        insert oppList_two ;

        List<Agreement__c> agreementList_two = TestDataFactory_Agreements.generateAgreements('Test Agreement', contactList[0].AccountId, Schema.SObjectType.Agreement__c.getRecordTypeInfosByName().get('MSA').getRecordTypeId(), 'Active', Date.today(), Date.today().addDays(6), 1);
        agreementList_two[0].Opportunity__c = oppList[0].Id ;
        insert agreementList_two;

        List<Rate__c> ratelist = TestDataFactory_Rates.generateRateForAgreement(agreementList[0].Id, Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS, 
                                                                                    Constants.ROLE_CONSULTANT, 100, 2);
        ratelist[1].Assignment_Type__c = Constants.ASSIGNMENTTYPE_RETAINEDCAPACITY;
        ratelist[1].Role__c = Constants.ROLE_DEVELOPER;
        ratelist[1].Hourly_Rate__c = 12;
        ratelist[1].RecordTypeId = Constants.RECORDTYPEID_RATE_RETAINED_CAPACITY;
        insert ratelist;
        List<Assignment__c> assignmentList = TestDataFactory_Assignments.generateAssignments(projectList[0].id, contactList[0].id, rateList[0].Id, 
                                                        'Active', Constants.ROLE_DEVELOPER, 
                                                        Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS,  true, 4, 
                                                        2);
        Integer i=0;
        for(assignment__c assignment :assignmentList) {
            assignment.Start_Date__c = Date.today().addDays(i).addYears(i);
            assignment.End_Date__c  = assignment.Start_Date__c.addDays(-i).addYears(i+1);
            assignment.Cost_Rate__c = ratelist[0].Id; 
            assignment.Planned_Hours__c = 100; 
            assignment.Rate__c = ratelist[1].Id; 
            assignment.Project__c = projectList[0].Id;
            assignment.Role__c = Constants.ROLE_DEVELOPER;
            assignment.Resource__c = contactList[0].Id;
            i++; 
        }
        insert assignmentList ;

        List<Assignment__c> assignmentNewList = TestDataFactory_Assignments.generateAssignments(projectList[0].id, contactList[0].id, rateList[0].Id, 
                                                        'Active', Constants.ROLE_DEVELOPER, 
                                                        Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS,  true, 4, 
                                                        1);
        i = i + 1 ;
        for(assignment__c newAssignment :assignmentNewList) {
            
          newAssignment.Start_Date__c = assignmentList[1].End_Date__c.addDays(i).addYears(i);
          newAssignment.End_Date__c  = newAssignment.Start_Date__c.addYears(i+1);
          newAssignment.Cost_Rate__c = ratelist[0].Id; 
          newAssignment.Planned_Hours__c = 100; 
          newAssignment.Rate__c = ratelist[1].Id; 
          newAssignment.Project__c = projectList[0].Id;
          newAssignment.Role__c = Constants.ROLE_DEVELOPER;
          newAssignment.Resource__c = contactList[0].Id;
          i++; 
        }
        insert assignmentNewList ;

        List<time_entry__c> timeEntries = new List<time_entry__c>(); 
        i=0;
        for(assignment__c assignment :assignmentList) {
            assignment.Cost_Rate__c = ratelist[1].Id;
            timeEntries.addAll(TestDataFactory_TimeEntries.generateTimeEntries(assignment.Id, 
                            'Test Time Entries', (assignment.Start_Date__c.addDays(1)), 4, 1));  
        }
        insert timeEntries;
        /*Database.SaveResult[] srList = Database.update(assignmentList, false);
        for(Database.SaveResult result :srList)
            System.assertEquals(false, result.isSuccess()); 
        
        for(assignment__c assignment :assignmentList) {
          assignment.Rate__c = ratelist[0].Id;
          assignment.Planned_Hours__c += 10;
        }        
        srList = Database.update(assignmentList, false);
        for(Database.SaveResult result :srList)
            System.assertEquals(false, result.isSuccess()); */
    }
}