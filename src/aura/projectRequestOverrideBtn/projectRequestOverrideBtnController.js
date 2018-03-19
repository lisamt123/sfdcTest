({
    showModalBox : function(component, event, helper) {
        $A.util.removeClass(component.find("block2ID"),'slds-show');
        $A.util.addClass(component.find("block2ID"),'slds-hide');
        component.set("v.isDisable",true);
        //added based on the S-0301.hides the Requested Experts section and displays the button on load
        document.getElementById("opPanel").style.display = "none";
        document.getElementById("ShowExpertsBtn").style.display = "none";
        //Intialise
    	helper.Intialise(component,event,helper);
        document.getElementById("backGroundSectionId").style.display = "block";
    	document.getElementById("newProjectRequestSectionId").style.display = "block";
        
    },
    
    hideModalBox : function(component, event, helper) {
		helper.hideModalBox(component, event, helper);
	},
    
    save : function(component,event,helper) {           
        helper.save(component,event,helper);
    },
    
    projectChange : function(component,event,helper){
       helper.projectChange(component,event,helper);
    },
    refreshTable: function(component,event,helper){
        
        var lstprd = component.get("v.ProjectRD");
        var inc = event.getParam("incrementRow");
        //check if the changed Role is last row
        if((lstprd.length-1) == inc){
        	helper.SetPRDRows(component,event,helper);
        }           
    },
    //set the projectRequest start/End Dates
    setPrdDates : function(component,event,helper){
       helper.setPrdDates(component,event,helper);
    },
    //shows the experts section 
    //added as per the S-0301
    showExperts : function (component,event,helper){
        document.getElementById("opPanel").style.display = "block";
        document.getElementById("ShowExpertsBtn").style.display = "none";
    }
})