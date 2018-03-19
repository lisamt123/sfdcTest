/*
    Author :- Akshat
    Helper purpose :- Event(After Insert) Helper class will be called by ContentDocumentLink Trigger for Achievement logo when 
*/

public with sharing class ContentDocumentLinksHelper{
    public static void processAfterInsert(List<ContentDocumentLink> newContentDocumentLinkList){
        Map<String,String> keys = new Map<String,String>();
    
        Map<String,Schema.SobjectType> describe = Schema.getGlobalDescribe();
        for(String s:describe.keyset())
            keys.put(describe.get(s).getDescribe().getKeyPrefix(),s);
        
        Set<Id> setContentDocumentIds = new Set<Id>();
        List<Achievement__c> achievementList = new List<Achievement__c>();
        
        List<ContentDocumentLink> newTriggerList = new List<ContentDocumentLink>();
        
        for(ContentDocumentLink conDocumentLink : newContentDocumentLinkList){
            If(conDocumentLink.LinkedEntityId != null && keys.get(String.valueOf(conDocumentLink.LinkedEntityId).substring(0,3)) == 'Achievement__c'){
                setContentDocumentIds.add(conDocumentLink.ContentDocumentId);
                newTriggerList.add(conDocumentLink);
            }
        }
        If(setContentDocumentIds.size() > 0){
            Map<Id,ContentDocument> conDocsWithVersionMap = new Map<Id,ContentDocument>();
            for(ContentDocument conDocs : [Select Id,title,LatestPublishedVersionId From ContentDocument Where ID IN : setContentDocumentIds]){
                conDocsWithVersionMap.put(conDocs.Id, conDocs);
            }
            
            Map<ID,ContentDistribution > mapContentLinkWithDistribution = new MAP<ID,ContentDistribution >();
            
            for(ContentDocumentLink conDocumentLink : newTriggerList){
                ContentDistribution cd = new ContentDistribution();
                cd.name = conDocsWithVersionMap.get(conDocumentLink.ContentDocumentId).title;
                cd.ContentVersionId = conDocsWithVersionMap.get(conDocumentLink.ContentDocumentId).LatestPublishedVersionId;
                cd.PreferencesAllowOriginalDownload = true;
                cd.PreferencesAllowPDFDownload = false;
                cd.PreferencesNotifyOnVisit = false;
                mapContentLinkWithDistribution.put(conDocumentLink.LinkedEntityId,cd);
            }
            If(mapContentLinkWithDistribution.size() > 0){
                Insert mapContentLinkWithDistribution.values();
                
                Map<Id,String> mapVersionWithDistributionURL = new Map<Id,String>();
                for(ContentDistribution conDistributions : [SELECT ContentVersionId,DistributionPublicUrl FROM ContentDistribution WHERE ID = : mapContentLinkWithDistribution.values()] ){
                    mapVersionWithDistributionURL.put(conDistributions.ContentVersionId,conDistributions.DistributionPublicUrl );
                }
                
                for(ContentDocumentLink conDocumentLink : newTriggerList){
                    Achievement__c achievement = new Achievement__c();
                    achievement.Id  = conDocumentLink.LinkedEntityId;
                    
                    /* achievement.Work_Badge_Image_URL__c = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId='+conDocsWithVersionMap.get(conDocumentLink.ContentDocumentId);
                    achievement.Work_Badge_Image_URL__c = mapVersionWithDistributionURL.get(conDocsWithVersionMap.get(conDocumentLink.ContentDocumentId).LatestPublishedVersionId);
                    achievement.Work_Badge_Image_URL__c = '/sfc/servlet.shepherd/version/download/'+conDocsWithVersionMap.get(conDocumentLink.ContentDocumentId).LatestPublishedVersionId; */
                    
                    If(mapVersionWithDistributionURL.get(conDocsWithVersionMap.get(conDocumentLink.ContentDocumentId).LatestPublishedVersionId) != null){
                        String distributionURL = mapVersionWithDistributionURL.get(conDocsWithVersionMap.get(conDocumentLink.ContentDocumentId).LatestPublishedVersionId);
                        string mainDistributionURL;
                        If(distributionURL.Contains('/a/')){
                            mainDistributionURL = '/a/'+distributionURL.split('/a/')[1];
                        }
                        achievement.Work_Badge_Image_URL__c ='/sfc/dist/version/download/?oid='+UserInfo.getOrganizationId()+'&ids='+conDocsWithVersionMap.get(conDocumentLink.ContentDocumentId).LatestPublishedVersionId +'&d='+mainDistributionURL+'&operationContext=DELIVERY&dpt=null';
                    }
                    achievementList.add(achievement);
                }
            }
            If(achievementList.size() > 0)
                update achievementList;
        }
    }
}