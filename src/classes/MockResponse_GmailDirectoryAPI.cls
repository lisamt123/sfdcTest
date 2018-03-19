@isTest
public class MockResponse_GmailDirectoryAPI implements HttpCalloutMock {
    
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest req) {
        
        HttpResponse res = new HttpResponse();

        //For SaveToken callout
        if(req.getEndpoint() == 'https://accounts.google.com/o/oauth2/token' && req.getMethod() == 'POST' && req.getBody().contains('grant_type=authorization_code')){
            res = returnSaveTokens();
        }
        //For RefreshToken Callout
        else if(req.getEndpoint() == 'https://accounts.google.com/o/oauth2/token' && req.getMethod() == 'POST' && req.getBody().contains('grant_type=refresh_token')){
            res = returnRefreshedAccessToken();
        }
        //For CreateUser callout
        else if(req.getEndpoint() == 'https://www.googleapis.com/admin/directory/v1/users' && req.getMethod() == 'POST'){
            res = returnCreatedGoogleUser();
        }
        //for fetching existing user callout
        else if(req.getEndpoint().contains('https://www.googleapis.com/admin/directory/v1/users') && req.getMethod() == 'GET'){
            res = returnUser();
        }
        //for suspendUser callout
        else if(req.getEndpoint().contains('https://www.googleapis.com/admin/directory/v1/users') && req.getMethod() == 'PUT' && req.getBody().contains('true')){
            res = returnSuspendedUser();
        }
        else if(req.getEndpoint().contains('https://www.googleapis.com/admin/directory/v1/users') && req.getMethod() == 'PUT' && req.getBody().contains('false')){
            res = returnUnSuspendedUser();
        }
        else if(req.getEndpoint().contains('https://www.googleapis.com/admin/datatransfer/v1/applications') && req.getMethod() == 'GET'){
            res = returnGoogleAppsUser();
        }
        else if(req.getEndpoint().contains('https://www.googleapis.com/admin/datatransfer/v1/transfers') && req.getMethod() == 'POST'){
            res = returnTransferAppResponse();
        }
        else if(req.getEndpoint().contains('https://www.googleapis.com/admin/directory/v1/users/') && req.getMethod() == 'DELETE'){
            res = returnDeleteUser();
        }
        
        return res;
    }
    
    
    
    public static HttpResponse returnRefreshedAccessToken(){ 
        
        HttpResponse httpResponse = new HttpResponse(); 
        httpResponse.setStatusCode(200); 
        httpResponse.setBody('{ "access_token" : "ya29.CjCYA4__2e6YY1bZzVa4-kIaVAMWtxVFuBpKzl7d_fKY0H2eZtz4ZDzVyL7fuFXxp8g","expires_in" : 3600,"token_type" : "Bearer"}'); 
        return httpResponse;
    }   
    
    public static HttpResponse returnCreatedGoogleUser(){ 
        
        HttpResponse httpResponse = new HttpResponse(); 
        httpResponse.setStatusCode(200); 
        httpResponse.setBody('{"kind": "admin#directory#user", "id": "113691240740537267825", "etag": "mVtRK5AeRZHHotPwF4vAn-nsx7I/aJoDDYbq4OKLqW6kSs3CO60WLxo", "primaryEmail": "RTestnonPortalContact@10kview-test.com", "name": {  "givenName": "Rajesh1",  "familyName": "Test non Portal Contact" }, "isAdmin": false, "isDelegatedAdmin": false, "creationTime": "2016-11-15T14:00:41.000Z", "suspended": true, "suspensionReason": "WEB_LOGIN_REQUIRED", "emails": [{"address": "rajeshkamath123@gmail.com", "type": "custom", "customType": "", "primary": false }],"phones": [{ "value": "111-111-1111", "type": "mobile"} ],"customerId": "C0351zg5w","orgUnitPath": "/","isMailboxSetup": false}'); 
        return httpResponse;
    }   
    
    public static HttpResponse returnUser(){ 
        
        HttpResponse httpResponse = new HttpResponse(); 
        httpResponse.setStatusCode(200); 
        httpResponse.setBody('{"kind": "admin#directory#user","id": "103005760348633131547","etag": "mVtRK5AeRZHHotPwF4vAn-nsx7I/rqpyZxdQTPHLSVWCpgE0qyyUe50","primaryEmail": "rtestnonportalcontact@10kview-test.com", "name": {  "givenName": "Rajesh1",  "familyName": "Test non Portal Contact",  "fullName": "Rajesh1 Test non Portal Contact" }, "isAdmin": false, "isDelegatedAdmin": false, "lastLoginTime": "1970-01-01T00:00:00.000Z", "creationTime": "2016-11-15T14:13:44.000Z", "agreedToTerms": true, "suspended": false, "changePasswordAtNextLogin": false, "ipWhitelisted": false, "emails": [  {   "address": "rajeshkamath123@gmail.com",   "type": "custom",   "customType": ""  },  {  "address": "rtestnonportalcontact@10kview-test.com",  "primary": true }], "phones": [{ "value": "111-111-1111", "type": "mobile" }],"customerId": "C0351zg5w","orgUnitPath": "/","isMailboxSetup": true, "includeInGlobalAddressList": true}'); 
        return httpResponse;
    }   
    
    public static HttpResponse returnSaveTokens(){ 
        
        HttpResponse httpResponse = new HttpResponse(); 
        httpResponse.setStatusCode(200); 
        httpResponse.setBody('{"kind": "admin#directory#token","etag": "xk_iBLBzFCnbhQvR8gbwRNxeTtA/cRsjKaKKwA4eRRXjS2pDtjK6Iew","clientId": "45360365731-ek83n98s3gakg6nomvef7c59krt840jk.apps.googleusercontent.com","displayText": "10K Project","anonymous": false,"nativeApp": false,"userKey": "110007436338075965814","scopes": ["https://www.googleapis.com/auth/admin.directory.user https://www.googleapis.com/auth/admin.datatransfer"]}'); 
        return httpResponse;
    } 
    
    public static HttpResponse returnSuspendedUser(){ 
        
        HttpResponse httpResponse = new HttpResponse(); 
        httpResponse.setStatusCode(200); 
        httpResponse.setBody('{ "kind": "admin#directory#user", "id": "103005760348633131547", "etag": "mVtRK5AeRZHHotPwF4vAn-nsx7I/TRQQc8aTdfNxrfUvmVbKysuRLuA", "primaryEmail": "rtestnonportalcontact@10kview-test.com", "name": {  "givenName": "Rajesh1",  "familyName": "Test non Portal Contact",  "fullName": "Rajesh1 Test non Portal Contact" }, "isAdmin": false, "isDelegatedAdmin": false, "lastLoginTime": "1970-01-01T00:00:00.000Z", "creationTime": "2016-11-15T14:13:44.000Z", "agreedToTerms": true, "suspended": true, "suspensionReason": "ADMIN", "changePasswordAtNextLogin": false, "ipWhitelisted": false, "emails": [ { "address": "rajeshkamath123@gmail.com", "type": "custom", "customType": ""  }, { "address": "rtestnonportalcontact@10kview-test.com",   "primary": true  } ], "phones": [  {  "value": "111-111-1111",  "type": "mobile"  } ], "nonEditableAliases": [ "rtestnonportalcontact@10kview-test.com.test-google-a.com" ], "customerId": "C0351zg5w", "orgUnitPath": "/", "isMailboxSetup": true, "includeInGlobalAddressList": true}'); 
        return httpResponse;
    } 
    
    public static HttpResponse returnUnSuspendedUser(){ 
        
        HttpResponse httpResponse = new HttpResponse(); 
        httpResponse.setStatusCode(200); 
        httpResponse.setBody('{ "kind": "admin#directory#user", "id": "107318881120986343037", "etag": "mVtRK5AeRZHHotPwF4vAn-nsx7I/sEgxYZkV3--y0pNv7PLtostAgBU", "primaryEmail": "rtestnonportalcontact@10kview-test.com", "name": {  "givenName": "Rajesh1",  "familyName": "Test non Portal Contact",  "fullName": "Rajesh1 Test non Portal Contact" }, "isAdmin": false, "isDelegatedAdmin": false, "lastLoginTime": "2016-11-15T14:26:02.000Z", "creationTime": "2016-11-15T14:24:23.000Z", "agreedToTerms": true, "suspended": false, "changePasswordAtNextLogin": false, "ipWhitelisted": false, "emails": [  {   "address": "rajeshkamath123@gmail.com",   "type": "custom",   "customType": ""  },  {   "address": "rtestnonportalcontact@10kview-test.com",   "primary": true  } ], "phones": [  {   "value": "111-111-1111",   "type": "mobile"  } ], "nonEditableAliases": [  "rtestnonportalcontact@10kview-test.com.test-google-a.com" ], "customerId": "C0351zg5w", "orgUnitPath": "/", "isMailboxSetup": true, "includeInGlobalAddressList": true}'); 
        return httpResponse;
    }
    
    public static HttpResponse returnGoogleAppsUser(){ 
        
        HttpResponse httpResponse = new HttpResponse(); 
        httpResponse.setStatusCode(200); 
        httpResponse.setBody('{ "kind": "admin#datatransfer#applicationsList", "etag": "Oe3A-aEzBDhJF9F0HWeUL2zDq6Y/zDy2pb-eyHGm84LAmKzXy6sP-mY", "applications": [ { "kind": "admin#datatransfer#ApplicationResource", "etag": "Oe3A-aEzBDhJF9F0HWeUL2zDq6Y/gpdrCNQ6mHfz_maHZIl4SYFeWYk", "id": "55656082996", "name": "Drive and Docs", "transferParams": [ { "key": "PRIVACY_LEVEL", "value": [ "SHARED", "PRIVATE" ] } ] }, { "kind": "admin#datatransfer#ApplicationResource", "etag": "Oe3A-aEzBDhJF9F0HWeUL2zDq6Y/jcCDiEJKoSnDd949jPKfZjvouzE", "id": "553547912911", "name": "Google+" } ] }'); 
        return httpResponse;
    }
    
    public static HttpResponse returnDeleteUser(){ 
        
        HttpResponse httpResponse = new HttpResponse(); 
        httpResponse.setStatusCode(204); 
        return httpResponse;
    }
    
    public static HttpResponse returnTransferAppResponse(){ 
        
        HttpResponse httpResponse = new HttpResponse(); 
        httpResponse.setStatusCode(200); 
        httpResponse.setBody('{ "kind": "admin#datatransfer#DataTransfer", "etag": "Oe3A-aEzBDhJF9F0HWeUL2zDq6Y/qsh2YOOHiAM8Lqu-QM1rV8mN5DQ", "id": "AKrEtIaSFpc-PE0mZ4nWmG76rqT-S6hbJnGa_WxWSX5jHphrfU36NigmXeLP-jb8CZUS-BXNTkTa", "oldOwnerUserId": "108751663743800169364", "newOwnerUserId": "116652677529088150603", "applicationDataTransfers": [ { "applicationId": "55656082996", "applicationTransferParams": [ { "key": "PRIVACY_LEVEL", "value": [ "PRIVATE", "SHARED" ] } ], "applicationTransferStatus": "pending" }, { "applicationId": "553547912911", "applicationTransferParams": [ { "key": "PRIVACY_LEVEL", "value": [ "PRIVATE", "SHARED" ] } ], "applicationTransferStatus": "pending" } ], "overallTransferStatusCode": "inProgress", "requestTime": "2017-08-10T10:35:56.303Z" }');
        return httpResponse;
    }
    
        
    
}