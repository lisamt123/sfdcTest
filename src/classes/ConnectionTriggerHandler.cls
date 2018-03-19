public class ConnectionTriggerHandler {
   
    public static void deleteConnectionInfoFromHeroku() {
        List<String> connectionsIdList = new List<String>();
        Set<String> connectionsIdSet = new Set<String>();
        for(Release__c release : [SELECT Id, Source__c, Target__c FROM Release__c WHERE Source__c IN: Trigger.old OR Target__c IN: Trigger.old]) {
            if(release.Source__c != null)
                connectionsIdSet.add(release.Source__c);
            if(release.Target__c != null)
                connectionsIdSet.add(release.Target__c);
        }
        for(Connection__c connection: (List<Connection__c>)Trigger.old) {
            if(connection.Scan_Running__c) 
                connection.addError('Connection can\'t be deleted while code scan is in progress.' );
            else if(connection.Refresh_Running__c) 
                connection.addError('Connection can\'t be deleted while a refresh is in progress.' );
            else if(connectionsIdSet.contains(connection.Id))
                connection.addError('This Connection has already been used as a source or target connection on Release, and cannot be deleted. Please remove it from the related Release.');
            else if(!connection.Delete_on_Heroku__c && !connection.Allow_Deletion__c && connection.Created_on_Heroku__c) 
                connection.addError('This Connection has already been used within the application, and cannot be deleted. Consider using the Remove oAuth Connection action instead. Contact a 10K Administrator if you need assistance deleting this Connection.' );
            else if(connection.Created_on_Heroku__c)
                connectionsIdList.add(connection.Id);
        }

        String projectId    = '';
        String projectName  = '';
        for(Connection__c connection: [SELECT Id, Project__c, Project__r.Name FROM Connection__c WHERE Id IN: connectionsIdList]) {
            if(projectId == '' || connection.Project__c == projectId) {
                projectId   = connection.Project__c;
                projectName = connection.Project__r.Name;
            }
            else {
                projectId   = null;
                projectName = null;
            }
        }

        if(connectionsIdList.size() > 0)
            removeConnectionsFromHeroku(connectionsIdList,projectId,projectName);
    }

    @future(callout=true)
    public static void removeConnectionsFromHeroku(List<String> connectionsIdList,String projectId,String projectName) {
        DeleteRecordsFromHeroku.removeRecordsFromHeroku(connectionsIdList,projectId,projectName);
    }
    
    public static void checkPrimaryDevelopmentEnvironment() {
 		List<Connection__c> connectionList = Trigger.new;
 		Set<String> projectIdSet = new Set<String>();
 		for(Connection__c con : connectionList) {
 			if(con.Primary_Development_Environment__c)
 				projectIdSet.add(con.Project__c);
 		}
 		if(projectIdSet.size() > 0) {
	 		List<Connection__c> allConnectionList = [SELECT Id, Primary_Development_Environment__c,Project__c FROM Connection__c WHERE Project__c IN : projectIdSet AND Primary_Development_Environment__c = true AND Id NOT IN: connectionList];
	 		
	 		Map<Id, List<Connection__c>> projectConnectionMap = new Map<Id, List<Connection__c>>();
	 		
	 		for(Connection__c con : allConnectionList) {
	 			if(!projectConnectionMap.containsKey(con.Project__c)) 
	 				projectConnectionMap.put(con.Project__c, new List<Connection__c>());
	 			projectConnectionMap.get(con.Project__c).add(con);
	 		}
			
			List<Connection__c> connectionListToBeUpdated = new List<Connection__c>();
	 		for(Connection__c con : connectionList) {
	 			if(projectConnectionMap.containsKey(con.Project__c)) {
	 				for(Connection__c con2 : projectConnectionMap.get(con.Project__c)){
	 					if(con.Id != con2.Id && con2.Primary_Development_Environment__c) {
	 						con2.Primary_Development_Environment__c = false;
	 						connectionListToBeUpdated.add(con2);
	 					}
	 				}
	 			}
	 			
	 		}
	 		update connectionListToBeUpdated;
 		} 
    }
}