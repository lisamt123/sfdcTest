public with sharing class AccountTriggerHandler 
{
    public Static List<Countries_Regions_Continents_ISO_Codes__c> countryWithIsoList = Countries_Regions_Continents_ISO_Codes__c.getall().values();
    public static void runAccountInvoiceRollupsUtility(List<Account> accountList)
    {
        accountList = [SELECT Id FROM Account WHERE Id IN : accountList];
        AccountInvoiceRollupsUtility.calcuateOutstandingInvoiceAmounts(accountList);

        List<Id> accountIds = new List<Id>();
        for (Account acc : accountList) 
        {
            accountIds.add(acc.Id);
        }
        if(accountIds.size() > 0) 
        {
            AccountInvoiceRollupsUtility.updateAccountServiceStatus(accountIds);
        }
    }
    
    // This New Process has been created By AK to populate the region Basd on ISO code 2 digit (CountryCode) field After state country picklist enabled 
    public static void populateCountryBasedISOCode(List<Account> accountList) {
        Map<String,String> isoWithRegionMap  = new Map<String,String>();
        
        for(Countries_Regions_Continents_ISO_Codes__c countryWithIsos : countryWithIsoList)
            If(countryWithIsos.ISO_2__c != null && countryWithIsos.ISO_2__c != '')
                isoWithRegionMap.put(countryWithIsos.ISO_2__c,countryWithIsos.Region__c);
            
        for(Account account: (List<Account>)accountList) 
            if(account.BillingCountryCode != null && account.BillingCountryCode != '' && isoWithRegionMap.ContainsKey(account.BillingCountryCode)) 
                account.Region_Picklist__c = isoWithRegionMap.get(account.BillingCountryCode);
             
    }

    public static void updateAccountRelatedContact(List<Account> oldAccountList, List<Account> newAccountList) {
        List<String> updatedAccountIdList = new List<String>();
        for(Integer i = 0; i < oldAccountList.size(); i++) {
            if(oldAccountList[i].Region_Picklist__c != newAccountList[i].Region_Picklist__c)
                updatedAccountIdList.add(newAccountList[i].Id);
        }
        if(updatedAccountIdList.size() > 0) {
            List<Contact> contactAccountWiseList = [Select Id, Name, Region_Picklist__c FROM Contact where AccountId IN: updatedAccountIdList];
            update contactAccountWiseList ;
        }
    }
}