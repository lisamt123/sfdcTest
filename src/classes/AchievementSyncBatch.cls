/**
*   Name          : AchievementSyncBatch 
*   Dated         : 6 July, 2016
*   Author        : BM
*   Useges        : Batch used to sync achievements. 
*/
global class AchievementSyncBatch implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful
{
    String query;
    Boolean isForceSync;
    Map<Id,String> sObjectIdMap;
    List<Id> sObjectIdList;
    //Id devRecordTypeId;
    String objectName;
    global AchievementSyncBatch(Map<Id,String> sObjectIdMap,Boolean isForceSync,String objectName) 
    {
        this.isForceSync    = isForceSync;
        this.sObjectIdMap   = sObjectIdMap;
        this.objectName     = objectName;
        sObjectIdList       = new List<Id>(sObjectIdMap.keySet());
        //devRecordTypeId   = Schema.SObjectType.Achievement__c.getRecordTypeInfosByName().get('Trailhead Badge').getRecordTypeId();
        if(objectName == 'Contact')
            query               = 'SELECT Id,Webassessor_Email__c,Updated_Created_From_Lead__c FROM ' + objectName +' WHERE id IN : sObjectIdList';
        else
            query               = 'SELECT Id,Webassessor_Email__c FROM ' + objectName +' WHERE id IN : sObjectIdList';

    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) 
    {
        List<Id> sObjectIdListForBoth           = new List<Id>();
        List<Id> sObjectIdListForCertificate    = new List<Id>();
        List<Id> sObjectIdListForBadges         = new List<Id>();
        Set<Id> parentIdSet                     = new Set<Id>();
        for(sObject obj: scope)
        {
            parentIdSet.add(obj.Id);
            if(sObjectIdMap.get(obj.Id) == 'both')
                sObjectIdListForBoth.add(obj.Id);
            if(sObjectIdMap.get(obj.Id) == 'certificate')
                sObjectIdListForCertificate.add(obj.Id);
            if(sObjectIdMap.get(obj.Id) == 'badge')
                sObjectIdListForBadges.add(obj.Id);
        }
        List<sObject> sObjectList = new List<sObject>();
        AchievementSyncUtility ach = new AchievementSyncUtility();

        if(sObjectIdListForBoth.size() > 0)
        {
            sObjectList.addAll(ach.syncSalesforceCertifications(sObjectIdListForBoth,isForceSync,objectName));
            sObjectList.addAll(ach.syncTrailheadBadges(sObjectIdListForBoth,objectName));
        }
        if(sObjectIdListForCertificate.size() > 0 && !Test.isRunningTest())
            sObjectList.addAll(ach.syncSalesforceCertifications(sObjectIdListForCertificate,isForceSync,objectName));
        if(sObjectIdListForBadges.size() > 0 )
            sObjectList.addAll(ach.syncTrailheadBadges(sObjectIdListForBadges,objectName));

        if(sObjectList.size() > 0)
        {

            List<sObject> listToUpdate      = new List<sObject>();
            List<sObject> listToInsertFirst = new List<sObject>();
            List<sObject> listToInsert      = new List<sObject>();
            List<sObject> listToDelete      = new List<sObject>();
            
            // Added By New list to Update Holder By Ak
            List<sObject> listToUpdateHolder      = new List<sObject>();
            
            for(sObject sobj : sObjectList) 
            {
                if(sobj.Id == null && sobj.getSObjectType() == Achievement__c.getSObjectType())
                    listToInsertFirst.add(sobj);
                else if(sobj.Id != null && sobj.getSObjectType() == Expert_Achievement__c.getSObjectType() && sobj.get('Status__c') == 'Delete' )
                    listToDelete.add(sobj);
                else if(sobj.Id != null && sobj.getSObjectType() == Expert_Achievement__c.getSObjectType() && sobj.get('Status__c') == 'UpdateHolderName' ){
                    sobj.put('Status__c','Active');
                    listToUpdateHolder.add(sobj);
                }
                else if(sobj.Id != null && sobj.getSObjectType() == Contact.getSObjectType())
                {
                    sobj.put('Updated_Created_From_Lead__c',false);
                    listToUpdate.add(sobj);
                }
                else if(sobj.Id != null )
                    listToUpdate.add(sobj);
                else 
                    listToInsert.add(sobj);
            }

            update listToUpdate;
            insert listToInsertFirst;
            update listToUpdateHolder;
            Map<String,Id> achievementNameMap = new Map<String,Id>();
            for(sObject obj : listToInsertFirst)
            {
                achievementNameMap.put((String)obj.get('Name'),obj.Id);
            }
            for(sObject obj : listToInsert)
            {
                if(achievementNameMap.keySet().contains((String)obj.get('Status__c')))
                {
                    obj.put('Achievement__c',achievementNameMap.get((String)obj.get('Status__c')));
                    obj.put('Status__c','Active');
                }
            }
            insert listToInsert;
            delete listToDelete;
        }
        List<sObject> sobjList = new List<sObject>();
        for(sObject sobj: Database.query('SELECT Id,Last_Achievement_Sync__c FROM ' + objectName + ' WHERE Id IN: parentIdSet'))
        {
            sobj.put('Last_Achievement_Sync__c',Datetime.now());
            sobjList.add(sobj);
        }
        update sobjList;
    }
    global void finish(Database.BatchableContext BC) 
    {}
}