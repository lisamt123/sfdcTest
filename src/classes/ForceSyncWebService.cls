/**
*   Name          : ForceSyncWebService 
*   Dated         : 7 July, 2016
*   Author        : BM
*   Useges        : Webservice used by related list button (Sync Achievements) to sync achievements. 
*/
global class ForceSyncWebService {
    //--Method used to synch achievements.
    @AuraEnabled
    webservice static Boolean forceSync(String recordId) {
        //try 
       // { 
             
            String objectName = '';
            if(Id.valueOf(recordId).getSObjectType() == Contact.getSObjectType())
                objectName = 'Contact';
            else 
                objectName = 'Lead';

            List<sObject> sObjectList   = new List<sObject>();
            AchievementSyncUtility ach  = new AchievementSyncUtility();
            List<String> recordsIdList  = new List<String>{recordId};
            sObjectList.addAll(ach.syncSalesforceCertifications(recordsIdList,true,objectName));
            sObjectList.addAll(ach.syncTrailheadBadges(recordsIdList,objectName));

            
            if(sObjectList.size() > 0) {
                List<sObject> listToUpdate      = new List<sObject>();
                List<sObject> listToInsertFirst = new List<sObject>();
                List<sObject> listToInsert      = new List<sObject>();
                List<sObject> listToDelete      = new List<sObject>();
                
                // Added By New list to Update Holder By Ak
                List<sObject> listToUpdateHolder      = new List<sObject>();
            
                for(sObject sobj : sObjectList) {
                    if(sobj.Id == null && sobj.getSObjectType() == Achievement__c.getSObjectType())
                        listToInsertFirst.add(sobj);
                    else if(sobj.Id != null && sobj.getSObjectType() == Expert_Achievement__c.getSObjectType() && sobj.get('Status__c') == 'Delete' )
                        listToDelete.add(sobj);
                    else if(sobj.Id != null && sobj.getSObjectType() == Expert_Achievement__c.getSObjectType() && sobj.get('Status__c') == 'UpdateHolderName' ){
                        sobj.put('Status__c','Active');
                        listToUpdateHolder.add(sobj);
                    }
                    else if(sobj.Id != null )
                        listToUpdate.add(sobj);
                    else 
                        listToInsert.add(sobj);
                }

                update listToUpdate ;
                insert listToInsertFirst;
                update listToUpdateHolder;

                Map<String,Id> achievementNameMap = new Map<String,Id>();
                for(sObject obj : listToInsertFirst)
                    achievementNameMap.put((String)obj.get('Name'),obj.Id);
                for(sObject obj : listToInsert) {
                    if(obj.get('Achievement__c') == null)
                        obj.put('Achievement__c',achievementNameMap.get((String)obj.get('Status__c')));
                    obj.put('Status__c','Active');
                }
                insert listToInsert;
                system.debug('-------------listToDelete-------------------------'+listToDelete);
                delete listToDelete;
            }
            List<sObject> sobjList = new List<sObject>();
            for(sObject sobj: Database.query('SELECT Id,Last_Achievement_Sync__c FROM ' + objectName + ' WHERE Id =: recordId')) {
                sobj.put('Last_Achievement_Sync__c',Datetime.now());
                sobjList.add(sobj);
            }
            update sobjList;
            return true;
       // } 
        //catch(Exception e) 
       // {
           // return false;
        //}
    }
}