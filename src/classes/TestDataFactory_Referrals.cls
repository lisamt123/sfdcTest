public with sharing class TestDataFactory_Referrals {
    
    public static List<Referral__c> generateReferrals(Id refereeContactId, Id refereeLeadId, Id referredByContactId, Id referredByLeadId, String referralSource,Integer numOfRecords) {
		return generateReferralsInternal(refereeContactId, refereeLeadId, referredByContactId, referredByLeadId, referralSource, numOfRecords);
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<Referral__c> generateReferralsInternal(Id refereeContactId, Id refereeLeadId, Id referredByContactId, Id referredByLeadId, String referralSource,Integer numOfRecords) {
    	List<Referral__c> referralList = new List<Referral__c>();
        
        for(Integer i = 0; i < numOfRecords; i++) {
        	Referral__c ref = new Referral__c();
			ref.Referee_Contact__c = refereeContactId;
			ref.Referee_Lead__c = refereeLeadId;
			ref.Referred_By_Contact__c = referredByContactId;
			ref.Referred_By_Lead__c = referredByLeadId;
			ref.Referral_Source__c = referralSource;
			
			referralList.add(ref);
        }
        
        return referralList;
    }
}