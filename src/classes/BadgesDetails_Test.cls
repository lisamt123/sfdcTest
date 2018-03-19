@isTest(SeeAllData=true)
private class BadgesDetails_Test {
  
    static testMethod void test_method_one() {
        
        TestDataFactory factory = new TestDataFactory();   
        List<User>userList = factory.createUsersWith10KCustomerProfile(1);
        Insert userList;
        RecordType trailRecords = [select Id,Name from RecordType where SobjectType='Achievement__c' and Name='Trailhead Badge' Limit 1];
        RecordType certificateRecord = [select Id,Name from RecordType where SobjectType='Achievement__c' and Name='Salesforce Certification' Limit 1];
        List<Achievement__c> achiList = new List<Achievement__c>();
        Achievement__c achi1 = new Achievement__c(Trailhead_Logo_Url__c = '/resource/Salesforce_Certified_Administrator',RecordTypeId = trailRecords.Id);
        Achievement__c achi2 = new Achievement__c(Trailhead_Logo_Url__c = '/resource/Salesforce_Certified_Administrator',RecordTypeId = certificateRecord.Id);
        achiList.add(achi1);
        achiList.add(achi2);
        Insert achiList;
        List<Expert_Achievement__c> expertList = new List<Expert_Achievement__c>();
        Expert_Achievement__c expert1 = new Expert_Achievement__c(Achievement__c = achiList[0].Id,Certification_Date__c = Date.Today(),Contact__c = userList[0].contactId);
        Expert_Achievement__c expert2 = new Expert_Achievement__c(Achievement__c = achiList[1].Id,Certification_Date__c = Date.Today(),Contact__c = userList[0].contactId);
        expertList.add(expert1);
        expertList.add(expert2);
        Insert expertList;
        Contact con = [Select Id,Trailhead_User_Id__c,Webassessor_ContactId__c From Contact Where Id = : userList[0].contactId];
        StaticResource reso = [SELECT Id, Name, ContentType, Body FROM StaticResource Where ContentType = 'image/png' And Name = 'closebutton'  Limit 1];
        System.assertNotEquals(reso, null);
        System.RunAs(userList[0]){
            BadgesDetails.getAchivements(UserInfo.getUserId()); 
            BadgesDetails.getCertifications(UserInfo.getUserId());
            BadgesDetails.getUserDetails(UserInfo.getUserId());
            BadgesDetails.validateCurrentUser(UserInfo.getUserId());
            BadgesDetails.userWrapp wrapp = new BadgesDetails.userWrapp();
            wrapp.userInfo = userList[0];
            wrapp.userStreet = 'Test';
            wrapp.userCity = 'Test';
            wrapp.userState = 'California';
            wrapp.userZip = '333';
            wrapp.userCountry = 'United States';
            wrapp.contactDetail = con;
            String jsonStr = JSON.serialize(wrapp);
            BadgesDetails.saveUserDetails(jsonStr);
            BadgesDetails.saveProfilePicture(EncodingUtil.base64Encode(reso.Body), UserInfo.getUserId());
            BadgesDetails.addFollowUser(UserInfo.getUserId());
            BadgesDetails.removeFollowUser(UserInfo.getUserId());
        }
        
    }
}