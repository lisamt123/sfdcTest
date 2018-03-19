public without sharing class PointDetailController {
	
	@AuraEnabled
	public static PointsWrap retPoints() {
		List<PointsWrapper> pointsWrapperList = new List<PointsWrapper>();
		Map<String, List<Id>> objectNameToSourceRecIdMap = new Map<String, List<Id>>();
		Map<List<Id>, String> displayNameSourceRecID = new Map<List<Id>, String>();
		Map<Id, String> fieldNameSourceRecID = new Map<Id, String>();
		Map<String, set<String>> objectNameToDisplayNameMap = new Map<String, Set<String>>();
		Set<String> fieldToIgnoreSet = new Set<String>();

		List<User> userList = [SELECT Id, ContactId FROM USER WHERE Id=: UserInfo.getUserId()];
		if(!userList.isEmpty() && userList[0].ContactId != null)
		{
			String contactId = userList[0].ContactId;
			Contact con = [SELECT Id, Lifetime_Points_Earned__c, Lifetime_Points_Redeemed__c FROM Contact WHERE Id =: contactId];
			List<Points__c> pointsList = [SELECT Id, Number_of_Points__c, Points_Rule__r.Name, Points_Rule__r.Object_API_Name__c, Source_Record_Id__c, 
												CreatedDate, Points_Rule__r.My_Points_Display_Name__c, Points_Rule__r.Hyperlink_Source_Record_Name__c 
											FROM Points__c 
											WHERE Contact__c =: contactId AND Points_Rule__c != null];
			for(Points__c pt : pointsList) {
				List<Id> recordIdList = new List<Id>();
				if(!String.isBlank(pt.Points_Rule__r.My_Points_Display_Name__c)){
					fieldNameSourceRecID.put(pt.Source_Record_Id__c,pt.Points_Rule__r.My_Points_Display_Name__c);
					if(!Schema.getGlobalDescribe().get(pt.Points_Rule__r.Object_API_Name__c).getDescribe().fields.getMap().containsKey(pt.Points_Rule__r.My_Points_Display_Name__c))
						fieldToIgnoreSet.add(pt.Points_Rule__r.My_Points_Display_Name__c);
				}
				else
					fieldNameSourceRecID.put(pt.Source_Record_Id__c,'');

				if(!String.isBlank(pt.Points_Rule__r.Object_API_Name__c)) {
					if(objectNameToSourceRecIdMap.containsKey(pt.Points_Rule__r.Object_API_Name__c)) {
						recordIdList.addAll(objectNameToSourceRecIdMap.get(pt.Points_Rule__r.Object_API_Name__c));
						recordIdList.add(pt.Source_Record_Id__c);
						objectNameToSourceRecIdMap.put(pt.Points_Rule__r.Object_API_Name__c, recordIdList);
					}
					else {
						recordIdList.add(pt.Source_Record_Id__c);
						objectNameToSourceRecIdMap.put(pt.Points_Rule__r.Object_API_Name__c, recordIdList);
					}

					Set<String> displayNameList = new Set<String>();
					if(objectNameToDisplayNameMap.containsKey(pt.Points_Rule__r.Object_API_Name__c)) {
						displayNameList.addAll(objectNameToDisplayNameMap.get(pt.Points_Rule__r.Object_API_Name__c));
						if(!String.isBlank(pt.Points_Rule__r.My_Points_Display_Name__c))
							if(pt.Points_Rule__r.My_Points_Display_Name__c.split('\\.').size() > 1 || Schema.getGlobalDescribe().get(pt.Points_Rule__r.Object_API_Name__c).getDescribe().fields.getMap().containsKey(pt.Points_Rule__r.My_Points_Display_Name__c))
								displayNameList.add(pt.Points_Rule__r.My_Points_Display_Name__c);
							objectNameToDisplayNameMap.put(pt.Points_Rule__r.Object_API_Name__c, displayNameList);
							
					}
					else {
						if(!String.isBlank(pt.Points_Rule__r.My_Points_Display_Name__c))
							if(pt.Points_Rule__r.My_Points_Display_Name__c.split('\\.').size() > 1 || Schema.getGlobalDescribe().get(pt.Points_Rule__r.Object_API_Name__c).getDescribe().fields.getMap().containsKey(pt.Points_Rule__r.My_Points_Display_Name__c))
								displayNameList.add(pt.Points_Rule__r.My_Points_Display_Name__c);
							objectNameToDisplayNameMap.put(pt.Points_Rule__r.Object_API_Name__c, displayNameList);
					}
				}
			}
			Map<String, String> sourceRecIdToNameMap = new Map<String, String>();
			Map<String, String> sourceRecIDToFieldRecId = new Map<String, String>();
			Integer queryCount = 0;
			for(String objAPI : objectNameToSourceRecIdMap.keySet()) {

				List<Id> recIdList = new List<Id>();
                List<String> fieldNameList = new List<String>();
				recIdList.addAll(objectNameToSourceRecIdMap.get(objAPI));
				String fieldsToQuery;
				String queryString;
				Set<String> checkFieldName = new Set<String>();
				if(objectNameToDisplayNameMap.containsKey(objAPI) && !(objectNameToDisplayNameMap.get(objAPI)).isEmpty()) {
                    fieldNameList.addAll(objectNameToDisplayNameMap.get(objAPI));
					fieldsToQuery = String.join(fieldNameList, ',');
				 	queryString = 'SELECT Id, '+fieldsToQuery+' FROM '+objAPI+' WHERE Id IN : recIdList';
				}
				else {
					queryString = 'SELECT Id, Name FROM '+objAPI+' WHERE Id IN : recIdList';
				}
				if(queryCount < 100) {
					List<SObject> objList = Database.query(queryString) ;
					if(objList.size() > 0) {
						for(SObject obj : objList){
							if(fieldNameSourceRecID.get((String)obj.get('Id')) != null && fieldNameSourceRecID.get((String)obj.get('Id')) != '' ){
								String s = fieldNameSourceRecID.get((String)obj.get('Id'));
								List<String> fieldNameSplit = s.split('\\.');
								String displayPointName = '';
								SObject rec = obj;
								if(fieldNameSplit.size() == 1 && !fieldToIgnoreSet.contains(fieldNameSplit[0])){
									sourceRecIdToNameMap.put((String)obj.get('Id'),(String)obj.get(fieldNameSplit[0]));
									sourceRecIDToFieldRecId.put((String)obj.get('Id'),(String)obj.get('Id'));
								}else if(fieldNameSplit.size() == 1 && fieldToIgnoreSet.contains(fieldNameSplit[0])){
									sourceRecIdToNameMap.put((String)obj.get('Id'),fieldNameSplit[0]);
									sourceRecIDToFieldRecId.put((String)obj.get('Id'),(String)obj.get('Id'));
								}
								else{
									Integer init = 1;
									for(String fieldName : fieldNameSplit){
										if(init < fieldNameSplit.size()){
											 rec = rec.getSobject(fieldName);
										}
										else{
											displayPointName = (String)rec.get(fieldName);
											sourceRecIDToFieldRecId.put((String)obj.get('Id'),(String)rec.get('Id'));
										}         
										init++;
									}
									sourceRecIdToNameMap.put((String)obj.get('Id'),displayPointName);
								}

								
							}
							else{
								sourceRecIdToNameMap.put((String)obj.get('Id'),'');
							}	
						}
					}
				}
				queryCount++;
			}

			for(Points__c pt : pointsList) {
				if(!String.isBlank(pt.Points_Rule__r.Object_API_Name__c)) 
					pointsWrapperList.add(new PointsWrapper(pt,sourceRecIdToNameMap.get(pt.Source_Record_Id__c),sourceRecIDToFieldRecId.get(pt.Source_Record_Id__c)));
				else
					pointsWrapperList.add(new PointsWrapper(pt,'',''));
			}
			PointsWrap wrap = new PointsWrap();
			wrap.pointWrapList = pointsWrapperList;
			wrap.totPoint = Integer.valueOf(String.valueOf(con.Lifetime_Points_Earned__c));
			wrap.redPoint = Integer.valueOf(String.valueOf(con.Lifetime_Points_Redeemed__c));
			return wrap;
		}
		else {
			return null;
		}
	}

	public class PointsWrap {
		@AuraEnabled public List<PointsWrapper> pointWrapList 	{get; set;}
		@AuraEnabled public Integer totPoint 	{get; set;}
		@AuraEnabled public Integer redPoint 	{get; set;}
	}

	public class PointsWrapper {
		@AuraEnabled public Points__c pointRec 		{get; set;}
		@AuraEnabled public String sourceRecName 	{get; set;}
		@AuraEnabled public String sourceRecId 		{get; set;}
		PointsWrapper(Points__c pointRec, String sourceRecName, String sourceRecId) {
			this.pointRec 		= pointRec;
			this.sourceRecName 	= sourceRecName;
			this.sourceRecId = sourceRecId;
		}
	}
}