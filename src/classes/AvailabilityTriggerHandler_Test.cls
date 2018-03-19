@isTest
public with sharing class AvailabilityTriggerHandler_Test {
	
	@isTest static void test_method_one() {
        Test.startTest();
        //Crating Instance of TestDataFactory
        TestDataFactory obj = new TestDataFactory();

        //Inserting Accounts Records By using TestDataFactory
        List<Account> accList = obj.generateAccounts(5);
        insert accList;

        //Inserting Contacts Records By using TestDataFactory
        List<Contact> conList = obj.generateContactsForAccounts(accList,5);
        insert conList;

        //Inserting Week__c Records 
        List<Week__c> weekList = new List<Week__c>();
            for(Integer i = 0; i < 5 ; i++) {
                weekList.add(new Week__c(Name = 'Week ' + i));
            }
        insert weekList;

        //Inserting Availability__c Records 
        List<Availability__c> availabilityList = new List<Availability__c>();
            for(Integer i = 0; i < 5 ; i++) {
                availabilityList.add(new Availability__c( Available_Hours__c = 0, Week__c = weekList[0].Id , Contact__c = conList[0].Id));
            }
        insert availabilityList;

        //Inserting Project__c Records
        List<Project__c> projectList = new List<Project__c>();
            for(Integer i = 0; i < 5 ; i++) {
                projectList.add(new Project__c(Name = 'TestProject ' + i));           
            }
        insert projectList;
        //Inserting Assignment__c Records By using TestDataFactory 
        List<Assignment__c> assignmentList = obj.generateAssignment(projectList[0].Id, 'Time & Materials', 5);
        insert assignmentList;

        //Inserting Budget__c Records
        List<Budget__c> budgetList = new List<Budget__c>();
            for(Integer i = 0; i < 5 ; i++) {
                budgetList.add(new Budget__c(Forecasted_Hours__c = 5 , Hours_Worked__c = 5, Availability__c = availabilityList[1].Id ,Assignment__c = assignmentList[0].Id,  Week__c = weekList[0].Id ));           
            }
        insert budgetList;
        if(availabilityList.size() > 0) {
            availabilityList[0].Available_Hours__c = 10;
            availabilityList[0].Week__c = null ;
        }    
        update availabilityList;
        if(availabilityList.size() > 0) {
            availabilityList[0].Available_Hours__c = 10;
            availabilityList[0].Week__c = weekList[2].Id ;
        }    
        update availabilityList;
        Test.stopTest();

    }
}