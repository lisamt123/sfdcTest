public with sharing class ConfigureCodeQualityScanController {
	@AuraEnabled
	public static List<RuleSetWrapper> retrieveCodeScanProperties(String recId) {
		Project__c project = [SELECT Id, Name FROM Project__c WHERE Id =: recId];
		Map<String,RuleSetWrapper> ruleNameMap = new Map<String,RuleSetWrapper>();
		HttpResponse res = RestRequestHandlerForHeroku.sendRequest('POST','Project_Code_Severity_Retrieve','','',(String)project.Id,(String)project.Name);

		if(res.getStatusCode() == 200 ) {
            ResponseWrapper response = (ResponseWrapper) JSON.deserialize(res.getBody(), ResponseWrapper.class);
            if(response.status == 'Success' )
            	if(response.ruleList != null && response.ruleList.size() > 0 && response.ruleList[0].ruleState != '')
            		for(RuleSetWrapper ruleInfo : response.ruleList)
            			ruleNameMap.put(ruleInfo.ruleName.trim(),ruleInfo);
        }
		List<RuleSetWrapper> ruleSetWrapperList = new List<RuleSetWrapper>();
		for(Code_Scan_Rule_Set__mdt rule : [SELECT Id, QualifiedApiName, Severity__c, State__c, Rule_Description__c FROM Code_Scan_Rule_Set__mdt]){
			RuleSetWrapper ruleInfo = new RuleSetWrapper();
			ruleInfo.ruleName 			= rule.QualifiedApiName;
			ruleInfo.ruleState 			= ruleNameMap.containsKey(rule.QualifiedApiName.trim()) ? ruleNameMap.get(rule.QualifiedApiName).ruleState : rule.State__c;
			ruleInfo.ruleSeverity 		= ruleNameMap.containsKey(rule.QualifiedApiName.trim()) ? ruleNameMap.get(rule.QualifiedApiName).ruleSeverity : rule.Severity__c;
			ruleInfo.ruleDescription 	= rule.Rule_Description__c;
            ruleSetWrapperList.add(ruleInfo);
		}
		return ruleSetWrapperList;
	}

	@AuraEnabled
	public static String updateCodeScanProperties(String recId,String ruleSetWrapperListJSON) {
		List<RuleSetWrapper> ruleSetWrapperList = (List<RuleSetWrapper>)JSON.deserialize(ruleSetWrapperListJSON, List<RuleSetWrapper>.class);
		Project__c project = [SELECT Id, Name FROM Project__c WHERE Id =: recId];
		for(RuleSetWrapper rule : ruleSetWrapperList)
			rule.ruleDescription = null;
		String requestJSONBody = '"ruleList":' + JSON.serialize(ruleSetWrapperList);
		HttpResponse res = RestRequestHandlerForHeroku.sendRequest('POST','Project_Code_Severity_Create',requestJSONBody,'',(String)project.Id,(String)project.Name);
        return 'Success';
	}

	public class ResponseWrapper {
        @AuraEnabled public String Status;
        @AuraEnabled public List<RuleSetWrapper> ruleList;
    }

	public class RuleSetWrapper {
		@AuraEnabled public string ruleName 		{get;set;}
		@AuraEnabled public string ruleState 		{get;set;}
		@AuraEnabled public string ruleSeverity 	{get;set;}
		@AuraEnabled public string ruleDescription 	{get;set;}
	}
}