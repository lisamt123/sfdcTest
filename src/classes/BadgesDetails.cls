public without sharing class BadgesDetails{
   
    
    @AuraEnabled
    public static List<BadgesWrapp> getAchivements(String profileUserId)
    {
        string userId = profileUserId;
        List<BadgesWrapp> trailWrapperList = new List<BadgesWrapp>();
        //userId = '005R00000025J9k';
        List<User> userDetail = [SELECT Id,Name,ContactId FROM User WHERE Id =: userId];
        if(userDetail != null && userDetail.size() > 0 && userDetail[0].ContactId != null)
        {
            List<Expert_Achievement__c> expertAch = [Select Achievement__r.name, Achievement__r.Trailhead_Logo_Url__c,Achievement__r.Salesforce_Certification_Logo_URL__c From Expert_Achievement__c Where Contact__c =: userDetail[0].ContactId AND Achievement__r.recordType.Name = 'Trailhead Badge'];
            if(expertAch != null && expertAch.size() > 0)
            {
                trailWrapperList.add(new BadgesWrapp(expertAch));
                return trailWrapperList;
            }
        }
        return null; 
    }

    @AuraEnabled
    public static String validateCurrentUser(Id profileUserId)
    {
        if( profileUserId == UserInfo.getUserId())
            return 'true';
        else        
            return [SELECT Id,Name FROM User WHERE Id =: profileUserId].Name;
    }

    public class BadgesWrapp{
        @AuraEnabled
        public List<Expert_Achievement__c> trailBadges {get;set;}
        
        public BadgesWrapp(List<Expert_Achievement__c> trails){
            trailBadges = trails;
        }
    }
    @AuraEnabled
    public static List<CertificationWrapp> getCertifications(String profileUserId)
    {
        string userId = profileUserId;
        //userId = '005R00000025J9k';
        String[] sitePrefix = Site.getPathPrefix().split('/s');
        
        
        List<CertificationWrapp> certificationWrapperList = new List<CertificationWrapp>();
        List<User> userDetail = [SELECT Id,Name,ContactId FROM User WHERE Id =: userId];
        if(userDetail != null && userDetail.size() > 0 && userDetail[0].ContactId != null)
        {
            List<Expert_Achievement__c> expertAch = [Select Achievement__r.name, Achievement__r.Salesforce_Certification_Logo_URL__c From Expert_Achievement__c Where Contact__c =: userDetail[0].ContactId AND Achievement__r.recordType.Name = 'Salesforce Certification'];
            for(Expert_Achievement__c each :expertAch)
            {
                each.Achievement__r.Name = each.Achievement__r.Name.replace('Salesforce Certified ','');
            }
            if(expertAch != null && expertAch.size() > 0)
            {    
                
                certificationWrapperList.add(new CertificationWrapp(expertAch,sitePrefix[0] ));
                return certificationWrapperList;
            }
        }
        return null; 
    }
    @AuraEnabled
    public static List<ClimbBadgesWrapp> getClimbBadges(String profileUserId)
    {
        string userId = profileUserId;
        String[] sitePrefix = Site.getPathPrefix().split('/s');
        List<ClimbBadgesWrapp> climbBadgesWrapperList = new List<ClimbBadgesWrapp>();
        List<User> userDetail = [SELECT Id,Name,ContactId FROM User WHERE Id =: userId];
        if(userDetail != null && userDetail.size() > 0 && userDetail[0].ContactId != null)
        {
            List<Expert_Achievement__c> expertAch = [Select Achievement__r.Name, Achievement__r.Work_Badge_Image_URL__c From Expert_Achievement__c Where Contact__c =: userDetail[0].ContactId AND Achievement__r.recordType.Name = 'Climb Achievement'];
            if(expertAch != null && expertAch.size() > 0)
            {    
                
                climbBadgesWrapperList.add(new ClimbBadgesWrapp(expertAch,sitePrefix[0]));
                return climbBadgesWrapperList;
            }
        }
        return null; 
    }
    public class CertificationWrapp{
        @AuraEnabled
        public List<Expert_Achievement__c> certifications {get;set;}
        @AuraEnabled
        public String communityPrefix{get;set;}
        
        public CertificationWrapp(List<Expert_Achievement__c> certi, String pre){
            certifications = certi;
            communityPrefix = pre;
        }
    }
    public class ClimbBadgesWrapp{
        @AuraEnabled
        public List<Expert_Achievement__c> climbBadges {get;set;}
        @AuraEnabled
        public String communityPrefix{get;set;}

        public ClimbBadgesWrapp(List<Expert_Achievement__c> climb, String pre){
            climbBadges = climb;
            communityPrefix = pre;
        }
    }
    @AuraEnabled
    public static UserWrapp getUserDetails(String profileUserId)
    {
        //System.debug('-----RecordId from Page:'+profileUserId);
        string userId = profileUserId;
        //userId = '005R00000025J9k';
        UserWrapp wrap = new UserWrapp();
        User currentUser = [SELECT Id,Name,FullPhotoUrl,LastName, FirstName, MiddleName,City,PostalCode,Country,State,Manager.Name,Title,CompanyName,Phone,Email,MobilePhone,AboutMe,ContactId,profileid FROM User WHERE Id =: userId];
        List<Contact> contactsRecordList = [SELECT Id,Webassessor_Email__c,AccountId,Trailhead_User_Id__c,Skype_Id__c,Suffix FROM Contact WHERE Id =: currentUser.ContactId];
        List<NetworkMember> pointList = [select Id,ReputationPoints from NetworkMember where MemberId =: currentUser.Id];
        wrap.userInfo = currentUser;
        if(contactsRecordList.size() > 0)
            wrap.contactDetail = contactsRecordList[0];
        if(pointList.size() > 0)
            wrap.memberPoint = pointList[0].ReputationPoints == null ? 0 : pointList[0].ReputationPoints;
        for( ReputationLevel repLevel: [SELECT id,levelNumber,Threshold FROM  ReputationLevel])
        {
            if(wrap.memberPoint >= repLevel.Threshold )
            { 
                Integer level = repLevel.LevelNumber;
                if(level < 10 && level != 0)
                    wrap.levelURL = Site.getPathPrefix().split('/s')[0] + '/img/reputation/levelicons/reputation_level_0' + level + '.png';
                else if(level != 0)
                    wrap.levelURL = Site.getPathPrefix().split('/s')[0] + '/img/reputation/levelicons/reputation_level_' + level + '.png';
            }
        }
        if(currentUser.MobilePhone == null ){
            currentUser.MobilePhone = '';
        }
        if(currentUser.AboutMe == null ){
            currentUser.AboutMe = '';
        }
        if(currentUser.Title == null ){
            currentUser.Title = '';
        }
        if(currentUser.CompanyName == null ){
            currentUser.CompanyName = '';
        }
        if(currentUser.Phone == null ){
            currentUser.Phone = '';
        }
        if(currentUser.LastName == null ){
            currentUser.LastName  = '';
        }
        if(currentUser.FirstName == null ){
            currentUser.FirstName  = '';
        }
        if(currentUser.MiddleName == null ){
            currentUser.MiddleName = '';
        }
       
        
        if(currentUser.City == null ){
            wrap.userCity  = '';
        }
        else{
            wrap.userCity = (String)currentUser.City;
        }
        if(currentUser.PostalCode == null ){
            wrap.userZip = '';
        }
        else{
            wrap.userZip = (String)currentUser.PostalCode;
        }
        if(currentUser.Country == null ){
            wrap.userCountry = '';
        }
        else{
            wrap.userCountry = (String)currentUser.Country;
        }
        if(currentUser.State == null ){
            wrap.userState = '';
        }
        else{
            wrap.userState = (String)currentUser.State;
        }
        if(UserInfo.getUserId() == Id.valueOf(profileUserId)){
            wrap.isCurrentUser = true;
            wrap.isConnectedUser = true;
        }
        else {
            Set<String> contactIdSet = new Set<String>();
            Set<String> connectedUserIdSet = new Set<String>();
            String accountId = [SELECT Id,Contact.AccountId FROM User WHERE Id =: UserInfo.getUserId()].Contact.AccountId;
            system.debug('========='+accountId);
            for(Project__c project : [SELECT Id,Name, (SELECT Id,Resource__c FROM Assignments__r) FROM Project__c WHERE Account__c =: accountId ])
            {
                for(Assignment__c assignment : project.Assignments__r)
                {
                    contactIdSet.add(assignment.Resource__c);
                }
            }
            for(User selectedUser : [SELECT Id FROM User WHERE ContactId IN: contactIdSet])
            {
                connectedUserIdSet.add(selectedUser.id);
            }
            system.debug('============'+connectedUserIdSet);
            system.debug('============'+profileUserId);
            if(connectedUserIdSet.contains(Id.valueOf(profileUserId)))
                wrap.isConnectedUser = true;
            else 
                wrap.isConnectedUser = false;
            wrap.isCurrentUser = false;
        }
        String subscriberId = UserInfo.getUserId();
        List<EntitySubscription> entitySubscriptionList = [SELECT Id FROM EntitySubscription WHERE SubscriberId =: subscriberId AND ParentId =: userId];
        if(entitySubscriptionList.size() > 0)
        {
            wrap.isFollowing = true;
        }
        else
        {
            wrap.isFollowing = false;
        }
        return wrap ;
    }
    
    public class UserWrapp{
        @AuraEnabled
        public user userInfo{get;set;}
        @AuraEnabled
        public String userStreet {get;set;}
        @AuraEnabled
        public String userCity {get;set;}
        @AuraEnabled
        public String userState {get;set;}
        @AuraEnabled
        public String userZip {get;set;}
        @AuraEnabled
        public String userCountry {get;set;}
        @AuraEnabled
        public Contact contactDetail{get;set;}
        @AuraEnabled
        public Decimal memberPoint{get;set;}
        @AuraEnabled
        public String levelURL{get;set;}
        @AuraEnabled
        public Boolean isCurrentUser {get;set;}
        @AuraEnabled
        public Boolean isConnectedUser {get;set;}
        @AuraEnabled
        public Boolean isFollowing {get;set;}
    
    }
    @AuraEnabled
    public static UserWrapp saveUserDetails(String updatedList)
    {    
        UserWrapp jsonData = (UserWrapp)JSON.deserialize(updatedList,UserWrapp.class);
        Contact updatedCon = new Contact();
        updatedCon = jsonData.contactDetail;
        User updatedUser = new User();
        updatedUser = jsonData.userInfo;
        updatedUser.city = jsonData.userCity;
        updatedUser.Street = jsonData.userStreet;
        updatedUser.State = jsonData.userState;
        updatedUser.Country = jsonData.userCountry;
        updatedUser.PostalCode = jsonData.userZip;
        Update updatedCon;
        Update updatedUser;
        return jsonData;
    }
    @AuraEnabled
    public static UserWrapp  saveProfilePicture(String fileContent, Id profileUserId)
    {
        ConnectApi.Photo photo = ConnectApi.UserProfiles.setPhoto(null,UserInfo.getUserId(),new ConnectApi.BinaryInput((Blob)(EncodingUtil.base64Decode(fileContent)),'image/jpg','userImage.jpg'));
        UserWrapp wrappRecord = getUserDetails(profileUserId);
        return  wrappRecord;
    }
    @AuraEnabled
    public static String addFollowUser(String parentId)
    {
		EntitySubscription newEntitySubscriptionRecord    = new EntitySubscription(
                                                            NetworkId       = Network.getNetworkId(),
                                                            ParentId        = parentId.substring(0, 15),
                                                            SubscriberId    = UserInfo.getUserId().substring(0, 15));
        try{insert newEntitySubscriptionRecord;}
        catch(Exception e){}
        
        return 'Subscription Added';
    }
    @AuraEnabled
    public static String removeFollowUser(String parentId)
    {
        String subscriberId = UserInfo.getUserId();
        delete [SELECT Id FROM EntitySubscription WHERE ParentId =: parentId AND SubscriberId =: subscriberId];
        return 'Subscription Removed';
    }
    
}