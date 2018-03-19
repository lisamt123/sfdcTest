@isTest
private class ClosedWonProcessController_Test {
	
	@isTest static void test_ClosedWonProcessController() {
		List<User> userList = TestDataFactory_Users.generateUsersWith10KDeliveryPartnerProfile(true,1);
        insert userList;

		Id partnerClientrecordTypeId 		= Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList 				= TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
                                                            'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                            'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
                                                            null, 'Net 30', 'test@test.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
                                                            1);
        insert accList;

        Id serviceOpportunityrecordTypeId 	= Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Services Opportunity').RecordTypeId;
		List<Opportunity> oppList 			= TestDataFactory_Opportunity.generateOpportunities(accList[0].Id, serviceOpportunityrecordTypeId, 'Qualification', (Date.today()).addDays(30), (Date.today()).addDays(-20), (Date.today()).addDays(30), 1);
		oppList[0].Type 					= 'First Project';
		oppList[0].LeadSource				= '10kview.com';
		oppList[0].Start_Date__c			= Date.newInstance(System.Today().Year() + 1, System.Today().Month() - 1, 1);
		insert oppList;

		List<Agreement__C> agreementList 	= TestDataFactory_Agreements.generateAgreements('Test Agreement', accList[0].Id,
                                                                                             Constants.RECORDTYPEID_AGREEMENT_RETAINER, 'Active', 
                                                                                             Date.newInstance(System.Today().Year(), System.Today().Month() - 1, 1), 
                                                                                             Date.newInstance(System.Today().Year() + 1, System.Today().Month() - 1, 1), 1) ;
        agreementList[0].Rate_Structure__c 	= 'Monthly';
        insert agreementList;

        List<Project__c> projectList 		= TestDataFactory_Projects.generateProjects(accList[0].Id, 'Test Project', 1);
        projectList[0].Status__c 			= 'Open';
        insert projectList;

        Project_Agreement__c projAgrRec 	= new Project_Agreement__c();
		projAgrRec.Agreement__c 			= agreementList[0].Id;
		projAgrRec.Project__c 				= projectList[0].Id;
		insert projAgrRec;

		Id pricebookId = Test.getStandardPricebookId();

		List<Product2> prod =  TestDataFactory_Products.generateProducts('Test Product', 'Developer');
		insert prod;

		List<PricebookEntry> standardPrice = TestDataFactory_PriceBookEntries.generatePriceBookEntries(pricebookId, prod[0].Id, 10000, true);
        insert standardPrice;

        Rate_Card__c oli = new Rate_Card__c(
		    Opportunity__c 		= oppList[0].Id,
		    Role__c 			= 'Developer',
		    Region__c 			= 'India',
		    Hourly_Rate__c 		= 30,
		    Assignment_Type__c 	= 'Time & Materials'
		);
		insert oli;

		List<Rate__c> rateList = TestDataFactory_Rates.generateRateForAgreement(agreementList[0].Id, Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS, Constants.ROLE_CONSULTANT, 100, 1);
		insert rateList;

		List<Assignment__c> assignmentList 	= TestDataFactory_Assignments.generateAssignments(projectList[0].id, userList[0].ContactId, rateList[0].Id, 'Active', Constants.ROLE_CONSULTANT, Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS, true, 8, 1);
        //assignmentList[0].End_Date__c 		= assignmentList[0].End_Date__c.addYears(1);
        assignmentList[0].Role__c 			= 'Developer';
        assignmentList[0].Region__c 		= 'India';
        insert assignmentList ;

		Test.startTest();
			ClosedWonProcessController.getClosedWonOpportunity(oppList[0].Id);
			ClosedWonProcessController.getClosedWonOpportunityAggreement(oppList[0].Id, accList[0].Id);
			ClosedWonProcessController.retriveProject(agreementList[0].Id);
			List<Id> agreementIdList = new List<Id>{agreementList[0].Id};
			ClosedWonProcessController.retriveProjectAssigment(oppList[0].Id, agreementIdList, '\"2017-12-01\"', '\"2018-12-01\"');
			Date effectiveDate 			= Date.today().addYears(1).addDays(7);
			Date expirationDate 		= Date.today().addYears(2).addDays(7);
			String effectiveDateString 	= '\"' + effectiveDate.year() + '-' + effectiveDate.month() + '-' + effectiveDate.day() + '\"';
			String expirationDateString = '\"' + expirationDate.year() + '-' + expirationDate.month() + '-' + expirationDate.day() + '\"';
			ClosedWonProcessController.createNewAgreementAndRates(oppList[0].Id, effectiveDateString, expirationDateString, agreementIdList, oppList[0]);
			ClosedWonProcessController.replaceAgreementsAndAssignments(oppList[0].Id, effectiveDateString, expirationDateString, agreementIdList, JSON.serialize(ClosedWonProcessController.retriveProjectAssigment(oppList[0].Id, agreementIdList, effectiveDateString, expirationDateString)), oppList[0]);
		Test.stopTest();
	}
}