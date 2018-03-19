@isTest
private class SandboxRefreshUtility_Test 
{

	@isTest static void test_SandboxRefreshUtility() 
	{
		Account acc = new Account(Name = 'Test',
									Additional_Invoice_Recipients__c = 'nneksdifls@jhifojpfj.com');
		insert acc;

		Contact con = new Contact(LastName = 'Test',
									Email = 'kjgbmvnvkjhvcn@kvnvoncv.com',
									AccountId = acc.Id,
									Other_Email__c = 'difhhfiuzhfh@bclzxcxlhc.com');
		insert con;

		Agreement__c agg = new Agreement__c(Name = 'Test Agreement ',
	                                           Account__c = acc.Id,
	                                           RecordTypeId = Constants.RECORDTYPEID_AGREEMENT_RETAINER,
	                                           Additional_Invoice_Recipients__c = 'iueyrasjfdioufy@hgfmljfdjfm.com',
	                                           Effective_Date__c = Date.newInstance(System.Today().Year(), System.Today().Month() - 1, 1),
                                               Valid_Through__c = Date.newInstance(System.Today().Year() + 1, System.Today().Month() - 1, 1));
		insert agg;

		Lead l = new Lead(Company = 'Test',
							LastName = 'Test',
							Status = 'Open',
							Email = 'lakjdlfaj3lkjr1l3412@lkjasdlf.com');
		insert l;

		SandboxRefreshUtility srutility = new SandboxRefreshUtility();
		Test.testSandboxPostCopyScript(srutility, null, null, null);
		System.assertEquals(acc.Name, 'Test');
	}
}