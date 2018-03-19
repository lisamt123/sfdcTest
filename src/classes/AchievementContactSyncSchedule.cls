global class AchievementContactSyncSchedule implements Schedulable 
{
    global void execute(SchedulableContext sc) 
    {
        Map<Id,String> contactIdMap = new Map<Id,String>();
        Integer recordLimit = Endpoint_URIs__c.getOrgDefaults().Limit_of_Records_Sync__c != null ? (Integer) Endpoint_URIs__c.getOrgDefaults().Limit_of_Records_Sync__c : 5;
        for(Contact selectedContact : [SELECT Id,Last_Achievement_Sync__c FROM Contact WHERE (Webassessor_Email__c != null OR Trailhead_User_Id__c != null)  AND (Last_Achievement_Sync__c = null OR Last_Achievement_Sync__c <= : Datetime.now() - 6)  ORDER BY Last_Achievement_Sync__c LIMIT: recordLimit])
        {
            contactIdMap.put(selectedContact.id,'both');
        }
        Id batchInstanceId = Database.executeBatch(new AchievementSyncBatch(contactIdMap,false,'Contact'), 1); 
    }
}