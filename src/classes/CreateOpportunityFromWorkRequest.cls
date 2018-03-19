global class CreateOpportunityFromWorkRequest
{
    webservice static String createOpportunity(String currentId)
    {
        Project_Request__c projectReq = [SELECT Id, Account__c, Project_Name__c, Account__r.id, Account__r.Name, Project__r.Name,Name,   Request_Contact__c,Description__c FROM Project_Request__c WHERE id =: currentId LIMIT 1];
        List<RecordType> recType = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Services_Opportunity'];
        String message;
        Date d = Date.today()+14;
        d = Date.newInstance(d.year(), d.month(), d.day());

        Opportunity opp = new Opportunity();
        opp.StageName = 'Active';
        String oppName = '';
        if(projectReq.Project_Name__c == null || projectReq.Project_Name__c == '')
        {
            oppName = projectReq.Account__r.Name;
        }
        else
        {
            oppName = projectReq.Account__r.Name+'-'+projectReq.Project_Name__c;
        }
        
        if(oppName.length() > 80)
        {
           oppName = oppName.substring(0, 80); 
        }
        opp.Name = oppName;
        opp.AccountId = projectReq.Account__c;
        opp.RecordTypeId = recType[0].Id;
        opp.CloseDate = d;
        opp.Amount = 0.0;
        opp.Description = projectReq.Description__c;

        try { 
            insert opp; 
            OpportunityContactRole primaryContactRole = new OpportunityContactRole(ContactId = projectReq.Request_Contact__c,IsPrimary = true,OpportunityId = opp.Id,Role='Other');
            insert primaryContactRole;
        }
        catch(DmlException ex) { message = ex.getMessage(); }
        System.debug(opp.Id);
        if((String)opp.Id == '')
        {
            return 'Failed to create Opportunity : '+message;
        }

        projectReq.Opportunity__c = opp.Id;
        update projectReq;

        return 'Success';
    }
}