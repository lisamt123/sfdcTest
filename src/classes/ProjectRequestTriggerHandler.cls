public without sharing class ProjectRequestTriggerHandler { 
    
    public void onAfterInsert(List<Project_Request__c> lstNewProjectRequestRecords, Map<Id, Project_Request__c> mapOldProjectRequestRecords){
    	
	//	autoCreateOpptyAndProjectRecord(lstNewProjectRequestRecords, mapOldProjectRequestRecords);
		createAndRemoveSharingRecords(lstNewProjectRequestRecords, false);
		createServiceOpportunity(lstNewProjectRequestRecords);
    }
   	 
    public void onAfterUpdate(List<Project_Request__c> lstNewProjectRequestRecords, Map<Id, Project_Request__c> mapOldProjectRequestRecords){
    	
	//	autoCreateOpptyAndProjectRecord(lstNewProjectRequestRecords, mapOldProjectRequestRecords);		
		createAndRemoveSharingRecords(lstNewProjectRequestRecords, false);
		updateServiceOpportunity(lstNewProjectRequestRecords);
    }

    public void onAfterDelete(List<Project_Request__c> lstOldProjectRequestRecords){
    	
		createAndRemoveSharingRecords(lstOldProjectRequestRecords, true);		
    }
    
    public void onAfterUnDelete(List<Project_Request__c> lstNewProjectRequestRecords){
    	
		createAndRemoveSharingRecords(lstNewProjectRequestRecords, false);
    }
    
/*	private static void autoCreateOpptyAndProjectRecord(List<Project_Request__c> lstProjectRequestRecords, Map<Id, Project_Request__c> mapOldProjectRequestRecords) {

		/*
		MLAMB: This isn't necessary, just use Trigger.isInsert, Salesforce provides this for us
		*/
		//boolean isInsert = (mapOldProjectRequestRecords == null);		
		/*Set<Id> setProjectRequestIDs = new Set<Id>();		
		Set<Id> setProjectRequestIDsForOppty = new Set<Id>();	
		List<Project_Request__c> lstProjectRequestRecordsToUpdate = new List<Project_Request__c>();
		List<Project_Request__c> lstProjectRequestRecordsToPerformUpdate = new List<Project_Request__c>();	
		Map<Id, Project__c> mapProjectRequestIDToProject = new Map<Id, Project__c>();		
		Map<Id, Opportunity> mapProjectRequestIDToOpportunity = new Map<Id, Opportunity>();
		
		for(Project_Request__c objProjectRequest : lstProjectRequestRecords) {
			
			system.debug('Processing this Project Requerst : ' + objProjectRequest);

			//Check if insert [ONLY INSERT IF T-0017] OR update[Update used AS PER THE CASE T-0019] then proceed further, Checking Request_Contact__c != null, to avoid flow trigger error on update of status field if Request_Contact__c is null	[R]
			
			/*
			MLAMB: I've removed the condition for "&& (objProjectRequest.Request_Contact__c != null)" because it isn't required here, it was preventing the
			creation of Opportunities when no Request Contact was provided. An Opp should always be created, having a Request Contact isn't a pre-condition
			for creating an Opp.
			*/
			/*if((Trigger.isInsert || (objProjectRequest.Status__c != mapOldProjectRequestRecords.get(objProjectRequest.Id).Status__c 
				             		 || objProjectRequest.Status_Detail__c != mapOldProjectRequestRecords.get(objProjectRequest.Id).Status_Detail__c)) 
			   /*&& (objProjectRequest.Request_Contact__c != null) ) */
			  /* {
				setProjectRequestIDsForOppty.add(objProjectRequest.Id);
			}
				
			//Check if insert or update of particular field then proceed further	[R]
			
			
			/*if(objProjectRequest.Project__c == null && 
			    ((Trigger.isInsert || (objProjectRequest.Status__c != mapOldProjectRequestRecords.get(objProjectRequest.Id).Status__c 
									 || objProjectRequest.Status_Detail__c != mapOldProjectRequestRecords.get(objProjectRequest.Id).Status_Detail__c)) 
			   && (objProjectRequest.Status__c != null && objProjectRequest.Status_Detail__c != null) 
			   && (objProjectRequest.Status__c == 'Closed' && (objProjectRequest.Status_Detail__c == 'Fulfilled' 
			   												   || objProjectRequest.Status_Detail__c == 'Partially Fulfilled'))))  {
				
				setProjectRequestIDs.add(objProjectRequest.Id);
			}*/				
	//	}
		
		/* For creating an Opportunity record as per task T-0017 */
		//commenting out the opportunity creation as per the T-0121
		/*if(!setProjectRequestIDsForOppty.isEmpty()) {
			
			for(Project_Request__c objProjectRequest : [Select Id, Account__c, Account__r.Name, Project_Name__c, Status__c, Status_Detail__c, Opportunity__c, Opportunity__r.Id From Project_Request__c Where Id IN :setProjectRequestIDsForOppty]) {
				
				if(Trigger.isInsert) {
					
					Opportunity objOpportunity = new Opportunity();
					objOpportunity.Name = objProjectRequest.Account__r.Name+' - '+objProjectRequest.Project_Name__c;
					objOpportunity.RecordTypeId = Constants.RECORDTYPEID_OPPORTUNITY_SERVICES;
					objOpportunity.AccountId = objProjectRequest.Account__c;
					objOpportunity.CloseDate = system.today().addDays(14);
					objOpportunity.Amount = 0.0;
					
					//Call a common method to Update Opportunity stage when status is updated
					mapProjectRequestIDToOpportunity.putAll(assignOpportunityStage(objProjectRequest, objOpportunity, mapOldProjectRequestRecords, Trigger.isInsert));
				}
				else if(objProjectRequest.Status__c != mapOldProjectRequestRecords.get(objProjectRequest.Id).Status__c || objProjectRequest.Status_Detail__c != mapOldProjectRequestRecords.get(objProjectRequest.Id).Status_Detail__c)
				{
					Opportunity objOpportunity = new Opportunity(Id = objProjectRequest.Opportunity__r.Id);
					
					//Call a common method to Update Opportunity stage when status is updated
					mapProjectRequestIDToOpportunity.putAll(assignOpportunityStage(objProjectRequest, objOpportunity, mapOldProjectRequestRecords, Trigger.isInsert));
				}
			}
			
			system.debug('Before the Opp Upsert : ' + mapProjectRequestIDToOpportunity);

			if(!mapProjectRequestIDToOpportunity.isEmpty()) {
				upsert mapProjectRequestIDToOpportunity.values();
			}
				
			// Set the Parent [Opportunity__c] reference on child [Project_Request__c] record 
			for(Id objProjectRequestID : mapProjectRequestIDToOpportunity.keySet()) {
				
				lstProjectRequestRecordsToPerformUpdate.add(new Project_Request__c(Id = objProjectRequestID, Opportunity__c = mapProjectRequestIDToOpportunity.get(objProjectRequestID).Id));
			}
			
			if(!lstProjectRequestRecordsToPerformUpdate.isEmpty()) {
				update lstProjectRequestRecordsToPerformUpdate;
			}
		}*/
		
		/* For creating a Project__c record as per task T-0020 */
		/*if(!setProjectRequestIDs.isEmpty()) {
		    
		    system.debug('-----------came into project creation');
			
			for(Project_Request__c objProjectRequest : [Select Id, Account__c, Account__r.Name, Opportunity__c, Project_Name__c, Status__c, Status_Detail__c From Project_Request__c Where Id IN :setProjectRequestIDs]) {
				
				Project__c objProject = new Project__c(Account__c = objProjectRequest.Account__c, Status__c = 'Projected');				
				objProject.Name = objProjectRequest.Account__r.Name + ' - ' + objProjectRequest.Project_Name__c;
								
				if(objProjectRequest.Opportunity__c != null) {
					objProject.Opportunity__c = objProjectRequest.Opportunity__c;
				}
				
				mapProjectRequestIDToProject.put(objProjectRequest.Id, objProject);
			}
			
			system.debug('----------project' + mapProjectRequestIDToProject.values());
			
			if(!mapProjectRequestIDToProject.isEmpty()) {
				insert mapProjectRequestIDToProject.values();
			}
			
			/* Set the Parent [Project__c] reference on child [Project_Request__c] record */		
		/* 	for(Id objProjectRequestID : mapProjectRequestIDToProject.keySet()) {
				
				Project_Request__c objProjectRequest = new Project_Request__c(Id = objProjectRequestID, Project__c = mapProjectRequestIDToProject.get(objProjectRequestID).Id);
				lstProjectRequestRecordsToUpdate.add(objProjectRequest);
			}
			
			if(!lstProjectRequestRecordsToUpdate.isEmpty()) {
				update lstProjectRequestRecordsToUpdate;
			}
		}*/
	//}
	
	/* private static Map<Id, Opportunity> assignOpportunityStage(Project_Request__c objProjectRequest, Opportunity objOpportunity, Map<Id, Project_Request__c> mapOldProjectRequestRecords, boolean isInsert) {
		
		Map<Id, Opportunity> mapProjectRequestIDToOpportunityy = new Map<Id, Opportunity>();
		
		//Update Opportunity stage when status is updated as per Task T-0019, Insert it has to perform as usual	 i.e. Update the following fields when Project_Request__c records are inserted as well as updated [Status__c OR Status_Detail__c]  [R]
		if((isInsert || (objProjectRequest.Status__c != mapOldProjectRequestRecords.get(objProjectRequest.Id).Status__c || objProjectRequest.Status_Detail__c != mapOldProjectRequestRecords.get(objProjectRequest.Id).Status_Detail__c))) { 
			
			if(objProjectRequest.Status__c == 'New') {
				objOpportunity.StageName = 'Qualification';
			}
			else if(objProjectRequest.Status__c == 'Under Review') {
				objOpportunity.StageName = 'Needs Analysis';
			}
			else if(objProjectRequest.Status__c == 'Pending Contract') {
				objOpportunity.StageName = 'Proposal';
			}
			else if(objProjectRequest.Status__c == 'Closed'	&& (objProjectRequest.Status_Detail__c == 'Fulfilled' || objProjectRequest.Status_Detail__c == 'Partially Fulfilled')) {
				objOpportunity.StageName = 'Closed Won';
			}
			else {
				objOpportunity.StageName = 'Closed Lost';
			}
				
			mapProjectRequestIDToOpportunityy.put(objProjectRequest.Id, objOpportunity);	
		}
		return mapProjectRequestIDToOpportunityy;
	}*/
	
	public static void createAndRemoveSharingRecords(List<Project_Request__c> lstProjectRequest, boolean boolPerformDelete) {
	
		if(boolPerformDelete) {
			deleteSharedRecords(lstProjectRequest, false);
		}
		else {
			if(Trigger.isInsert || Trigger.isUndelete) {
				insertNewProjectRequestShareRecords(lstProjectRequest);    
			}
			else if(Trigger.isUpdate) {
				
				system.debug('>>>>>>>>>>>>>>>PRH>>>>>>>>UPDATE');
				List<Project_Request__c> listOfProjRequestWithChangedAccounts = new List<Project_Request__c>();
				for(Project_Request__c objProjectRequest : lstProjectRequest) {
					
					system.debug('>>>>>>>>>>>>>>>PRH>>>Recalculate_Sharing_on_Save__c>>>>>old map>>>' +((Project_Request__c)Trigger.OldMap.get(objProjectRequest.id)).Recalculate_Sharing_on_Save__c);
					system.debug('>>>>>>>>>>>>>>>PRH>>>Recalculate_Sharing_on_Save__c>>>>>current>>>' +objProjectRequest.Recalculate_Sharing_on_Save__c);
					
					if((objProjectRequest.Account__c != ((Project_Request__c)Trigger.OldMap.get(objProjectRequest.id)).Account__c) || (objProjectRequest.Request_Contact__c != ((Project_Request__c)Trigger.OldMap.get(objProjectRequest.id)).Request_Contact__c) || objProjectRequest.Recalculate_Sharing_on_Save__c) {
						listOfProjRequestWithChangedAccounts.add(objProjectRequest);
						//objProjectRequest.Recalculate_Sharing_on_Save__c = false;										
					}
				}
				if(listOfProjRequestWithChangedAccounts.size() > 0) {
					
					deleteSharedRecords(listOfProjRequestWithChangedAccounts, true);
					insertNewProjectRequestShareRecords(listOfProjRequestWithChangedAccounts);
				}     
			}
		}
	}
	
	
	//This Method Creates New Sharing Records
	private static void insertNewProjectRequestShareRecords(List<Project_Request__c> lstProjectRequest) {
		List<Project_Request__Share> sharingList = new List<Project_Request__Share>();
		Map<Id, Set<Id>> userRoleMap = new Map<Id,Set<Id>>();
		Map<Id,List<Group>> groupListWithRoleIdMap = new Map<Id,List<Group>>();
		List<Project_Request__c> projectRequestlst = new List<Project_Request__c>();
			
		//let's create a Set of Account ids
		Set<Id> setAccountIDs = getAccountIds(lstProjectRequest, false);
		Set<Id> setProjectRequestIDs = new Set<Id>();
		
		//let's fill a Map with User role id according to the associate Account id.
		if(setAccountIDs.size() > 0) {
			userRoleMap = getUserRole(setAccountIDs);
		}
		
		//Fetching User according to the Role
		if(userRoleMap.size() > 0){
			groupListWithRoleIdMap = getGroupRecordsAccordingToRole(userRoleMap);
		}
		
		for(Project_Request__c objProjectRequest : lstProjectRequest) {
			
			setProjectRequestIDs.add(objProjectRequest.Id); 
		}
		
		system.debug('>>>>>>>>>>>>>>>PRH>>>insertNewProjectRequestShareRecords>>>>>' );
		
															
		for(Project_Request__c objProjectRequest : [SELECT Id, Request_Contact__c, Request_Contact__r.Id, Request_Contact__r.OwnerId, 
														   Account__c, Account__r.Name, Opportunity__c, Project_Name__c, Recalculate_Sharing_on_Save__c, Status__c, 
														   Status_Detail__c, Request_Contact__r.Portal_User__c 
													FROM Project_Request__c 
													WHERE Id IN: setProjectRequestIDs]) {
			
			if(objProjectRequest.Account__c != null && userRoleMap.containsKey(objProjectRequest.Account__c)){
				
				system.debug('>>>>>>>>>>>>>>>PRH>>>Account__c != null>>objProjectRequest.Recalculate_Sharing_on_Save__c>>>' +objProjectRequest.Recalculate_Sharing_on_Save__c);
				system.debug('>>>>>>>>>>>>>>>PRH>>>objProjectRequest.Request_Contact__r.Portal_User__c>>>>>' +objProjectRequest.Request_Contact__r.Portal_User__c);
				
				if(objProjectRequest.Request_Contact__r.Portal_User__c != null && objProjectRequest.Recalculate_Sharing_on_Save__c) {
					
					system.debug('>>>>>>>>>>>>>>>PRH>>>objProjectRequest.Request_Contact__r.Portal_User__c>>>>>' );

					objProjectRequest.Recalculate_Sharing_on_Save__c = false;
					projectRequestlst.add(objProjectRequest);

					system.debug('================================INNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN');
					Project_Request__Share projectRequestShare1 = new Project_Request__Share();
					projectRequestShare1.ParentId = objProjectRequest.Id;
				 	projectRequestShare1.UserOrGroupId = objProjectRequest.Request_Contact__r.Portal_User__c;
				 	projectRequestShare1.AccessLevel = 'Edit';
				 	projectRequestShare1.RowCause = Schema.Project_Request__Share.RowCause.Customer__c;
				 	sharingList.add(projectRequestShare1); 
				}
							 
				for(Id userRoleId : userRoleMap.get(objProjectRequest.Account__c)) {
					if(groupListWithRoleIdMap.containsKey(userRoleId)) {
						for(Group groupObj : groupListWithRoleIdMap.get(userRoleId)) {
							 Project_Request__Share projectRequestShare = new Project_Request__Share();
							 projectRequestShare.ParentId = objProjectRequest.id;
							 projectRequestShare.UserOrGroupId = groupObj.id;
							 projectRequestShare.AccessLevel = 'Read';
							 projectRequestShare.RowCause = Schema.Project_Request__Share.RowCause.Customer__c;
							 sharingList.add(projectRequestShare); 
						}
					}    
			   }    
			}
		}
		if(sharingList.size() > 0){
			insert sharingList;
		}
		if(projectRequestlst.size() > 0)
		{
			update projectRequestlst;
		}		
	}	
	    
	//This methods delete sharing records for Customer. flag variable maintain direct delete and update delete functionality
	public static void deleteSharedRecords(List<Project_Request__c> lstProjectRequest, boolean deleteFlag){

		List<Project_Request__Share> projectShareRecordForDelete = new List<Project_Request__Share>();
		List<Project_Request__Share> projectShareRecordsForDelete = new List<Project_Request__Share>();
		system.debug('deleteFlag: ' + deleteFlag);
		system.debug('lstProjectRequest: ' + lstProjectRequest);
		
		//let's create a Set of Contact ids
		Set<Id> contactIds = getContactIds(lstProjectRequest, true);
		
		if(!contactIds.isEmpty()) {
			
			List<User> lstUserIDs = new List<User>([Select Id From User Where ContactId IN :contactIds]);
			
			projectShareRecordsForDelete = [SELECT id FROM Project_Request__Share where ParentId in: lstProjectRequest and UserOrGroupId IN :lstUserIDs];	
		}	
		
		if(deleteFlag){
			Map<Id, Set<Id>> userRoleMap = new Map<Id,Set<Id>>();
			Map<Id,List<Group>> groupListWithRoleIdMap = new Map<Id,List<Group>>();
			Set<Id> allRolesUserOrGroupIds = new Set<Id>();    
			
			//let's create a Set of Account ids
			Set<Id> accountId = getAccountIds(lstProjectRequest, true);
			
			//let's fill a Map with User role id according to the associate Account id.
			if(accountId.size()>0){
				userRoleMap = getUserRole(accountId);
			}
			
			//Fetching User according to the Role
			if(userRoleMap.size()>0){
				groupListWithRoleIdMap = getGroupRecordsAccordingToRole(userRoleMap);
			}
			
			for(Project_Request__c objProjectRequest : lstProjectRequest){
				if(userRoleMap.containsKey(((Project_Request__c)trigger.oldMap.get(objProjectRequest.id)).Account__c)){              
					for(Id userRoleId : userRoleMap.get(((Project_Request__c)trigger.oldMap.get(objProjectRequest.id)).Account__c)){
						if(groupListWithRoleIdMap.containsKey(userRoleId)){
							for(Group groupObj : groupListWithRoleIdMap.get(userRoleId)){
								allRolesUserOrGroupIds.add(groupObj.id);
							}
						}
					}    
				}
			}
			projectShareRecordForDelete = [SELECT id FROM Project_Request__Share where ParentId in: lstProjectRequest and UserOrGroupId in: allRolesUserOrGroupIds];
				
		}else{
			projectShareRecordForDelete = [SELECT id FROM Project_Request__Share where ParentId in: lstProjectRequest];
		}
		if(projectShareRecordForDelete.size()>0) { delete projectShareRecordForDelete; }
		
		if(!projectShareRecordsForDelete.isEmpty()) { Database.Delete(projectShareRecordsForDelete, false); } 
	}
	
	
	//Fill Account ids
	private static Set<Id> getAccountIds(List<Project_Request__c> lstProjectRequest, boolean deleteFlag){
		
		 Set<Id> setAccountIDs = new Set<Id>();
		 
		 for(Project_Request__c objProjectRequest : lstProjectRequest){
			if(objProjectRequest.Account__c != null){
				if(deleteFlag == true){
					setAccountIDs.add(((Project_Request__c)trigger.oldMap.get(objProjectRequest.id)).Account__c);
				}else
					setAccountIDs.add(objProjectRequest.Account__c);
			}     
		}
		return setAccountIDs;
	} 
	
	//Fill Account ids
	private static Set<Id> getContactIds(List<Project_Request__c> lstProjectRequest, boolean deleteFlag){
		
		 Set<Id> setContactIDs = new Set<Id>();
		 
		 for(Project_Request__c objProjectRequest : lstProjectRequest){
			if(objProjectRequest.Request_Contact__c != null){
				if(deleteFlag == true){
					setContactIDs.add(((Project_Request__c)trigger.oldMap.get(objProjectRequest.id)).Request_Contact__c);
				}
			}     
		}
		return setContactIDs;
	} 
	
	//Fill User Role ids with Account ids
	private static Map<Id, Set<Id>> getUserRole(Set<Id> setAccountIDs) {
		Map<Id, Set<Id>> accountRoleMap = new Map<Id,Set<Id>>();
		List<UserRole> userRoleList = [SELECT Id, Name, PortalAccountId, PortalRole, ParentRoleId
									   FROM UserRole 
									   WHERE PortalAccountId IN: setAccountIDs];
								   
		if(userRoleList.size() > 0) {
			for(UserRole userRoleObj : userRoleList) {
				Set<Id> userRoleObjSet = accountRoleMap.get(userRoleObj.portalAccountId);
				if(userRoleObjSet == null){
					accountRoleMap.put(userRoleObj.PortalAccountId, new Set<Id>());  
				}
				accountRoleMap.get(userRoleObj.PortalAccountId).add(userRoleObj.id);    
			}
		}
		return accountRoleMap;
	}
	
	//Fill Group List accourding to Its Role
	private static Map<Id, List<Group>> getGroupRecordsAccordingToRole(Map<Id,Set<Id>> userRoleMap) {
		
		Set<Id> userRoleIds =  new Set<Id>();
		for(Id accountId : userRoleMap.keySet()){
			userRoleIds.addAll(userRoleMap.get(accountId));
		}   
		
		List<Group> groupList = [SELECT id, RelatedId, Type FROM Group where RelatedId in : userRoleIds and type = 'RoleAndSubordinates'];
		Map<Id, List<Group>> groupListWithRoleIdMap = new Map<Id, List<Group>>();
		if(groupList.size() > 0) {
			for(Group groupObj : groupList) {
				List<Group> groupOtherList =  groupListWithRoleIdMap.get(groupObj.RelatedId);
				if(groupOtherList == null) {
					groupOtherList = new List<Group>();
				}
				groupOtherList.add(groupObj);
				groupListWithRoleIdMap.put(groupObj.RelatedId, groupOtherList);
			}
		}
		return groupListWithRoleIdMap;
	}

	public static void createServiceOpportunity(List<Project_Request__c> lstProjectRequest) {
		List<Opportunity> oppRecList = new List<Opportunity>();
		Set<Id> accIdList = new Set<Id>();
		Map<Id,Integer> accToCountServiceMap = new Map<Id,Integer>();
		List<Project_Request__c> workRequestList = new List<Project_Request__c>();
		List<OpportunityContactRole> newContactRoleList = new List<OpportunityContactRole>();
		Map<String,String> statusToStageMap = new Map<String,String>();
		Map<Id,Opportunity> workRequestNameToOppMap = new Map<Id,Opportunity>();
		for(Project_Request__c workRequest : lstProjectRequest)	{
			accIdList.add(workRequest.Account__c);
		}

		for(WorkRequestStatus_To_ServiceOppStage__mdt workStatusToOppStage : [SELECT ID, Label, ServiceOpp_Stage__c FROM WorkRequestStatus_To_ServiceOppStage__mdt]){
            statusToStageMap.put(workStatusToOppStage.Label, workStatusToOppStage.ServiceOpp_Stage__c);
        }
		
       for(Account acc : [SELECT Id,(SELECT Id FROM Opportunities 
        							WHERE RecordTypeId = :Constants.RECORDTYPEID_OPPORTUNITY_SERVICES) 
        							FROM Account WHERE Id IN :accIdList]) {
       		accToCountServiceMap.put(acc.Id,acc.Opportunities.size());

        }						
		
		for(Project_Request__c workRequest : lstProjectRequest)	{
			Opportunity opp = new Opportunity();
			opp.Name  		= workRequest.Name;
			opp.AccountId 	= workRequest.Account__c;
			if(workRequest.Start_Date__c != null)
				opp.CloseDate 	= workRequest.Start_Date__c;
			opp.Description = workRequest.Description__c;
			opp.RecordTypeId = Constants.RECORDTYPEID_OPPORTUNITY_SERVICES;
			opp.Start_Date__c = workRequest.Start_Date__c;
			opp.End_Date__c  = workRequest.End_Date__c;
			if(statusToStageMap.containsKey(workRequest.Status__c))
				opp.StageName   = statusToStageMap.get(workRequest.Status__c);
			
			if(accToCountServiceMap.get(workRequest.Account__c) == 0){
				opp.Type = 'First Project';
			}
			else if(workRequest.Project__c == null){
				opp.Type = 'New Project';
			}
			else if(workRequest.Project__c != null){
				opp.Type = 'Project Extension';
			}
			

			oppRecList.add(opp);
			workRequestNameToOppMap.put(workRequest.Id,opp);
		}
		
		if(!oppRecList.isEmpty())
			insert oppRecList;

		for(Project_Request__c workRequest : [SELECT Id,Opportunity__c,Request_Contact__c,Name FROM Project_Request__c 
												WHERE Id IN: Trigger.newMap.keySet()]){
			if(workRequestNameToOppMap.containsKey(workRequest.Id)){
				if(workRequestNameToOppMap.containsKey(workRequest.Id))
					workRequest.Opportunity__c = workRequestNameToOppMap.get(workRequest.Id).Id;
				if(workRequest.Request_Contact__c != null)
					newContactRoleList.add(new OpportunityContactRole(ContactId=workRequest.Request_Contact__c,OpportunityId=workRequestNameToOppMap.get(workRequest.Id).Id,Role='Decision Maker',IsPrimary=true));
				
				workRequestList.add(workRequest);
			}
		}

		if(!newContactRoleList.isEmpty())
			insert newContactRoleList;
		
		if(!workRequestList.isEmpty())
			update workRequestList;
	}


	public static void updateServiceOpportunity(List<Project_Request__c> lstProjectRequest) {
		List<Id> oppIdList = new List<Id>();
		List<Opportunity> oppListToBeUpdated = new List<Opportunity>();
		List<OpportunityContactRole> newContactRoleList = new List<OpportunityContactRole>();
		List<Id> oppIdListToDelOppContactRole = new List<Id>();
		Map<String,String> statusToStageMap = new Map<String,String>();

		for(WorkRequestStatus_To_ServiceOppStage__mdt workStatusToOppStage : [SELECT ID, Label, ServiceOpp_Stage__c FROM WorkRequestStatus_To_ServiceOppStage__mdt]){
            statusToStageMap.put(workStatusToOppStage.Label, workStatusToOppStage.ServiceOpp_Stage__c);
        }

		for(Project_Request__c workRequest : lstProjectRequest)	{
			oppIdList.add(workRequest.Opportunity__c);
		}
		
		Map<Id,Opportunity> opportunityIdToRecMap = new Map<Id,Opportunity>([SELECT Id,Name,AccountId,CloseDate,Description,StageName FROM Opportunity WHERE Id IN :oppIdList]);
	
		for(Project_Request__c workRequest : lstProjectRequest)	{
			if(workRequest.Name != ((Project_Request__c)Trigger.oldMap.get(workRequest.Id)).Name || workRequest.Account__c != ((Project_Request__c)Trigger.oldMap.get(workRequest.Id)).Account__c 
									|| workRequest.Start_Date__c != ((Project_Request__c)Trigger.oldMap.get(workRequest.Id)).Start_Date__c || workRequest.Description__c != ((Project_Request__c)Trigger.oldMap.get(workRequest.Id)).Description__c 
									|| workRequest.Request_Contact__c != ((Project_Request__c)Trigger.oldMap.get(workRequest.Id)).Request_Contact__c 
									|| workRequest.Status__c != ((Project_Request__c)Trigger.oldMap.get(workRequest.Id)).Status__c ) {

				if(opportunityIdToRecMap.containsKey(workRequest.Opportunity__c)) {
					opportunityIdToRecMap.get(workRequest.Opportunity__c).Name 			= workRequest.Name;
					opportunityIdToRecMap.get(workRequest.Opportunity__c).AccountId 	= workRequest.Account__c;
					opportunityIdToRecMap.get(workRequest.Opportunity__c).CloseDate 	= workRequest.Start_Date__c;
					opportunityIdToRecMap.get(workRequest.Opportunity__c).Description 	= workRequest.Description__c;
					opportunityIdToRecMap.get(workRequest.Opportunity__c).StageName 	= statusToStageMap.get(workRequest.Status__c);
					if(workRequest.Request_Contact__c != ((Project_Request__c)Trigger.oldMap.get(workRequest.Id)).Request_Contact__c) {
						oppIdListToDelOppContactRole.add(workRequest.Opportunity__c);
						newContactRoleList.add(new OpportunityContactRole(ContactId=workRequest.Request_Contact__c,OpportunityId=opportunityIdToRecMap.get(workRequest.Opportunity__c).Id,Role='Decision Maker',IsPrimary=true));

					}

					oppListToBeUpdated.add(opportunityIdToRecMap.get(workRequest.Opportunity__c));
				}
			}
		}

		List<OpportunityContactRole> oppContactRoleToBeDeleted = [SELECT Id,OpportunityId FROM OpportunityContactRole 
																  	WHERE OpportunityId IN :oppIdListToDelOppContactRole];
		if(!oppContactRoleToBeDeleted.isEmpty())
			Delete oppContactRoleToBeDeleted;

		if(!newContactRoleList.isEmpty())
			insert newContactRoleList;
		if(!oppListToBeUpdated.isEmpty())
			update oppListToBeUpdated;		
	}
}