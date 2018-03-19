@isTest
private class ManageAchievementSkillsController_Test 
{
	
	@isTest static void test_method_one() 
	{
		TestDataFactory factory = new TestDataFactory();
		List<Achievement__c> achievementsList = factory.generateAchievements(1);
		insert achievementsList;

		Skill_Group__c skillGroup = new Skill_Group__c(Name = 'Test Group');
		insert skillGroup;

		ProfileSkill skill = new ProfileSkill(Name = 'Test Skill', Skill_Group__c = skillGroup.Id);
		insert skill;

		Achievement_Skill__c achievementskill = new Achievement_Skill__c(Achievement__c = achievementsList[0].Id, Skill__c = skill.Id);
		insert achievementskill;
		ApexPages.currentPage().getParameters().put('id',achievementsList[0].Id);
		Test.startTest();
			ApexPages.StandardSetController sc = new ApexPages.StandardSetController(new List<Achievement_Skill__c>{achievementskill});
			ManageAchievementSkillsController controller = new ManageAchievementSkillsController(sc);
			controller.saveModification();
			System.assertNotEquals(controller.achievement, null);
		Test.stopTest();
	}
}