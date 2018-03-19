public without sharing class RecalculateSharingController implements Queueable{

    set<Id> projectIds;
    set<Id> assignmentIds;
    set<Id> userIds;
    set<Id> setProjectRequestIDs;
    
    public RecalculateSharingController (set<Id> projectids,set<Id> assignmentIds,set<Id> userIds, set<Id> setProjectRequestIDs) {
        this.projectIds =  projectids;
        this.assignmentIds =  assignmentIds;
        this.userIds = userIds;
        this.setProjectRequestIDs = setProjectRequestIDs;
    }

    public void execute(QueueableContext context) {

        if(userIds !=null && userIds.size()>0){
            //queueable to sync portal user to contact
            system.debug('queueing job for contact case---->');
            System.enqueueJob(new SyncPortalUserToContactController (userIds));
        }

        if(projectIds != null && projectIds.size()>0){
        
            List<Project__c> projectList = new List<Project__c>();
            for(Project__c projectObj : [select id,name, Recalculate_Sharing_on_Save__c from project__c where id in :projectIds]){           
                
                projectObj.Recalculate_Sharing_on_Save__c = true;
                projectList.add(projectObj); 
            } 
            if(projectList.size()>0){   
                try{
                    system.debug('---> list to in queue update' + projectList);
                    if(!Test.isRunningTest())
                        update projectList;
                }catch(Exception exp){
                    system.debug('Exception caught qqqqqqq--->' + exp.getMessage());
                }
            }  
        }
        
        if(assignmentIds != null && assignmentIds.size()>0){    
            //setting checkbox to 'True'
            List<Assignment__c> assignmentList = new List<Assignment__c>();
            for(Assignment__c assignmentObj : [select id, Recalculate_Sharing_on_Save__c from assignment__c where id in :assignmentIds]){           
                assignmentObj.Recalculate_Sharing_on_Save__c = true;
                assignmentList.add(assignmentObj); 
            } 
            if(assignmentList.size()>0){   
                try{
                    system.debug('---> assignment list to update' + assignmentList);
                    if(!Test.isRunningTest())
                        update assignmentList;
                }catch(Exception exp){
                    system.debug('Exception caught ---->' + exp.getMessage());
                }
            }  
         }     
         
		if(setProjectRequestIDs != null && setProjectRequestIDs.size() > 0) {
    
			List<Project_Request__c> lstProjectRequestRecordsToUpdate = new List<Project_Request__c>();
	
			for(Project_Request__c objProjectRequest : [Select Id, Recalculate_Sharing_on_Save__c From Project_Request__c where Id IN :setProjectRequestIDs]){           
				
				Project_Request__c objProjectRequestToUpdate = new Project_Request__c(Id = objProjectRequest.Id, Recalculate_Sharing_on_Save__c = true);
				lstProjectRequestRecordsToUpdate.add(objProjectRequestToUpdate); 
			} 
	
			if(!lstProjectRequestRecordsToUpdate.isEmpty()) {  
			
				try {
				
					system.debug('---> list to in queue update' +lstProjectRequestRecordsToUpdate);
					
					if(!Test.isRunningTest()) {
					
						update lstProjectRequestRecordsToUpdate;
					}
				}
				catch(Exception exp){
				
					system.debug('Exception caught qqqqqqq--->' + exp.getMessage());
				}
			}  
		}    
 	}
}