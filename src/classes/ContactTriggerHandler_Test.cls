@isTest
private class ContactTriggerHandler_Test {
	
	@testSetup static void createData() {
        TestDataFactory_CustomSettings.initializeEndpointURIsCustomSetting();
    }
	
	static testMethod void test_usecase_one() {
    	List<Countries_Regions_Continents_ISO_Codes__c> countriesRegionsContinentsISOCodesList = TestDataFactory_CustomSettings.generateCountriesRegionsContinentsISOCodes('Americas', 'United States', 'US', 'USA', 'North America', 1);
        insert countriesRegionsContinentsISOCodesList;
        
    	Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
                                                            'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                            'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
                                                            null, 'Net 30', 'acc@testemail.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
                                                            1);
        insert accList;
        
    	List<Contact> contactList = TestDataFactory_Contacts.generatecontacts(accList, 'Test contact', 'lastName','test2@testemail.com', '', 1);
        insert contactList;
        
        contactList[0].MailingCountryCode = 'US';
        contactList[0].Referral_Code__c = null;
        update contactList;
        
        Test.startTest();
	        //List<Contact> contactResultLi = [SELECT Id,Region__c,Referral_Code__c FROM Contact];
	        List<Contact> contactResultLi = [SELECT Id,Region_Picklist__c,Referral_Code__c FROM Contact];
	        System.assertEquals(1, contactResultLi.size());
	        System.assertNotEquals(null, contactResultLi[0].Referral_Code__c);
	        System.assertEquals(countriesRegionsContinentsISOCodesList[0].Region__c,contactResultLi[0].Region_Picklist__c);
		Test.stopTest();
    }
    
    //Contact Trigger, Handler, AchievementSyncUtility, AchievementSyncBatch
    static testMethod void test_usecase_two() {
    	
    	Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
                                                            'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                            'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
                                                            null, 'Net 30', 'acc@testemail.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
                                                            1);
        insert accList;
        
    	List<Contact> contactList = TestDataFactory_Contacts.generatecontacts(accList, 'Test contact', 'lastName','test2@testemail.com', '', 1);
    	contactList.addAll(TestDataFactory_Contacts.generatecontacts(accList, 'Test contact', 'lastName','test2@testemail.com', '', 1));
        insert contactList;
        
        Database.MergeResult result = Database.merge(contactList[0], contactList[1], false);
		
		Test.startTest();
			List<Old_Referral_Code__c> oldReferralLi = [SELECT Id, Contact__c, Lead__c FROM Old_Referral_Code__c];
	        System.assertEquals(1, oldReferralLi.size());
	        System.assertEquals(contactList[0].Id, oldReferralLi[0].Contact__c);
		Test.stopTest();
    }
    
    //Contact Trigger, Handler, AchievementSyncUtility, AchievementSyncBatch
    static testMethod void test_usecase_three() {
    	
    	List<Lead> leadList = TestDataFactory_Leads.generateLeads(Constants.RECORDTYPEID_Customer, 'TestCompany', 'LName', 'test@testemail.com', null, null, 'US', 1);
        insert leadList;
        
        leadList[0].Referral_Code__c = null;
        update leadList;
        
        Database.LeadConvert lc = new database.LeadConvert();
		lc.setLeadId(leadList[0].id);
		lc.setDoNotCreateOpportunity(false);
		lc.setConvertedStatus('Qualified');
		Database.LeadConvertResult lcr = Database.convertLead(lc);
		System.assert(lcr.isSuccess());
		
		List<Contact> contacList = [SELECT Id,Trailhead_User_Id__c,Webassessor_Email__c FROM Contact];
		System.assertEquals(1, contacList.size());
			
		List<Skill_Group__c> skillGroupsList = TestDataFactory_SkillGroups.generateSkillGroups('Test Group', 1);
		insert skillGroupsList;
		
		List<ProfileSkill> profileSkillList = TestDataFactory_Skills.generateSkills('Test Skill', null, skillGroupsList[0].Id, null, 1);
		insert profileSkillList;
		
		List<Expert_Skill__c> expertSkillsList = TestDataFactory_ExpertSkills.generateExpertSkills(contacList[0].id, null, profileSkillList[0].Id, 2);
		insert expertSkillsList;
		
		Id salesforceCertificationRecordTypeId = Schema.SObjectType.Achievement__c.RecordTypeInfosByName.get('Salesforce Certification').RecordTypeId;
		List<Achievement__c> achievementsList = TestDataFactory_Achievements.generateAchievements(salesforceCertificationRecordTypeId, 'Test123', 'Climb Achievement', 'Achievements', Date.today().addDays(365), false, false, '', '', '', 1);
		insert achievementsList;
		
		List<Expert_Achievement__c> exAchievementsList = TestDataFactory_ExpertAchievements.generateExpertAchievements('Active', null, 'LName', false, contacList[0].id, Date.today().addDays(-30), achievementsList[0].Id, 2);
		insert exAchievementsList;
		
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
			//contacList[0].Trailhead_User_Id__c = 'testtesttest';
			contacList[0].Webassessor_Email__c = 'test@test1.test';
			update contacList;
			
			List<Expert_Achievement__c> exAchievementsResultList = [SELECT Id FROM Expert_Achievement__c WHERE Contact__c=:contacList[0].Id];
			System.assertEquals(1, exAchievementsResultList.size());
			List<Expert_Skill__c> expertSkillsResultList = [SELECT Id FROM Expert_Skill__c WHERE Contact__c=:contacList[0].Id];
			System.assertEquals(1, expertSkillsResultList.size());
			
			List<Old_Referral_Code__c> oldReferralLi = [SELECT Id, Contact__c FROM Old_Referral_Code__c];
	        System.assertEquals(1, oldReferralLi.size());
	        System.assertEquals(contacList[0].Id, oldReferralLi[0].Contact__c);
        Test.stopTest();
    }
    
        //Contact Trigger, Handler, AchievementSyncUtility, AchievementSyncBatch
    static testMethod void test_usecase_four() {
    	
    	Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
                                                            'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                            'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
                                                            null, 'Net 30', 'acc@testemail.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
                                                            1);
        insert accList;
        
    	List<Contact> contactList = TestDataFactory_Contacts.generatecontacts(accList, 'Test contact', 'lastName','test2@testemail.com', '', 1);
        insert contactList;
        
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
			contactList[0].Trailhead_User_Id__c = 'testtesttest';
			update contactList;
			
			//List<Contact> leadResultLi = [SELECT Id,Region__c,Referral_Code__c FROM Contact];
			List<Contact> leadResultLi = [SELECT Id,Region_Picklist__c,Referral_Code__c FROM Contact];
	        System.assertEquals(1, leadResultLi.size());
	        System.assertNotEquals(null, leadResultLi[0].Referral_Code__c);
        Test.stopTest();
    }
    
    //Contact Trigger, Handler, AchievementSyncUtility, AchievementSyncBatch
    static testMethod void test_usecase_five() {
    	
    	Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
                                                            'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                            'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
                                                            null, 'Net 30', 'acc@testemail.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
                                                            1);
        insert accList;
        
    	List<Contact> contactList = TestDataFactory_Contacts.generatecontacts(accList, 'Test contact', 'lastName','test2@testemail.com', '', 1);
        insert contactList;
        
        List<Skill_Group__c> skillGroupsList = TestDataFactory_SkillGroups.generateSkillGroups('Test Group', 1);
		insert skillGroupsList;
		
		List<ProfileSkill> profileSkillList = TestDataFactory_Skills.generateSkills('Test Skill', null, skillGroupsList[0].Id, null, 1);
		insert profileSkillList;
		
		List<Expert_Skill__c> expertSkillsList = TestDataFactory_ExpertSkills.generateExpertSkills(contactList[0].id, null, profileSkillList[0].Id, 2);
		insert expertSkillsList;
		
		Id trailheadBadgeRecordTypeId = Schema.SObjectType.Achievement__c.RecordTypeInfosByName.get('Trailhead Badge').RecordTypeId;
		Id salesforceCertificationRecordTypeId = Schema.SObjectType.Achievement__c.RecordTypeInfosByName.get('Salesforce Certification').RecordTypeId;
		List<Achievement__c> achievementsList = TestDataFactory_Achievements.generateAchievements(trailheadBadgeRecordTypeId, 'Test321', 'Climb Achievement', 'Achievements', Date.today().addDays(365), false, false, '', '', '', 1);
		achievementsList.addAll(TestDataFactory_Achievements.generateAchievements(salesforceCertificationRecordTypeId, 'Test123', 'Climb Achievement', 'Achievements', Date.today().addDays(365), false, false, '', '', '', 1));
		insert achievementsList;
		
		List<Expert_Achievement__c> exAchievementsList = TestDataFactory_ExpertAchievements.generateExpertAchievements('Active', null, 'LName', false, contactList[0].id, Date.today().addDays(-30), achievementsList[0].Id, 2);
		exAchievementsList.addAll(TestDataFactory_ExpertAchievements.generateExpertAchievements('Active', null, 'LName', false, contactList[0].id, Date.today().addDays(-30), achievementsList[1].Id, 2));
		insert exAchievementsList;
        
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
			contactList[0].Trailhead_User_Id__c = 'testtesttest';
			contactList[0].Webassessor_Email__c = 'test@test1.test';
			update contactList;
			
			List<Expert_Achievement__c> exAchievementsResultList = [SELECT Id FROM Expert_Achievement__c WHERE Contact__c=:contactList[0].Id];
			System.assertEquals(2, exAchievementsResultList.size());
			List<Expert_Skill__c> expertSkillsResultList = [SELECT Id FROM Expert_Skill__c WHERE Contact__c=:contactList[0].Id];
			System.assertEquals(1, expertSkillsResultList.size());
        Test.stopTest();
    }
    
    //Contact Trigger, Handler, AchievementSyncUtility, AchievementSyncBatch
    static testMethod void test_usecase_six() {
    	
    	Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
                                                            'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                            'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
                                                            null, 'Net 30', 'acc@testemail.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
                                                            1);
        insert accList;
        
    	List<Contact> contactList = TestDataFactory_Contacts.generatecontacts(accList, 'Test contact', 'lastName','test2@testemail.com', '', 1);
        insert contactList;
        
        List<Skill_Group__c> skillGroupsList = TestDataFactory_SkillGroups.generateSkillGroups('Test Group', 1);
		insert skillGroupsList;
		
		List<ProfileSkill> profileSkillList = TestDataFactory_Skills.generateSkills('Test Skill', null, skillGroupsList[0].Id, null, 1);
		insert profileSkillList;
		
		List<Expert_Skill__c> expertSkillsList = TestDataFactory_ExpertSkills.generateExpertSkills(contactList[0].id, null, profileSkillList[0].Id, 2);
		insert expertSkillsList;
		
		Id trailheadBadgeRecordTypeId = Schema.SObjectType.Achievement__c.RecordTypeInfosByName.get('Trailhead Badge').RecordTypeId;
		Id salesforceCertificationRecordTypeId = Schema.SObjectType.Achievement__c.RecordTypeInfosByName.get('Salesforce Certification').RecordTypeId;
		List<Achievement__c> achievementsList = TestDataFactory_Achievements.generateAchievements(trailheadBadgeRecordTypeId, 'Quick Start: Visualforce', 'Climb Achievement', 'Achievements', Date.today().addDays(365), false, false, '', '', '', 1);
		achievementsList.addAll(TestDataFactory_Achievements.generateAchievements(salesforceCertificationRecordTypeId, 'Salesforce Certified Administrator', 'Climb Achievement', 'Achievements', Date.today().addDays(365), false, false, '', '', '', 1));
		insert achievementsList;
		
		List<Expert_Achievement__c> exAchievementsList = TestDataFactory_ExpertAchievements.generateExpertAchievements('Active', null, 'LName', false, contactList[0].id, Date.today().addDays(-30), achievementsList[0].Id, 2);
		exAchievementsList.addAll(TestDataFactory_ExpertAchievements.generateExpertAchievements('Active', null, 'LName', false, contactList[0].id, Date.today().addDays(-30), achievementsList[1].Id, 2));
		insert exAchievementsList;
        
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
			contactList[0].Trailhead_User_Id__c = 'testtesttest';
			contactList[0].Webassessor_Email__c = 'test@test1.test';
			update contactList;
			
			List<Expert_Achievement__c> exAchievementsResultList = [SELECT Id FROM Expert_Achievement__c WHERE Contact__c=:contactList[0].Id];
			System.assertEquals(2, exAchievementsResultList.size());
			List<Expert_Skill__c> expertSkillsResultList = [SELECT Id FROM Expert_Skill__c WHERE Contact__c=:contactList[0].Id];
			System.assertEquals(1, expertSkillsResultList.size());
        Test.stopTest();
    }
}