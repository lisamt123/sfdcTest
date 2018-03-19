global class AchievementLeadSyncSchedule implements Schedulable 
{
    global void execute(SchedulableContext sc) 
    {
        Map<Id,String> leadIdMap = new Map<Id,String>();
        //Datetime 
        Integer recordLimit = Endpoint_URIs__c.getOrgDefaults().Limit_of_Records_Sync__c != null ? (Integer) Endpoint_URIs__c.getOrgDefaults().Limit_of_Records_Sync__c : 5;
        for(Lead selectedLead : [SELECT Id,Last_Achievement_Sync__c 
                                FROM Lead 
                                WHERE IsConverted = false AND ( Webassessor_Email__c != null OR Trailhead_User_Id__c != null ) AND (Last_Achievement_Sync__c = null OR Last_Achievement_Sync__c <= : Datetime.now() - 1) 
                                ORDER BY Last_Achievement_Sync__c LIMIT: recordLimit])
        {
            leadIdMap.put(selectedLead.id,'both');
        }
        Id batchInstanceId = Database.executeBatch(new AchievementSyncBatch(leadIdMap,false,'Lead'), 1); 
    }
}