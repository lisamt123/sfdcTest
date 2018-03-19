({
    doInit : function(component, event, helper) { 
       helper.getAllData (component);//get all data   
       
    },

    refresh1 : function (component, event, helper){
        helper.getAllData (component);//get all data    
    },
    showSpinner : function (component, event, helper) {
        component.set("v.showSpinner",true);
    },
    hideSpinner : function (component, event, helper) {
        component.set("v.showSpinner",false);        
    },
    showModal : function(component, event, helper){
        //show modal
        helper.toggleClass(component,'backdrop','slds-backdrop--');
        helper.toggleClass(component,'modalBox','slds-fade-in-');    
        var submitButton = component.find("submitButton");        
        $A.util.removeClass(submitButton,'uiButton--default');                
        $A.util.removeClass(submitButton,'uiButton');        
        
        //set attributes
        component.set("v.toUpdateTimeEntry", event.getParam("timeEntry"));       
        component.set("v.source", event.getSource().getGlobalId());        
        component.set("v.selectedDay",event.getParam("selectedDay"));
        component.set("v.selectedAssig", event.getParam("selectedAssig"));
        component.set("v.isStoryRequired", event.getParam("isStoryRequired"));
        component.set("v.selectedProject",event.getParam("clickedProjectName"));
        var clickedProjectId = event.getParam("selectedProject");
        var isStoryReq = event.getParam("isStoryRequired");

        var action2 = component.get("c.getUserStories");
        action2.setParams({"projectId": clickedProjectId});
            action2.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && state ==="SUCCESS"){
                if(response.getReturnValue()[0].storyWrapperList.length < 1)
                {
                    component.set("v.hasStories", false);
                }
                else
                {
                    component.set("v.hasStories", true);
                    component.set("v.storyMap", response.getReturnValue()[0].storyWrapperList);
                    component.set("v.storyTaskMap", response.getReturnValue()[0].storyToTaskMap);
                    helper.fillStoryPicklist(component);
                }
            }
        });
        $A.enqueueAction(action2); 
    },
    hideModal : function(component, event, helper){  
        
        //get input fields
        var descriFieldArray = [];
        var hoursFieldArray = [];
        var descriField = component.find('TymDescription'); 
        var hoursField = component.find('TymHours'); 
        
        var errorBox = component.find("errorBox");
        
        //check length
        if(descriField.length === undefined){         
            descriFieldArray.push(descriField);
        }
        else{
            descriFieldArray = descriField; 
        }      
        if(hoursField.length === undefined){           
            hoursFieldArray.push(hoursField);
        }
        else{
            hoursFieldArray = hoursField;
        } 
        
        //remove error class
        for(var i=0 ; i < hoursFieldArray.length ; i++){
            $A.util.removeClass(hoursFieldArray[i],'error');
            $A.util.removeClass(descriFieldArray[i],'error');
        }
        
        //remove Blank rows
        helper.getAllData (component);
        
        //hide modal
        helper.toggleClassInverse(component,'backdrop','slds-backdrop--'); 
        helper.toggleClassInverse(component,'modalBox','slds-fade-in-');
        
        //hide error box
        $A.util.addClass(errorBox,'Boxhide');
        component.set("v.ErrorMessge","");
        
    },
    addNewTimeEntry : function (component, event, helper){        
        var toUpdateTimeEntry = component.get("v.toUpdateTimeEntry");
        var index = toUpdateTimeEntry.length;
        //add new time Entry
        var newTime = {};  
        newTime.Assignment__c =  toUpdateTimeEntry[0].Assignment__c;
        newTime.Description__c =  '';
        newTime.Date__c =  toUpdateTimeEntry[0].Date__c;
        newTime.Hours__c =  null;
        newTime.sobjectType = 'Time_Entry__c';
      
        toUpdateTimeEntry.push(newTime);

        
        component.set("v.toUpdateTimeEntry", toUpdateTimeEntry);
        
    },
    removeTimeEntry : function (component, event, helper){     
        var toUpdateTimeEntry = component.get("v.toUpdateTimeEntry");        
        var buttonClass = event.getSource().get("v.name");
        var res = buttonClass.split(" ");
        var removeclass;
        for(var i=0; i < res.length; i++) {
            if(res[i].startsWith("removeIndex")){
                removeclass = res[i];
            }            
        }
        var index;
        if(removeclass.length == 12){
            index = parseInt(removeclass.slice(removeclass.length - 1, removeclass.length));
        }else {
             index = parseInt(removeclass.slice(removeclass.length - 2, removeclass.length));
        }
        toUpdateTimeEntry.splice(index,1);
        component.set("v.toUpdateTimeEntry", toUpdateTimeEntry);
        
    },
    closeError : function(component, event, helper)
    {
        var errorBox = component.find("errorBox");
        $A.util.addClass(errorBox,'Boxhide');
    },
    createTymEntry : function(component, event, helper) {  
        var selectedIndex = component.get("v.selectedDay");
        var selectedAssig = component.get("v.selectedAssig");
        var selectedStoryList = document.getElementsByClassName("InputSelectStory");
        var selectedTaskList = document.getElementsByClassName("InputSelectTask");
        var isStoryReq = component.get("v.isStoryRequired");
        
        
        var TotHoursCell = 0;
        var errorBox = component.find("errorBox");
        
        //get hoursField
        var hoursField = component.find('TymHours');        
        var hoursFieldArray = [];
        
        //get DescriptionField
        var descriField = component.find('TymDescription');        
        var descriFieldArray = [];

         var assignField = component.find('TymAssignId');
        var assignFieldArray = [] ;
        
        //get sobjeType Field
        var stypeArray = [];
        var stypeField  = component.find('typetxt');
        
        //check length
        if(stypeField.length === undefined ){           
            stypeArray.push(stypeField);
        }
        else{
            stypeArray = stypeField; 
        } 
        if(descriField.length === undefined){           
            descriFieldArray.push(descriField);
        }
        else{
            descriFieldArray = descriField; 
        }      
        if(hoursField.length === undefined){           
            hoursFieldArray.push(hoursField);
        }
        else{
            hoursFieldArray = hoursField;
        }  

        if(assignField.length === undefined){           
            assignFieldArray.push(assignField);
        }
        else{
            assignFieldArray = assignField;
        }   
        
        for(var i=0 ; i < hoursFieldArray.length ; i++){            
            
            //set sobject type
            stypeArray[i].set("v.value","Time_Entry__c");
            
            var hours = hoursFieldArray[i].get("v.value");
            var Description = descriFieldArray[i].get("v.value");
            var timeAssignId = assignFieldArray[i].get("v.value");            
            
            if(timeAssignId == null || timeAssignId == '') {
                $A.util.removeClass(errorBox,'Boxhide');
                component.set("v.ErrorMessge","  Message: There was some error while saving time card. Please refresh your time card.");
                return null;
            }
            if( (hours == null ) && (Description === undefined || Description == null || Description == '') ){                
                $A.util.addClass(hoursFieldArray[i],'error');
                $A.util.addClass(descriFieldArray[i],'error');
                $A.util.removeClass(errorBox,'Boxhide');
                component.set("v.ErrorMessge","  Message: You must enter data in at least one row to submit your time card.");
                return null;
            }
            else if((hours == null || hours == 0 || hours < 0)){ //check hours null or 0
                $A.util.removeClass(errorBox,'Boxhide');
                component.set("v.ErrorMessge","  Message: Hours cannot be less than or equal to 0 or blank.");
                $A.util.addClass(hoursFieldArray[i],'error');
                return null;
            }
            else if ( ((hours%.25) != 0)/* && (Description === undefined || Description == null || Description == '') */){
                $A.util.removeClass(errorBox,'Boxhide');
                component.set("v.ErrorMessge","  Message: Enter Hours in correct format."); 
                $A.util.addClass(hoursFieldArray[i],'error');
                return null;
            }   
            else if( (hours > 24) /*&& (Description === undefined || Description == null || Description == '') */){
                $A.util.removeClass(errorBox,'Boxhide');
                component.set("v.ErrorMessge","  Message: You cannot log more than 24 hours for a single day.");   
                $A.util.addClass(hoursFieldArray[i],'error');
                return null;
            }
            else if(isStoryReq && selectedStoryList[i].getAttribute("data-val") == null)
            {
                $A.util.removeClass(errorBox,'Boxhide');
                component.set("v.ErrorMessge", "  Message: Story is required on all time entries for this project.");
                return null;
            }
            else if((Description === undefined || Description == null || Description == '') /*&& ( (hours == null || hours == 0) && ( (hours%.25) != 0) && (hours > 24) )*/){
                $A.util.removeClass(errorBox,'Boxhide');
                component.set("v.ErrorMessge", "  Message: Enter Description."); 
                $A.util.removeClass(hoursFieldArray[i],'error');
                $A.util.addClass(descriFieldArray[i],'error');
                return null;
            }
            else{
                $A.util.removeClass(hoursFieldArray[i],'error');
                $A.util.removeClass(descriFieldArray[i],'error');
                TotHoursCell += hours;   
            }
        }
        
        //check total hours of time entries
        if(TotHoursCell > 24){
            $A.util.removeClass(errorBox,'Boxhide');
            component.set("v.ErrorMessge", "  Message: You cannot log more than 24 hours for a single day across all the Project assignments.");        
            return null;
        }
        
        //check for Existing records
        var toUpdateTimeEntry = component.get('v.toUpdateTimeEntry');        
        for(var i =0 ; i<toUpdateTimeEntry.length ; i++){
            if((toUpdateTimeEntry[i].Id != '' && toUpdateTimeEntry[i].Id != null) && ((toUpdateTimeEntry[i].Hours__c == '' || toUpdateTimeEntry[i].Hours__c == null) || (toUpdateTimeEntry[i].Description__c == '' || toUpdateTimeEntry[i].Description__c == null) ) ){
                    $A.util.removeClass(errorBox,'Boxhide');
                    component.set("v.ErrorMessge","  Message: Existing Records can not be blank");   
                    return null;     
            }
        }
        
        
        //check for total hours of all project
        var activeAssignmentLst = component.get('v.activeAssignmentLst');
        var total = 0;
        for (var i = 0; i < activeAssignmentLst.length; i++) {
            var tymList = activeAssignmentLst[i].TimeEntryList;   
            var tym = tymList[selectedIndex].tymEnry ;            
            if(selectedAssig != i){
                if(tymList[selectedIndex].totOfTimeEnries > 0 && tymList[selectedIndex].totOfTimeEnries != null){
                    total = total + tymList[selectedIndex].totOfTimeEnries;
                }
            }
            else{
                total = total + TotHoursCell;
            }
        }
        
        if(total > 24){
            $A.util.removeClass(errorBox,'Boxhide');
            component.set("v.ErrorMessge", "  Message: You cannot log more than 24 hours for a single day across all the Project assignments.");    
        }else{
            var hasStories = component.get("v.hasStories");
            
            $A.util.addClass(errorBox,'Boxhide');            
            component.set("v.ErrorMessge","");
            for(var i=0 ; i<toUpdateTimeEntry.length ; i++){
                toUpdateTimeEntry[i].Assignment__c = assignFieldArray[i].get("v.value");
                toUpdateTimeEntry[i].Hours__c = hoursFieldArray[i].get("v.value");
                toUpdateTimeEntry[i].Description__c = descriFieldArray[i].get("v.value");
                if(hasStories)
                {
                    toUpdateTimeEntry[i].Story__c = selectedStoryList[i].getAttribute("data-val");
                    toUpdateTimeEntry[i].Task__c = selectedTaskList[i].getAttribute("data-val");
                }
            }
            component.set('v.toUpdateTimeEntry', toUpdateTimeEntry);
            helper.upsertTymEntry(component, event, helper);
        }                 
        
    },
   onStorySelectChange : function(component, event, helper)
   {
        var index = event.target.getAttribute("id").substring(5);
        var selectTask = document.getElementById("task"+index);
        selectTask.setAttribute("disabled", true);
        selectTask.options.length = 1;
        var selectedStory = event.target.value;
        
        var action2 = component.get("c.getStoryTasks");
        action2.setParams({"storyId": selectedStory});
            action2.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && state ==="SUCCESS"){
                if(response.getReturnValue().length > 0)
                {
                    for(var i=0;i< response.getReturnValue().length;i++)
                    {
                        var taskoption = new Option();
                        taskoption.setAttribute("class","optionClass");
                        taskoption.setAttribute("label",response.getReturnValue()[i].recName);
                        taskoption.setAttribute("value",response.getReturnValue()[i].recId);
                        taskoption.setAttribute("id",response.getReturnValue()[i].recId);
                        selectTask.options[selectTask.options.length] = taskoption;
                    }
                    selectTask.removeAttribute("disabled");
                }
            }
        });
        $A.enqueueAction(action2);
   },
   typeAhead : function(component, event, helper)
   {
        var list = event.target.nextElementSibling.children;
        var text = event.target.value;
        for(var i = 0; i < list.length; i++)
        {
            if(event.target.value.length > 0)
            {
                var optionText = list[i].getAttribute('data-name');
                var lowerOptionText = optionText.toLowerCase();
                var lowerText = text.toLowerCase();
                var regex = new RegExp("^" + text, "i");
                var match = optionText.match(regex);
                var contains = lowerOptionText.indexOf(lowerText) != -1;
                if (match || contains) 
                { 
                    list[i].classList.remove('is-selected');
                    list[i].classList.remove('is-hidden');
                }
                else
                {
                    list[i].classList.add('is-hidden');
                    list[i].classList.remove('is-selected'); 
                }
            }
            else
            {
                list[i].classList.remove('is-selected');
                list[i].classList.remove('is-hidden');
            }
        }
        var filteredList = event.target.nextElementSibling.querySelectorAll('li.typeaheadlist:not(.is-hidden)');
        if(filteredList.length > 0 && event.target.value.length != 0)
            filteredList[0].classList.add('is-selected');
   },
   toggleSelectList : function(component, event, helper)
   {
        event.target.parentElement.parentElement.classList.toggle('slds-is-open');
        event.target.parentElement.nextElementSibling.firstChild.classList.toggle('slds-hide');
   },
   selectStory : function(component, event, helper)
   {
        event.target.parentElement.parentElement.parentElement.firstChild.firstChild.setAttribute("value",event.target.getAttribute("data-name"));
        var taskListElem = event.target.parentElement.parentElement.parentElement.parentElement.parentElement.parentElement.nextElementSibling.nextElementSibling.firstChild.firstChild.firstChild.lastChild.lastChild;
        var inputTextElem = event.target.parentElement.parentElement.parentElement.parentElement.parentElement.parentElement.nextElementSibling.nextElementSibling.firstChild.firstChild.firstChild.firstChild.firstChild;
        if(event.target.getAttribute("data-val") == "None")
        {
            event.target.parentElement.parentElement.parentElement.firstChild.firstChild.removeAttribute("data-val");
            
            inputTextElem.removeAttribute("value");
            inputTextElem.removeAttribute("data-val");
            inputTextElem.setAttribute("disabled", true);
            inputTextElem.parentElement.parentElement.classList.remove('slds-is-open');
            inputTextElem.parentElement.nextElementSibling.firstChild.classList.add('slds-hide');
            for(var i = 0; i < taskListElem.children.length; i++)
            {
                if(i != 0)
                {
                    taskListElem.removeChild(taskListElem.childNodes[i]);
                }
            }
        }
        else
        {
            event.target.parentElement.parentElement.parentElement.firstChild.firstChild.setAttribute("data-val",event.target.getAttribute("data-val"));
        }
        inputTextElem.parentElement.parentElement.classList.remove('slds-is-open');
        inputTextElem.parentElement.nextElementSibling.firstChild.classList.add('slds-hide');
        event.target.parentElement.parentElement.parentElement.classList.remove('slds-is-open');
        event.target.parentElement.parentElement.firstChild.classList.add('slds-hide');
        var selectedStory = event.target.getAttribute("data-val");
        component.set("v.selectedStory", selectedStory);
        if(event.target.getAttribute("data-val") != "None")
        {
            helper.onStorySelectChange(component, event, selectedStory);
        }
   },
   selectTask : function(component, event, helper)
   {
        event.target.parentElement.parentElement.parentElement.firstChild.firstChild.removeAttribute("value");
        event.target.parentElement.parentElement.parentElement.firstChild.firstChild.removeAttribute("data-val");
        event.target.parentElement.parentElement.parentElement.classList.remove('slds-is-open');
        event.target.parentElement.parentElement.firstChild.classList.add('slds-hide');
   }
   
})