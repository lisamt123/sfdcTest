public with sharing class CustomLightningForgotPasswordController {
	
	@AuraEnabled
    public static String forgotPassword(String username, String checkEmailUrl) {
        try 
        {
            Site.forgotPassword(username);
            ApexPages.PageReference checkEmailRef = new PageReference(checkEmailUrl);
            List<User> userList = [SELECT id,Username FROM User WHERE IsActive = True AND Username =: username];
            if(!Site.isValidUsername(username) || userList.isEmpty()) 
            {
                return 'We can’t find a username that matches what you entered. Verify that your username is an email address (for example, username@company.com).';
            }
            else {
                aura.redirect(checkEmailRef);
                return null;
            }
        }
        catch (Exception ex) {
            return ex.getMessage();
        }
    }
}