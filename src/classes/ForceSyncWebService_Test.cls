@isTest
private class ForceSyncWebService_Test{

    @testSetup static void createData() {
        TestDataFactory_CustomSettings.initializeEndpointURIsCustomSetting();
    }


    static testMethod void test_usecase_one() {
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
        contactList[0].Trailhead_User_Id__c = 'testtesttest';
            contactList[0].Webassessor_Email__c = 'test@test1.test';
            update contactList;
        
         Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockResponseCallout());
            
            
            ForceSyncWebService.forceSync(contactList[0].Id);
        Test.stopTest();
        
    }
}