public with sharing class LicenseTriggerHandler {

	public static void setAccountAndContact(List<sfLma__License__c> licenseList) {
		Set<String> packageLicenseIdSet 			= new Set<String>();
		Set<String> licenseIdSet 					= new Set<String>();

		for(sfLma__License__c licenseRec : licenseList) {
			if(licenseRec.sfLma__Account__c == null || licenseRec.sfLma__Contact__c == null) {
				if(licenseRec.sfLma__Package_License_ID__c != null && licenseRec.sfLma__Package_License_ID__c != '') {
					packageLicenseIdSet.add(licenseRec.sfLma__Package_License_ID__c);
					licenseIdSet.add(licenseRec.Id);
				}
			}
		}
		
		if(!licenseIdSet.isEmpty())
			LicenseTriggerHandler.processAutomation(packageLicenseIdSet, licenseIdSet);
	}

	@future
	public static void processAutomation(Set<String> packageLicenseIdSet, Set<String> licenseIdSet) {
		Map<String, String> packageIdToAccConMap 	= new Map<String, String>();
		List<sfLma__License__c> licenseList 		= [SELECT Id, sfLma__Package_License_ID__c, sfLma__Account__c, sfLma__Contact__c 
															FROM sfLma__License__c 
															WHERE Id IN: licenseIdSet];
		if(!packageLicenseIdSet.isEmpty()) {
			for(sfLma__License__c existingLicenseRec : [SELECT Id, sfLma__Package_License_ID__c, sfLma__Account__c, sfLma__Contact__c 
															FROM sfLma__License__c 
															WHERE sfLma__Package_License_ID__c IN: packageLicenseIdSet 
															AND sfLma__Account__c != null AND sfLma__Contact__c != null]) {
				packageIdToAccConMap.put(existingLicenseRec.sfLma__Package_License_ID__c, existingLicenseRec.sfLma__Account__c + '##' + existingLicenseRec.sfLma__Contact__c);
			}
		}

		if(!packageIdToAccConMap.isEmpty()) {
			for(sfLma__License__c licenseRec : licenseList) {
				if(licenseRec.sfLma__Account__c == null) {
					licenseRec.sfLma__Account__c = packageIdToAccConMap.get(licenseRec.sfLma__Package_License_ID__c).split('##')[0];
				}
				if(licenseRec.sfLma__Contact__c == null) {
					licenseRec.sfLma__Contact__c = packageIdToAccConMap.get(licenseRec.sfLma__Package_License_ID__c).split('##')[1];
				}
			}

			if(!licenseList.isEmpty()) {
				update licenseList;
			}
		}
	}
}