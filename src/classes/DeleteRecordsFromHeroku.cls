public with sharing class DeleteRecordsFromHeroku {
	public static void removeRecordsFromHeroku(List<String> recordsIdList,String projectId,String projectName) {
        String storyKeyPrifix       = Schema.getGlobalDescribe().get('Story__c').getDescribe().getKeyPrefix();
        String releaseKeyPrifix     = Schema.getGlobalDescribe().get('Release__c').getDescribe().getKeyPrefix();
        String connectionKeyPrifix  = Schema.getGlobalDescribe().get('Connection__c').getDescribe().getKeyPrefix();
        String reqEndpoint          = '';
        String recId 				= recordsIdList[0];
        if(recId.substring(0, 3) == storyKeyPrifix)
            reqEndpoint = 'Story_Delete';
        else if (recId.substring(0, 3) == releaseKeyPrifix)
            reqEndpoint = 'Release_Delete';
        else if (recId.substring(0, 3) == connectionKeyPrifix)
            reqEndpoint = 'Connection_Delete';
        
        String requestJSONBody = '"jsonList":' + JSON.serialize(recordsIdList); 
        HttpResponse res = RestRequestHandlerForHeroku.sendRequest('POST',reqEndpoint,requestJSONBody,null,projectId,projectName);
    }
}