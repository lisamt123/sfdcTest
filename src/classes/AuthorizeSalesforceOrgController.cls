public with sharing class AuthorizeSalesforceOrgController {

    public String errorMessage          {get;set;}
    public String accessToken           {get;set;}
    public String connectionName        {get;set;}
    public String remoteSiteSettingUrl  {get;set;}
    public Connection__c connection     {get;set;}

    @TestVisible private String code;
    @TestVisible private String githubAppKey;
    @TestVisible private String githubAppSecret;
    @TestVisible private Boolean isUpdate;
    @TestVisible private ResponseWrapper responseWrapper;
    @TestVisible private StateWrapper stateWraper;
    @TestVisible private String redirectUri;
    //@TestVisible private ConnectedApp__c credentials = ConnectedApp__c.getOrgDefaults();
    @TestVisible private Heroku_oAuth_Setting__mdt credentials;

    public AuthorizeSalesforceOrgController(ApexPages.StandardController std) {
    	
    	Organization orgz = [SELECT IsSandbox FROM Organization LIMIT 1];
		credentials = [SELECT ID, QualifiedApiName, Callback_URL__c, Call_back_Url_Community__c, Consumer_Key__c, 
                        Consumer_Secret__c, Heroku_URL__c, Github_URL__c, Github_Consumer_Key__c, Github_Consumer_Secret__c,
                        Github_Community_Consumer_Key__c, Github_Community_Consumer_Secret__c
                      FROM Heroku_oAuth_Setting__mdt 
                      WHERE IsSandbox__c =: orgz.IsSandbox LIMIT 1];
		
        isUpdate        = false;
        User currentUser = [SELECT Id,ContactId FROM User WHERE Id =: UserInfo.getUserId() ];
        if(currentUser.ContactId != null) {
            redirectUri     = credentials.Call_back_Url_Community__c;
            githubAppKey    = credentials.Github_Community_Consumer_Key__c;
            githubAppSecret = credentials.Github_Community_Consumer_Secret__c;
        }
        else {
            redirectUri     = credentials.Callback_URL__c;
            githubAppKey    = credentials.Github_Consumer_Key__c;
            githubAppSecret = credentials.Github_Consumer_Secret__c;
        }
        if(std.getRecord().Id != null) {
            connection  = [SELECT Id, Name, Project__c, Project__r.Name, RecordTypeId, Created_On_Heroku__c, Metadata_Describe_Error__c,Organization_URL__c, Status__c
                            FROM Connection__c 
                            WHERE Id =: std.getRecord().Id];
        }
        else {
            connection = new Connection__c(Name = 'test');
        }
        connectionName  = connection.Name.replace(' ','_');
        code            = ApexPages.currentPage().getParameters().get('code');
        errorMessage    = ApexPages.currentPage().getParameters().get('error');
        if(code != null ||  errorMessage != null)
            retrieveTokens(); 
    }

    public PageReference retrieveAuthCode() {
        
        String endPoint;
        if(connection.RecordTypeId == Constants.RECORDTYPEID_CONNECTION_PRODICTION)
            endPoint = 'https://login.salesforce.com';
        else if (connection.RecordTypeId == Constants.RECORDTYPEID_CONNECTION_SANDBOX)
            endPoint = 'https://test.salesforce.com';
        else if (connection.RecordTypeId == Constants.RECORDTYPEID_CONNECTION_OTHER)
            endPoint = connection.Organization_URL__c;
        else if(connection.RecordTypeId == Constants.RECORDTYPEID_CONNECTION_GITHUB)
            endPoint = credentials.Github_URL__c + 'authorize?client_id='+githubAppKey+'&redirect_uri='+redirectUri+'&fingerprint=looogin&state=' + 
                        EncodingUtil.urlEncode(JSON.serialize(new StateWrapper(credentials.Github_URL__c,connection.Id)),'UTF-8') + '&scope=repo,public_repo,write:org' ;

        if(connection.RecordTypeId != Constants.RECORDTYPEID_CONNECTION_GITHUB)
            endPoint += '/services/oauth2/authorize?response_type=code&client_id=' + credentials.Consumer_Key__c + '&redirect_uri=' + redirectUri + 
                    '&prompt=login consent&=true&state=' + EncodingUtil.urlEncode(JSON.serialize(new StateWrapper(endPoint,connection.Id)),'UTF-8'); //encodeendPoint + '#' + connection.id;
        return new PageReference(endPoint);
    }

    public boolean isLightningExperience() {
        if(Apexpages.currentPage().getParameters().get('sfdcIFrameOrigin') != null)
            return true;
        return false;
    }

    public void retrieveTokens() {
        if(errorMessage != 'access_denied') 
            errorMessage = '';
        String state    = ApexPages.currentPage().getParameters().get('state');
        if(state != null) {
            stateWraper = (StateWrapper) JSON.deserialize(EncodingUtil.urlDecode(state, 'UTF-8'), StateWrapper.class);
            connection  = [SELECT Id, Name, Project__c, Project__r.Name, RecordTypeId, Created_On_Heroku__c, Metadata_Describe_Error__c,Organization_URL__c
                            FROM Connection__c 
                            WHERE Id =: stateWraper.connectionId];
        }
        connectionName          = connection.Name.replace(' ','_');
        remoteSiteSettingUrl    = connection.Organization_URL__c;
        if(code != null && code != '' && state != null) {
            String endPoint         =  stateWraper.endpoint;
            String requestJSONBody  = '';
            if(connection.RecordTypeId != Constants.RECORDTYPEID_CONNECTION_GITHUB) {
                endPoint += '/services/oauth2/token?grant_type=authorization_code' +
                            '&code='            + EncodingUtil.urlEncode(code,'UTF-8') +
                            '&redirect_uri='    + EncodingUtil.urlEncode(redirectUri,'UTF-8') +
                            '&client_id='       + EncodingUtil.urlEncode(credentials.Consumer_Key__c,'UTF-8') +
                            '&client_secret='   + EncodingUtil.urlEncode(credentials.Consumer_Secret__c,'UTF-8');
                requestJSONBody = null;
            } 
            else {
                endPoint += 'access_token';
                requestJSONBody = '{"client_id": "'     + EncodingUtil.urlEncode(githubAppKey,'UTF-8') +'",'+
                                  '"client_secret": "'  + EncodingUtil.urlEncode(githubAppSecret,'UTF-8') +'",'+
                                  '"code": "'           + EncodingUtil.urlEncode(code,'UTF-8') +'",'+
                                  '"redirect_uri": "'   + redirectUri +'"}';
            }
            HttpResponse res;
            try {
                res =  sendRequest(endpoint,requestJSONBody);
            }
            catch(Exception ex) {
                if(ex.getMessage().contains('Unauthorized endpoint'))
                    errorMessage = ex.getMessage();
            }
            try {
                responseWrapper = (ResponseWrapper) JSON.deserialize(res.getBody(), AuthorizeSalesforceOrgController.ResponseWrapper.class);
                if(responseWrapper != null && state != null)
                    isUpdate = true;
            }                               
            catch(Exception ex) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, ex.getMessage()));
            }
        }
        if(errorMessage != null && errorMessage != '') {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, errorMessage));
        }
    }

    public PageReference redirectBackToConnection() {
        String state    = ApexPages.currentPage().getParameters().get('state');
        if(state != null) {
            stateWraper = (StateWrapper) JSON.deserialize(EncodingUtil.urlDecode(state, 'UTF-8'), StateWrapper.class);
            connection  = [SELECT Id, Name, RecordTypeId, Created_On_Heroku__c, Metadata_Describe_Error__c,Organization_URL__c,Status__c
                            FROM Connection__c 
                            WHERE Id =: stateWraper.connectionId];
        }
        PageReference connection = new ApexPages.StandardController(connection).view();
        connection.setRedirect(true);
        return connection;
    }
    public PageReference updateConnection() {
        if(errorMessage == 'access_denied')
            redirectBackToConnection();
        if(code == null && errorMessage == null)
           return retrieveAuthCode();
        if(isUpdate) {
            //update connection;
            if(connection.RecordTypeId == Constants.RECORDTYPEID_CONNECTION_GITHUB) {
                errorMessage    = 'github';
                accessToken     = responseWrapper.access_token;
            }
            else {
                createConnectionRecord();
                return redirectBackToConnection();
            }
        }
        return null;
    }

    public void createConnectionRecord() {
        HttpResponse res;
        String requestJSONBody =  '"Organization_Id":"",'+
                                  '"Connection_Type":"Salesforce",'+
                                  '"repo":"",'+
                                  '"project":"'                     + connection.Project__c + '",'+
                                  '"Organization_URL":"'            + responseWrapper.instance_url +'",'+
                                  '"Access_Token":"'                + responseWrapper.access_token +'",'+ 
                                  '"Refresh_Token":"'               + responseWrapper.refresh_token +'",'+
                                  '"Development_Environment_URL":"' + System.URL.getSalesforceBaseUrl().toExternalForm() +'",'+
                                  '"Site_URL":"'                    + Label.Site_URL + '"';
        if(connection.Created_On_Heroku__c) {
            requestJSONBody += ',"Action":"Update"';
            res = RestRequestHandlerForHeroku.sendRequest('PUT','Connection_Update',requestJSONBody,connection.Id,connection.Project__c,connection.Project__r.Name);
        }
        else {
            requestJSONBody += ',"Connection_Id":"'+ connection.Id + '"';
            res = RestRequestHandlerForHeroku.sendRequest('POST','Connection_Create',requestJSONBody,'',connection.Project__c,connection.Project__r.Name);
        }
        
        if(res.getStatusCode() == 200 ) {
            ConnectionResponseWrapper response = (ConnectionResponseWrapper) JSON.deserialize(EncodingUtil.urlDecode(res.getBody(), 'UTF-8'), ConnectionResponseWrapper.class);
            
            if(response.status == 'Success') {
                connection.Refresh_Running__c           = true;
                connection.Metadata_Describe_Error__c   = '';
                connection.Created_On_Heroku__c         = true;
            }
            else
                connection.Metadata_Describe_Error__c = response.message;
        }
        update connection;
    }
    private HttpResponse sendRequest(String endpoint,String requestJSONBody) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setTimeOut(120000);
        if(requestJSONBody != null) {
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');
            req.setBody(requestJSONBody );
        }
        Http h = new Http();
        String resp;
        HttpResponse res = h.send(req);
        system.debug(res);
        system.debug(res.getBody());
        return res;
    }

    public class ResponseWrapper {
        public String access_token;
        public String refresh_token;
        public String signature;
        public String scope;
        public String id_token;
        public String instance_url;
        public String id;
        public String token_type;
        public String issued_at;
        public String status;
        public String message;
    }

    public class StateWrapper {
        public String endpoint;
        public Id connectionId;

        public StateWrapper(String endpoint,Id connectionId) {
            this.endpoint       = endpoint;
            this.connectionId   = connectionId;     
        }
    }
    public class ConnectionResponseWrapper {
        public String message;
        public String status;
    }
}