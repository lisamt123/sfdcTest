public class DeleteConnectionBatch implements Database.Batchable<Connection__c>,Database.AllowsCallouts{

   //chunk of 200 connection from trigger handler	   	
   private List<Connection__c> connectionToDeleteList;

   public DeleteConnectionBatch(List<Connection__c> connectionToDeleteList){
       this.connectionToDeleteList = connectionToDeleteList;
   }

   public List<Connection__c> start(Database.BatchableContext BC){
   	  System.debug(connectionToDeleteList);
   	  System.debug('size :' +connectionToDeleteList.size());
      return connectionToDeleteList;
   }

   public void execute(Database.BatchableContext BC, List<Connection__c> scope){
	   System.assertEquals(true, scope.size() <= 100);
	   
	   Organization orgz = [SELECT IsSandbox FROM Organization LIMIT 1];
	   Heroku_oAuth_Setting__mdt credentials = [SELECT ID, QualifiedApiName, Heroku_URL__c  FROM Heroku_oAuth_Setting__mdt WHERE IsSandbox__c =: orgz.IsSandbox LIMIT 1];
										
	   Map<String, String> herokuEndpointsMap  = new Map<String, String>();
		
	   for(Heroku_Endpoint__mdt endpoint : [SELECT ID, QualifiedApiName, Endpoint__c FROM Heroku_Endpoint__mdt]){
			herokuEndpointsMap.put(endpoint.QualifiedApiName, endpoint.Endpoint__c);
	   }
		
	   Http h; 
	   HttpRequest req;
       for(Connection__c connection : scope) {
       	   String token = HerokuToken.headerToken();
       	   
       	   h = new Http();	
		   req = new HttpRequest();
	       req.setEndpoint(credentials.Heroku_URL__c + herokuEndpointsMap.get('Connection_Delete') + connection.Id);
		   req.setMethod('GET');
		   req.setHeader('token',token);
		   req.setTimeOut(120000);
		
		   HttpResponse res = h.send(req);
		   System.debug(res);
		   System.debug(res.getBody());
       }
   }

   public void finish(Database.BatchableContext BC){
   		//Nothing to do	here
   }
}