public with sharing class TestDataFactory_Leads {
	
    public static List<Lead> generateLeads(Id recordTypeId, String company, String lastName, String email, String webassessorEmail, String trailheadId, String countryCode, Integer numOfRecords) {
		return generateLeadsInternal(recordTypeId, company, lastName, email, webassessorEmail, trailheadId, countryCode, numOfRecords);
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<Lead> generateLeadsInternal(Id recordTypeId, String company, String lastName, String email, String webassessorEmail, String trailheadId, String countryCode, Integer numOfRecords) {
    	List<Lead> leadList = new List<Lead>();

        for(Integer i = 0; i < numOfRecords; i++) {
            Lead objLead = new Lead();
            objLead.Email = email;
		 	objLead.RecordTypeId = recordTypeId;
		 	objLead.lastName = lastName;
		 	objLead.Company = company;
		 	objLead.Webassessor_Email__c = webassessorEmail;
		 	objLead.Trailhead_User_Id__c = trailheadId;
		 	objLead.CountryCode = countryCode;
		 	leadList.add(objLead);
        }
        
        return leadList;
    }
}