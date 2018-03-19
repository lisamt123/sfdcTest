@IsTest
public class CaseTriggerHandler_Test{

    @IsTest 
    public static void CaseTriggerHandlerTest(){
    	Case newCase = new Case();
    	newCase.Status = 'New';
    	newCase.Subject = 'Test Case';
    	insert newCase;    
    }
    
    static testMethod void test_method_one() {
		
		TestDataFactory objTestDataFactory = new TestDataFactory();
		
        List<Account> lstAccounts = objTestDataFactory.generateAccounts(1);
        insert lstAccounts;
        
        List<Contact> lstContacts = objTestDataFactory.generateContactsForAccounts(lstAccounts, 2);
        lstContacts[0].Email = 'rajesh.kamath@trekbin.com';
        lstContacts[1].Email = 'rajesh.test@trekbin.com';
        insert lstContacts;

        List<User> userList = objTestDataFactory.createUsersWith10KDeliveryPartnerProfileNew(1);
        userList[0].Email = 'test@contact.com';
        userList[0].Authorized_DFP_Case_Creator__c = true;
        insert userList;

        List<Case> lstCases = new List<Case>();        
        lstCases.add(objTestDataFactory.generateCase('rajesh.kamath@trekbin.com'));
        lstCases.add(objTestDataFactory.generateCase('test.test@trekbin.com'));
        lstCases.add(objTestDataFactory.generateCase('test@contact.com'));
        lstCases[2].ContactId = lstContacts[0].Id;
        lstCases[2].Subject = '10K Case number';
        lstCases[2].RecordTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get('DoubleClick for Salesforce').RecordTypeId;
        lstCases[0].Origin = '10K Community';
        lstCases[1].Origin = '10K Community';
        insert lstCases;        
    }
}