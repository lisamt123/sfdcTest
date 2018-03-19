public with sharing class CustomArticleManagementController {
	public static Map<Id, SObject> allArticleTypeDataMap = new Map<Id, SObject>();
	public static Map<String, String> languageCodeToLanguage = new Map<String, String>();
	public static Map<String, String> languageToLanguageCode = new Map<String, String>();
	
	static {
		Schema.DescribeFieldResult fieldResult = User.LanguageLocaleKey.getDescribe();
		List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
		for (Schema.PicklistEntry picklistEntry : picklistValues) {
			
			String language = picklistEntry.getLabel();
			String languageCode = picklistEntry.getValue();

			languageCodeToLanguage.put(languageCode, language);
			languageToLanguageCode.put(language, languageCode);
		}

		// get data from All Knowledge_kav
		for(X10K_Way__kav elem : [SELECT Id,Title,UrlName,Summary, ArticleType, KnowledgeArticleId, Examples__c, Procedure__c FROM X10K_Way__kav WHERE PublishStatus = 'Online' AND Language = 'en_US']) {
			allArticleTypeDataMap.put(elem.Id, elem);
		}
	}

	@RemoteAction
	public static List<KnowledgeArticleVersion> retreiveKnowledgeArticleVersionList(String lang) {
		lang = 'en_US';
		String status = 'Online';
		String atype = 'X10K_Way__kav';
		return Database.query('SELECT Id, KnowledgeArticleId, ArticleType, Title, Summary, Language FROM KnowledgeArticleVersion WHERE PublishStatus = :status AND Language = :lang AND ArticleType = :atype');
	}

	@RemoteAction
	public static String cloneKnowledgeArticleData(String selectedArticles) {
		System.debug(selectedArticles);
		List<SObject> clones = new List<SObject>();
		String hashString = String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
		Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
		String hexDigest = EncodingUtil.convertToHex(hash);
		Database.DMLOptions dml = new Database.DMLOptions();
		dml.allowFieldTruncation = true;
		for(ArticleCls item : (List<ArticleCls>)JSON.deserialize(selectedArticles, List<ArticleCls>.class)) 
		{
			if(allArticleTypeDataMap.get(item.kavId) != null) 
			{
				System.debug(allArticleTypeDataMap.get(item.kavId));	
				SObject data = allArticleTypeDataMap.get(item.kavId);

				if(item.aType == 'X10K_Way__kav') 
				{
					X10K_Way__kav temp = (X10K_Way__kav) data;
					temp.Id = null;
					temp.UrlName = ((X10K_Way__kav) data).get('UrlName')+'-'+hexDigest;
					temp.setOptions(dml);
					clones.add(temp);
				}
			}
		}

		try 
		{
			if(!clones.isEmpty())
			{
				Database.SaveResult[] srList = Database.insert(clones, false);
				for(Database.SaveResult sr : srList) {
				    if (sr.isSuccess()) {
				        System.debug('Successfully cloned article ID: ' + sr.getId());
				    } 
				    else {
				        for(Database.Error err : sr.getErrors()) {
				            System.debug('The following error has occurred.');                    
				            System.debug(err.getStatusCode() + ': ' + err.getMessage());
				            System.debug('Cloned article fields that affected this error: ' + err.getFields());
					    }
			    	}
				}
			}
		} catch(Exception e) {
			System.debug(e);
			return e.getMessage();
		}
		return 'SUCCESS';
	}

	class ArticleCls {
		String kavId;
		String kaId;
		String aType;
	}
}