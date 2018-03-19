@isTest
private class ProjectRequestDetailTriggerHandler_Test {
   
   @testSetup static void setup() {
       Account ac = new Account(
        Name = 'TestAc'
     );
     Database.insert( ac );
    Test.startTest();
     Project_Request__c pRequest = new Project_Request__c(
        Closed_Date__c = Date.today(),
        Start_Date__c = Date.today(),
        End_Date__c  =  Date.today().addDays(1),
        Status__c = 'New',
        Account__c =  ac.Id
     );
     Database.insert( pRequest );
     
     List<Project_Request__c > pReq = [SELECT Id,Opportunity__c,Opportunity__r.PriceBook2Id FROM Project_Request__c WHERE ID = :pRequest.Id ];
     System.assertNotEquals( pReq[0].Opportunity__c, NULL );
     
     List<Product2> prod =  TestDataFactory_Products.generateProducts('Developer - India - Time & Materials', 'Developer');
     prod[0].Region__c = 'India';
     insert prod;
     List<Product2> prod1 =  TestDataFactory_Products.generateProducts('Technical Lead - India - Time & Materials', 'Technical Lead');
     prod1[0].Region__c = 'India';
     insert prod1;

     Id standardPriceBookId = Test.getStandardPricebookId();

     List<PricebookEntry> standardPrice = TestDataFactory_PriceBookEntries.generatePriceBookEntries(standardPriceBookId, prod[0].Id, 10000, true);
     insert standardPrice;
     
     List<PricebookEntry> standardPrice1 = TestDataFactory_PriceBookEntries.generatePriceBookEntries(standardPriceBookId, prod1[0].Id, 10000, true);
     insert standardPrice1;
        
     Id servicesRecordTypeId = Schema.SObjectType.Pricebook2.getRecordTypeInfosByName().get('Services Price Book').getRecordTypeId();
     List<PriceBook2> pb = TestDataFactory_PriceBooks.generatePriceBooks('Custom Test PriceBook', true, 'Base', 'Testing', 1);
     pb[0].RecordTypeId = servicesRecordTypeId;
     insert pb;
        
     List<PricebookEntry> customPrice = TestDataFactory_PriceBookEntries.generatePriceBookEntries(pb[0].Id, prod[0].Id, 12000, true);
     insert customPrice;
     
     List<PricebookEntry> customPrice2 = TestDataFactory_PriceBookEntries.generatePriceBookEntries(pb[0].Id, prod1[0].Id, 12000, true);
     insert customPrice2;
        
      List<opportunity> opp = [SELECT PriceBook2Id FROM opportunity WHERE Id =: pReq[0].Opportunity__c];
      opp[0].PriceBook2Id = pb[0].Id;  
      Database.update( opp );
      System.assertNotEquals( opp[0].PriceBook2Id , NULL );
      List<Project_Request_Detail__c> lstProjectRequestDetails = new List<Project_Request_Detail__c>();
      Project_Request_Detail__c objProjectRequestDetail1 = new Project_Request_Detail__c (
        Requested_Rate__c = 6,
        Requested_Hours__c = 5,
        Region__c = 'India',
        Project_Request__c = pRequest.Id,
        Role__c = 'Developer'
     );
     lstProjectRequestDetails.add(objProjectRequestDetail1);
     Database.insert( lstProjectRequestDetails );
     
     //lstProjectRequestDetails[0].Requested_Hours__c  = 10;   where id =:lstProjectRequestDetails[0].id
      Test.stopTest();
        
    }
   
   
   static testMethod void test_method_one() {
        Test.startTest();
      List<Project_Request_Detail__c> pdetail = [Select Requested_Hours__c  from Project_Request_Detail__c];
      pdetail[0].Requested_Hours__c  = 10;
      Database.update( pdetail[0] );
      
       Delete pdetail[0];
        Test.stopTest();
       List<Project_Request__c> projectRequets = [Select Opportunity__c  from Project_Request__c];
       System.assertNotEquals(projectRequets[0].Opportunity__c, null);
   } 
        
}