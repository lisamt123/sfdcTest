global class ExpertAvailabilityBatch implements Database.Batchable<sObject> {
	
	String query = 'SELECT Id, ContactId FROM User WHERE ContactId != null AND IsActive = true AND Profile.Name like \'10K Delivery Partner%\'';
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<User> userList) {
   		Set<Id> contactIdSet = new Set<Id>();
		for(User selectedUser : userList) {
			contactIdSet.add(selectedUser.ContactId);
		}

		Integer currentWeekNumber 	= Integer.valueOf(DateTime.newInstance(Date.today(), Time.NewInstance(12,0,0,0)).format('w'));
		String currentYear 			= DateTime.newInstance(Date.today(), Time.NewInstance(12,0,0,0)).format('YYYY');
		List<Week__c> weekList 		= [SELECT Id, Week_Starts_On__c, Week_Number__c, Year__c 
										FROM Week__c 
										WHERE (Year__c =: currentYear AND Week_Number__c >=: currentWeekNumber) OR Year__c >: currentYear 
										ORDER BY Year__c ASC, Week_Number__c ASC LIMIT 24];
		List<Contact> contactList 	= [SELECT Id,
											(SELECT Id 
											FROM Availability__r 
											WHERE (Week__r.Year__c =: currentYear AND Week__r.Week_Number__c >=: currentWeekNumber) OR Week__r.Year__c >: currentYear 
											ORDER BY Week__r.Year__c ASC, Week__r.Week_Number__c ASC LIMIT 24)
							 			FROM Contact WHERE Id IN : contactIdSet];
		Map<String,Id> weekIdMap = new Map<String,Id>();
		if(weekList.size() < 24) {
			for(Integer count = weekList.size() ; count < 24 ;count++) {
				Integer weekNumber 	= Integer.valueOf(DateTime.newInstance(Date.today().addDays(count*7), Time.NewInstance(12,0,0,0)).format('w'));
				String year 		= DateTime.newInstance(Date.today().addDays(count*7), Time.NewInstance(12,0,0,0)).format('YYYY');
				weekList.add(newWeek(year,weekNumber));
			}
			upsert weekList;
		}

		for(Week__c week : weekList){
			weekIdMap.put(week.Year__c + week.Week_Number__c ,week.Id);
		}

		List<Availability__c> availabilityList = new List<Availability__c>();
		for(Contact selectedContact : contactList) {
			if(selectedContact.Availability__r.size() < 24 ) {
				for(Integer count = selectedContact.Availability__r.size() ; count < 24 ;count++) {
					Integer weekNumber 	= Integer.valueOf(DateTime.newInstance(Date.today().addDays(count*7), Time.NewInstance(12,0,0,0)).format('w'));
					String year 		= DateTime.newInstance(Date.today().addDays(count*7), Time.NewInstance(12,0,0,0)).format('YYYY');
					availabilityList.add(new Availability__c(Contact__c = selectedContact.Id,Week__c = weekIdMap.get(year + weekNumber)));
				}
			}
		}
		if(availabilityList.size() > 0)
			insert availabilityList;
	}

	public Week__c newWeek(String year,Integer week) {
        Week__c newWeek 			= new Week__c(Week_Number__c = week,Year__c = year);
        newWeek.Week_Starts_On__c 	= Date.newInstance(Integer.valueOf(year),1,1).toStartOfWeek().addDays(7 * week - 1).toStartOfWeek() + 1 ;
        newWeek.Week_Ends_On__c 	= newWeek.Week_Starts_On__c + 6;
        return newWeek;
    }
	
	global void finish(Database.BatchableContext BC) {
	}
	
}