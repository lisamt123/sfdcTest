public with sharing class MetadataComparisonLightning {
    @AuraEnabled
    public static List<SelectOptionCustom> retrieveConnectionData(String recId) { 
        List<SelectOptionCustom> connectionOptions = new List<SelectOptionCustom>();
        Connection__c selectedConnection = [SELECT Id, Name, Project__c, Project__r.Name FROM Connection__c WHERE Id =: recId];
        connectionOptions.add(new SelectOptionCustom('','--None--'));
        for(Connection__c connection : [SELECT Id, Name, Project__c 
                                        FROM Connection__c 
                                        WHERE Project__c =: selectedConnection.Project__c
                                            AND RecordTypeId !=: Constants.RECORDTYPEID_CONNECTION_GITHUB])
            connectionOptions.add(new SelectOptionCustom(connection.Id,connection.Name));

        return connectionOptions;
    }

    @AuraEnabled
    public static Connection__c retrieveConnection(String recId) { 
        Connection__c selectedConnection = [SELECT Id, Name, Comparing_Connections__c FROM Connection__c WHERE Id =: recId];
        return selectedConnection;
    }

    @AuraEnabled
    public static MetadataResponse retrieveConnectionMetaData(String recId, String secondConnection) {
        Connection__c selectedConnection = [SELECT Id, Project__c, Project__r.Name FROM Connection__c WHERE Id =: recId];

        String requestJSONBody = '"targetConnection":"' + secondConnection +'"';
        HttpResponse res = RestRequestHandlerForHeroku.sendRequest('POST','Connection_MetadataTypes',requestJSONBody,recId,selectedConnection.Project__c,selectedConnection.Project__r.Name);

        if(res.getStatusCode() == 200)
            return (MetadataResponse) JSON.deserialize(res.getBody(), MetadataResponse.class);
        return null;
    }

    @AuraEnabled
    public static MetadataResponse retrieveConnectionMetaDataList(String recId, String secondConnection, String metadataType) {
        Connection__c selectedConnection = [SELECT Id, Project__c, Project__r.Name FROM Connection__c WHERE Id =: recId];

        String requestJSONBody = '"targetConnection":"'     + secondConnection + '",' +
                                 '"metadataType":"'     + metadataType + '"';
        HttpResponse res = RestRequestHandlerForHeroku.sendRequest('POST','Connection_MetadataType_Artifact',requestJSONBody,recId,selectedConnection.Project__c,selectedConnection.Project__r.Name);

        if(res.getStatusCode() == 200)
            return (MetadataResponse) JSON.deserialize(res.getBody(), MetadataResponse.class);
        return null;
    }

    @AuraEnabled
    public static MetadataResponse compareMetadataType(String recId, String secondConnection) {
        List<Connection__c> selectedConnections = [SELECT Id, Project__c, Project__r.Name, Comparing_Connections__c FROM Connection__c WHERE Id =: recId OR Id =: secondConnection];

        String requestJSONBody = '"targetConnection":"' + secondConnection + '"';
        HttpResponse res = RestRequestHandlerForHeroku.sendRequest('POST','Connection_Compare',requestJSONBody,recId,selectedConnections[0].Project__c,selectedConnections[0].Project__r.Name);
        if(res.getStatusCode() == 200) {
            if(recId == secondConnection) {
            	selectedConnections[0].Comparing_Connections__c = updateComparingConnections(secondConnection,selectedConnections[0].Comparing_Connections__c);
            }
            else if(selectedConnections[0].Id == recId) {
                selectedConnections[0].Comparing_Connections__c = updateComparingConnections(secondConnection,selectedConnections[0].Comparing_Connections__c);
                selectedConnections[1].Comparing_Connections__c = updateComparingConnections(recId,selectedConnections[1].Comparing_Connections__c);
            }
            else {
                selectedConnections[0].Comparing_Connections__c = updateComparingConnections(recId,selectedConnections[0].Comparing_Connections__c);
                selectedConnections[1].Comparing_Connections__c = updateComparingConnections(secondConnection,selectedConnections[1].Comparing_Connections__c);
            }
            
            update selectedConnections;
            return (MetadataResponse) JSON.deserialize(res.getBody(), MetadataResponse.class);
        }
        return null;
    }

    public static String updateComparingConnections(String recId,String comparingConnections) {
    	if(comparingConnections == null || comparingConnections == '')
    		return recId;
    	else if(comparingConnections.contains(recId))
    		return comparingConnections;
    	else
    		return comparingConnections + ',' + recid;

    }

    @AuraEnabled
    public static MetadataCompareResponse retrieveMetadata(String recId, String secondConnection,String metadataType, String sourceArtifact, String targetArtifact) {
        List<Connection__c> selectedConnections = [SELECT Id, Name, Project__c, Project__r.Name FROM Connection__c WHERE Id =: recId OR Id =: secondConnection];

        String requestJSONBody = '"targetConnection":"' + secondConnection + '",'+
        						 '"metadataType":"' 	+ metadataType + '",'+
        						 '"sourceArtifact":"' 	+ sourceArtifact + '",'+
  						 		 '"targetArtifact":"' 	+ targetArtifact + '"';
        HttpResponse res = RestRequestHandlerForHeroku.sendRequest('POST','Connection_ArtifactData',requestJSONBody,recId,selectedConnections[0].Project__c,selectedConnections[0].Project__r.Name);
        if(res.getStatusCode() == 200) {
        	MetadataCompareResponse metadataCompareResp = (MetadataCompareResponse) JSON.deserialize(res.getBody(), MetadataCompareResponse.class);
        	if(recId == secondConnection) {
                metadataCompareResp.targetConnectionName = selectedConnections[0].Name;
                metadataCompareResp.sourceConnectionName = selectedConnections[0].Name;
            }
            else if(selectedConnections[0].Id == recId) {
                metadataCompareResp.targetConnectionName = selectedConnections[1].Name;
                metadataCompareResp.sourceConnectionName = selectedConnections[0].Name;
            }
            else {
                metadataCompareResp.targetConnectionName = selectedConnections[0].Name;
                metadataCompareResp.sourceConnectionName = selectedConnections[1].Name;
            }
            return metadataCompareResp;
        }
        return null;
    }

    public class MetadataCompareResponse {
        @AuraEnabled public String status;
        @AuraEnabled public String targetArtifactData;
        @AuraEnabled public String sourceArtifactData;
        @AuraEnabled public String targetConnectionName {get;set;}
        @AuraEnabled public String sourceConnectionName {get;set;}
    }

    public class MetadataResponse {
        @AuraEnabled public String status;
        @AuraEnabled public String runningStatus;
        @AuraEnabled public List<String> metadataList;
        @AuraEnabled public List<ArtifactList> artifactList;
        @AuraEnabled public String logTime {get;set{
                logTime = value.replace(' ','T') + 'Z';
            }
        }
    }

    public class ArtifactList {
        @AuraEnabled public String artifactSource;
        @AuraEnabled public String compareStatus;
        @AuraEnabled public String artifactTarget;
    }

    public class SelectOptionCustom {
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}
        
        public SelectOptionCustom(String value,String label){
            this.value = value;
            this.label = label;
        }
    }
}