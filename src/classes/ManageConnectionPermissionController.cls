global without sharing class ManageConnectionPermissionController {
	
	@auraEnabled
	public static List<ConnectionWrapper> getProjectConnectionList(Id projectId, Id connectionId) {
		
		List<ConnectionWrapper> connectionWrapperList = new List<ConnectionWrapper>();
        if(!String.isBlank(projectId)) {
        	ProjectConnectionResponseJSON connectionResponse;
        	if(String.isBlank(connectionId)) {
        		connectionResponse = getProjectHerokuResponse(projectId);
        	}else {
        		connectionResponse = getConnectionHerokuResponse(connectionId);
        	}
        	Map<String,boolean> validateMap = new Map<String,boolean>();
			Map<String,boolean> deployMap = new Map<String,boolean>();
			if(connectionResponse.status == 'Success') {
				
				String key;
				for(ProjectConnectionResponseJSONWrapper response :connectionResponse.permissionList) {
					key = response.connectionId+'#'+response.contactId ;
					//key = response.connectionId+'#'+response.contactId+'#'+response.role+'#'+response.region ;
					validateMap.put(key, response.validateRelease);
					deployMap.put(key, response.deployRelease);
				}
			}

        	List<Assignment__c> assignmentList = [SELECT Id, Resource_Name__c, Status__c,Resource__r.Id,Region__c,Role__c FROM Assignment__c WHERE Project__c =: projectId];
        	List<AssignmentWrapper> assignmentWrapperList = new List<AssignmentWrapper>();
			boolean validateBoolean;
			boolean deployBoolean;
			
			List<Connection__C> connectionList = (String.isBlank(connectionId)) ? [SELECT Id, Name, RecordTypeId, Status__C, CreatedDate from Connection__C WHERE Project__C =: projectId ORDER BY CreatedDate DESC] : [SELECT Id, Name, RecordTypeId, Status__C, CreatedDate from Connection__C WHERE Project__C =: projectId and Id =: connectionId ORDER BY CreatedDate DESC];
			if(connectionList.size() > 0) {
				Set<Id> connectionRecordTypeIdSet = new Set<Id>();	
				Map<Id,String> connectionRecordTypeMap = new Map<Id,String>();
				for(Connection__C connection : connectionList) {
					connectionRecordTypeIdSet.add(connection.RecordTypeId);
				}
				if(connectionRecordTypeIdSet.size() > 0) {
					for(RecordType recType : [SELECT Id, Name FROM RecordType WHERE Id IN: connectionRecordTypeIdSet]) {
						connectionRecordTypeMap.put(recType.Id, recType.Name);
					}
				}
				
				for(Connection__C connection : connectionList) {
					Set<Id> assignmentIdSet = new Set<Id>();
					List<AssignmentWrapper> assignWrapperList = new List<AssignmentWrapper>();
					for(Assignment__c assignment : assignmentList){
						if(!assignmentIdSet.contains(assignment.Resource__r.Id)){
							AssignmentWrapper assignWrapper = new AssignmentWrapper();
							assignWrapper.assignment = assignment;
							assignWrapper.validateReleaseTo = (validateMap.containsKey(connection.Id+'#'+assignment.Resource__r.Id)) ? validateMap.get(connection.Id+'#'+assignment.Resource__r.Id) : true;
							assignWrapper.deployReleaseTo = (deployMap.containsKey(connection.Id+'#'+assignment.Resource__r.Id)) ? deployMap.get(connection.Id+'#'+assignment.Resource__r.Id) : true;
							assignWrapperList.add(assignWrapper);
							assignmentIdSet.add(assignment.Resource__r.Id);
						}
					}
					connectionWrapperList.add(new ConnectionWrapper(connection,connectionRecordTypeMap.get(connection.RecordTypeId),assignWrapperList));
				}
			}
			connectionWrapperList.sort();
		}
		return connectionWrapperList;
	}

	public static ProjectConnectionResponseJSON getProjectHerokuResponse(Id projectId) {
		Project__c project = [SELECT Id, Name FROM Project__c WHERE Id =: projectId];
		return getConnectionResponse((String)projectId,project.Id,project.Name);		
	}

	public static ProjectConnectionResponseJSON getConnectionHerokuResponse(Id connectionId) {
		Connection__c connection = [SELECT Id, Project__c, Project__r.Name FROM Connection__c WHERE Id =: connectionId];
		return getConnectionResponse((String)connectionId,connection.Project__C,connection.Project__r.Name);		
	}

	public static ProjectConnectionResponseJSON getConnectionResponse(String recId, String projectId, String projectName) {
		String connectionKeyPrifix  = Schema.getGlobalDescribe().get('Connection__c').getDescribe().getKeyPrefix();
        String projectKeyPrifix     = Schema.getGlobalDescribe().get('Project__c').getDescribe().getKeyPrefix();
        String reqEndpoint 			= '';
        if(recId.substring(0, 3) == projectKeyPrifix)
            reqEndpoint  = 'Project_ConnectionPermission_Retrieve';
        else if (recId.substring(0, 3) == connectionKeyPrifix)
            reqEndpoint  = 'Connection_Permission_Retrieve';

		HttpResponse res = RestRequestHandlerForHeroku.sendRequest('POST',reqEndpoint,'',recId,projectId,projectName);
        ProjectConnectionResponseJSON connectionResponse = (ProjectConnectionResponseJSON)JSON.deserialize(res.getBody(), ProjectConnectionResponseJSON.class);    
		return connectionResponse;		
	}

	@auraEnabled
	public static String saveConnectionPermissions(Id projectId,String connectionList) {
		String message;
		Project__c project = [SELECT Id, Name FROM Project__c WHERE Id =: projectId];
		List<ConnectionWrapper> connectionWrapperList = (List<ConnectionWrapper>)JSON.deserialize(connectionList, List<ConnectionWrapper>.class);
        List<ProjectConnectionResponseJSONWrapper> wrapperList = new List<ProjectConnectionResponseJSONWrapper>();    
		if((!String.isBlank(projectId)) && (connectionWrapperList.size() > 0)) {
			for(ConnectionWrapper conWrapper : connectionWrapperList) {
				for(AssignmentWrapper assignWrapper : conWrapper.assignmentwrapperList) {
					ProjectConnectionResponseJSONWrapper jsonWrapper = new ProjectConnectionResponseJSONWrapper();
					jsonWrapper.validateRelease = assignWrapper.validateReleaseTo ;
  					jsonWrapper.deployRelease 	= assignWrapper.deployReleaseTo ;
  					jsonWrapper.contactId 		= assignWrapper.assignment.Resource__r.Id ;
  					jsonWrapper.connectionId 	= conWrapper.connection.Id ;
					wrapperList.add(jsonWrapper);
				}
			}
			if(wrapperList.size() > 0)
				message = savePermissions((String)projectId, wrapperList,project.Id,project.Name);
		}
		return message;
	}

	@auraEnabled
	public static String saveConnectionWisePermissions(Id connectionId,String assignmentWrapperList) {
		String message;
		Connection__c connection = [SELECT Id, Project__c, Project__r.Name FROM Connection__c WHERE Id =: connectionId];
		List<AssignmentWrapper> connectionWrapperList = (List<AssignmentWrapper>)JSON.deserialize(assignmentWrapperList, List<AssignmentWrapper>.class);
        List<ProjectConnectionResponseJSONWrapper> wrapperList = new List<ProjectConnectionResponseJSONWrapper>();    
		if((!String.isBlank(connectionId)) && (connectionWrapperList.size() > 0)) {
			List<Connection__C> connectionList = [SELECT Id, Name, RecordTypeId, Status__C, CreatedDate, Project__c from Connection__C WHERE Id =: connectionId] ;
        	if(connectionList.size() > 0) {
				String projectId = 	connectionList[0].Project__c;
				for(AssignmentWrapper assignWrapper : connectionWrapperList) {
					ProjectConnectionResponseJSONWrapper jsonWrapper = new ProjectConnectionResponseJSONWrapper();
					jsonWrapper.validateRelease = assignWrapper.validateReleaseTo ;
					jsonWrapper.deployRelease 	= assignWrapper.deployReleaseTo ;
					jsonWrapper.contactId 		= assignWrapper.assignment.Resource__r.Id ;
					jsonWrapper.projectId 		= projectId ;
					wrapperList.add(jsonWrapper);	
				}
				if(wrapperList.size() > 0)
					message = savePermissions((String)connectionId, wrapperList,connection.Project__c,connection.Project__r.Name);
			}
		}
		return message;
	}

	public static String savePermissions(String recId, List<ProjectConnectionResponseJSONWrapper> wrapperList, String projectId, String projectName) {
		String message;
        String connectionKeyPrifix  = Schema.getGlobalDescribe().get('Connection__c').getDescribe().getKeyPrefix();
        String projectKeyPrifix     = Schema.getGlobalDescribe().get('Project__c').getDescribe().getKeyPrefix();
        String reqEndpoint = '';
        if(recId.substring(0, 3) == projectKeyPrifix)
            reqEndpoint  = 'Project_ConnectionPermission';
        else if (recId.substring(0, 3) == connectionKeyPrifix)
            reqEndpoint  = 'Connection_Permission';

		String requestJSONBody = '"permissionList":' + JSON.serialize(wrapperList);
		HttpResponse res = RestRequestHandlerForHeroku.sendRequest('POST',reqEndpoint,requestJSONBody,recId,projectId,projectName);
		ConnectionSaveResponseJSON saveResponse = (ConnectionSaveResponseJSON)JSON.deserialize(res.getBody(), ConnectionSaveResponseJSON.class);
		if(saveResponse.status == 'Success') {
			message = saveResponse.message;
		}
		return message;
	}

	@auraEnabled
	public static ConnectionWrapper getConnectionAssignments(Id connectionId) {
		if(!String.isBlank(connectionId)) {
			List<Connection__C> connectionList = [SELECT Id, Name, RecordTypeId, Status__C, CreatedDate, Project__c from Connection__C WHERE Id =: connectionId] ;
			if(connectionList.size() > 0) {
				List<ConnectionWrapper> connectionWrapper =  getProjectConnectionList(connectionList[0].Project__c, connectionList[0].Id);
				if(connectionWrapper.size() > 0)
					return connectionWrapper[0];
				else
					return null ;	
			}
			else 
				return null ;
		}else 
			return null ;
		
	}

	public class ConnectionSaveResponseJSON {
		public String status;
		public String message;
	}

	public class ProjectConnectionResponseJSON {
		public String status;
		public List<ProjectConnectionResponseJSONWrapper> permissionList;
	}

	public class ProjectConnectionResponseJSONWrapper {
		public boolean validateRelease;
  		public boolean deployRelease;
  		public String contactId;
  		public String connectionId;
  		public String projectId;
  		//public String region;
  		//public String role;
	}
	
	public class AssignmentWrapper {
		@auraEnabled public Assignment__c assignment ;
		@auraEnabled public boolean validateReleaseTo;
		@auraEnabled public boolean deployReleaseTo;

	}

	public class ConnectionWrapper implements Comparable {
		@auraEnabled
		public Connection__C connection;
		@auraEnabled
		public String recordTypeName;
		@auraEnabled
		public List<AssignmentWrapper> assignmentwrapperList;

		public Integer compareTo(Object compareTo) {
            ConnectionWrapper other = (ConnectionWrapper) compareTo;
            if (this.recordTypeName > other.recordTypeName)
              return 1;
            else if (this.recordTypeName == other.recordTypeName)
              return 0;
            return -1;
        }

		public ConnectionWrapper(Connection__C connection, String recordTypeName,List<AssignmentWrapper> assignmentwrapperList) {
			this.connection = connection;
			this.recordTypeName = recordTypeName;
			this.assignmentwrapperList = assignmentwrapperList ;
		}
	}
}