@isTest
private class ApplyGoodwillController_Test 
{
    
    @isTest static void test_ApplyGoodwillController() 
    {
        Id partnerClientrecordTypeId        = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accountList           = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test Account', 'Prospect', 15, 
                                                                                'code coverage', 'internal', 'App Cloud;Sales Cloud', 'Enterprise', 
                                                                                'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                                                'code quality with code coverage above 75%', 'NDA aggrement', 'United States', 
                                                                                '501 test street', 'test city', 'Florida', '90001', null, null, 'Net 30', 
                                                                                'acc@testemail.com', 'TestA', 'HELLO WORLD', 'invoicingNotes', 
                                                                                'Partner Client', 1);
        insert accountList;
        List<Contact> contactList           = TestDataFactory_Contacts.generatecontacts(accountList, 'Contact firstName', 'Contact lastName', 'contact@testemail.com', '', 1);
        insert contactList;
        List<Project__c> projectList        = TestDataFactory_Projects.generateProjects(accountList[0].id, 'Test Project', 2);
        insert projectList;
        List<Agreement__c> agreementList    = TestDataFactory_Agreements.generateAgreements('Test Agreement', accountList[0].id, 
                                                                                         Constants.RECORDTYPEID_AGREEMENT_RETAINER, 
                                                                                         'Active', 
                                                                                         Date.newInstance(System.Today().Year(), System.Today().Month() - 1, 1), 
                                                                                         Date.newInstance(System.Today().Year() + 1, System.Today().Month() - 1, 1), 
                                                                                         2);

        insert agreementList;
        List<Rate__c> rateList              = TestDataFactory_Rates.generateRateForAgreement(agreementList[0].id, 
                                                                                'Time & Materials', 
                                                                                Constants.ROLE_USER_EXPERIENCE, 4, 2);
        rateList[1].Assignment_Type__c      = 'Named Resource';
        rateList[1].RecordTypeId            = Constants.RECORDTYPEID_RATE_NAMED_RESOURCE;
        rateList[1].Role__c                 = Constants.ROLE_DEVELOPER;
        insert rateList;
        List<Project_Agreement__c> projectAgreementList = TestDataFactory_ProjectAgreements.generateProjectAgreements(projectList[0].Id, agreementList[0].Id,1);
        insert projectAgreementList;
        List<Assignment__c> assignmentList  = TestDataFactory_Assignments.generateAssignments(projectList[0].Id, contactList[0].Id, 
                                                                                             rateList[0].Id, Constants.ASSIGNMENT_STATUS_ACTIVE, Constants.ROLE_DEVELOPER, 
                                                                                             Constants.ASSIGNMENTTYPE_NAMEDRESOURCE, true, 
                                                                                             100, 2);
        assignmentList[1].Start_Date__c     = assignmentList[1].Start_Date__c.addYears(1).addDays(7);
        assignmentList[1].End_Date__c       = assignmentList[1].End_Date__c.addYears(1).addDays(7);
        assignmentList[1].Cost_Rate__c      = rateList[1].Id;
        assignmentList[0].Cost_Rate__c      = rateList[0].Id;
        insert assignmentList;
        List<Invoice__c> invoiceList        = TestDataFactory_Invoices.generateInvoices(accountList[0].id, date.today(), date.today().addDays(2), date.today().addDays(6), 1.2, 1);
        insert invoiceList;
        List<Invoice_Line_Item__c> invoiceLineItemList = TestDataFactory_InvoiceLineItems.generateInvoiceLineItems(invoiceList[0].Id, 
                                                                                                                   Constants.RECORDTYPEID_INVOICE_10KCREDITINVOICELINEITEM, 
                                                                                                                   rateList[0].Id, 10, 1000, 2);
        invoiceLineItemList[1].rate__c      = rateList[0].Id;
        invoiceLineItemList[1].invoice__c   = invoiceList[0].Id;
        invoiceLineItemList[1].RecordTypeId = Constants.RECORDTYPEID_INVOICE_10KGOODWILLNVOICELINEITEM;
        invoiceLineItemList[1].Discount__c  = 50;
        invoiceLineItemList[1].Sales_Price__c = 5000;
        insert invoiceLineItemList;
        List<time_entry__c> timeEntries     = TestDataFactory_TimeEntries.generateTimeEntries(assignmentList[0].Id, 
                                                                                          'Test Time Entry', Date.today(), 
                                                                                          5.5, 1);
        timeEntries[0].Invoice__c           = invoiceList[0].id;
        timeEntries[0].Goodwill_Hours__c    = 5.00;
        timeEntries[0].Delivery_Partner_Invoice__c  = invoiceList[0].Id;
        timeEntries[0].Expert_Goodwill_Hours__c     = 5.00;
        insert timeEntries;

        Test.startTest();
            apexpages.currentpage().getparameters().put('id',invoiceList[0].id);
            ApexPages.StandardController sc = new ApexPages.StandardController(invoiceList.get(0));
            ApplyGoodwillController cntrlr  = new ApplyGoodwillController(sc);
            cntrlr.saveTimeEntries();
            System.assertEquals(invoiceLineItemList.size(), 2);
        Test.stopTest();
    }
}