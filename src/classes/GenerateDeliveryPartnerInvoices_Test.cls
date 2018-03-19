@isTest
private class GenerateDeliveryPartnerInvoices_Test {
	
	@isTest static void test_method_one() {
		// Implement test code
		TestDataFactory factory = new TestDataFactory ();
        List<Account> accList = factory.generateAccounts(1);
        insert accList;
        
        List<agreement__C> agreementList = factory.generateRetainerAgreementsForAccounts(accList, 1);
        agreementList[0].Rate_Structure__c = 'Monthly';
        agreementList[0].Status__c = 'Active';
        insert agreementList;
        
        system.debug('AGREEMENT !!!! : ' + agreementList);
        pagereference pg=Page.GenerateInvoices;
        Test.setCurrentPageReference(pg); //utgr
        apexpages.currentpage().getparameters().put('agreementId',agreementList[0].id);
        

        accList[0].Billing_Code__c = 'Test-6';
        update accList;
         
         
        accList[0].Payment_Terms__c = 'Null';
        update accList;
         
        //generating projects
        List<Project__C> prjList = factory.generateProjects(accList[0].id,1);
        prjList[0].name ='Test Prj';
        insert prjList;
         
        //generating project agreement
        Project_agreement__c prjAgreement = factory.generateProjectAgreements(prjList[0].id,agreementList[0].id);
        insert prjAgreement;
         
        agreementList[0].Payment_Terms__c = 'Net 15';
        agreementList[0].RecordTypeId = Constants.RECORDTYPEID_AGREEMENT_DELIVERYPARTER;
        update agreementList;
         
        List<Rate__c> ratelist = factory.generateRateForAgreement(agreementList[0].id,Constants.ASSIGNMENTTYPE_NAMEDRESOURCE,Constants.ROLE_CONSULTANT,1);
        rateList[0].Hours_Per_Month__c = 2;
        rateList[0].Monthly_Rate__c = 2;
        insert ratelist;
        
        //generating assignments
        List<Assignment__c> assignmentList = factory.generateAssignment(prjList[0].id,Constants.ASSIGNMENTTYPE_NAMEDRESOURCE ,1);
        assignmentList[0].Billable__c = true;
        assignmentList[0].Cost_Rate__c = rateList[0].Id;
        assignmentList[0].Role__c = Constants.ROLE_CONSULTANT ; 
        insert assignmentList;

        system.debug('ASSIGNMENT !!!! : ' + assignmentList);
        
        List<Time_Entry__c> timeEntryList = factory.generateTimeEntry(assignmentList[0].id ,'test',system.today(),2,1);
        insert timeEntryList;
         
		Test.startTest();
			GenerateDeliveryPartnerInvoicesBatch invoiceBatch = new GenerateDeliveryPartnerInvoicesBatch();
            Database.executeBatch(invoiceBatch,1);
		Test.stopTest();
	}
	
	@isTest static void test_method_two() {
		// Implement test code
		// Implement test code
		TestDataFactory factory = new TestDataFactory ();
        List<Account> accList = factory.generateAccounts(1);
        insert accList;
        
        List<agreement__C> agreementList = factory.generateRetainerAgreementsForAccounts(accList, 1);
        agreementList[0].Rate_Structure__c = 'weekly';
        insert agreementList;
        
        system.debug('AGREEMENT !!!! : ' + agreementList);
        pagereference pg=Page.GenerateInvoices;
        Test.setCurrentPageReference(pg);
        apexpages.currentpage().getparameters().put('agreementId',agreementList[0].id);
        

        accList[0].Billing_Code__c = 'Test-6';
        update accList;
         
         
        accList[0].Payment_Terms__c = 'Null';
        update accList;
         
        //generating projects
        List<Project__C> prjList = factory.generateProjects(accList[0].id,1);
        prjList[0].name ='Test Prj';
        insert prjList;
         
        //generating project agreement
        Project_agreement__c prjAgreement = factory.generateProjectAgreements(prjList[0].id,agreementList[0].id);
        insert prjAgreement;
         
        agreementList[0].Payment_Terms__c = 'Net 15';
        agreementList[0].RecordTypeId = Constants.RECORDTYPEID_AGREEMENT_DELIVERYPARTER;
        update agreementList;
         
        List<Rate__c> ratelist = factory.generateRateForAgreement(agreementList[0].id,Constants.ASSIGNMENTTYPE_NAMEDRESOURCE,Constants.ROLE_CONSULTANT,1);
        rateList[0].Hours_Per_Month__c = 2;
        insert ratelist;
        
        //generating assignments
        List<Assignment__c> assignmentList = factory.generateAssignment(prjList[0].id,Constants.ASSIGNMENTTYPE_NAMEDRESOURCE ,1);
        assignmentList[0].Billable__c = true;
        assignmentList[0].Cost_Rate__c = rateList[0].Id;
        assignmentList[0].Role__c = Constants.ROLE_CONSULTANT ; 
        insert assignmentList;

        system.debug('ASSIGNMENT !!!! : ' + assignmentList);
        
        List<time_entry__c> timeEntryList = factory.generateTimeEntry(assignmentList[0].id ,'test',system.today(),2,1);
        insert timeEntryList;
         
		Test.startTest();
            GenerateDeliveryPartnerInvoicesBatch invoiceBatch = new GenerateDeliveryPartnerInvoicesBatch();
            Database.executeBatch(invoiceBatch,1);
        Test.stopTest();
	}
	
}