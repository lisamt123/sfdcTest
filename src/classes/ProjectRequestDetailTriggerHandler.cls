public without sharing class ProjectRequestDetailTriggerHandler { 
        
    public void onAfterInsert(List<Project_Request_Detail__c> lstNewProjectRequestDetailRecords, Map<Id, Project_Request_Detail__c> mapOldProjectRequestDetailRecords){
        
        //autoCreateAssignmentRecord(lstNewProjectRequestDetailRecords, mapOldProjectRequestDetailRecords);  
        createOpportunityProductToLinkedServiceOpp(lstNewProjectRequestDetailRecords,null);     
    }
     
    public void onAfterUpdate(List<Project_Request_Detail__c> lstNewProjectRequestDetailRecords, Map<Id, Project_Request_Detail__c> mapOldProjectRequestDetailRecords){
        
        autoCreateAssignmentRecord(lstNewProjectRequestDetailRecords, mapOldProjectRequestDetailRecords);
        createOpportunityProductToLinkedServiceOpp(lstNewProjectRequestDetailRecords,mapOldProjectRequestDetailRecords);       
    }

    public void onAfterDelete(List<Project_Request_Detail__c> lstoldProjectRequestDetailRecords){
        delOppProductOnREDel(lstoldProjectRequestDetailRecords);
    }

    public void onAfterUnDelete(List<Project_Request_Detail__c> lstNewProjectRequestDetailRecords) {
         createOpportunityProductToLinkedServiceOpp(lstNewProjectRequestDetailRecords,null); 
    }  
        
    private static void autoCreateAssignmentRecord(List<Project_Request_Detail__c> lstProjectRequestDetailRecords, Map<Id, Project_Request_Detail__c> mapOldProjectRequestDetailRecords) {
        /*             
        boolean isInsert = (mapOldProjectRequestDetailRecords == null);         
        Set<Id> setProjectRequestDetailIDs = new Set<Id>(); 
        Set<Id> setPostProjectRequestDetailIDs = new Set<Id>(); 
        List<Project_Request__c> lstProjectRequestRecordsToUpdate = new List<Project_Request__c>();
        List<Project_Request_Detail__c> lstProjectRequestDetailRecordsToUpdate = new List<Project_Request_Detail__c>();
        Map<Id, Assignment__c> mapProjectRequestDetailIDToAssignment = new Map<Id, Assignment__c>();    
                        
        for(Project_Request_Detail__c objProjectRequestDetail : lstProjectRequestDetailRecords) {
            
            if((isInsert || (objProjectRequestDetail.Status__c != mapOldProjectRequestDetailRecords.get(objProjectRequestDetail.Id).Status__c || objProjectRequestDetail.Status_Detail__c != mapOldProjectRequestDetailRecords.get(objProjectRequestDetail.Id).Status_Detail__c)) && (objProjectRequestDetail.Status__c == 'Closed' && (objProjectRequestDetail.Status_Detail__c == 'Fulfilled' || objProjectRequestDetail.Status_Detail__c == 'Partially Fulfilled'))) {       
                
                setProjectRequestDetailIDs.add(objProjectRequestDetail.Id);
            }
        }
        
        if(!setProjectRequestDetailIDs.isEmpty()) {
            
            for(Project_Request_Detail__c objProjectRequestDetail : [Select Id, Name, Role__c, Assigned_Hours__c, Assigned_Expert__c, Project_Request__c, Project_Request__r.Id, Project_Request__r.Project__c, Project_Request__r.Status_Detail__c, Project_Request__r.Status__c From Project_Request_Detail__c Where Id IN :setProjectRequestDetailIDs]) {
                
                if((objProjectRequestDetail.Project_Request__r.Status__c == 'Closed' && (objProjectRequestDetail.Project_Request__r.Status_Detail__c == 'Fulfilled' || objProjectRequestDetail.Project_Request__r.Status_Detail__c == 'Partially Fulfilled')) && objProjectRequestDetail.Project_Request__r.Project__c != null) {   
                    
                    Assignment__c objAssignmentToInsert = createAssignmentRecord(objProjectRequestDetail);              
                    mapProjectRequestDetailIDToAssignment.put(objProjectRequestDetail.Id, objAssignmentToInsert);
                }
                else
                {
                    Project_Request__c objProjectRequestToUpdate = new Project_Request__c(Id = objProjectRequestDetail.Project_Request__r.Id, Status__c = 'Closed', Status_Detail__c = 'Fulfilled');
                    lstProjectRequestRecordsToUpdate.add(objProjectRequestToUpdate);
                    
                    setPostProjectRequestDetailIDs.add(objProjectRequestDetail.Id);                     
                }               
            }
            
            if(!lstProjectRequestRecordsToUpdate.isEmpty()) {
                update lstProjectRequestRecordsToUpdate;
            }
            
            if(!setPostProjectRequestDetailIDs.isEmpty()) {
                
                for(Project_Request_Detail__c objProjectRequestDetailRecord : [Select Id, Name, Role__c, Assigned_Hours__c, Assigned_Expert__c, Project_Request__c, Project_Request__r.Id, Project_Request__r.Project__c, Project_Request__r.Status_Detail__c, Project_Request__r.Status__c From Project_Request_Detail__c Where Id IN :setPostProjectRequestDetailIDs]) {
                    
                    Assignment__c objAssignmentToInsert = createAssignmentRecord(objProjectRequestDetailRecord);
                    mapProjectRequestDetailIDToAssignment.put(objProjectRequestDetailRecord.Id, objAssignmentToInsert); 
                }
            }
            
            if(!mapProjectRequestDetailIDToAssignment.isEmpty()) {
                
                insert mapProjectRequestDetailIDToAssignment.values();
            }
            
            //Set the Parent [Assignment__c] reference on child [Project_Request_Detail__c] record
            for(Id objProjectRequestDetailID : mapProjectRequestDetailIDToAssignment.keySet()) {
                
                Project_Request_Detail__c objProjectRequestDetailToUpdate = new Project_Request_Detail__c(Id = objProjectRequestDetailID, Assignment__c = mapProjectRequestDetailIDToAssignment.get(objProjectRequestDetailID).Id);
                lstProjectRequestDetailRecordsToUpdate.add(objProjectRequestDetailToUpdate);
            }
            
            if(!lstProjectRequestDetailRecordsToUpdate.isEmpty()) {
                update lstProjectRequestDetailRecordsToUpdate;
            }
        }
        */
    }
    
    /*
    private static Assignment__c createAssignmentRecord(Project_Request_Detail__c objProjectRequestDetail) {
        
        Assignment__c objAssignment = new Assignment__c();
        objAssignment.Billable__c = true;
        objAssignment.Planned_Hours__c = objProjectRequestDetail.Assigned_Hours__c;
        objAssignment.Resource__c = objProjectRequestDetail.Assigned_Expert__c;
        objAssignment.Project__c = objProjectRequestDetail.Project_Request__r.Project__c;
        objAssignment.Role__c = objProjectRequestDetail.Role__c;
        objAssignment.Percent_Allocated__c = objProjectRequestDetail.Assigned_Allocation__c;
        
        return objAssignment;
    }
    */

    private static void createOpportunityProductToLinkedServiceOpp(List<Project_Request_Detail__c> lstProjectRequestDetailRecords,Map<Id, Project_Request_Detail__c> mapOldProjectRequestDetailRecords) {
        Map<Id,Project_Request__c> workReqIdToWorkReqMap            = new  Map<Id,Project_Request__c>();
        Map<Id,OpportunityLineItem> requestedExpertIdToOppProduct   = new  Map<Id,OpportunityLineItem>();
        Map<Id,List<PricebookEntry> > pbWithPBEntryMap = new  Map<Id,List<PricebookEntry> >();
        Map<Id,Project_Request_Detail__c> oppProductIdToREMap = new Map<Id,Project_Request_Detail__c>();
        Set<Id> workRequestId = new Set<Id>(); 
        Set<Id> priceBookIdSet = new Set<Id>();
        List<OpportunityLineItem> oppProductList = new List<OpportunityLineItem>();
        List<OpportunityLineItem> oppProductUpdateList = new List<OpportunityLineItem>();
        list<OpportunityLineItem> oppProductDeleteList = new List<OpportunityLineItem>();
		System.debug(Trigger.isUpdate+'---'+Trigger.isInsert);
        System.debug(Trigger.isUpdate+' '+mapOldProjectRequestDetailRecords);
        System.debug(Trigger.isUpdate+'=='+lstProjectRequestDetailRecords);
        List<Project_Request_Detail__c> requestedExpertList = new List<Project_Request_Detail__c>(); 
        for(Project_Request_Detail__c projectReqDetail : lstProjectRequestDetailRecords) {
           system.debug('>>>>>>>>projectReqDetail.Requested_Hours__c'+ projectReqDetail.Requested_Hours__c);
            system.debug('>>>>>>>>mapOldProjectRequestDetailRecords.get(projectReqDetail.Id).Requested_Hours__c'+ mapOldProjectRequestDetailRecords);
            
            
            if((Trigger.isInsert || Trigger.isUndelete) || (Trigger.isUpdate && projectReqDetail.Region__c != mapOldProjectRequestDetailRecords.get(projectReqDetail.Id).Region__c 
                || projectReqDetail.Role__c != mapOldProjectRequestDetailRecords.get(projectReqDetail.Id).Role__c 
                || projectReqDetail.Requested_Rate__c != mapOldProjectRequestDetailRecords.get(projectReqDetail.Id).Requested_Rate__c 
                || projectReqDetail.Requested_Hours__c != mapOldProjectRequestDetailRecords.get(projectReqDetail.Id).Requested_Hours__c)){
                System.debug(Trigger.isUpdate+'projectReqDetail.Opportunity_Product_ID__c'+projectReqDetail.Opportunity_Product_ID__c);
                if(projectReqDetail.Opportunity_Product_ID__c != null && !(Trigger.isUndelete))
                    oppProductIdToREMap.put(projectReqDetail.Opportunity_Product_ID__c,projectReqDetail);
                
                workRequestId.add(projectReqDetail.Project_Request__c); 
           }
        }

        for( Project_Request__c workRequest : [SELECT Id,Opportunity__c,Opportunity__r.Pricebook2Id 
                                                    FROM Project_Request__c 
                                                    WHERE Id = :workRequestId]){
            workReqIdToWorkReqMap.put(workRequest.Id,workRequest);
            priceBookIdSet.add(workRequest.Opportunity__r.Pricebook2Id);
        }

        for( PricebookEntry pbEntry : [SELECT Id,Product2.Region__c,Product2.Role__c,
                                        Product2.Assignment_Type__c,IsActive,PriceBook2.Account_Tier__c,
                                        Product2Id,UnitPrice,PriceBook2Id,Product2.Name,Product2.Id 
                                            FROM PricebookEntry 
                                            WHERE PriceBook2Id 
                                            IN :priceBookIdSet]){

           if(pbWithPBEntryMap.containsKey(pbEntry.PriceBook2Id))
                pbWithPBEntryMap.get(pbEntry.PriceBook2Id).add(pbEntry);
            else
                pbWithPBEntryMap.put(pbEntry.PriceBook2Id,new List<PricebookEntry>{pbEntry});
        }

        if(Trigger.isInsert || Trigger.isUndelete) {
            for(Project_Request_Detail__c projectReqDetail : lstProjectRequestDetailRecords) {
                if(workReqIdToWorkReqMap.containsKey(projectReqDetail.Project_Request__c)){
                    if(workReqIdToWorkReqMap.get(projectReqDetail.Project_Request__c).Opportunity__r.Pricebook2Id != null){
                            OpportunityLineItem oppLineItemRec = new OpportunityLineItem();
                            for(PricebookEntry pbEntry : pbWithPBEntryMap.get(workReqIdToWorkReqMap.get(projectReqDetail.Project_Request__c).Opportunity__r.Pricebook2Id)){
                                if(pbEntry.Product2.Region__c == projectReqDetail.Region__c && pbEntry.Product2.Role__c == projectReqDetail.Role__c){
                                     oppLineItemRec.PricebookEntryId = pbEntry.Id;
                                }
                            }
                            oppLineItemRec.Quantity = projectReqDetail.Requested_Hours__c;
                           
                            oppLineItemRec.OpportunityId = workReqIdToWorkReqMap.get(projectReqDetail.Project_Request__c).Opportunity__c;
                            oppLineItemRec.unitPrice = projectReqDetail.Requested_Rate__c;
                            if(oppLineItemRec.PricebookEntryId != null && oppLineItemRec.unitPrice != null){
                                oppProductList.add(oppLineItemRec);
                                requestedExpertIdToOppProduct.put(projectReqDetail.Id,oppLineItemRec);
                            }
                    }
                }
            }
        }

        if(Trigger.isUpdate){
            for(OpportunityLineItem oli : [SELECT PricebookEntryId,Quantity,UnitPrice 
                                                FROM OpportunityLineItem WHERE Id 
                                                IN :oppProductIdToREMap.keySet()]){
                if(oppProductIdToREMap.get(oli.Id).Role__c == ((Project_Request_Detail__c)Trigger.oldMap.get(oppProductIdToREMap.get(oli.Id).Id)).Role__c &&
                        oppProductIdToREMap.get(oli.Id).Region__c == ((Project_Request_Detail__c)Trigger.oldMap.get(oppProductIdToREMap.get(oli.Id).Id)).Region__c){
                    oli.Quantity = oppProductIdToREMap.get(oli.Id).Requested_Hours__c;
                    oli.unitPrice =  oppProductIdToREMap.get(oli.Id).Requested_Rate__c;
                    if(oli.PricebookEntryId != null && oli.unitPrice != null){
                        oppProductUpdateList.add(oli);
                    }
                }

                else{
                        oppProductDeleteList.add(oli);
                        OpportunityLineItem oppLineItemRec = new OpportunityLineItem();
                        for(PricebookEntry pbEntry : pbWithPBEntryMap.get(workReqIdToWorkReqMap.get(oppProductIdToREMap.get(oli.Id).Project_Request__c).Opportunity__r.Pricebook2Id)){
                            if(pbEntry.Product2.Region__c == oppProductIdToREMap.get(oli.Id).Region__c && pbEntry.Product2.Role__c == oppProductIdToREMap.get(oli.Id).Role__c){
                                 oppLineItemRec.PricebookEntryId = pbEntry.Id;
                            }
                        }
                        oppLineItemRec.Quantity = oppProductIdToREMap.get(oli.Id).Requested_Hours__c;
                       
                        oppLineItemRec.OpportunityId = workReqIdToWorkReqMap.get(oppProductIdToREMap.get(oli.Id).Project_Request__c).Opportunity__c;
                        oppLineItemRec.unitPrice = oppProductIdToREMap.get(oli.Id).Requested_Rate__c;
                        if(oppLineItemRec.PricebookEntryId != null && oppLineItemRec.unitPrice != null){
                            oppProductList.add(oppLineItemRec);
                            requestedExpertIdToOppProduct.put(oppProductIdToREMap.get(oli.Id).Id,oppLineItemRec);
                        }
                }
            }
        }

        if(!oppProductDeleteList.isEmpty())
            Delete oppProductDeleteList;
        if(!oppProductList.isEmpty())
            insert oppProductList;

        if(!oppProductUpdateList.isEmpty())
            update oppProductUpdateList;

        if(Trigger.isInsert || Trigger.isUndelete || Trigger.isUpdate && (!requestedExpertIdToOppProduct.isEmpty())){
            for(Project_Request_Detail__c requestedExpert : [SELECT Opportunity_Product_ID__c 
                                                                FROM Project_Request_Detail__c 
                                                                WHERE Id IN :lstProjectRequestDetailRecords]) {
                if(requestedExpertIdToOppProduct.containsKey(requestedExpert.Id)){
                    requestedExpert.Opportunity_Product_ID__c = requestedExpertIdToOppProduct.get(requestedExpert.Id).Id;
                    requestedExpertList.add(requestedExpert);
                }
            }
        }    

        if(!requestedExpertList.isEmpty())
            update requestedExpertList;
    }

    private static void delOppProductOnREDel(List<Project_Request_Detail__c> lstoldProjectRequestDetailRecords) {
        Set<Id> oppProductIdList = new Set<Id>();
        list<OpportunityLineItem> oppProductDeleteList = new List<OpportunityLineItem>();
        
        for(Project_Request_Detail__c projectReqDetail : lstoldProjectRequestDetailRecords) {
            oppProductIdList.add(projectReqDetail.Opportunity_Product_ID__c);
        }

        for(OpportunityLineItem oli : [SELECT PricebookEntryId,Quantity,UnitPrice 
                                                FROM OpportunityLineItem WHERE Id 
                                                IN :oppProductIdList]){
            oppProductDeleteList.add(oli);
        }

        if(!oppProductDeleteList.isEmpty())
            Delete oppProductDeleteList;
    }
}