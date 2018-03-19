public with sharing class TestDataFactory_Users {
    
    public static List<User> generateUsers(Id contactId, String profileName, boolean IsActive, Integer numOfRecords) {
    	
    	Profile userProfile = [SELECT Id FROM Profile WHERE Name=:profileName];
    	
		return generateUsersInternal(contactId, userProfile.Id, IsActive, numOfRecords);
    }
    
    public static List<User> generateUsersWith10KCustomerProfile(boolean IsActive, Integer numOfRecords) {
    	
    	Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = new List<Account>();
        List<Contact> contactList = new List<Contact>();
        List<User> userLi = new List<User>();
        for(integer i = 0; i < numOfRecords ; i ++) {
        	
        	accList.addAll(TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test'+i+1, 'Prospect', 15, 'code coverage', 'internal',
                                                            'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                            'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
                                                            null, 'Net 30', 'acc@testemail.com', 'TestA'+i, 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
                                                            1));
        }
        insert accList;
        
        contactList.addAll(TestDataFactory_Contacts.generateContacts(accList, 'Test contact', 'lastName', 'test1@testemail.com', '', 1));
        insert contactList;
        
        Profile communityUserProfile = [SELECT Id FROM Profile WHERE Name = '10K Services Client (License)'];

        for(integer i = 0; i < accList.size(); i ++) {
        	
        	userLi.addAll(generateUsersInternal(contactList[i].Id, communityUserProfile.Id, IsActive, 1));
        }
        return userLi;
    }

    public static List<User> generateUsersWith10KDeliveryPartnerProfile(boolean IsActive, Integer numOfRecords) {
    	
    	Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = new List<Account>();
        List<Contact> contactList = new List<Contact>();
        List<User> userLi = new List<User>();
        for(integer i = 0; i < numOfRecords ; i ++) {
        	
        	accList.addAll(TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test'+i+1, 'Prospect', 15, 'code coverage', 'internal',
                                                            'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                            'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
                                                            null, 'Net 30', 'acc@testemail.com', 'TestB'+i, 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
                                                            1));
        }
        insert accList;
        
        contactList.addAll(TestDataFactory_Contacts.generateContacts(accList, 'Test contact', 'lastName', 'test1@testemail.com', '', 1));
        insert contactList;
        
        Profile communityUserProfile = [SELECT Id FROM Profile WHERE Name = '10K Delivery Partner (License)'];

        for(integer i = 0; i < contactList.size(); i ++) {
        	
        	userLi.addAll(generateUsersInternal(contactList[i].Id, communityUserProfile.Id, IsActive, 1));
        }
        return userLi;
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<User> generateUsersInternal(Id contactId, Id profileId, boolean IsActive, Integer numOfRecords) {
    	List<User> userList = new List<User>();
        
        for(integer i = 0; i < numOfRecords ; i ++) {
            User u = new User(Alias = 'user' + i, 
                              Email = 'testUser' + i + '@10kcommunityview.com',
                              EmailEncodingKey = 'UTF-8', 
                              Country = 'United States',
                              LastName = 'Testing' + i, 
                              LanguageLocaleKey = 'en_US', 
                              LocaleSidKey = 'en_US', 
                              ProfileId = profileId, 
                              TimeZoneSidKey = 'America/Los_Angeles',
                              UserName = 'testUser' + i + '@10kcommunityview.com',
                              IsActive = IsActive);
            
            if(contactId != null) {
                u.UserName += contactId;
                u.ContactId = contactId;
            }
            userList.add(u);
        }
        
        return userList ;
    }
}