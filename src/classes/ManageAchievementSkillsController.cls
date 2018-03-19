public with sharing class ManageAchievementSkillsController 
{
	public Achievement__c achievement {get; set;}
	private Id achievementId;
	public List<SelectOption> availableSkills {get; set;}
	public List<SelectOption> selectedSkills {get; set;}
	public Boolean isLightningExperience { get;set; }

	public ManageAchievementSkillsController(ApexPages.StandardSetController controller) 
	{
		isLightningExperience = false;
		if(ApexPages.CurrentPage().GetParameters().get('sfdcIFrameOrigin') != null) {
            
            isLightningExperience = true;
        }
		availableSkills		= new List<SelectOption>();
		selectedSkills 		= new List<SelectOption>();
		achievementId		= ApexPages.currentPage().getParameters().get('id');
		achievement 		= [SELECT Id, Name FROM Achievement__c WHERE Id =: achievementId];
		List<Achievement__c> achievementList = [SELECT Id,(SELECT Id, Skill__c, Skill__r.Name FROM Achievement_Skills__r) FROM Achievement__c WHERE Id =: achievementId];
		Set<String> selectedSkillSet = new Set<String>();
		for(Achievement_Skill__c achskill : achievementList[0].Achievement_Skills__r)
		{
			selectedSkillSet.add(achskill.Skill__c);
		}
		System.debug(selectedSkillSet);
		List<ProfileSkill> skillList = [SELECT Id, Name FROM ProfileSkill];

		for(ProfileSkill skill : skillList)
		{
			if(selectedSkillSet.contains(skill.Id))
			{
				selectedSkills.add(new SelectOption(skill.Id, skill.Name));
			}
			else
			{
				availableSkills.add(new SelectOption(skill.Id, skill.Name));
			}
		}
	}

	public PageReference saveModification()
	{
		List<Achievement_Skill__c> achievementSkillsToInsert = new List<Achievement_Skill__c>();
		List<Achievement_Skill__c> achievementSkillsToDelete = [SELECT Id, Achievement__c FROM Achievement_Skill__c WHERE Achievement__c =: achievementId];

		if(!achievementSkillsToDelete.isEmpty())
		{
			try{
				delete achievementSkillsToDelete;
			}
			catch(DmlException ex){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
			}
		}

		for(SelectOption changedOption : selectedSkills)
		{
			achievementSkillsToInsert.add(new Achievement_Skill__c(Achievement__c = achievementId, Skill__c = changedOption.getValue()));
		}
		if(!achievementSkillsToInsert.isEmpty())
		{
			try{
				insert achievementSkillsToInsert;
			}
			catch(DmlException e){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
			}
		}
		PageReference pg = new PageReference('/'+achievementId);
		return pg;
	}
}