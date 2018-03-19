public without sharing class PersonReferralProfileController 
{
	public static List<ReferralWrapper> referralWrapperList {get; set;}
	@AuraEnabled
    public static List<ReferralWrapper> getReferralCount(String recordID){
    	
    	String recID = recordID;
        System.debug(recID);
        referralWrapperList = new List<ReferralWrapper>();
        if(recID != null || recID != '' || recID != 'undefined')
        {
            List<User> userList = [SELECT Id, ContactId FROM User WHERE Id =: recID];
	        if(!userList.isEmpty())
	        {
                Referral_Program_Settings__c rps = Referral_Program_Settings__c.getOrgDefaults();
	        	Contact con = [SELECT Id, Referral_URL__c, Referral_Code__c FROM Contact WHERE Id =: userList[0].ContactId];
	        	List<Referral__c> referralList = [SELECT Id FROM Referral__c WHERE Referred_By_Contact__c =: userList[0].ContactId];
	        	referralWrapperList.add(new ReferralWrapper(referralList.size(), 'http://www.10kview.com/?rc='+con.Referral_Code__c, rps.Twitter_Message__c, rps.LinkedIn_Message__c, rps.Twitter_URL__c, rps.LinkedIn_URL__c, rps.Facebook_URL__c));
	        }
        }
        return referralWrapperList;
    }
    @AuraEnabled
    public static Boolean validateCurrentUser(Id profileUserId)
    {
        if( profileUserId == UserInfo.getUserId())
            return true;
        else        
            return false;
    }
    public class ReferralWrapper
    {
    	@AuraEnabled public Integer refCount   {get; set;}
    	@AuraEnabled public String refUrl 	   {get; set;}
        @AuraEnabled public String tweetMsg    {get; set;}
        @AuraEnabled public String linkedInMsg {get; set;}
        @AuraEnabled public String tweetURL    {get; set;}
        @AuraEnabled public String linkedInURL {get; set;}
        @AuraEnabled public String facebookURL {get; set;}

    	public ReferralWrapper(Integer refCount, String refUrl, String tweetMsg, String linkedInMsg, String tweetURL, String linkedInURL, String facebookURL)
    	{
    		this.refCount 	   = refCount;
    		this.refUrl 	   = refUrl;
            this.tweetMsg      = tweetMsg;
            this.linkedInMsg   = linkedInMsg;
            this.tweetURL      = tweetURL;
            this.linkedInURL   = linkedInURL;
            this.facebookURL   = facebookURL;
    	}
    }
}