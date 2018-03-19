@isTest
private class GenerateProjectInvoicesBatch_Test 
{
	@isTest static void test_GenerateInvoicesBatch() 
	{
		TestDataFactory factory = new TestDataFactory ();
         List<Account> accList = factory.generateAccounts(1);
         insert accList;
         
         List<agreement__C> agreementList = factory.generateRetainerAgreementsForAccounts(accList, 1);
         agreementList[0].Rate_Structure__c = 'Monthly';
         agreementList[0].Status__c = 'Active';
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
         prjList[0].Invoiced_Separately__c = true;
         prjList[0].Project_Billing_Code__c = '123456';
         insert prjList;
         
         //generating project agreement
         Project_agreement__c prjAgreement = factory.generateProjectAgreements(prjList[0].id,agreementList[0].id);
         insert prjAgreement;
         
         agreementList[0].Payment_Terms__c = 'Net 15';
         update agreementList;
         
         List<Rate__c> ratelist = factory.generateRateForAgreement(agreementList[0].id,Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS,Constants.ROLE_CONSULTANT,1);
         rateList[0].Hours_Per_Month__c = 2;
         insert ratelist;
        
         //generating assignments
         List<Assignment__c> assignmentList = factory.generateAssignment(prjList[0].id,Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS ,1);
         assignmentList[0].Billable__c = true;
         assignmentList[0].Rate__c = rateList[0].Id;
         assignmentList[0].Role__c = Constants.ROLE_CONSULTANT ; 
         insert assignmentList;

         system.debug('ASSIGNMENT !!!! : ' + assignmentList);
         
         List<time_entry__c> timeEntryList = factory.generateTimeEntry(assignmentList[0].id ,'test',system.today(),2,1);
         insert timeEntryList;
         
		Test.startTest();
			GenerateProjectInvoicesBatch projectInvoiceBatch = new GenerateProjectInvoicesBatch();
            Database.executeBatch(projectInvoiceBatch);
		Test.stopTest();
	}
}