public with sharing class TestDataFactory_ProjectAgreements {
	
	public static List<Project_Agreement__C> generateProjectAgreements(Id projecId, Id agreementId, Integer numOfRecords) {
		return generateProjectAgreementsInternal(projecId, agreementId, numOfRecords);
	}

	private static List<Project_Agreement__C> generateProjectAgreementsInternal(Id projecId, Id agreementId, Integer numOfRecords) {
		List<Project_Agreement__C> projectAgreementList = new List<Project_Agreement__C>();
		for(Integer i = 0; i < numOfRecords; i++) {
            Project_agreement__c prjAgreement = new Project_agreement__c();
        	prjAgreement.agreement__C = agreementId;
        	prjAgreement.project__C = projecId;
            projectAgreementList.add(prjAgreement); 
        } 
        
        return projectAgreementList;
	}
}