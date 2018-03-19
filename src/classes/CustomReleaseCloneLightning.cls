public with sharing class CustomReleaseCloneLightning {
	@auraEnabled
	public static Map<String,Object> getRecordData(String sObjectName, Id recordId, String fieldToSkip) {
		SObject recordObj ;
		Map<String,Object> fieldValueMap = new Map<String,Object>();
		if(!String.isBlank(sObjectName) && recordId != null) {
			Schema.DescribeSObjectResult[] descResultList = Schema.describeSObjects(new String[]{sObjectName});
			Map<String, String> fieldMap = new Map<String,String>();
			Map<String, String> fieldToSkipMap = new Map<String,String>();
			List<String> fieldToSkipList = new List<String>();
			fieldToSkipList = fieldToSkip.split(',');
			for(String skip : fieldToSkipList)
				fieldToSkipMap.put(skip, skip);
			if(descResultList.size() > 0) {
				Schema.DescribeSObjectResult descResult = descResultList[0];
				if(descResult.isAccessible()) {
					Map<String, SObjectField> fieldSetMap = descResult.fields.getMap();
					for(String key : fieldSetMap.keySet()) {
						DescribeFieldResult selectedField = fieldSetMap.get(key).getDescribe();
						if(selectedField.isCreateable() && selectedField.isAccessible() && (!fieldToSkipMap.containsKey(selectedField.getName())))
							fieldMap.put(selectedField.getName(),selectedField.getLabel());
					}
				}
			}
			if(fieldMap.size() > 0) {
				Set<String> fieldSet = fieldMap.keySet();
				String fieldString = String.join(new List<String>(fieldSet), ',');
				List<SObject> sObjList = Database.query('SELECT '+ fieldString + ' FROM '+ sObjectName + ' WHERE Id = \'' + recordId + '\'');
				if(sObjList.size() > 0) 
					recordObj = sObjList[0];

				if(recordObj != null) 
					for(String skey : fieldSet) 
						if(recordObj.get(skey) != null)
							fieldValueMap.put(skey, recordObj.get(skey));
			}
		}
		return fieldValueMap;
	}
	
	@auraEnabled
	public static void cloning(Id release_Id,Id clonedFromReleaseId) { 
        List<Release__c> releaseList = [SELECT Id, Project__c, Project__r.Name, Created_On_Heroku__c FROM Release__c where Id =: clonedFromReleaseId];
        if(releaseList.size() > 0) {
        	Release__c release = releaseList[0] ;
        	if(release.Created_On_Heroku__c) {
		        String requestJSONBody = '"Release_Id_OLD":"'+ clonedFromReleaseId +'",'+ 
		                   				 '"Release_Id_NEW":"' + release_Id +'"';

		        HttpResponse res = RestRequestHandlerForHeroku.sendRequest('POST','Release_Clone',requestJSONBody,'',release.Project__c,release.Project__r.Name);
		        ResponseWrapper resp = (ResponseWrapper)JSON.deserialize(res.getBody(), ResponseWrapper.class);
		        if(resp.status == 'SUCCESS') {
		        	releaseList = [SELECT Id, Created_On_Heroku__c FROM Release__c where Id =: release_Id];
		        	if(releaseList.size() > 0) {
		        		Release__c newRelease = releaseList[0];
		        		newRelease.Created_On_Heroku__c = true;
		        		update newRelease ;
		        	}
		        }
        	}
        }
    }

    public class ResponseWrapper {
    	public String status;
    	public String message;
    }
}