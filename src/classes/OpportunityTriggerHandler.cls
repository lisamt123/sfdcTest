public class OpportunityTriggerHandler {
    // Class Properties
    Private static final String PRODUCT_OPPORTUNITY = 'Product Opportunity';
    Private static final String STAGE_NAME = 'Closed Won';
    
    //Create Project whenever opportunity stage is updated to Closed Won. Accepts new map and old map from trigger
    public static void createProject(Map<Id, Opportunity> newOppMap) {
        List<Project__c> projects = new List<Project__c>();
        
        for(Opportunity opp : newOppMap.values()) {
            if(opp.RecordTypeId == Constants.RECORDTYPEID_OPPORTUNITY_SERVICES && opp.StageName != null && opp.StageName.equalsIgnoreCase(Constants.OPP_STAGE_CLOSED_WON) 
               && (Trigger.isInsert || (Trigger.isUpdate && ((Opportunity)Trigger.oldMap.get(opp.Id)).StageName != opp.StageName))) {
                projects.add(new Project__c(Name = opp.Name, Opportunity__c = opp.Id, Account__c = opp.AccountId, Status__c = Constants.PROJECT_STATUS_PROJECTED));
            }
        }
        
        if(projects.size() > 0) {
            insert projects;
        }        
    }
    
    // Method called on AfterInser trigger
    public static void onAfterInsert(List<Opportunity> Opportunities){
        Id OpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(PRODUCT_OPPORTUNITY).getRecordTypeId();
        List<opportunity> validOpportunities = new List<opportunity>();
        for(Opportunity Opp: Opportunities){
            if(Opp.RecordTypeId == OpportunityRecordTypeId && Opp.stageName == STAGE_NAME){
                validOpportunities.add(opp);
            }
        }
        
         InvoiceCreationUtility.createProductInvoice(validOpportunities);
         
         setLicenseExpirationDate(Opportunities, null);     //Created By Rajesh
    }
    
    
    // Method called on AfterUpdate trigger
    public static void onAfterUpdate(Map<Id,Opportunity> NewOpportunities,Map<Id,Opportunity> OldOpportunities){
        Id OpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(PRODUCT_OPPORTUNITY).getRecordTypeId();
        Id OpportunityMsaRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('MSA Opportunity').getRecordTypeId();
        List<opportunity> validOpportunities = new List<opportunity>();
        List<Opportunity> lstOpportunities = new List<Opportunity>();       //Created By Rajesh
        List<Opportunity> lstMsaOpportunities = new List<Opportunity>();
        Map<Id,Id> msaOppToSelectedPriceBookID = new Map<Id,Id>();
        for(Opportunity Opp: NewOpportunities.values()){
            if(Opp.RecordTypeId == OpportunityRecordTypeId && Opp.StageName == STAGE_NAME && OldOpportunities.get(Opp.Id).stageName != Opp.StageName){
                validOpportunities.add(opp);
            }
            lstOpportunities.add(Opp);
        }


         for(Opportunity Opp: NewOpportunities.values()){
            if(Opp.RecordTypeId == OpportunityMsaRecordTypeId && Opp.StageName != 'Closed Won' && OldOpportunities.get(Opp.Id).Selected_Price_Book__c != Opp.Selected_Price_Book__c){
                lstMsaOpportunities.add(Opp);
                msaOppToSelectedPriceBookID.put(Opp.Id,Opp.Selected_Price_Book__c);
            }
        }
        
         InvoiceCreationUtility.createProductInvoice(validOpportunities);
         createRenewalOpportunities(validOpportunities);
         
         setLicenseExpirationDate(lstOpportunities, OldOpportunities);      //Created By Rajesh
         updateAccountBecameClientOndate(lstOpportunities);

         if(!lstMsaOpportunities.isEmpty())
            updateRequestedExpert(lstMsaOpportunities,msaOppToSelectedPriceBookID);

    }
    
    
    //Method for updating expiration date on License object on insert/update of product opportunity whose stage is closed won
    private static void setLicenseExpirationDate(List<Opportunity> lstOpportunityRecords, Map<Id, Opportunity> mapOldOpportunityRecords) {
        
        Id OpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(PRODUCT_OPPORTUNITY).getRecordTypeId();
        set<Id> setAccountIDs = new set<Id>();
        list<Opportunity> lstOpportunities = new list<Opportunity>();
        list<sfLma__License__c> lstLicensesToUpdate = new list<sfLma__License__c>();
        map<Id, Id> mapOpportunityIdToAccountId = new map<Id, Id>();
        map<Id, set<Id>> mapAccountIdToSetOfLicences = new map<Id, set<Id>>();
                    
        for(Opportunity objOpportunity : lstOpportunityRecords) {
            
            if((Trigger.isInsert || objOpportunity.StageName != mapOldOpportunityRecords.get(objOpportunity.Id).StageName) 
                && objOpportunity.StageName == 'Closed Won' && objOpportunity.RecordTypeId == OpportunityRecordTypeId && objOpportunity.Subscription_End_Date__c != null) {
                
                setAccountIDs.add(objOpportunity.AccountId);  
                
                lstOpportunities.add(objOpportunity);  
                
                mapOpportunityIdToAccountId.put(objOpportunity.Id, objOpportunity.AccountId);
            }   
        }
        
        for(sfLma__License__c objLicense : [Select sfLma__Status__c, sfLma__Is_Sandbox__c, sfLma__Expiration__c, sfLma__Account__c, Id From sfLma__License__c Where sfLma__Account__c IN :setAccountIDs AND sfLma__Is_Sandbox__c = false]) {
            
            if(!mapAccountIdToSetOfLicences.containsKey(objLicense.sfLma__Account__c)) {
                
                mapAccountIdToSetOfLicences.put(objLicense.sfLma__Account__c, new set<Id>());
            }
            
            mapAccountIdToSetOfLicences.get(objLicense.sfLma__Account__c).add(objLicense.Id);
        }   
        
        
        for(Opportunity objOpportunity : lstOpportunities) {
            
            if(!mapOpportunityIdToAccountId.isEmpty() && !mapAccountIdToSetOfLicences.isEmpty() && !mapAccountIdToSetOfLicences.get(mapOpportunityIdToAccountId.get(objOpportunity.Id)).isEmpty()) {
                
                for(Id objLicenseID : mapAccountIdToSetOfLicences.get(mapOpportunityIdToAccountId.get(objOpportunity.Id))) {
                    
                    sfLma__License__c objLicense = new sfLma__License__c(Id = objLicenseID, sfLma__Expiration__c = objOpportunity.Subscription_End_Date__c + 30, sfLma__Status__c = 'Active');
                    
                    lstLicensesToUpdate.add(objLicense);
                }
            }
        }
        
        if(!lstLicensesToUpdate.isEmpty()) {
            
            update lstLicensesToUpdate;
        }
    }

    public static void createRenewalOpportunities(List<Opportunity> oppList) {
        Id OpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(PRODUCT_OPPORTUNITY).getRecordTypeId();
        Map<Id,Opportunity> oldIdToNewOpportunityMap = new Map<Id,Opportunity>();
        
        Map<Id, String> oppIdToAccountNameMap = new Map<Id, String>();
        for(Opportunity opp : [SELECT Id, Account.Name FROM Opportunity WHERE Id IN: oppList]) {
            oppIdToAccountNameMap.put(opp.Id, opp.Account.Name);
        }
        system.debug(oppIdToAccountNameMap);

        for(Opportunity opp : oppList) {
            Opportunity renewalOpp                  = new Opportunity();
            renewalOpp.AccountId                    = opp.AccountId;                //Required
            renewalOpp.Amount                       = 0;                            //Required
            renewalOpp.CloseDate                    = opp.CloseDate.addMonths(12);  //Required
            renewalOpp.StageName                    = 'Qualification';              //Required
            renewalOpp.Type                         = 'Renewal';
            renewalOpp.LeadSource                   = 'DSM for Salesforce';
            renewalOpp.OwnerId                      = opp.OwnerId;
            renewalOpp.RecordTypeId                 = OpportunityRecordTypeId;
            renewalOpp.Subscription_Start_Date__c   = opp.Subscription_End_Date__c.addDays(1);
            renewalOpp.Subscription_End_Date__c     = opp.Subscription_End_Date__c.addDays(365);
            renewalOpp.Name                         = oppIdToAccountNameMap.get(opp.Id) + ' - DoubleClick for Salesforce - ' 
                                                      + renewalOpp.Subscription_Start_Date__c.month() + '/' + renewalOpp.Subscription_Start_Date__c.year()
                                                      + ' to ' + renewalOpp.Subscription_End_Date__c.month() + '/' + renewalOpp.Subscription_End_Date__c.year();
            system.debug(renewalOpp.Name);
            system.debug(renewalOpp.Name.length());
            oldIdToNewOpportunityMap.put(opp.Id, renewalOpp);
        }

        if(!oldIdToNewOpportunityMap.isEmpty())
        {
            insert oldIdToNewOpportunityMap.values();
        }

        List<OpportunityContactRole> ocrList = [SELECT OpportunityId, ContactId, Role 
                                                FROM OpportunityContactRole 
                                                WHERE OpportunityId IN : oppList];

        List<Opportunitylineitem> oliList = [SELECT OpportunityId, Quantity, UnitPrice, ListPrice, Pricebookentryid, 
                                                    Discount, ServiceDate, Description 
                                                FROM Opportunitylineitem 
                                                WHERE OpportunityId IN : oppList];

        List<OpportunityContactRole> newOcrList = new List<OpportunityContactRole>();
        List<Opportunitylineitem> newOliList    = new List<Opportunitylineitem>();

        for(OpportunityContactRole ocr : ocrList) 
        {
            OpportunityContactRole newOcr   = new OpportunityContactRole();
            newOcr.ContactId                = ocr.ContactId;
            newOcr.Role                     = ocr.Role;
            newOcr.OpportunityId            = oldIdToNewOpportunityMap.get(ocr.OpportunityId).Id;
            newOcrList.add(newOcr);
        }

        if(!newOcrList.isEmpty())
        {
            insert newOcrList;
        }

        for(Opportunitylineitem oli : oliList)
        {
            Opportunitylineitem newOli  = new Opportunitylineitem();
            newOli.OpportunityId        = oldIdToNewOpportunityMap.get(oli.OpportunityId).Id;
            newOli.Quantity             = oli.Quantity;
            newOli.UnitPrice            = oli.UnitPrice;
            newOli.Pricebookentryid     = oli.Pricebookentryid;
            newOliList.add(newOli);
        }

        if(!newOliList.isEmpty())
        {
            insert newOliList;
        }
    }

    public static void applicableMsaAgreement(List<Opportunity> newOpportunityList) {
        Id serviceRecordTypeId          = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Services Opportunity').getRecordTypeId();
        Id msaAgreementRecordTypeId     = Schema.SObjectType.Agreement__c.getRecordTypeInfosByName().get('MSA').getRecordTypeId();
        Id msaOpportunityRecordTypeId   = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('MSA Opportunity').getRecordTypeId();
        Set<String> accountId           = new Set<String>();
        Map<Id,List<Agreement__c>> mapofAccountToAgreement  = new Map<Id,List<Agreement__c>>();
        Map<Id,List<Opportunity>> mapofAccountToOpportunity = new Map<Id,List<Opportunity>>();
        for(Opportunity opp : newOpportunityList) {
            if(Trigger.isInsert || opp.RecordTypeId == serviceRecordTypeId && opp.StageName != 'Closed Won' && opp.StageName != 'Closed Lost'  ) {/*&& (opp.MSA_Agreement__c == null || opp.MSA_Opportunity__c == null)*/
                accountId.add(opp.AccountId);
            }

        }
        for(Account acc : [SELECT id,
                                (SELECT Id,Opportunity__r.Selected_Price_Book__c,Opportunity__c,
                                  Effective_Date__c,Valid_Through__c FROM Agreements__r 
                                  WHERE RecordTypeId = :msaAgreementRecordTypeId) 
                            FROM Account WHERE Id IN :accountId] ) {
            System.debug((acc.Agreements__r).size());
            if((acc.Agreements__r).size() > 0)
                mapofAccountToAgreement.put(acc.Id,acc.Agreements__r);
        }

        for(Account acc : [SELECT id,
                                (SELECT Id FROM Opportunities 
                                WHERE RecordTypeId = :msaOpportunityRecordTypeId) 
                            FROM Account WHERE Id IN :accountId] ) {
            if((acc.Opportunities).size() > 0)
                mapofAccountToOpportunity.put(acc.Id,acc.Opportunities);
        }
        
        for(Opportunity opp :newOpportunityList) {
            if(opp.RecordTypeId == serviceRecordTypeId) {
                List<Agreement__c> listAgreementRec = new List<Agreement__c>();
                if(mapofAccountToAgreement.containsKey(opp.AccountId)) {
                   
                    for(Agreement__c agreementRec : mapofAccountToAgreement.get(opp.AccountId)) {
                        if(opp.CloseDate >= agreementRec.Effective_Date__c && opp.CloseDate <= agreementRec.Valid_Through__c) {
                            listAgreementRec.add(agreementRec);
                        }
                    }
                    if(listAgreementRec.size() == 1) {
                        
                        opp.MSA_Opportunity__c  = listAgreementRec[0].Opportunity__c;
                        opp.MSA_Agreement__c    = listAgreementRec[0].Id;
                        opp.Pricebook2Id        = listAgreementRec[0].Opportunity__r.Selected_Price_Book__c;
                    }
                    else {
                        if(mapofAccountToOpportunity.containsKey(opp.AccountId))
                            setMSAOppurtunityCriteriaWise(opp,mapofAccountToOpportunity);
                        else {
                            opp.MSA_Opportunity__c  = null;
                            opp.MSA_Agreement__c    = null;
                        }
                    } 
                } else {
                    if(mapofAccountToOpportunity.containsKey(opp.AccountId))
                        setMSAOppurtunityCriteriaWise(opp,mapofAccountToOpportunity);
                    else {
                        opp.MSA_Opportunity__c  = null;
                        opp.MSA_Agreement__c    = null;
                    }
                }
            }
        }
    }

    public static void checkLinkedServiceOpportunityForWorkRequest(Map<Id,Opportunity> newOpportunities,Map<Id,Opportunity> oldOpportunities) {
       
       String url;
       for(Opportunity opp :[SELECT Id,StageName,CloseDate,MSA_Agreement__c,AccountId,Amount,RecordTypeId,MSA_Opportunity__c,
                                (SELECT Id,Name FROM Project_Requests__r LIMIT 1) FROM Opportunity 
                                WHERE Id IN :newOpportunities.keySet()]) {
            System.debug(opp.Project_Requests__r.size());
            if((oldOpportunities.get(opp.Id)).StageName != newOpportunities.get(opp.ID).StageName || (oldOpportunities.get(opp.Id)).AccountId != newOpportunities.get(opp.ID).AccountId 
                || (oldOpportunities.get(opp.Id)).CloseDate != newOpportunities.get(opp.ID).CloseDate 
                || (oldOpportunities.get(opp.Id)).MSA_Agreement__c != newOpportunities.get(opp.ID).MSA_Agreement__c || (oldOpportunities.get(opp.Id)).MSA_Opportunity__c != newOpportunities.get(opp.ID).MSA_Opportunity__c 
                || (oldOpportunities.get(opp.Id)).RecordTypeId != newOpportunities.get(opp.ID).RecordTypeId) {
                
                System.debug('in>>>');
                if(opp.Project_Requests__r.size() > 0){
                    //String salesforceBaseUrl = URL.getSalesforceBaseUrl().toExternalForm();
                    url = '<a href="'+'/'+opp.Project_Requests__r[0].Id+'">'; 
                    Trigger.newMap.get(opp.ID).addError('This Opportunity is linked to Work Request <a href=\'/'  + opp.Project_Requests__r[0].Id + '\'>' + opp.Project_Requests__r[0].Name + '</a> and cannot be edited directly. Edit the Work Request instead, and your updates will sync to this Opportunity.',false);
                }
            }
       }
    }

    public static void setMSAOppurtunityCriteriaWise(Opportunity opp,Map<Id,List<Opportunity>> mapofAccountToOpportunity) {
        
        List<opportunity> opportunityList = new List<opportunity>();
        if(!mapofAccountToOpportunity.isEmpty() && mapofAccountToOpportunity.containsKey(opp.AccountId)) {
            opportunityList = mapofAccountToOpportunity.get(opp.AccountId);
        }
        if(opportunityList.size() >= 1) {
            opp.MSA_Opportunity__c  = opportunityList[0].Id;
            opp.MSA_Agreement__c    = null;
        }
    }

    public static void validationForOverlapOpportunityMSADates(List<Opportunity> newOpportunityList) {
        Id msaRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('MSA Opportunity').getRecordTypeId();
        List<Opportunity> oldCreatedOpportunity = new List<Opportunity>();
        List<Opportunity> newOpportunityMsaList = new List<Opportunity>();
        Set<String> accountId = new Set<String>();
        for(Opportunity opp : newOpportunityList){
            accountId.add(opp.AccountId);
            if(opp.RecordTypeId == msaRecordTypeId)
                newOpportunityMsaList.add(opp);
        }
        oldCreatedOpportunity = [SELECT Start_Date__c,Name,AccountId,RecordTypeId,End_Date__c 
                                    FROM opportunity 
                                    WHERE  AccountId In :accountId AND RecordTypeId =:msaRecordTypeId  
                                    AND Id NOT IN : newOpportunityList];
        
        if(!newOpportunityMsaList.isEmpty()) {
            for(Integer k = 0 ; k < newOpportunityMsaList.size(); k++){
                for(Opportunity old_asg : oldCreatedOpportunity) {
                    if((newOpportunityMsaList[k].Start_Date__c == old_asg.Start_Date__c) || (newOpportunityMsaList[k].Start_Date__c == old_asg.End_Date__c))
                            newOpportunityMsaList[k].Start_Date__c.addError('This Start Date overlaps with the dates of Oppoprtunity '+ old_asg.Name +'. Please choose an Start Date that doesn\'t overlap with the other Opportunity.');
                    else if((newOpportunityMsaList[k].End_Date__c == old_asg.End_Date__c) || (newOpportunityMsaList[k].End_Date__c == old_asg.Start_Date__c))
                            newOpportunityMsaList[k].End_Date__c.addError('This End Date overlaps with the dates of Oppoprtunity '+ old_asg.Name +'. Please choose an End Date that doesn\'t overlap with the other Opportunity.');
                    else if(old_asg.Start_Date__c < newOpportunityMsaList[k].Start_Date__c && old_asg.End_Date__c >= newOpportunityMsaList[k].Start_Date__c)
                            newOpportunityMsaList[k].Start_Date__c.addError('This Start Date overlaps with the dates of Oppoprtunity '+ old_asg.Name +'. Please choose an Start Date that doesn\'t overlap with the other Opportunity.');
                    else if(old_asg.Start_Date__c > newOpportunityMsaList[k].Start_Date__c && old_asg.Start_Date__c <= newOpportunityMsaList[k].End_Date__c)
                            newOpportunityMsaList[k].End_Date__c.addError('This End Date overlaps with the dates of Oppoprtunity '+ old_asg.Name +'. Please choose an End Date that doesn\'t overlap with the other Opportunity.');
                }
                for(Integer i = 0 ; i < newOpportunityMsaList.size(); i++) {
                    if(k != i) {
                        if((newOpportunityMsaList[k].Start_Date__c == newOpportunityMsaList[i].Start_Date__c) || (newOpportunityMsaList[k].Start_Date__c == newOpportunityMsaList[i].End_Date__c))
                            newOpportunityMsaList[k].Start_Date__c.addError('This Start Date overlaps with the dates of other MSA Opportunity '+ newOpportunityMsaList[i].Name +'. Please choose an Start Date that doesn\'t overlap with the other Opportunity.');
                        else if((newOpportunityMsaList[k].End_Date__c == newOpportunityMsaList[i].End_Date__c) || (newOpportunityMsaList[k].End_Date__c == newOpportunityMsaList[i].Start_Date__c))
                            newOpportunityMsaList[k].End_Date__c.addError('This End Date overlaps with the dates of other MSA Opportunity '+ newOpportunityMsaList[i].Name +'. Please choose an End Date that doesn\'t overlap with the other Opportunity.');
                        else if(newOpportunityMsaList[i].Start_Date__c < newOpportunityMsaList[k].Start_Date__c && newOpportunityMsaList[i].End_Date__c >= newOpportunityMsaList[k].Start_Date__c)
                            newOpportunityMsaList[k].Start_Date__c.addError('This Start Date overlaps with the dates of other MSA Opportunity '+ newOpportunityMsaList[i].Name +'. Please choose an Start Date that doesn\'t overlap with the other Opportunity.');
                        else if(newOpportunityMsaList[i].Start_Date__c > newOpportunityMsaList[k].Start_Date__c && newOpportunityMsaList[i].Start_Date__c <= newOpportunityMsaList[k].End_Date__c)
                            newOpportunityMsaList[k].End_Date__c.addError('This End Date overlaps with the dates of other MSA Opportunity '+ newOpportunityMsaList[i].Name +'. Please choose an End Date that doesn\'t overlap with the other Opportunity.');
                    }
                }
            }
        }
    }
    
    //Method for updating expiration date on License object on insert/update of product opportunity whose stage is closed won
    private static void updateAccountBecameClientOndate(List<Opportunity> lstOpportunityRecords) {
        
        set<Id> setAccountIDs = new set<Id>();
        
        for(Opportunity objOpportunity : lstOpportunityRecords) {
            setAccountIDs.add(objOpportunity.AccountId);  
        }
        List<Account> lstUpdateAccount = new List<Account>();
        for(Account acc : [Select Id,Name,Became_Client_On_date__c,(Select Id,Name,CloseDate,StageName from Opportunities Where StageName = 'Closed Won' Order By CloseDate ASC) from Account Where Became_Client_On_date__c = null AND ID IN : setAccountIDs]){
            system.debug('-----acc ----------'+acc );
            for(Opportunity opp: acc.Opportunities){
                acc.Became_Client_On_date__c = opp.CloseDate;
                lstUpdateAccount.add(acc);
                Break;
            }
        }
        If(lstUpdateAccount.size() > 0)
            update lstUpdateAccount;
    }

    private static void updateRequestedExpert(List<Opportunity> lstMsaOpportunityRecords,Map<Id,Id> msaOppToSelectedPriceBookID) {
        List<Project_Request__c> workRequestList = new List<Project_Request__c>();
        Map<Id,List<PricebookEntry> > pbWithPBEntryMap = new  Map<Id,List<PricebookEntry> >();
        
        for( PricebookEntry pbEntry : [SELECT Id,Product2.Region__c,Product2.Role__c,
                                        Product2.Assignment_Type__c,IsActive,PriceBook2.Account_Tier__c,
                                        Product2Id,UnitPrice,PriceBook2Id,Product2.Name,Product2.Id 
                                            FROM PricebookEntry 
                                            WHERE PriceBook2Id 
                                            IN :msaOppToSelectedPriceBookID.values()]){

           if(pbWithPBEntryMap.containsKey(pbEntry.PriceBook2Id))
                pbWithPBEntryMap.get(pbEntry.PriceBook2Id).add(pbEntry);
            else
                pbWithPBEntryMap.put(pbEntry.PriceBook2Id,new List<PricebookEntry>{pbEntry});
        }

        for(Opportunity serviceOpp : [SELECT Id,(SELECT Id FROM Project_Requests__r) FROM Opportunity 
                                        WHERE MSA_Opportunity__c 
                                        IN :lstMsaOpportunityRecords 
                                        AND RecordTypeId = :Constants.RECORDTYPEID_OPPORTUNITY_SERVICES]){
            for(Project_Request__c workRequest : serviceOpp.Project_Requests__r) {
                workRequestList.add(workRequest);
            }
        }
        for(Project_Request_Detail__c pRequestDetail : [SELECT Id,Requested_Hours__c,Requested_Rate__c,Role__c,Region__c 
                                                            FROM Project_Request_Detail__c 
                                                            WHERE Project_Request__c IN :workRequestList]){

        }
    }
}