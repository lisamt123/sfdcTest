@isTest
private class LeadTriggerHandler_Test {

    //Lead Trigger, Handler, AchievementSyncUtility 
    static testMethod void test_usecase_one() {
        
        List<Countries_Regions_Continents_ISO_Codes__c> countriesRegionsContinentsISOCodesList = TestDataFactory_CustomSettings.generateCountriesRegionsContinentsISOCodes('Americas', 'United States', 'US', 'USA', 'North America', 1);
        insert countriesRegionsContinentsISOCodesList;
        
        List<Lead> leadList = TestDataFactory_Leads.generateLeads(Constants.RECORDTYPEID_Customer, 'TestCompany', 'LName', 'test@testemail.com', null, null, 'US', 1);
        insert leadList;
        
        Test.startTest();
            List<Lead> leadResultLi = [SELECT Id,Region__c,Referral_Code__c FROM Lead];
            System.assertEquals(1, leadResultLi.size());
            System.assertNotEquals(null, leadResultLi[0].Referral_Code__c);
            System.assertEquals(countriesRegionsContinentsISOCodesList[0].Region__c,leadResultLi[0].Region__c);
        Test.stopTest();
    }
    
    //Lead Trigger, Handler, AchievementSyncUtility 
    static testMethod void test_usecase_two() {
        
        List<Lead> leadList = TestDataFactory_Leads.generateLeads(Constants.RECORDTYPEID_Customer, 'TestCompany', 'LName', 'test@testemail.com', null, null, 'US', 1);
        leadList.addAll(TestDataFactory_Leads.generateLeads(Constants.RECORDTYPEID_Customer, 'TestCompany2', 'LName2', 'test2@testemail.com', null, null, 'US', 1));
        insert leadList;
        
        Database.MergeResult result = Database.merge(leadList[0], leadList[1], false);
        List<Old_Referral_Code__c> oldReferralLi = [SELECT Id FROM Old_Referral_Code__c];
        System.assertEquals(1, oldReferralLi.size());
    }
    
    //Lead Trigger, Handler, AchievementSyncUtility 
    static testMethod void test_usecase_three() {
        
        List<Lead> leadList = TestDataFactory_Leads.generateLeads(Constants.RECORDTYPEID_Customer, 'TestCompany', 'LName', 'test@testemail.com', null, null, 'US', 1);
        insert leadList;
        
        List<Skill_Group__c> skillGroupsList = TestDataFactory_SkillGroups.generateSkillGroups('Test Group', 1);
        insert skillGroupsList;
        
        List<ProfileSkill> profileSkillList = TestDataFactory_Skills.generateSkills('Test Skill', null, skillGroupsList[0].Id, null, 1);
        insert profileSkillList;
        
        List<Expert_Skill__c> expertSkillsList = TestDataFactory_ExpertSkills.generateExpertSkills(null, leadList[0].id, profileSkillList[0].Id, 2);
        insert expertSkillsList;
        
        Test.startTest();
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(leadList[0].id);
            lc.setDoNotCreateOpportunity(false);
            lc.setConvertedStatus('Qualified');
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            System.assert(lcr.isSuccess());
            
            List<Contact> contacList = [SELECT Id FROM Contact];
            System.assertEquals(1, contacList.size());
            
            List<Expert_Skill__c> expertSkillsResultList = [SELECT Id FROM Expert_Skill__c];
            System.assertEquals(1, expertSkillsResultList.size()); 
        Test.stopTest();
    }
    
    static testMethod void test_usecase_four() {
        
        List<Lead> leadList = TestDataFactory_Leads.generateLeads(Constants.RECORDTYPEID_Customer, 'TestCompany', 'LName', 'test@testemail.com', null, null, 'US', 1);
        insert leadList;
        
        Id salesforceCertificationRecordTypeId = Schema.SObjectType.Achievement__c.RecordTypeInfosByName.get('Salesforce Certification').RecordTypeId;
        List<Achievement__c> achievementsList = TestDataFactory_Achievements.generateAchievements(salesforceCertificationRecordTypeId, 'Test234', 'Climb Achievement', 'Achievements', Date.today().addDays(365), false, false, '', '', '', 1);
        insert achievementsList;
        
        List<Expert_Achievement__c> exAchievementsList = TestDataFactory_ExpertAchievements.generateExpertAchievements('Active', leadList[0].id, 'LName', false, null, Date.today().addDays(-30), achievementsList[0].Id, 2);
        insert exAchievementsList;
        
        Test.startTest();
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(leadList[0].id);
            lc.setDoNotCreateOpportunity(false);
            lc.setConvertedStatus('Qualified');
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            System.assert(lcr.isSuccess());
        
            List<Contact> contacList = [SELECT Id FROM Contact];
            System.assertEquals(1, contacList.size());
            
            List<Expert_Achievement__c> exAchievementsResultList = [SELECT Id FROM Expert_Achievement__c];
            System.assertEquals(1, exAchievementsResultList.size());
            
        Test.stopTest();
    }
}