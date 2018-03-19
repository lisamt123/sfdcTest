@isTest
private class InvoiceCreationUtility_Test {

    private static testMethod void test() {
        setup();
        // Update Trigger
        Test.startTest();
        List<Opportunity> Opps = new List<Opportunity> ();
        for(Opportunity Opp: [SELECT Id,StageName FROM Opportunity ]){
            opp.StageName = 'Closed Won';
            opp.Subscription_Start_Date__c = Date.today();
            opp.Subscription_End_Date__c = Date.today() + 5;
            Opps.add(opp);
        }
        
        update Opps;
        Test.stopTest();
        
        //system.assertEquals(2, [SELECT Id FROM Invoice__c].size());
        //system.assertEquals(4, [SELECT Id FROM Invoice_Line_Item__c].size());
        // Insert Trigger
        String PRODUCT_OPPORTUNITY = 'Product Opportunity';
        Id OpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(PRODUCT_OPPORTUNITY).getRecordTypeId();
        Account acc =  new Account(name = 'Test Account');
        insert acc;
        insert new Opportunity(name = 'Test Opportunity', StageName = 'Closed Won', closeDate = date.Today(),amount = 100, accountId = acc.Id, recordTypeId = OpportunityRecordTypeId, Subscription_Start_Date__c = Date.today(), Subscription_End_Date__c = Date.today() + 5);
        
        //system.assertEquals(3, [SELECT Id FROM Invoice__c].size());
        
        
    }
    // Creating test Records
    private static void setup(){
        String PRODUCT_OPPORTUNITY = 'Product Opportunity';
        Id OpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(PRODUCT_OPPORTUNITY).getRecordTypeId();
        Account acc = new Account(name = 'Test Account');
        Account acc1 = new Account(name = 'Test Account1');
        insert new List<Account>{acc,acc1};
        
        Id pricebookId = Test.getStandardPricebookId();
        
        product2 prod = new product2(Name = 'TestProduct');
        insert prod;
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id,UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Opportunity Opp = new Opportunity(name = 'Test Opportunity', StageName = 'Qualification', closeDate = date.Today(),amount = 100, accountId = acc.Id, recordTypeId = OpportunityRecordTypeId, Subscription_Start_Date__c = Date.today(), Subscription_End_Date__c = Date.today() + 5) ;
        insert Opp;
        /*Opportunity Opp1 = new Opportunity(name = 'Test Opportunity1', StageName = 'Qualification', closeDate = date.Today(),amount = 100, accountId = acc1.Id, recordTypeId = OpportunityRecordTypeId, Subscription_Start_Date__c = Date.today(), Subscription_End_Date__c = Date.today() + 5) ;
        insert new List<Opportunity> {Opp,Opp1};*/
        
        OpportunityLineItem Oli = new OpportunityLineItem(OpportunityId = opp.id, PricebookEntryId = standardPrice.id,  UnitPrice = 500, Discount = 5, Quantity = 1);
        insert Oli;
        /*OpportunityLineItem Oli1 = new OpportunityLineItem(OpportunityId = opp.id, PricebookEntryId = standardPrice.id, UnitPrice = 500, Discount = 5, Quantity = 1);
        
        OpportunityLineItem Oli2 = new OpportunityLineItem(OpportunityId = opp1.id, PricebookEntryId = standardPrice.id, UnitPrice = 500, Discount = 5, Quantity = 1);
        OpportunityLineItem Oli3 = new OpportunityLineItem(OpportunityId = opp1.id, PricebookEntryId = standardPrice.id, UnitPrice = 500, Discount = 5, Quantity = 1);
        insert new List<OpportunityLineItem> {Oli,Oli1,Oli2,Oli3};*/
        
    }

}