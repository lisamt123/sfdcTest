@IsTest(SeeAllData = true)
private class CustomLightningForgotPassword_Test {
	
	/* Verifies that ForgotPasswordController handles invalid usernames appropriately */
	@IsTest
	static void testCustomLightningForgotPasswordControllerInvalidUserName() 
	{
		System.assertEquals(CustomLightningForgotPasswordController.forgotPassword('fakeUser', 'http://a.com'), 'We can’t find a username that matches what you entered. Verify that your username is an email address (for example, username@company.com).');
		System.assertEquals(CustomLightningForgotPasswordController.forgotPassword(null, 'http://a.com'), 'We can’t find a username that matches what you entered. Verify that your username is an email address (for example, username@company.com).');
		System.assertEquals(CustomLightningForgotPasswordController.forgotPassword('a', '/home/home.jsp'), 'We can’t find a username that matches what you entered. Verify that your username is an email address (for example, username@company.com).');
	}

	/* Verifies that null checkEmailRef url throws proper exception. */
	@IsTest
	static void testCustomLightningForgotPasswordControllerWithNullCheckEmailRef() 
	{
		System.assertEquals(CustomLightningForgotPasswordController.forgotPassword('a', null), 'Argument 1 cannot be null');
		System.assertEquals(CustomLightningForgotPasswordController.forgotPassword('a@salesforce.com', null), 'Argument 1 cannot be null');
	}

	/* Verifies that CustomLightningForgotPasswordController object is instantiated correctly. */
	@IsTest
	static void LightningForgotPasswordControllerInstantiation() 
	{
		CustomLightningForgotPasswordController controller = new CustomLightningForgotPasswordController();
		System.assertNotEquals(controller, null);
	}	
}