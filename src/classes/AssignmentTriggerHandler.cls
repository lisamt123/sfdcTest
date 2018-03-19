/**
@Name           : AssignmentTriggerHandler
@Dated          : 24 June, 2016
@Author         :
@Description    : This class is Handler of AssignmentTrigger, used to share Projects with community user.   
*/
public class AssignmentTriggerHandler {
  
    private static Set<Id> oldContactIds;
    
    //to insert share records for new assignments.
    public static void processInsert(List<assignment__c> assignmentList) {
        insertNewShareRecords(assignmentList);
    }
    
    //to delete share records for deleting assignments
    public static void processDelete(List<Assignment__c> assignmentList) {
        oldContactIds = new set <Id>();
        Set<Id> projectIds = new Set<Id>();
        for(Assignment__c assignmentObj : assignmentList) {  
            if(assignmentObj.resource__c !=null) {                      
                projectIds.add(assignmentObj.project__c);
                oldContactIds.add(assignmentObj.resource__c);
            }           
        }
        //deleting sharing records
        if(projectIds.size()>0) {
            deleteShareRecords(projectIds);
        }
    }
    
    //to delete and to recreate sharing records
    private static void deleteShareRecords(Set<Id> projectIds) {
        Map<Id,Set<Id>> projectToContactMap =  new Map<Id,Set<Id>>();
        Set<Id> contactIds = new Set<Id>();
        Map<Id, Id> contactToUserMap = new Map<Id, Id>();
        Set<Id> userIds = new Set<Id>();
        List<Project__Share> shareRecordsToDelete = new List<Project__Share>();
        
        for(Assignment__c assignmentObj : [select resource__c, project__c,Recalculate_Sharing_on_Save__c from assignment__c
                                            where project__c in :projectIds and resource__c != null]) {
            
            contactIds.add(assignmentObj.resource__c);
            if(!projectToContactMap.containsKey(assignmentObj.project__c)) {
                projectToContactMap.put(assignmentObj.project__c, new Set<Id>());
            }
            projectToContactMap.get(assignmentObj.project__c).add(assignmentObj.resource__c);                               
        }
        
        for(Id projectId : projectToContactMap.keySet()) {
             contactIds.addAll(projectToContactMap.get(projectId));
        }
        //adding old contact
        contactIds.addAll(oldContactIds);
        
        if(contactIds.size()>0) {
            contactToUserMap = getUserIds(contactIds);
        }
        
        for(Id projectId : projectToContactMap.keySet()) {
            for(Id contactId : projectToContactMap.get(projectId)) {
                if(contactToUserMap.containsKey(contactId)) {
                 userIds.add(contactToUserMap.get(contactId));
                }
            }
        }
        
        //to delete old contact sharing
        for(Id oldContactId : oldContactIds) {
            if(contactToUserMap.containsKey(oldContactId )) {
             userIds.add(contactToUserMap.get(oldContactId));
            }
        }
        
        try{
            shareRecordsToDelete = [select id from project__share where parentid in :projectIds and userOrGroupId in :userIds]; 
            if(shareRecordsToDelete !=null && shareRecordsToDelete.size()>0)
                delete shareRecordsToDelete ; 
        }catch(Exception exp) {
            system.debug('exception -->' + exp.getMessage());
        }
        
        //if(projectToContactMap.size()>0) {
            List<Assignment__c> AssignmentList  = [select id, resource__c, Recalculate_Sharing_on_Save__c,project__c from assignment__c where project__c in: projectIds];
            if(AssignmentList !=null && AssignmentList.size()>0) {
                insertNewShareRecords(assignmentList);
            }
       // }     
    }
   
    public static void processUpdate(List<assignment__c> newAssignmentList) {       
        oldContactIds = new Set<Id>();   
        Set<Id> projectIds = new Set<Id>();
        Set<Id> assignmentIds = new Set<Id>();
        List<Time_Entry__c> timeEntryList = new List<Time_Entry__c>();
        for(Assignment__c assignmentObj : newAssignmentList) {
            if(assignmentObj.resource__c != ((Assignment__c)Trigger.oldMap.get(assignmentObj.id)).resource__c || assignmentObj.Recalculate_Sharing_on_Save__c) {
                projectIds.add(assignmentObj.project__c); 
                oldContactIds.add(((Assignment__c)Trigger.oldMap.get(assignmentObj.id)).resource__c);
            } 
            if(assignmentObj.Cost_Rate__c != null && assignmentObj.Cost_Rate__c != ((Assignment__c)Trigger.oldMap.get(assignmentObj.Id)).Cost_Rate__c){
                assignmentIds.add(assignmentObj.Id);
            }          
        }
        if(assignmentIds.size() > 0 ){
            for(Time_Entry__c timeEntry : [SELECT Id,Hourly_Cost_Rate__c FROM Time_Entry__c WHERE Assignment__c IN : assignmentIds]){
                timeEntryList.add(timeEntry);
            }
        }
        if(timeEntryList.size() > 0 ){
            update timeEntryList;
        }
        //creating sharing for updated contact
        if(projectIds.size()>0) {
            deleteShareRecords(projectIds);
        }    
    }
    
    //this method generates and return Instanct Project Share Record
    private static Project__share generateProjectShare(Id projectId, Id userOrGroupId) {
           Project__share projectRecord = new Project__share();
           projectRecord.ParentId = projectId;
           projectRecord.UserOrGroupId = userOrGroupId;
           projectRecord.AccessLevel = 'Read';
           projectRecord.RowCause = Schema.project__share.RowCause.Delivery_Employee__c;
           return projectRecord;
    }

    //this method return portal User ids of passed contacts
    private static Map<Id, Id> getUserIds(Set<Id> contactIds) {
        Map<Id, Id> contactToUserMap = new Map<Id, Id>();
      
        for(User userObj : [SELECT Id, ContactId 
                            FROM User 
                            WHERE ContactId IN: contactIds
                                  AND IsActive = true]) {
            contactToUserMap.put(userObj.contactId,userObj.id);
        }
        
        system.debug('contactToUserMap : ' + contactToUserMap);

        return contactToUserMap;
    }
    
    //to insert new share records for assignments
    private static void insertNewShareRecords(List<Assignment__c> assignmentList) {
    
        Set<Id> contactIds =  new Set<Id>();
        Map<Id, Id> contactToUserMap = new Map<Id, Id>();
        List<Project__Share> projectShareList = new List<Project__Share>();
        
        //fetching contact ids to get their users
        for(Assignment__c assignmentObj :  assignmentList) {
            if(assignmentObj.resource__c !=null) {
                contactIds.add(assignmentObj.resource__c);
            }
        }
        if(contactIds.size() > 0) {
            contactToUserMap = getUserIds(contactIds);  
        }
       
        Set<Id> assignmentIds = new Set<Id>();
        for(Assignment__c assignmentObj :  assignmentList) {
            if(assignmentObj.resource__c != null && contactToUserMap.containsKey(assignmentObj.resource__c)) {
                system.debug('Here is the Resource : ' + assignmentObj.resource__c);
                Id userId = contactToUserMap.get(assignmentObj.resource__c);
                system.debug('Found this User Id : ' + userId);
                if(userId != null) {
                    system.debug('Adding a Project Share');
                    projectShareList.add(generateProjectShare(assignmentObj.project__c, userId)); 
                }
            }
            assignmentIds.add(assignmentObj.id);
        }
        try{
            if(projectShareList != null && projectShareList.size()>0) {
                insert projectShareList;        
            }
                                    
            if(!projectShareList.isEmpty()) {

                set<Id> setUserIdsFromProjectShare = new set<Id>();
                set<Id> setUserIdsSharedWithTrekbin = new set<Id>();
                set<Id> setProjectShareParentID = new set<Id>();
                list<Project__c> lstProjectRecordsToUpdate = new list<Project__c>();
            
                for(Project__share objProjectShare : projectShareList) {    
                    
                    if(objProjectShare.RowCause == 'Delivery_Employee__c') {                
                        
                        setUserIdsFromProjectShare.add(objProjectShare.UserOrGroupId);
                    }
                }
            
                for(User objUser : [Select Id, ContactId, Contact.AccountId, Contact.Account.Name From User Where Id IN :setUserIdsFromProjectShare]) {
                    
                    if(objUser.Contact.Account.Name.contains('Trekbin')) {
                        
                        setUserIdsSharedWithTrekbin.add(objUser.Id);
                    }
                }
            
                for(Project__Share objProjectShare : projectShareList) {    
                    
                    if(setUserIdsSharedWithTrekbin.contains(objProjectShare.UserOrGroupId)) {
                        
                        lstProjectRecordsToUpdate.add(new Project__c(Id = objProjectShare.parentId, Shared_with_Trekbin__c = true));
                                        
                        setProjectShareParentID.add(objProjectShare.parentId);
                    }
                    else
                    {
                        if(!setProjectShareParentID.contains(objProjectShare.parentId)) {
                            
                            lstProjectRecordsToUpdate.add(new Project__c(Id = objProjectShare.parentId, Shared_with_Trekbin__c = false));
                        }
                    }
                }
                
                if(!lstProjectRecordsToUpdate.isEmpty()) {
                            
                    update lstProjectRecordsToUpdate;
                } 
            }
            //uncheck the checkbox of recalculating 
            if(assignmentIds.size()>0) { 
                setRecalculationToFalse(assignmentIds);
            }
        }catch(Exception exp) {
            system.debug('Exception--->' +  exp.getMessage());
        }   
    }
    
    //update checkbox status
    private static void setRecalculationToFalse(Set<Id> assignmentIds) {
        List<Assignment__c> assignmentList = new List<Assignment__c>();
        for(Assignment__c assignment : [select id,Recalculate_Sharing_on_Save__c from assignment__c where id in : assignmentIds]) {
            assignment.Recalculate_Sharing_on_Save__c = false;
            assignmentList.add(assignment);
        }
        update assignmentList;
    }  
    
    /* Use : If a Cost Rate or Billable Rate on an Assignment is changed (from some non-null value to a different non-null value, or from some non-null value to a null value),
             we should prevent that change from happening.
    **/
    /* public static void preventRateChangeIfTimeEntryExist() {
       //Get the new map of assignments updated
        Map<Id, sObject> newAssignmentMap = Trigger.newMap;
        
        //Get the old map of assignment updated
        Map<Id, sObject> oldAssignmentMap = Trigger.oldMap;
        
        //query all the time entry records which have parent in newMap so that error can be added to parent assignment
        List<AggregateResult> timeEntries = [Select Assignment__c parentAssignment FROM Time_Entry__c Where Assignment__c IN :newAssignmentMap.keySet() GROUP BY  Assignment__c];
        //timeEntries[0].get('parentAssignment')
        for(AggregateResult aggResult :timeEntries) {
            Id parentAssignmentId = (Id)aggResult.get('parentAssignment');
            //map will always have this key
            sObject newAssignment = newAssignmentMap.get(parentAssignmentId);
            sObject oldAssignment = oldAssignmentMap.get(parentAssignmentId);
            
            Boolean checkCostRateChange = (oldAssignment.get('Cost_Rate__c') != null && newAssignment.get('Cost_Rate__c') != null && (newAssignment.get('Cost_Rate__c') != oldAssignment.get('Cost_Rate__c'))) || 
                                          (oldAssignment.get('Cost_Rate__c') != null && newAssignment.get('Cost_Rate__c') == null);
            
            Boolean checkBillableRateChange = (oldAssignment.get('Rate__c') != null && newAssignment.get('Rate__c') != null && (newAssignment.get('Rate__c') != oldAssignment.get('Rate__c'))) || 
                                              (oldAssignment.get('Rate__c') != null && newAssignment.get('Rate__c') == null);                   
            
            //If a Cost Rate or Billable Rate on an Assignment is changed (from some non-null value to a different non-null value, or from some non-null value to a null value)
            if(checkCostRateChange || checkBillableRateChange) {
              String rateType = (checkCostRateChange && checkBillableRateChange)? 'Billable and Cost Rate' : (checkCostRateChange ? 'Cost Rate' : 'Billable Rate');
              String errorMsg = 'Time has already been logged against Assignment ' +
                                newAssignment.get('Name') + 
                                ', so you cannot change the ' +
                                rateType +
                                '. Please create a new Assignment instead.'; 
              newAssignment.addError(errorMsg); 
            }   
        }
    }*/

    public static void expertToExpertFeedback(List<Assignment__c> newAssignmentList)
    {
        Set<Id> closedAssignmentIdSet               = new Set<Id>();
        Set<Id> projectIdSet                        = new Set<Id>();
        List<Feedback__c> feedbackListToBeInserted  = new List<Feedback__c>();

        for(Assignment__c assignment : newAssignmentList)
        {
            if(assignment.Status__c == 'Closed' && ((Assignment__c)Trigger.oldMap.get(assignment.Id)).Status__c != 'Closed')
            {
                closedAssignmentIdSet.add(assignment.Id);
            }
        }
        List<Assignment__c> assignmentList = [SELECT Id, Project__c   
                                                FROM Assignment__c 
                                                WHERE Id 
                                                IN : closedAssignmentIdSet];

        for(Assignment__c assignment : assignmentList)
        {
            projectIdSet.add(assignment.Project__c);
        }

        List<Project__c> projectList = [SELECT Id, Status__c, (SELECT Id, Status__c, Do_Not_Send_Feedback_Survey__c, Project__c,  
                                                                        Project__r.Status__c, Project__r.Name, Resource__c, Resource__r.Name 
                                                                        FROM Assignments__r 
                                                                        WHERE Id 
                                                                        IN : closedAssignmentIdSet 
                                                                        OR Status__c = 'Active') 
                                        FROM Project__c 
                                        WHERE Id 
                                        IN : projectIdSet];

        for(Project__c project : projectList)
        {
            if(project.Status__c == 'Completed')
            {
                for(Assignment__c assignment : project.Assignments__r)
                {
                    if(! assignment.Do_Not_Send_Feedback_Survey__c)
                        for(Assignment__c assignment1 : project.Assignments__r)
                        {
                            if(assignment.Id != assignment1.Id)
                            {
                                Feedback__c feedback    = new Feedback__c();
                                feedback.Expert__c      = assignment.Resource__c;
                                feedback.Submitter__c   = assignment1.Resource__c;
                                feedback.Assignment__c  = assignment.Id;
                                feedbackListToBeInserted.add(feedback);
                            }
                        }
                }
            }
            else
            {
                for(Assignment__c assignment : project.Assignments__r)
                {
                    if(assignment.Status__c == 'Closed' && assignment.Do_Not_Send_Feedback_Survey__c == false)
                    {
                        for(Assignment__c assignment1 : project.Assignments__r)
                        {
                            if(assignment1.Status__c == 'Active')
                            {
                                Feedback__c feedback    = new Feedback__c();
                                feedback.Expert__c      = assignment.Resource__c;
                                feedback.Submitter__c   = assignment1.Resource__c;
                                feedback.Assignment__c  = assignment.Id;
                                feedbackListToBeInserted.add(feedback);
                            }
                        }
                    }
                }
            }
        }
        insert feedbackListToBeInserted;
    }
    public static void createWeekRecords(List<Assignment__c> newAssignmentList,Boolean isUpdate,Map<Id,Assignment__c> oldAssignmentMap) {
        Set<Decimal> weekSet = new Set<Decimal>();
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true];
        Map<String,Set<Integer>> yearWeekMap = new Map<String,Set<Integer>>();
        Map<String,Set<Integer>> yearWeekMapExisting = new Map<String,Set<Integer>>();
        Map<String,Set<AssignmentContactWeekWrapper>> assignmentContactWeekWrapperMap = new Map<String,Set<AssignmentContactWeekWrapper>>();
        Set<Id> contactIdSet = new Set<Id>();
        for(Assignment__c assignment : newAssignmentList) {
            Boolean flag = isUpdate ? assignment.Generate_Budget_Records__c ? true : false : true ;
            Date assignmentStartDate;
            if(!flag && assignment.Start_Date__c < Date.today() && oldAssignmentMap.get(assignment.Id).End_Date__c != null && oldAssignmentMap.get(assignment.Id).End_Date__c != assignment.End_Date__c ){
                assignmentStartDate = Date.today();
            }
            else {
                assignmentStartDate = assignment.Start_Date__c;
            }
            if(assignment.Start_Date__c != null && assignment.End_Date__c != null) {
                if(!isUpdate || oldAssignmentMap.get(assignment.Id).Start_Date__c != assignment.Start_Date__c || oldAssignmentMap.get(assignment.Id).End_Date__c != assignment.End_Date__c || oldAssignmentMap.get(assignment.Id).Planned_Hours__c != assignment.Planned_Hours__c || assignment.Generate_Budget_Records__c) {
                    Set<String> dateStringSet = new Set<String>();
                    for(Date assignmentDate = assignmentStartDate; assignmentDate < assignment.End_Date__c ; assignmentDate += 1 ) {
                        String week = DateTime.newInstance(assignmentDate.toStartOfWeek(), Time.NewInstance(12,0,0,0)).format('w');
                        String year = DateTime.newInstance(assignmentDate.toStartOfWeek(), Time.NewInstance(12,0,0,0)).format('YYYY');
                        if(!dateStringSet.contains(year + '---' + week + '----' + assignment.Id)) {
                            dateStringSet.add(year + '---' + week + '----' + assignment.Id);
                            if(!yearWeekMap.containsKey(year)) 
                                yearWeekMap.put(year,new Set<Integer>());
                            yearWeekMap.get(year).add(Integer.valueOf(week));
                            weekSet.add(Decimal.valueOf(week));

                            if(assignment.Resource__c != null) {
                                if(!assignmentContactWeekWrapperMap.containsKey(assignment.Id + '#' + assignment.Resource__c )) 
                                    assignmentContactWeekWrapperMap.put(assignment.Id + '#' + assignment.Resource__c ,new Set<AssignmentContactWeekWrapper>());
                                assignmentContactWeekWrapperMap.get(assignment.Id + '#' + assignment.Resource__c ).add(new AssignmentContactWeekWrapper(Integer.valueOf(week),year)); 
                            }
                        }
                    }
                    //assignment.Generate_Budget_Records__c = false;
                    contactIdSet.add(assignment.Resource__c);
                }
            }
        }
        
        List<Week__c> weekList = [SELECT Id,Week_Number__c,Year__c FROM Week__c WHERE Week_Number__c IN : weekSet AND Year__c  IN : yearWeekMap.keySet() ];
        Set<Id> weekIdSet = new Set<Id>();
        for(Week__c week : weekList) {
            if(!yearWeekMapExisting.containsKey(week.Year__c)) 
                yearWeekMapExisting.put(week.Year__c,new Set<Integer>());
            yearWeekMapExisting.get(week.Year__c).add((Integer)week.Week_Number__c);
            weekIdSet.add(week.Id);
        }

        List<Week__c> weekListToBeInserted = new List<Week__c>();
        for(String year : yearWeekMap.keySet()) {
            if(!yearWeekMapExisting.containsKey(year)) {
                for(Integer week : yearWeekMap.get(year)) {
                    weekListToBeInserted.add(newWeek(year,week));
                }
            }
            else {
                for(Integer week : yearWeekMap.get(year)) {
                    if(!yearWeekMapExisting.get(year).contains(week)) {
                        weekListToBeInserted.add(newWeek(year,week));
                    }
                }
            }
        }
        if(weekListToBeInserted.size() > 0)
            insert weekListToBeInserted;
                
        if(!assignmentContactWeekWrapperMap.isEmpty()) {
            List<Availability__c> availabilityList = [SELECT Id,Week__c,Week__r.Week_Number__c,Week__r.Year__c,Contact__c FROM Availability__c WHERE Week__c IN : weekIdSet AND Contact__c IN : contactIdSet];
            Set<String> contactAndAvailabilitySet = new Set<String>();
            for(Availability__c availability : availabilityList) {
                String key = availability.Contact__c + String.valueOf(Integer.valueOf(availability.Week__r.Week_Number__c)) + availability.Week__r.Year__c;
                contactAndAvailabilitySet.add(key);
            }

            List<Week__c> completeWeekList = new List<Week__c>();
            completeWeekList.addAll(weekListToBeInserted);
            completeWeekList.addAll(weekList);
            Map<String,String> weekMap = new Map<String,String>();
            for(Week__c week: completeWeekList) {
                weekMap.put(week.Year__c + String.valueOf(week.Week_Number__c),week.Id);
            }
            List<Availability__c> availabilityListToInsert = new List<Availability__c>();

            for(String assignment : assignmentContactWeekWrapperMap.keySet()) {
                for(AssignmentContactWeekWrapper assignmentContactWeekWrapper : assignmentContactWeekWrapperMap.get(assignment)) {
                    String key = assignment.split('#')[1] + String.valueOf(assignmentContactWeekWrapper.week) + assignmentContactWeekWrapper.year ;
                    if(!contactAndAvailabilitySet.contains(key)) {
                        availabilityListToInsert.add(new Availability__c(Contact__c = assignment.split('#')[1],Week__c = weekMap.get(assignmentContactWeekWrapper.year + String.valueOf(assignmentContactWeekWrapper.week))));
                    }
                }
            }
            if(availabilityListToInsert.size() > 0 ) {
                insert availabilityListToInsert;
            }

            List<Availability__c> completeAvailabilityList = new List<Availability__c>();
            completeAvailabilityList.addAll(availabilityListToInsert);
            completeAvailabilityList.addAll(availabilityList);

            Map<String,String> availabilityMap = new Map<String,String>();
            for(Availability__c availability : completeAvailabilityList) {
                availabilityMap.put(availability.Contact__c + '' + availability.Week__c,availability.Id);
            }
            //List<Budget__c> budgetList = [SELECT Id,Availability__c,Assignment__c,Week__c FROM Budget__c WHERE Availability__c IN : availabilityListToInsert AND Week__c IN : completeWeekList AND Assignment__c IN: newAssignmentList];
            Map<String,Budget__c> budgetIfoMap = new Map<String,Budget__c>();
            Map<String,List<Budget__c>> budgetHoursMap = new Map<String,List<Budget__c>>();
            for(Budget__c budget : [SELECT Id,Availability__c,Assignment__c,Week__c,Week__r.Week_Ends_On__c,Week__r.Week_Starts_On__c,Forecasted_Hours__c 
                                        ,Week__r.Year__c,Week__r.Week_Number__c
                                    FROM Budget__c 
                                    WHERE Availability__c IN : completeAvailabilityList 
                                        AND Week__c IN : completeWeekList 
                                        AND Assignment__c IN: newAssignmentList]) {
                budgetIfoMap.put(budget.Availability__c + '' + budget.Assignment__c + '' + budget.Week__c,budget);
            }

            for(Budget__c budget : [SELECT Id,Availability__c,Assignment__c,Week__c,Week__r.Week_Ends_On__c,Week__r.Week_Starts_On__c,Forecasted_Hours__c 
                                        ,Week__r.Year__c,Week__r.Week_Number__c
                                    FROM Budget__c 
                                    WHERE Assignment__c IN: newAssignmentList]) {
                if(!budgetHoursMap.containsKey(budget.Assignment__c))
                    budgetHoursMap.put(budget.Assignment__c,new List<Budget__c>());
                 budgetHoursMap.get(budget.Assignment__c).add(budget);   
            }

            List<Budget__c> budgetListToBeInserted = new List<Budget__c>();
            List<Budget__c> budgetListToBeDeleted = new List<Budget__c>();
            Boolean flag3 = false; 
            for(String assignmentAndContactString : assignmentContactWeekWrapperMap.keySet()) {
                Assignment__c assignment = (Assignment__c)Trigger.newMap.get(assignmentAndContactString.split('#')[0]);
                Boolean flag = isUpdate ? assignment.Generate_Budget_Records__c ? true : false : true ;
                Date assignmentStartDate;
                Boolean flag2 = false;
                if(!flag && assignment.Start_Date__c < Date.today() && oldAssignmentMap.get(assignment.Id).End_Date__c != null && oldAssignmentMap.get(assignment.Id).End_Date__c != assignment.End_Date__c){
                    assignmentStartDate = Date.today();
                    flag2 = true;
                }
                else {
                    assignmentStartDate = assignment.Start_Date__c;
                }
                Decimal planedHours = assignment.Planned_Hours__c == null ? 0 : assignment.Planned_Hours__c;
                Decimal oldPlanedHours = oldAssignmentMap != null ? oldAssignmentMap.get(assignment.Id).Planned_Hours__c == null ? 0 : oldAssignmentMap.get(assignment.Id).Planned_Hours__c : 0;
                Decimal hoursPerDay = planedHours/retrieveBussinessDaysBetweenTwoDates(assignment.Start_Date__c,assignment.End_Date__c + 1,bh);
                Decimal hoursUsedCurrentWeek = 0;
                if(flag2) {
                    Integer remainingDays = retrieveBussinessDaysBetweenTwoDates(assignmentStartDate,assignment.End_Date__c + 1,bh);
                    if(oldAssignmentMap != null && oldPlanedHours <= assignment.Planned_Hours__c && oldAssignmentMap.get(assignment.Id).End_Date__c <= assignment.End_Date__c) {
                        hoursPerDay = (planedHours - oldPlanedHours ) / remainingDays;
                        flag3 = true;
                    }
                    else {
                        Integer currentWeek = Integer.valueOf(DateTime.newInstance(Date.today().toStartOfWeek(), Time.NewInstance(12,0,0,0)).format('w'));
                        Integer currentYear = Integer.valueOf(DateTime.newInstance(Date.today().toStartOfWeek(), Time.NewInstance(12,0,0,0)).format('YYYY'));
                        Decimal pastWeekHours = 0;
                        if(budgetHoursMap.containsKey(assignment.Id)) {
                            for(Budget__c budget : budgetHoursMap.get(assignment.Id)) {
                                if(currentYear >= Integer.valueOf(budget.Week__r.Year__c) && currentWeek > Integer.valueOf(budget.Week__r.Week_Number__c)) {
                                    pastWeekHours += budget.Forecasted_Hours__c;
                                }
                                else if(currentYear == Integer.valueOf(budget.Week__r.Year__c) && currentWeek == Integer.valueOf(budget.Week__r.Week_Number__c)) {
                                    Decimal hoursPerDayForCurrentWeek = budget.Forecasted_Hours__c/retrieveBussinessDaysBetweenTwoDates(budget.Week__r.Week_Starts_On__c,budget.Week__r.Week_Ends_On__c,bh);
                                    Integer pastDays = retrieveBussinessDaysBetweenTwoDates(Date.today().toStartOfWeek(),Date.today(),bh);
                                    if(pastDays > 0) {
                                        hoursUsedCurrentWeek = hoursPerDayForCurrentWeek * pastDays;
                                        pastWeekHours += hoursUsedCurrentWeek;
                                    }
                                }
                            }
                        }
                        hoursPerDay = (planedHours - pastWeekHours ) / remainingDays;
                    }
                }

                for(AssignmentContactWeekWrapper assignmentContactWeekWrapper : assignmentContactWeekWrapperMap.get(assignmentAndContactString)) {
                    String weekAndYear = assignmentContactWeekWrapper.year + String.valueOf(assignmentContactWeekWrapper.week);
                    if(availabilityMap.containsKey(assignmentAndContactString.split('#')[1] + '' + weekMap.get(weekAndYear))) {
                        String key = availabilityMap.get(assignmentAndContactString.split('#')[1] + '' + weekMap.get(weekAndYear)) + assignmentAndContactString.split('#')[0] + weekMap.get(weekAndYear) ;
                        System.debug('budgetIfoMap.get(key)---'+budgetIfoMap.get(key)+'----key---'+key);
                        if(!budgetIfoMap.containsKey(key)) {
                            
                            Date startDate = Date.newInstance(Integer.valueOf(assignmentContactWeekWrapper.year),1,1).toStartOfWeek().addDays(7 * assignmentContactWeekWrapper.week - 1).toStartOfWeek() + 1;
                            Date endDate = startDate + 6;
                            Decimal budgetedHours = 0.0;
                            if(assignment.Start_Date__c > startDate) {
                                if(assignment.End_Date__c < endDate) {
                                    budgetedHours = retrieveBussinessDaysBetweenTwoDates(assignment.Start_Date__c,assignment.End_Date__c + 1,bh) * hoursPerDay;
                                } 
                                else {
                                    budgetedHours = retrieveBussinessDaysBetweenTwoDates(assignment.Start_Date__c,endDate,bh) * hoursPerDay;
                                }
                            }
                            else if(assignment.End_Date__c < endDate)
                                budgetedHours = retrieveBussinessDaysBetweenTwoDates(startDate,assignment.End_Date__c + 1,bh) * hoursPerDay;
                            else
                                budgetedHours = retrieveBussinessDaysBetweenTwoDates(startDate,endDate,bh) * hoursPerDay;
                            budgetListToBeInserted.add(new Budget__c(Forecasted_Hours__c = budgetedHours,Availability__c = availabilityMap.get(assignmentAndContactString.split('#')[1] + '' + weekMap.get(weekAndYear)) , Assignment__c = assignmentAndContactString.split('#')[0],Week__c = weekMap.get(weekAndYear)));
                        }
                        else {
                            
                            Date startDate = Date.newInstance(Integer.valueOf(assignmentContactWeekWrapper.year),1,1).toStartOfWeek().addDays(7 * assignmentContactWeekWrapper.week - 1).toStartOfWeek() + 1;
                            Date endDate = startDate + 6;
                            Decimal budgetedHours = 0.0;
                            if(weekAndYear == DateTime.newInstance(Date.today().toStartOfWeek(), Time.NewInstance(12,0,0,0)).format('YYYYw') && flag2) {
                                Integer remainingDays = retrieveBussinessDaysBetweenTwoDates(Date.today(),Date.today().toStartOfWeek() + 7,bh);
                                budgetedHours = hoursUsedCurrentWeek + (hoursPerDay * remainingDays);
                            }
                            else if(assignment.Start_Date__c > startDate) {
                                if(assignment.End_Date__c < endDate) {
                                    budgetedHours = retrieveBussinessDaysBetweenTwoDates(assignment.Start_Date__c,assignment.End_Date__c + 1,bh) * hoursPerDay;
                                }
                                else {
                                    budgetedHours = retrieveBussinessDaysBetweenTwoDates(assignment.Start_Date__c,endDate,bh) * hoursPerDay;
                                }
                            }
                            else if(assignment.End_Date__c < endDate)
                                budgetedHours = retrieveBussinessDaysBetweenTwoDates(startDate,assignment.End_Date__c + 1,bh) * hoursPerDay;
                            else
                                budgetedHours = retrieveBussinessDaysBetweenTwoDates(startDate,endDate,bh) * hoursPerDay;

                            if(flag3)
                                budgetIfoMap.get(key).Forecasted_Hours__c = budgetedHours + budgetIfoMap.get(key).Forecasted_Hours__c;
                            else
                                budgetIfoMap.get(key).Forecasted_Hours__c = budgetedHours;
                            budgetListToBeInserted.add(budgetIfoMap.get(key));
                        }
                    }
                }
                
                if(budgetHoursMap.containsKey(assignment.Id)) {
                    String week = DateTime.newInstance( ( assignment.End_Date__c - 1 ).toStartOfWeek(), Time.NewInstance(12,0,0,0)).format('w');
                    String year = DateTime.newInstance( ( assignment.End_Date__c - 1 ).toStartOfWeek(), Time.NewInstance(12,0,0,0)).format('YYYY');
                    String startYear = DateTime.newInstance( ( assignment.Start_Date__c).toStartOfWeek(), Time.NewInstance(12,0,0,0)).format('YYYY');
                    String startWeek = DateTime.newInstance( ( assignment.Start_Date__c).toStartOfWeek(), Time.NewInstance(12,0,0,0)).format('w');
                    for(Budget__c budget : budgetHoursMap.get(assignment.Id)) {
                        if(Integer.valueOf(year) == Integer.valueOf(budget.Week__r.Year__c) && Integer.valueOf(week) < Integer.valueOf(budget.Week__r.Week_Number__c)) {
                            budgetListToBeDeleted.add(budget);
                        }
                        else if(Integer.valueOf(year) < Integer.valueOf(budget.Week__r.Year__c)) {
                            budgetListToBeDeleted.add(budget);
                        }
                        else if(Integer.valueOf(startYear) > Integer.valueOf(budget.Week__r.Year__c) && assignment.Generate_Budget_Records__c) {
                            budgetListToBeDeleted.add(budget);
                        }
                        else if(Integer.valueOf(startYear) == Integer.valueOf(budget.Week__r.Year__c) && Integer.valueOf(startWeek) > Integer.valueOf(budget.Week__r.Week_Number__c) && assignment.Generate_Budget_Records__c) {
                            budgetListToBeDeleted.add(budget);
                        }
                    }
                }
            }
            if(budgetListToBeDeleted.size() > 0 ) {
                delete budgetListToBeDeleted;
            }
            if(budgetListToBeInserted.size() > 0 ) {
                upsert budgetListToBeInserted;
            }
        }
        if(isUpdate) {
            for(Assignment__c assignment : newAssignmentList) {
                assignment.Generate_Budget_Records__c = false;
            }
        }
    }

    public static Week__c newWeek(String year,Integer week) {
        Week__c newWeek = new Week__c(Week_Number__c = week,Year__c = year);
        newWeek.Week_Starts_On__c = Date.newInstance(Integer.valueOf(year),1,1).toStartOfWeek().addDays(7 * week - 1).toStartOfWeek() + 1 ;
        newWeek.Week_Ends_On__c = newWeek.Week_Starts_On__c + 6;
        return newWeek;
    }

    public static Integer retrieveBussinessDaysBetweenTwoDates(Date startDate,Date endDate,BusinessHours bh) {
        return Integer.valueOf(BusinessHours.diff(bh.Id, DateTime.newInstanceGMT(startDate,Time.NewInstance(0,0,0,0)), DateTime.newInstanceGMT(endDate,Time.NewInstance(23,0,0,0)))/28800000);
    }

    public static void validationForOverlapAssignmentDates(List<Assignment__c> newAssignmentList) {
        Set<String> projetSet = new Set<String>();
        for(Assignment__c asg : newAssignmentList){
            projetSet.add(asg.Project__c);
        }
        List<Assignment__c> oldCreatedAssignment = new List<Assignment__c>();
        oldCreatedAssignment = [SELECT Name, Start_Date__c, End_Date__c, Project__c , Role__c , Resource__c 
                                    FROM Assignment__c 
                                    WHERE Project__c IN : projetSet 
                                    AND Id NOT IN : newAssignmentList];
        Date validationCheckDate = date.newinstance(2018, 1, 1);                            
        for(Integer k = 0 ; k < newAssignmentList.size(); k++){
            for(Assignment__c old_asg : oldCreatedAssignment) {
                if(newAssignmentList[k].Project__c == old_asg.Project__c && newAssignmentList[k].Role__c == old_asg.Role__c && newAssignmentList[k].Resource__c == old_asg.Resource__c){
                    
                    if((newAssignmentList[k].Start_Date__c >= validationCheckDate) && (old_asg.Start_Date__c >= validationCheckDate))
                        if((newAssignmentList[k].Start_Date__c == old_asg.Start_Date__c) || (newAssignmentList[k].Start_Date__c == old_asg.End_Date__c))
                            newAssignmentList[k].Start_Date__c.addError('This Start Date overlaps with the dates of Assignment '+ old_asg.Name +'. Please choose an Start Date that doesn\'t overlap with the other Assignments for this Expert on this Project.');
                        else if((newAssignmentList[k].End_Date__c == old_asg.End_Date__c) || (newAssignmentList[k].End_Date__c == old_asg.Start_Date__c))
                            newAssignmentList[k].End_Date__c.addError('This End Date overlaps with the dates of Assignment '+ old_asg.Name +'. Please choose an End Date that doesn\'t overlap with the other Assignments for this Expert on this Project.');
                        else if(old_asg.Start_Date__c < newAssignmentList[k].Start_Date__c && old_asg.End_Date__c >= newAssignmentList[k].Start_Date__c)
                            newAssignmentList[k].Start_Date__c.addError('This Start Date overlaps with the dates of Assignment '+ old_asg.Name +'. Please choose an Start Date that doesn\'t overlap with the other Assignments for this Expert on this Project.');
                        else if(old_asg.Start_Date__c > newAssignmentList[k].Start_Date__c && old_asg.Start_Date__c <= newAssignmentList[k].End_Date__c)
                            newAssignmentList[k].End_Date__c.addError('This End Date overlaps with the dates of Assignment '+ old_asg.Name +'. Please choose an End Date that doesn\'t overlap with the other Assignments for this Expert on this Project.');
                }           
            }
            for(Integer i = 0 ; i < newAssignmentList.size(); i++) {
                if(k != i) {
                    if(newAssignmentList[k].Project__c == newAssignmentList[i].Project__c && newAssignmentList[k].Role__c == newAssignmentList[i].Role__c && newAssignmentList[k].Resource__c == newAssignmentList[i].Resource__c){
                        if((newAssignmentList[k].Start_Date__c >= validationCheckDate) && (newAssignmentList[i].Start_Date__c >= validationCheckDate))
                            if((newAssignmentList[k].Start_Date__c == newAssignmentList[i].Start_Date__c) || (newAssignmentList[k].Start_Date__c == newAssignmentList[i].End_Date__c))
                                newAssignmentList[k].Start_Date__c.addError('This Start Date overlaps with the dates of Assignment '+ newAssignmentList[i].Name +'. Please choose an Start Date that doesn\'t overlap with the other Assignments for this Expert on this Project.');
                            else if((newAssignmentList[k].End_Date__c == newAssignmentList[i].End_Date__c) || (newAssignmentList[k].End_Date__c == newAssignmentList[i].Start_Date__c))
                                newAssignmentList[k].End_Date__c.addError('This End Date overlaps with the dates of Assignment '+ newAssignmentList[i].Name +'. Please choose an End Date that doesn\'t overlap with the other Assignments for this Expert on this Project.');
                            else if(newAssignmentList[i].Start_Date__c < newAssignmentList[k].Start_Date__c && newAssignmentList[i].End_Date__c >= newAssignmentList[k].Start_Date__c)
                                newAssignmentList[k].Start_Date__c.addError('This Start Date overlaps with the dates of Assignment '+ newAssignmentList[i].Name +'. Please choose an Start Date that doesn\'t overlap with the other Assignments for this Expert on this Project.');
                            else if(newAssignmentList[i].Start_Date__c > newAssignmentList[k].Start_Date__c && newAssignmentList[i].Start_Date__c <= newAssignmentList[k].End_Date__c)
                                newAssignmentList[k].End_Date__c.addError('This End Date overlaps with the dates of Assignment '+ newAssignmentList[i].Name +'. Please choose an End Date that doesn\'t overlap with the other Assignments for this Expert on this Project.');
                    }
                }
            }
        }
    } 

    public class AssignmentContactWeekWrapper {
        public Integer week;
        public String year;

        public AssignmentContactWeekWrapper(Integer week,String year) {
            this.week = week;
            this.year = year;
        }
    }
}