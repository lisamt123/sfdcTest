public without sharing class ExpertAvailabilityController {
	@AuraEnabled
	public static ResultWrapper retrieveAvailability(String direction,String startDateString,String endDateString) {
		User currentUser 										= [SELECT ContactId FROM User WHERE Id =: UserInfo.getUserId()];
		List<Availability__c> availabilityList 					= new List<Availability__c>();
		List<AvailabilityWrapper> availabilityWrapperListFirst 	= new List<AvailabilityWrapper>();
		List<AvailabilityWrapper> availabilityWrapperListSecond = new List<AvailabilityWrapper>();

		Date startDate 	= startDateString == null ? Date.today().toStartOfWeek().addDays(1) : Date.valueOf(startDateString) ;
		Date endDate 	= endDateString == null ? startDate.addDays(55) : Date.valueOf(endDateString) ;
		
		if(direction == 'next') {
			startDate 	= endDate.addDays(1);
			endDate		= startDate.addDays(55);
		}
		else if(direction == 'previous') {
			endDate 	= startDate.addDays(-1);
			startDate	= endDate.addDays(-55);
		}

		Integer currentWeekNumber 	= Integer.valueOf(DateTime.newInstance(startDate, Time.NewInstance(12,0,0,0)).format('w'));
		String currentYear 			= DateTime.newInstance(startDate, Time.NewInstance(12,0,0,0)).format('YYYY');
		Boolean disablePrevious 	= false;
		Boolean disableNext 		= false;
		if(currentUser.ContactId != null) {
			availabilityList = [SELECT Id, Available_Hours__c, Contact__c, Week__r.Name, Week__r.Week_Starts_On__c, Week__r.Week_Ends_On__c, 
									Week__r.Week_Number__c, Forecasted_Hours__c, Hours_Worked_Rollup__c, Week__r.Year__c 
								FROM Availability__c 
								WHERE Contact__c =: currentUser.ContactId
								AND ((Week__r.Year__c =: currentYear AND Week__r.Week_Number__c >=: currentWeekNumber) OR Week__r.Year__c >: currentYear )
								ORDER BY Week__r.Year__c ASC, Week__r.Week_Number__c ASC LIMIT 16];
			if(availabilityList.size() > 0) {
				List<Availability__c> availabilityFirstRecord = [SELECT Id
																FROM Availability__c 
																WHERE Contact__c =: currentUser.ContactId
																ORDER BY Week__r.Year__c ASC, Week__r.Week_Number__c ASC LIMIT 1];
				List<Availability__c> availabilityLastRecord = [SELECT Id 
																FROM Availability__c 
																WHERE Contact__c =: currentUser.ContactId
																ORDER BY Week__r.Year__c DESC, Week__r.Week_Number__c DESC LIMIT 1];
				if(availabilityList[0].Id == availabilityFirstRecord[0].Id)
					disableNext = true;
				if(availabilityList[availabilityList.size() - 1].Id == availabilityLastRecord[0].Id)
					disablePrevious = true;

			}
			else {
				disablePrevious	= false;
		 		disableNext 	= false;
			}
		}
		Integer count = 0;
		for(Availability__c availability : availabilityList) {
			Integer monthNo = availability.Week__r.Week_Ends_On__c.month();
			if(availability.Available_Hours__c == null)
				availability.Available_Hours__c = 0 ;
			if(count < 8)
				availabilityWrapperListFirst.add(new AvailabilityWrapper(availability, monthNo));
			else
				availabilityWrapperListSecond.add(new AvailabilityWrapper(availability, monthNo));
			count++;
		}
		ResultWrapper result 					= new ResultWrapper();
		result.disableNext 						= disableNext;
		result.disablePrevious 					= disablePrevious;
		result.startDateString 					= startDate.year() + '-' + startDate.month() + '-' + startDate.day();
		result.endDateString 					= endDate.year() + '-' + endDate.month() + '-' + endDate.day();
		result.availabilityWrapperListFirst 	= availabilityWrapperListFirst;
		result.availabilityWrapperListSecond 	= availabilityWrapperListSecond;

		System.debug(result);
		return result;
	}

	public class AvailabilityWrapper {
		@AuraEnabled public Availability__c avail 	{get; set;}
		@AuraEnabled public Integer monthNumber 	{get; set;}

		AvailabilityWrapper(Availability__c avail, Integer monthNumber) {
			this.avail 			= avail;
			this.monthNumber 	= monthNumber;
		}
	}

	public class ResultWrapper {
		@AuraEnabled public String startDateString 										{get; set;}
		@AuraEnabled public String endDateString 										{get; set;}
		@AuraEnabled public Boolean disableNext											{get; set;}
		@AuraEnabled public Boolean disablePrevious 									{get; set;}
		@AuraEnabled public List<AvailabilityWrapper> availabilityWrapperListFirst 		{get; set;}
		@AuraEnabled public List<AvailabilityWrapper> availabilityWrapperListSecond 	{get; set;}
	}
}