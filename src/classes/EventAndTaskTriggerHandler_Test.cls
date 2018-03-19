@isTest
public with sharing class EventAndTaskTriggerHandler_Test {
	@testSetup static void setupData() {
        TestDataFactory factory = new TestDataFactory();
        
        List<Account> accountList = factory.generateAccounts(1);
        insert accountList;
        
        List<Contact> contactList = factory.generateContactsForAccounts(accountList, 1);
        insert contactList;
       
    }  
    static testMethod void testTaskAttachments()
    {
    	List<Contact> contactList= [SELECT Id FROM Contact];
    	
    	Test.startTest();
	    	Task newTask = new Task();
	    	newTask.whoId = contactList[0].Id;
	    	newTask.Subject = 'call';
	    	//newTask.AssignedToId = UserInfo.getUserId();
	    	newTask.Priority = 'High';
	    	newTask.Status = 'Open';
	    	insert newTask;
	        System.assertEquals(true, newTask != null);
	    Test.stopTest();
    }
    static testMethod void testEventAttachments()
    {
    	List<Contact> contactList= [SELECT Id FROM Contact];
  
    	Test.startTest();
	    	Event newEvent = new Event();
	    	newEvent.whoId = contactList[0].Id;
	    	newEvent.Subject = 'call';
	    	//newEvent.AssignedToId = UserInfo.getUserId();
	    	newEvent.StartDateTime = DateTime.now();
	    	newEvent.EndDateTime =  DateTime.now();
	    	insert newEvent;
	        System.assertEquals(true, newEvent != null);
	    Test.stopTest();
    }
}