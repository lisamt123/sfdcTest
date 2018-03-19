public with sharing class ProvisionCommunityUserController {

    private String strAuthorizationCode;
    private String strSalesforceBaseUrl;
    private String strRedirectURI;
    public String strGoogleClientID {get;set;}
    private String strGoogleClientSecret;
    private String strGoogleAPIKey;
    private String strGoogle10KDomain;
    private String strExchangedAccessToken;
    private String strUserPrimaryEmail;
    public Contact objContact;  
    public String strContactID                  { get;set; }
    public String strContactFullName            { get;set; }
    public boolean displayCreateUserButton      { get;set; }
    public boolean displayDisableButton         { get;set; }
    public boolean displayEnableButton          { get;set; }
    public boolean displayInputEmailSection     { get;set; }
    public String strMessageToDisplay           { get;set; }
    public String strUserLastLoginDate          { get;set; }
    public String strUserEmailAddress           { get;set; }
    public Boolean isLightningExperience        { get;set; }
    public String strInputPrimaryEmailFromUI    { get;set; }
    
    //For Community user
    public Boolean displayNewUserSection        { get;set; }
    public User communityUser                   { get;set; }
    public List<SelectOption> userTypes         { get;set; }
    public String selectedUserType              { get;set; }
    public String selectedLoginType             { get;set; }
    public boolean isUserActive                 { get;set; }
    public boolean isUserCreated                { get;set; }
    public List<SelectOption> roleLevels        { get;set; }
    public String selectedRoleLevel             { get;set; }
    public List<SelectOption> allPermisstionSet { get;set; } 
    public List<SelectOption> userPermisstionSet{ get;set; }
    public String permissionSets                { get;set; }
    public Boolean isdisabled                   { get;set; }
    public String profileNameDefault            { get;set; }
    public Set<String> permissionSetNameSet     { get;set; }
    public String selectedGoogleUsersCMT        { get;set; }
    private string currentGoogleOwnerId;
    
    public static final GoogleAuthSettings__c objGoogleAuthSettingsCS = GoogleAuthSettings__c.getOrgDefaults();
    
    public ProvisionCommunityUserController() { 
        
        isLightningExperience = false;
        displayNewUserSection = false;
        isdisabled            = true;

        allPermisstionSet = new List<SelectOption>();
        userPermisstionSet = new List<SelectOption>();
        if(ApexPages.CurrentPage().GetParameters().get('sfdcIFrameOrigin') != null) {
            
            isLightningExperience = true;
        }
        
        strAuthorizationCode = ApexPages.currentPage().getParameters().get('code') ;
        
        if(ApexPages.currentPage().getParameters().get('Id') != null && ApexPages.currentPage().getParameters().get('Id') != '') {
        
            strContactId = ApexPages.currentPage().getParameters().get('Id');
        }
        else if(ApexPages.currentPage().getParameters().get('state') != null && ApexPages.currentPage().getParameters().get('state') != '') {
        
            strContactId = ApexPages.currentPage().getParameters().get('state');
        }
        
        displayDisableButton = displayCreateUserButton = displayInputEmailSection = displayEnableButton = false;
        if(objGoogleAuthSettingsCS != null) {
            
            if(!string.isBlank(objGoogleAuthSettingsCS.Refresh_Token__c)) {
                
                displayCreateUserButton = true;
            }
            
            if(!string.isBlank(objGoogleAuthSettingsCS.GoogleClientID__c)) {
                
                strGoogleClientID = objGoogleAuthSettingsCS.GoogleClientID__c;
            }
            
            if(!string.isBlank(objGoogleAuthSettingsCS.GoogleClientSecret__c)) {
                
                strGoogleClientSecret = objGoogleAuthSettingsCS.GoogleClientSecret__c; 
            }
            
            if(!string.isBlank(objGoogleAuthSettingsCS.API_Key__c)) {
                
                strGoogleAPIKey = objGoogleAuthSettingsCS.API_Key__c;
            }
            
            if(!string.isBlank(objGoogleAuthSettingsCS.X10K_Domain__c)) {
                
                strGoogle10KDomain = objGoogleAuthSettingsCS.X10K_Domain__c;
            }
        }
        if(!string.isBlank(strContactId) && !string.isBlank(strGoogle10KDomain)) {
            
            Contact objContactFetched = [SELECT Id, AccountId, Account.Name, Email, FirstName, LastName, Name, Other_Email__c FROM Contact WHERE Id = :strContactId];
            
            if(objContactFetched.Email == null) {
            
                strMessageToDisplay =  'This Contact has no Email. Please add the contact current email address to the Email field, then try again. Note: To go back please click on "Back to Contact" button';
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, strMessageToDisplay));
                
                return;
            }
            
            if(objContactFetched.FirstName == null) {
                
                strMessageToDisplay =  'First Name is mandatory for creating user record. Please enter the value for the same by going back to the contact record. ';
                strMessageToDisplay +=  'Note: To go back please click on "Back to Contact" button';
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, strMessageToDisplay));
                
                return;
            }
        
            /* Used to restore the login date if the user clicks on the button again going back */
            //Exchange new access token.    
            if(string.isBlank(strExchangedAccessToken)) {
                
                strExchangedAccessToken = exchangeAccessTokenForRefreshToken();
            }
            
            String strEmailBasedOnAccountName = '';
            
            strEmailBasedOnAccountName = performEmailTrimmingBasedOnAccountName(objContactFetched);
            
            if(!string.isBlank(strEmailBasedOnAccountName)) {
                
                strInputPrimaryEmailFromUI = (strEmailBasedOnAccountName).toLowerCase();    
                
                displayInputEmailSection = true;
            }
            else
            {
            
                strMessageToDisplay =  'The Email Field needs to have an email value. Please enter the value and proceed.';
            
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, strMessageToDisplay));
            
                return; 
            }
            if(!string.isBlank(objContactFetched.FirstName)) {
                /*if(!string.isBlank(strEmailBasedOnAccountName) && !string.isBlank(fetchCreatedUser(strEmailBasedOnAccountName, strExchangedAccessToken))) {
                    
                    displayDisableButton = true;
                    displayCreateUserButton = false;
                    displayInputEmailSection = false;
                    strUserEmailAddress = (strEmailBasedOnAccountName).toLowerCase();
                    strUserLastLoginDate = fetchCreatedUser(strEmailBasedOnAccountName, strExchangedAccessToken);
                } 
                else*/ 
                if(!string.isBlank(objContactFetched.Email) && !string.isBlank(fetchCreatedUser(objContactFetched.Email, strExchangedAccessToken))) {
                    displayDisableButton = true;
                    displayCreateUserButton = false;
                    displayInputEmailSection = false;
                    strUserEmailAddress = (objContactFetched.Email).toLowerCase();
                    strUserLastLoginDate = fetchCreatedUser(objContactFetched.Email, strExchangedAccessToken);
                }
            }
            
            if(string.isBlank(strUserPrimaryEmail) && !string.isBlank(String.valueOf(objContactFetched.Email)) && !string.isBlank(String.valueOf(objContactFetched.Other_Email__c))) {
                
                strUserPrimaryEmail = String.valueOf(objContactFetched.Email);
            }
            
            strContactFullName = objContactFetched.Name;
        }

        //For Community user access the contact record
        if(!string.isBlank(strContactId)) {
            fetchCurrentContactUser();
        }
        fetchPermisstionSet();
        /*set<string> duplicateIdSet = new set<string>();
        if(communityUser != null && communityUser.Id != null){
            for(PermissionSetAssignment option : [SELECT Id, PermissionSetId, PermissionSet.name , PermissionSet.label, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId =: communityUser.Id AND PermissionSet.name like 'Community%']){ 
                userPermisstionSet.Add(New SelectOption(option.PermissionSetId,option.PermissionSet.label));
                duplicateIdSet.add(option.PermissionSetId);     
            }
            for(PermissionSet option : [SELECT Id, ProfileId, Name, Label FROM PermissionSet WHERE name like 'Community%']){ 
                if(!duplicateIdSet.contains(option.id)){
                    allPermisstionSet.Add(New SelectOption(option.id,option.Label)); 
                }    
            }
        }*/
    } 
    
    
    public PageReference fetchPermisstionSet(){
        
        set<string> duplicateIdSet = new set<string>();
        List<SelectOption> userOldPermisstionSet = userPermisstionSet;
        userPermisstionSet = new List<SelectOption>();
        allPermisstionSet  = new List<SelectOption>();
        permissionSetNameSet = new Set<String>();
        if(communityUser != null && communityUser.Id != null){
            
            for(Default_Permission_Set__c defaultPermissionSet : [SELECT Profile_Name__c, Permission_Set_Name__c FROM Default_Permission_Set__c WHERE Profile_Name__c =: profileNameDefault]){
                permissionSetNameSet.add(defaultPermissionSet.Permission_Set_Name__c);
            }

            for(PermissionSetAssignment option : [SELECT Id, PermissionSetId, PermissionSet.name , PermissionSet.label, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId =: communityUser.Id AND (PermissionSet.label IN: permissionSetNameSet OR PermissionSet.name LIKE 'Community%')]){ 
                userPermisstionSet.Add(New SelectOption(option.PermissionSetId,option.PermissionSet.label));
                system.debug(option.PermissionSetId + ' ----Assigned--- '+ option.PermissionSet.label);
                duplicateIdSet.add(option.PermissionSetId);     
            }

            for(PermissionSet option : [SELECT Id, ProfileId, Name, Label FROM PermissionSet WHERE Label IN: permissionSetNameSet OR Name LIKE 'Community%']){ 
                if(!duplicateIdSet.contains(option.id)){
                    system.debug(option.Id + ' ----All Permission--- '+ option.label);
                    allPermisstionSet.Add(New SelectOption(option.id,option.Label)); 
                }    
            }
        }
        else{
            for(PermissionSet option : [SELECT Id, ProfileId, Name, Label FROM PermissionSet]){ 
                if(!duplicateIdSet.contains(option.id)){
                    system.debug(option.Id + ' ----All Permission--- '+ option.label);
                    allPermisstionSet.Add(New SelectOption(option.id,option.Label)); 
                }    
            }
        }
        return null;
        
    }
    
    public void fetchCurrentContactUser(){

        List<User> alreadyUser = [SELECT Id,AccountId,ProfileId,Profile.Name,FirstName,LastName,Account.Name,Name,ContactId,IsActive,Username,Email,LastLoginDate FROM user WHERE ContactId =: strContactId];
        
        String strEmailBasedOnAccountName = '';
        
        //If User is already created for this contact then hide the new user section and show user active/deactive section  
        if(alreadyUser != null && alreadyUser.size() > 0){
            displayNewUserSection = false;
            isUserActive = alreadyUser[0].IsActive;
            communityUser = alreadyUser[0];

            if(alreadyUser[0].ProfileId != null){
                profileNameDefault = alreadyUser[0].Profile.Name;
            }
            
            Contact objContactFetched = [SELECT Id, AccountId, Account.Name, Email, FirstName, LastName, Name, Other_Email__c FROM Contact WHERE Id = :alreadyUser[0].ContactId];
            
            strEmailBasedOnAccountName = performEmailTrimmingBasedOnAccountName(objContactFetched);
        }
        else{
            displayNewUserSection = true;
            communityUser = new User();
            String userName;
            
            
            Contact objContactFetched = [SELECT Id, AccountId, Account.Name, Email, FirstName, LastName, Name, Other_Email__c FROM Contact WHERE Id = :strContactId];
            
            strEmailBasedOnAccountName = performEmailTrimmingBasedOnAccountName(objContactFetched);
            
            if(objContactFetched.FirstName != null && objContactFetched.FirstName != ''){
                String firstInitial = (objContactFetched.FirstName).length() >= 1 ? (objContactFetched.FirstName).substring(0,1) : (objContactFetched.FirstName).substring(0,(objContactFetched.FirstName).length());
                userName = firstInitial + objContactFetched.LastName + '@10kview.com';
                userName = userName.replace(' ','');
                List<User> userNameExist = [SELECT Id,Name,ContactId,IsActive,Username,Email,LastLoginDate FROM user WHERE Username=: userName];
                if(userNameExist != null && userNameExist.size() > 0){
                    firstInitial = (objContactFetched.FirstName).length() >= 2 ? (objContactFetched.FirstName).substring(0,2) : (objContactFetched.FirstName).substring(0,(objContactFetched.FirstName).length());
                    userName = firstInitial + objContactFetched.LastName + '@10kview.com';
                    userName = userName.replace(' ','');
                }

                //Check if user already exist with this username
                List<User> alreadyUser2 = [SELECT Id,Username FROM User WHERE Username =: userName];

                if(alreadyUser2 != null && alreadyUser2.size() > 0)
                    userName = (objContactFetched.FirstName == null ? '' : objContactFetched.FirstName) + objContactFetched.LastName + '@10kview.com';
            }
            else{
                userName = (objContactFetched.FirstName == null ? '' : objContactFetched.FirstName) + objContactFetched.LastName + '@10kview.com';
            }

            userName = userName.replace(' ','');

            //Prefill the user's fields
            communityUser.FirstName = objContactFetched.FirstName;
            communityUser.LastName = objContactFetched.LastName;
            communityUser.LocaleSidKey = 'en_US';
            communityUser.TimeZoneSidKey = 'America/New_York';
            if(objContactFetched.Email != null){
                communityUser.Email = (objContactFetched.Email).toLowerCase();
            }
            if(userName != null){
                communityUser.Username = userName.toLowerCase();
            }
            communityUser.contactId = strContactId;

            userTypes = new List<SelectOption>();
            userTypes.add(new SelectOption('Delivery Expert','Delivery Expert'));
            userTypes.add(new SelectOption('Services Client','Services Client'));
            userTypes.add(new SelectOption('Product Client','Product Client'));
            userTypes.add(new SelectOption('Services & Product Client','Services & Product Client'));

            roleLevels = new List<SelectOption>();
            roleLevels.add(new SelectOption('Manager','Manager'));
            roleLevels.add(new SelectOption('User','User'));

            selectedUserType = '';
            selectedLoginType = '';
            selectedRoleLevel = 'User';
        }
    }

    //Fetch the login types according to selected user types
    /*public List<SelectOption> getLoginTypes(){
        List<SelectOption> loginTypes = new List<SelectOption>();
        if(selectedUserType != null && (selectedUserType == 'Services Client' || selectedUserType == 'Product Client')){
            loginTypes.add(new SelectOption('Dedicated License','Dedicated License'));
            loginTypes.add(new SelectOption('Login Pool','Login Pool'));
            isdisabled = false;
        }
        else if(selectedUserType != null && selectedUserType == 'Delivery Expert' || selectedUserType == 'Services & Product Client'){
            loginTypes.add(new SelectOption('Dedicated License','Dedicated License'));
            loginTypes.add(new SelectOption('Login Pool','Login Pool'));
            //selectedLoginType = 'Dedicated License';
            isdisabled = false;
        }
        else{
            isdisabled = true;
        }
        return loginTypes;
    }*/

    //Create the community user
    public void createCommunityUser(){
        
        
        if(selectedUserType == null || selectedUserType == '' || selectedRoleLevel == null || selectedRoleLevel == ''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'User Type and Role Level all are required'));
        }
        else{
            String profileName;

            //Fetch profiles
            if(selectedUserType == 'Services Client'){
                profileName = '10K Services Client (Login)';
            }
            else if(selectedUserType == 'Product Client'){
                profileName = '10K Product Client (Login)';
            }
            else if(selectedUserType == 'Delivery Expert'){
                profileName = '10K Delivery Partner (Login)';
            }
            else if(selectedUserType == 'Services & Product Client') {
                profileName = '10K Services and Product Client (Login)';
            }

            List<Profile> profile = [SELECT Id,Name FROM Profile WHERE Name =: profileName];
            profileNameDefault = profileName;
            if(profile != null && profile.size() > 0){
                communityUser.alias = (communityUser.FirstName == null ? '' : communityUser.FirstName.substring(0,1) + '' + (communityUser.LastName.length() < 4 ? communityUser.LastName : communityUser.LastName.substring(0,4))).toLowerCase();
                communityUser.profileid = profile[0].Id;
                communityUser.CommunityNickname = communityUser.FirstName == null ? '' : communityUser.FirstName+ ' ' + communityUser.LastName;
                communityUser.emailencodingkey = 'UTF-8';
                communityUser.languagelocalekey = 'en_US';
                Database.DMLOptions dlo = new Database.DMLOptions();
                dlo.EmailHeader.triggerUserEmail= true;
                Database.saveresult sr = Database.insert(communityUser,dlo);

                if(sr.isSuccess()){
                    isUserCreated = true;
                    updateUserRole(communityUser.Id, selectedRoleLevel);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,'User created successfully.'));
                    permissionSetNameSet = new Set<String>();
                    for(Default_Permission_Set__c defaultPermissionSet : [SELECT Profile_Name__c, Permission_Set_Name__c FROM Default_Permission_Set__c WHERE Profile_Name__c =: profileName]){
                        permissionSetNameSet.add(defaultPermissionSet.Permission_Set_Name__c);
                    }
                    permissionSets = '';
                    for(SelectOption option : allPermisstionSet){
                        if(permissionSetNameSet.contains(option.getLabel()))
                            permissionSets += option.getValue() + '`' ;
                    }
                    savePermission();
                    fetchPermisstionSet();
                    permissionSets = '';
                    
                    
                    
                    
                    
                    
                    
                    // Added by Akshat to update the Training Plan Assignment after User Creation Based on Training Plan Refrenece Object
                    
                    try{
                        assignmentAccessCheck();
                        
                        Id userCommunityId = communityUser.Id;
                        
                        if(LMSUtils.isValidLMSUser(userCommunityId)){
							Set<Id> trainingPlanIdSet = new Set<Id>();
	                    
		                    for(Default_Training_Plan__c defaultTrainingPlan : [SELECT Profile_Name__c, Training_Plan__c FROM Default_Training_Plan__c WHERE Profile_Name__c =: profileName]){
		                        trainingPlanIdSet.add(defaultTrainingPlan.Training_Plan__c); 
		                    }
		                    
	                    	System.debug('*** M trainingPlanIdSet: '+trainingPlanIdSet);
		                    System.debug('*********************communityUser***********************'+communityUser);
		                    
	                    	If(trainingPlanIdSet != null && trainingPlanIdSet.size() > 0){
	                            futureUpsertAssignments(userCommunityId,trainingPlanIdSet,null);
	                            LMSUtils.addSuccessMessage(System.Label.ALMS_Single_User_Assignment_Success);
	                        }
		                }
		                else{
		                    LMSUtils.addErrorMessage(System.Label.ALMS_User_Missing_Perms);
		                }
                    }
                    catch(Exception e){
                        System.debug(e.getLineNumber()+'------------e-----------------'+e);
                        
                        LMSUtils.logException(e,'TrainingPlanAssignment Error');
                        LMSUtils.addGenericUnknownErrorMessage('Provision User UI - TrainingPlanAssignment - assignUsers (1)');
                    }
                    
                }
                else{
                    isUserCreated = false;
                    for(Database.Error err : sr.getErrors()){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,err.getMessage())); 
                    }
                }

                //Refresh current contact user
                fetchCurrentContactUser();
            }
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'No matching profile found, please contact your admin.'));
            }

        }
        
    }
    
    // Future instance for Traning Plan Acces  record
    @Future
    public static void futureUpsertAssignments(Id userCommunityId,Set<Id> trainingPlanIdSet, Id CommunityId){
		LMSService.upsertAssignments(new Set<Id>{userCommunityId },trainingPlanIdSet,null);
    }
    
    //Update the community user (Activate or Deactivate)
    public void updateCommunityUser(){
        boolean userActivation = !isUserActive;
        communityUser.IsActive = userActivation;
        try{
            Update communityUser;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,'User updated successfully'));
            isUserActive = userActivation;
        }
        catch(DmlException ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
        }
        
        system.debug('----userActivation----' +userActivation);
        system.debug('----strContactId----' +strContactId);
        
        //If user is deactivated then close the related assisnments
        if(!userActivation){
            updateUserAssignment(strContactId);
        }
        //newMethod();
    }
    
    
    public PageReference  newMethod(){
        userPermisstionSet = new List<SelectOption>();
        allPermisstionSet  = new List<SelectOption>();      //.clear();
        fetchPermisstionSet();
        return null;
    }

    //Update the user assignments 
    @future
    public static void updateUserAssignment(String contactId){
        List<Assignment__c> assisnments = [SELECT Id,Resource__c,Status__c FROM Assignment__c WHERE Resource__c =: contactId];
        if(assisnments != null && assisnments.size() > 0){
            for(Assignment__c assign : assisnments){
                assign.Status__c = 'Closed';
            }
            update assisnments;
        }
    }

    //Update the user role
    @future
    public static void updateUserRole(String userId, String roleLevel){
        List<User> user = [SELECT Id,Name,UserRoleId,UserRole.Name,accountId FROM User WHERE Id =: userId];
        if(user != null && user.size() > 0){
            if(!(user[0].UserRole.Name).containsIgnoreCase(roleLevel)){

                List<UserRole> userRolesByAccount = [SELECT Id,Name,PortalAccountId FROM UserRole WHERE PortalAccountId =: user[0].accountId];
                for(UserRole role : userRolesByAccount){
                    if(user[0].UserRole.Name != role.Name && (role.Name).containsIgnoreCase(roleLevel)){
                        user[0].UserRoleId = role.Id;
                    }
                }
                update user[0];
            }
        }
    }

    
    public pagereference AuthorizeToGoogle()
    {
        if(objGoogleAuthSettingsCS != null) {   
            
            ///If refresh token is not available authorize to google
            if(string.isBlank(objGoogleAuthSettingsCS.Refresh_Token__c)) {
                
                if(!string.isBlank(objGoogleAuthSettingsCS.GoogleClientID__c)) {
                    
                    strSalesforceBaseUrl = URL.getSalesforceBaseUrl().toExternalForm();
                    PageReference objPageReference = new PageReference(getGoogleAuthorizationURI(objGoogleAuthSettingsCS.GoogleClientID__c, (UserInfo.getUiTheme() == 'Theme4d' ? '/apex/ProvisionCommunityUser' : strSalesforceBaseUrl + '/apex/ProvisionCommunityUser')));
                    return objPageReference;
                }
            } 
        }
        return null;
    }
    
    public String getGoogleAuthorizationURI(String strClientID, String strRedirectURI) { 
        
        String strClient_Id = EncodingUtil.urlEncode(strClientID, 'UTF-8'); 
        String strRedirect_URI = EncodingUtil.urlEncode(strRedirectURI, 'UTF-8');
        
        String strAuthenticationURI = 'https://accounts.google.com/o/oauth2/v2/auth?'+ 
                                       'client_id='+strClient_Id+  
                                       '&response_type=code'+  
                                       '&scope=https://www.googleapis.com/auth/admin.directory.user https://www.googleapis.com/auth/admin.datatransfer'+  
                                       '&redirect_uri='+strRedirect_URI+
                                       '&state='+strContactID+
                                       '&login_hint=jsmith@example.com'+
                                       '&prompt=consent'+
                                       '&access_type=offline';
                                       
        return strAuthenticationURI;  
    }
    
    
    public void SaveTokens() {
        
        if(string.isBlank(strAuthorizationCode)) {
            
            return;
        }
                    
        List<GoogleAuthSettings__c> lstGoogleAuthSettingsToUpdate = new List<GoogleAuthSettings__c>();
        
        Http http = new Http();     
        HttpRequest req = new HttpRequest();
        HttpResponse resp;
        
        String strEndPointValue = 'https://accounts.google.com/o/oauth2/token';
        strSalesforceBaseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        String strRedirect_URI;
        if(isLightningExperience)
            strRedirect_URI = strSalesforceBaseUrl + '/apex/ProvisionCommunityUser';
        else 
            strRedirect_URI = EncodingUtil.urlEncode(strSalesforceBaseUrl + '/apex/ProvisionCommunityUser', 'UTF-8');
        
        String strMessageBody = 'code='+strAuthorizationCode+
                                '&client_id='+strGoogleClientID+
                                '&client_secret='+strGoogleClientSecret+
                                '&redirect_uri='+strRedirect_URI+
                                '&grant_type=authorization_code'; 
                 
        req.setMethod('POST');
        req.setEndpoint(strEndPointValue);
        req.setHeader('content-type', 'application/x-www-form-urlencoded');
        req.setHeader('Content-length', String.valueOf(strMessageBody.length())); 
        req.setBody(strMessageBody);  
        req.setTimeout(60000);
        
        resp = http.send(req);
        system.debug('refresh token response'  + resp.getBody());
        Map<String, Object> root = (Map<String, Object>)JSON.deserializeUntyped(resp.getBody());    
                        
        if(objGoogleAuthSettingsCS != null) {
            
            GoogleAuthSettings__c objGoogleAuthSettings = objGoogleAuthSettingsCS;
            
            if(!string.isBlank(String.valueOf(root.get('access_token')))) {
                
                objGoogleAuthSettings.Access_Token__c = String.valueOf(root.get('access_token'));
            }
            
            if(!string.isBlank(String.valueOf(root.get('refresh_token')))) {
                
                objGoogleAuthSettings.Refresh_Token__c = String.valueOf(root.get('refresh_token'));
            }
            
            lstGoogleAuthSettingsToUpdate.add(objGoogleAuthSettings);
        }   
         
        if(!lstGoogleAuthSettingsToUpdate.isEmpty()) {
            
            update lstGoogleAuthSettingsToUpdate; 
            
            if(!string.isBlank(lstGoogleAuthSettingsToUpdate[0].Refresh_Token__c)) {
                
                displayCreateUserButton = true;
            }
        }
    }   
    
    
    public void createUser() {  
            
        if(ApexPages.currentPage().getParameters().get('Id') != null && ApexPages.currentPage().getParameters().get('Id') != '') {
        
            strContactId = ApexPages.currentPage().getParameters().get('Id');
        }
        else if(ApexPages.currentPage().getParameters().get('state') != null && ApexPages.currentPage().getParameters().get('state') != '') {
        
            strContactId = ApexPages.currentPage().getParameters().get('state');
        }
                
        string strContactPhone = '';
        string strEmailToWrap = '';
        
        if(string.isBlank(strContactId)) {
            
            strMessageToDisplay =  'Contact not selected';
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, strMessageToDisplay));
            
            return;
        }
            
        if(string.isBlank(strInputPrimaryEmailFromUI)) {
            
            strMessageToDisplay =  'The Email Field needs to have an email value. Please enter the value and proceed.';
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, strMessageToDisplay));
            
            return; 
        }
        
        Contact objContact = [SELECT Email, Other_Email__c, Temporary_Gmail_Password__c, Id, AccountId, Account.Name, LastName, FirstName, Phone FROM Contact WHERE Id = : strContactId];

        if(objContact.Email == null) {
            
            strMessageToDisplay =  'This Contact has no Email. Please add the contact current email address to the Email field, then try again. Note: To go back please click on "Back to Contact" button';
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, strMessageToDisplay));
            
            return;
        }
        
        if(objContact.FirstName == null) {
            
            strMessageToDisplay =  'First Name is mandatory for creating user record. Please enter the value for the same by going back to the contact record. ';
            strMessageToDisplay +=  'Note: To go back please click on "Back to Contact" button';
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, strMessageToDisplay));
            
            return;
        }
        
        if(string.isBlank(objContact.Phone)) {
            
            strContactPhone = '111-111-1111';
        }
        else
        {
            strContactPhone = objContact.Phone;
        }
        
        //Exchange new access token.    
        if(string.isBlank(strExchangedAccessToken)) {
            
            strExchangedAccessToken = exchangeAccessTokenForRefreshToken();
        }
        
        String strPassword = getPassword(8);
        
        system.debug('>>>>>>-------strGoogle10KDomain-----' +strGoogle10KDomain);
        
        if(!string.isBlank(strGoogle10KDomain)) {
            
            strEmailToWrap = strInputPrimaryEmailFromUI;
            
            wrapperUserMessageBody objFieldAssignmentWrapper = new wrapperUserMessageBody(new wrapperUserName(objContact.FirstName, objContact.LastName), strEmailToWrap, strPassword, false, new list<EmailsWrapper>{new EmailsWrapper(objContact.Email)}, new list<PhonesWrapper>{new PhonesWrapper(strContactPhone, 'mobile')},true); 
            
            string strFieldAssignmentWrapper = JSON.serialize(objFieldAssignmentWrapper);
            if(!string.isBlank(strFieldAssignmentWrapper)) {
                getCreateGoogleUser(strFieldAssignmentWrapper, strExchangedAccessToken, objContact.Email, strPassword, objContact.FirstName, objContact.LastName, objContact.Id, strEmailToWrap); 
            }
        }
    }
    
    private String exchangeAccessTokenForRefreshToken() {
        
        //Exchange new access token. 
        Http http = new Http();     
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        string strEndPointValue = 'https://accounts.google.com/o/oauth2/token';
        string strMessageBody = 'client_id='+strGoogleClientID+
                                '&client_secret='+strGoogleClientSecret+
                                '&refresh_token='+objGoogleAuthSettingsCS.Refresh_Token__c+
                                '&grant_type=refresh_token';
        httpReq.setMethod('POST');
        httpReq.setEndpoint(strEndPointValue);
        httpReq.setHeader('content-type', 'application/x-www-form-urlencoded');
        httpReq.setHeader('Content-length', String.valueOf(strMessageBody.length()));
        httpReq.setBody(strMessageBody);
        
        httpRes = httpRes = http.send(httpReq);
        Map<String, Object> root = (Map<String, Object>)JSON.deserializeUntyped(httpRes.getBody()); 
        
        return String.valueOf(root.get('access_token'));
    }
    
    private void getCreateGoogleUser(string strJSONUserMessageBody, String strNewAccessToken, String strContactEmail, String strPassword, String strContactFirstName, String strContactLastName, String strContactId, String strEmailToWrap) 
    { 
        String strExceptionBody = '';
        
        if(!string.isBlank(strJSONUserMessageBody) && !string.isBlank(strNewAccessToken)) {
            
            //This is for creating new user
            Http http = new Http();     
            HttpRequest httpReq = new HttpRequest();
            HttpResponse httpRes = new HttpResponse();
            
            String strEndPointValue = 'https://www.googleapis.com/admin/directory/v1/users';
            httpReq.setMethod('POST');
            httpReq.setHeader('content-type', 'application/json');
            httpReq.setHeader('Authorization','Bearer '+strNewAccessToken);
            httpReq.setHeader('key',strGoogleAPIKey);
            httpReq.setTimeout(120000);
            httpReq.setEndpoint(strEndPointValue);
            httpReq.setBody(strJSONUserMessageBody);
            httpRes = http.send(httpReq);
            
            system.debug('==============create user httpRes ' +httpRes.getBody() );
                        
            if(httpRes.getStatusCode() == 200) {
                                
                if(!string.isBlank(strContactEmail) && !string.isBlank(strPassword)  && !string.isBlank(strContactFirstName) && !string.isBlank(strContactLastName) && !string.isBlank(strContactId) && !string.isBlank(strGoogle10KDomain) && !string.isBlank(strEmailToWrap)) {
                    
                    strUserEmailAddress = (strEmailToWrap).toLowerCase();
                    strUserLastLoginDate = fetchCreatedUser(strEmailToWrap, strNewAccessToken);
                    
                    updateContactEmail(strContactId, strContactEmail, strPassword, strContactFirstName, strContactLastName, strEmailToWrap);
                    
                    notifyLoginCredentialsToUser(strContactEmail, strContactId);
                    
                    strMessageToDisplay = strContactFirstName+'\'s 10K Gmail account has been created, and they have been sent a notification.';
                    
                    displayCreateUserButton = false;
                    displayInputEmailSection = false;
                    
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, strMessageToDisplay));
                }
            }
            else 
            {
                if(String.valueOf(httpRes.getStatus()) == 'Conflict') {
                    
                    strMessageToDisplay =  'User record didnot get created. There is already an email address registered for ' +strContactFirstName.trim().substring(0,1)+strContactLastName.replaceAll('\\s+', '')+'@'+strGoogle10KDomain+'. Click "Back to Contact" button to return back to the contact record';
                    
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, strMessageToDisplay));
                }
                else
                {
                    strExceptionBody = String.valueOf(httpRes.getBody());
                    
                    if(!string.isBlank(strExceptionBody) && strExceptionBody.contains('Invalid') && strExceptionBody.contains('Input') && strExceptionBody.contains('primary_user_email')) {
                        
                        strMessageToDisplay = 'User record didnot get created. Reason: Please enter valid value in the email field';
                    }
                    else
                    {
                        strMessageToDisplay =  'User record didnot get created. Reason: '+String.valueOf(httpRes.getStatus());
                    }
                    
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, strMessageToDisplay));
                }
            }
        }   
    }
    
    private static String getPassword(Integer length) {
        
        Blob blobKey = crypto.generateAesKey(192);
        String strPassKey = EncodingUtil.base64encode(blobKey);
        return strPassKey.substring(0, length);
    }
    
    private void notifyLoginCredentialsToUser(String strEmail, String strContactId) {
        
        EmailTemplate objEmailTemplate = [SELECT Id, DeveloperName, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'Alert_User_s_secondary_email_on_google_user_account_creation'];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        List<String> sendTo = new List<String>();       
        sendTo.add(strEmail);
        mail.setToAddresses(sendTo);
        mail.setBccSender(false);
        mail.setTemplateID(objEmailTemplate.Id);
        mail.setUseSignature(false);
        mail.setSenderDisplayName('gsuite-noreply@google.com');
        mail.setTargetObjectId(Id.valueOf(strContactId)); 
        mail.setTreatTargetObjectAsRecipient(false);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });     
    }
    
    private void updateContactEmail(String strContactID, String strContactEmail, String strPassword, String strContactFirstName, String strContactLastName, String strEmailToWrap) {
        
        if(!string.isBlank(strGoogle10KDomain)) {
            
            objContact = new Contact(Id = Id.valueOf(strContactID), Other_Email__c = strContactEmail, Email = strEmailToWrap, Temporary_Gmail_Password__c = strPassword);
            update objContact;
        }
        strUserPrimaryEmail = objContact.Email;
        fetchCurrentContactUser();

        if(objContact.Other_Email__c != null) {
            
            displayDisableButton = true;
            displayCreateUserButton = false;
            displayInputEmailSection = false;
        }   
    }
    
    private String fetchCreatedUser(String strUserPrimaryEmail, String strNewAccessToken) {
    
        String strLastLoginDate = '';
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse resp;
                    
        req.setMethod('GET');
        req.setEndpoint('https://www.googleapis.com/admin/directory/v1/users/'+strUserPrimaryEmail);
        req.setHeader('content-type', 'text/plain');
        req.setHeader('Authorization','Bearer '+strNewAccessToken);
        req.setTimeout(60000);
        
        resp = http.send(req);           
        Map<String, Object> root = (Map<String, Object>)JSON.deserializeUntyped(resp.getBody());   
        system.debug('=======================respgetBody=============================='+resp.getBody());
        if(!root.keySet().isEmpty()) {
            if(!string.isBlank(String.valueOf(root.get('suspended')))) {
                if(root.get('suspended') == true) {
                    displayEnableButton = true;
                    displayDisableButton = false;
                }
                else
                {
                    displayEnableButton = false;
                    displayDisableButton = true;
                }
            }
            if(!string.isBlank(String.valueOf(root.get('id')))) {
                currentGoogleOwnerId = String.valueOf(root.get('id'));
            }
            if(!string.isBlank(String.valueOf(root.get('lastLoginTime')))) {
                
                if(String.valueOf(root.get('lastLoginTime')).contains('true')) {
                    
                    strLastLoginDate = 'Never';
                }
                else
                {
                    strLastLoginDate = String.valueOf(root.get('lastLoginTime'));
                }
            }
            return strLastLoginDate;
        }
        return null;
    }
    
    
    private String performEmailTrimmingBasedOnAccountName(Contact objContact) {
        
        String strEmailBasedOnAccountName = '';
        
        if(String.valueOf(objContact.Account.Name).contains('10K Advisors')) {
                
            strEmailBasedOnAccountName = objContact.FirstName+'@'+strGoogle10KDomain;   
        }
        else {
            
            strEmailBasedOnAccountName = objContact.FirstName.trim().substring(0,1)+objContact.LastName.replaceAll('\\s+', '')+'@'+strGoogle10KDomain;      
        }
            
        return strEmailBasedOnAccountName;
    }
    
    public void suspendUser() {
        
        if(string.isBlank(strExchangedAccessToken)) {
            
            strExchangedAccessToken = exchangeAccessTokenForRefreshToken();
        }
        
        if(!string.isBlank(strExchangedAccessToken)) {
            
            wrapperUpdateUserMessageBody objFieldAssignmentWrapper = new wrapperUpdateUserMessageBody(true);
            
            string strFieldAssignmentWrapper = JSON.serialize(objFieldAssignmentWrapper);
        
            if(!string.isBlank(strFieldAssignmentWrapper)) {
            
                //This is for updating created user
                Http http = new Http();     
                HttpRequest httpReq = new HttpRequest();
                HttpResponse httpRes = new HttpResponse();
                
                String strEndPointValue = 'https://www.googleapis.com/admin/directory/v1/users/'+strUserPrimaryEmail;
                httpReq.setMethod('PUT');
                httpReq.setHeader('content-type', 'application/json');
                httpReq.setHeader('Authorization','Bearer '+strExchangedAccessToken);
                httpReq.setTimeout(120000);
                httpReq.setEndpoint(strEndPointValue);
                httpReq.setBody(strFieldAssignmentWrapper);
                
                httpRes = http.send(httpReq);
                             
                if(httpRes.getStatusCode() == 200) {
                    
                    displayEnableButton = true;
                    displayDisableButton = false;
                    strMessageToDisplay =  strContactFullName+'\'s 10K Gmail account has been successfully disabled.';
                    
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, strMessageToDisplay));
                }
            }
        }
    }
     
    public void unSuspendUser() {
        
        if(string.isBlank(strExchangedAccessToken)) {
            
            strExchangedAccessToken = exchangeAccessTokenForRefreshToken();
        }
        
        if(!string.isBlank(strExchangedAccessToken)) {
            
            wrapperUpdateUserMessageBody objFieldAssignmentWrapper = new wrapperUpdateUserMessageBody(false);
            
            string strFieldAssignmentWrapper = JSON.serialize(objFieldAssignmentWrapper);
        
            
            if(!string.isBlank(strFieldAssignmentWrapper)) {
            
                //This is for updating created user
                Http http = new Http();     
                HttpRequest httpReq = new HttpRequest();
                HttpResponse httpRes = new HttpResponse();
                
                String strEndPointValue = 'https://www.googleapis.com/admin/directory/v1/users/'+strUserPrimaryEmail;
                httpReq.setMethod('PUT');
                httpReq.setHeader('content-type', 'application/json');
                httpReq.setHeader('Authorization','Bearer '+strExchangedAccessToken);
                httpReq.setTimeout(120000);
                httpReq.setEndpoint(strEndPointValue);
                httpReq.setBody(strFieldAssignmentWrapper);
                
                httpRes = http.send(httpReq);
                
                if(httpRes.getStatusCode() == 200) {
                    
                    displayEnableButton = false;
                    displayDisableButton = true;
                    strMessageToDisplay =  strContactFullName+'\'s 10K Gmail account has been successfully re-enabled.';
                    
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, strMessageToDisplay));
                }
            }
        }
    }

    public void savePermission(){
        list<PermissionSetAssignment> permisionForDeletion = new list<PermissionSetAssignment>();
        list<PermissionSetAssignment> permisionForInsert = new list<PermissionSetAssignment>();
        try{
            map<string,PermissionSetAssignment> oldAssignedMap = new map<string,PermissionSetAssignment>();
            list<PermissionSetAssignment> alreadyAssignedPermissionsList = [SELECT Id, PermissionSetId, PermissionSet.name , PermissionSet.label, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId =: communityUser.Id AND (PermissionSet.label IN: permissionSetNameSet OR PermissionSet.name LIKE 'Community%')];
            for(PermissionSetAssignment OldAssignments : alreadyAssignedPermissionsList){
                oldAssignedMap.put(OldAssignments.PermissionSetId, OldAssignments);
            }
            set<string> selectIds = new set<string>();
            if(permissionSets != null && permissionSets != '' && permissionSets.indexOf('`') != -1){
                selectIds.addAll(permissionSets.split('`'));
            }
            
            for(string permisionId : oldAssignedMap.keySet()){
                if(!selectIds.contains(permisionId)){
                    permisionForDeletion.add(oldAssignedMap.get(permisionId));
                }
            }
            delete permisionForDeletion;
            for(string permisionId : selectIds){
                if(!oldAssignedMap.containsKey(permisionId)){
                    PermissionSetAssignment assignePer = new PermissionSetAssignment();
                    assignePer.PermissionSetid = permisionId;
                    assignePer.AssigneeId = communityUser.Id;
                    permisionForInsert.add(assignePer);
                }
            }
            if(permisionForInsert != null && permisionForInsert.size() > 0){
                insert permisionForInsert;
            }
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,ex.getMessage()));
        }
        if(permisionForDeletion.size() > 0 || permisionForInsert.size() > 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,'User Permissions updated successfully'));
            fetchPermisstionSet();
        }
        
    }
    
    public void performCancel() {}
    
    public class wrapperUserMessageBody {
        
        public wrapperUserName name;
        public String primaryEmail;
        public String password;
        public Boolean suspended;
        public list<EmailsWrapper> emails;
        public list<PhonesWrapper> phones;
        public Boolean changePasswordAtNextLogin; //added by Hemant
        
        public wrapperUserMessageBody(wrapperUserName objwrapperUserName, String strUserEmail, String strPassword, Boolean boolSuspended, list<EmailsWrapper> lstEmailWrappers, list<PhonesWrapper> lstPhoneWrappers, Boolean changePasswordAtNextLogin) {
            
            this.name = objwrapperUserName;
            this.primaryEmail = strUserEmail;
            this.password = strPassword;
            this.suspended = boolSuspended;
            this.emails = lstEmailWrappers;
            this.phones = lstPhoneWrappers;
            this.changePasswordAtNextLogin = changePasswordAtNextLogin;
        }
    }
    
    public class wrapperUserName {
        
        public String givenName;
        public String familyName;
        
        public wrapperUserName(String strFirstName, String strLastName) {
            
            this.givenName = strFirstName;
            this.familyName = strLastName;
        }
    }
    
    public class EmailsWrapper {
        
        public String address;
        public boolean primary;
        public String type;
        public String customType;
        
        public EmailsWrapper(String address) {  
            
            this.address = address;
            this.primary = false;
            this.type = 'custom';
            this.customType = '';
        }
    }
    
    public class PhonesWrapper {
        
        public String value;
        public String type;
        
        public PhonesWrapper(String value, String type) { 
            
            this.value = value;
            this.type = type;
        }
    }
    
    public class wrapperUpdateUserMessageBody {
        
        public Boolean suspended;
        
        public wrapperUpdateUserMessageBody(Boolean boolSuspended) {
            
            this.suspended = boolSuspended;
        }
    }
    
    // Added by Akshat to retrieve all Custom Metadata Value to Trnasfer Records
    public List<SelectOption> getgoogleUsersCMT(){
        List<SelectOption> googleUsersCMT = new List<SelectOption>();
        for (Google_Provision_User__mdt googleUserCMT : [SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, Email__c FROM Google_Provision_User__mdt Where Email__c != : strUserPrimaryEmail ]){
            googleUsersCMT.add(new SelectOption(googleUserCMT.Email__c,googleUserCMT.MasterLabel)); 
        }
        
        return googleUsersCMT;
    }
    public void doDataTransferDeleteUser(){
        system.debug('================------selectedGoogleUsersCMT----======================'+selectedGoogleUsersCMT);
        if(string.isBlank(strExchangedAccessToken)) {
            strExchangedAccessToken = exchangeAccessTokenForRefreshToken();
        }
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse resp;
                    
        req.setMethod('GET');
        req.setEndpoint('https://www.googleapis.com/admin/directory/v1/users/'+selectedGoogleUsersCMT);
        req.setHeader('content-type', 'text/plain');
        req.setHeader('Authorization','Bearer '+strExchangedAccessToken);
        req.setTimeout(60000);
        
        resp = http.send(req); 
        
        if(resp.getStatusCode() == 200) {
            String newGoogleOwnerId ;         
            String customerId;         
            Map<String, Object> root = (Map<String, Object>)JSON.deserializeUntyped(resp.getBody());
            if(!string.isBlank(String.valueOf(root.get('id')))) {
                newGoogleOwnerId = String.valueOf(root.get('id'));
            }
            
            if(!string.isBlank(String.valueOf(root.get('customerId')))) {
                customerId = String.valueOf(root.get('customerId'));
            }
            
            // get the list of application which we need to transfer
            List<String> trfAppIds = doGetApplicationsList(customerId );
            
            //Transfer the owner to new User for existing applications
            If(trfAppIds != null){
                doApplicationTransfer(newGoogleOwnerId,currentGoogleOwnerId,trfAppIds);
            }
            doDeleteGoogleUser(currentGoogleOwnerId);
        }
        else{
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'No matching User found, please select another User or contact your admin.'));
        }
        // getListOfTransferAPICall(newGoogleOwnerId,currentGoogleOwnerId,customerId );
    }
    
    public List<String> doGetApplicationsList(String customerId ){
        if(string.isBlank(strExchangedAccessToken)) {
            strExchangedAccessToken = exchangeAccessTokenForRefreshToken();
        }
        List<String> trfAppIds = new List<String>(); 
        
        Http httpTransfers  = new Http();
        HttpRequest reqHttpTransfers = new HttpRequest();
        HttpResponse respHttpTransfers  ;
        
        string applicationMessageBody = 'customerId='+customerId;
                                
        reqHttpTransfers.setMethod('GET');
        reqHttpTransfers.setEndpoint('https://www.googleapis.com/admin/datatransfer/v1/applications?'+applicationMessageBody);
        reqHttpTransfers.setHeader('Authorization','Bearer '+strExchangedAccessToken);
        reqHttpTransfers.setTimeout(60000);
        respHttpTransfers = httpTransfers.send(reqHttpTransfers);   
        
        if(respHttpTransfers.getStatusCode() == 200) {
            ApplicationsTransferResponse applicationsTransferRes = (ApplicationsTransferResponse) System.JSON.deserialize(respHttpTransfers.getBody(), ApplicationsTransferResponse.class);
            for(ApplicationsResponse apps : applicationsTransferRes.Applications){
                trfAppIds.add(apps.Id);
            }
            return trfAppIds;
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Getting Issues in fetching applications via Customer Id, please contact your admin.'));
        }
        return null;
    }
    
    public void doApplicationTransfer(string newGoogleOwnerId,String currentGoogleOwnerId,List<String> trfAppIds){
        if(string.isBlank(strExchangedAccessToken)) {
            strExchangedAccessToken = exchangeAccessTokenForRefreshToken();
        }
        
        List<ApplicationDataTransfers> tempAppDataWrapperList = new List<ApplicationDataTransfers>();
        
        for(String appId : trfAppIds){
            tempAppDataWrapperList.add(new ApplicationDataTransfers(appId,new list<ApplicationTransferParams>{new ApplicationTransferParams()}));
        }
        
        WrapperTransferBody transferAssignmentWrapper = new WrapperTransferBody( newGoogleOwnerId, currentGoogleOwnerId, tempAppDataWrapperList);
        String transferAssignmentWrapJSON = JSON.serialize(transferAssignmentWrapper);
        
        Http httpAppsTransfer = new Http();
        HttpRequest reqHttpAppsTransfer = new HttpRequest();
        HttpResponse respHttpAppsTransfer;
        
        reqHttpAppsTransfer.setMethod('POST');
        reqHttpAppsTransfer.setEndpoint('https://www.googleapis.com/admin/datatransfer/v1/transfers');
        reqHttpAppsTransfer.setHeader('Authorization','Bearer '+strExchangedAccessToken);
        reqHttpAppsTransfer.setHeader('content-type', 'application/json');
        reqHttpAppsTransfer.setTimeout(120000);
        reqHttpAppsTransfer.setBody(transferAssignmentWrapJSON);
        respHttpAppsTransfer = httpAppsTransfer.send(reqHttpAppsTransfer);
        
        If(respHttpAppsTransfer.getStatusCode() != 200){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, strContactFullName+ ' getting Issues When Transfering the applications, please contact your admin'));
        }
    }
    
    public void doDeleteGoogleUser(String currentGoogleOwnerId){
        
        Http httpDeleteUser = new Http();
        HttpRequest reqHttpDeleteUser = new HttpRequest();
        HttpResponse respHttpDeleteUser;
        
        reqHttpDeleteUser.setMethod('DELETE');
        reqHttpDeleteUser.setEndpoint('https://www.googleapis.com/admin/directory/v1/users/'+currentGoogleOwnerId);
        reqHttpDeleteUser.setHeader('Authorization','Bearer '+strExchangedAccessToken);
        reqHttpDeleteUser.setTimeout(120000);
        respHttpDeleteUser = httpDeleteUser.send(reqHttpDeleteUser);
        
        If(respHttpDeleteUser.getStatusCode() == 204){
            displayCreateUserButton = true;
            displayInputEmailSection = true;
            
            Contact objUpdateContact = [SELECT Email, Other_Email__c, Temporary_Gmail_Password__c, Id, AccountId, Account.Name, LastName, FirstName, Phone FROM Contact WHERE Id = : strContactId];
            objUpdateContact.Email = objUpdateContact .Other_Email__c;
            objUpdateContact.Other_Email__c = '';
            update objUpdateContact;
            
             strMessageToDisplay =  strContactFullName+'\'s 10K Gmail account has been successfully deleted.';
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, strMessageToDisplay));
        }
        Else{
            strMessageToDisplay =  strContactFullName+'\'s 10K Gmail account has been getting some issue.';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, strMessageToDisplay));
        }
    }
    
    public class ApplicationsTransferResponse {
        public String kind;
        public String etag;
        public List<ApplicationsResponse> applications;
    }
    public class ApplicationsResponse {
        public String kind;
        public String etag;
        public String id;
        public String name;
        public List<TransferParams> transferParams;
    }
    
    public class TransferParams {
        public String key;
        public List<String> value;
    }
    
    public class WrapperTransferBody {
        public String newOwnerUserId;
        public String oldOwnerUserId;
        public List<ApplicationDataTransfers> applicationDataTransfers;
        
        public WrapperTransferBody(String newOwnerUserId,String oldOwnerUserId,List<ApplicationDataTransfers> applicationDataTransfers){
            this.newOwnerUserId = newOwnerUserId;
            this.oldOwnerUserId = oldOwnerUserId;
            this.applicationDataTransfers = applicationDataTransfers;
        }    
    }
    
    public class ApplicationDataTransfers {
        public String applicationId;
        public List<ApplicationTransferParams> applicationTransferParams;
        
        public ApplicationDataTransfers(String applicationId,List<ApplicationTransferParams> applicationTransferParams){
            this.applicationId = applicationId;
            this.applicationTransferParams = applicationTransferParams;
        }    
    }
    
    public class ApplicationTransferParams {
        public String key;
        public List<String> value;
        public ApplicationTransferParams(){
            this.key = 'PRIVACY_LEVEL';
            this.value = new List<String>{'PRIVATE','SHARED'};  
        }
    }
    
    // New Methods for Traning Plan Operations
    
    private void assignmentAccessCheck(){
        //BEGIN Access Check
        Map<Schema.sObjectType,List<String>> relatedFieldsObjects = new Map<Schema.sObjectType,List<String>>();
        relatedFieldsObjects.put(Learning_Assignment__c.sObjectType,new List<String>{
            'Learning__c'
            ,'Learning_Version__c'
            ,'Training_Plan__c'
            ,'Training_Plan_Section__c'
            ,'Training_Plan_Section_Item__c'
        });
        LMS_ESAPI.isAuthorizedToCreate(relatedFieldsObjects);
        LMS_ESAPI.isAuthorizedToUpdate(relatedFieldsObjects);
        //END Access Check
    }
}