@isTest (SeeAllData=true)
private class CustomArticleManagementController_Test 
{
	@isTest static void test_CustomArticleManagementController() 
	{
		Test.startTest();
			List<KnowledgeArticleVersion> kavList = CustomArticleManagementController.retreiveKnowledgeArticleVersionList('en_US');
			String selectedArticle;
			if(!kavList.isEmpty())
			{
				selectedArticle = '[{\"kavId\":\"'+kavList[0].Id+'\",\"kaId\":\"'+kavList[0].KnowledgeArticleId+'\",\"aType\":\"'+kavList[0].ArticleType+'\"}]';
				CustomArticleManagementController.cloneKnowledgeArticleData(selectedArticle);
			}
			
		Test.stopTest();
	}
}