@isTest(SeeAllData = false)
private class AccountInvoiceRollups_Test {
    
    static testMethod void test_usecase_one() {
        
		Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
    														'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
    														'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
    														null, 'Net 30', 'test@test.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
    														1);
        insert accList;
        
        List<Contact> contactList = TestDataFactory_Contacts.generatecontacts(accList, 'Test contact', 'lastName', '', '', 1);
        insert contactList;
        
        List<Opportunity> oppList = TestDataFactory_Opportunity.generateOpportunities(accList[0].Id,Constants.RECORDTYPEID_OPPORTUNITY_PRODUCT, 'Closed Won', system.today().addDays(2),system.today().addDays(-30),system.today().addDays(-2), 1);
        insert oppList;
        
        List<Account_Plan__c> accountPlanningsList = TestDataFactory_AccountPlannings.generateAccountPlannings('Test', accList[0].Id, String.valueOf(Date.today().year()),1);
        accountPlanningsList.addAll(TestDataFactory_AccountPlannings.generateAccountPlannings('Test2', accList[0].Id, String.valueOf(Date.today().year()),1));
        insert accountPlanningsList;
        
        List<Project__c> projectList = TestDataFactory_Projects.generateProjects(accList[0].Id, 'Test Project', 1);
        insert projectList;
        
        List<Agreement__c> agreementList = TestDataFactory_Agreements.generateAgreements('Test Agreement 1', accList[0].Id, Constants.RECORDTYPEID_AGREEMENT_RETAINER, 'Active', Date.newInstance(System.Today().Year(), System.Today().Month() - 1, 1), Date.newInstance(System.Today().Year() + 1, System.Today().Month() - 1, 1) , 1);
        insert agreementList;
        
        List<Rate__c> rateList = TestDataFactory_Rates.generateRateForAgreement(agreementList[0].id, Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS, Constants.ROLE_CONSULTANT, 100, 1);
        insert rateList;
        List<Assignment__c> assignmentList = TestDataFactory_Assignments.generateAssignments(projectList[0].Id, contactList[0].Id, rateList[0].Id, 'Active', 'Developer', 'Named Resource', true, 250, 1);
        insert assignmentList;
        
        List<Invoice__c> invoiceList = TestDataFactory_Invoices.generateInvoices(accList[0].Id, system.today(),system.today().addDays(-2), system.today(), 2, 1);
        invoiceList.addAll(TestDataFactory_Invoices.generateInvoices(accList[0].Id, system.today().addDays(-32), system.today(), system.today(), 2, 1));
        invoiceList.addAll(TestDataFactory_Invoices.generateInvoices(accList[0].Id, system.today().addDays(-62), system.today(), system.today(), 2, 1));
        invoiceList.addAll(TestDataFactory_Invoices.generateInvoices(accList[0].Id, system.today().addDays(-92), system.today(), system.today(), 2, 1));
        invoiceList[0].Type__c = 'Actual';
        invoiceList[1].Type__c = 'Actual';
        invoiceList[2].Type__c = 'Actual';
        invoiceList[3].Type__c = 'Actual';
        insert invoiceList;
        
        List<Invoice_Line_Item__c> InvoiceLineItemsList = TestDataFactory_InvoiceLineItems.generateInvoiceLineItems(invoiceList[0].Id, Constants.RECORDTYPEID_INVOICE_10KPRODUCTNVOICELINEITEM, null, 2, 30, 1);
        InvoiceLineItemsList.addAll(TestDataFactory_InvoiceLineItems.generateInvoiceLineItems(invoiceList[1].Id, Constants.RECORDTYPEID_INVOICE_10KPRODUCTNVOICELINEITEM, null, 2, 30, 1));
        InvoiceLineItemsList.addAll(TestDataFactory_InvoiceLineItems.generateInvoiceLineItems(invoiceList[2].Id, Constants.RECORDTYPEID_INVOICE_10KPRODUCTNVOICELINEITEM, null, 2, 30, 1));
        InvoiceLineItemsList.addAll(TestDataFactory_InvoiceLineItems.generateInvoiceLineItems(invoiceList[3].Id, Constants.RECORDTYPEID_INVOICE_10KPRODUCTNVOICELINEITEM, null, 2, 30, 1));
        insert InvoiceLineItemsList;
        
        Test.startTest();
            Id idCron = System.schedule('Account Invoice Rollups Scheduler TEST', '0 0 0 * * ?' , new AccountInvoiceRollupsSchedule());
            List<Account_Plan__c> accountPlanResultList = [SELECT Id, Annual_Invoiced_Total__c, Annual_Paid_Total__c, Annual_Margin__c  FROM Account_Plan__c WHERE Id=:accountPlanningsList[0].Id];
            List<Account> accountResultList = [SELECT Id,TotalOutstandingInvoices0_30DaysOverdue__c, TotalOutstandingInvoices31_60DaysOverdue__c, TotalOutstandingInvoices61_90DaysOverdue__c, 
            									TotalOutstandingInvoices_90DaysOverdue__c, Total_paid_previous_year__c, Total_paid_this_year__c,
            									Total_invoiced_this_year__c, Total_invoiced_previous_year__c  FROM Account WHERE Id=:accList[0].Id];
            
            System.assertEquals(28,accountResultList[0].TotalOutstandingInvoices0_30DaysOverdue__c);
            System.assertEquals(28,accountResultList[0].TotalOutstandingInvoices31_60DaysOverdue__c);
            System.assertEquals(28,accountResultList[0].TotalOutstandingInvoices61_90DaysOverdue__c);
            System.assertEquals(28,accountResultList[0].TotalOutstandingInvoices_90DaysOverdue__c);

            System.assertEquals(112, accountResultList[0].Total_invoiced_this_year__c);
            System.assertEquals(0, accountResultList[0].Total_invoiced_previous_year__c);
            
            System.assertEquals(0, accountResultList[0].Total_paid_this_year__c);
            System.assertEquals(0, accountResultList[0].Total_paid_previous_year__c);
            
            System.assertEquals(8, accountPlanResultList[0].Annual_Margin__c);
            System.assertEquals(112, accountPlanResultList[0].Annual_Invoiced_Total__c);
            System.assertEquals(0, accountPlanResultList[0].Annual_Paid_Total__c);
            
            
        Test.stopTest();
    }
    
    static testMethod void test_usecase_two() {
    	
    	Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
    														'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
    														'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
    														null, 'Net 30', 'test@test.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
    														1);
        insert accList;
        
        List<Contact> contactList = TestDataFactory_Contacts.generatecontacts(accList, 'Test contact', 'lastName', '', '', 1);
        insert contactList;
        
        List<Opportunity> oppList = TestDataFactory_Opportunity.generateOpportunities(accList[0].Id,Constants.RECORDTYPEID_OPPORTUNITY_PRODUCT, 'Closed Won', system.today().addDays(2),system.today().addDays(-30),system.today().addDays(-2), 1);
        insert oppList;
        
        List<Account_Plan__c> accountPlanningsList = TestDataFactory_AccountPlannings.generateAccountPlannings('Test', accList[0].Id, String.valueOf(Date.today().year()),1);
        accountPlanningsList.addAll(TestDataFactory_AccountPlannings.generateAccountPlannings('Test2', accList[0].Id, String.valueOf(Date.today().year())
            ,1));
        insert accountPlanningsList;
        
        List<Project__c> projectList = TestDataFactory_Projects.generateProjects(accList[0].Id, 'Test Project', 1);
        insert projectList;
        
        List<Agreement__c> agreementList = TestDataFactory_Agreements.generateAgreements('Test Agreement 1', accList[0].Id, Constants.RECORDTYPEID_AGREEMENT_RETAINER, 'Active', Date.newInstance(System.Today().Year(), System.Today().Month() - 1, 1), Date.newInstance(System.Today().Year() + 1, System.Today().Month() - 1, 1) , 1);
        insert agreementList;
        
        List<Rate__c> rateList = TestDataFactory_Rates.generateRateForAgreement(agreementList[0].id, Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS, Constants.ROLE_CONSULTANT, 100, 1);
        insert rateList;
        
        List<Assignment__c> assignmentList = TestDataFactory_Assignments.generateAssignments(projectList[0].Id, contactList[0].Id, rateList[0].Id, 'Active', 'Developer', 'Named Resource', true, 250, 1);
        insert assignmentList;
        
        List<Invoice__c> invoiceList = TestDataFactory_Invoices.generateInvoices(accList[0].Id, system.today(),system.today().addDays(-2), system.today(), 2, 1);
        invoiceList.addAll(TestDataFactory_Invoices.generateInvoices(accList[0].Id, system.today().addDays(-32), system.today(), system.today(), 2, 1));
        invoiceList.addAll(TestDataFactory_Invoices.generateInvoices(accList[0].Id, system.today().addDays(-62), system.today(), system.today(), 2, 1));
        invoiceList.addAll(TestDataFactory_Invoices.generateInvoices(accList[0].Id, system.today().addDays(-92), system.today(), system.today(), 2, 1));
        invoiceList[0].Type__c = 'Actual';
        invoiceList[1].Type__c = 'Actual';
        invoiceList[2].Type__c = 'Actual';
        invoiceList[3].Type__c = 'Actual';
        insert invoiceList;
        
        List<Invoice_Line_Item__c> InvoiceLineItemsList = TestDataFactory_InvoiceLineItems.generateInvoiceLineItems(invoiceList[0].Id, Constants.RECORDTYPEID_INVOICE_10KPRODUCTNVOICELINEITEM, null, 2, 30, 1);
        InvoiceLineItemsList.addAll(TestDataFactory_InvoiceLineItems.generateInvoiceLineItems(invoiceList[1].Id, Constants.RECORDTYPEID_INVOICE_10KPRODUCTNVOICELINEITEM, null, 2, 30, 1));
        InvoiceLineItemsList.addAll(TestDataFactory_InvoiceLineItems.generateInvoiceLineItems(invoiceList[2].Id, Constants.RECORDTYPEID_INVOICE_10KPRODUCTNVOICELINEITEM, null, 2, 30, 1));
        InvoiceLineItemsList.addAll(TestDataFactory_InvoiceLineItems.generateInvoiceLineItems(invoiceList[3].Id, Constants.RECORDTYPEID_INVOICE_10KPRODUCTNVOICELINEITEM, null, 2, 30, 1));
        insert InvoiceLineItemsList;
        
        List<Payment__c> paymentList = TestDataFactory_Payments.generatePayments(invoiceList[0].Id, 10, Date.today(), 1);
        paymentList.addAll(TestDataFactory_Payments.generatePayments(invoiceList[1].Id, 20, Date.today(), 1));
        paymentList.addAll(TestDataFactory_Payments.generatePayments(invoiceList[2].Id, 30, Date.today(), 1));
        paymentList.addAll(TestDataFactory_Payments.generatePayments(invoiceList[3].Id, 10, Date.today(), 1));
        insert paymentList;
        
        Test.startTest();
            Id idCron = System.schedule('Account Invoice Rollups Scheduler TEST', '0 0 0 * * ?' , new AccountInvoiceRollupsSchedule());
            List<Account_Plan__c> accountPlanResultList = [SELECT Id, Annual_Invoiced_Total__c, Annual_Paid_Total__c, Annual_Margin__c  FROM Account_Plan__c WHERE Id=:accountPlanningsList[0].Id];
            List<Account> accountResultList = [SELECT Id,TotalOutstandingInvoices0_30DaysOverdue__c, TotalOutstandingInvoices31_60DaysOverdue__c, TotalOutstandingInvoices61_90DaysOverdue__c, 
            									TotalOutstandingInvoices_90DaysOverdue__c, Total_paid_previous_year__c, Total_paid_this_year__c,
            									Total_invoiced_this_year__c, Total_invoiced_previous_year__c  FROM Account WHERE Id=:accList[0].Id];
            
            System.assertEquals(1, accountPlanResultList.size());
            System.assertEquals(1, accountResultList.size());
            
            System.assertEquals(18,accountResultList[0].TotalOutstandingInvoices0_30DaysOverdue__c);
            System.assertEquals(8,accountResultList[0].TotalOutstandingInvoices31_60DaysOverdue__c);
            System.assertEquals(-2,accountResultList[0].TotalOutstandingInvoices61_90DaysOverdue__c);
            System.assertEquals(18,accountResultList[0].TotalOutstandingInvoices_90DaysOverdue__c);
            
            System.assertEquals(112, accountResultList[0].Total_invoiced_this_year__c);
            System.assertEquals(0, accountResultList[0].Total_invoiced_previous_year__c);
            
            System.assertEquals(70, accountResultList[0].Total_paid_this_year__c);
            System.assertEquals(0, accountResultList[0].Total_paid_previous_year__c);
            
            System.assertEquals(8, accountPlanResultList[0].Annual_Margin__c);
            System.assertEquals(112, accountPlanResultList[0].Annual_Invoiced_Total__c);
            System.assertEquals(70, accountPlanResultList[0].Annual_Paid_Total__c);
            
            
        Test.stopTest();
    }
    
    static testMethod void test_usecase_three() {
    	
    	Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
    														'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
    														'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
    														null, 'Net 30', 'test@test.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
    														1);
        insert accList;
        
        List<Contact> contactList = TestDataFactory_Contacts.generatecontacts(accList, 'Test contact', 'lastName', '', '', 1);
        insert contactList;
        
        List<Opportunity> oppList = TestDataFactory_Opportunity.generateOpportunities(accList[0].Id,Constants.RECORDTYPEID_OPPORTUNITY_PRODUCT, 'Closed Won', system.today().addDays(2),system.today().addDays(-30),system.today().addDays(-2), 1);
        insert oppList;
        
        List<Account_Plan__c> accountPlanningsList = TestDataFactory_AccountPlannings.generateAccountPlannings('Test', accList[0].Id, String.valueOf(Date.today().year()),1);
        accountPlanningsList.addAll(TestDataFactory_AccountPlannings.generateAccountPlannings('Test2', accList[0].Id, String.valueOf(Date.today().year()),1));
        insert accountPlanningsList;
        
        List<Project__c> projectList = TestDataFactory_Projects.generateProjects(accList[0].Id, 'Test Project', 1);
        insert projectList;
        
        List<Agreement__c> agreementList = TestDataFactory_Agreements.generateAgreements('Test Agreement 1', accList[0].Id, Constants.RECORDTYPEID_AGREEMENT_RETAINER, 'Active', Date.newInstance(System.Today().Year(), System.Today().Month() - 1, 1), Date.newInstance(System.Today().Year() + 1, System.Today().Month() - 1, 1) , 1);
        insert agreementList;
        
        List<Rate__c> rateList = TestDataFactory_Rates.generateRateForAgreement(agreementList[0].id, Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS, Constants.ROLE_CONSULTANT, 100, 1);
        insert rateList;
        
        List<Assignment__c> assignmentList = TestDataFactory_Assignments.generateAssignments(projectList[0].Id, contactList[0].Id, rateList[0].Id, 'Active', 'Developer', 'Named Resource', true, 250, 1);
        insert assignmentList;
        
        List<Invoice__c> invoiceList = TestDataFactory_Invoices.generateInvoices(accList[0].Id, system.today(),system.today().addDays(-2), system.today(), 2, 1);
        invoiceList.addAll(TestDataFactory_Invoices.generateInvoices(accList[0].Id, system.today().addDays(-32), system.today(), system.today(), 2, 1));
        invoiceList.addAll(TestDataFactory_Invoices.generateInvoices(accList[0].Id, system.today().addDays(-62), system.today(), system.today(), 2, 1));
        invoiceList.addAll(TestDataFactory_Invoices.generateInvoices(accList[0].Id, system.today().addDays(-92), system.today(), system.today(), 2, 1));
        invoiceList.addAll(TestDataFactory_Invoices.generateInvoices(accList[0].Id, system.today(), system.today().addYears(-1), system.today(), 2, 1));
        invoiceList[0].Type__c = 'Actual';
        invoiceList[1].Type__c = 'Actual';
        invoiceList[2].Type__c = 'Actual';
        invoiceList[3].Type__c = 'Actual';
        invoiceList[4].Type__c = 'Actual';
        insert invoiceList;
        
        List<Invoice_Line_Item__c> InvoiceLineItemsList = TestDataFactory_InvoiceLineItems.generateInvoiceLineItems(invoiceList[0].Id, Constants.RECORDTYPEID_INVOICE_10KPRODUCTNVOICELINEITEM, null, 2, 30, 1);
        InvoiceLineItemsList.addAll(TestDataFactory_InvoiceLineItems.generateInvoiceLineItems(invoiceList[1].Id, Constants.RECORDTYPEID_INVOICE_10KPRODUCTNVOICELINEITEM, null, 2, 30, 1));
        InvoiceLineItemsList.addAll(TestDataFactory_InvoiceLineItems.generateInvoiceLineItems(invoiceList[2].Id, Constants.RECORDTYPEID_INVOICE_10KPRODUCTNVOICELINEITEM, null, 2, 30, 1));
        InvoiceLineItemsList.addAll(TestDataFactory_InvoiceLineItems.generateInvoiceLineItems(invoiceList[3].Id, Constants.RECORDTYPEID_INVOICE_10KPRODUCTNVOICELINEITEM, null, 2, 30, 1));
        InvoiceLineItemsList.addAll(TestDataFactory_InvoiceLineItems.generateInvoiceLineItems(invoiceList[4].Id, Constants.RECORDTYPEID_INVOICE_10KPRODUCTNVOICELINEITEM, null, 3, 20, 1));
        insert InvoiceLineItemsList;
        
        List<Payment__c> paymentList = TestDataFactory_Payments.generatePayments(invoiceList[0].Id, 10, Date.today(), 1);
        paymentList.addAll(TestDataFactory_Payments.generatePayments(invoiceList[1].Id, 20, Date.today(), 1));
        paymentList.addAll(TestDataFactory_Payments.generatePayments(invoiceList[2].Id, 30, Date.today(), 1));
        paymentList.addAll(TestDataFactory_Payments.generatePayments(invoiceList[3].Id, 10, Date.today(), 1));
        insert paymentList;
        
        Test.startTest();
            Id idCron = System.schedule('Account Invoice Rollups Scheduler TEST', '0 0 0 * * ?' , new AccountInvoiceRollupsSchedule());
            List<Account_Plan__c> accountPlanResultList = [SELECT Id, Annual_Invoiced_Total__c, Annual_Paid_Total__c, Annual_Margin__c  FROM Account_Plan__c WHERE Id=:accountPlanningsList[0].Id];
            List<Account> accountResultList = [SELECT Id,TotalOutstandingInvoices0_30DaysOverdue__c, TotalOutstandingInvoices31_60DaysOverdue__c, TotalOutstandingInvoices61_90DaysOverdue__c, 
            									TotalOutstandingInvoices_90DaysOverdue__c, Total_paid_previous_year__c, Total_paid_this_year__c,
            									Total_invoiced_this_year__c, Total_invoiced_previous_year__c  FROM Account WHERE Id=:accList[0].Id];
            System.debug(accountResultList[0]);
            System.debug(accountPlanResultList[0]);
            
            System.assertEquals(1, accountPlanResultList.size());
            System.assertEquals(1, accountResultList.size());
            
            System.assertEquals(35,accountResultList[0].TotalOutstandingInvoices0_30DaysOverdue__c);
            System.assertEquals(8,accountResultList[0].TotalOutstandingInvoices31_60DaysOverdue__c);
            System.assertEquals(-2,accountResultList[0].TotalOutstandingInvoices61_90DaysOverdue__c);
            System.assertEquals(18,accountResultList[0].TotalOutstandingInvoices_90DaysOverdue__c);
            
            System.assertEquals(112, accountResultList[0].Total_invoiced_this_year__c);
            System.assertEquals(17, accountResultList[0].Total_invoiced_previous_year__c);
            
            System.assertEquals(70, accountResultList[0].Total_paid_this_year__c);
            System.assertEquals(0, accountResultList[0].Total_paid_previous_year__c);
            
            System.assertEquals(10, accountPlanResultList[0].Annual_Margin__c);
            System.assertEquals(112, accountPlanResultList[0].Annual_Invoiced_Total__c);
            System.assertEquals(70, accountPlanResultList[0].Annual_Paid_Total__c);
            
            
        Test.stopTest();
    }
    
    static testMethod void test_usecase_four() {
    	
    	Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
    														'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
    														'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
    														null, 'Net 30', 'test@test.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
    														1);
        insert accList;
        
        List<Contact> contactList = TestDataFactory_Contacts.generatecontacts(accList, 'Test contact', 'lastName', '', '', 1);
        insert contactList;
        
        List<Account_Plan__c> accountPlanningsList = TestDataFactory_AccountPlannings.generateAccountPlannings('Test', accList[0].Id, String.valueOf(Date.today().year()),1);
        accountPlanningsList.addAll(TestDataFactory_AccountPlannings.generateAccountPlannings('Test2', accList[0].Id, String.valueOf(Date.today().year()),1));
        insert accountPlanningsList;
        
        List<Project__c> projectList = TestDataFactory_Projects.generateProjects(accList[0].Id, 'Test Project', 1);
        insert projectList;
        
        List<Agreement__c> agreementList = TestDataFactory_Agreements.generateAgreements('Test Agreement 1', accList[0].Id, Constants.RECORDTYPEID_AGREEMENT_RETAINER, 'Active', Date.newInstance(System.Today().Year(), System.Today().Month() - 1, 1), Date.newInstance(System.Today().Year() + 1, System.Today().Month() - 1, 1) , 1);
        insert agreementList;
        
        List<Rate__c> rateList = TestDataFactory_Rates.generateRateForAgreement(agreementList[0].id, Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS, Constants.ROLE_CONSULTANT, 100, 1);
        insert rateList;
        
        List<Assignment__c> assignmentList = TestDataFactory_Assignments.generateAssignments(projectList[0].Id, contactList[0].Id, rateList[0].Id, 'Active', 'Developer', 'Named Resource', true, 250, 1);
        insert assignmentList;
        
        List<Time_Entry__c> timeEntriesList = TestDataFactory_TimeEntries.generateTimeEntries(assignmentList[0].Id, 'Test', system.today().addMonths(1), 8, 1);
        insert timeEntriesList;
        	
    	Test.startTest();
        	//Id idCron = System.schedule('Account Invoice Rollups Scheduler TEST', '0 0 0 * * ?' , new AccountInvoiceRollupsSchedule());
        	List<Id> lstAccountIds = new List<Id>{accList[0].Id};
        	AccountInvoiceRollupsUtility.updateAccountServiceStatus(lstAccountIds);
            List<Account_Plan__c> accountPlanResultList = [SELECT Id, Annual_Invoiced_Total__c, Annual_Paid_Total__c, Annual_Margin__c  FROM Account_Plan__c WHERE Id=:accountPlanningsList[0].Id];
            List<Account> accountResultList = [SELECT Id,Services_Status__c FROM Account WHERE Id=:accList[0].Id];
            System.debug(accountResultList[0]);
            
            System.assertEquals(1, accountResultList.size());
            System.assertEquals('Prospect',accountResultList[0].Services_Status__c);
        Test.stopTest();
    }
    
	static testMethod void test_usecase_five() {
    	
    	Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
    														'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
    														'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
    														null, 'Net 30', 'test@test.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
    														1);
        insert accList;
        
        List<Contact> contactList = TestDataFactory_Contacts.generatecontacts(accList, 'Test contact', 'lastName', '', '', 1);
        insert contactList;
        
        List<Account_Plan__c> accountPlanningsList = TestDataFactory_AccountPlannings.generateAccountPlannings('Test', accList[0].Id, String.valueOf(Date.today().year()),1);
        accountPlanningsList.addAll(TestDataFactory_AccountPlannings.generateAccountPlannings('Test2', accList[0].Id, String.valueOf(Date.today().year()),1));
        insert accountPlanningsList;
        
        List<Project__c> projectList = TestDataFactory_Projects.generateProjects(accList[0].Id, 'Test Project', 1);
        insert projectList;
        
        List<Agreement__c> agreementList = TestDataFactory_Agreements.generateAgreements('Test Agreement 1', accList[0].Id, Constants.RECORDTYPEID_AGREEMENT_RETAINER, 'Active', Date.newInstance(System.Today().Year(), System.Today().Month() - 1, 1), Date.newInstance(System.Today().Year() + 1, System.Today().Month() - 1, 1) , 1);
        insert agreementList;
        
        List<Rate__c> rateList = TestDataFactory_Rates.generateRateForAgreement(agreementList[0].id, Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS, Constants.ROLE_CONSULTANT, 100, 1);
        insert rateList;
        
        List<Assignment__c> assignmentList = TestDataFactory_Assignments.generateAssignments(projectList[0].Id, contactList[0].Id, rateList[0].Id, 'Active', 'Developer', 'Named Resource', true, 250, 1);
        insert assignmentList;
        
        List<Time_Entry__c> timeEntriesList = TestDataFactory_TimeEntries.generateTimeEntries(assignmentList[0].Id, 'Test', system.today().addMonths(7), 8, 1);
        insert timeEntriesList;
        	
    	Test.startTest();
        	//Id idCron = System.schedule('Account Invoice Rollups Scheduler TEST', '0 0 0 * * ?' , new AccountInvoiceRollupsSchedule());
        	List<Id> lstAccountIds = new List<Id>{accList[0].Id};
        	AccountInvoiceRollupsUtility.updateAccountServiceStatus(lstAccountIds);
        	
            List<Account_Plan__c> accountPlanResultList = [SELECT Id, Annual_Invoiced_Total__c, Annual_Paid_Total__c, Annual_Margin__c  FROM Account_Plan__c WHERE Id=:accountPlanningsList[0].Id];
            List<Account> accountResultList = [SELECT Id,Services_Status__c FROM Account WHERE Id=:accList[0].Id];
            System.debug(accountResultList[0]);
            
            System.assertEquals(1, accountResultList.size());
            //System.assertEquals('Former',accountResultList[0].Services_Status__c);
        Test.stopTest();
    }
    
    static testMethod void test_usecase_six() {
    	
    	Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
    														'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
    														'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
    														null, 'Net 30', 'test@test.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
    														1);
        insert accList;
        
        List<Contact> contactList = TestDataFactory_Contacts.generatecontacts(accList, 'Test contact', 'lastName', '', '', 1);
        insert contactList;
        
        List<Account_Plan__c> accountPlanningsList = TestDataFactory_AccountPlannings.generateAccountPlannings('Test', accList[0].Id, String.valueOf(Date.today().year()),1);
        accountPlanningsList.addAll(TestDataFactory_AccountPlannings.generateAccountPlannings('Test2', accList[0].Id, String.valueOf(Date.today().year()),1));
        insert accountPlanningsList;
        
        List<Project__c> projectList = TestDataFactory_Projects.generateProjects(accList[0].Id, 'Test Project', 1);
        insert projectList;
        
        List<Agreement__c> agreementList = TestDataFactory_Agreements.generateAgreements('Test Agreement 1', accList[0].Id, Constants.RECORDTYPEID_AGREEMENT_RETAINER, 'Active', Date.newInstance(System.Today().Year(), System.Today().Month() - 1, 1), Date.newInstance(System.Today().Year() + 1, System.Today().Month() - 1, 1) , 1);
        insert agreementList;
        
        List<Rate__c> rateList = TestDataFactory_Rates.generateRateForAgreement(agreementList[0].id, Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS, Constants.ROLE_CONSULTANT, 100, 1);
        insert rateList;
        
        List<Assignment__c> assignmentList = TestDataFactory_Assignments.generateAssignments(projectList[0].Id, contactList[0].Id, rateList[0].Id, 'Active', 'Developer', 'Named Resource', true, 250, 1);
        insert assignmentList;
        	
    	Test.startTest();
        	//Id idCron = System.schedule('Account Invoice Rollups Scheduler TEST', '0 0 0 * * ?' , new AccountInvoiceRollupsSchedule());
        	List<Id> lstAccountIds = new List<Id>{accList[0].Id};
        	AccountInvoiceRollupsUtility.updateAccountServiceStatus(lstAccountIds);
        	
            List<Account_Plan__c> accountPlanResultList = [SELECT Id, Annual_Invoiced_Total__c, Annual_Paid_Total__c, Annual_Margin__c  FROM Account_Plan__c WHERE Id=:accountPlanningsList[0].Id];
            List<Account> accountResultList = [SELECT Id,Services_Status__c FROM Account WHERE Id=:accList[0].Id];
            System.debug(accountResultList[0]);
			
            System.assertEquals(1, accountResultList.size());
            System.assertEquals('Prospect',accountResultList[0].Services_Status__c);
        Test.stopTest();
    }
    
    static testMethod void test_usecase_seven() {
    	
    	Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
    														'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
    														'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
    														null, 'Net 30', 'test@test.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
    														1);
        insert accList;
        
        List<Contact> contactList = TestDataFactory_Contacts.generatecontacts(accList, 'Test contact', 'lastName', '', '', 1);
        insert contactList;
        
        List<Opportunity> oppList = TestDataFactory_Opportunity.generateOpportunities(accList[0].Id,Constants.RECORDTYPEID_OPPORTUNITY_PRODUCT, 'Closed Won', system.today().addDays(2),system.today().addDays(-50),system.today().addDays(-20), 1);
        insert oppList;
        
        List<Account_Plan__c> accountPlanningsList = TestDataFactory_AccountPlannings.generateAccountPlannings('Test', accList[0].Id, String.valueOf(Date.today().year()),1);
        accountPlanningsList.addAll(TestDataFactory_AccountPlannings.generateAccountPlannings('Test2', accList[0].Id, String.valueOf(Date.today().year()),1));
        insert accountPlanningsList;
        
        List<Project__c> projectList = TestDataFactory_Projects.generateProjects(accList[0].Id, 'Test Project', 1);
        insert projectList;
        
        List<Agreement__c> agreementList = TestDataFactory_Agreements.generateAgreements('Test Agreement 1', accList[0].Id, Constants.RECORDTYPEID_AGREEMENT_RETAINER, 'Active', Date.newInstance(System.Today().Year(), System.Today().Month() - 1, 1), Date.newInstance(System.Today().Year() + 1, System.Today().Month() - 1, 1) , 1);
        insert agreementList;
        
        List<Rate__c> rateList = TestDataFactory_Rates.generateRateForAgreement(agreementList[0].id, Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS, Constants.ROLE_CONSULTANT, 100, 1);
        insert rateList;
        
        List<Assignment__c> assignmentList = TestDataFactory_Assignments.generateAssignments(projectList[0].Id, contactList[0].Id, rateList[0].Id, 'Active', 'Developer', 'Named Resource', true, 250, 1);
        insert assignmentList;
        
        List<Time_Entry__c> timeEntriesList = TestDataFactory_TimeEntries.generateTimeEntries(assignmentList[0].Id, 'Test', system.today().addMonths(1), 8, 1);
        insert timeEntriesList;
        	
    	Test.startTest();
        	//Id idCron = System.schedule('Account Invoice Rollups Scheduler TEST', '0 0 0 * * ?' , new AccountInvoiceRollupsSchedule());
        	List<Id> lstAccountIds = new List<Id>{accList[0].Id};
        	AccountInvoiceRollupsUtility.updateAccountServiceStatus(lstAccountIds);
        	
            List<Account> accountResultList = [SELECT Id, DoubleClick_Status__c, Services_Status__c FROM Account WHERE Id=:accList[0].Id];
            System.debug(accountResultList[0]);
            
            System.assertEquals(1, accountResultList.size());
            //System.assertEquals('Current Subscriber',accountResultList[0].DoubleClick_Status__c);
        Test.stopTest();
    }
    
    static testMethod void test_usecase_eight() {
    	
    	Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
    														'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
    														'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
    														null, 'Net 30', 'test@test.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
    														1);
        insert accList;
        
        List<Contact> contactList = TestDataFactory_Contacts.generatecontacts(accList, 'Test contact', 'lastName', '', '', 1);
        insert contactList;
        
        List<Opportunity> oppList = TestDataFactory_Opportunity.generateOpportunities(accList[0].Id,Constants.RECORDTYPEID_OPPORTUNITY_PRODUCT, 'Closed Won', system.today().addDays(2),system.today().addDays(-150),system.today().addDays(-130), 1);
        insert oppList;
        
        List<Account_Plan__c> accountPlanningsList = TestDataFactory_AccountPlannings.generateAccountPlannings('Test', accList[0].Id, String.valueOf(Date.today().year()),1);
        accountPlanningsList.addAll(TestDataFactory_AccountPlannings.generateAccountPlannings('Test2', accList[0].Id, String.valueOf(Date.today().year()),1));
        insert accountPlanningsList;
        
        List<Project__c> projectList = TestDataFactory_Projects.generateProjects(accList[0].Id, 'Test Project', 1);
        insert projectList;
        
        List<Agreement__c> agreementList = TestDataFactory_Agreements.generateAgreements('Test Agreement 1', accList[0].Id, Constants.RECORDTYPEID_AGREEMENT_RETAINER, 'Active', Date.newInstance(System.Today().Year(), System.Today().Month() - 1, 1), Date.newInstance(System.Today().Year() + 1, System.Today().Month() - 1, 1) , 1);
        insert agreementList;
        
        List<Rate__c> rateList = TestDataFactory_Rates.generateRateForAgreement(agreementList[0].id, Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS, Constants.ROLE_CONSULTANT, 100, 1);
        insert rateList;
        
        List<Assignment__c> assignmentList = TestDataFactory_Assignments.generateAssignments(projectList[0].Id, contactList[0].Id, rateList[0].Id, 'Active', 'Developer', 'Named Resource', true, 250, 1);
        insert assignmentList;
        
        List<Time_Entry__c> timeEntriesList = TestDataFactory_TimeEntries.generateTimeEntries(assignmentList[0].Id, 'Test', system.today().addMonths(1), 8, 1);
        insert timeEntriesList;
        	
    	Test.startTest();
        	//Id idCron = System.schedule('Account Invoice Rollups Scheduler TEST', '0 0 0 * * ?' , new AccountInvoiceRollupsSchedule());
        	List<Id> lstAccountIds = new List<Id>{accList[0].Id};
        	AccountInvoiceRollupsUtility.updateAccountServiceStatus(lstAccountIds);
        	
            List<Account> accountResultList = [SELECT Id, DoubleClick_Status__c, Services_Status__c FROM Account WHERE Id=:accList[0].Id];
            System.debug(accountResultList[0]);
            
            System.assertEquals(1, accountResultList.size());
            //System.assertEquals('Former Subscriber',accountResultList[0].DoubleClick_Status__c);
        Test.stopTest();
    }
    
    static testMethod void test_usecase_nine() {
    	
    	Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
    														'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
    														'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
    														null, 'Net 30', 'test@test.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
    														1);
        insert accList;
        
        List<Contact> contactList = TestDataFactory_Contacts.generatecontacts(accList, 'Test contact', 'lastName', '', '', 1);
        insert contactList;
        
        List<Account_Plan__c> accountPlanningsList = TestDataFactory_AccountPlannings.generateAccountPlannings('Test', accList[0].Id, String.valueOf(Date.today().year()),1);
        accountPlanningsList.addAll(TestDataFactory_AccountPlannings.generateAccountPlannings('Test2', accList[0].Id, String.valueOf(Date.today().year()),1));
        insert accountPlanningsList;
        
        List<Project__c> projectList = TestDataFactory_Projects.generateProjects(accList[0].Id, 'Test Project', 1);
        insert projectList;
        
        List<Agreement__c> agreementList = TestDataFactory_Agreements.generateAgreements('Test Agreement 1', accList[0].Id, Constants.RECORDTYPEID_AGREEMENT_RETAINER, 'Active', Date.newInstance(System.Today().Year(), System.Today().Month() - 1, 1), Date.newInstance(System.Today().Year() + 1, System.Today().Month() - 1, 1) , 1);
        insert agreementList;
        
        List<Rate__c> rateList = TestDataFactory_Rates.generateRateForAgreement(agreementList[0].id, Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS, Constants.ROLE_CONSULTANT, 100, 1);
        insert rateList;
        
        List<Assignment__c> assignmentList = TestDataFactory_Assignments.generateAssignments(projectList[0].Id, contactList[0].Id, rateList[0].Id, 'Active', 'Developer', 'Named Resource', true, 250, 1);
        insert assignmentList;
        	
    	Test.startTest();
        	//Id idCron = System.schedule('Account Invoice Rollups Scheduler TEST', '0 0 0 * * ?' , new AccountInvoiceRollupsSchedule());
        	List<Id> lstAccountIds = new List<Id>{accList[0].Id};
        	AccountInvoiceRollupsUtility.updateAccountServiceStatus(lstAccountIds);
        	
            List<Account> accountResultList = [SELECT Id, DoubleClick_Status__c, Services_Status__c FROM Account WHERE Id=:accList[0].Id];
            System.debug(accountResultList[0]);
            
            System.assertEquals(1, accountResultList.size());
            System.assertEquals('Not A Subscriber',accountResultList[0].DoubleClick_Status__c);
        Test.stopTest();
    }


    static testMethod void test_usecase_ten() {
        
        
        Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList    = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test Account', 'Prospect', 15, 
                                                                                'code coverage', 'internal', 'App Cloud;Sales Cloud', 'Enterprise', 
                                                                                'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                                                'code quality with code coverage above 75%', 'NDA aggrement', 'United States', 
                                                                                '501 test street', 'test city', 'Florida', '90001', null, null, 'Net 30', 
                                                                                'acc@testemail.com', 'TestA', 'HELLO WORLD', 'invoicingNotes', 
                                                                                'Partner Client', 1);
        insert accList;
        
        List<Contact> contactList = TestDataFactory_Contacts.generatecontacts(accList, 'Test contact', 'lastName', '', '', 1);
        insert contactList;
        
        List<Opportunity> oppList = TestDataFactory_Opportunity.generateOpportunities(accList[0].Id,Constants.RECORDTYPEID_OPPORTUNITY_PRODUCT, 'Closed Won', system.today().addDays(2),system.today().addDays(-30),system.today().addDays(-2), 1);
        insert oppList;
        
        List<Account_Plan__c> accountPlanningsList = TestDataFactory_AccountPlannings.generateAccountPlannings('Test', accList[0].Id, String.valueOf(Date.today().year()),1);
        accountPlanningsList.addAll(TestDataFactory_AccountPlannings.generateAccountPlannings('Test2', accList[0].Id, String.valueOf(Date.today().year()),1));
        insert accountPlanningsList;
        
        List<Project__c> projectList = TestDataFactory_Projects.generateProjects(accList[0].Id, 'Test Project', 1);
        insert projectList;
        
        List<Agreement__c> agreementList = TestDataFactory_Agreements.generateAgreements('Test Agreement 1', accList[0].Id, Constants.RECORDTYPEID_AGREEMENT_RETAINER, 'Active', Date.newInstance(System.Today().Year(), System.Today().Month() - 1, 1), Date.newInstance(System.Today().Year() + 1, System.Today().Month() - 1, 1) , 1);
        insert agreementList;
        
        List<Rate__c> rateList = TestDataFactory_Rates.generateRateForAgreement(agreementList[0].id, Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS, Constants.ROLE_CONSULTANT, 100, 1);
        insert rateList;
        List<Assignment__c> assignmentList = TestDataFactory_Assignments.generateAssignments(projectList[0].Id, contactList[0].Id, rateList[0].Id, 'Active', 'Developer', 'Named Resource', true, 250, 1);
        insert assignmentList;
        

        List<Invoice__c> invoiceList =TestDataFactory_Invoices.generateInvoices(accList[0].id, Date.today(), Date.today().addDays(2), Date.today().addDays(6), 1.2, 2);
        invoiceList[0].Due_Date__c = Date.today().addDays(-99);
        invoiceList[1].Due_Date__c = Date.today().addDays(-2);
        invoiceList[0].Billing_Period_Start_Date__c = Date.today().addDays(-20);
        invoiceList[0].Billing_Period_End_Date__c = Date.today().addDays(-10);
        invoiceList[1].Billing_Period_Start_Date__c = Date.today().addDays(-100);
        invoiceList[1].Billing_Period_End_Date__c = Date.today().addDays(-110);
        invoiceList[1].Invoice_Generated_On__c = Date.today().addDays(-80);
        invoiceList[0].RecordTypeId = Constants.RECORDTYPEID_INVOICE_10KSERVICESINVOICE;
        invoiceList[1].RecordTypeId = Constants.RECORDTYPEID_INVOICE_10KSERVICESINVOICE;
        invoiceList[0].Type__c = 'Actual';
        invoiceList[1].Type__c = 'Actual';
        insert invoiceList;
        
        List<Invoice_Line_Item__c> invoiceLineItemList = TestDataFactory_InvoiceLineItems.generateInvoiceLineItems(invoiceList[0].Id, 
                                                                                                                   Constants.RECORDTYPEID_INVOICE_10KSERVICESINVOICELINEITEM, 
                                                                                                                   rateList[0].Id, 10, 1000, 2);
        
        invoiceLineItemList[1].invoice__c = invoiceList[1].Id;
        invoiceLineItemList[0].Hours__c = 5;
        invoiceLineItemList[0].Goodwill_Amount__c = 5;
        invoiceLineItemList[1].Goodwill_Amount__c = 10;
        invoiceLineItemList[1].Hours__c = 10;
        insert invoiceLineItemList;
        
        Test.startTest();
            Id idCron = System.schedule('Account Invoice Rollups Scheduler TEST', '0 0 0 * * ?' , new AccountInvoiceRollupsSchedule());
            List<Account_Plan__c> accountPlanResultList = [SELECT Id, Annual_Invoiced_Total__c, Annual_Paid_Total__c, Annual_Margin__c  FROM Account_Plan__c WHERE Id=:accountPlanningsList[0].Id];
            List<Account> accountResultList = [SELECT Id,Total_Goodwill_Last_Year__c,Total_Goodwill_This_Year__c,TotalOutstandingInvoices0_30DaysOverdue__c, TotalOutstandingInvoices31_60DaysOverdue__c, TotalOutstandingInvoices61_90DaysOverdue__c, 
                                                TotalOutstandingInvoices_90DaysOverdue__c, Total_paid_previous_year__c, Total_paid_this_year__c,
                                                Total_invoiced_this_year__c, Total_invoiced_previous_year__c  FROM Account WHERE Id=:accList[0].Id];
            
            System.assertEquals(5,accountResultList[0].Total_Goodwill_This_Year__c);
            System.assertEquals(10,accountResultList[0].Total_Goodwill_Last_Year__c);
        Test.stopTest();
    }
}