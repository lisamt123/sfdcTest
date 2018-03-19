/**
*   Name          : ContactTriggerHandler 
*   Dated         : 12 July, 2016
*   Author        : BM
*   Useges        : Handler class for Lead trigger. 
*/
public with sharing class LeadTriggerHandler 
{
    public Static List<Countries_Regions_Continents_ISO_Codes__c> countryWithIsoList = Countries_Regions_Continents_ISO_Codes__c.getall().values();
    
    
    public static void updateWebAssessorleadId() 
    {
        Set<String> leadsIdSet          = new Set<String>();
        Set<Id> unconvertedLeadsIdSet   = new Set<Id>();
        List<Lead> leadList             = Trigger.new;
        
        for(Lead selectedLead : leadList) 
        {
            if(selectedLead.IsConverted == true) 
                leadsIdSet.add(selectedLead.id);
            else 
                unconvertedLeadsIdSet.add(selectedLead.id);
        }
        if(leadsIdSet.size() > 0)
        {
            AchievementSyncUtility.resolveRedundancy('Contact__c',transferCertificatesAndBadges(leadsIdSet));
        }
        else
            AchievementSyncUtility.resolveRedundancy('Lead__c',unconvertedLeadsIdSet);
    }
    
    public static Set<Id> transferCertificatesAndBadges(Set<String> leadsIdSet)
    {
        List<Expert_Achievement__c> listToUpdate = new List<Expert_Achievement__c>();
        Set<Id> contactIdSet = new Set<Id>();
        for(Expert_Achievement__c selectedExpertAchievement: [SELECT Id,Lead__c,Lead__r.ConvertedContactId,Contact__c,Created_From_Sync__c FROM Expert_Achievement__c WHERE Lead__c IN : leadsIdSet])
        {
            contactIdSet.add(selectedExpertAchievement.Lead__r.ConvertedContactId);
            selectedExpertAchievement.Contact__c    = selectedExpertAchievement.Lead__r.ConvertedContactId;
            selectedExpertAchievement.Lead__c       = null;
            listToUpdate.add(selectedExpertAchievement);
        }
        if(listToUpdate.size() > 0)
            update listToUpdate;
        List<Expert_Skill__c> listToUpdateExpertSkills = new List<Expert_Skill__c>();
        for(Expert_Skill__c selectedExpertSkill: [SELECT Id,Lead__c,Lead__r.ConvertedContactId,Contact__c FROM Expert_Skill__c WHERE Lead__c IN : leadsIdSet])
        {
            contactIdSet.add(selectedExpertSkill.Lead__r.ConvertedContactId);
            selectedExpertSkill.Contact__c  = selectedExpertSkill.Lead__r.ConvertedContactId;
            selectedExpertSkill.Lead__c     = null;
            listToUpdateExpertSkills.add(selectedExpertSkill);
        }
        if(listToUpdateExpertSkills.size() > 0)
            update listToUpdateExpertSkills;

        return contactIdSet;
    }

    public static void updateRefferalRecords() {
        Map<String,String> leadandContactMap = new Map<String,String>();
        for(Lead selectedLead : (List<Lead>) Trigger.new) {
            if(selectedLead.IsConverted == true)
                leadandContactMap.put(selectedLead.id,selectedLead.ConvertedContactId);
        }
        List<Referral__c> referralList = [SELECT ID,Referee_Lead__c,Referred_By_Contact__c,Referred_By_Lead__c,Referee_Contact__c
                                            FROM Referral__c 
                                            WHERE Referee_Lead__c IN: leadandContactMap.keySet() OR Referred_By_Lead__c IN : leadandContactMap.keySet()];
        for(Referral__c rferral : referralList) {
            if(leadandContactMap.containsKey(rferral.Referee_Lead__c)) {
                rferral.Referee_Contact__c = leadandContactMap.get(rferral.Referee_Lead__c);
                rferral.Referee_Lead__c = null;
            }
            if(leadandContactMap.containsKey(rferral.Referred_By_Lead__c)) {
                rferral.Referred_By_Contact__c = leadandContactMap.get(rferral.Referred_By_Lead__c);
                rferral.Referred_By_Lead__c = null;
            }
        }
        update referralList;
        List<Old_Referral_Code__c> oldReferralList = [SELECT ID,Referral_Code__c,Lead__c,Contact__c
                                            FROM Old_Referral_Code__c 
                                            WHERE Lead__c IN: leadandContactMap.keySet()];
        for(Old_Referral_Code__c oldRferral : oldReferralList) {
            if(leadandContactMap.containsKey(oldRferral.Lead__c)) {
                oldRferral.Contact__c = leadandContactMap.get(oldRferral.Lead__c);
                oldRferral.Lead__c = null;
            }
        } 
        update oldReferralList;                                  
    }

    public static void populateReferralCode() {
        List<String> referralCodeList = new List<String>();
        Integer counter = 0;
        for(Lead lead : (List<Lead>)Trigger.new) {
            if(lead.Referral_Code__c == null || lead.Referral_Code__c == '' ) {
                counter++;
            }
        }
        referralCodeList = new List<String>(checkDuplicate(new Set<String>(),counter));
        counter = 0;
        for(Lead lead : (List<Lead>)Trigger.new) {
            if(lead.Referral_Code__c == null || lead.Referral_Code__c == '') {
                lead.Referral_Code__c = referralCodeList[counter];
                counter++;
            }
        }
    }
    public static Set<String> checkDuplicate(Set<String> referralCodeSet,Integer counter) {
        String charSequense         = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        String digitSequense        = '0123456789';
        Set<String> duplicateReferralCodeSet = new Set<String>();
        for(Integer count = 0 ; count < counter ; count++) {
            Boolean flag = true;
            while(flag) {
                String key = generateReferralCode();
                if(!key.containsOnly(charSequense) && !key.containsOnly(digitSequense)){
                    referralCodeSet.add(key);
                    flag = false;
                }
            }
        }
        for(Contact selectedContact : [ SELECT Referral_Code__c FROM Contact WHERE Referral_Code__c IN : referralCodeSet AND Referral_Code__c != null]) {
            duplicateReferralCodeSet.add(selectedContact.Referral_Code__c);
        }
        for(Lead selectedLead : [ SELECT Referral_Code__c FROM Lead WHERE Referral_Code__c IN : referralCodeSet AND Referral_Code__c != null]) {
            duplicateReferralCodeSet.add(selectedLead.Referral_Code__c);
        }
        for(Old_Referral_Code__c selectedOldReferralCode : [ SELECT Referral_Code__c FROM Old_Referral_Code__c WHERE Referral_Code__c IN : referralCodeSet AND Referral_Code__c != null]) {
            duplicateReferralCodeSet.add(selectedOldReferralCode.Referral_Code__c);
        }
        if(duplicateReferralCodeSet.size() > 0) {
            referralCodeSet.removeAll(duplicateReferralCodeSet);
            checkDuplicate(referralCodeSet,duplicateReferralCodeSet.size());
        }
        return referralCodeSet;
    }
    
    public static void createOldReferralRecords() {
        List<Old_Referral_Code__c> oldReferralCodesList = new List<Old_Referral_Code__c>();
        for(Lead selectedLead : (List<Lead> )Trigger.new) {
            if (Trigger.oldMap.get(selectedLead.Id).get('Referral_Code__c') != null && selectedLead.Referral_Code__c != Trigger.oldMap.get(selectedLead.Id).get('Referral_Code__c')) {
                oldReferralCodesList.add(new Old_Referral_Code__c(Lead__c = selectedLead.Id, Referral_Code__c = (String)Trigger.oldMap.get(selectedLead.Id).get('Referral_Code__c')));
            }
        }
        insert oldReferralCodesList;
    }

    public static void createOldReferralRecordsFromDeletedLeads() {
        List<Old_Referral_Code__c> oldReferralCodesList = new List<Old_Referral_Code__c>();
        for(Lead selectedLead : (List<Lead> )Trigger.old) {
            if ( selectedLead.Referral_Code__c != null && selectedLead.MasterRecordId != null) {
                oldReferralCodesList.add(new Old_Referral_Code__c(Lead__c = selectedLead.MasterRecordId , Referral_Code__c = selectedLead.Referral_Code__c));
            }
        }
        insert oldReferralCodesList;
    }

    public static String generateReferralCode() {

        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,6);
       
        return guid.toUpperCase();
    }
    
    // This New Process has been created By AK to populate the region Basd on ISO code 2 digit (CountryCode) field After state country picklist enabled
    
    public static void populateCountryBasedISOCode(List<Lead> leadList) {
        Map<String,String> isoWithRegionMap  = new Map<String,String> ();
        for(Countries_Regions_Continents_ISO_Codes__c countryWithIsos : countryWithIsoList)
            If(countryWithIsos.ISO_2__c != null && countryWithIsos.ISO_2__c != '')
                isoWithRegionMap.put(countryWithIsos.ISO_2__c,countryWithIsos.Region__c);
        
        for(Lead lead : (List<Lead>)leadList ) 
            if(lead.CountryCode != null && lead.CountryCode != '' && isoWithRegionMap.ContainsKey(lead.CountryCode)) 
                Lead.Region__c = isoWithRegionMap.get(lead.CountryCode);         
    }
}