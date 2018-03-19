public with sharing class TestDataFactory_Points {
    
    public static List<Points__c> generatePoints(Id storyId, Id contactId, Integer numberOfPoints, Id pointRuleId, Integer numOfRecords) {
		return generatePointsInternal(storyId, contactId, numberOfPoints, pointRuleId, numOfRecords);
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<Points__c> generatePointsInternal(Id storyId, Id contactId, Integer numberOfPoints, Id pointRuleId, Integer numOfRecords) {
    	List<Points__c> pointList = new List<Points__c>();
        
        for(Integer i = 0; i < numOfRecords; i++) {
            
            Points__c pointRec = new Points__c();
            pointRec.Source_Record_Id__c = storyId;
            pointRec.Contact__c = contactId;
            pointRec.Number_of_Points__c = numberOfPoints;
            pointRec.Points_Rule__c = pointRuleId;
            
            pointList.add(pointRec);
        }
        
        return pointList;
    }  
}