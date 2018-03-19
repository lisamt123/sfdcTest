global with sharing class SandboxRefreshUtility implements SandboxPostCopy
{
	global void runApexClass(SandboxContext context) 
	{
		List<Lead> leadList = new List<Lead>();
		for(Lead l : [SELECT Id, Email FROM Lead WHERE Email != null]) 
		{
		    l.Email = 'matt@10kview.com';
		    leadList.add(l);
		}
		update leadList;

		List<Contact> contactList = new List<Contact>();
		for(Contact con : [SELECT Id, Email, Other_Email__c FROM Contact WHERE Email != null OR Other_Email__c != null]) 
		{
		    if(con.Email != null) {
		        con.Email = 'matt@10kview.com';
		    }
		    if(con.Other_Email__c != null) {
		        con.Other_Email__c = 'matt@10kview.com';
		    }
		    contactList.add(con);
		}
		update contactList;

		List<Account> accountList = new List<Account>();
		for(Account acc : [SELECT Id, Additional_Invoice_Recipients__c FROM Account WHERE Additional_Invoice_Recipients__c != null]) 
		{
		    acc.Additional_Invoice_Recipients__c = 'becky@10kview.com';
		    accountList.add(acc);
		}
		update accountList;

		List<Agreement__c> agreementList = new List<Agreement__c>();
		for(Agreement__c agreement : [SELECT Id, Additional_Invoice_Recipients__c FROM Agreement__c WHERE Additional_Invoice_Recipients__c != null]) 
		{
		    agreement.Additional_Invoice_Recipients__c = 'becky@10kview.com';
		    agreementList.add(agreement);
		}
		update agreementList;
	}
}