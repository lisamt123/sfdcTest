public with sharing class TestDataFactory_License {
	public static List<sfLma__License__c> generateLicense(Id AccountId, Id ContactId, Id recordTypeId, String status, Integer noOfRows) {
		return generateLicenseInternal(AccountId, ContactId, recordTypeId, status, noOfRows);
	}

	public static List<sfLma__License__c> generateLicenseInternal(Id AccountId, Id ContactId, Id recordTypeId, String status, Integer noOfRows) {
		 List<sfLma__License__c> licenseList = new List<sfLma__License__c>();
		 for(integer i=0; i < noOfRows ; i++){
            sfLma__License__c licenseObj = new sfLma__License__c();
            licenseObj.RecordTypeId = recordTypeId;
            licenseObj.sfLma__Account__c = AccountId;
            licenseObj.sfLma__Contact__c = ContactId;
            licenseObj.sfLma__Status__c = status;
            licenseList.add(licenseObj);
        }
		 return licenseList ;
	}
}