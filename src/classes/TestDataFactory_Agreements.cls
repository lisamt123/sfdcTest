public with sharing class TestDataFactory_Agreements {
    
    public static List<Agreement__c> generateAgreements(String agreementName, Id accountId, Id recordTypeId, String status, Date effectiveDate, Date validThrough, Integer numberOfAgreementsPerAccount) {
    	return generateAgreementsInternal(agreementName, accountId, recordTypeId, status, effectiveDate, validThrough, numberOfAgreementsPerAccount);
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<Agreement__c> generateAgreementsInternal(String agreementName, Id accountId, Id recordTypeId, String status, Date effectiveDate, Date validThrough, Integer numberOfAgreementsPerAccount) {
    	List<Agreement__c> agreementList = new List<Agreement__c>();
        
        for(Integer i = 0; i < numberOfAgreementsPerAccount; i++) {
        	Agreement__c agreement = new Agreement__c();
        	agreement.Name = agreementName;
            agreement.Account__c = accountId;
            agreement.RecordTypeId = recordTypeId;
            agreement.Status__c = status;//'Active';
            agreement.Effective_Date__c = effectiveDate;//Date.newInstance(System.Today().Year(), System.Today().Month() - 1, 1);
            agreement.Valid_Through__c = validThrough;//Date.newInstance(System.Today().Year() + 1, System.Today().Month() - 1, 1);
            agreementList.add(agreement);
        }

        return agreementList;
    }
}