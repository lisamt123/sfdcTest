public with sharing class TestDataFactory_Merchandise {
    
    public static List<Merchandise__c> generateMerchandise(Integer pointValue, String description, String picture, Integer numOfRecords) {
		return generateMerchandiseInternal(pointValue, description, picture, numOfRecords);
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<Merchandise__c> generateMerchandiseInternal(Integer pointValue, String description, String picture, Integer numOfRecords) {
    	List<Merchandise__c> merchandiseList = new List<Merchandise__c>();
        
        for(Integer i = 0; i < numOfRecords; i++) {
			Merchandise__c merchandise = new Merchandise__c();
			merchandise.Point_Value__c = pointValue;
			merchandise.Description__c = description;
			merchandise.Picture__c = picture;
            merchandiseList.add(merchandise);
        }
        
        return merchandiseList;
    }
}