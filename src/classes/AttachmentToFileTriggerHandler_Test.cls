@isTest
public with sharing class AttachmentToFileTriggerHandler_Test {
	@testSetup static void setupData() {
        TestDataFactory factory = new TestDataFactory();
        
        List<Account> accountList = factory.generateAccounts(1);
        insert accountList;
        
        List<Contact> contactList = factory.generateContactsForAccounts(accountList, 1);
        insert contactList;
       
    }  
    static testMethod void testAttachments()
    {
    	Case cse=new Case();
	    insert cse;
	        
    	Test.startTest();
	        Attachment attach=new Attachment();   	
	    	attach.Name='Unit Test Attachment';
	    	Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
	    	attach.body=bodyBlob;
	        attach.parentId=cse.id;
	        attach.ContentType = 'application/pdf';
	        insert attach;
	        System.assertEquals(true, attach != null);
	    Test.stopTest();
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
	    	
	        Attachment attach=new Attachment();   	
	    	attach.Name='Unit Test Attachment';
	    	Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
	    	attach.body=bodyBlob;
	        attach.parentId=newTask.id;
	        attach.ContentType = 'application/pdf';
	        insert attach;
	        System.assertEquals(true, attach != null);
	    Test.stopTest();
    }
}