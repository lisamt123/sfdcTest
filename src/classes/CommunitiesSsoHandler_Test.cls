@isTest
private class CommunitiesSsoHandler_Test {

	@testSetup static void setupData() {
		TestDataFactory factory = new TestDataFactory();
		List<User> userList = factory.createUsersWith10KDeliveryPartnerProfileNew(1); 
		insert userList;
	}	
	
	static testMethod void testCreateAndUpdateUser() {
	    CommunitiesSsoHandler handler = new CommunitiesSsoHandler();
	    Auth.UserData sampleData = new Auth.UserData( 'testId', 'testFirst', 'testLast', 'testFirst testLast',
	        										  'testUser0@10kcommunityview.com', null, 'testuserlong',
	        										  'en_US', 'salesforce', null, 
	        										   new Map<String, String>{'language' => 'en_US'}
	        										 );
	        										 
	    User user = handler.createUser(null, sampleData);
	    System.assertNotEquals(null, user.id);
	    
	    String userId = user.id;
	    sampleData = new Auth.UserData( 'testNewId', 'testNewFirst', 'testNewLast',
	        						    'testNewFirst testNewLast', 'testnewuser@example.org',
	        						     null, 'testnewuserlong', 'en_US', 'salesforce',
	       								 null, new Map<String, String>{}
	       							   );
	    handler.updateUser(userId, null, sampleData);
	    
	    //User updatedUser = [SELECT userName, email, firstName, lastName, alias FROM user WHERE id=:userId];
	    //System.assertEquals('testnewuser@example.org', updatedUser.email);
	    //System.assertEquals('testNewLast', updatedUser.lastName);
	    //System.assertEquals('testNewFirst', updatedUser.firstName);
	}
	
	static testMethod void testCreateUserMatchContactEmail() {
		CommunitiesSsoHandler handler = new CommunitiesSsoHandler();
	    Auth.UserData sampleData = new Auth.UserData( 'testId', 'testFirst', 'testLast', 'testFirst testLast',
	        										  'test@contact.com', null, 'testuserlong',
	        										  'en_US', 'salesforce', null, 
	        										   new Map<String, String>{'language' => 'en_US'}
	        										 );
	        										 
	    User user = handler.createUser(null, sampleData);
	    System.assertNotEquals(null, user.id);	
	}
	
	static testMethod void testCreateUserMatchContactOtherEmail() {
		CommunitiesSsoHandler handler = new CommunitiesSsoHandler();
	    Auth.UserData sampleData = new Auth.UserData( 'testId', 'testFirst', 'testLast', 'testFirst testLast',
	        										  'test@other.com', null, 'testuserlong',
	        										  'en_US', 'salesforce', null, 
	        										   new Map<String, String>{'language' => 'en_US'}
	        										 );
	        										 
	    User user = handler.createUser(null, sampleData);
	    System.assertNotEquals(null, user.id);	
	}
	
	static testMethod void testCreateUserMatchContactWebassessorEmail() {
		CommunitiesSsoHandler handler = new CommunitiesSsoHandler();
	    Auth.UserData sampleData = new Auth.UserData( 'testId', 'testFirst', 'testLast', 'testFirst testLast',
	        										  'test@webassessor.com', null, 'testuserlong',
	        										  'en_US', 'salesforce', null, 
	        										   new Map<String, String>{'language' => 'en_US'}
	        										 );
	        										 
	    User user = handler.createUser(null, sampleData);
	    System.assertNotEquals(null, user.id);	
	}		
}