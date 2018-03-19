@RestResource(urlMapping='/syncConnection/')
global with sharing class SyncConnection {
    @HttpPost
    global static String syncConnectionRecord() {
        RestRequest req = RestContext.request;
        try {
            List<Connection__c> connectionList = [SELECT Metadata_Last_Described__c, Allow_Deletion__c, Metadata_Describe_Error__c, 
                                                      Scan_Running__c, Code_Scan_Status__c, Code_Scan_Describe_Message__c, Status__c,
              										  Connection_Compare_Describe_Message__c, Comparing_Connections__c 
          										  FROM Connection__c
                                                  WHERE ID =: req.params.get('Connection_Id')];
            if(connectionList.size() > 0) {
                for( Connection__c connectionToUpdate :connectionList) {
                	if(req.params.get('Task') == 'MetadataDescribe') {
    	            	if(req.params.get('refreshStstus') == 'true') {
    	            		connectionToUpdate.Refresh_Running__c = true;
    	            	}
    	            	else {
    						connectionToUpdate.Metadata_Last_Described__c = Datetime.now(); 
    						connectionToUpdate.Refresh_Running__c         = false; 
    						connectionToUpdate.Status__c                  = req.params.get('Status'); 
    						connectionToUpdate.Metadata_Describe_Error__c = req.params.get('Error_Message'); 
                            //connectionToUpdate.Allow_Deletion__c          = false;
    	            	}
                	}
                	if(req.params.get('Task') == 'CodeReview') {
                		connectionToUpdate.Code_Scan_Status__c            = req.params.get('Status');
                		connectionToUpdate.Scan_Running__c                = false; 
                		connectionToUpdate.Code_Scan_Describe_Message__c  = req.params.get('Describe_Error'); 
                        connectionToUpdate.Allow_Deletion__c              = false;
                	}
                	if(req.params.get('Task') == 'ConnectionCompare') {
                		connectionToUpdate.Connection_Compare_Describe_Message__c = req.params.get('Describe_Error'); 
                        connectionToUpdate.Allow_Deletion__c                      = false;
                        String connectionIdString = '';
                        connectionToUpdate.Comparing_Connections__c = connectionToUpdate.Comparing_Connections__c == null ? '' : connectionToUpdate.Comparing_Connections__c;
                        for(String connectionId : connectionToUpdate.Comparing_Connections__c.split(','))
                            if(connectionId != req.params.get('targetConnection') && connectionId.trim() != '')
                                connectionIdString += connectionIdString == '' ? connectionId : ',' + connectionId;
                        connectionToUpdate.Comparing_Connections__c = connectionIdString;
                	}
                } 
                if(req.params.get('Task') == 'ConnectionCompare' && req.params.get('targetConnection') != req.params.get('Connection_Id')) {
                    for(Connection__c connection : [SELECT Id, Comparing_Connections__c FROM Connection__c WHERE Id =: req.params.get('targetConnection')]) {
                        String connectionIdString = '';
                        connection.Comparing_Connections__c = connection.Comparing_Connections__c == null ? '' : connection.Comparing_Connections__c;
                        for(String connectionId : connection.Comparing_Connections__c.split(','))
                            if(connectionId != req.params.get('Connection_Id')  && connectionId.trim() != '')
                                connectionIdString += connectionIdString == '' ? connectionId : ',' + connectionId;
                        connection.Comparing_Connections__c = connectionIdString;
                        connectionList.add(connection);
                    }
                }
                update connectionList; 

                return 'Success';
            }
        }
        catch(Exception ex) {
            return 'Failure : '+ ex.getMessage();
        }  
        return 'Success';
   }
}