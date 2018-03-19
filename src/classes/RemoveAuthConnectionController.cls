public class RemoveAuthConnectionController{

    @TestVisible private Connection__c connection ;
    
    public  RemoveAuthConnectionController(ApexPages.StandardController connectionCont) {
        connection = (Connection__c)connectionCont.getRecord();
    }
    
    @RemoteAction
    public static String removeAuth(Id connection_Id) { 
        Connection__c con = [SELECT Id, Project__c, Project__r.Name, Status__c, RecordTypeId FROM Connection__c WHERE Id =: connection_Id];
        String message = null;
        String connectionType;
        if(con.RecordTypeId != Constants.RECORDTYPEID_CONNECTION_GITHUB) 
            connectionType = 'Salesforce';
        else 
            connectionType = 'Github';
        String requestJSONBody =  '"Action":"Remove",'+
                                  '"Connection_Type":"'+ connectionType + '"';
        
        HttpResponse res = RestRequestHandlerForHeroku.sendRequest('PUT','Connection_Update',requestJSONBody,con.Id,con.Project__c,con.Project__r.Name);
        if(res.getStatusCode() == 200 ) {
            ConnectionResponseWrapper response = (ConnectionResponseWrapper) JSON.deserialize(EncodingUtil.urlDecode(res.getBody(), 'UTF-8'), ConnectionResponseWrapper.class);
            message = response.message;
            if(response.status == 'Success') {
                con.Status__c = 'Disabled';
                update con;
            }
        }
        return message;
    }
    
    public PageReference returnBack() {
        Connection__c currentConnection = [SELECT ID FROM Connection__c WHERE Id =: connection.Id ];
        PageReference connectionPage = new ApexPages.StandardController(currentConnection).view();
        connectionPage.setRedirect(true);
        return connectionPage;
    }
    
    public class ConnectionResponseWrapper {
        public String message;
        public String status;
    }
}