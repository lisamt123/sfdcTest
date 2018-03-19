@IsTest(SeeAllData = true)
private class CustomLightningLoginFormController_Test {
	@IsTest
 	static void testLoginWithInvalidCredentials() {
  		System.assertEquals('Argument 1 cannot be null', CustomLightningLoginFormController.login('testUser', 'fakepwd', null));
 	}

 	@IsTest
 	static void CustomLightningLoginFormControllerInstantiation() {
 		CustomLightningLoginFormController controller = new CustomLightningLoginFormController();
 		System.assertNotEquals(controller, null);
 	}

 	@IsTest
 	static void testIsUsernamePasswordEnabled() {
 		System.assertEquals(true, CustomLightningLoginFormController.getIsUsernamePasswordEnabled());
 	}

 	@IsTest
 	static void testIsSelfRegistrationEnabled() {
 		System.assertEquals(false, CustomLightningLoginFormController.getIsSelfRegistrationEnabled());
 	}

 	@IsTest
 	static void testGetSelfRegistrationURL() {
 		System.assertEquals(null, CustomLightningLoginFormController.getSelfRegistrationUrl());
 	}

 	@IsTest
 	static void testAuthConfig() {
 		Auth.AuthConfiguration authConfig = CustomLightningLoginFormController.getAuthConfig();
 		System.assertNotEquals(null, authConfig);
 		CustomLightningLoginFormController.getMyCustomData();
 	}
}