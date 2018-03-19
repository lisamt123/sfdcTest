@isTest
private class ProjectRequestOverrideHandler_Test {

	private static testMethod void testRedirectMethod() {
        ProjectRequestOverrideHandler classObj = new ProjectRequestOverrideHandler(null);
        pageReference pgRef = classObj.redirect();
        system.assertNotEquals(null, pgRef);
	}

}