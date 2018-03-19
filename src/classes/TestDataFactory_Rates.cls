public with sharing class TestDataFactory_Rates {
    
    public static List<Rate__c> generateRateForAgreement(Id agreementId, String assignmentType, String role, Decimal hourlyRate, Integer numOfRecords) {
		return generateRateForAgreementInternal(agreementId, assignmentType, role, hourlyRate, numOfRecords);
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<Rate__c> generateRateForAgreementInternal(Id agreementId, String assignmentType, String role, Decimal hourlyRate, Integer numOfRecords) {
    	List<Rate__c> rateList = new List<Rate__c>();
        
        for(integer i = 0; i < numOfRecords ; i ++) {
            Rate__c rate = new Rate__c();
            rate.Name = 'Test Rate' + i;
            if(assignmentType == Constants.ASSIGNMENTTYPE_NAMEDRESOURCE) {
                rate.RecordTypeId = Constants.RECORDTYPEID_RATE_NAMED_RESOURCE;
            }
            else if(assignmentType == Constants.ASSIGNMENTTYPE_RETAINEDCAPACITY) {
                rate.RecordTypeId = Constants.RECORDTYPEID_RATE_RETAINED_CAPACITY;
            }
            else if(assignmentType == Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS) {
                rate.RecordTypeId = Constants.RECORDTYPEID_RATE_TIMEANDMATERIALS;
            }
            rate.Agreement__c = agreementId;
            rate.Assignment_Type__c = assignmentType;
            rate.Role__c = role;
            rate.Hourly_Rate__c = hourlyRate;
            rateList.add(rate);
        }
        
        return rateList ;
    }
}