@isTest
public with sharing class HerokuToken_Test {
	
	@isTest static  void test_usecase_one() {		
		Test.startTest();
			String str = HerokuToken.headerToken();
			System.assertNotEquals(str,null);
		Test.stopTest();
	}
}