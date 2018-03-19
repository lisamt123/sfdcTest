@isTest
private class AdditionalCaseContactController_Test 
{
	@isTest static void test_method_one() 
	{
		TestDataFactory factory = new TestDataFactory();
		Case caseRec = factory.generateCase('test@test.com');
		caseRec.Origin = 'Phone';
		insert caseRec;
		
		Test.startTest();
			AdditionalCaseContactController.retriveCase((String)caseRec.Id);
			AdditionalCaseContactController.updateAdditionalCaseContacts(caseRec);
			System.assertEquals(caseRec.Origin, 'Phone');
		Test.stopTest();
	}
}