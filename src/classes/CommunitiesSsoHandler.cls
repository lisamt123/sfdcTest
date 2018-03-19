global class CommunitiesSsoHandler implements Auth.RegistrationHandler {
	//Error handler class 
	class RegHandlerException extends Exception { }
	
	private user u;
    private List<User> userList;
    private static String STR_USERNOTFOUND = 'User not found. For help, contact your administrator.';
    private static String STR_USERINACTIVE = 'User not active. For help, contact your administrator.';

    global User findUser(Auth.UserData data) {
        System.debug('**** UserData.Email  ' + Data.Email);

        //First match user email
        userList = [select Id, Username, IsActive from User where Email = : data.Email];

        System.debug('**** userList  ' + userList);

        if (userList.size() == 1) {
        	//if single user is found we are good to go and let user login
            return userList[0];
        } else {
            //if more than 1 or no user matched, match user against its contact email
            userList = [select Id, Username, IsActive from User where User.Contact.Email = : data.Email];
            if(userList.size() == 1) {
            	//if single user is found we are good to go and let user login
                return userList[0];
            }else {
                //if more than 1 or no user matched, match user against its contact other email
                userList = [select Id, Username, IsActive from User where User.Contact.Other_Email__c = : data.Email];
	            if (userList.size() == 1) {
	            	//if single user is found we are good to go and let user login
	                return userList[0];
	            }else {
	            	//if more than 1 or no user matched, finally match user against its contact Webassessor email
	                userList = [SELECT Id, Username, IsActive FROM User WHERE Contact.Webassessor_Email__c =: data.email];
        			if(userList.size() == 1) {
        				//if single user is found we are good to go and let user login
        				return userList[0];	
        			}else {
        				//Show loggin error, with message to user
        				//throw new RegHandlerException('We encountered a problem signing you in, please try another login method.');
        				throw new RegHandlerException(STR_USERNOTFOUND);
        			}
	            }
            }
        }
    }
    	
    global User createUser(Id portalId, Auth.UserData data) {
        u = findUser(data);
        return u;
    }

    global void updateUser(Id userId, Id portalId, Auth.UserData data) {
    	System.debug('After first time update is firing------ '+userId + '  -----  ' +portalId +'  ====data---- '+data);
       	Boolean activeUser = [select Id, IsActive from User where Id = : userId].IsActive;
        if (activeUser) {
            // User is allowed to login successfully
        } else {
            throw new RegHandlerException(STR_USERINACTIVE);
        }
    }
}