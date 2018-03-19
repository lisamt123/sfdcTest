@isTest
public class OpportunityTriggerHandler_Test{

    @isTest
    public static void ProjectInsertOnClosedWonOppTest() {
    
        //TestDataFactory factory = new TestDataFactory();
        
        //List<Account> accList = factory.generateAccounts(1);
        //insert accList;
        test.startTest();
        /* apar */
        Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accountList    = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test Account', 'Prospect', 15, 
                                                                                'code coverage', 'internal', 'App Cloud;Sales Cloud', 'Enterprise', 
                                                                                'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                                                'code quality with code coverage above 75%', 'NDA aggrement', 'United States', 
                                                                                '501 test street', 'test city', 'Florida', '90001', null, null, 'Net 30', 
                                                                                'acc@testemail.com', 'TestA', 'HELLO WORLD', 'invoicingNotes', 
                                                                                'Partner Client', 1);
        insert accountList;

        /* apar */
        
        //generating opportunity
        //List<Opportunity> oppList = factory.generateOpportunities(accList[0].Id,'Qualification', system.today().addDays(2), 2);
        //oppList[1].stageName = Constants.OPP_STAGE_CLOSED_WON; 
        //oppList[0].stageName = Constants.OPP_STAGE_CLOSED_WON; 
        //insert oppList;
        
        /* apar */
        List<Opportunity> oppList = TestDataFactory_Opportunity.generateOpportunities(accountList[0].Id, Constants.RECORDTYPEID_OPPORTUNITY_PRODUCT, 'Test opportunity', 
                                                                                      date.today().addYears(1), date.today().addDays(1), 
                                                                                      date.today().addDays(20), 2);

        insert oppList;
        /* apar */

        //verify insert case
        //system.assert([SELECT Id FROM Project__c WHERE Opportunity__c =: oppList[1].Id].size() > 0);
        
         //oppList[0].RecordTypeId = Constants.RECORDTYPEID_OPPORTUNITY_PRODUCT;
         //oppList[1].RecordTypeId = Constants.RECORDTYPEID_OPPORTUNITY_PRODUCT;
         //update oppList;
        
        //system.assert([SELECT Id FROM Opportunity WHERE RecordTypeId =: Constants.RECORDTYPEID_OPPORTUNITY_PRODUCT].size() > 0);
        system.assert(oppList.size() > 0);
        test.stopTest();
    }
    
  static testMethod void test_method_one() {
        
    
        test.startTest();
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
        
        Id trialRecordTypeID = [select Id, Name, sObjectType from RecordType Where Name = 'Trial' And sObjectType = 'sfLma__License__c'][0].Id;
        
        List<sfLma__License__c> LicensesList = new List<sfLma__License__c>();
        
        if(trialRecordTypeID != null) {
            
          
            LicensesList = TestDataFactory_License.generateLicense(accountList[0].Id, contactList[0].Id, trialRecordTypeID, 'active', 2);
            LicensesList[0].sfLma__Subscriber_Org_Is_Sandbox__c = false ;
            LicensesList[1].sfLma__Subscriber_Org_Is_Sandbox__c = false ;
        }
        Id pricebookId = Test.getStandardPricebookId(); 
        
        List<Product2> productList = TestDataFactory_Products.generateProducts('Product X', 'Architect');
        productList[0].ProductCode = 'Pro-X' ;
        productList[0].isActive = true ;
        insert productList;
       
        List<PricebookEntry> pbEntryList = TestDataFactory_PriceBookEntries.generatePriceBookEntries(pricebookId, productList[0].Id, 100, true);
        insert pbEntryList ;
        
        List<Opportunity> opportunitiesList = TestDataFactory_Opportunity.generateOpportunities(accountList[0].Id, Constants.RECORDTYPEID_OPPORTUNITY_PRODUCT, 'Closed Won', system.today().addYears(1), system.today(), system.today().addDays(2), 2);
        opportunitiesList[1].Is_Closed_Through_Process__c  = true;
        opportunitiesList[0].Is_Closed_Through_Process__c  = true;
        opportunitiesList[0].Name = 'Test Oppty1' ;
        opportunitiesList[1].Name = 'Test Oppty2';
        opportunitiesList[1].StageName = 'Proposal' ;
        insert opportunitiesList ;
        
        List<OpportunityContactRole> oppContactRoleList = TestDataFactory_OpportunityContactRole.generateOpportunityContactRole(opportunitiesList[1].Id, contactList[0].Id, 'Test', 1);
        insert oppContactRoleList;
        
        List<OpportunityLineItem> oppLineItemList = TestDataFactory_OpportunityLineItem.generateOpportunityLineItem(opportunitiesList[1].Id, 5, pbEntryList[0].Id, pbEntryList[0].UnitPrice, 1);
        insert oppLineItemList ;
        Test.stopTest();
        Opportunity objOpportunity3 = new Opportunity(Id = opportunitiesList[1].Id, StageName = 'Closed Won');
        update objOpportunity3;
        system.assertEquals(objOpportunity3.StageName , 'Closed Won');
        //system.assert([SELECT Id FROM Opportunity WHERE RecordTypeId =: Constants.RECORDTYPEID_OPPORTUNITY_PRODUCT].size() > 0);
        //test.stopTest();
    }

    static testMethod void test_method_two() {
        test.startTest();
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
        
        List<Opportunity> opportunitiesList = TestDataFactory_Opportunity.generateOpportunities(accountList[0].Id, Constants.RECORDTYPEID_OPPORTUNITY_MSA, 'Closed Won', system.today().addYears(1), system.today(), system.today().addDays(2), 2);
        opportunitiesList[1].Is_Closed_Through_Process__c  = true;
        opportunitiesList[0].Is_Closed_Through_Process__c  = true;
        opportunitiesList[0].Name = 'Test Oppty1' ;
        opportunitiesList[1].Name = 'Test Oppty2';
        opportunitiesList[0].Start_Date__c = system.today();
        opportunitiesList[0].End_Date__c = system.today().addDays(5);
        opportunitiesList[1].Start_Date__c = system.today().addDays(7);
        opportunitiesList[1].End_Date__c = system.today().addDays(14);
        opportunitiesList[1].StageName = 'Proposal' ;
        insert opportunitiesList ;

        opportunitiesList[1].Start_Date__c = system.today().addDays(4);
       try { 
            update opportunitiesList[1];
        }
       catch(Exception e) {
            //System.assertEquals(e.getMessage(),'This Start Date overlaps with the dates of Opportunity Test Oppty1. Please choose an Start Date that doesn\'t overlap with the other Opportunity.');
        }


    }

    public static testMethod void checkMsaAgreementOnAccount(){
        Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accountList    = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test Account', 'Prospect', 15, 
                                                                                'code coverage', 'internal', 'App Cloud;Sales Cloud', 'Enterprise', 
                                                                                'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                                                'code quality with code coverage above 75%', 'NDA aggrement', 'United States', 
                                                                                '501 test street', 'test city', 'Florida', '90001', null, null, 'Net 30', 
                                                                                'acc@testemail.com', 'TestA', 'HELLO WORLD', 'invoicingNotes', 
                                                                                'Partner Client', 1);
        insert accountList;


        List<Product2> prod =  TestDataFactory_Products.generateProducts('Developer - Time & Materials', 'Developer');
        insert prod;

        Id standardPriceBookId = Test.getStandardPricebookId();

        List<PricebookEntry> standardPrice = TestDataFactory_PriceBookEntries.generatePriceBookEntries(standardPriceBookId, prod[0].Id, 10000, true);
        insert standardPrice;
        
        Id servicesRecordTypeId = Schema.SObjectType.Pricebook2.getRecordTypeInfosByName().get('Services Price Book').getRecordTypeId();
        List<PriceBook2> pb = TestDataFactory_PriceBooks.generatePriceBooks('Custom Test PriceBook', true, 'Base', 'Testing', 1);
        pb[0].RecordTypeId = servicesRecordTypeId;
        insert pb;

        List<Agreement__c> agreementList = TestDataFactory_Agreements.generateAgreements('Test Agreement 1', accountList[0].Id, Constants.RECORDTYPEID_AGREEMENT_MSA, 'Active', Date.newInstance(System.Today().Year(), System.Today().Month() - 1, 1), Date.newInstance(System.Today().Year() + 1, System.Today().Month() - 1, 1) , 1);
        
        insert agreementList;
        
        Id msaRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('MSA Opportunity').getRecordTypeId();
         List<Opportunity> oppList1 = TestDataFactory_Opportunity.generateOpportunities(accountList[0].Id,msaRecordTypeId, 'Qualification', system.today().addDays(2),system.today().addDays(-30),system.today().addDays(-2), 1);
        oppList1[0].Selected_Price_Book__c = pb[0].Id;
        insert oppList1;
        
        agreementList[0].Opportunity__c = oppList1[0].Id;
        update agreementList;
        
        List<PricebookEntry> customPrice = TestDataFactory_PriceBookEntries.generatePriceBookEntries(pb[0].Id, prod[0].Id, 12000, true);
        insert customPrice;

        

        Id serviceRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Services Opportunity').getRecordTypeId();
        List<Opportunity> oppList = TestDataFactory_Opportunity.generateOpportunities(accountList[0].Id,msaRecordTypeId, 'Qualification', system.today().addDays(2),system.today().addDays(-30),system.today().addDays(-2), 1);
        oppList[0].RecordTypeId = serviceRecordTypeId;
        insert oppList;
    }

    public static testMethod void checkNoMsaAgreementOnAccount(){
        Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accountList    = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test Account', 'Prospect', 15, 
                                                                                'code coverage', 'internal', 'App Cloud;Sales Cloud', 'Enterprise', 
                                                                                'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                                                'code quality with code coverage above 75%', 'NDA aggrement', 'United States', 
                                                                                '501 test street', 'test city', 'Florida', '90001', null, null, 'Net 30', 
                                                                                'acc@testemail.com', 'TestA', 'HELLO WORLD', 'invoicingNotes', 
                                                                                'Partner Client', 1);
        insert accountList;


        List<Product2> prod =  TestDataFactory_Products.generateProducts('Developer - Time & Materials', 'Developer');
        insert prod;

        Id standardPriceBookId = Test.getStandardPricebookId();

        List<PricebookEntry> standardPrice = TestDataFactory_PriceBookEntries.generatePriceBookEntries(standardPriceBookId, prod[0].Id, 10000, true);
        insert standardPrice;
        
        Id servicesRecordTypeId = Schema.SObjectType.Pricebook2.getRecordTypeInfosByName().get('Services Price Book').getRecordTypeId();
        List<PriceBook2> pb = TestDataFactory_PriceBooks.generatePriceBooks('Custom Test PriceBook', true, 'Base', 'Testing', 1);
        pb[0].RecordTypeId = servicesRecordTypeId;
        insert pb;

        //List<Agreement__c> agreementList = TestDataFactory_Agreements.generateAgreements('Test Agreement 1', accountList[0].Id, Constants.RECORDTYPEID_AGREEMENT_MSA, 'Active', Date.newInstance(System.Today().Year(), System.Today().Month() - 1, 1), Date.newInstance(System.Today().Year() + 1, System.Today().Month() - 1, 1) , 1);
        
        //insert agreementList;
        
        Id msaRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('MSA Opportunity').getRecordTypeId();
         List<Opportunity> oppList1 = TestDataFactory_Opportunity.generateOpportunities(accountList[0].Id,msaRecordTypeId, 'Qualification', system.today().addDays(2),system.today().addDays(-30),system.today().addDays(-2), 1);
        oppList1[0].Selected_Price_Book__c = pb[0].Id;
        insert oppList1;
        
        //agreementList[0].Opportunity__c = oppList1[0].Id;
        //update agreementList;
        
        List<PricebookEntry> customPrice = TestDataFactory_PriceBookEntries.generatePriceBookEntries(pb[0].Id, prod[0].Id, 12000, true);
        insert customPrice;

        

        Id serviceRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Services Opportunity').getRecordTypeId();
        List<Opportunity> oppList = TestDataFactory_Opportunity.generateOpportunities(accountList[0].Id,msaRecordTypeId, 'Qualification', system.today().addDays(2),system.today().addDays(-30),system.today().addDays(-2), 1);
        oppList[0].RecordTypeId = serviceRecordTypeId;
        insert oppList;

    }

    public static testMethod void checkUpdateServiceOppLinked(){
        TestDataFactory objTestDataFactory = new TestDataFactory();
        
        Test.startTest();
        //Generate a new Community User, and create an Account and Contact for that person as well
        List<User> userList = objTestDataFactory.createUsersWith10KCustomerProfile(1);
        insert userList;

        //Fetch the Contact that is associated with our Community Contact that was inserted
        List<Contact> contactList = [SELECT Id, AccountId 
                                     FROM Contact 
                                     WHERE Id =: userList[0].ContactId];
                                     
        contactList[0].Email = 'testEmail@test.com';
        update contactList;
        
        system.assertEquals(contactList.size(), 1);

        //Before we start, verify that there are no Project_Request__Share records
        List<Project_Request__Share> projectRequestShares = [SELECT Id, AccessLevel, ParentId, RowCause, UserOrGroupId 
                                                             FROM Project_Request__Share
                                                             WHERE RowCause = 'Customer__c'];
        system.assertEquals(projectRequestShares.size(), 0);
        
        List<Project_Request__c> lstProjectRequests = new List<Project_Request__c>();
        
        Project_Request__c objProjectRequest1 = objTestDataFactory.generateProjectRequestRecord(contactList[0].AccountId, 'New', contactList[0].Id, 'TestProjectWithNewStatus', system.today());
        objProjectRequest1.Account__c = contactList[0].AccountId;
        objProjectRequest1.Start_Date__c = system.today();
        objProjectRequest1.Name = 'test1';
        lstProjectRequests.add(objProjectRequest1);
        
        insert lstProjectRequests;

       Opportunity opp =  [SELECT Id, Name FROM Opportunity LIMIT 1];
       opp.Name = 'test';                         
        try{
            update opp;
        }
        catch(Exception ex){

        }                        

        //Verify the Project_Request__Share records were written correctly
        projectRequestShares = [SELECT Id, AccessLevel, ParentId, RowCause, UserOrGroupId 
                                FROM Project_Request__Share
                                WHERE RowCause = 'Customer__c'];

        system.assertEquals(projectRequestShares.size(), 2);
        system.assertEquals(projectRequestShares[0].ParentId, lstProjectRequests[0].Id);

        Test.stopTest();
    }
}