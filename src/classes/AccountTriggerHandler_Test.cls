@isTest
private class AccountTriggerHandler_Test 
{
	/*@isTest static void test_AccountTriggerHandler() 
	{
		TestDataFactory factory = new TestDataFactory();   
        
        List<Account> accList = factory.generateAccounts(1);
        insert accList;
        Test.startTest();
        	List<Account> accountList = [SELECT Id FROM Account];
        	System.assertEquals(accountList.size(),1);
        Test.stopTest();
	}*/
	
	//
    static testMethod void test_usecase_one() {
    	List<Countries_Regions_Continents_ISO_Codes__c> countriesRegionsContinentsISOCodesList = TestDataFactory_CustomSettings.generateCountriesRegionsContinentsISOCodes('Americas', 'United States', 'US', 'USA', 'North America', 1);
        insert countriesRegionsContinentsISOCodesList;
        
        Id deliveryPartnerrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Delivery Partner').RecordTypeId;
        
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(deliveryPartnerrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
    														'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
    														'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
    														null, 'Net 30', 'test@test.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', null,
    														1);
    	accList.addAll(TestDataFactory_Accounts.generateAccounts(deliveryPartnerrecordTypeId, 'Test2', 'Prospect', 15, 'code coverage', 'internal',
    														'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
    														'code quality with code coverage above 75%', 'NDA aggrement', 'Australia', '501 test street', 'test city', 'Victoria', '90001', null,
    														null, 'Net 30', 'test@test.com', 'Test-7', 'HELLO WORLD', 'invoicingNotes',null,
    														1));													
        insert accList;
        Test.startTest();
        	List<Countries_Regions_Continents_ISO_Codes__c> crcList = [SELECT Id,Region__c FROM Countries_Regions_Continents_ISO_Codes__c];
        	System.assertEquals(crcList.size(),1);
        	
        	List<Account> accountList = [SELECT Id,Region_Picklist__c,Account_Record_Type__c,RecordTypeId FROM Account WHERE Id=:accList[0].Id];
        	System.assertEquals(accountList.size(),1);
        	//If reason found in Countries_Regions_Continents_ISO_Codes__c custom setting
        	System.assertEquals(countriesRegionsContinentsISOCodesList[0].Region__c,accountList[0].Region_Picklist__c);
        	
        	accountList = [SELECT Id,Region_Picklist__c,Account_Record_Type__c,RecordTypeId FROM Account WHERE Id=:accList[1].Id];
        	System.assertEquals(accountList.size(),1);
        	System.assertNotEquals(countriesRegionsContinentsISOCodesList[0].Region__c,accountList[0].Region_Picklist__c);
        Test.stopTest();
    }
    
    static testMethod void test_usecase_two() {
        
        Id deliveryPartnerrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Delivery Partner').RecordTypeId;
        Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(deliveryPartnerrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
    														'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
    														'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
    														null, 'Net 30', 'test@test.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
    														1);												
        insert accList;
        Test.startTest();
        	List<Account> accountList = [SELECT Id,Region_Picklist__c,Account_Record_Type__c,RecordTypeId FROM Account WHERE Id=:accList[0].Id];
        	System.assertEquals(accountList.size(),1);
        	//If reason found in Countries_Regions_Continents_ISO_Codes__c custom setting
        	System.assertEquals(partnerClientrecordTypeId,accountList[0].RecordTypeId);
        Test.stopTest();
    }
    
    static testMethod void test_usecase_three() {
        
        Id deliveryPartnerrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Delivery Partner').RecordTypeId;
        Id directClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Direct Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(deliveryPartnerrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
    														'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
    														'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
    														null, 'Net 30', 'test@test.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Direct Client',
    														1);												
        insert accList;
        Test.startTest();
        	List<Account> accountList = [SELECT Id,Region_Picklist__c,Account_Record_Type__c,RecordTypeId FROM Account WHERE Id=:accList[0].Id];
        	System.assertEquals(accountList.size(),1);
        	//If reason found in Countries_Regions_Continents_ISO_Codes__c custom setting
        	System.assertEquals(directClientrecordTypeId,accountList[0].RecordTypeId);
        Test.stopTest();
    }
    
    static testMethod void test_usecase_four() {
        
        Id deliveryPartnerrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Delivery Partner').RecordTypeId;
        Id directClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Direct Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(directClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
    														'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
    														'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
    														null, 'Net 30', 'test@test.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Delivery Partner',
    														1);												
        insert accList;
        Test.startTest();
        	List<Account> accountList = [SELECT Id,Region_Picklist__c,Account_Record_Type__c,RecordTypeId FROM Account WHERE Id=:accList[0].Id];
        	System.assertEquals(accountList.size(),1);
        	//If reason found in Countries_Regions_Continents_ISO_Codes__c custom setting
        	System.assertEquals(deliveryPartnerrecordTypeId,accountList[0].RecordTypeId);
        Test.stopTest();
    }
}