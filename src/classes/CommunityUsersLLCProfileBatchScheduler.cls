global class CommunityUsersLLCProfileBatchScheduler implements Schedulable 
{
    global void execute(SchedulableContext sc) 
    {
        /* CommunityUsersLLCProfileBatch cullcpBatch = new CommunityUsersLLCProfileBatch();
        Database.executebatch(cullcpBatch); */
        
        doLicenseAssignment();
    }
    
    global void doLicenseAssignment(){
        Integer count = 0;
        Set<Id> hundredTopUserIds = new Set<Id>();
        User_License_Setting__mdt userLicenseSetting = [SELECT ID, QualifiedApiName, License_Count__c  FROM User_License_Setting__mdt WHERE QualifiedApiName = 'Customer_Community_Plus' LIMIT 1];
        List<User> userListToBeUpdated  = new List<User>();        
        List<User> userListToBeUpdatedToLicence    = new List<User>();
        List<User> userListToBeUpdatedToLogin      = new List<User>();
        
        String query = 'SELECT Id, ProfileId, Profile.Name FROM User WHERE IsActive = TRUE AND ';
        
        Set<String> communityProfileNameSet = new Set<String>();
        Set<String> licenseProfileNameSet = new Set<String>();
        for(Profile_Names__c profileName : Profile_Names__c.getAll().values())
        {
            communityProfileNameSet.add(profileName.License_Profile_Name__c);
            communityProfileNameSet.add(profileName.Login_Profile_Name__c);
            licenseProfileNameSet.add(profileName.License_Profile_Name__c);
        }
        
        if(Test.isRunningTest())
        {
            query += 'Profile.Name IN: licenseProfileNameSet LIMIT 100';
        }
        else
        {
            query += 'Profile.Name IN: communityProfileNameSet';
        }
        
        List<User> activeCommunityUserList = Database.query(query);
        
        Map<String,String> profileNameMap = new Map<String,String>();
        for(Profile_Names__c profileName : Profile_Names__c.getAll().values())
        {
            profileNameMap.put(profileName.Login_Profile_Name__c,profileName.License_Profile_Name__c);
            profileNameMap.put(profileName.License_Profile_Name__c,profileName.Login_Profile_Name__c);
        }
        Map<String,Id> profileNameAndIdMap = new Map<String,Id>();
        Map<Id,User> activeCommunityUserMap = new Map<Id,User>(activeCommunityUserList);
        List<Profile> communityProfileList  = [SELECT Id, Name 
                                                FROM Profile 
                                                WHERE Name IN : profileNameMap.keySet() 
                                                ORDER BY Name];
        for(Profile pr : communityProfileList)
        {
            if(!profileNameAndIdMap.containsKey(pr.Name)) 
                profileNameAndIdMap.put(pr.Name,pr.Id);
        }
        
        List<AggregateResult> loginHistoryList = [SELECT UserId, Count(LoginTime) 
                                                    FROM LoginHistory 
                                                    WHERE LoginTime = LAST_N_DAYS:30 
                                                    AND UserId IN : activeCommunityUserList
                                                    GROUP BY UserId 
                                                    ORDER BY Count(LoginTime) DESC LIMIT : Integer.ValueOf(userLicenseSetting.License_Count__c) ];
        
        System.debug('----loginHistorySize -------'+loginHistoryList.size()+'---loginHistoryList ----'+loginHistoryList );
                                                    
        for(AggregateResult ar : loginHistoryList)
        
        {
            userListToBeUpdated.add(activeCommunityUserMap.get((String)(ar.get('UserId'))));
            hundredTopUserIds.add((String)ar.get('UserId'));
        }
        
        for(User userRec : activeCommunityUserList)
        {
            if(!hundredTopUserIds.contains(userRec.Id))
            {
                userListToBeUpdated.add(userRec);
            }
        }
        
        if(!userListToBeUpdated.isEmpty())
        {
            for(User usr : userListToBeUpdated)
            {
                if(count < userLicenseSetting.License_Count__c && (usr.Profile.Name).contains('Login') && profileNameMap.containsKey(usr.Profile.Name) && profileNameAndIdMap.containsKey(profileNameMap.get(usr.Profile.Name))) 
                {
                    usr.ProfileId = profileNameAndIdMap.get(profileNameMap.get(usr.Profile.Name));
                    userListToBeUpdatedToLicence.add(usr);
                }
                else if(count >= userLicenseSetting.License_Count__c && (usr.Profile.Name).contains('License') && profileNameMap.containsKey(usr.Profile.Name) && profileNameAndIdMap.containsKey(profileNameMap.get(usr.Profile.Name))) 
                {
                    usr.ProfileId = profileNameAndIdMap.get(profileNameMap.get(usr.Profile.Name));
                    userListToBeUpdatedToLogin.add(usr);
                }
                count++;
            }
        }
        System.debug('----userListToBeUpdated-------'+userListToBeUpdated.size()+'----userListToBeUpdatedToLogin-------'+userListToBeUpdatedToLogin.size()+'----userListToBeUpdatedToLicence---------'+userListToBeUpdatedToLicence.size());
        if(!userListToBeUpdatedToLogin.isEmpty()){
            update userListToBeUpdatedToLogin;
        }
        if(!userListToBeUpdatedToLicence.isEmpty()){
            update userListToBeUpdatedToLicence;
        }
    }
}