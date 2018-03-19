public with sharing class TestDataFactory_PointRules {
	
	public static List<Points_Rule__c> generatePointRules(boolean active, String criteriaBehavior, String sourceContactFieldAPIName, String objectAPIName, Integer numberofPointsAwarded, Id recordTypeId, Integer numOfRecords) {
		return generatePointRulesInternal(active, criteriaBehavior, sourceContactFieldAPIName, objectAPIName, numberofPointsAwarded, recordTypeId, numOfRecords);
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<Points_Rule__c> generatePointRulesInternal(boolean active, String criteriaBehavior, String sourceContactFieldAPIName, String objectAPIName, Integer numberofPointsAwarded, Id recordTypeId, Integer numOfRecords) {
    	List<Points_Rule__c> pointRuleRecList = new List<Points_Rule__c>();
        
        for(Integer i = 0; i < numOfRecords; i++) {
        	
			Points_Rule__c pointRuleRec = new Points_Rule__c();
            pointRuleRec.Active__c = active;
            pointRuleRec.Criteria_Behavior__c = criteriaBehavior;
            pointRuleRec.Source_Contact_Field_API_Name__c = sourceContactFieldAPIName;
            pointRuleRec.Object_API_Name__c = objectAPIName;
            pointRuleRec.Number_of_Points_Awarded__c = numberofPointsAwarded;
            pointRuleRec.RecordTypeId = recordTypeId;
            
            pointRuleRecList.add(pointRuleRec);
        }
        
        return pointRuleRecList;
    }    
}