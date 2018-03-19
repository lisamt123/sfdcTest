public without sharing class BudgetTriggerHandler {
	
    public static void updateTimeEntries(List<Budget__c> budgetList ) {
        budgetList = [SELECT Id,Assignment__c,Week__c,Week__r.Week_Ends_on__c,Week__r.Week_Starts_on__c 
                        FROM Budget__c WHERE Id IN : budgetList];
        Set<Id> weekIdSet = new Set<Id>();
        Set<Id> assignmentIdSet = new Set<Id>();
        Set<Date> dateSet = new Set<Date>();
        Map<String,Id> assignmentAndBudgetMap = new Map<String,Id>();
        for(Budget__c budget : budgetList) {
            if(budget.Week__c != null && budget.Assignment__c != null) {
                assignmentIdSet.add(budget.Assignment__c);  
                weekIdSet.add(budget.Week__c); 
                for(Date dateVar = budget.Week__r.Week_Starts_on__c ; dateVar <= budget.Week__r.Week_Ends_on__c ; dateVar += 1) {
                    dateSet.add(dateVar);
                    assignmentAndBudgetMap.put(budget.Assignment__c + '' + dateVar,budget.Id);
                }        
            }
        }

        List<Time_Entry__c> timeEntryList = new List<Time_Entry__c>();
        /*Change by A.S remove budget null condition check*/
        /*[SELECT Id, Budget__c,Date__c,Assignment__c FROM Time_Entry__c WHERE Date__c IN: dateSet AND Assignment__c IN : assignmentIdSet AND Budget__c != null]*/
        for(Time_Entry__c timeEntry: [SELECT Id, Budget__c,Date__c,Assignment__c FROM Time_Entry__c WHERE Date__c IN: dateSet AND Assignment__c IN : assignmentIdSet]) {
            if(assignmentAndBudgetMap.containsKey(timeEntry.Assignment__c  + '' +  timeEntry.Date__c)) {
                timeEntry.Budget__c = assignmentAndBudgetMap.get(timeEntry.Assignment__c  + '' +  timeEntry.Date__c);
                timeEntryList.add(timeEntry);
            }
        }
        if(timeEntryList.size() > 0)
            update timeEntryList;
    }

	/*public static void updateAvailabilityHours(List<Budget__c> budgetList , Boolean isNew) {
        Set<Id> weekIdSet = new Set<Id>();
        Set<Id> availabilityIdSet = new Set<Id>();
        for(Budget__c item : budgetList) {
            if(item.Week__c != null && isNew) {
                weekIdSet.add(item.Week__c);        
            }
            else if(item.Week__c != null && !isNew) {
                if(((Budget__c)Trigger.oldMap.get(item.Id)).Week__c != item.Week__c || ((Budget__c)Trigger.oldMap.get(item.Id)).Forecasted_Hours__c != item.Forecasted_Hours__c || ((Budget__c)Trigger.oldMap.get(item.Id)).Hours_Worked__c != item.Hours_Worked__c) 
                    weekIdSet.add(item.Week__c);        
            }
            if(item.Availability__c != null && isNew) {
                availabilityIdSet.add(item.Availability__c);        
            }
            else if(item.Availability__c != null && !isNew) {
                if(((Budget__c)Trigger.oldMap.get(item.Id)).Availability__c != item.Availability__c || ((Budget__c)Trigger.oldMap.get(item.Id)).Forecasted_Hours__c != item.Forecasted_Hours__c || ((Budget__c)Trigger.oldMap.get(item.Id)).Hours_Worked__c != item.Hours_Worked__c) 
                    availabilityIdSet.add(item.Availability__c);        
            }
        }
        if(weekIdSet.size() > 0 && availabilityIdSet.size() > 0) {
        	updateAvailability(weekIdSet ,availabilityIdSet);
        }
    }

    public static void updateAvailability(Set<Id> weekIdSet , Set<Id> availabilityIdSet) {
        
    	List<Availability__c> updateAvailabilityList = new List<Availability__c>();    	
    	Map<String,HoursWrapper> weekHourNewMap = new Map<String,HoursWrapper>();
    	if(weekIdSet.size() > 0 && availabilityIdSet.size() > 0){	
    		for(Budget__c budget : [SELECT Name , Forecasted_Hours__c, Hours_Worked__c ,Week__c,Availability__c FROM Budget__c WHERE Week__c IN : weekIdSet AND Availability__c IN : availabilityIdSet]) {				
					if(!weekHourNewMap.containsKey(budget.Availability__c + '-' + budget.Week__c )) 
						weekHourNewMap.put(budget.Availability__c + '-' + budget.Week__c,new HoursWrapper(0,0));
					
					Decimal hoursWorked = weekHourNewMap.get(budget.Availability__c + '-' + budget.Week__c).hoursWorked + (budget.Hours_Worked__c != null ? budget.Hours_Worked__c > 0 ? budget.Hours_Worked__c : 0 : 0);
					Decimal availableHours = weekHourNewMap.get(budget.Availability__c + '-' + budget.Week__c).availableHours + (budget.Forecasted_Hours__c != null ? budget.Forecasted_Hours__c > 0 ? budget.Forecasted_Hours__c : 0 : 0);
					weekHourNewMap.put(budget.Availability__c + '-' + budget.Week__c,new HoursWrapper(hoursWorked,availableHours));
            } 

			for(Availability__c avalibility : [SELECT Name , Available_Hours__c, Hours_Worked__c ,Week__c FROM Availability__c WHERE Week__c IN : weekIdSet AND Id IN : availabilityIdSet]) {					
				if(weekHourNewMap.containsKey(avalibility.Id + '-' + avalibility.Week__c)) {
					avalibility.Available_Hours__c = weekHourNewMap.get(avalibility.Id + '-' + avalibility.Week__c).availableHours;
					avalibility.Hours_Worked__c = weekHourNewMap.get(avalibility.Id + '-' + avalibility.Week__c).hoursWorked;
					updateAvailabilityList.add(avalibility);	
				}	
			}			
		}
		if(updateAvailabilityList.size() > 0){
			update updateAvailabilityList;
		}
    }

    public class HoursWrapper {
    	public Decimal hoursWorked;
    	public Decimal availableHours;

    	public HoursWrapper(Decimal hoursWorked,Decimal availableHours) {
    		this.hoursWorked = hoursWorked;
    		this.availableHours = availableHours;
    	}
    }*/
}