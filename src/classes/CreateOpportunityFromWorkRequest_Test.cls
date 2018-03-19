@isTest
private class CreateOpportunityFromWorkRequest_Test 
{
    
    @isTest static void test_method_one() 
    {
        TestDataFactory fact = new TestDataFactory();

        Test.startTest();
            List<Account> acc = fact.generateAccounts(2);
            insert acc;
            List<Contact> con = fact.generateContactsForAccounts(acc, 1);
            insert con;
            Project_Request__c projectReq = fact.generateProjectRequestRecord(acc[0].Id, 'New', con[0].Id, 'Test', Date.today());
            projectReq.Start_Date__c = system.today();
            insert projectReq;
            System.assertEquals(acc.size(), 2);
            CreateOpportunityFromWorkRequest.createOpportunity((String)projectReq.Id);
        Test.stopTest();
    }
}