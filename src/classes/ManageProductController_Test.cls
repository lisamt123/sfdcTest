@isTest
public class ManageProductController_Test{
    static testMethod void test_method_one() {
        Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accountList    = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test Account', 'Prospect', 15, 
                                                                                'code coverage', 'internal', 'App Cloud;Sales Cloud', 'Enterprise', 
                                                                                'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                                                'code quality with code coverage above 75%', 'NDA aggrement', 'United States', 
                                                                                '501 test street', 'test city', 'Florida', '90001', null, null, 'Net 30', 
                                                                                'acc@testemail.com', 'TestA', 'HELLO WORLD', 'invoicingNotes', 
                                                                                'Partner Client', 1);
        insert accountList;

        List<Project_Request__c> projRequestList = TestDataFactory_ProjectRequest.generateProjectRequest(accountList[0].Id,Date.today(),Date.today().addDays(4),'Test Project Request',2);   
        insert projRequestList;
        List<Project_Request_Detail__c> projrequestDetail = TestDataFactory_ProjectRequestDetail.generateProjectRequestDetail(projRequestList[0].Id,2);
        insert projrequestDetail ;
        Test.startTest();
            ManageProductController.RequestedExpertWrapper requestExpertWrapper = ManageProductController.getRequestedExperts(projRequestList[0].Id);
            System.assertEquals(requestExpertWrapper.workRequest.Id,projRequestList[0].Id);
        Test.stopTest();
    }

    static testMethod void test_method_two() {
        Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accountList    = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test Account', 'Prospect', 15, 
                                                                                'code coverage', 'internal', 'App Cloud;Sales Cloud', 'Enterprise', 
                                                                                'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                                                'code quality with code coverage above 75%', 'NDA aggrement', 'United States', 
                                                                                '501 test street', 'test city', 'Florida', '90001', null, null, 'Net 30', 
                                                                                'acc@testemail.com', 'TestA', 'HELLO WORLD', 'invoicingNotes', 
                                                                                'Partner Client', 1);
        insert accountList;

        List<Project_Request__c> projRequestList = TestDataFactory_ProjectRequest.generateProjectRequest(accountList[0].Id,Date.today(),Date.today().addDays(4),'Test Project Request',2);   
        insert projRequestList;
        List<Project_Request_Detail__c> projrequestDetail = TestDataFactory_ProjectRequestDetail.generateProjectRequestDetail(projRequestList[0].Id,2);
        insert projrequestDetail ;
        String region = 'Africa' ;
        String role = 'Architect';


        List<Product2> prod =  TestDataFactory_Products.generateProducts('Developer - Time & Materials', 'Developer');
        insert prod;

        Id standardPriceBookId = Test.getStandardPricebookId();

        List<PricebookEntry> standardPrice = TestDataFactory_PriceBookEntries.generatePriceBookEntries(standardPriceBookId, prod[0].Id, 10000, true);
        insert standardPrice;
        
        Id servicesRecordTypeId = Schema.SObjectType.Pricebook2.getRecordTypeInfosByName().get('Services Price Book').getRecordTypeId();
        List<PriceBook2> pb = TestDataFactory_PriceBooks.generatePriceBooks('Custom Test PriceBook', true, 'Base', 'Testing', 1);
        pb[0].RecordTypeId = servicesRecordTypeId;
        insert pb;
        
        List<PricebookEntry> customPrice = TestDataFactory_PriceBookEntries.generatePriceBookEntries(pb[0].Id, prod[0].Id, 12000, true);
        insert customPrice;


        Id msaRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('MSA Opportunity').getRecordTypeId();
        Id serviceRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Services Opportunity').getRecordTypeId();
        
        List<Opportunity> oppList = TestDataFactory_Opportunity.generateOpportunities(accountList[0].Id,msaRecordTypeId, 'Closed Won', system.today().addDays(2),system.today().addDays(-30),system.today().addDays(-2), 2);
        oppList[0].RecordTypeId = serviceRecordTypeId;
        oppList[1].Selected_Price_Book__c = pb[0].Id;
        oppList[1].RecordTypeId = msaRecordTypeId ;
        insert oppList;
        oppList[0].MSA_Opportunity__c = oppList[1].Id ;
        update oppList ;
        projRequestList[0].Opportunity__c = oppList[0].Id ;
        update projRequestList ;

        List<Rate_Card__c> rateCardList = TestDataFactory_RateCard.generateRateCard('Test Rate Card', projRequestList[0].Opportunity__c, region, role, 1);
        insert rateCardList ;
        List<Project_Request_Detail__c> projectRequestDetailList = TestDataFactory_ProjectRequestDetail.generateProjectRequestDetail(projRequestList[0].Id,1);
        String projRequestString =  JSON.serialize(projectRequestDetailList[0]);
        Id recId = projRequestList[0].Id ;
        Project_Request__c workRequest = [SELECT Id, Start_Date__c, End_Date__c, Opportunity__r.MSA_Opportunity__c 
                                            FROM Project_Request__c WHERE Id =: recId];
        workRequest.Opportunity__r.MSA_Opportunity__c = oppList[1].Id ;
        update workRequest ;
        Test.startTest();
            ManageProductController.getRatePickVals(role, region, workRequest);
            ManageProductController.approveRequestedExperts(projRequestString,projRequestList[0].Id);
            String requestIdString = String.valueOf(projrequestDetail[0].Id);
            ManageProductController.delRequestedExpert(requestIdString, projRequestList[0].Id);
            List<Project_Request_Detail__c> delRequestDetailList = [SELECT Id FROM Project_Request_Detail__c WHERE Id =: requestIdString] ;
            system.assertEquals(0,delRequestDetailList.size());
        Test.stopTest();
    }
}