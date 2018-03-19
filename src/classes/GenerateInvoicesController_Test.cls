@isTest
private class GenerateInvoicesController_Test {

   @IsTest static void test_method_one() {
        // Implement test code
        
         TestDataFactory factory = new TestDataFactory ();
         List<Account> accList = factory.generateAccounts(1);
         insert accList;
         
         List<agreement__C> agreementList = factory.generateRetainerAgreementsForAccounts(accList, 1);
         agreementList[0].Rate_Structure__c = 'Monthly';
         insert agreementList;
         
         system.debug('AGREEMENT !!!! : ' + agreementList);

         pagereference pg=Page.GenerateInvoices;
         Test.setCurrentPageReference(pg);
         apexpages.currentpage().getparameters().put('agreementId',agreementList[0].id);
        
         GenerateInvoicesController cntrlr =new GenerateInvoicesController();

         accList[0].Billing_Code__c = 'Test-6';
         update accList;
         
         cntrlr =new GenerateInvoicesController();
         
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
        
         cntrlr = new GenerateInvoicesController();
         
         cntrlr.selectedMonth = timeEntryList[0].Date__c.Year() + '-' + timeEntryList[0].Date__c.Month();
         cntrlr.selectedPeriodEndDate = timeEntryList[0].Date__c.Year() + '-' + timeEntryList[0].Date__c.Month() + '-' + timeEntryList[0].Date__c.Day();
         cntrlr.fetchProjects();
         cntrlr.selectedProject = prjList[0].id;
         cntrlr.getProjectOptions();        
         cntrlr.fetchTimeEntryData();
         cntrlr.getMonthOptions();
       
    }
    
    @isTest static void test_method_two() {
        // Implement test code
        
         TestDataFactory factory = new TestDataFactory ();
         List<Account> accList = factory.generateAccounts(1);
         insert accList;
         
         List<Contact> contList = factory.generateContactsForAccounts(accList, 1);
         insert contList;
         
         List<agreement__C> agreementList = factory.generateRetainerAgreementsForAccounts(accList, 1); 
         agreementList[0].Effective_Date__c = Date.newInstance(System.today().Year(), System.today().Month(), 1);
         agreementList[0].Valid_Through__c  = Date.newInstance(System.today().Year(), System.today().Month()+1, 1) - 1;
         agreementList[0].Rate_Structure__c = 'Weekly';
         insert agreementList;
         
         pagereference pg=Page.GenerateInvoices;
         Test.setCurrentPageReference(pg);
         apexpages.currentpage().getparameters().put('agreementId',agreementList[0].id);
        
         GenerateInvoicesController cntrlr = new GenerateInvoicesController();

         accList[0].Billing_Code__c = 'Test-6';
         update accList;
         
         cntrlr =new GenerateInvoicesController();
         
         accList[0].Payment_Terms__c = 'Null';
         update accList;
         
         //generating projects
         List<Project__C> prjList = factory.generateProjects(accList[0].id,1);
         prjList[0].Project_Billing_Code__c ='ABCG12';
         insert prjList;
         
         //generating project agreement
         Project_agreement__c prjAgreement = factory.generateProjectAgreements(prjList[0].id,agreementList[0].id);
         insert prjAgreement ;
         
         agreementList[0].Payment_Terms__c = 'Net 15';
         update agreementList;
         
         List<Rate__c> ratelist = factory.generateRateForAgreement(agreementList[0].id,Constants.ASSIGNMENTTYPE_NAMEDRESOURCE,Constants.ROLE_CONSULTANT,1);
         rateList[0].Hours_Per_Week__c = 40;
         rateList[0].Number_of_Weeks__c = 4;
         rateList[0].Weekly_Rate__c = 1000;
         insert ratelist;

         List<Rate__c> ratelist1 = factory.generateRateForAgreement(agreementList[0].id,Constants.ASSIGNMENTTYPE_NAMEDRESOURCE,Constants.ROLE_CONSULTANT,1);
         rateList1[0].Hours_Per_Week__c = 40;
         rateList1[0].Number_of_Weeks__c = 4;
         rateList1[0].Weekly_Rate__c = 1000;
         insert ratelist1 ;
         List<Rate__c> ratelist2 = factory.generateRateForAgreement(agreementList[0].id,Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS,Constants.ROLE_CONSULTANT,1);
         rateList2[0].Hours_Per_Week__c = 40;
         rateList2[0].Number_of_Weeks__c = 4;
         rateList2[0].Weekly_Rate__c = 1000;
         insert ratelist2 ;
             
         List<Assignment__c> assignmentList = factory.generateAssignment(prjList[0].id,Constants.ASSIGNMENTTYPE_NAMEDRESOURCE,1);
         assignmentList[0].Billable__c = true;
         assignmentList[0].role__c = Constants.ROLE_CONSULTANT ; 
         assignmentList[0].Resource__c = contList[0].id;
         assignmentList[0].Rate__c = rateList[0].Id;
         insert assignmentList ;
         List<Assignment__c> assignmentList1 = factory.generateAssignment(prjList[0].id,Constants.ASSIGNMENTTYPE_NAMEDRESOURCE,1);
         assignmentList1[0].Billable__c = true;
         assignmentList1[0].role__c = Constants.ROLE_CONSULTANT ; 
         assignmentList1[0].Resource__c = contList[0].id;
         assignmentList1[0].Rate__c = rateList2[0].Id;
         insert assignmentList1 ;
         List<Assignment__c> assignmentList2 = factory.generateAssignment(prjList[0].id,Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS,1);
         assignmentList2[0].Billable__c = true;
         assignmentList2[0].role__c = Constants.ROLE_CONSULTANT ; 
         assignmentList2[0].Rate__c = rateList2[0].Id;
         assignmentList2[0].Resource__c = contList[0].id;
         insert assignmentList2 ;
         
         List<time_entry__c> timeEntryList  = factory.generateTimeEntry(assignmentList[0].id ,'test',system.today(),3,1);
         insert timeEntryList ;
        
        
         cntrlr = new GenerateInvoicesController();
         
         //setting selected month value in controller
         cntrlr.selectedMonth = timeEntryList[0].Date__c.Year() + '-' + timeEntryList[0].Date__c.Month();
         cntrlr.selectedPeriodEndDate = timeEntryList[0].Date__c.Year() + '-' + timeEntryList[0].Date__c.Month() + '-' + timeEntryList[0].Date__c.Day();
         cntrlr.fetchProjects();
         //cntrlr.selectedMonth = timeEntryList[0].Date__c.Year() + '-' + timeEntryList[0].Date__c.Month();
         cntrlr.selectedProject = prjList[0].id;
         cntrlr.getProjectOptions();  
         
         cntrlr.fetchTimeEntryData();
         //cntrlr.saveInvoiceAndLineItems();
           
    }
    @isTest static void test_method_three() {
        // Implement test code
        
         TestDataFactory factory = new TestDataFactory ();
         List<Account> accList = factory.generateAccounts(1);
         insert accList;
         
         List<Contact> contList = factory.generateContactsForAccounts(accList, 1);
         insert contList;
         
         List<agreement__C> agreementList = factory.generateRetainerAgreementsForAccounts(accList, 1); 
         agreementList[0].Effective_Date__c = Date.newInstance(System.today().Year(), System.today().Month(), 1);
         agreementList[0].Valid_Through__c  = Date.newInstance(System.today().Year(), System.today().Month()+1, 1) - 1;
         insert agreementList;
         
         pagereference pg=Page.GenerateInvoices;
         Test.setCurrentPageReference(pg);
         apexpages.currentpage().getparameters().put('agreementId',agreementList[0].id);
        
         GenerateInvoicesController cntrlr = new GenerateInvoicesController();

         accList[0].Billing_Code__c = 'Test-6';
         update accList;
         
         cntrlr =new GenerateInvoicesController();
         
         accList[0].Payment_Terms__c = 'Null';
         update accList;
         
         //generating projects
         List<Project__C> prjList = factory.generateProjects(accList[0].id,1);
         prjList[0].Project_Billing_Code__c ='ABCG12';
         insert prjList;
         
         //generating project agreement
         Project_agreement__c prjAgreement = factory.generateProjectAgreements(prjList[0].id,agreementList[0].id);
         insert prjAgreement ;
         
         agreementList[0].Payment_Terms__c = 'Net 15';
         update agreementList;
         
         List<Rate__c> ratelist = factory.generateRateForAgreement(agreementList[0].id,Constants.ASSIGNMENTTYPE_NAMEDRESOURCE,Constants.ROLE_CONSULTANT,1);
         rateList[0].Hours_Per_Month__c = 2;
         rateList[0].Hourly_Rate__c = 4;
         rateList[0].Monthly_Rate__c = 200;
         insert ratelist;

         List<Rate__c> ratelist1 = factory.generateRateForAgreement(agreementList[0].id,Constants.ASSIGNMENTTYPE_RETAINEDCAPACITY,Constants.ROLE_CONSULTANT,1);
         rateList1[0].Hours_Per_Month__c = 2;
         rateList1[0].Hourly_Rate__c = 2;
         rateList1[0].Monthly_Rate__c = 200;
         insert ratelist1;

         List<Rate__c> ratelist2 = factory.generateRateForAgreement(agreementList[0].id,Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS,Constants.ROLE_CONSULTANT,1);
         rateList2[0].Hours_Per_Month__c = 2;
         rateList2[0].Hourly_Rate__c = 2;
         insert ratelist2;
             
         List<Assignment__c> assignmentList = factory.generateAssignment(prjList[0].id,Constants.ASSIGNMENTTYPE_NAMEDRESOURCE,1);
         assignmentList[0].Billable__c = true;
         assignmentList[0].role__c = Constants.ROLE_CONSULTANT ; 
         assignmentList[0].Rate__c = rateList[0].Id; 
         assignmentList[0].Resource__c = contList[0].Id;
         insert assignmentList;
         List<Assignment__c> assignmentList1 = factory.generateAssignment(prjList[0].id,Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS,1);
         assignmentList1[0].Billable__c = true;
         assignmentList1[0].role__c = Constants.ROLE_CONSULTANT;
         assignmentList1[0].Rate__c = rateList2[0].Id;
         assignmentList1[0].Resource__c = contList[0].id;
         insert assignmentList1 ;
         List<Assignment__c> assignmentList2 = factory.generateAssignment(prjList[0].id,Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS,1);
         assignmentList2[0].Billable__c = true;
         assignmentList2[0].role__c = Constants.ROLE_CONSULTANT; 
         assignmentList2[0].Resource__c = contList[0].id;
         assignmentList2[0].Rate__c = rateList2[0].Id;
         insert assignmentList2 ;
         
         List<time_entry__c> timeEntryList  = factory.generateTimeEntry(assignmentList[0].id ,'test',system.today(),3,1);
         insert timeEntryList ;
        
        
         cntrlr = new GenerateInvoicesController();
         
         //setting selected month value in controller
         cntrlr.selectedMonth = timeEntryList[0].Date__c.Year() + '-' + timeEntryList[0].Date__c.Month();
         cntrlr.fetchProjects();
         //cntrlr.selectedMonth = timeEntryList[0].Date__c.Year() + '-' + timeEntryList[0].Date__c.Month();
         cntrlr.selectedProject = prjList[0].id;
         cntrlr.getProjectOptions();  
         
         cntrlr.fetchTimeEntryData();
         //cntrlr.saveInvoiceAndLineItems();
           
    }
    @isTest static void test_method_four() {
        // Implement test code
        
         TestDataFactory factory = new TestDataFactory ();
         List<Account> accList = factory.generateAccounts(1);
         insert accList;
         
         List<Contact> contList = factory.generateContactsForAccounts(accList, 1);
         insert contList;
         
         List<agreement__C> agreementList = factory.generateRetainerAgreementsForAccounts(accList, 1); 
         agreementList[0].Effective_Date__c = Date.newInstance(System.today().Year(), System.today().Month(), 1);
         agreementList[0].Valid_Through__c  = Date.newInstance(System.today().Year(), System.today().Month()+1, 1) - 1;
         insert agreementList;
         
         pagereference pg=Page.GenerateInvoices;
         Test.setCurrentPageReference(pg);
         apexpages.currentpage().getparameters().put('agreementId',agreementList[0].id);
        
         GenerateInvoicesController cntrlr = new GenerateInvoicesController();

         accList[0].Billing_Code__c = 'Test-6';
         update accList;
         
         cntrlr =new GenerateInvoicesController();
         
         accList[0].Payment_Terms__c = 'Null';
         update accList;
         
         //generating projects
         List<Project__C> prjList = factory.generateProjects(accList[0].id,1);
         prjList[0].Project_Billing_Code__c ='ABCG12';
         insert prjList;
         
         //generating project agreement
         Project_agreement__c prjAgreement = factory.generateProjectAgreements(prjList[0].id,agreementList[0].id);
         insert prjAgreement ;
         
         agreementList[0].Payment_Terms__c = 'Net 15';
         update agreementList;
         
         List<Rate__c> ratelist = factory.generateRateForAgreement(agreementList[0].id,Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS,Constants.ROLE_CONSULTANT,1);
         rateList[0].Hours_Per_Month__c = 2;
         rateList[0].Hourly_Rate__c = 2;
         insert ratelist ;
         List<Rate__c> ratelist1 = factory.generateRateForAgreement(agreementList[0].id,Constants.ASSIGNMENTTYPE_NAMEDRESOURCE,Constants.ROLE_CONSULTANT,1);
         rateList1[0].Hours_Per_Month__c = 2;
         rateList1[0].Hourly_Rate__c = 2;
         rateList1[0].Monthly_Rate__c = 200;
         insert ratelist1 ;
         List<Rate__c> ratelist2 = factory.generateRateForAgreement(agreementList[0].id,Constants.ASSIGNMENTTYPE_NAMEDRESOURCE,Constants.ROLE_CONSULTANT,1);
         rateList2[0].Hours_Per_Month__c = 2;
         rateList2[0].Hourly_Rate__c = 2;
         rateList2[0].Monthly_Rate__c = 200;
         insert ratelist2 ;
             
         List<Assignment__c> assignmentList = factory.generateAssignment(prjList[0].id,Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS,1);
         assignmentList[0].Billable__c = true;
         assignmentList[0].role__c = Constants.ROLE_CONSULTANT;
         assignmentList[0].Rate__c = rateList[0].Id;
         assignmentList[0].Resource__c = contList[0].id;
         insert assignmentList ;
         List<Assignment__c> assignmentList1 = factory.generateAssignment(prjList[0].id,Constants.ASSIGNMENTTYPE_NAMEDRESOURCE,1);
         assignmentList1[0].Billable__c = true;
         assignmentList1[0].Rate__c = rateList2[0].Id;
         assignmentList1[0].role__c = Constants.ROLE_CONSULTANT ; 
         assignmentList1[0].Resource__c = contList[0].id;
         insert assignmentList1 ;
         List<Assignment__c> assignmentList2 = factory.generateAssignment(prjList[0].id,Constants.ASSIGNMENTTYPE_NAMEDRESOURCE,1);
         assignmentList2[0].Billable__c = true;
         assignmentList2[0].role__c = Constants.ROLE_CONSULTANT;
         assignmentList2[0].Rate__c = rateList2[0].Id;
         assignmentList2[0].Resource__c = contList[0].id;
         insert assignmentList2 ;
         
         List<time_entry__c> timeEntryList  = factory.generateTimeEntry(assignmentList[0].id ,'test',system.today(),3,1);
         insert timeEntryList;
        
        
         cntrlr = new GenerateInvoicesController();
         
         //setting selected month value in controller
         cntrlr.selectedMonth = timeEntryList[0].Date__c.Year() + '-' + timeEntryList[0].Date__c.Month();
         cntrlr.fetchProjects();
         //cntrlr.selectedMonth = timeEntryList[0].Date__c.Year() + '-' + timeEntryList[0].Date__c.Month();
         cntrlr.selectedProject = prjList[0].id;
         cntrlr.getProjectOptions();  
         
         cntrlr.fetchTimeEntryData();
         //cntrlr.saveInvoiceAndLineItems();
           
    }
    
}