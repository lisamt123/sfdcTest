global class ClosedWonProcessController {

	@AuraEnabled
	public static OpportunityWrapper getClosedWonOpportunity(Id recId) {
		Opportunity oppRecord 	= [SELECT CloseDate, AccountId, Amount, Type, LeadSource, StageName, Start_Date__c, Account_Tier__c, Account.Payment_Terms__c, 
										Is_Closed_Through_Process__c,RecordTypeId,Agreement_Generated__c, End_Date__c, Account.Primary_Billing_Contact__c 
									FROM Opportunity 
									WHERE Id =:recId];

		List<PickValWrap> opportunityTypePickValues 			= new List<PickValWrap>();
		List<PickValWrap> opportunityLeadSourcePickValues 		= new List<PickValWrap>();
	   	Schema.DescribeFieldResult fieldResult 					= Opportunity.Account_Tier__c.getDescribe();
	   	List<Schema.PicklistEntry> ple 							= fieldResult.getPicklistValues();

	   	for(Schema.PicklistEntry f : ple) {
	   		if(f.getLabel() == oppRecord.Account_Tier__c)
	      		opportunityTypePickValues.add(new PickValWrap(f.getLabel(), f.getValue(), true));
	      	else
	      		opportunityTypePickValues.add(new PickValWrap(f.getLabel(), f.getValue(), false));
	   	}

	   	Schema.DescribeFieldResult fieldResult1 				= Account.Payment_Terms__c.getDescribe();
	   	List<Schema.PicklistEntry> ple1							= fieldResult1.getPicklistValues();

	   	for(Schema.PicklistEntry f1 : ple1) {
	   		if(f1.getLabel() == oppRecord.Account.Payment_Terms__c)
	      		opportunityLeadSourcePickValues.add(new PickValWrap(f1.getLabel(), f1.getValue(), true));
	      	else
	      		opportunityLeadSourcePickValues.add(new PickValWrap(f1.getLabel(), f1.getValue(), false));
	   	}

	   	OpportunityWrapper oppWrapRec 	= new OpportunityWrapper();
	   	oppWrapRec.oppRec 				= oppRecord;
	   	oppWrapRec.oppType 				= opportunityTypePickValues;
	   	oppWrapRec.oppLeadSource 		= opportunityLeadSourcePickValues;

		return oppWrapRec;
	}

	@AuraEnabled
	public static List<AgreementWrapper> getClosedWonOpportunityAggreement(Id recId, Id accId) {
		List<AgreementWrapper> agreementWrapperList = new List<AgreementWrapper>();
		for(Agreement__c agreementRecord : [SELECT Id, Name, Status__c 
												FROM Agreement__c 
												WHERE  Status__c = 'Active' 
												AND Account__c =:accId]) {
			agreementWrapperList.add(new AgreementWrapper(agreementRecord, false));
		}
		return agreementWrapperList;
	}

	@AuraEnabled
	public static List<Project_Agreement__c> retriveProject(Id agreement_Id) {
		List<Project_Agreement__c> projectRecord = [SELECT Id, Name, Project__r.Name 
													FROM Project_Agreement__c 
													WHERE  Agreement__c =:agreement_Id];
		return projectRecord;
	}

	@AuraEnabled
	public static List<AssignmentWrapper> retriveProjectAssigment(String recId, List<Id> agreementIdList, String agreementEffectiveDate, String agreementExpireDate) {
		List<AssignmentWrapper> assignmentRecord 	= new List<AssignmentWrapper>();
		Set<Id> projectIdSet 						= new Set<Id>();
		Set<String> roleSet 						= new Set<String>();
		agreementEffectiveDate 						= agreementEffectiveDate.replace('\"', '');
		agreementExpireDate 						= agreementExpireDate.replace('\"', '');
		Date effectiveDate 							= Date.newInstance(Integer.valueOf(agreementEffectiveDate.split('-')[0]), Integer.valueOf(agreementEffectiveDate.split('-')[1]), Integer.valueOf(agreementEffectiveDate.split('-')[2]));
		Date expireDate 							= Date.newInstance(Integer.valueOf(agreementExpireDate.split('-')[0]), Integer.valueOf(agreementExpireDate.split('-')[1]), Integer.valueOf(agreementExpireDate.split('-')[2]));
		for(Project_Agreement__c projectAgreement : [SELECT Project__c, Project__r.id, Project__r.Name 
														FROM Project_Agreement__c 
														WHERE  Agreement__c IN :agreementIdList]) {
			projectIdSet.add(projectAgreement.Project__c);
		}

        List<String> roleList 						= new List<String>();
        roleList.add('');
        for(Rate_Card__c rateCardRec : [SELECT Id, Role__c, Region__c 
										FROM Rate_Card__c 
										WHERE Opportunity__c =: recId]) {
			roleSet.add(rateCardRec.Role__c + ' - ' + rateCardRec.Region__c);
		}
		roleList.addAll(roleSet);

		Map<Id, Date> projectIdToEndDateMap 		= new Map<Id,Date>();
		for(Project__c projectRec : [SELECT Id, End_Date__c FROM Project__c WHERE Id IN: projectIdSet]) {
			projectIdToEndDateMap.put(projectRec.Id, projectRec.End_Date__c);
		}

		for(Assignment__c assign : [SELECT Id, Name, Role__c, Project__c, Billable__c, Project__r.Name, Status__c, Planned_Hours__c, Total_Number_of_Hours__c, 
										Do_Not_Send_Feedback_Survey__c, Cost_Rate__c, Resource__c, End_Date__c, Start_Date__c, Generate_Budget_Records__c,Region__c 
									FROM Assignment__c 
									WHERE Project__c IN :projectIdSet 
									AND (Status__c = 'Active' OR Status__c = 'Projected') 
									ORDER BY Project__r.Name]) {
			assignmentRecord.add(new AssignmentWrapper(assign, roleList, effectiveDate, (expireDate < projectIdToEndDateMap.get(assign.Project__c) ? expireDate : projectIdToEndDateMap.get(assign.Project__c)), roleSet.contains(assign.Role__c + ' - ' + assign.Region__c) ? assign.Role__c + ' - ' + assign.Region__c : ''));
		}
		assignmentRecord.sort();
		return assignmentRecord;
	}

	@AuraEnabled
	public static String createNewAgreementAndRates(String recId, String agreementEffectiveDate, String agreementExpirationDate, List<Id> agreementIdList, Opportunity oppRec) {
		agreementEffectiveDate 				= agreementEffectiveDate.replace('\"', '');
		agreementExpirationDate 			= agreementExpirationDate.replace('\"', '');
		List<Rate__c> rateList 				= new List<Rate__c>();
		List<Project_Agreement__c> pAgrList = new List<Project_Agreement__c>();
		Set<Id> projectIdSet 				= new Set<Id>();
		List<Opportunity> oppList 			= [SELECT Id, AccountId, Account.Name, Account_Tier__c, Amount FROM Opportunity WHERE Id =: recId];
		List<Account> accountList 			= [SELECT Id, Current_Tier__c FROM Account WHERE Id =: oppList[0].AccountId];
		accountList[0].Current_Tier__c 		= oppList[0].Account_Tier__c;
		Agreement__c agreementRec 			= new Agreement__c();
		
		if(oppRec.RecordTypeId == Constants.RECORDTYPEID_OPPORTUNITY_MSA) {
			agreementRec.RecordTypeId 		= Constants.RECORDTYPEID_AGREEMENT_MSA;
			agreementRec.Name 				= oppList[0].Account.Name + ' - ' + 'MSA' + ' - ';
		}
		else {
			agreementRec.RecordTypeId 		= Constants.RECORDTYPEID_AGREEMENT_DELIVERYPARTER;
			agreementRec.Name 				= oppList[0].Account.Name + ' - ' + 'Time & Materials SOW' + ' - ';
		}
		agreementRec.Name 					+= fetchMonthName(Integer.valueOf(agreementEffectiveDate.split('-')[1])) + ' ' + agreementEffectiveDate.split('-')[0] +
												' to ' + fetchMonthName(Integer.valueOf(agreementExpirationDate.split('-')[1])) + ' ' + agreementExpirationDate.split('-')[0];
		agreementRec.Effective_Date__c 		= Date.newInstance(Integer.valueOf(agreementEffectiveDate.split('-')[0]), Integer.valueOf(agreementEffectiveDate.split('-')[1]), Integer.valueOf(agreementEffectiveDate.split('-')[2]));
		agreementRec.Valid_Through__c 		= Date.newInstance(Integer.valueOf(agreementExpirationDate.split('-')[0]), Integer.valueOf(agreementExpirationDate.split('-')[1]), Integer.valueOf(agreementExpirationDate.split('-')[2]));
		agreementRec.Account__c 			= oppList[0].AccountId;
		agreementRec.Status__c 				= 'Active';
		agreementRec.Tier__c 				= oppList[0].Account_Tier__c;
		agreementRec.Budget__c 				= oppList[0].Amount;
		agreementRec.Opportunity__c 		= oppList[0].Id;
		insert agreementRec;

		for(Rate_Card__c rateCardRec : [SELECT Id, Opportunity__c, Role__c, Assignment_Type__c, Hourly_Rate__c, Region__c   
										FROM Rate_Card__c 
										WHERE Opportunity__c =: recId]) {
			Rate__c rateRec 				= new Rate__c();
			rateRec.Name 					= rateCardRec.Role__c + ' - ' +  (rateCardRec.Region__c != null ? (rateCardRec.Region__c + ' - '):'') +  rateCardRec.Assignment_Type__c + ' - $' + rateCardRec.Hourly_Rate__c;
			rateRec.Role__c 				= rateCardRec.Role__c;
			rateRec.Assignment_Type__c 		= rateCardRec.Assignment_Type__c;
			rateRec.Hourly_Rate__c 			= rateCardRec.Hourly_Rate__c;
			rateRec.Region__c 				= rateCardRec.Region__c;
			rateRec.Agreement__c 			= agreementRec.Id;
			rateList.add(rateRec);
		}
		if(!rateList.isEmpty()) {
			insert rateList;
		}
		oppRec.Is_Closed_Through_Process__c 		= true; 
		oppRec.Agreement_Generated__c 				= true;
		update oppRec;
		update accountList;
		return 'The Agreement has been successfully created.';
	}

	@AuraEnabled
	public static String replaceAgreementsAndAssignments(String recId, String agreementEffectiveDate, String agreementExpirationDate, List<Id> agreementIdList, String wrapperListJSON, Opportunity oppRec) {
		agreementEffectiveDate 				= agreementEffectiveDate.replace('\"', '');
		agreementExpirationDate 			= agreementExpirationDate.replace('\"', '');
		List<AssignmentWrapper> assignWrap 	= (List<AssignmentWrapper>)JSON.deserialize(wrapperListJSON, List<AssignmentWrapper>.class);
		List<Assignment__c> oldAssignList 	= new List<Assignment__c>();
		List<Assignment__c> newAssignList 	= new List<Assignment__c>();
		List<Rate__c> rateList 				= new List<Rate__c>();
		Map<String, Id> newRateRoleToIdMap	= new Map<String, Id>();
		List<Project_Agreement__c> pAgrList = new List<Project_Agreement__c>();
		Set<Id> projectIdSet 				= new Set<Id>();
		List<Opportunity> oppList 			= [SELECT Id, AccountId, Account.Name, Account_Tier__c, Amount FROM Opportunity WHERE Id =: recId];
		List<Account> accountList 			= [SELECT Id, Current_Tier__c FROM Account WHERE Id =: oppList[0].AccountId];
		accountList[0].Current_Tier__c 		= oppList[0].Account_Tier__c;
		Agreement__c agreementRec 			= new Agreement__c();
		
		if(oppRec.RecordTypeId == Constants.RECORDTYPEID_OPPORTUNITY_MSA) {
			agreementRec.RecordTypeId 		= Constants.RECORDTYPEID_AGREEMENT_MSA;
			agreementRec.Name 				= oppList[0].Account.Name + ' - ' + 'MSA' + ' - ';
		}
		else {
			agreementRec.RecordTypeId 		= Constants.RECORDTYPEID_AGREEMENT_DELIVERYPARTER;
			agreementRec.Name 				= oppList[0].Account.Name + ' - ' + 'Time & Materials SOW' + ' - ';
		}
		agreementRec.Name 					+= fetchMonthName(Integer.valueOf(agreementEffectiveDate.split('-')[1])) + ' ' + agreementEffectiveDate.split('-')[0] +
												' to ' + fetchMonthName(Integer.valueOf(agreementExpirationDate.split('-')[1])) + ' ' + agreementExpirationDate.split('-')[0];	
		agreementRec.Effective_Date__c 		= Date.newInstance(Integer.valueOf(agreementEffectiveDate.split('-')[0]), Integer.valueOf(agreementEffectiveDate.split('-')[1]), Integer.valueOf(agreementEffectiveDate.split('-')[2]));
		agreementRec.Valid_Through__c 		= Date.newInstance(Integer.valueOf(agreementExpirationDate.split('-')[0]), Integer.valueOf(agreementExpirationDate.split('-')[1]), Integer.valueOf(agreementExpirationDate.split('-')[2]));
		agreementRec.Account__c 			= oppList[0].AccountId;
		agreementRec.Status__c 				= 'Active';
		agreementRec.Tier__c 				= oppList[0].Account_Tier__c;
		agreementRec.Budget__c 				= oppList[0].Amount;
		agreementRec.Opportunity__c 		= oppList[0].Id;
		insert agreementRec;

		for(Rate_Card__c rateCardRec : [SELECT Id, Opportunity__c, Role__c, Assignment_Type__c, Hourly_Rate__c, Region__c  
										FROM Rate_Card__c 
										WHERE Opportunity__c =: recId]) {
			Rate__c rateRec 				= new Rate__c();
			rateRec.Name 					= rateCardRec.Role__c + ' - ' +  (rateCardRec.Region__c != null ? (rateCardRec.Region__c + ' - '):'') +  rateCardRec.Assignment_Type__c + ' - $' + rateCardRec.Hourly_Rate__c;
			rateRec.Role__c 				= rateCardRec.Role__c;
			rateRec.Assignment_Type__c 		= rateCardRec.Assignment_Type__c;
			rateRec.Hourly_Rate__c 			= rateCardRec.Hourly_Rate__c;
			rateRec.Region__c 				= rateCardRec.Region__c;
			rateRec.Agreement__c 			= agreementRec.Id;
			rateList.add(rateRec);
		}
		if(!rateList.isEmpty()) {
			insert rateList;
		}
		for(Rate__c rate : rateList) {
			newRateRoleToIdMap.put(rate.Role__c + ' - ' + rate.Region__c, rate.Id);
		}
		if(!agreementIdList.isEmpty()) {
			for(Project_Agreement__c projectAgg : [SELECT Id, Project__c 
													FROM Project_Agreement__c 
													WHERE Agreement__c IN : agreementIdList 
													AND Project__r.Status__c = 'Open']) {
				projectIdSet.add(projectAgg.Project__c);
			}
			for(Id projectId : projectIdSet) {
				Project_Agreement__c projAgrRec = new Project_Agreement__c();
				projAgrRec.Agreement__c 		= agreementRec.Id;
				projAgrRec.Project__c 			= projectId;
				pAgrList.add(projAgrRec);
			}
			if(!pAgrList.isEmpty()) {
				insert pAgrList;
			}

			for(AssignmentWrapper assignWrapRec : assignWrap) {
				System.debug(assignWrapRec.endDate);
				Assignment__c assignRec 		= new Assignment__c();
				if(assignWrapRec.assignment.Planned_Hours__c == null)
					assignWrapRec.assignment.Planned_Hours__c = 0;
				if(assignWrapRec.effectiveDate <= Date.today())
					assignRec.Status__c 		= 'Active';
				else
					assignRec.Status__c 		= 'Projected';
				assignRec.Start_Date__c 		= assignWrapRec.effectiveDate;
				assignRec.End_Date__c 			= assignWrapRec.endDate;
				assignRec.Role__c 				= (assignWrapRec.selectedRole).split('-')[0].trim();
				assignRec.Region__c 			= (assignWrapRec.selectedRole).split('-')[1].trim();
				assignRec.Assignment_Type__c 	= 'Time & Materials';
				if(oppRec.RecordTypeId == Constants.RECORDTYPEID_OPPORTUNITY_MSA)
					assignRec.Rate__c 				= newRateRoleToIdMap.get(assignWrapRec.selectedRole);
				assignRec.Project__c 			= assignWrapRec.assignment.Project__c;
				assignRec.Resource__c 			= assignWrapRec.assignment.Resource__c;
				assignRec.Billable__c 			= assignWrapRec.assignment.Billable__c;
				assignRec.Planned_Hours__c 		= assignWrapRec.assignment.Planned_Hours__c - assignWrapRec.assignment.Total_Number_of_Hours__c;
				assignRec.Cost_Rate__c 			= assignWrapRec.assignment.Cost_Rate__c;
				assignRec.Generate_Budget_Records__c = true;
				newAssignList.add(assignRec);

				assignWrapRec.assignment.Do_Not_Send_Feedback_Survey__c = true;
				assignWrapRec.assignment.Planned_Hours__c 				= assignWrapRec.assignment.Total_Number_of_Hours__c;
				assignWrapRec.assignment.Generate_Budget_Records__c 	= true;
				assignWrapRec.assignment.End_Date__c 					= (oppRec.Start_Date__c).addDays(-1);
				assignWrapRec.assignment.Automatically_Close__c 		= true;
				if(assignWrapRec.assignment.End_Date__c < Date.today() || assignWrapRec.assignment.Status__c == 'Projected') {
					assignWrapRec.assignment.Status__c 					= 'Closed';
				} else {
					assignWrapRec.assignment.Status__c 					= 'Active';
				}
				oldAssignList.add(assignWrapRec.assignment);
			}

			if(!oldAssignList.isEmpty())
				update oldAssignList;
			if(!newAssignList.isEmpty())
				insert newAssignList;
		}
		oppRec.Is_Closed_Through_Process__c 	= true;
		oppRec.Agreement_Generated__c 			= true;
		update oppRec;
		update accountList;
		return 'The Agreement has been successfully created.';
	}

	private static String fetchMonthName(Integer month) {
		Map<Integer, String> monthNumberToNameMap = new Map<Integer, String>{1 =>'Jan', 2 =>'Feb', 3 =>'Mar', 4 =>'Apr', 5 =>'May', 6 =>'Jun', 7 =>'Jul', 8 =>'Aug', 9 =>'Sep', 10 =>'Oct', 11 =>'Nov', 12 =>'Dec'};
		return monthNumberToNameMap.get(month);
	}

	global class AssignmentWrapper implements Comparable {
		@AuraEnabled public Assignment__c assignment 		{get;set;}
		@AuraEnabled public List<String> newRole  			{get;set;}
		@AuraEnabled public Date effectiveDate 				{get;set;}
		@AuraEnabled public Date endDate 					{get;set;}
		@AuraEnabled public String selectedRole 			{get;set;}

		global AssignmentWrapper(Assignment__c assignment, List<String> newRole, Date effectiveDate, Date endDate, String selectedRole) {
	    	this.assignment 	= assignment;
	   		this.newRole 		= newRole;
	    	this.effectiveDate 	= effectiveDate;
	    	this.endDate 		= endDate;
	    	this.selectedRole 	= selectedRole;
		}

		global Integer compareTo(Object ObjToCompare) {
            return selectedRole.CompareTo(((AssignmentWrapper)ObjToCompare).selectedRole);
        }
	}

	global class OpportunityWrapper {
		@AuraEnabled public Opportunity oppRec 				{get; set;}
		@AuraEnabled public List<PickValWrap> oppType 		{get; set;}
		@AuraEnabled public List<PickValWrap> oppLeadSource {get; set;}
	}

	global class PickValWrap {
		@AuraEnabled public String text 					{get; set;}
		@AuraEnabled public String val 						{get; set;}
		@AuraEnabled public Boolean isSelected 				{get; set;}

		PickValWrap(String text, String val, Boolean isSelected) {
			this.text 		= text;
			this.val 		= val;
			this.isSelected = isSelected;
		}
	}

	global class AgreementWrapper {
		@AuraEnabled public Agreement__c agreementRec 		{get; set;}
		@AuraEnabled public Boolean isSelected 				{get; set;}

		AgreementWrapper(Agreement__c agreementRec, Boolean isSelected) {
			this.agreementRec 	= agreementRec;
			this.isSelected 	= isSelected;
		}
	}
}