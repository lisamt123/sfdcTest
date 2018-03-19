/**
        Name            :        ManageAssignmentsController
        Date            :        July 08, 2016
        Author          :        
        Description     :        This controller is used to manage Assignments(create/edit/delete) under a Project.

*/

public class ManageAssignmentsController{

    public List<AssignmentWrapper> assignmentWrapperList {get; set;}
    public List<SelectOption> agreementOptions {get; set;}
    public List<SelectOption> roleOptions {get; set;}
    public List<SelectOption> assignmentTypes {get; set;}
    public List<SelectOption> regionOptions {get; set;}
    public String projectName {get; set;}
    public String selectedAgreementId {get; set;}
    public Integer selectedIndex {get; set;}
    public Boolean flag {get; set;}
    public Boolean isLightningExperience {get; set;}

    private Map<Id,Id> agreementRecordTypeMap;
    private Set<Id> agreementIds;
    private List<Assignment__c> deletingAssignments;
    private List<Rate__c> availableRateList;
    private Project__c projectRec;
    
    private String projectId;
    private Integer indexNo;
    
    public ManageAssignmentsController(ApexPages.StandardController std) {
        isLightningExperience = false;
        if(ApexPages.CurrentPage().GetParameters().get('sfdcIFrameOrigin') != null) {
            isLightningExperience = true;
        }
        
        assignmentWrapperList = new List<AssignmentWrapper>();
    
        agreementOptions  = new List<SelectOption>();
        agreementOptions.add(new SelectOption('','--None--')); 

        regionOptions  = new List<SelectOption>();
        regionOptions.add(new SelectOption('','--None--'));
        Schema.sObjectType objType = Rate__c.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        List<Schema.PicklistEntry> options = fieldMap.get('Region__c').getDescribe().getPickListValues(); 
        for( Schema.PicklistEntry option : options)
            regionOptions.add(new SelectOption(option.getLabel(), option.getValue()));

        roleOptions = new List<SelectOption>();
        roleOptions.add(new SelectOption('','--None--'));
        
        assignmentTypes = new List<SelectOption>();
        assignmentTypes.add(new SelectOption('','--None--'));

        agreementRecordTypeMap = new Map<Id,Id>();
        availableRateList = new List<Rate__c>();
        deletingAssignments = new List<Assignment__c>();
        agreementIds = new Set<Id>();

        projectName = '';
        indexNo = 0;
        flag = false;
        
        //Fetch the Project Id from the URL, passed in when we arrive from the Manage Assignments button(s) on the Project
        projectId = apexpages.currentpage().getParameters().get('projectId');
        
        if(projectId == null) {
            //Handle the case in which we arrive from the Edit of an Assignment
            String assignmentId = ApexPages.CurrentPage().GetParameters().get('id');
            if(!String.isBlank(assignmentId)) {
                //getting project id
                for(Assignment__c assignmentObj : [SELECT Id, Project__c, Project__r.Name, Start_Date__c, End_Date__c,
                                                    Resource__r.Region_Picklist__c  
                                                   FROM Assignment__c 
                                                   WHERE Id =: assignmentId
                                                   ORDER BY Status__c ASC]) {
                    projectId  = assignmentObj.Project__c;
                    projectName  = assignmentObj.Project__r.Name;
                }
            }
        }
        else {
          List<Project__c> projectList = [SELECT Id, Name, Start_Date__c, End_Date__c FROM Project__c WHERE Id =: projectId];
          if(!projectList.isEmpty()) {
            projectName = projectList[0].Name;
            projectRec = projectList[0];
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
            for(Agreement__c agreement : [SELECT Id, Name, Status__c, RecordType.Id,
                                                 (SELECT Id, Name, Agreement__c, Assignment_Type__c, Role__c, Region__c 
                                                  FROM Rates__r) 
                                          FROM Agreement__c
                                          WHERE Id IN: agreementIds AND RecordTypeId !=: Constants.RECORDTYPEID_AGREEMENT_DELIVERYPARTER
                                          ORDER BY Valid_Through__c DESC]) {
                 
                 //checking if multiple agreements are tied to the project
                 if(agreementIds.size() > 0) {
                     agreementOptions.add(new SelectOption(agreement.Id, agreement.Name + ' (' + agreement.Status__c + ')'));
                 }
 
                 //fetching unique roles
                 for(Rate__c rateObj : agreement.Rates__r) {
                     if(!roleSet.contains(rateObj.Role__c)) {
                         roleOptions.add(new SelectOption(rateObj.Role__c, rateObj.Role__c));
                         roleSet.add(rateObj.Role__c);
                     }    
                     availableRateList.add(rateObj);  
                 }   
                 agreementRecordTypeMap.put(agreement.Id, agreement.RecordType.Id);
            } 
            
            if(!agreementIds.isEmpty()) {
                for(Assignment__c assignmentObj : [SELECT Id, Status__c, Resource__c, Resource__r.Name, Role__c, Assignment_Type__c, Start_Date__c, 
                                                          Planned_Hours__c, Billable__c, Rate__c, Rate__r.Name, Rate__r.Agreement__c, End_Date__c, 
                                                          Region__c, Resource__r.Region_Picklist__c, 
                                                          (SELECT Id 
                                                           FROM Time_Entries__r
                                                           LIMIT 5)
                                                   FROM Assignment__c
                                                   WHERE Project__c =: projectId]) {
                    
                    String agreementId = (assignmentObj.Rate__c != null) ? assignmentObj.Rate__r.Agreement__c : null;
                    //assignmentWrapperList.add(new AssignmentWrapper(assignmentObj, ++indexNo, assignmentObj.Role__c, assignmentObj.Assignment_Type__c, agreementId,this,projectRec));
                    assignmentWrapperList.add(new AssignmentWrapper(assignmentObj, ++indexNo, assignmentObj.Role__c, assignmentObj.Assignment_Type__c, agreementId,this,projectRec,assignmentObj.Region__c));
                    selectedIndex = indexNo;
                    
                    //populating role according to selected agreement
                    selectedAgreementId = agreementId;
                    
                    if(agreementIds.size() > 1){
                        //agreementSelected();
                    }
                    else {
                        //populateValidAssignmentTypes();
                    }
 
                    selectedIndex = null;
                }

                //fetching and setting rate in modal
                if(agreementIds.size() == 1) {
                    //agreementSelected();
                    //populateRateValue();
                }
                
                //setting default assignment type for new record
                
                //assignmentWrapperList.add(new AssignmentWrapper(new Assignment__c(Project__c = projectId), ++indexNo, '', '', '',null,projectRec));
                assignmentWrapperList.add(new AssignmentWrapper(new Assignment__c(Project__c = projectId), ++indexNo, '', '', '',null,projectRec,''));
            }
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Constants.ERROR_NO_PROJECT_AGREEMENTS));
            }   
        }
    }
    
  public void resourceSelected() {
    if(selectedIndex != null) {
      for(AssignmentWrapper wrapperObj : assignmentWrapperList) {
        if(wrapperObj.index == selectedIndex) {
          wrapperObj.isNewlyAdded = false;
          //setting default assignment type for new record
          String agreementId = '';
          if(agreementOptions.size() == 2) {
            //for(Id agreeId : agreementIds) {
              agreementId = agreementOptions[1].getvalue();
              //break;
            //}  
            wrapperObj.selectedAgreementId = agreementId;
            Set<String> roleSet = new Set<String>();
            for(Rate__c rateObj : availableRateList) {
                if(rateObj.Agreement__c == wrapperObj.selectedAgreementId && !roleSet.contains(rateObj.Role__c)) {                         
                    wrapperObj.roleOptions.add(new SelectOption(rateObj.Role__c, rateObj.Role__c));
                    roleSet.add(rateObj.Role__c);                  
                }
            }
          }
          if(!String.isBlank(wrapperObj.assignmentObj.Resource__c)) {
            List<Contact> contactList = [select Id,Region_Picklist__c from Contact where Id = :wrapperObj.assignmentObj.Resource__c];
            if(contactList.size() > 0) {
              Contact conObj = contactList[0] ;
              if(!String.isBlank(conObj.Region_Picklist__c))
                wrapperObj.selectedRegion = conObj.Region_Picklist__c ;
            }
          }
          if(assignmentTypes.size() == 2) {
            //assignmentWrapperList.add(new AssignmentWrapper(new Assignment__c(Project__c = projectId), ++indexNo, '', Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS, '',null,projectRec));
            assignmentWrapperList.add(new AssignmentWrapper(new Assignment__c(Project__c = projectId), ++indexNo, '', Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS, '',null,projectRec,''));
          }
          else{
            //assignmentWrapperList.add(new AssignmentWrapper(new Assignment__c(Project__c = projectId), ++indexNo, '', '', '',null,projectRec));
            assignmentWrapperList.add(new AssignmentWrapper(new Assignment__c(Project__c = projectId), ++indexNo, '', '', '',null,projectRec,''));
          }
          selectedIndex = 0;
          break;
        }
      }
    }
  }

    //populate role options
    public void agreementSelected() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));
        
        //populating roles according to the agreement
        if(!String.isBlank(selectedAgreementId)) {
            Set<String> roleSet = new Set<String>();
            for(Rate__c rateObj : availableRateList) {
                if(rateObj.Agreement__c == selectedAgreementId && !roleSet.contains(rateObj.Role__c) ) {                         
                    options.add(new SelectOption(rateObj.Role__c, rateObj.Role__c));
                    roleSet.add(rateObj.Role__c);                  
                }
            }
            
            for(AssignmentWrapper wrapperObj : assignmentWrapperList) {
                if(selectedIndex == wrapperObj.index) {
                   wrapperObj.roleOptions = options ;
            
                  if(options.size() == 2) {
                      wrapperObj.selectedRole =  options.get(1).getvalue(); 
                    }
                    flag = true;
                    populateRateValue();
                    break; 
                }
            }
        } 
        else {
          for(AssignmentWrapper wrapperObj : assignmentWrapperList) {
              if(selectedIndex == wrapperObj.index) {
                  wrapperObj.roleOptions = options;
                       
                    wrapperObj.selectedRole =  options.get(0).getvalue(); 
                    flag = true;
                    populateRateValue();
                    break; 
                }
            }
        }
    }

    //to populate valid assignment types
    private void populateValidAssignmentTypes(){
        Set<String> assignmentTypeSet = new Set<String>();

        for(AssignmentWrapper wrapperObj : assignmentWrapperList) {
            if(wrapperObj.index == selectedIndex) {
                wrapperObj.assignmentTypes = new List<SelectOption>();
                wrapperObj.assignmentTypes.add(new SelectOption('', '--None--'));

                for(Rate__c rateObj : availableRateList) {
                    //adding agreement id in condtions // new
                    if(wrapperObj.selectedRole ==  rateObj.Role__c && wrapperObj.selectedAgreementId == rateObj.Agreement__c) {
                        //fetching unique assignment types
                        //for assignment checking record type id of agreement
                        
                        system.debug('GETTING HERE!!!');

                        if(agreementRecordTypeMap.containsKey(wrapperObj.selectedAgreementId) && agreementRecordTypeMap.get(wrapperObj.selectedAgreementId) == Constants.RECORDTYPEID_AGREEMENT_RETAINER 
                           && (rateObj.Assignment_Type__c == Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS || rateObj.Assignment_Type__c == Constants.ASSIGNMENTTYPE_NAMEDRESOURCE)) {
                            if(!assignmentTypeSet.contains(rateObj.Assignment_Type__c)) {
                                wrapperObj.assignmentTypes.add(new SelectOption(rateObj.Assignment_Type__c, rateObj.Assignment_Type__c));
                                assignmentTypeSet.add(rateObj.Assignment_Type__c);
                             }    
                        }
                        else if(agreementRecordTypeMap.containsKey(wrapperObj.selectedAgreementId) && agreementRecordTypeMap.get(wrapperObj.selectedAgreementId) != Constants.RECORDTYPEID_AGREEMENT_RETAINER && 
                                  rateObj.Assignment_Type__c == Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS) {
                            if(!assignmentTypeSet.contains(rateObj.Assignment_Type__c)) {
                              wrapperObj.assignmentTypes.add(new SelectOption(rateObj.Assignment_Type__c,rateObj.Assignment_Type__c));
                                assignmentTypeSet.add(rateObj.Assignment_Type__c);
                            }
                        }
                    }
                }
                
                //Set the default selection if there is only one option available
        if(wrapperObj.assignmentTypes.size() == 2) {
                  wrapperObj.assignmentObj.Assignment_Type__c = wrapperObj.assignmentTypes.get(1).getvalue();
                }
            }
        }    
    }

    public void populateRateValue() {
        String selectedRole;
        String selectedAssignmentType;

        //system.debug('========='+selectedIndex);
        //system.debug('========='+flag);

        if(selectedIndex != null) {
            if(flag) {
                populateValidAssignmentTypes();
            } 
            //for single one   
            for(AssignmentWrapper wrapperObj : assignmentWrapperList) {
                if(wrapperObj.index == selectedIndex) {
                    wrapperObj.rateOptions = new List<SelectOption>();
                    wrapperObj.rateOptions.add(new SelectOption('', '--None--'));
                    selectedRole = wrapperObj.selectedRole;
                    selectedAssignmentType =  wrapperObj.assignmentObj.Assignment_Type__c;

                    for(Rate__c rateObj : availableRateList) {
                        //if(rateObj.Assignment_Type__c == selectedAssignmentType && rateObj.Role__c == selectedRole && rateObj.Agreement__c == wrapperObj.selectedAgreementId) {
                        //    wrapperObj.rateOptions.add(new SelectOption(rateObj.Id, rateObj.Name));
                        //}
                        if(rateObj.Assignment_Type__c == selectedAssignmentType && rateObj.Role__c == selectedRole && 
                            rateObj.Agreement__c == wrapperObj.selectedAgreementId && (!String.isBlank(wrapperObj.selectedRegion)) 
                            && rateObj.Region__c == wrapperObj.selectedRegion) {
                            wrapperObj.rateOptions.add(new SelectOption(rateObj.Id, rateObj.Name));
                        }
                    } 
                    if(wrapperObj.rateOptions.size()==2) {
                        wrapperObj.selectedRate = wrapperObj.rateOptions.get(1).getvalue();
                    }
                    break;
                }   
            }
        }
        else{
            //setting rate on the basis of SELECTed role and assignment. (at the time of starting)
            for(AssignmentWrapper wrapperObj : assignmentWrapperList) {
                
                if(wrapperObj.assignmentObj.Rate__c == null) {
                    wrapperObj.rateOptions = new List<SelectOption>();
                    wrapperObj.rateOptions.add(new SelectOption('', '--None--'));

                    selectedRole = wrapperObj.selectedRole;
                    selectedAssignmentType = wrapperObj.assignmentObj.Assignment_Type__c;

                    for(Rate__c rateObj : availableRateList) {
                        if(rateObj.Assignment_Type__c == selectedAssignmentType && rateObj.Role__c == selectedRole && rateObj.Agreement__c == wrapperObj.selectedAgreementId) {
                            wrapperObj.rateOptions.add(new SelectOption(rateObj.Id, rateObj.Name));    
                            wrapperObj.selectedRate = rateObj.Id;
                            wrapperObj.selectedRateName =  rateObj.Name;
                        }    
                    } 
                    
                    // if any assignment has no assignment rates and there are multiple options then SELECT none
                    if(wrapperObj.rateOptions.size() > 2) {
                      wrapperObj.selectedRate = null;
                    }
                }   
            }
        }
    }

  //Deletes the selected row from the grid
  public void deleteRow() {
    if(selectedIndex != null) {
      List<AssignmentWrapper> tempAssignmentWrapperList = new List<AssignmentWrapper>();
      for(AssignmentWrapper wrapperObj : assignmentWrapperList) {
        if(wrapperObj.index != selectedIndex) {
          tempAssignmentWrapperList.add(wrapperObj);
        }
        else if(wrapperObj.assignmentObj.id != null) {
          deletingAssignments.add(wrapperObj.assignmentObj);
        }
      }
      assignmentWrapperList = tempAssignmentWrapperList;     
    }
  }

  //to save assignments
  public pagereference save() {

    List<Assignment__c> assignmentList = new List<Assignment__c>();

    for(AssignmentWrapper wrapperObj : assignmentWrapperList) {

      if(!wrapperObj.isNewlyAdded) {

        wrapperObj.assignmentObj.Role__c = wrapperObj.selectedRole;
        wrapperObj.assignmentObj.Rate__c = wrapperObj.selectedRate;
        wrapperObj.assignmentObj.Region__c = wrapperObj.selectedRegion;
        //checking for required fields 
        if(wrapperObj.assignmentObj.Resource__c == null || wrapperObj.assignmentObj.Status__c == null ||
           wrapperObj.assignmentObj.Assignment_Type__c == null || wrapperObj.assignmentObj.Role__c == null ||
           wrapperObj.selectedRate == null || wrapperObj.assignmentObj.Region__c == null) {

          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,Constants.ERROR_REQUIRED_FIELDS);
          ApexPages.addMessage(myMsg);
          return null; 
        } 
        assignmentList.add(wrapperObj.assignmentObj);
      }     
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
        public List<SelectOption> rateOptions {get; set;}
        public List<SelectOption> assignmentTypes {get; set;}
        public List<SelectOption> roleOptions {get; set;}
        public List<SelectOption> regionOptions {get; set;}
        public Id selectedRate {get; set;}

        public String selectedAgreementId {get; set;}
        public String selectedRegion {get; set;}
        public String agreementDisplayName {get; set;}
        public String selectedRateName {get; set;}
        public String selectedRole {get; set;}
        
        public Integer index {get; set;}

        public Boolean isNewlyAdded {get; set;}
        public Boolean hasTimeEntry {get; set;}
        //public AssignmentWrapper(Assignment__c assignmentObj, Integer indx, String role, String assignmentType, String agreementId ,ManageAssignmentsController outerClass,Project__c project) {
        public AssignmentWrapper(Assignment__c assignmentObj, Integer indx, String role, String assignmentType, String agreementId ,ManageAssignmentsController outerClass,Project__c project,String region) {
            assignmentTypes = new List<SelectOption>();
            assignmentTypes.add(new SelectOption('','--None--'));

            rateOptions = new List<SelectOption>();
            rateOptions.add(new SelectOption('','--None--'));

            roleOptions = new List<SelectOption>();
            roleOptions.add(new SelectOption('','--None--'));
            
            //regionOptions = ManageAssignmentsController.getPicklistValues('Assignment__c','Region__c');
            regionOptions = new List<SelectOption>();
            regionOptions.add(new SelectOption('','--None--'));

            selectedRegion = region ;
            selectedAgreementId = agreementId;
            hasTimeEntry = false;
            if(project != null)
            {
              if(assignmentObj.Start_Date__c == null)
              {
                assignmentObj.Start_Date__c = project.Start_Date__c;
              }
              if(assignmentObj.End_Date__c == null)
              {
                assignmentObj.End_Date__c = project.End_Date__c;
              }
            }

            
           
            //Set the default values used on newly created Assignments
            if(assignmentObj.Id == null) {
                isNewlyAdded = true;
                assignmentObj.Status__c = 'Active';
                assignmentObj.Billable__c = true;
            }
            else {
                isNewlyAdded = false;
                
                //Check for existing Time Entries, so we know whether or not to render certain things as editable
                if(assignmentObj.Time_Entries__r != null && !assignmentObj.Time_Entries__r.isEmpty()) {
                  hasTimeEntry = true;
                }
                
                if(assignmentObj.Rate__c != null) {
                  selectedRate = assignmentObj.Rate__c;
                  selectedRateName = assignmentObj.Rate__r.Name;
                  rateOptions.add(new SelectOption(assignmentObj.Rate__c, assignmentObj.Rate__r.Name));
                }
            }

            assignmentObj.Assignment_Type__c = assignmentType;

            this.assignmentObj = assignmentObj;
            index = indx;
            selectedRole = role;

            //populating roles according to the agreement
            if(!String.isBlank(agreementId)) {
                Set<String> roleSet = new Set<String>();
                for(Rate__c rateObj : outerClass.availableRateList) {
                    if(rateObj.Agreement__c == agreementId && !roleSet.contains(rateObj.Role__c)) {                         
                        roleOptions.add(new SelectOption(rateObj.Role__c, rateObj.Role__c));
                        roleSet.add(rateObj.Role__c);                  
                    }
                } 
                Set<String> assignmentTypeSet = new Set<String>();

                for(Rate__c rateObj : outerClass.availableRateList) {
                    //adding agreement id in condtions // new
                    if(selectedRole ==  rateObj.Role__c && agreementId == rateObj.Agreement__c) {
                        //fetching unique assignment types
                        //for assignment checking record type id of agreement

                        if(outerClass.agreementRecordTypeMap.containsKey(agreementId) && outerClass.agreementRecordTypeMap.get(agreementId) == Constants.RECORDTYPEID_AGREEMENT_RETAINER 
                           && (rateObj.Assignment_Type__c == Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS || rateObj.Assignment_Type__c == Constants.ASSIGNMENTTYPE_NAMEDRESOURCE)) {
                            if(!assignmentTypeSet.contains(rateObj.Assignment_Type__c)) {
                                assignmentTypes.add(new SelectOption(rateObj.Assignment_Type__c, rateObj.Assignment_Type__c));
                                assignmentTypeSet.add(rateObj.Assignment_Type__c);
                             }    
                        }
                        else if(outerClass.agreementRecordTypeMap.containsKey(agreementId) && outerClass.agreementRecordTypeMap.get(agreementId) != Constants.RECORDTYPEID_AGREEMENT_RETAINER && 
                                  rateObj.Assignment_Type__c == Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS) {
                            if(!assignmentTypeSet.contains(rateObj.Assignment_Type__c)) {
                              assignmentTypes.add(new SelectOption(rateObj.Assignment_Type__c,rateObj.Assignment_Type__c));
                                assignmentTypeSet.add(rateObj.Assignment_Type__c);
                            }
                        }
                    }
                }
            } 
        }

    }
}