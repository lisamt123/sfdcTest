public with sharing class TestDataFactory {
    
    
    public List<Expert_Achievement__c> generateExpertAchievements(List<Achievement__c> achievements, List<Contact> contacts) {
        List<Expert_Achievement__c> expertAchievementsList = new List<Expert_Achievement__c>(); 
        
        if(achievements == null || contacts == null || (achievements.size() != contacts.size()))    
            return null;
            
        for(Integer i =0; i < achievements.size() ; i++ ) {
            expertAchievementsList.add(new Expert_Achievement__c(Achievement__c=achievements[i].Id, Contact__c=contacts[i].Id));        
        }
        return expertAchievementsList;
    }

    public List<Expert_Achievement__c> generateExpertAchievementsForLead(List<Achievement__c> achievements, Lead leadRec) {
        List<Expert_Achievement__c> expertAchievementsList = new List<Expert_Achievement__c>(); 
        
        if(achievements == null || leadRec == null )    
            return null;
            
        for(Integer i =0; i < achievements.size() ; i++ ) {
            expertAchievementsList.add(new Expert_Achievement__c(Achievement__c=achievements[i].Id, Lead__c=leadRec.Id));        
        }
        return expertAchievementsList;
    }
    
    public List<Achievement__c> generateAchievements(Integer numberOfAchievements) {
        List<Achievement__c> achievementList = new List<Achievement__c>();
        for(Integer i = 0; i < numberOfAchievements; i++) {
            achievementList.add(new Achievement__c(Name = 'Achievenment ' + i+1, RecordTypeId = Constants.RECORDTYPEID_Achievement));
        }

        return achievementList;
    }
    
    public List<Account> generateAccounts(Integer numberOfAccounts) {
        List<Account> accountList = new List<Account>();
        
        for(Integer i = 0; i < numberOfAccounts; i++) {
            accountList.add(new Account(Name = 'Test Account ' + i+1));
        }

        return accountList;
    }

    public List<Status_Report__c> generateStatusReports(Integer numberOfStatusReports,Project__c project) {
        List<Status_Report__c> statusReportList = new List<Status_Report__c>();
        
        for(Integer i = 0; i < numberOfStatusReports; i++) {
            statusReportList.add(new Status_Report__c(Start_Date__c = System.today().addDays(-7),End_Date__c = System.today(),
                                    Issues_Risks__c = 'Test', Key_Items_Completed_Last_Week__c = 'Test', Key_Items_Scheduled_for_This_Week__c = 'Test', 
                                    Upcoming_Holidays_PTO__c = 'Test', Project__c = project.Id));
        }

        return statusReportList;
    }
    
    public Case generateCase(String strSuppliedEmail) {
        
        Case objCase = new Case(Status = 'New', Origin = 'Email', SuppliedEmail = strSuppliedEmail);

        return objCase;
    }
    
    public Lead generateLead(String strLastName, String strCompany, String strStatus) {
        
        Lead objLead = new Lead(Status = strStatus, LastName = strLastName, Company = strCompany);

        return objLead;
    }
    
    public Id generateRecordTypeID(String strObjectName, String strDeveloperName) {
        
        if(!string.isBlank(strObjectName) && !string.isBlank(strDeveloperName)) {
            
            return [Select SobjectType, Id, DeveloperName From RecordType Where SobjectType = :strObjectName And DeveloperName =:strDeveloperName][0].Id;
        }
        else {
            
            return null;
        }
    }
     public List<Story__c> generateSprintStories(Id projectId, Id sprintId, Integer numberOfStories){
        List<Story__c> storiesList = new List<Story__c>();
        for(Integer i=0; i < numberOfStories ; i++){
            Story__c stry = new Story__c();
            stry.Story_Name__c = 'Test Story' + String.valueOf(i);
            stry.Project__c = projectId ;
            stry.Sprint__c = sprintId;
            stry.Status__c = 'Draft';
            stry.Priority__c = 'Medium' ;
            storiesList.add(stry);
        }
        return storiesList;
    }
    public List<Story__c> generateStories(Id projectId, Integer numberOfStories){
        List<Story__c> storiesList = new List<Story__c>();
        for(Integer i=0; i < numberOfStories ; i++){
            Story__c stry = new Story__c();
            stry.Story_Name__c = 'Test Story' + String.valueOf(i);
            stry.Project__c = projectId ;
            stry.Status__c = 'Draft';
            stry.Priority__c = 'Medium' ;
            stry.Level_of_Effort__c = 2;
            storiesList.add(stry);
        }
        return storiesList;
    }

    public  List<Opportunity> generateOpportunities(Id accountId,String stageName, Date closeDate ,Integer numberOfOpportunities) {
        List<Opportunity> oppList = new  List<Opportunity>();
        for(integer i=0; i < numberOfOpportunities ; i++){
            Opportunity opp = new Opportunity();
            opp.RecordTypeId = Constants.RECORDTYPEID_OPPORTUNITY_SERVICES;
            opp.AccountId = accountId;
            opp.StageName = stageName;
            opp.CloseDate =  closeDate ;
            opp.Amount = 10;
            opp.Name = 'Test Opportunity' + i;
            oppList.add(opp);
        }
        return oppList;
    }
    
    public Opportunity generateOpportunity(String strOpptyName, Id accountId, Date closeDate, String strStageName, Date subscriptionStartDate, Date subscriptionEndDate) {
        
        Opportunity objOpportunity = new Opportunity(Name = strOpptyName, AccountId = accountId, CloseDate = closeDate, Amount = 10, StageName = strStageName, Subscription_Start_Date__c = subscriptionStartDate, Subscription_End_Date__c = subscriptionEndDate);

        return objOpportunity;
    }
    
    public sfLma__License__c generateLicense(Id accountId) {
        
       sfLma__License__c objLicense = new sfLma__License__c(sfLma__Account__c = accountId);

        return objLicense;
    }
    
    public List<Contact> generateContactsForAccounts(List<Account> accountList, Integer numberOfContactsPerAccount) {
        List<Contact> contactList = new List<Contact>();
        
        for(Account acct : accountList) {
            for(Integer i = 0; i < numberOfContactsPerAccount; i++) {
                contactList.add(new Contact(FirstName = 'Test',
                                            LastName = 'Contact ' + i+1,
                                            AccountId = acct.Id));
            }
        }

        return contactList;
    }

    public List<Agreement__c> generateRetainerAgreementsForAccounts(List<Account> accountList, Integer numberOfAgreementsPerAccount) {
        List<Agreement__c> agreementList = generateAgreementsForAccounts(accountList, numberOfAgreementsPerAccount, Constants.RECORDTYPEID_AGREEMENT_RETAINER);
        for(Agreement__c agreement : agreementList) {
            agreement.Rate_Structure__c = 'Monthly';
        }
        return agreementList;
    }

    private List<Agreement__c> generateAgreementsForAccounts(List<Account> accountList, Integer numberOfAgreementsPerAccount, Id recordType) {
        List<Agreement__c> agreementList = new List<Agreement__c>();
        
        for(Account acct : accountList) {
            for(Integer i = 0; i < numberOfAgreementsPerAccount; i++) {
                agreementList.add(new Agreement__c(Name = 'Test Agreement ' + i+1,
                                                   Account__c = acct.Id,
                                                   RecordTypeId = recordType,
                                                   Status__c = 'Active',
                                                   Effective_Date__c = Date.newInstance(System.Today().Year(), System.Today().Month() - 1, 1),
                                                   Valid_Through__c = Date.newInstance(System.Today().Year() + 1, System.Today().Month() - 1, 1)));
            }
        }

        return agreementList;
    }

    public List<Project__c > generateProjects(Id accountId, integer noOfProjects){
        List<Project__c > projectList = new  List<Project__c >();
        for(integer i = 0; i< noOfProjects; i++){
            projectList.add(new project__c(account__C = accountId));
        }
        return projectList ;
    }
    
    public List<Rate__c> generateRateForAgreement(Id agreementId, String assignmentType, String role, Integer noOfInstance) {
        List<Rate__c> rateList = new List<Rate__c>();
        
        for(integer i = 0; i < noOfInstance ; i ++) {
            Rate__c rate = new Rate__c();
            rate.Name = 'Test Rate' + i;
            if(assignmentType == Constants.ASSIGNMENTTYPE_NAMEDRESOURCE) {
                rate.RecordTypeId = Constants.RECORDTYPEID_RATE_NAMED_RESOURCE;
            }
            else if(assignmentType == Constants.ASSIGNMENTTYPE_RETAINEDCAPACITY) {
                rate.RecordTypeId = Constants.RECORDTYPEID_RATE_RETAINED_CAPACITY;
            }
            else if(assignmentType == Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS) {
                rate.RecordTypeId = Constants.RECORDTYPEID_RATE_TIMEANDMATERIALS;
            }
            rate.Agreement__c = agreementId;
            rate.Assignment_Type__c = assignmentType;
            rate.Role__c = role;
            rate.Hourly_Rate__c = 100;
            rateList.add(rate);
        }
        return rateList ;
    }

    public List<assignment__c> generateAssignment(Id projectId, String assignmentType, Integer noOfInstance){
        List<Assignment__c> assignmentList = new List<assignment__c>();
        for(Integer i=0; i< noOfInstance ; i ++){
            Assignment__c assignmentObj = new Assignment__c();
            assignmentObj.Assignment_Type__c = assignmentType;
            assignmentObj.Status__c = 'Active';
            assignmentObj.project__c =  projectId;
            assignmentList.add(assignmentObj); 
        } 
        
        return assignmentList ;
    }
    
    public List<time_entry__c> generateTimeEntry(Id assignmentId, String description, Date dateValue, Decimal hour, Integer noOfInstance){
        List<time_entry__c> timeEntryList = new List<time_entry__c>();
        for(Integer i=0; i < noOfInstance ; i++){
            Time_entry__C timeEntryObj = new Time_entry__C(hours__c = hour);
            timeEntryObj.assignment__C = assignmentId;
            timeEntryObj.description__c = description;
            timeEntryObj.date__C = dateValue;
            timeEntryList.add(timeEntryObj);
        }    
        return timeEntryList ;
    }
    
    public Project_Agreement__C  generateProjectAgreements(Id projecId, Id agreementId){
        Project_agreement__c prjAgreement = new Project_agreement__c();
        prjAgreement.agreement__C = agreementId;
        prjAgreement.project__C = projecId;
        return prjAgreement;
    }
    
    public List<Invoice__c > generateInvoices (Id accountid, String Name, Integer noOfInstance) {
        List<Invoice__c > invoiceList = new List<Invoice__c >();
        for(Integer i=0; i < noOfInstance ; i++){
            Invoice__c  invoice = new Invoice__c  ();
            invoice.account__c = accountid;
            invoice.name = Name + i;
            invoice.Billing_Period_Start_Date__c = Date.today() -20 ;
            invoice.Billing_Period_End_Date__c = Date.today() -10 ;
            invoiceList.add(invoice );
        }    
        return invoiceList;
    }

    public List<Invoice_Line_Item__c> generateInvoiceLineItems (Id invoiceId, Id rateId, Integer noOfInstance) {
        List<Invoice_Line_Item__c> invoiceLinItemList = new List<Invoice_Line_Item__c>();
        for(Integer i=0; i < noOfInstance ; i++){
            Invoice_Line_Item__c invoiceLineItem = new Invoice_Line_Item__c();
            invoiceLineItem.invoice__c = invoiceId;
            invoiceLineItem.rate__c = rateId;
            invoiceLinItemList .add(invoiceLineItem );
        }    
        return invoiceLinItemList ;
    }
    
    public Invoice_Line_Item__c generateInvoiceLineItem(Id invoiceId) {
            
        Invoice_Line_Item__c invoiceLineItem = new Invoice_Line_Item__c();
        invoiceLineItem.invoice__c = invoiceId;
        
        return invoiceLineItem;
    }
    
    public List<User> createUsersWithStandardProfile(Integer numOfUsers) {
        Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        return createUsers(numOfUsers, standardUserProfile.Id, null);
    }

    public List<User> createUsersWith10KCustomerProfile(Integer numOfUsers) {
        List<Account> accountList = generateAccounts(numOfUsers);
        insert accountList;

        List<Contact> contactList = generateContactsForAccounts(accountList, 1);
        insert contactList;

        Profile communityUserProfile = [SELECT Id FROM Profile WHERE Name = '10K Services Client (License)'];
        return createUsers(numOfUsers, communityUserProfile.Id, contactList);
    }

    public List<User> createUsersWith10KDeliveryPartnerProfile(Integer numOfUsers) {
        List<Account> accountList = generateAccounts(numOfUsers);
        insert accountList;

        List<Contact> contactList = generateContactsForAccounts(accountList, 1);
        insert contactList;

        Profile communityUserProfile = [SELECT Id FROM Profile WHERE Name = '10K Delivery Partner (License)'];
        return createUsers(numOfUsers, communityUserProfile.Id, contactList);
    }
    
    public List<User> createUsersWith10KDeliveryPartnerProfileNew(Integer numOfUsers) {
        List<Account> accountList = generateAccounts(numOfUsers);
        insert accountList;

        List<Contact> contactList = generateContactsForAccounts(accountList, 1);
        contactList[0].email = 'test@contact.com';
        contactList[0].Other_Email__c = 'test@other.com';
        contactList[0].Webassessor_Email__c = 'test@webassessor.com';
        insert contactList;

        Profile communityUserProfile = [SELECT Id FROM Profile WHERE Name = '10K Delivery Partner (License)'];
        return createUsers(numOfUsers, communityUserProfile.Id, contactList);
    }

    private List<User> createUsers(Integer numOfUsers, Id profileId, List<Contact> contactList) {
        List<User> userList = new List<User>();
        
        for(Integer i = 0; i < numOfUsers; i++) {
            User u = new User(Alias = 'user' + i, 
                              Email = 'testUser' + i + '@10kcommunityview.com',
                              EmailEncodingKey = 'UTF-8', 
                              Country = 'United States',
                              LastName = 'Testing' + i, 
                              LanguageLocaleKey = 'en_US', 
                              LocaleSidKey = 'en_US', 
                              ProfileId = profileId, 
                              TimeZoneSidKey = 'America/Los_Angeles',
                              UserName = 'testUser' + i + '@10kcommunityview.com');
            
            if(contactList != null) {
                u.UserName += contactList[i].Id;
                u.ContactId = contactList[i].Id;
            }

            userList.add(u);
        }
        return userList;
    }
    
    public Project_Request__c generateProjectRequestRecord(Id accountID, String strStatus, Id contactID, String strProjectName, Date closeDateValue){
        
        Project_Request__c objProjectRequest = new Project_Request__c();
        objProjectRequest.Account__c = accountID;
        objProjectRequest.Request_Contact__c = contactID;
        objProjectRequest.Status__c = strStatus;
        objProjectRequest.Closed_Date__c = closeDateValue;
        objProjectRequest.Project_Name__c = strProjectName;
        return objProjectRequest;
    }
    
    public Project_Request_Detail__c generateProjectRequestDetailRecord(Id projectRequestID, String strStatus, Id contactID, Integer assignHrs, Date startDateValue, Date endDateValue, String strRole){
        
        Project_Request_Detail__c objProjectRequestDetail = new Project_Request_Detail__c();
        objProjectRequestDetail.Project_Request__c = projectRequestID;
        objProjectRequestDetail.Assigned_Expert__c = contactID;
        objProjectRequestDetail.Status__c = strStatus;
        objProjectRequestDetail.Assigned_Hours__c = assignHrs;
        objProjectRequestDetail.Assigned_Start_Date__c = startDateValue;
        objProjectRequestDetail.Assigned_End_Date__c = endDateValue;
        objProjectRequestDetail.Role__c = strRole;
        return objProjectRequestDetail;
    }
    
    public List<User> createUsersWith10KCustProfileRecords(Integer numOfUsers, List<Account> accountList, List<Contact> contactList) {      
        Profile communityUserProfile = [SELECT Id FROM Profile WHERE Name = '10K Services Client (License)'];
        return createUsers(numOfUsers, communityUserProfile.Id, contactList);
    }

    public static void initializeEndpointURIsCustomSetting() {
        try {
            Endpoint_URIs__c customSetting = Endpoint_URIs__c.getOrgDefaults();
            customSetting.TrailheadBadges_URI_Trailhead__c = 'https://trailhead.salesforce.com/users/profiles/';
            customSetting.ContactId_URI_Salesforce_Certificate__c = 'http://certification.salesforce.com/verification-email?init=1&email=';
            customSetting.SalesforceCertificates_URI__c = 'http://certification.salesforce.com/certification-detail?conId=';
            update customSetting;
        }
        catch (Exception ex) {
            Endpoint_URIs__c customSetting = new Endpoint_URIs__c();
            customSetting.TrailheadBadges_URI_Trailhead__c  = 'https://trailhead.salesforce.com/users/profiles/';
            customSetting.ContactId_URI_Salesforce_Certificate__c = 'http://certification.salesforce.com/verification-email?init=1&email=';
            customSetting.SalesforceCertificates_URI__c = 'http://certification.salesforce.com/certification-detail?conId=';
            insert customSetting;
        }
    }
    
    public static ConnectedApp__c createConnectedAppCustomSetting() {
        ConnectedApp__c credentials = new ConnectedApp__c( Callback_URL__c = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/AuthorizeSalesforceOrg', 
                                                            Consumer_Key__c = '3MVG9hq7jmfCuKfcGjlDxJufcTij8DYinl.ioRbU7QNTrZC8q67ySP3hrO.hcTzWYMk8AjBySMwCqkNlYA1jI', 
                                                            Consumer_Secret__c = '3922199713804899562' ); //
        insert credentials;
        return credentials;
    }
    
    public static List<Connection__c> generateConnections(Id projectId, Integer noOfProjects) {
        List<Connection__c> connectionList = new List<Connection__c>();
        for(Integer i=0; i<noOfProjects; i++) {
            connectionList.add(new Connection__c( Project__c = projectId,Status__c = 'Inactive'));
        }
        return connectionList;
    }

    public static List<Release__c> generateReleases(Id projectId, Id connectionId, Integer noOfProjects) {
        List<Release__c> releaseList = new List<Release__c>();
        Date Actual_Release_Date = System.today();
        Date Target_Release_Date = Actual_Release_Date.addDays(2);
        for(Integer i=0; i<noOfProjects; i++) {
            releaseList.add(new Release__c(Name = 'TestRelease', Project__c = projectId, Source__c = connectionId, Target__c = connectionId, Status__c = 'Planned', Actual_Release_Date__c = Actual_Release_Date, Target_Release_Date__c = Target_Release_Date));
        }
        return releaseList;
    }

    public static List<Sprint__c> generateSprints(Id projectId, Integer noOfProjects) {
        List<Sprint__c> sprintList = new List<Sprint__c>();
       
        for(Integer i=0; i<noOfProjects; i++) {
            sprintList.add(new Sprint__c(Name = 'TestSprint'+i, Project__c = projectId, Status__c= 'In Progress'));
        }
        return sprintList;
    }

    /* Commented By Ak due deete objct  Story_Artifact__c  09-10-17
    public static List<Story_Artifact__c> generateStoryArtifacts(Id storyId, Integer noOfProjects) {
        List<Story_Artifact__c> artifactList = new List<Story_Artifact__c>();
       
        for(Integer i=0; i<noOfProjects; i++) {
            artifactList.add(new Story_Artifact__c(Story__c = storyId, Metadata_Type__c= 'ApexClass', Metadata_Name__c= 'Test'));
        }
        return artifactList;
    }*/

    /*public static List<Week__c> generateWeeks( Integer noOfWeeks) {
        List<Week__c> weekList = new List<Week__c>();
        for(Integer i = 0; i < noOfWeeks ; i++) {
            weekList.add(new Week__c(Name = 'Week ' + i));
        }
        return  weekList;
    }*/

    /*public static List<Availability__c> generateAvailabilities( Integer noOfAvailabilities, Id weekId, Id contactId) {
        List<Availability__c> availabilityList = new List<Availability__c>();
        for(Integer i = 0; i < noOfAvailabilities ; i++) {
            availabilityList.add(new Availability__c(Name = 'Availability ' + i, Available_Hours__c = 0, Hours_Worked__c = 0 , Week__c = weekId , Contact__c = contactId));
        }
        return availabilityList;
    }*/

    /*public static List<Budget__c> generateBudgets( Integer noOfBudgets, Id weekId, Id availabilitYId , Id assignmentId) {
        List<Budget__c> budgetList = new List<Budget__c>();
        for(Integer i = 0; i < noOfBudgets ; i++) {
            budgetList.add(new Budget__c(Name = 'Budget ' + i,Available_Hours__c = 10, Hours_Worked__c = 10, Availability__c = availabilitYId ,Assignment__c = assignmentId,  Week__c = weekId ));           
        }
        return budgetList;
    }

    public static List<Project__c> generateProjects( Integer noOfProjects) {
        List<Project__c> projectList = new List<Project__c>();
        for(Integer i = 0; i < noOfProjects ; i++) {
            projectList.add(new Project__c(Name = 'TestProject ' + i));           
        }
        return projectList;
    }*/
    
    

   
    
}