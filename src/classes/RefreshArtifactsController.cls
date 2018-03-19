public with sharing class RefreshArtifactsController {
	public String responseMessage {get;set;}
	private Connection__c connection;
	public RefreshArtifactsController(ApexPages.StandardController std) {
		connection = [SELECT Id, Created_On_Heroku__c FROM Connection__c WHERE Id=: std.getId() ];
		if(!connection.Created_On_Heroku__c) 
			responseMessage = 'Please Authorize the connection before refreshing.';
	}
	public void refreshArtifacts() {
		responseMessage = ManageArtifactsLightning.refreshArtifacts(connection.Id);
	}

	public PageReference redirectBackToConnection() {
		connection = [SELECT Id, Created_On_Heroku__c, Refresh_Running__c FROM Connection__c WHERE Id=: connection.Id ];
        PageReference connectionDetail = new ApexPages.StandardController(connection).view();
        connectionDetail.setRedirect(true);
        return connectionDetail;
    }
}