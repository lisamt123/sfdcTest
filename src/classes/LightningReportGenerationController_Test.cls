@isTest
Private class LightningReportGenerationController_Test {
    Static testMethod void myUnitTest() {
        String sDate = String.valueOf(Date.Today());
        String eDate = String.valueOf(Date.Today().addDays(28));
        String projectName = 'All Projects';
        String otherProject = 'Test project -1';
        
        TestDataFactory factory = new TestDataFactory();
        List<User> userList = factory.createUsersWith10KDeliveryPartnerProfileNew(1);
        insert userList;
        
        Test.startTest();
 
            Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
            List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
                                                                'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                                'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
                                                                null, 'Net 30', 'test@test.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
                                                                1);
            insert accList;
            
            List<Contact> contactList = TestDataFactory_Contacts.generatecontacts(accList, 'Test contact', 'lastName', '', '', 1);
            insert contactList;
            System.assertNotEquals(accList, null);        
            List<Agreement__c> agreementList = TestDataFactory_Agreements.generateAgreements('Test Agreement 1', accList[0].Id, Constants.RECORDTYPEID_AGREEMENT_RETAINER, 'Active', Date.newInstance(System.Today().Year(), System.Today().Month() - 1, 1), Date.newInstance(System.Today().Year() + 1, System.Today().Month() - 1, 1) , 1); 
            insert agreementList;
            List<Rate__c> rateList = TestDataFactory_Rates.generateRateForAgreement(agreementList[0].id, Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS, Constants.ROLE_CONSULTANT, 100, 1);
            insert rateList;
             List<Project__c> projectList = TestDataFactory_Projects.generateProjects(accList[0].Id, 'Test Project', 1);
            insert projectList;

            List<Invoice__c> invoiceList = TestDataFactory_Invoices.generateInvoices(accList[0].Id, system.today(),system.today().addDays(-2), system.today(), 2, 1);
            invoiceList.addAll(TestDataFactory_Invoices.generateInvoices(accList[0].Id, system.today().addDays(-32), system.today(), system.today(), 2, 1));
            invoiceList.addAll(TestDataFactory_Invoices.generateInvoices(accList[0].Id, system.today().addDays(-62), system.today(), system.today(), 2, 1));
            invoiceList.addAll(TestDataFactory_Invoices.generateInvoices(accList[0].Id, system.today().addDays(-92), system.today(), system.today(), 2, 1));
            insert invoiceList;

            List<Assignment__c> assignmentList = TestDataFactory_Assignments.generateAssignments(projectList[0].Id, userList[0].ContactId, rateList[0].Id, 'Active', 'Developer', 'Named Resource', true, 250, 2);
            assignmentList[1].Start_Date__c = assignmentList[1].Start_Date__c.addYears(1).addDays(7);
            assignmentList[1].End_Date__c   = assignmentList[1].End_Date__c.addYears(1).addDays(7);
            Insert assignmentList;
            List<time_entry__c>entryList = TestDataFactory_TimeEntries.generateTimeEntries(assignmentList[0].Id,'testing',assignmentList[0].Start_Date__c, 5, 1);//Date.Today()
            entryList[0].Invoice__c = invoiceList[0].Id;
            Insert entryList;

            System.RunAs(userList[0]) {
                LightningReportGenerationController.getDefaultValues(sDate,eDate,projectName, null);
                LightningReportGenerationController.getDefaultValues(sDate,eDate,'', null);
                LightningReportGenerationController.invoiceId = invoiceList[0].Id;
                LightningReportGenerationController.getDefaultValues(sDate,eDate,otherProject, null);
                Set<Id> assignmentIds = new Set<Id>();
                assignmentIds.add(assignmentList[0].Id);
                LightningReportGenerationController.getDefaultValues(sDate,eDate,projectName,JSON.serialize(assignmentIds));
            }

        Test.stopTest();
    }   
}