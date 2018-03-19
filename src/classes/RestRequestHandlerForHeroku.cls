public with sharing class RestRequestHandlerForHeroku {
	public static HttpResponse sendRequest(String method,String herokuEndpoint, String requestJSONBody, String recId, String projectId, String projectName) {
		Map<String, String> herokuEndpointsMap  = new Map<String, String>();
        Organization orgz                       = [SELECT IsSandbox FROM Organization LIMIT 1];
        Heroku_oAuth_Setting__mdt credentials   = [SELECT ID, QualifiedApiName, Heroku_URL__c  
                                                    FROM Heroku_oAuth_Setting__mdt 
                                                    WHERE IsSandbox__c =: orgz.IsSandbox LIMIT 1];
        for(Heroku_Endpoint__mdt endpoint : [SELECT ID, QualifiedApiName, Endpoint__c FROM Heroku_Endpoint__mdt])
            herokuEndpointsMap.put(endpoint.QualifiedApiName, endpoint.Endpoint__c);

        User currentUser 			= [SELECT Id, Name, ContactId FROM User WHERE Id =: UserInfo.getUserId() ];
        List<Contact> contactList 	= [SELECT Id, Account.Name, AccountId FROM Contact WHERE Id =: currentUser.ContactId ];
        String token    			= HerokuToken.headerToken();
        String requestEndpoint 		= credentials.Heroku_URL__c + herokuEndpointsMap.get(herokuEndpoint) + ( recId != '' && recId != null ? recId : '') ;
        Http h          			= new Http();
        HttpRequest request 		= new HttpRequest();
        String requestJSONFinalBody	= '{' + (requestJSONBody == '' ? requestJSONBody :  requestJSONBody + ',') +
        							  '"Project_Id":"'   + projectId +'",'+
                                      '"Project_Name":"' + projectName +'",'+
        							  '"User_Id":"'      + currentUser.Id +'",'+
                                 	  '"User_Name":"'    + currentUser.Name +'",'+
                                      '"Account_Id":"'   + (contactList.size() > 0 ? contactList[0].AccountId : null) +'",'+
                                      '"Account_Name":"' + (contactList.size() > 0 ? contactList[0].Account.Name : null)  +'"}';
        request.setEndpoint(requestEndpoint);
        request.setMethod(method);
        request.setHeader('Content-Type', 'application/json');
        request.setBody(requestJSONFinalBody );
        request.setHeader('token',token); 
        request.setTimeOut(120000);

        HttpResponse response = h.send(request);
        System.debug('==========> request ---------'+requestJSONFinalBody);
        System.debug('==========> record id ---------' + recId);
        System.debug('==========> ' + herokuEndpoint + '---------' + response);
        System.debug('==========> ' + herokuEndpoint + '---------' + response.getBody());

        return response;
	}
}