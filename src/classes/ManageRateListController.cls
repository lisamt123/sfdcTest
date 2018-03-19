/**
@Name           : ManageRateListController
@Dated          : 31 May, 2016
@Author         :
@Description    : This class is used to manage (Create/edit/delete) Rates of a Agreement.   
*/

public class ManageRateListController{

    string agreementId ;
    public string TMSectionTitle{get;set;}
    public string RCSectionTitle{get;set;}
    public string NRSectionTitle{get;set;}
    public string rowType{get;set;}
    public string deletingSectionType{get;set;}
    public integer removingIndex{get;set;}
    public List<RateModal> rateNRWrapperList{get;set;}
    public List<RateModal> rateRCWrapperList{get;set;}
    public List<RateModal> rateTMWrapperList{get;set;}
    Private List<Rate__c> ratesToDelete ;
    private Integer indexNo;
    //public boolean isTMSelected{get;set;}
    //public boolean isRetainerSelected{get;set;}
    public boolean showAll{get;set;}
    //private Id SelectedRecordType;
    public string agreementName{get;set;}
    
    public Boolean isMonthly {get; set;}

    public Boolean isLightningExperience {get; set;}

    public Boolean isSalesforceOne {get;set;}

    public ManageRateListController(apexpages.standardController cntrl){
        isLightningExperience = false;
        if(Apexpages.currentPage().getParameters().get('sfdcIFrameOrigin') != null)
            isLightningExperience = true;
        isSalesforceOne = false;
        if (UserInfo.getUITheme().toLowerCase() == 'theme4t')
            isSalesforceOne = true;
        indexNo = 0;
        agreementName = '';
        showAll = false;  
        TMSectionTitle = Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS;
        RCSectionTitle = Constants.ASSIGNMENTTYPE_RETAINEDCAPACITY;
        NRSectionTitle = 'Named Resources';

        agreementId  = apexpages.currentpage().getParameters().get('agreeId');
        
        String rateId = apexpages.currentpage().getParameters().get('id');
        
        rateNRWrapperList = new List<RateModal>();
        rateRCWrapperList  = new List<RateModal>();
        rateTMWrapperList  = new List<RateModal>();
        ratesToDelete = new List<Rate__c>();
        
        if(!String.isBlank(rateId)) {
            //fetching agreement id from rate object . 
            Set<Id> rateIds = new Set<Id>{rateId};  
            List<Rate__c> rateList = [SELECT Id, Agreement__c, Weekly_Rate__c
                                      FROM Rate__c 
                                      WHERE Id IN: rateIds];
            
            if(rateList !=null && rateList.size() > 0) {
                agreementId =  rateList[0].Agreement__c;
            }
        }

        if(agreementId != null) {
            //fetching agreement name.
            for(Agreement__c agreementObj : [SELECT Id, Name, RecordType.Id, Rate_Structure__c
                                             FROM Agreement__c 
                                             WHERE Id =: agreementId]) {
                agreementName = agreementObj.name;
                if(agreementObj.recordtype.id == Constants.RECORDTYPEID_AGREEMENT_RETAINER) {
                    showAll = true;          
                }
                
                isMonthly = false;
                if(agreementObj.Rate_Structure__c == 'Monthly') {
                    isMonthly = true;
                }
            }

            //filling the modal list with rate records and to categorize them into 3 sections.
            //added one more column in row - 'region'. Now rate records are categorized into 4 sections
            for(Rate__c rate : [SELECT Id, Agreement__c, Assignment_Type__c, RecordType.Name, RecordType.Id, Role__c, Name, Hourly_Rate__c,
                                       Hours_Per_Month__c, Monthly_Rate__c, Number_of_Months__c, Rate_Specific_Effective_Date__c, 
                                       Rate_Specific_Valid_Through__c, Hours_Per_Week__c, Weekly_Rate__c,Number_of_Weeks__c, Region__c, 
                                       (SELECT Id
                                        FROM Invoice_Line_Items__r),
                                       (SELECT Id
                                        FROM Assignments__r) 
                                FROM Rate__c 
                                WHERE Agreement__c =: agreementId]) {
                               
                   if(showAll && rate.recordtype.id == Constants.RECORDTYPEID_RATE_NAMED_RESOURCE && rate.assignment_type__c.equalsIgnoreCase(Constants.ASSIGNMENTTYPE_NAMEDRESOURCE)){
                       if(rate.Invoice_Line_Items__r !=null && rate.Invoice_Line_Items__r.size()>0){
                           rateNRWrapperList.add(new RateModal(rate, ++indexNo, true, isMonthly)); 
                       }else{ 
                           rateNRWrapperList.add(new RateModal(rate, ++indexNo, false, isMonthly));
                       }         
                   }else if(showAll && rate.recordtype.id == Constants.RECORDTYPEID_RATE_RETAINED_CAPACITY  && rate.assignment_type__c.equalsIgnoreCase(Constants.ASSIGNMENTTYPE_RETAINEDCAPACITY)){
                       if(rate.Invoice_Line_Items__r !=null && rate.Invoice_Line_Items__r.size()>0){
                           rateRCWrapperList.add(new RateModal(rate,++indexNo, true, isMonthly));
                       }else{  
                           rateRCWrapperList.add(new RateModal(rate,++indexNo, false, isMonthly));
                       }        
                   }else if(rate.recordtype.id == Constants.RECORDTYPEID_RATE_TIMEANDMATERIALS && rate.assignment_type__c.equalsIgnoreCase(Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS)){
                       if(rate.Invoice_Line_Items__r !=null && rate.Invoice_Line_Items__r.size()>0){
                           rateTMWrapperList.add(new RateModal(rate,++indexNo, true, isMonthly));
                       }else{
                           rateTMWrapperList.add(new RateModal(rate,++indexNo, false, isMonthly));
                       }    
                   }                    
            }
            if(showAll){
                rowType = 'TM';
                addNewRow();
                rowType = 'RC';
                addNewRow();
                rowType = 'NR';
                addNewRow();
            }else{
                rowType = 'TM';
                addNewRow();
            }
        }
    }
    
    public ManageRateListController(){
    }

    //adding row 
    public void addNewRow(){
    
        //adding a new row of 'Rate' into the selected section.
        if(!String.isBlank(rowType)){
            Rate__c rateObj = new Rate__c(name = 'New Rate');
            rateObj.agreement__c = agreementId !=null? agreementId:null ;
            if(rowType == 'TM'){
                //setting record type and assignment type.
                rateObj.recordtypeId = Constants.RECORDTYPEID_RATE_TIMEANDMATERIALS ; 
                rateObj.assignment_type__c = Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS ;
                rateTMWrapperList.add(new RateModal(rateObj,++indexNo, false, isMonthly));     
            }else if(rowType == 'NR'){
                //setting record type and assignment type.
                rateObj.recordtypeId =  Constants.RECORDTYPEID_RATE_NAMED_RESOURCE ;
                rateObj.assignment_type__c = Constants.ASSIGNMENTTYPE_NAMEDRESOURCE ;
                rateNRWrapperList.add(new RateModal(rateObj,++indexNo, false, isMonthly));     
            }else if(rowType == 'RC'){
                //setting record type and assignment type.
                rateObj.recordtypeId =  Constants.RECORDTYPEID_RATE_RETAINED_CAPACITY ;
                rateObj.assignment_type__c = Constants.ASSIGNMENTTYPE_RETAINEDCAPACITY ;
                rateRCWrapperList.add(new RateModal(rateObj,++indexNo, false, isMonthly));          
            }    
        }
    }
    //selecting role by user and rendering the other fields on new empty row .
    public void roleSelected(){
        if(removingIndex !=null && deletingSectionType !=null){
            if(deletingSectionType.equalsIgnoreCase('TM')){
                for(RateModal modalRec : rateTMWrapperList){
                    if(modalRec.index == removingIndex ){    
                        modalRec.isNewlyAdded = false;
                        rowType = 'TM';
                        addNewRow();
                        break;
                    }    
                }
            }else if(deletingSectionType.equalsIgnoreCase('NR')){
                for(RateModal modalRec : rateNRWrapperList){
                    if(modalRec.index == removingIndex ){    
                        modalRec.isNewlyAdded = false;
                        rowType = 'NR';
                        addNewRow();
                        break;
                    }    
                }
           }else if(deletingSectionType.equalsIgnoreCase('RC')){ 
                for(RateModal modalRec : rateRCWrapperList){
                   if(modalRec.index == removingIndex){    
                        modalRec.isNewlyAdded = false;
                        rowType = 'RC';
                        addNewRow();
                        break;
                    }    
                }
           }          
       }          
    }
      
    //to remove row
    public void removeRow(){
    
        List<RateModal> rateModalList = new List<RateModal>();
        
        //removing row from the selected section on the basis of index.
        if(removingIndex !=null && deletingSectionType !=null){
            if(deletingSectionType.equalsIgnoreCase('TM')){
                for(RateModal modalRec : rateTMWrapperList){
                    //skipping the deleting item from list
                    if(modalRec.index != removingIndex){
                        rateModalList.add(modalRec);
                    }else{
                         if(!String.isBlank(modalRec.rateObj.id)){
                            ratesToDelete.add(modalRec.rateObj);
                         }   
                    }    
                }
               rateTMWrapperList = rateModalList;
                    
            }else if(deletingSectionType.equalsIgnoreCase('NR')){
                for(RateModal modalRec : rateNRWrapperList){
                    //skipping the deleting item from list
                    if(modalRec.index != removingIndex){
                        rateModalList.add(modalRec);
                    }else{
                         if(!String.isBlank(modalRec.rateObj.id)){
                            ratesToDelete.add(modalRec.rateObj);
                         }   
                    }    
                }
              
                rateNRWrapperList = rateModalList;
            }else if(deletingSectionType.equalsIgnoreCase('RC')){ 
                for(RateModal modalRec : rateRCWrapperList){
                    //skipping the deleting item from list
                    if(modalRec.index != removingIndex){
                        rateModalList.add(modalRec);
                    }else{
                        if(!String.isBlank(modalRec.rateObj.id)){
                             ratesToDelete.add(modalRec.rateObj);
                        }     
                    }    
                }
                rateRCWrapperList = rateModalList;
            }
        }
    }  
 
    //to save rates
    public pagereference save(){
        List<Rate__c> rateList = new List<Rate__c>();
        Set<String> selectedRolesTM = new Set<String>();
        String duplicateRolesInTM ='', duplicateRolesInRC ='', errorInRC = '', errorInNR ='';
        System.debug('start duplicateRolesInTM - '+duplicateRolesInTM);
        //fetching all TM Rates
        if(rateTMWrapperList !=null && rateTMWrapperList.size()>0){
        
        system.debug('-----------rateTMWrapperList----------------------'+rateTMWrapperList);
        system.debug('-----------rateRCWrapperList ----------------------'+rateRCWrapperList );
        system.debug('-----------rateNRWrapperList ----------------------'+rateNRWrapperList );
        
        Map<String,Set<Decimal>> selectedRolesRatesMap = new Map<String,Set<Decimal>>();
                    
            for(RateModal modalRec : rateTMWrapperList){
                //skipping last extra row
                system.debug('-----------modalRec ----------------------'+modalRec );
                if(!modalRec.isNewlyAdded){
                    //checking required fields.
                    if(modalRec.rateObj.hourly_rate__c == null || modalRec.rateObj.role__C == null || modalRec.rateObj.region__C == null){
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,Constants.ERROR_REQUIRED_FIELDS);
                        ApexPages.addMessage(myMsg);
                        return null; 
                    }
                
                    // checking for Multiple Same rates for a single role :- Added By AK
                    // modified by AS on 17jan according to region also
                    if(selectedRolesRatesMap.size() > 0 && selectedRolesRatesMap.containsKey(modalRec.rateObj.role__c+'#'+modalRec.rateObj.region__C))
                    {
                        Set<Decimal> roleRateSet = selectedRolesRatesMap.get(modalRec.rateObj.role__c+'#'+modalRec.rateObj.region__C);
                        If(roleRateSet.contains(modalRec.rateObj.hourly_rate__c))
                        {
                            if(!duplicateRolesInTM.contains(modalRec.rateObj.role__c))
                            {
                                duplicateRolesInTM += modalRec.rateObj.role__c + ' for $'+modalRec.rateObj.hourly_rate__c +' , ';
                            }   
                        }
                        else
                        {
                            roleRateSet.add(modalRec.rateObj.hourly_rate__c);
                            selectedRolesRatesMap.put(modalRec.rateObj.role__c+'#'+modalRec.rateObj.region__C,roleRateSet);
                        }
                    }
                    else
                    {
                        selectedRolesRatesMap.put(modalRec.rateObj.role__c+'#'+modalRec.rateObj.region__C,new Set<Decimal>{modalRec.rateObj.hourly_rate__c});
                        selectedRolesTM.add(modalRec.rateObj.role__c);
                    }    
                    rateList.add(modalRec.rateObj);
                }    
            }  
            
        }
        System.debug('--------------duplicateRolesInTM -------------------------'+duplicateRolesInTM );
        //fetching all RC Rates
        if(rateRCWrapperList !=null && rateRCWrapperList.size()>0){
            Set<String> selectedRolesRC = new Set<String>();
            for(RateModal modalRec : rateRCWrapperList){
                //skipping last extra row
                if(!modalRec.isNewlyAdded){
                    //checking required fields.
                    if((modalRec.isMonthly && (modalRec.rateObj.Hours_Per_Month__c == null || modalRec.rateObj.Role__c == null || modalRec.rateObj.Hourly_Rate__c == null))
                       || (!modalRec.isMonthly && (modalRec.rateObj.Hours_Per_Week__c == null || modalRec.rateObj.Role__c == null || modalRec.rateObj.Hourly_Rate__c == null))) {
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,Constants.ERROR_REQUIRED_FIELDS);
                        ApexPages.addMessage(myMsg);
                        return null; 
                    }
                    //checking for multiple rates for a single role.
                    if(selectedRolesRC.size() > 0 && selectedRolesRC.contains(modalRec.rateObj.role__c)){
                        if(!duplicateRolesInRC.contains(modalRec.rateObj.role__c)){
                            duplicateRolesInRC += modalRec.rateObj.role__c + ', ';
                        }    
                    }else{
                        selectedRolesRC.add(modalRec.rateObj.role__c);
                    }             
                    //checking for corresponding record in Time n Materials.
                    if(!selectedRolesTM.contains(modalRec.rateObj.role__C)){
                        errorInRC = Constants.ERROR_RETAINED_CAPACITY_ROLE_MUST_HAVE_CORRESPONDING_TM ;
                    }
                    rateList.add(modalRec.rateObj);
                }    
            }           
        }
        
         //fetching all NR Rates
        if(rateNRWrapperList !=null && rateNRWrapperList.size() > 0) {
            for(RateModal modalRec : rateNRWrapperList) {
                //skipping last extra row
                if(!modalRec.isNewlyAdded) {
                    //checking required fields
                    if((modalRec.isMonthly && (modalRec.rateObj.Hours_Per_Month__c == null || modalRec.rateObj.Role__c == null || modalRec.rateObj.Monthly_Rate__c == null || modalRec.rateObj.Number_of_Months__c == null))
                       || (!modalRec.isMonthly && (modalRec.rateObj.Hours_Per_Week__c == null || modalRec.rateObj.Role__c == null || modalRec.rateObj.Weekly_Rate__c == null || modalRec.rateObj.Number_of_Weeks__c == null))) {
                       
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,Constants.ERROR_REQUIRED_FIELDS);
                        ApexPages.addMessage(myMsg);
                        return null; 
                    }
                    //checking for corresponding record in Time n Materials.
                    if(!selectedRolesTM.contains(modalRec.rateObj.role__C)){
                        errorInNR  = Constants.ERROR_NAMED_RESOURCE_ROLE_MUST_HAVE_CORRESPONDING_TM;  
                    }
                    rateList.add(modalRec.rateObj);
                }    
            }    
        }
        //Error for multiple roles in Time n Materials.
        if(!String.isBlank(duplicateRolesInTM) && duplicateRolesInTM .endsWith(', ')){
             duplicateRolesInTM =  duplicateRolesInTM.substring(0,duplicateRolesInTM .length()-2);
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,Constants.ERROR_SAME_TM_RATES + duplicateRolesInTM );
             ApexPages.addMessage(myMsg);
        } 
        //Error for multiple roles in retained capacity.
        if(!String.isBlank(duplicateRolesInRC) && duplicateRolesInRC.endsWith(', ')){
             duplicateRolesInRC =  duplicateRolesInRC.substring(0,duplicateRolesInRC.length()-2);
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,Constants.ERROR_MULTIPLE_RETAINED_CAPACITY_RATES + duplicateRolesInRC );
             ApexPages.addMessage(myMsg);
        } 
        //checking if any corresponding record in TM Section is missing for Retained section. 
        if(!String.isBlank(errorInRC)){
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errorInRC);
             ApexPages.addMessage(myMsg);
        } 
        //checking if any corresponding record in TM Section is missing Named Resources section.
        if(!String.isBlank(errorInNR)){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errorInNR);
            ApexPages.addMessage(myMsg);
        }
        
        if(!String.isBlank(duplicateRolesInTM) || !String.isBlank(duplicateRolesInRC) || !String.isBlank(errorInRC) || !String.isBlank(errorInNR)){ 
             System.debug('in multiple roles 3');
             return null;
        }
        try{
            if(rateList !=null && rateList.size()>0){
                upsert rateList;
            }    
            //removing rates from database
            if(ratesToDelete !=null && ratesToDelete.size()>0){
                delete ratesToDelete;
            }    
        }catch(Exception exp){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,exp.getMessage());
            System.debug('>>>>>>>>>'+ exp.getMessage());
            ApexPages.addMessage(myMsg);
            return null; 
        
        }    
        if(agreementId !=null){
            System.debug('in if case');
            if(Apexpages.currentPage().getParameters().get('isdtp') == 'mn')
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Confirm,'Rates have been saved successfully.');
                ApexPages.addMessage(myMsg);
                return null;
            }
            else
                return new pagereference('/'+agreementId);
        }else{
            return new pagereference('/'+rate__c.sobjecttype.getDescribe().getKeyPrefix());  
        }           
    }
      
    public pagereference cancel(){
        if(agreementId !=null){
            if(Apexpages.currentPage().getParameters().get('isdtp') == 'mn')
            {
                return new pagereference(ApexPages.currentPage().getUrl());
            }
            else
                return new pagereference('/'+agreementId);
        }else{
            return new pagereference('/'+rate__c.sobjecttype.getDescribe().getKeyPrefix());  
        }        
    }
    public class RateModal{
    
        public Rate__c rateObj {get; set;}
        public Integer index {get; set;}
        public boolean isReadOnly {get; set;}
        public boolean hasAssignments {get; set;}
        public boolean isNewlyAdded {get; set;}
        public Boolean isMonthly {get; set;}

        public RateModal(Rate__c rate, Integer indx, Boolean isReadOnly, Boolean isMonthly) {
            rateObj = rate; 
            index = indx;
            //checking for assignment rate.
            if(rate.Assignments__r != null && rate.Assignments__r.size() > 0) {
                 hasAssignments = true;
            }
            else{
                 hasAssignments = false;
            }
            
            if(rate.id != null){
                isNewlyAdded = false;
            }else{
                isNewlyAdded = true;
            }
           
            this.isReadOnly = isReadOnly;
            this.isMonthly = isMonthly;
        }
    }
}