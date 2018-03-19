@isTest(SeeAllData = false)
private class InvoiceTriggerHandler_Test {

    static testMethod void test_method_one() {
        
        TestDataFactory objTestDataFactory = new TestDataFactory();    
        
        Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accountList    = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test Account', 'Prospect', 15, 
                                                                                'code coverage', 'internal', 'App Cloud;Sales Cloud', 'Enterprise', 
                                                                                'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                                                'code quality with code coverage above 75%', 'NDA aggrement', 'United States', 
                                                                                '501 test street', 'test city', 'Florida', '90001', null, null, 'Net 30', 
                                                                                'acc@testemail.com', 'TestA', 'HELLO WORLD', 'invoicingNotes', 
                                                                                'Partner Client', 1);
        insert accountList;
        List<Contact> contactList = TestDataFactory_Contacts.generatecontacts(accountList, 'Contact firstName', 'Contact lastName', 'contact@testemail.com', '', 1);
        insert contactList;
        List<Project__c> projectList = TestDataFactory_Projects.generateProjects(accountList[0].id, 'Test Project', 1);
        insert projectList;
        List<Invoice__c> invoiceList =TestDataFactory_Invoices.generateInvoices(accountList[0].id, Date.today(), Date.today().addDays(2), Date.today().addDays(6), 1.2, 3);
        invoiceList[0].Due_Date__c = Date.today().addDays(-99);
        invoiceList[0].Type__c = 'Actual';
        invoiceList[1].Type__c = 'Actual';
        invoiceList[2].Type__c = 'Actual';
        invoiceList[1].Due_Date__c = Date.today().addDays(-2);
        //invoiceList[0].Type__c = 'Draft';
        invoiceList[0].Billing_Period_Start_Date__c = Date.today().addDays(-20);
        invoiceList[0].Billing_Period_End_Date__c = Date.today().addDays(-10);
        invoiceList[1].Billing_Period_Start_Date__c = Date.today().addDays(-20);
        invoiceList[1].Billing_Period_End_Date__c = Date.today().addDays(-10);
        invoiceList[0].RecordTypeId = Constants.RECORDTYPEID_INVOICE_10KSERVICESINVOICE;
        invoiceList[2].RecordTypeId = Constants.RECORDTYPEID_INVOICE_10KSERVICESINVOICE;
        insert invoiceList;
        List<Agreement__c> agreementList = TestDataFactory_Agreements.generateAgreements('Test Agreement', accountList[0].id, 
                                                                                         Constants.RECORDTYPEID_AGREEMENT_RETAINER, 
                                                                                         'Active', 
                                                                                         Date.newInstance(System.Today().Year(), System.Today().Month() - 1, 1), 
                                                                                         Date.newInstance(System.Today().Year() + 1, System.Today().Month() - 1, 1), 
                                                                                         1);

        insert agreementList;
        
        List<Rate__c> rateList           = TestDataFactory_Rates.generateRateForAgreement(agreementList[0].id, 
                                                                                'Time & Materials', 
                                                                                Constants.ROLE_USER_EXPERIENCE, 20, 1);
       
        insert rateList;

        List<Invoice_Line_Item__c> invoiceLineItemList = TestDataFactory_InvoiceLineItems.generateInvoiceLineItems(invoiceList[0].Id, 
                                                                                                                   Constants.RECORDTYPEID_INVOICE_10KSERVICESINVOICELINEITEM, 
                                                                                                                   rateList[0].Id, 10, 1000, 2);
        
        invoiceLineItemList[1].invoice__c = invoiceList[1].Id;
        invoiceLineItemList[0].Hours__c = 5;
        invoiceLineItemList[1].Hours__c = 10;
        insert invoiceLineItemList;
        invoiceList[2].Due_Date__c = date.today().addDays(-101);
        invoiceList[0].Due_Date__c = date.today().addDays(-98);        
        update invoiceList;

        List<Assignment__c> assignmentList = TestDataFactory_Assignments.generateAssignments(projectList[0].Id, contactList[0].Id, 
                                                                                             rateList[0].Id, Constants.ASSIGNMENT_STATUS_ACTIVE, Constants.ROLE_CONSULTANT, 
                                                                                             Constants.ASSIGNMENTTYPE_NAMEDRESOURCE, true, 
                                                                                             100, 1);
        assignmentList[0].Billable__c = true;
        assignmentList[0].Cost_Rate__c = rateList[0].Id;
        assignmentList[0].Role__c = Constants.ROLE_CONSULTANT ; 
        insert assignmentList;

        

        List<time_entry__c> timeEntries = TestDataFactory_TimeEntries.generateTimeEntries(assignmentList[0].Id, 
                                                                                          'Test Time Entry', Date.today(), 
                                                                                          5.5, 2);
        timeEntries[0].Invoice__c = invoiceList[1].Id;
        timeEntries[1].Invoice__c = invoiceList[2].Id;
        timeEntries[1].Total_Expert_Goodwill_Amount__c = 5;
        timeEntries[1].Goodwill_Hours__c = 12;
        insert timeEntries;

        Test.startTest();
            
            List<Account> lstAccountForAssertionCheck1 = [Select Id, TotalOutstandingInvoices0_30DaysOverdue__c, TotalOutstandingInvoices31_60DaysOverdue__c, TotalOutstandingInvoices61_90DaysOverdue__c, TotalOutstandingInvoices_90DaysOverdue__c From Account where Id = :accountList[0].Id];
            system.assertEquals(200, lstAccountForAssertionCheck1[0].TotalOutstandingInvoices0_30DaysOverdue__c);
            system.assertEquals(100, lstAccountForAssertionCheck1[0].TotalOutstandingInvoices_90DaysOverdue__c);
            
            invoiceList[0].Due_Date__c = date.today().addDays(-1); 
            update invoiceList;
            
            List<Account> lstAccountForAssertionCheck2 = [Select Id, TotalOutstandingInvoices0_30DaysOverdue__c, TotalOutstandingInvoices31_60DaysOverdue__c, TotalOutstandingInvoices61_90DaysOverdue__c, TotalOutstandingInvoices_90DaysOverdue__c From Account where Id = :accountList[0].Id];
            system.assertEquals(300, lstAccountForAssertionCheck2[0].TotalOutstandingInvoices0_30DaysOverdue__c);
            system.assertEquals(0, lstAccountForAssertionCheck2[0].TotalOutstandingInvoices_90DaysOverdue__c);
                    
            invoiceList[1].Due_Date__c = date.today().addDays(-98);
            invoiceList[0].Name = 'newinvoice';   
            update invoiceList;
            
            List<Account> lstAccountForAssertionCheck3 = [Select Id, TotalOutstandingInvoices0_30DaysOverdue__c, TotalOutstandingInvoices31_60DaysOverdue__c, TotalOutstandingInvoices61_90DaysOverdue__c, TotalOutstandingInvoices_90DaysOverdue__c From Account where Id = :accountList[0].Id];
            system.assertEquals(100, lstAccountForAssertionCheck3[0].TotalOutstandingInvoices0_30DaysOverdue__c);
            system.assertEquals(200, lstAccountForAssertionCheck3[0].TotalOutstandingInvoices_90DaysOverdue__c);
            
            invoiceList[1].Due_Date__c = date.today().addDays(-50); 
            update invoiceList;
            
            List<Account> lstAccountForAssertionCheck4 = [Select Id, TotalOutstandingInvoices0_30DaysOverdue__c, TotalOutstandingInvoices31_60DaysOverdue__c, TotalOutstandingInvoices61_90DaysOverdue__c, TotalOutstandingInvoices_90DaysOverdue__c From Account where Id = :accountList[0].Id];
            system.assertEquals(200, lstAccountForAssertionCheck4[0].TotalOutstandingInvoices31_60DaysOverdue__c);
            system.assertEquals(100, lstAccountForAssertionCheck4[0].TotalOutstandingInvoices0_30DaysOverdue__c);
            
            invoiceList[1].Due_Date__c = date.today().addDays(-80); 
            update invoiceList;
            
            List<Account> lstAccountForAssertionCheck5 = [Select Id, TotalOutstandingInvoices0_30DaysOverdue__c, TotalOutstandingInvoices31_60DaysOverdue__c, TotalOutstandingInvoices61_90DaysOverdue__c, TotalOutstandingInvoices_90DaysOverdue__c From Account where Id = :accountList[0].Id];
            system.assertEquals(200, lstAccountForAssertionCheck5[0].TotalOutstandingInvoices61_90DaysOverdue__c);
            system.assertEquals(100, lstAccountForAssertionCheck5[0].TotalOutstandingInvoices0_30DaysOverdue__c);
            
            invoiceList[1].Due_Date__c = date.today().addDays(-2);  
            update invoiceList;
            
            List<Account> lstAccountForAssertionCheck6 = [Select Id, TotalOutstandingInvoices0_30DaysOverdue__c, TotalOutstandingInvoices31_60DaysOverdue__c, TotalOutstandingInvoices61_90DaysOverdue__c, TotalOutstandingInvoices_90DaysOverdue__c From Account where Id = :accountList[0].Id];
            system.assertEquals(300, lstAccountForAssertionCheck6[0].TotalOutstandingInvoices0_30DaysOverdue__c);
            
            delete invoiceList[0];
            
            List<Account> lstAccountForAssertionCheck7 = [Select Id, TotalOutstandingInvoices0_30DaysOverdue__c, TotalOutstandingInvoices31_60DaysOverdue__c, TotalOutstandingInvoices61_90DaysOverdue__c, TotalOutstandingInvoices_90DaysOverdue__c From Account where Id = :accountList[0].Id];
            system.assertEquals(200, lstAccountForAssertionCheck7[0].TotalOutstandingInvoices0_30DaysOverdue__c);
            system.assertEquals(0, lstAccountForAssertionCheck7[0].TotalOutstandingInvoices_90DaysOverdue__c);
            
            undelete invoiceList[0];
            
            List<Account> lstAccountForAssertionCheck8 = [Select Id, TotalOutstandingInvoices0_30DaysOverdue__c, TotalOutstandingInvoices31_60DaysOverdue__c, TotalOutstandingInvoices61_90DaysOverdue__c, TotalOutstandingInvoices_90DaysOverdue__c From Account where Id = :accountList[0].Id];
            system.assertEquals(300, lstAccountForAssertionCheck8[0].TotalOutstandingInvoices0_30DaysOverdue__c);
            
        Test.stopTest();
    }


    static testMethod void test_method_two()
    {
        TestDataFactory objTestDataFactory = new TestDataFactory();    
        Test.startTest();
            Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
            List<Account> accountList    = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test Account', 'Prospect', 15, 
                                                                                    'code coverage', 'internal', 'App Cloud;Sales Cloud', 'Enterprise', 
                                                                                    'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                                                    'code quality with code coverage above 75%', 'NDA aggrement', 'United States', 
                                                                                    '501 test street', 'test city', 'Florida', '90001', null, null, 'Net 30', 
                                                                                    'acc@testemail.com', 'TestA', 'HELLO WORLD', 'invoicingNotes', 
                                                                                    'Partner Client', 1);
            insert accountList;
            List<Contact> contactList = TestDataFactory_Contacts.generatecontacts(accountList, 'Contact Firstname', 'Contact Lastname', 'test@test.com', '', 1);
            insert contactList;
            
            accountList[0].Primary_Billing_Contact__c = contactList[0].Id;
            update accountList;
            
            List<Invoice__c> invoiceList =TestDataFactory_Invoices.generateInvoices(accountList[0].id, date.today(), date.today().addDays(2), date.today().addDays(6), 1.2, 1);
            invoiceList[0].Due_Date__c = date.today().addDays(-99);
            invoiceList[0].Billing_Period_Start_Date__c = Date.today().addDays(-20);
            invoiceList[0].Billing_Period_End_Date__c = Date.today().addDays(-10);
            invoiceList[0].Type__c = 'Actual';
            invoiceList[0].Payment_Initiated__c = false;
            invoiceList[0].RecordTypeId = Constants.RECORDTYPEID_INVOICE_DELIVERYPARTNERINVOICE;
            insert invoiceList; 
            
            accountList[0].Bank_Address__c = 'abc' ;
            update accountList;
            invoiceList =TestDataFactory_Invoices.generateInvoices(accountList[0].id, date.today(), date.today().addDays(2), date.today().addDays(6), 1.2, 1);
            invoiceList[0].Due_Date__c = date.today().addDays(-99);
            invoiceList[0].Billing_Period_Start_Date__c = Date.today().addDays(-20);
            invoiceList[0].Billing_Period_End_Date__c = Date.today().addDays(-10);
            invoiceList[0].Type__c = 'Actual';
            invoiceList[0].Payment_Initiated__c = false;
            invoiceList[0].RecordTypeId = Constants.RECORDTYPEID_INVOICE_DELIVERYPARTNERINVOICE;
            insert invoiceList;
            accountList[0].Routing_Number__c = '456';
            update accountList;
            invoiceList =TestDataFactory_Invoices.generateInvoices(accountList[0].id, date.today(), date.today().addDays(2), date.today().addDays(6), 1.2, 1);
            invoiceList[0].Due_Date__c = date.today().addDays(-99);
            invoiceList[0].Billing_Period_Start_Date__c = Date.today().addDays(-20);
            invoiceList[0].Billing_Period_End_Date__c = Date.today().addDays(-10);
            invoiceList[0].Type__c = 'Actual';
            invoiceList[0].Payment_Initiated__c = false;
            invoiceList[0].RecordTypeId = Constants.RECORDTYPEID_INVOICE_DELIVERYPARTNERINVOICE;
            insert invoiceList;
            accountList[0].Account_Number__c = '123';
            update accountList;
            accountList[0].Taxpayer_Identification_Number_TIN__c = '123' ;
            update accountList;
            invoiceList =TestDataFactory_Invoices.generateInvoices(accountList[0].id, date.today(), date.today().addDays(2), date.today().addDays(6), 1.2, 1);
            invoiceList[0].Due_Date__c = date.today().addDays(-99);
            invoiceList[0].Billing_Period_Start_Date__c = Date.today().addDays(-20);
            invoiceList[0].Billing_Period_End_Date__c = Date.today().addDays(-10);
            invoiceList[0].Type__c = 'Actual';
            invoiceList[0].Payment_Initiated__c = false;
            invoiceList[0].RecordTypeId = Constants.RECORDTYPEID_INVOICE_DELIVERYPARTNERINVOICE;
            insert invoiceList;
            accountList[0].Bank_Name__c = 'Test Bank ' ;
            update accountList;
            invoiceList =TestDataFactory_Invoices.generateInvoices(accountList[0].id, date.today(), date.today().addDays(2), date.today().addDays(6), 1.2, 1);
            invoiceList[0].Due_Date__c = date.today().addDays(-99);
            invoiceList[0].Billing_Period_Start_Date__c = Date.today().addDays(-20);
            invoiceList[0].Billing_Period_End_Date__c = Date.today().addDays(-10);
            invoiceList[0].Type__c = 'Actual';
            invoiceList[0].Payment_Initiated__c = false;
            invoiceList[0].RecordTypeId = Constants.RECORDTYPEID_INVOICE_DELIVERYPARTNERINVOICE;
            insert invoiceList;
            accountList[0].BillingCountry  = 'India' ;
            accountList[0].Bank_Address__c = '';
            accountList[0].Indian_Financial_Services_Code__c = '';
            update accountList;
            invoiceList =TestDataFactory_Invoices.generateInvoices(accountList[0].id, date.today(), date.today().addDays(2), date.today().addDays(6), 1.2, 1);
            invoiceList[0].Due_Date__c = date.today().addDays(-99);
            invoiceList[0].Billing_Period_Start_Date__c = Date.today().addDays(-20);
            invoiceList[0].Billing_Period_End_Date__c = Date.today().addDays(-10);
            invoiceList[0].Type__c = 'Actual';
            invoiceList[0].Payment_Initiated__c = false;
            invoiceList[0].RecordTypeId = Constants.RECORDTYPEID_INVOICE_DELIVERYPARTNERINVOICE;
            insert invoiceList;
            
            
            List<Agreement__c> agreementList = TestDataFactory_Agreements.generateAgreements('Test Agreement', accountList[0].id, 
                                                                                             Constants.RECORDTYPEID_AGREEMENT_RETAINER, 
                                                                                             'Active', 
                                                                                             Date.newInstance(System.Today().Year(), System.Today().Month() - 1, 1), 
                                                                                             Date.newInstance(System.Today().Year() + 1, System.Today().Month() - 1, 1), 
                                                                                             1);

            insert agreementList;
            
            List<Rate__c> rateList           = TestDataFactory_Rates.generateRateForAgreement(agreementList[0].id, 
                                                                                    'Time & Materials', 
                                                                                   Constants.ROLE_USER_EXPERIENCE, 4, 1);
           
            insert rateList;
            List<Invoice_Line_Item__c> invoiceLineItemList = TestDataFactory_InvoiceLineItems.generateInvoiceLineItems(invoiceList[0].Id, 
                                                                                                                   Constants.RECORDTYPEID_INVOICE_10KSERVICESINVOICELINEITEM, 
                                                                                                                   rateList[0].Id, 10, 1000, 1);

            invoiceLineItemList[0].Hours__c = 5;
            insert invoiceLineItemList;
            invoiceList[0].Due_Date__c = date.today().addDays(-98);
            invoiceList[0].Payment_Initiated__c = true;
            update invoiceList ;

            List<Payment__c> paymentList = TestDataFactory_Payments.generatePayments(invoiceList[0].Id, 20.1, date.today().addDays(12), 1);
            paymentList[0].Invoice__c = invoiceList[0].id;
            paymentList[0].Payment_Date__c = Date.today();
            paymentList[0].Amount__c = 50.00;
            insert paymentList ;
            System.assertEquals(invoiceList[0].RecordTypeId, Constants.RECORDTYPEID_INVOICE_DELIVERYPARTNERINVOICE);
        Test.stopTest();
    }
}