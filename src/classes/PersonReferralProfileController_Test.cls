@isTest
private class PersonReferralProfileController_Test {
	
	@isTest static void test_method_one() 
	{
		TestDataFactory factory = new TestDataFactory();   
        List<User>userList = factory.createUsersWith10KCustomerProfile(1);
        Insert userList;

        Referral__c referralRec = new Referral__c();
        referralRec.Referred_By_Contact__c = userList[0].ContactId;
        insert referralRec;

        System.RunAs(userList[0]){
        	PersonReferralProfileController.getReferralCount(UserInfo.getUserId());
        	Boolean isCurrentUser = PersonReferralProfileController.validateCurrentUser(UserInfo.getUserId());
        	System.assertEquals(isCurrentUser, true);
        }
	}
}