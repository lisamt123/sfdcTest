/**
*   Name          : ContactTriggerHandler 
*   Dated         : 6 July, 2016
*   Author        : BM
*   Useges        : Handler class for Contact trigger. 
*/
public with sharing class ContactTriggerHandler 
{
    public Static List<Countries_Regions_Continents_ISO_Codes__c> countryWithIsoList = Countries_Regions_Continents_ISO_Codes__c.getall().values();
    public void updateWebAssessorContactId(List<Contact> contactList,Map<Id,Contact> contactOldMap)
    {
        Map<Id,String> contactIdMap = new Map<Id,String>();
        for(Contact con : contactList)
        {
            if(contactOldMap != null)
            {
                if(con.Webassessor_Email__c != null && con.Trailhead_User_Id__c != null && con.Updated_Created_From_Lead__c)
                {
                    contactIdMap.put(con.id,'both');
                }
                else if(con.Webassessor_Email__c != contactOldMap.get(con.Id).Webassessor_Email__c && con.Webassessor_Email__c != null && con.Trailhead_User_Id__c != contactOldMap.get(con.Id).Trailhead_User_Id__c && con.Trailhead_User_Id__c != null)
                {
                    contactIdMap.put(con.id,'both');
                }
                else if(con.Webassessor_Email__c != contactOldMap.get(con.Id).Webassessor_Email__c && con.Webassessor_Email__c != null)
                {
                    contactIdMap.put(con.id,'certificate');
                }
                else if(con.Trailhead_User_Id__c != contactOldMap.get(con.Id).Trailhead_User_Id__c && con.Trailhead_User_Id__c != null)
                {
                    contactIdMap.put(con.id,'badge');
                }
            }
            else 
            {
                if(con.Webassessor_Email__c != null && con.Trailhead_User_Id__c != null)
                {
                    contactIdMap.put(con.id,'both');
                }
                else if(con.Webassessor_Email__c != null)
                {
                    contactIdMap.put(con.id,'certificate');
                }
                else if(con.Trailhead_User_Id__c != null)
                {
                    contactIdMap.put(con.id,'badge');
                }
            }
        }
        AchievementSyncUtility.resolveRedundancy('Contact__c',Trigger.newMap.keySet());
        if(contactIdMap.size() > 0)
            Id batchInstanceId = Database.executeBatch(new AchievementSyncBatch(contactIdMap,false,'Contact'), 1); 
    }

    public void updateCreatedFromLead(List<Contact> contactList)
    {
        for(Contact con : contactList)
        {
            con.Updated_Created_From_Lead__c = false;
        }
    }

    public void populateReferralCode() {
        List<String> referralCodeList = new List<String>();
        Integer counter = 0;
        for(Contact con : (List<Contact>)Trigger.new) {
            if(con.Referral_Code__c == null || con.Referral_Code__c == '' ) {
                counter++;
            }
        }
        referralCodeList = new List<String>(checkDuplicate(new Set<String>(),counter));
        counter = 0;
        for(Contact con : (List<Contact>)Trigger.new) {
            if(con.Referral_Code__c == null || con.Referral_Code__c == '') {
                con.Referral_Code__c = referralCodeList[counter];
                counter++;
            }
        }
    }
    public Set<String> checkDuplicate(Set<String> referralCodeSet,Integer counter) {
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

    public static String generateReferralCode() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,6);
        return guid.toUpperCase();
    }

    public static void createOldReferralRecords() {
        List<Old_Referral_Code__c> oldReferralCodesList = new List<Old_Referral_Code__c>();
        for(Contact selectedContact : (List<Contact> )Trigger.new) {
            if (Trigger.oldMap.get(selectedContact.Id).get('Referral_Code__c') != null && selectedContact.Referral_Code__c != Trigger.oldMap.get(selectedContact.Id).get('Referral_Code__c')) {
                oldReferralCodesList.add(new Old_Referral_Code__c(Contact__c = selectedContact.Id, Referral_Code__c = (String)Trigger.oldMap.get(selectedContact.Id).get('Referral_Code__c')));
            }
        }
        insert oldReferralCodesList;
    }

    public static void createOldReferralRecordsFromDeletedContacts() {
        List<Old_Referral_Code__c> oldReferralCodesList = new List<Old_Referral_Code__c>();
        for(Contact selectedContact : (List<Contact> )Trigger.old) {
            if ( selectedContact.Referral_Code__c != null && selectedContact.MasterRecordId != null) {
                oldReferralCodesList.add(new Old_Referral_Code__c(Contact__c = selectedContact.MasterRecordId , Referral_Code__c = selectedContact.Referral_Code__c));
            }
        }
        insert oldReferralCodesList;
    }
    // This New Process has been created By AK to populate the region Except ISO code
    public static void populateCountryBasedISOCode(List<Contact> contactList) {
        
        SET<Id> accountIdSet = new SET<Id>();
        for(Contact con : contactList) 
            accountIdSet.add(con.AccountId);

        Map<Id, String> accountIdToRegionMap = new Map<Id, String>();
        for(Account acc: [SELECT Id, Region_Picklist__c FROM Account where Id IN: accountIdSet]) 
            accountIdToRegionMap.put(acc.Id, acc.Region_Picklist__c);

        Map<String,String> isoWithRegionMap  = new Map<String,String>();
        for(Countries_Regions_Continents_ISO_Codes__c countryWithIsos : countryWithIsoList) {
            if(countryWithIsos.ISO_2__c != null && countryWithIsos.ISO_2__c != '') {
                isoWithRegionMap.put(countryWithIsos.ISO_2__c,countryWithIsos.Region__c);
            }
        }
        for(Contact contact : (List<Contact>)contactList) { 
            if(contact.MailingCountryCode != null && contact.MailingCountryCode != '' && isoWithRegionMap.containsKey(contact.MailingCountryCode)) {
                contact.Region_Picklist__c = isoWithRegionMap.get(contact.MailingCountryCode);
            }
            else {
                contact.Region_Picklist__c = accountIdToRegionMap.get(contact.AccountId);
            }
        }
    }
}