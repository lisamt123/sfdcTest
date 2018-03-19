public with sharing class TestDataFactory_Contacts {
    
    public static List<Contact> generatecontacts(List<Account> accountList, String firstName, String lastName, String email, String webassessorEmail, Integer numOfRecords) {
        return generatecontactsInternal(accountList, firstName, lastName, email, webassessorEmail, numOfRecords);
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<Contact> generatecontactsInternal(List<Account> accountList, String firstName, String lastName, String email, String webassessorEmail, Integer numOfRecords) {
        List<Contact> contactList = new List<Contact>();
        
        for(Account acct : accountList) {
            for(Integer i = 0; i < numOfRecords; i++) {
                Contact con = new Contact();
                con.FirstName = firstName;
                con.LastName = lastName+' '+ i+1;
                con.AccountId = acct.Id;
                con.Email = email;
                con.Webassessor_Email__c = webassessorEmail;
                contactList.add(con);
            }
        }
        
        return contactList;
    }
}