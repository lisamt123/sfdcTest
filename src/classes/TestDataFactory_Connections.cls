public with sharing class TestDataFactory_Connections {
    
    public static List<Connection__c> generateConnections(Id recordTypeId, Id projectId, String status, String orgUrl, Integer numOfRecords) {
		return generateConnectionsInternal(recordTypeId, projectId, status, orgUrl, numOfRecords);
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<Connection__c> generateConnectionsInternal(Id recordTypeId, Id projectId, String status, String orgUrl, Integer numOfRecords) {
    	List<Connection__c> connectionList = new List<Connection__c>();
        
        for(Integer i = 0; i < numOfRecords; i++) {
			Connection__c con = new Connection__c();
			con.Project__c = projectId;
			con.Status__c = status;
			if(orgUrl != null)
				con.Organization_URL__c = orgUrl;
			if(recordTypeId != null)
				con.RecordTypeId = recordTypeId;
            connectionList.add(con);
        }
        
        return connectionList;
    }
}