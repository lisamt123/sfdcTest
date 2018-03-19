public without sharing class LightningReportGenerationController 
{
    
    //Set to hold the project names so as to use it in query [R]
    static Set<String> setProjectNames = new Set<String>();
    //set to hold the project ids so as to use it in query
    static Set<Id> setProjectIds = new Set<Id>();
    //static variable for specific invoice time
    public static id invoiceId{get;set;}
        
    @AuraEnabled
    public static List<ProjectWrapper> getDefaultValues(String startDateString, String endDateString, String project,String assignIdSet) {
        Set<Id> tempassignIdSet;
        if(assignIdSet != null) 
            tempassignIdSet = (Set<Id>)JSON.deserialize(assignIdSet,Set<Id>.class);
        else 
            tempassignIdSet = new Set<Id>();
        Set<id> projectIdSet                    = new Set<id>();
        Set<Project__c> proList                 = new Set<Project__c>();
        Date selectedDate                       = Date.today();
        Date startDate                          = startDateString == null ? selectedDate.toStartOfMonth() : Date.valueOf(startDateString);
        Date endDate                            = endDateString == null ? startDate.addDays(date.daysInMonth(selectedDate.year() , selectedDate.month()) - 1) : Date.valueOf(endDateString);
        List<String> projectOptions             = new List<String>();
        List<AssignmentWrapper> wrappInner      = new List<AssignmentWrapper>();
        List<ProjectWrapper> wrappOuter         = new List<ProjectWrapper>();
        Map<id,List<Time_Entry__c>> innerMap    = new Map<id,List<Time_Entry__c>>();
        List<Project__c> projectList            = new List<Project__c>();
        List<User> userDetail                   = [SELECT Id,Name,AccountId,ContactId,UserRoleId,CompanyName FROM User WHERE Id =: UserInfo.getUserId()];
        List<Profile> userProfileDetail         = [SELECT Id,Name FROM Profile WHERE Id=:UserInfo.getProfileId()];
        Set<Id> contactIdSet                    = new Set<Id>();
        List<User> allUserList                  = new List<User>();
        list<UserRole> lowerManagerList         = new list<UserRole>();
        list<UserRole> userRoleList             = new list<UserRole>();
        //List<User> userDetail                   = [SELECT Id,Name,AccountId FROM User WHERE Id = '005R00000025J9k'];
        Map<Id, Integer> projectIdToAssignmentCountMap = new Map<Id, Integer>();
        String userRoleName = '';
        userRoleList = [SELECT Name, Id, ParentRoleId FROM UserRole where id =: userDetail[0].UserRoleId ];
        
        if(userRoleList != null && userRoleList.size() > 0)
            userRoleName = userRoleList[0].Name;
        if(userRoleName.toLowerCase().indexOfAny('manager') != -1 ) {
            lowerManagerList = [SELECT Id, ParentRoleId, Name FROM UserRole where ParentRoleId =: userDetail[0].UserRoleId ];
            System.debug('lowerManagerList>>>>>>>>>'+lowerManagerList);
            if(lowerManagerList != null && lowerManagerList.size() > 0) {
                contactIdSet.add(userDetail[0].ContactId);
                for(User allUsers : [SELECT Id,Name,AccountId,ContactId,UserRoleId,CompanyName FROM User WHERE UserRoleId In: lowerManagerList]) {
                    if(allUsers.CompanyName == userDetail[0].CompanyName)
                        contactIdSet.add(allUsers.ContactId);
                }
            }
            else
                contactIdSet.add(userDetail[0].ContactId);
        }
        else
            contactIdSet.add(userDetail[0].ContactId);
        
        if(project == null || project == '') {
            if(userDetail != null && userDetail.size() > 0 && userProfileDetail != null && userProfileDetail.size() > 0) {
                if( userDetail[0].AccountId != null && (userProfileDetail[0].Name).containsIgnoreCase('Client')) {
                    projectOptions.add('All Projects');
                    String queryString  = 'SELECT Id,Name FROM Project__c WHERE Account__c =\'' + userDetail[0].AccountId + '\'';
                    projectList = retrieveProjects(queryString,projectOptions);
                }
                else if(userDetail[0].ContactId != null && (userProfileDetail[0].Name).containsIgnoreCase('Delivery')) {
                    for(Assignment__c assignment : [select id,Project__c,Resource__c from Assignment__c where Resource__c In: contactIdSet])
                        setProjectIds.add(assignment.Project__c);
                    projectOptions.add('All Projects');
                    String queryString  = 'SELECT Id,Name FROM Project__c WHERE Id IN : setProjectIds';
                    projectList = retrieveProjects(queryString,projectOptions);
                }
                else if(userProfileDetail[0].Name == 'System Administrator') {
                    projectOptions.add('All Projects');
                    String queryString  = 'SELECT Id,Name FROM Project__c';
                    projectList = retrieveProjects(queryString,projectOptions);
                }
                if(projectList.size() <= 0) {
                    wrappOuter = new List<ProjectWrapper>();
                    List<String> dummyOptions = new List<String>();
                    dummyOptions.add('---None---');
                    wrappOuter.add(new ProjectWrapper(null, null, startDate, endDate, dummyOptions));
                    return wrappOuter;
                }
            }
        }
        else if(project == 'All Projects') {
            projectOptions.add('All Projects');
            if(userDetail[0].AccountId != null && (userProfileDetail[0].Name).containsIgnoreCase('Client')) {
                String queryString  = 'SELECT Id,Name FROM Project__c WHERE Account__c =\'' + userDetail[0].AccountId + '\'';
                projectList         = retrieveProjects(queryString,projectOptions);
            }
            else if(userDetail[0].ContactId != null && (userProfileDetail[0].Name).containsIgnoreCase('Delivery')) {
                for(Assignment__c assignment : [select id,Project__c,Resource__c,Project__r.Name from Assignment__c where Resource__c In : contactIdSet])
                    setProjectIds.add(assignment.Project__c);
                String queryString  = 'SELECT Id,Name FROM Project__c WHERE Id IN :setProjectIds';
                projectList = retrieveProjects(queryString,projectOptions);
            }
            else if(userProfileDetail[0].Name == 'System Administrator') {
                String queryString  = 'SELECT Id,Name FROM Project__c';
                projectList = retrieveProjects(queryString,projectOptions);
            }
        }
        else {
            /* Check if there are multiple project names in a string [R] */ 
            if(project.contains('#')) {
                //Iterate over all the project Names and hold the string in a set [R]
                //Add the project names into the set formed above [R] 
                for(String strProjectName : project.split('#'))
                    setProjectNames.add(strProjectName);
                //Form a query String   [R]
                String queryString  = 'SELECT Id, Name FROM Project__c WHERE Name IN :setProjectNames';
                projectList         = retrieveProjects(queryString, projectOptions);
            }
            else {
                String queryString  = 'SELECT Id,Name FROM Project__c WHERE Name =\'' + project + '\'';
                projectList         = retrieveProjects(queryString,projectOptions);
            }
        }

        if(projectList.size() > 0) {
            for(Project__c pro: projectList ) {
                projectIdSet.add(pro.id);
                proList.add(pro);
            }
        }
                                                     
        List<Assignment__c> assignmentList = new list<Assignment__c>();
        if(invoiceId != null) {
            assignmentList = [SELECT Id, Name, Resource__c, Assignment_Type__c, Project__c, Resource_Name__c,
                                (SELECT Id, Name, Date__c, Description__c, Task__r.Name, 
                                    Hourly_Rate__c, Hours__c, Invoice__r.Name , Story__r.Name  
                                FROM Time_Entries__r 
                                WHERE  Invoice__c =: invoiceId
                                ORDER BY Date__c DESC)
                            FROM Assignment__c 
                            WHERE Project__c IN: projectIdSet];
        }
        else {
            assignmentList = [SELECT Id, Name, Resource__c, Assignment_Type__c, Project__c, Resource_Name__c,
                                (SELECT Id, Name, Date__c, Description__c, Task__r.Name,  
                                    Hourly_Rate__c, Hours__c, Invoice__r.Name ,Story__r.Name 
                                FROM Time_Entries__r 
                                WHERE Date__c >=: startDate 
                                    AND Date__c <=: endDate
                                ORDER BY Date__c DESC)
                            FROM Assignment__c 
                            WHERE Project__c IN: projectIdSet];
        }
        
        for(Assignment__c assign : assignmentList) {
            system.debug('Working with this Assignment : ' + assign);
            system.debug('Working with this Assignment Time Entries : ' + assign.Time_Entries__r);

            if(assign.Time_Entries__r != null && assign.Time_Entries__r.size() > 0) {
                system.debug('Putting this one in the inner map!');
                innerMap.put(assign.id, assign.Time_Entries__r); 

                if(!projectIdToAssignmentCountMap.containsKey(assign.Project__c))
                    projectIdToAssignmentCountMap.put(assign.Project__c, 0);
                projectIdToAssignmentCountMap.put(assign.Project__c, projectIdToAssignmentCountMap.get(assign.Project__c) + 1);
            }
        }
            
        for(Project__c pro : [SELECT Id, Name, 
                                     (SELECT Id, Name, Resource_Name__c, Assignment_Type__c, Project__c,Role__c FROM Assignments__r)
                              FROM Project__c 
                              WHERE Id IN: projectIdSet]) {
            
            wrappInner = new List<AssignmentWrapper>();
            for(Assignment__c assign : pro.Assignments__r) {
                if(innerMap.containsKey(assign.Id)) {
                    if(assignIdSet == null)
                        wrappInner.add(new AssignmentWrapper(assign, innerMap.get(assign.Id),true));
                    else if(tempassignIdSet.contains(assign.Id))
                        wrappInner.add(new AssignmentWrapper(assign, innerMap.get(assign.Id),true));
                    else
                        wrappInner.add(new AssignmentWrapper(assign, innerMap.get(assign.Id),false));
                }
            }
            if(projectIdToAssignmentCountMap.containsKey(pro.Id) && projectIdToAssignmentCountMap.get(pro.Id) > 0)
                wrappOuter.add(new ProjectWrapper(pro,wrappInner,startDate,endDate,projectOptions));
        }
        if(wrappOuter.size() < 1)
            wrappOuter.add(new ProjectWrapper(new Project__c(),new List<AssignmentWrapper>(),startDate,endDate,projectOptions));
        return wrappOuter;
    }

    public static List<Project__c> retrieveProjects( String queryString,List<String> projectOptions  ) {
        List<Project__c> projectList = (List<Project__c>)Database.query(queryString);
        //projectOptions.add('All Projects');
        for(Project__c pro : projectList)
            projectOptions.add(pro.Name);
        return projectList;
    }
    
    public class AssignmentWrapper {
        @AuraEnabled public Assignment__c  assignment       {get;set;}
        @AuraEnabled public List<Time_Entry__c> entryList   {get;set;}
        @AuraEnabled public Boolean flag                    {get;set;}
        @AuraEnabled public Decimal totalTime               {get;set;}
        @AuraEnabled public String communityUrl             {get;set;}

        public AssignmentWrapper(Assignment__c  assignment, List<Time_Entry__c> entryList,Boolean flg) {
            this.assignment     = assignment;
            if(flg)
                this.entryList  = entryList;
            else
                this.entryList  = new List<Time_Entry__c>();
            this.flag           = flg;
            Decimal totalTime   = 0.0;
            for(Time_Entry__c timeEntry : entryList)
                totalTime += timeEntry.Hours__c != null ? timeEntry.Hours__c : 0.0;
            this.totalTime = totalTime;
            communityUrl = Site.getPathPrefix().split('/s')[0];
        }
    }
    
    public class ProjectWrapper {
        @AuraEnabled public Project__c project                  {get;set;} 
        @AuraEnabled public List<AssignmentWrapper> wrappList   {get;set;} 
        @AuraEnabled public List<String> projectOption          {get;set;} 
        @AuraEnabled public Date staretDate                     {get;set;} 
        @AuraEnabled public Date endDate                        {get;set;} 
        @AuraEnabled public Decimal totalTime                   {get;set;}
    
        public ProjectWrapper(Project__c pro, List<AssignmentWrapper> wrappList, Date sDate, Date lDate, List<String> Options) {
            this.project        = pro;
            this.wrappList      = wrappList;
            this.staretDate     = sDate;
            this.endDate        = lDate;
            this.projectOption  = Options;
            Decimal totalTime   = 0;
            if(wrappList != null && wrappList.size() > 0 ) {
                for(AssignmentWrapper asWrap : wrappList)
                    totalTime += asWrap.totalTime;
                this.totalTime = totalTime;
            }
        }
    }
}