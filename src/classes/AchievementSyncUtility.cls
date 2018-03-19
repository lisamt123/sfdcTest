/**
*   Name          : AchievementSyncUtility 
*   Dated         : 29 June, 2016
*   Author        : BM
*   Useges        : Used to retrieve information regarding Salesforce Certification and Trailhead badges and store them in Achievement object related to a specific contact. 
*/
public with sharing class AchievementSyncUtility {
    public AchievementSyncUtility() 
    {}

    //--Method to retrieve information about Salesforce certificates of a user.
    public List<sObject> syncSalesforceCertifications(List<Id> contactIdList,Boolean isForceSync,String objectName) {
        List<sObject> sObjectList = new List<sObject>();
        Id devRecordTypeId = Schema.SObjectType.Achievement__c.getRecordTypeInfosByName().get('Salesforce Certification').getRecordTypeId();
        Map<String,Achievement__c> achievementsMap = new Map<String,Achievement__c>();
        for(Achievement__c Achievement : [SELECT Id, Name FROM Achievement__c WHERE RecordTypeId =: devRecordTypeId]) {
            achievementsMap.put(Achievement.Name,Achievement);
        }

        List<sObject> recordsList  = Database.query('SELECT Id, Webassessor_Email__c ,Webassessor_ContactId__c,(SELECT Id,Name,Achievement__c,Achievement__r.Name,Created_From_Sync__c FROM Expert_Achievements__r WHERE Type__c = \'Salesforce Certification\' LIMIT 250) FROM ' + objectName + ' WHERE ID IN:contactIdList LIMIT 50');
        for(sObject sobj :recordsList) {
            if(sobj.get('Webassessor_Email__c') != null) {
                String webassessorContactId = isForceSync && sobj.get('Webassessor_ContactId__c') != null ? (String)sobj.get('Webassessor_ContactId__c') : retrieveContactId((String)sobj.get('Webassessor_Email__c'));
                if(webassessorContactId != '' && webassessorContactId != null) {
                    sobj.put('Webassessor_ContactId__c', webassessorContactId);
                    sObjectList.add(sobj);
                    Map<String,DateAndHolderNameWrapper> certificatesMap = retrieveSalesforceCertificates(webassessorContactId,sobj.Id);

                    Set<String> certificateSet = new Set<String>();
                    for(sObject ach: sobj.getsObjects('Expert_Achievements__r')) {
                        Expert_Achievement__c expertAchievement = (Expert_Achievement__c)ach;
                        if(certificatesMap.keySet().contains(expertAchievement.Achievement__r.Name)) {
                            expertAchievement.Status__c                 = 'Active';
                            expertAchievement.Holder_Name__c            = certificatesMap.get(expertAchievement.Achievement__r.Name).holderName;
                            expertAchievement.Certification_Date__c     = certificatesMap.get(expertAchievement.Achievement__r.Name).certificateDate;
                        }
                        else {
                            if(expertAchievement.Created_From_Sync__c == true)
                                expertAchievement.Status__c = 'Expired';
                            else 
                                expertAchievement.Status__c = 'Deprecated';
                        }
                        certificateSet.add(expertAchievement.Achievement__r.Name);
                        sObjectList.add(expertAchievement);
                    }

                    for(String certificateName :certificatesMap.keyset()) {
                        if(!achievementsMap.keySet().contains(certificateName)) {
                            Achievement__c achievement          = new Achievement__c();
                            achievement.Name                    = certificateName;
                            achievement.RecordTypeId            = devRecordTypeId;
                            sObjectList.add(achievement);

                            Expert_Achievement__c expertAchievement = new Expert_Achievement__c();
                            expertAchievement.Created_From_Sync__c  = true;
                            expertAchievement.Status__c             = certificateName;
                            expertAchievement.Certification_Date__c = certificatesMap.get(certificateName).certificateDate;
                            expertAchievement.Holder_Name__c        = certificatesMap.get(certificateName).holderName;
                            expertAchievement.Achievement__c        = achievement.Id;
                            if(objectName == 'Contact')
                                expertAchievement.Contact__c        = sobj.Id;
                            else 
                                expertAchievement.Lead__c           = sobj.Id;
                            sObjectList.add(expertAchievement);
                        } 
                        else if(!certificateSet.contains(certificateName)) {
                            Expert_Achievement__c expertAchievement = new Expert_Achievement__c();
                            expertAchievement.Created_From_Sync__c  = true;
                            expertAchievement.Certification_Date__c = certificatesMap.get(certificateName).certificateDate;
                            expertAchievement.Holder_Name__c        = certificatesMap.get(certificateName).holderName;
                            expertAchievement.Achievement__c        = achievementsMap.get(certificateName).Id;
                            expertAchievement.Status__c             = 'Active';
                            if(objectName == 'Contact')
                                expertAchievement.Contact__c        = sobj.Id;
                            else 
                                expertAchievement.Lead__c           = sobj.Id;
                            sObjectList.add(expertAchievement);
                        }
                    }
                }
            }
        }
        return sObjectList;
    }

    //--Method to retrieve information about trailhead badges of a user.
    public List<sObject> syncTrailheadBadges(List<Id> contactIdList,String objectName) {
        system.debug('----------------contactIdList---------------------'+contactIdList);
        List<sObject> sObjectList                   = new List<sObject>();
        Id devRecordTypeId                          = Schema.SObjectType.Achievement__c.getRecordTypeInfosByName().get('Trailhead Badge').getRecordTypeId();
        Map<String,Achievement__c> achievementsMap  = new Map<String,Achievement__c>();
        for(Achievement__c Achievement : [SELECT Id, Name FROM Achievement__c WHERE RecordTypeId =: devRecordTypeId])
            achievementsMap.put(Achievement.Name,Achievement);
        List<sObject> recordsList  = Database.query('SELECT Id, Trailhead_User_Id__c,(SELECT Id,Name,Achievement__c,Achievement__r.Name,Created_From_Sync__c,Holder_Name__c,Achievement__r.Trailhead_Logo_Url__c FROM Expert_Achievements__r WHERE Type__c = \'Trailhead Badge\') FROM ' + objectName + ' WHERE ID IN:contactIdList LIMIT 50');
        Set<Id> achievementsIdSet = new Set<Id>();
        for(sObject sobj :recordsList) {
            if(sobj.get('Trailhead_User_Id__c') != null) {
                Map<String,String> badgesMap    = retrieveTrailheadBadges((String)sobj.get('Trailhead_User_Id__c'),sobj);
                Set<String> badgeSet            = new Set<String>();
                
                for(sObject ach: sobj.getsObjects('Expert_Achievements__r')) {
                    Expert_Achievement__c expertAachievement = (Expert_Achievement__c)ach;
                    badgeSet.add(expertAachievement.Achievement__r.Name);
                    
                    // Added else part by AKS to update the HolderName and update Batch and trigger to handle update holder
                    if(!badgesMap.keyset().contains(expertAachievement.Achievement__r.Name)) {
                        expertAachievement.Status__c = 'Delete';
                        sObjectList.add(expertAachievement);
                    }
                    else if(badgesMap.keyset().contains(expertAachievement.Achievement__r.Name) && expertAachievement.Holder_Name__c != badgesMap.get('userName')){
                        expertAachievement.Status__c = 'UpdateHolderName';
                        expertAachievement.Holder_Name__c = badgesMap.get('userName');
                        sObjectList.add(expertAachievement);
                    }
                }
                for(String badgeName :badgesMap.keyset()) {
                    if(!achievementsMap.keySet().contains(badgeName) && badgeName != 'userName') {
                        Achievement__c achievement          = new Achievement__c();
                        achievement.Name                    = badgeName;
                        achievement.RecordTypeId            = devRecordTypeId;
                        achievement.Trailhead_Logo_Url__c   = badgesMap.get(badgeName);
                        sObjectList.add(achievement);

                        Expert_Achievement__c expertAchievement = new Expert_Achievement__c();
                        expertAchievement.Created_From_Sync__c  = true;
                        expertAchievement.Status__c             = badgeName;
                        expertAchievement.Holder_Name__c        = badgesMap.get('userName');
                        expertAchievement.Achievement__c        = achievement.Id;
                        if(objectName == 'Contact')
                            expertAchievement.Contact__c        = sobj.Id;
                        else 
                            expertAchievement.Lead__c           = sobj.Id;
                        sObjectList.add(expertAchievement);
                        achievementsIdSet.add(achievement.Id);
                    }
                    else if(!badgeSet.contains(badgeName) && badgeName != 'userName') {
                        Expert_Achievement__c expertAchievement = new Expert_Achievement__c();
                        expertAchievement.Created_From_Sync__c  = true;
                        expertAchievement.Holder_Name__c        = badgesMap.get('userName');
                        expertAchievement.Achievement__c        = achievementsMap.get(badgeName).Id;
                        expertAchievement.Status__c             = 'Active';
                        if(objectName == 'Contact')
                            expertAchievement.Contact__c        = sobj.Id;
                        else 
                            expertAchievement.Lead__c           = sobj.Id;
                        sObjectList.add(expertAchievement);
                        achievementsIdSet.add(achievementsMap.get(badgeName).Id);

                    }
                }
            }
        }
        
            removeAchievements(achievementsMap.values(),achievementsIdSet);
        return sObjectList;
    }

    public void removeAchievements(List<Achievement__c> achievementsList,Set<Id> achievementsIdSet) {
        Set<Id> achievementId = new Set<Id>();
        Set<Id> setAchIdNotToDelete = achievementsIdSet;
        Set<Id> setAchIdToDelete = new Set<Id>();
        Id devRecordTypeId       = Schema.SObjectType.Achievement__c.getRecordTypeInfosByName().get('Trailhead Badge').getRecordTypeId();

        List<sObject> listToDelete = new List<sObject>();
        
        achievementsList.addAll([SELECT Id, Name FROM Achievement__c WHERE Id Not IN :achievementsList AND RecordTypeId =: devRecordTypeId]);     
        for(Achievement__c ach : [SELECT Id,(SELECT Id FROM Expert_Achievements__r) FROM Achievement__c WHERE Id IN :achievementsList]) {
             if(!ach.Expert_Achievements__r.isEmpty())
                setAchIdNotToDelete.add(ach.id);
        }

        for(Achievement__c ach : [SELECT Id,(SELECT Id FROM Achievement_Skills__r) FROM Achievement__c WHERE Id IN :achievementsList]) {
             if(!ach.Achievement_Skills__r.isEmpty())
                setAchIdNotToDelete.add(ach.id);
        }

        for(Achievement__c ach : [SELECT Id,(select Id from Achievement_Assignments__r) FROM Achievement__c WHERE Id IN :achievementsList]) {
             if(!ach.Achievement_Assignments__r.isEmpty())
                setAchIdNotToDelete.add(ach.id);
        }

        for(Achievement__c ach : [SELECT Id,(select Id from Training_Tracks__r) FROM Achievement__c WHERE Id IN :achievementsList]) {
             if(!ach.Training_Tracks__r.isEmpty())
                setAchIdNotToDelete.add(ach.id);
        }
        for(Achievement__c ach : [SELECT Id,(Select id from Training_Plan_Achievements__r) FROM Achievement__c WHERE Id IN :achievementsList]) { 
             if(!ach.Training_Plan_Achievements__r.isEmpty())
                setAchIdNotToDelete.add(ach.id);
        }
        for(Achievement__c obj: achievementsList) {
            if(!setAchIdNotToDelete.contains(obj.Id))
                listToDelete.add(obj);
        }
        if(listToDelete.size() > 0)
            Delete listToDelete;
    }

    //--Return map of name and url of Trailhead badges for a particular user by screen screping "https://trailhead.salesforce.com/en/me/userId" page.
    public Map<String,String> retrieveTrailheadBadges(String trailheadUserId,sObject record) {
        boolean statusResponse  = false;
        String requestUrl       = Endpoint_URIs__c.getOrgDefaults().TrailheadBadges_URI_Trailhead__c + trailheadUserId;
        Http http               = new Http();
        HttpRequest req         = new HttpRequest();
        req.setEndpoint( requestUrl);
        req.setMethod('GET');
        HTTPResponse res    = http.send(req);
        String output       = res.getBody();
        Integer status      = res.getStatusCode();
        String userName     = '';
        List<String> splitResponseList1 = new List<String>();
        Map<String,String> badgesMap    = new Map<String,String>();
        
        if(status == 301) {
            if(output.contains('href="') && output.split('href="').size() > 1)
                requestUrl = output.split('href="')[1].split('">')[0];
            Http http1       = new Http();
            HttpRequest req1 = new HttpRequest();
            req1.setEndpoint( requestUrl);
            req1.setMethod('GET');
            HTTPResponse res1   = http1.send(req1);
            output              = res1.getBody();
            status              = res1.getStatusCode();
        }
        
        if(status  == 200 ) { 
            try {

                String outputWithoutQuot    = '';
                outputWithoutQuot           = output.replace('&quot;','"');
                splitResponseList1          = outputWithoutQuot.split('"tags":');
                userName = outputWithoutQuot.split('<title>')[1].split('Salesforce Trailhead')[1].split('&#39;s')[0];
                userName = EncodingUtil.urlEncode(userName, 'UTF-8').replace('%7C','');
                userName = EncodingUtil.urlDecode(userName,'UTF-8');
                userName = userName.trim();
                
                for(Integer i = 0 ; i < splitResponseList1.size() - 1 ; i++) {
                    String badgeurl;
                    String badgeName;
                    if (!(splitResponseList1[i].contains('"badge_type":"event"') || splitResponseList1[i].contains('"badge_type":"community"'))) {
                        badgeurl    = splitResponseList1[i].split('"icon_url":"')[1].split('","title":"')[0]; 
                        badgeName   = splitResponseList1[i].split('"title":"')[1].split('","progress"')[0];
                    } 
                    else {
                        badgeurl    = splitResponseList1[i].split('"icon_url":"')[1].split('","progress"')[0]; 
                        badgeName   = splitResponseList1[i].split('"title":"')[1].split('","path"')[0];
                    }
                        
                    if (badgeName != null && badgeurl != null) {
                        badgeName = badgeName.unescapeJava();
                        badgeName = badgeName.unescapeHtml4(); 
                        badgeName = badgeName.unescapeUnicode();
                        badgeName = EncodingUtil.urlEncode(badgeName,'UTF-8');
                        badgeName = EncodingUtil.urlDecode(badgeName,'UTF-8');
                       
                        
                        badgeurl = EncodingUtil.urlEncode(badgeurl, 'UTF-8');
                        badgeurl = badgeurl.replaceAll('%5Ct', '');
                        badgeurl = badgeurl.replace('5Cu0026','26');
                        badgeurl = EncodingUtil.urlDecode(badgeurl,'UTF-8');
                        badgesMap.put(badgeName.trim(),badgeurl.trim());
                    }
                }
                
                if(userName != '')
                    badgesMap.put('userName',userName);
            }
            catch(Exception e) {
                String body = '<html><body>Hi Matt,<br><br>Trailhead Badges Sync Process has been failed due to  Unparse Response  <br> Source Record Id : '+record.Id+'<br> ClassName : AchievementSyncUtility.cls'+'<br> Line Number : '+e.getLineNumber()+'<br> Error Message: '+e.getMessage();
                String subject = 'Trailhead Badges Sync Process Failed';
                if((!output.contains('TRAIL NOT FOUND')) && (output.contains('BadgesPanel')))
                     mailForBadgesCertification(subject,body);
            }
        }
       return badgesMap;
    }

    //--Return userID for salesforce certification by screen screping "http://certification.salesforce.com/verification-email?init=1&email=userEmail" page.
    public String retrieveContactId(String contactsWebassessorEmail) {
        String requestUrl   = Endpoint_URIs__c.getOrgDefaults().ContactId_URI_Salesforce_Certificate__c + contactsWebassessorEmail;
        Http http           = new Http();
        HttpRequest req     = new HttpRequest();
        req.setEndpoint( requestUrl);
        req.setMethod('GET');

        HTTPResponse res    = http.send(req);
        String output       = res.getBody();
        if(output.contains('conId='))
            return output.split('conId=')[1].split('"')[0];
        return '';
    }

    //--Return a map of name and created date of salesforce certification for a particular user by screen screping "http://certification.salesforce.com/certification-detail?conId=contactid" page.
    public Map<String,DateAndHolderNameWrapper> retrieveSalesforceCertificates(String webassessorContactId,String recordId) {
        Boolean statusResponse = false;
        Integer status;
        Map<String,DateAndHolderNameWrapper> certificatesMap = new Map<String,DateAndHolderNameWrapper>();
        String requestUrl   = Endpoint_URIs__c.getOrgDefaults().SalesforceCertificates_URI__c + webassessorContactId;
        Http http           = new Http();
        HttpRequest req     = new HttpRequest();
        req.setEndpoint( requestUrl);
        req.setMethod('GET');

        HTTPResponse res    = http.send(req);
        String output       = res.getBody();
        status = res.getStatusCode();
        List<String> splitResponseList = new List<String>();
        String holderName = '';
        
        if(status == 301) {
            if(output.contains('href="') && output.split('href="').size() > 1)
                requestUrl = output.split('href="')[1].split('">')[0];
            Http http1           = new Http();
            HttpRequest req1     = new HttpRequest();
            req1.setEndpoint(requestUrl);
            req1.setMethod('GET');
            HTTPResponse res1    = http1.send(req1);
            output       = res1.getBody();
            status = res1.getStatusCode();
        }
        
        if(status == 200) {
            try {
                if(output.contains(webassessorContactId)) {
                    splitResponseList = output.split(webassessorContactId + '">');
                    holderName = splitResponseList[0].split('data-full-name="')[1].split('"')[0];
                }
            
                Map<String,String> dateMap = new Map<String,String> {
                    'January'   => '1',
                    'February'  => '2',
                    'March'     => '3',
                    'April'     => '4',
                    'May'       => '5',
                    'June'      => '6',      
                    'July'      => '7',
                    'August'    => '8',
                    'September' => '9',
                    'October'   => '10',
                    'November'  => '11',
                    'December'  => '12'
                };

                
                for(Integer i = 1 ; i < splitResponseList.size() ; i++) {
                    String certificateName         = splitResponseList[i].split('</span>')[0];
                    String certificateDateString    = splitResponseList[i].split('</span>')[1].split('"date-certified">')[1];
                    Integer year                    =  Integer.valueOf(certificateDateString.split(',')[1].trim());
                    Integer month                   = Integer.valueOf(dateMap.get(certificateDateString.split(' ')[0].trim()));
                    Integer day                     = Integer.valueOf(certificateDateString.split(' ')[1].split(',')[0].trim());
                    Date certificateDate            = Date.newInstance(year,month,day);
                    certificatesMap.put(certificateName.replace('&amp;', '&'),new DateAndHolderNameWrapper(certificateDate,holderName));
                    
                }
                
            }

            catch(Exception e) {
                String body = '<html><body>Hi Matt,<br><br> Salesforce Certification Sync Process has been failed due to  Unparse Response  <br> Source Record Id : '+recordId+'<br> ClassName : AchievementSyncUtility.cls'+'<br> Line Number : '+e.getLineNumber()+'<br> Error Message: '+e.getMessage();
                String subject = 'Salesforce Certification Sync Process Failed';
                mailForBadgesCertification(subject,body);
            }
        }
        return certificatesMap;
    }

    public void mailForBadgesCertification(String subject,String body) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String strEmail = System.Label.Badge_Sync_Report_Email;
        List<String> sendTo = new List<String>();       
        sendTo.add(strEmail);
        mail.setToAddresses(sendTo);
        mail.setBccSender(false);
        mail.setHtmlBody(body);
        mail.setSubject(subject);
        mail.setUseSignature(false);
        mail.setTreatTargetObjectAsRecipient(false);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    } 

    public static void resolveRedundancy(String parent,Set<Id> idSet) {
        List<Expert_Achievement__c> listToDelete = new List<Expert_Achievement__c>();
        String query = 'SELECT Id, Achievement__c,CreatedDate,Lead__c,Contact__c FROM Expert_Achievement__c WHERE ' + parent + ' IN: idSet';
        Map<String,List<Expert_Achievement__c>> expertAchievementMap = new Map<String,List<Expert_Achievement__c>>();
        
        for(Sobject sobj : Database.query(query)) {
            if(!expertAchievementMap.containsKey((String)sobj.get(parent)))
                expertAchievementMap.put((String)sobj.get(parent),new List<Expert_Achievement__c>());
            expertAchievementMap.get((String)sobj.get(parent)).add((Expert_Achievement__c)sobj);
        }
        
        for(String str : expertAchievementMap.keySet())
            listToDelete.addAll(retrieveListToDelete(expertAchievementMap.get(str)));

        if(listToDelete.size() > 0)
            delete listToDelete;

        query = 'SELECT Id, Skill__c,CreatedDate,Lead__c,Contact__c FROM Expert_Skill__c WHERE ' + parent + ' IN: idSet';
        Map<String,List<Expert_Skill__c>> expertSkillMap = new Map<String,List<Expert_Skill__c>>();
        List<Expert_Skill__c> listOfSkillToDelete = new List<Expert_Skill__c>();
        for(Sobject sobj : Database.query(query)) {
            //listToDelete.addAll(retrieveListToDelete(con.Expert_Achievements__r));
            if(!expertSkillMap.containsKey((String)sobj.get(parent)))
                expertSkillMap.put((String)sobj.get(parent),new List<Expert_Skill__c>());
            expertSkillMap.get((String)sobj.get(parent)).add((Expert_Skill__c)sobj);
        }
        
        for(String str : expertSkillMap.keySet())
            listOfSkillToDelete.addAll(retrieveSkillListToDelete(expertSkillMap.get(str)));

        if(listOfSkillToDelete.size() > 0)
            delete listOfSkillToDelete;
    }

    public Static List<Expert_Achievement__c> retrieveListToDelete(List<Expert_Achievement__c> expertAchievementList) {
        List<Expert_Achievement__c> listToDelete = new List<Expert_Achievement__c>();
        Map<Id,Expert_Achievement__c> achievementIdMap = new Map<Id,Expert_Achievement__c>();
        for(Expert_Achievement__c expertAchievement : expertAchievementList) {
            if(achievementIdMap.containsKey(expertAchievement.Achievement__c)) {
                if(achievementIdMap.get(expertAchievement.Achievement__c).CreatedDate > expertAchievement.CreatedDate ) {
                    listToDelete.add(achievementIdMap.get(expertAchievement.Achievement__c));
                    achievementIdMap.put(expertAchievement.Achievement__c,expertAchievement);
                }
                else
                    listToDelete.add(expertAchievement);
            }
            else
                achievementIdMap.put(expertAchievement.Achievement__c,expertAchievement);
        }
        return listToDelete;
    }

    public Static List<Expert_Skill__c> retrieveSkillListToDelete(List<Expert_Skill__c> expertSkillList) {
        List<Expert_Skill__c> listToDelete = new List<Expert_Skill__c>();
        Map<Id,Expert_Skill__c> achievementIdMap = new Map<Id,Expert_Skill__c>();
        for(Expert_Skill__c expertSkill : expertSkillList) {
            if(achievementIdMap.containsKey(expertSkill.Skill__c)) {
                if(achievementIdMap.get(expertSkill.Skill__c).CreatedDate > expertSkill.CreatedDate ) {
                    listToDelete.add(achievementIdMap.get(expertSkill.Skill__c));
                    achievementIdMap.put(expertSkill.Skill__c,expertSkill);
                }
                else
                    listToDelete.add(expertSkill);
            }
            else
                achievementIdMap.put(expertSkill.Skill__c,expertSkill);
        }
        return listToDelete;
    }

    public class DateAndHolderNameWrapper {
        public Date certificateDate;
        public String holderName;

        public DateAndHolderNameWrapper(Date certificateDate,String holderName) {
            this.certificateDate = certificateDate;
            this.holderName = holderName;
        }
    }
}