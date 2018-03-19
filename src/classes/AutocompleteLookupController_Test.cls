@isTest
public with sharing class AutocompleteLookupController_Test {
	@IsTest 
    public static void testcase(){
		TestDataFactory factory = new TestDataFactory();

        List<Account> accountList = factory.generateAccounts(1);
    	accountList[0].Name = 'My Test Account';
    	insert accountList;

    	//var res = queryTerm + '#' + '{!objectName}' + '#' + '{!FieldName}';
    	String queryString = 'Test#Account#Name';

    	AutocompleteLookupController.dynamicQuery(queryString);
    }
}