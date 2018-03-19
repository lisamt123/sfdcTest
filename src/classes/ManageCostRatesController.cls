public with sharing class ManageCostRatesController {

    public List<AssignmentWrapper> assignmentWrapperList {get; set;}
    public List<Agreement__c> agreementsList {get;set;}
    public String projectName {get; set;}
    public String selectedAgreementId {get; set;}
    public Integer selectedIndex {get; set;}
    private Set<Id> agreementIds;
    private List<Assignment__c> deletingAssignments;
    private List<Rate__c> availableRateList;
    private String projectId;
    private Integer indexNo;
    public Boolean isLightningExperience {get; set;}
    
    public ManageCostRatesController(ApexPages.StandardController std) {
        isLightningExperience = false;
        if(ApexPages.CurrentPage().GetParameters().get('sfdcIFrameOrigin') != null) {
            isLightningExperience = true;
        }
        
        assignmentWrapperList = new List<AssignmentWrapper>();
    
        agreementsList  = new List<Agreement__c>();    
        availableRateList = new List<Rate__c>();
        deletingAssignments = new List<Assignment__c>();
        agreementIds = new Set<Id>();

        projectName = '';
        indexNo = 0;
        
        //Fetch the Project Id from the URL, passed in when we arrive from the Manage Assignments button(s) on the Project
        projectId = apexpages.currentpage().getParameters().get('projectId');
        
        if(projectId == null) {
            //Handle the case in which we arrive from the Edit of an Assignment
            String assignmentId = ApexPages.CurrentPage().GetParameters().get('id');
            if(!String.isBlank(assignmentId)) {
                //getting project id
                for(Assignment__c assignmentObj : [SELECT Id, Project__c, Project__r.Name, Region__c 
                                   FROM Assignment__c 
                                   WHERE Id =: assignmentId
                                                   ORDER BY Status__c ASC]) {
                    projectId  = assignmentObj.Project__c;
                    projectName  = assignmentObj.Project__r.Name;
                }
            }
        }
        else {
          List<Project__c> projectList = [SELECT Id, Name FROM Project__c WHERE Id =: projectId];
          if(!projectList.isEmpty()) {
            projectName = projectList[0].Name;
          }
        }

        if(!String.isBlank(projectId)) {
            
            //fetching roles options
            for(Project_Agreement__c projectAgreement : [SELECT Id, Agreement__c 
                                                         FROM Project_Agreement__c 
                                                         WHERE Project__c =: projectId]) {
                agreementIds.add(projectAgreement.Agreement__c);
            }
            
            Set<String> roleSet = new Set<String>(); 
            Set<String> assignmentTypeSet = new Set<String>();
            for(Agreement__c agreement : [SELECT Id, Name, Status__c, RecordType.Id,Account__c,
                                                 (SELECT Id, Name, Agreement__c, Assignment_Type__c, Role__c, Region__c
                                                  FROM Rates__r) 
                                          FROM Agreement__c
                                          WHERE Id IN: agreementIds AND RecordTypeId =: Constants.RECORDTYPEID_AGREEMENT_DELIVERYPARTER
                                          ORDER BY Valid_Through__c DESC]) {
                 
                 //checking if multiple agreements are tied to the project
                 if(agreementIds.size() > 0) {
                    agreementsList.add(agreement);
                     //agreementOptions.add(new SelectOption(agreement.Id, agreement.Name  + ' (' + agreement.Status__c + ')'));
                 }
 
                 //fetching unique roles
                 for(Rate__c rateObj : agreement.Rates__r) {
                     availableRateList.add(rateObj);  
                 }   
            }
            
            if(!agreementIds.isEmpty()) {
            
                for(Assignment__c assignmentObj : [SELECT Id, Status__c, Resource__c, Resource__r.Name,Resource__r.AccountId, Role__c, Assignment_Type__c,
                                                          Planned_Hours__c, Billable__c, Rate__c,Cost_Rate__c,Cost_Rate__r.Agreement__c,
                                                          Cost_Rate__r.Name, Rate__r.Name, Rate__r.Agreement__c, Region__c, 
                                                          (SELECT Id 
                                                           FROM Time_Entries__r
                                                           LIMIT 5)
                                                   FROM Assignment__c
                                                   WHERE Project__c =: projectId]) {
                    
                    String agreementId = (assignmentObj.Cost_Rate__c != null) ? assignmentObj.Cost_Rate__r.Agreement__c : null;

                    assignmentWrapperList.add(new AssignmentWrapper(assignmentObj, ++indexNo, assignmentObj.Role__c, agreementId,this));
                    
                    //populating role according to selected agreement
                    selectedAgreementId = agreementId;
                    
                    selectedIndex = null;
                }
                
                
            }
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Constants.ERROR_NO_PROJECT_AGREEMENTS));
            }   
        }
    }
    
    //populate role options
    public void agreementSelected() {
      //populating roles according to the agreement
      for(AssignmentWrapper wrapperObj : assignmentWrapperList) {
        if(selectedIndex == wrapperObj.index) {
          populateRateValue();
          break; 
        }
      }
    }


    public void populateRateValue() {
        String selectedRole;
        String selectedAssignmentType;
        String selectedRegion;
        if(selectedIndex != null) {
            for(AssignmentWrapper wrapperObj : assignmentWrapperList) {
                if(wrapperObj.index == selectedIndex) {
                    selectedRole = wrapperObj.assignmentObj.Role__c;
                    selectedRegion = wrapperObj.assignmentObj.Region__c;
                    wrapperObj.rateOptions = new List<SelectOption>();
                    wrapperObj.rateOptions.add(new SelectOption('','--None--'));
                    for(Rate__c rateObj : availableRateList) {
                        if(rateObj.Role__c == selectedRole && rateObj.Agreement__c == wrapperObj.selectedAgreementId && rateObj.Region__c == selectedRegion) {
                          wrapperObj.rateOptions.add(new SelectOption(rateObj.Id,rateObj.Name));
                        }
                    }
                    if(wrapperObj.rateOptions.size() == 2){
                      wrapperObj.assignmentObj.Cost_Rate__c = wrapperObj.rateOptions[1].getValue();
                    }
                    break;
                }   
            }
        }
    }

  //to save assignments
  public pagereference save() {

    List<Assignment__c> assignmentList = new List<Assignment__c>();

    for(AssignmentWrapper wrapperObj : assignmentWrapperList) {
      //checking for required fields
      if(wrapperObj.assignmentObj.Resource__c == null || wrapperObj.assignmentObj.Status__c == null || 
        wrapperObj.assignmentObj.Role__c == null ) {

        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,Constants.ERROR_REQUIRED_FIELDS);
        ApexPages.addMessage(myMsg);
        return null; 
      } 
      if( wrapperObj.assignmentObj.Cost_Rate__c == null){
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,Constants.ERROR_REQUIRED_COST_RATE_FIELDS);
        ApexPages.addMessage(myMsg);
        return null; 
      }
      assignmentList.add(wrapperObj.assignmentObj);
    }
       
    try{
      //upserting the assignments
      if(assignmentList.size() > 0) {
        upsert assignmentList;
      }

      //deleting the assignments that were removed FROM UI by user
      if(deletingAssignments.size() > 0) {
        delete deletingAssignments;
      }

    }
    catch(Exception exp) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, exp.getMessage()));
      return null; 
    }

    if(projectId != null) {
      if(Apexpages.currentPage().getParameters().get('isdtp') == 'mn') {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, 'Assignments have been saved successfully.'));
        return null;
      }
      else {
        return new PageReference('/' + projectId);
      }
    }
    else {
      return new PageReference('/' + Assignment__c.sObjectType.getDescribe().getKeyPrefix());  
    }
  }

    //To cancel and redirect
    public PageReference cancel() {
        if(projectId != null) {
            if(ApexPages.CurrentPage().getParameters().get('isdtp') == 'mn') {
                return new PageReference(ApexPages.CurrentPage().getUrl());
            }
            else {
                return new PageReference('/' + projectId);
            }
        }
        else{
            return new PageReference('/' + Assignment__c.sObjectType.getDescribe().getKeyPrefix());  
        }        
    }

    public class AssignmentWrapper {
        public Assignment__c assignmentObj {get; set;}
        public List<SelectOption> agreementOptions {get; set;}
        public List<SelectOption> rateOptions {get; set;}
        public String selectedAgreementId {get; set;}        
        public String agreementDisplayName {get; set;}
        public Integer index {get; set;}
        public Boolean hasTimeEntry {get; set;}
        
        public AssignmentWrapper(Assignment__c assignmentObj, Integer indx, String role,String agreementId ,ManageCostRatesController outerClass) {

            agreementOptions = new List<SelectOption>();
            agreementOptions.add(new Selectoption('','--None--'));
            selectedAgreementId = agreementId;
            hasTimeEntry = false;
            rateOptions = new List<SelectOption>();
            rateOptions.add(new SelectOption('','--None--'));
            //Check for existing Time Entries, so we know whether or not to render certain things as editable
            if(assignmentObj.Time_Entries__r != null && !assignmentObj.Time_Entries__r.isEmpty()) {
              hasTimeEntry = true;
            }
            this.assignmentObj = assignmentObj;
            index = indx;
            
            Id activeAgrementId;
            Integer count = 0;
            for(Agreement__c agreement: outerClass.agreementsList){
                if(assignmentObj.Resource__r.AccountId  == agreement.Account__c){
                    agreementOptions.add(new SelectOption(agreement.Id, agreement.Name  + ' (' + agreement.Status__c + ')'));
                }
                if(agreement.Status__c == 'Active' && agreementId == null){
                  activeAgrementId = agreement.id;
                  count++;
                }
            }
            
            if(agreementOptions.size() == 2){
                selectedAgreementId = agreementOptions[1].getValue();
            }
            else if(count == 1 && activeAgrementId != null && assignmentObj.Cost_Rate__c == null){
              selectedAgreementId = activeAgrementId;
            }

            for(Rate__c rateObj : outerClass.availableRateList) {
                if(rateObj.Role__c == assignmentObj.Role__c && rateObj.Agreement__c == selectedAgreementId) {
                  rateOptions.add(new SelectOption(rateObj.Id,rateObj.Name));
                }
            }
            
            if(rateOptions.size() == 2 && assignmentObj.Cost_Rate__c == null){
                assignmentObj.Cost_Rate__c= rateOptions[1].getValue();
            }
        }
    }
}