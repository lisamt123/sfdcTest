public with sharing class TestDataFactory_PointsRuleCriteria {
    
    public static List<Points_Rule_Criteria__c> generatePointRuleCriteria(String fieldAPIName, String fieldValue, String operator, Id pointRuleId, Integer numOfRecords) {
		return generatePointRuleCriteriaInternal(fieldAPIName, fieldValue, operator, pointRuleId, numOfRecords);
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<Points_Rule_Criteria__c> generatePointRuleCriteriaInternal(String fieldAPIName, String fieldValue, String operator, Id pointRuleId, Integer numOfRecords) {
    	List<Points_Rule_Criteria__c> pointRuleRecList = new List<Points_Rule_Criteria__c>();
        
        for(Integer i = 0; i < numOfRecords; i++) {
            
            Points_Rule_Criteria__c pointRuleCriteriaRec = new Points_Rule_Criteria__c();
	        pointRuleCriteriaRec.Field_API_Name__c = fieldAPIName;
	        pointRuleCriteriaRec.Field_Value__c = fieldValue;
	        pointRuleCriteriaRec.Operator__c = operator;
	        pointRuleCriteriaRec.Points_Rule__c = pointRuleId;
            
            pointRuleRecList.add(pointRuleCriteriaRec);
        }
        
        return pointRuleRecList;
    }   
}