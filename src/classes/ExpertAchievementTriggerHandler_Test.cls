@isTest
private class ExpertAchievementTriggerHandler_Test {
	
	static testMethod void test_usecase_one() {
		
		Id salesforceCertificationRecordTypeId = Schema.SObjectType.Achievement__c.RecordTypeInfosByName.get('Salesforce Certification').RecordTypeId;
        List<Achievement__c> achievementsList = TestDataFactory_Achievements.generateAchievements(salesforceCertificationRecordTypeId, 'Test123', 'Climb Achievement', 'Achievements', Date.today().addDays(365), false, false, '', '', '', 1);
        achievementsList.addAll(TestDataFactory_Achievements.generateAchievements(salesforceCertificationRecordTypeId, 'Test456', 'Climb Achievement', 'Achievements', Date.today().addDays(365), false, false, '', '', '', 1));
        insert achievementsList;
        
		List<Skill_Group__c> skillGroupsList = TestDataFactory_SkillGroups.generateSkillGroups('Test Group', 1);
        insert skillGroupsList;
        
        List<ProfileSkill> profileSkillList = TestDataFactory_Skills.generateSkills('Test Skill', null, skillGroupsList[0].Id, null, 1);
        insert profileSkillList;
        
        List<Achievement_Skill__c> achievementSkillsList = TestDataFactory_AchievementSkills.generateAchievementSkills(achievementsList[0].Id, profileSkillList[0].Id, 1);
        achievementSkillsList.addAll(TestDataFactory_AchievementSkills.generateAchievementSkills(achievementsList[1].Id, profileSkillList[0].Id, 1));
        insert achievementSkillsList;
        
        Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
                                                            'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                            'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
                                                            null, 'Net 30', 'acc@testemail.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
                                                            1);
        insert accList;
        
        List<Contact> contactList = TestDataFactory_Contacts.generatecontacts(accList, 'Test contact', 'lastName','test2@testemail.com', '', 1);
        insert contactList;
        
        List<Lead> leadList = TestDataFactory_Leads.generateLeads(Constants.RECORDTYPEID_Customer, 'TestCompany', 'LName', 'test@testemail.com', null, null, 'US', 1);
        insert leadList;
        
        List<Expert_Achievement__c> exAchievementsList = TestDataFactory_ExpertAchievements.generateExpertAchievements('Active', null, 'LName', false, contactList[0].id, Date.today().addDays(-30), achievementsList[0].Id, 1);
        exAchievementsList.addAll(TestDataFactory_ExpertAchievements.generateExpertAchievements('Active', leadList[0].Id, 'LName', false, null, Date.today().addDays(-30), achievementsList[0].Id, 1));
        insert exAchievementsList;
        
        List<Expert_Skill__c> expertSkillsList = [SELECT Id FROM Expert_Skill__c WHERE Skill__c =:profileSkillList[0].Id AND (Contact__c=:contactList[0].Id OR Lead__c=:leadList[0].Id)];
        System.assertEquals(2, expertSkillsList.size());
        
        List<Endorsement__c> endorsementList = [SELECt Id, Expert_Skill__c, Expert_Achievement__c FROM Endorsement__c];
        System.assertEquals(2, endorsementList.size());
        
        //In case if contact/lead already have expert skills
        exAchievementsList = TestDataFactory_ExpertAchievements.generateExpertAchievements('Active', null, 'LName', false, contactList[0].id, Date.today().addDays(-30), achievementsList[1].Id, 1);
        exAchievementsList.addAll(TestDataFactory_ExpertAchievements.generateExpertAchievements('Active', leadList[0].Id, 'LName', false, null, Date.today().addDays(-30), achievementsList[1].Id, 1));
        insert exAchievementsList;
        
        endorsementList = [SELECt Id, Expert_Skill__c, Expert_Achievement__c FROM Endorsement__c];
        System.assertEquals(4, endorsementList.size());
        
        System.assertEquals(2, exAchievementsList.size());
        delete exAchievementsList[1];
        
        List<Lead> leadResultList = [SELECT Id,Achievement_Count__c FROM Lead WHERE Id=:leadList[0].Id];
        System.assertEquals(1, leadResultList.size());
        System.assertEquals(1, leadResultList[0].Achievement_Count__c);
	}
	
	static testMethod void test_usecase_two() {
		//Negative Testing
		Id salesforceCertificationRecordTypeId = Schema.SObjectType.Achievement__c.RecordTypeInfosByName.get('Salesforce Certification').RecordTypeId;
        List<Achievement__c> achievementsList = TestDataFactory_Achievements.generateAchievements(salesforceCertificationRecordTypeId, 'Test123', 'Climb Achievement', 'Achievements', Date.today().addDays(365), false, false, '', '', '', 1);
        insert achievementsList;
        
		List<Skill_Group__c> skillGroupsList = TestDataFactory_SkillGroups.generateSkillGroups('Test Group', 1);
        insert skillGroupsList;
        
        List<ProfileSkill> profileSkillList = TestDataFactory_Skills.generateSkills('Test Skill', null, skillGroupsList[0].Id, null, 1);
        insert profileSkillList;
        
        List<Achievement_Skill__c> achievementSkillsList = TestDataFactory_AchievementSkills.generateAchievementSkills(achievementsList[0].Id, profileSkillList[0].Id, 1);
        insert achievementSkillsList;
        
        Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
                                                            'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                            'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
                                                            null, 'Net 30', 'acc@testemail.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
                                                            1);
        insert accList;
        
        List<Contact> contactList = TestDataFactory_Contacts.generatecontacts(accList, 'Test contact', 'lastName','test2@testemail.com', '', 1);
        insert contactList;
        
        List<Lead> leadList = TestDataFactory_Leads.generateLeads(Constants.RECORDTYPEID_Customer, 'TestCompany', 'LName', 'test@testemail.com', null, null, 'US', 1);
        insert leadList;
        
        List<Expert_Achievement__c> exAchievementsList = TestDataFactory_ExpertAchievements.generateExpertAchievements('Active', null, 'LName', false, contactList[0].id, Date.today().addDays(-30), achievementsList[0].Id, 1);
        exAchievementsList.addAll(TestDataFactory_ExpertAchievements.generateExpertAchievements('Active', leadList[0].Id, 'LName', false, null, Date.today().addDays(-30), achievementsList[0].Id, 1));
        insert exAchievementsList;
        System.assertEquals(2, exAchievementsList.size());
        
        try
        {
        	//validation
        	exAchievementsList = TestDataFactory_ExpertAchievements.generateExpertAchievements('Active', null, 'LName', false, contactList[0].id, Date.today().addDays(-30), achievementsList[0].Id, 1);
        	insert exAchievementsList;
        }
        catch(Exception ex)
        {
        	String errorMessage = ex.getMessage();
        	System.assert(errorMessage.contains('You can\'t select Achievement which already exist.'));
        }
        
        try
        {
        	//validation
        	exAchievementsList = TestDataFactory_ExpertAchievements.generateExpertAchievements('Active', leadList[0].Id, 'LName', false, null, Date.today().addDays(-30), achievementsList[0].Id, 1);
        	insert exAchievementsList;
        }
        catch(Exception ex)
        {
        	String errorMessage = ex.getMessage();
        	System.assert(errorMessage.contains('You can\'t select Achievement which already exist.'));
        }
	}
}