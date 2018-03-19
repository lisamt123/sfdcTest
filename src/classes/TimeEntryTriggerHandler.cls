public without sharing class TimeEntryTriggerHandler {
    public static void updateBudgetHoursWorked(List<Time_Entry__c> timeEntryList , Boolean isNew) {
        Set<Id> budgetIdSet = new Set<Id>();
        for(Time_Entry__c item : timeEntryList) {
            if(item.Budget__c != null && isNew) {
                budgetIdSet.add(item.Budget__c);        
            }
            else if(item.Budget__c != null && !isNew) {
                if(((Time_Entry__c)Trigger.oldMap.get(item.Id)).Budget__c != item.Budget__c) {
                    budgetIdSet.add(item.Budget__c); 
                    if(((Time_Entry__c)Trigger.oldMap.get(item.Id)).Budget__c != null)
                        budgetIdSet.add(((Time_Entry__c)Trigger.oldMap.get(item.Id)).Budget__c);     
                }
                else if(((Time_Entry__c)Trigger.oldMap.get(item.Id)).Hours__c != item.Hours__c) 
                    budgetIdSet.add(item.Budget__c);        
            }
        }
        
        List<Budget__c > updateBudgetList = new List<Budget__c >();
        if(budgetIdSet.size() > 0) { 
            Map<String,Decimal> budgetHoursMap = new Map<String,Decimal>();
            for(Time_Entry__c timeEntry : [SELECT Name , Hours__c,Budget__c FROM Time_Entry__c WHERE Budget__c IN : budgetIdSet AND Hours__c != null AND Hours__c > 0]) {
                if(!budgetHoursMap.containsKey(timeEntry.Budget__c))
                    budgetHoursMap.put(timeEntry.Budget__c,0);
                Decimal totalHours = budgetHoursMap.get(timeEntry.Budget__c) + timeEntry.Hours__c;
                budgetHoursMap.put(timeEntry.Budget__c,totalHours);
            }   
            for(Budget__c budget : [SELECT Id,Name,Hours_Worked__c FROM Budget__c WHERE Id IN : budgetIdSet]) {
                budget.Hours_Worked__c = budgetHoursMap.get(budget.Id) ;
                updateBudgetList.add(budget);
            }  
        }   
        
        if(updateBudgetList.size() > 0){
            update updateBudgetList;
        }
    }
    
    // This Method is Added by AK to update Total Logged hour field on Story and Task Updation
    public static void updateLoggedHoursStoryAndTask(List<Time_Entry__c> timeEntryList , Boolean isNew) {
        Set<Id> storyIdSet = new Set<Id>();
        Set<Id> taskIdSet = new Set<Id>();
        
        for(Time_Entry__c item : timeEntryList) {
            if(isNew) {
                if(item.Story__c != null)
                    storyIdSet.add(item.Story__c); 
                if(item.Task__c!= null)
                    taskIdSet.add(item.Task__c);        
            }
            else if(!isNew) {
                if(((Time_Entry__c)Trigger.oldMap.get(item.Id)).Story__c  != item.Story__c ) {
                    if(item.Story__c != null)
                        storyIdSet.add(item.Story__c ); 
                    if(((Time_Entry__c)Trigger.oldMap.get(item.Id)).Story__c != null)
                        storyIdSet.add(((Time_Entry__c)Trigger.oldMap.get(item.Id)).Story__c);     
                }
                else if(((Time_Entry__c)Trigger.oldMap.get(item.Id)).Hours__c != item.Hours__c) {
                    if(item.Story__c != null)
                        storyIdSet.add(item.Story__c);        
                    if(((Time_Entry__c)Trigger.oldMap.get(item.Id)).Story__c != null)
                        storyIdSet.add(((Time_Entry__c)Trigger.oldMap.get(item.Id)).Story__c);     
                }
                
                if(((Time_Entry__c)Trigger.oldMap.get(item.Id)).Task__c != item.Task__c) {
                    if(item.Task__c != null)
                        taskIdSet.add(item.Task__c); 
                    if(((Time_Entry__c)Trigger.oldMap.get(item.Id)).Task__c != null)
                        taskIdSet.add(((Time_Entry__c)Trigger.oldMap.get(item.Id)).Task__c);     
                }
                else if(((Time_Entry__c)Trigger.oldMap.get(item.Id)).Hours__c != item.Hours__c)  {
                    if(item.Task__c != null)
                        taskIdSet.add(item.Task__c);        
                    if(((Time_Entry__c)Trigger.oldMap.get(item.Id)).Task__c != null)    
                        taskIdSet.add(((Time_Entry__c)Trigger.oldMap.get(item.Id)).Task__c);   
                }
            }
        }
        
        // Processing the Story record based on Time Entry Hour
        List<Story__c> updateStoryList = new List<Story__c>();
        if(storyIdSet.size() > 0) { 
            Map<String,Decimal> storyHoursMap = new Map<String,Decimal>();
            for(Time_Entry__c timeEntry : [SELECT Name , Hours__c,Story__c FROM Time_Entry__c WHERE Story__c IN : storyIdSet AND Hours__c != null AND Hours__c > 0]) {
                if(!storyHoursMap.containsKey(timeEntry.Story__c ))
                    storyHoursMap.put(timeEntry.Story__c ,0);
                Decimal totalHours = storyHoursMap.get(timeEntry.Story__c ) + timeEntry.Hours__c;
                storyHoursMap.put(timeEntry.Story__c ,totalHours);
            }  
            for(Story__C story : [SELECT Id,Name,Total_Hours_Logged__c FROM Story__c WHERE Id IN : storyIdSet]) {
                story.Total_Hours_Logged__c = storyHoursMap.get(story.Id) ;
                updateStoryList.add(story);
            } 
        }
        if(updateStoryList.size() > 0){
            update updateStoryList;
        }
        
        // Processing the Task record based on Time Entry Hour
        List<Task__c> updateTaskList = new List<Task__c>();
        if(taskIdSet.size() > 0) { 
            Map<String,Decimal> taskHoursMap = new Map<String,Decimal>();
            for(Time_Entry__c timeEntry : [SELECT Name , Hours__c,Task__c FROM Time_Entry__c WHERE Task__c IN : taskIdSet AND Hours__c != null AND Hours__c > 0]) {
                if(!taskHoursMap.containsKey(timeEntry.Task__c))
                    taskHoursMap.put(timeEntry.Task__c,0);
                Decimal totalHours = taskHoursMap.get(timeEntry.Task__c) + timeEntry.Hours__c;
                taskHoursMap.put(timeEntry.Task__c,totalHours);
            }  
            for(Task__c task : [SELECT Id,Name,Total_Hours_Logged__c FROM Task__c  WHERE Id IN : taskIdSet ]) {
                task.Total_Hours_Logged__c = taskHoursMap.get(task.Id) ;
                updateTaskList.add(task);
            } 
        }
        if(updateTaskList.size() > 0){
            update updateTaskList;
        }
    }
    
    public static void updateTimeEntries(List<Time_Entry__c> timeEntryList ,Boolean isNew) {
        //Map<Id,Time_Entry__c> timeEntryMap = new Map<Id,Time_Entry__c>([SELECT Id,Assignment__r.Resource__c FROM Time_Entry__c WHERE Id IN : timeEntryList]);
        Set<String> assignmentIdSet = new Set<String>();
        for(Time_Entry__c timeEntry: timeEntryList) {
            assignmentIdSet.add(timeEntry.Assignment__c);
        }
        Map<Id,Id> assignmentAndResourceMap = new Map<Id,Id>();

        for(Assignment__c assignment : [SELECT Id,Resource__c FROM Assignment__c WHERE Id IN : assignmentIdSet AND Resource__c != null]) {
            assignmentAndResourceMap.put(assignment.Id,assignment.Resource__c);
        }
        Set<Decimal> weekSet = new Set<Decimal>();
        Set<Id> contactIdSet = new Set<Id>();
        Map<String,String> contactAndWeekMap = new Map<String,string>();
        Map<String,Set<Integer>> yearAndWeekMap = new Map<String,Set<Integer>>();
        for(Time_Entry__c timeEntry: timeEntryList) {
            if(isNew || Trigger.oldMap.get(timeEntry.Id).get('Assignment__c') != timeEntry.Assignment__c || Date.valueOf(Trigger.oldMap.get(timeEntry.Id).get('Date__c')) != Date.valueOf(Trigger.newMap.get(timeEntry.Id).get('Date__c'))) {
                if(assignmentAndResourceMap.get(timeEntry.Assignment__c) != null) {
                    String year = DateTime.newInstance(timeEntry.Date__c, Time.NewInstance(12,0,0,0)).format('YYYY');
                    String week = DateTime.newInstance(timeEntry.Date__c, Time.NewInstance(12,0,0,0)).format('w');
                    if(!yearAndWeekMap.containsKey(year)) 
                        yearAndWeekMap.put(year,new Set<Integer>());
                    yearAndWeekMap.get(year).add(Integer.valueOf(week));
                    weekSet.add(Decimal.valueOf(week));
                    contactIdSet.add(assignmentAndResourceMap.get(timeEntry.Assignment__c));
                    contactAndWeekMap.put(assignmentAndResourceMap.get(timeEntry.Assignment__c) + '#' + year + week,timeEntry.Assignment__c);
                }
            }
        }

        List<Week__c> weekList = [SELECT Id,Week_Number__c,Year__c FROM Week__c WHERE Year__c IN : yearAndWeekMap.keyset() AND Week_Number__c IN : weekSet];

        Map<String,Set<Integer>> existingYearAndWeekMap = new Map<String,Set<Integer>>();
        Set<Id> weekIdSet = new Set<Id>();
        for(Week__c week : weekList) {
            if(!existingYearAndWeekMap.containsKey(week.Year__c)) 
                existingYearAndWeekMap.put(week.Year__c,new Set<Integer>());
            existingYearAndWeekMap.get(week.Year__c).add((Integer)week.Week_Number__c);
            weekIdSet.add(week.Id);
        }

        List<Week__c> weekListToBeInserted = new List<Week__c>();
        for(String year :yearAndWeekMap.keySet()) {
            if(!existingYearAndWeekMap.containsKey(year)) {
                for(Integer week : yearAndWeekMap.get(year)) {
                    weekListToBeInserted.add(newWeek(year,week));
                }
            }
            else {
                for(Integer week : yearAndWeekMap.get(year)) {
                    if(!existingYearAndWeekMap.get(year).contains(week)) {
                        weekListToBeInserted.add(newWeek(year,week));
                    }
                }
            }
        }

        if(weekListToBeInserted.size() > 0)
            insert weekListToBeInserted;

        List<Availability__c> availabilityList = [SELECT Id,Week__c,Week__r.Week_Number__c,Week__r.Year__c,Contact__c FROM Availability__c WHERE Week__c IN : weekIdSet AND Contact__c IN : contactIdSet];
        Set<String> contactAndAvailabilitySet = new Set<String>();
        for(Availability__c availability : availabilityList) {
            String key = availability.Contact__c + '#' + availability.Week__r.Year__c + String.valueOf(Integer.valueOf(availability.Week__r.Week_Number__c));
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

        for(String key : contactAndWeekMap.keySet()) {
            if(!contactAndAvailabilitySet.contains(key)) {
                availabilityListToInsert.add(new Availability__c(Contact__c = key.split('#')[0],Week__c = weekMap.get(key.split('#')[1])));
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

        Map<String,Budget__c> budgetIfoMap = new Map<String,Budget__c>();
        List<Budget__c> budgetList = [SELECT Id,Availability__c,Assignment__c,Week__c,Week__r.Week_Ends_On__c,Week__r.Week_Starts_On__c,Forecasted_Hours__c 
                                            ,Week__r.Year__c,Week__r.Week_Number__c
                                        FROM Budget__c 
                                        WHERE Availability__c IN : completeAvailabilityList 
                                            AND Week__c IN : completeWeekList];
        for(Budget__c budget : budgetList) {
            budgetIfoMap.put(budget.Availability__c + '' + budget.Assignment__c + '' + budget.Week__c,budget);
        }

        List<Budget__c> budgetListToBeInserted = new List<Budget__c>();
        for(String str : contactAndWeekMap.keySet()) {
            String weekAndYear = str.split('#')[1];
            if(availabilityMap.containsKey(str.split('#')[0] + '' + weekMap.get(weekAndYear))) {
                String key = availabilityMap.get(str.split('#')[0] + '' + weekMap.get(weekAndYear)) + contactAndWeekMap.get(str) + weekMap.get(weekAndYear) ;
                if(!budgetIfoMap.containsKey(key))
                    budgetListToBeInserted.add(new Budget__c(Forecasted_Hours__c = 0,Availability__c = availabilityMap.get(str.split('#')[0] + '' + weekMap.get(weekAndYear)) , Assignment__c = contactAndWeekMap.get(str),Week__c = weekMap.get(weekAndYear)));
            }
        }
        if(budgetListToBeInserted.size() > 0 ) {
            insert budgetListToBeInserted;
        }

        for(Budget__c budget : budgetListToBeInserted) {
            budgetIfoMap.put(budget.Availability__c + '' + budget.Assignment__c + '' + budget.Week__c,budget);
        }
        
        for(Time_Entry__c timeEntry: timeEntryList) {
            if(isNew || Trigger.oldMap.get(timeEntry.Id).get('Date__c') != timeEntry.Date__c || Trigger.oldMap.get(timeEntry.Id).get('Assignment__c') != timeEntry.Assignment__c) {
                String weekAndYear = DateTime.newInstance(timeEntry.Date__c, Time.NewInstance(12,0,0,0)).format('YYYYw');
                String key = availabilityMap.get(assignmentAndResourceMap.get(timeEntry.Assignment__c) + '' + weekMap.get(weekAndYear)) + timeEntry.Assignment__c  + weekMap.get(weekAndYear);
                if(budgetIfoMap.containsKey(key)) 
                    timeEntry.Budget__c = budgetIfoMap.get(key).Id;
            }
        }
    }

    public static Week__c newWeek(String year,Integer week) {
        Week__c newWeek = new Week__c(Week_Number__c = week,Year__c = year);
        newWeek.Week_Starts_On__c = Date.newInstance(Integer.valueOf(year),1,1).toStartOfWeek().addDays(7 * week - 1).toStartOfWeek() + 1 ;
        newWeek.Week_Ends_On__c = newWeek.Week_Starts_On__c + 6;
        return newWeek;
    }
}