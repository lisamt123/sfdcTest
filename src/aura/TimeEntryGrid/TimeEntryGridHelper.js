({ 
    getAllData : function(component) {
        var DayDate = new Date(component.get("v.theDate"));
        if(DayDate == 'Invalid Date'){
            DayDate = new Date();
        }
        var day = String( new Date(DayDate).getDate() ) ;
        var month = String ( new Date(DayDate).getMonth() + 1 );
        var year = String (new Date(DayDate).getFullYear());
        
        var action = component.get("c.getCurrentWeek");
        action.setParams({"day": day, "month": month, "year": year});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    component.set("v.CurrentWeek", response.getReturnValue());
                }
            });
        $A.enqueueAction(action);
        var action1 = component.get("c.getwrapp");
        action1.setParams({"day": day, "month": month, "year": year});
            action1.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && state ==="SUCCESS"){
                component.set("v.activeAssignmentLst", response.getReturnValue());
                this.iniTotal(component);  
            }
        });
        $A.enqueueAction(action1); 
    }, 
    iniTotal : function(component){
        var sunday=0,monday=0,tuesday=0,wednesday=0,thursday=0,friday=0,saturday=0;
        var activeAssignmentLst = component.get('v.activeAssignmentLst');
        for (var i = 0; i < activeAssignmentLst.length; i++) {
            var tymList = activeAssignmentLst[i].TimeEntryList;                    
            if(tymList[0].totOfTimeEnries > 0 && tymList[0].totOfTimeEnries != null){
                sunday = sunday + tymList[0].totOfTimeEnries;
            } 
            if(tymList[1].totOfTimeEnries > 0 && tymList[1].totOfTimeEnries != null){
                monday = monday + tymList[1].totOfTimeEnries;
            } 
            if(tymList[2].totOfTimeEnries > 0 && tymList[2].totOfTimeEnries != null){
                tuesday = tuesday + tymList[2].totOfTimeEnries;
            } 
            if(tymList[3].totOfTimeEnries > 0 && tymList[3].totOfTimeEnries != null){
                wednesday = wednesday + tymList[3].totOfTimeEnries;
            } 
            if(tymList[4].totOfTimeEnries > 0 && tymList[4].totOfTimeEnries != null){
                thursday = thursday + tymList[4].totOfTimeEnries;
            } 
            if(tymList[5].totOfTimeEnries > 0 && tymList[5].totOfTimeEnries != null){
                friday = friday + tymList[5].totOfTimeEnries;
            } 
            if(tymList[6].totOfTimeEnries > 0 && tymList[6].totOfTimeEnries != null){
                saturday = saturday + tymList[6].totOfTimeEnries;
            } 
        } 
        component.find("totSunday").set("v.value",sunday);
        component.find("totMonday").set("v.value",monday);                
        component.find("totTuesday").set("v.value",tuesday);              
        component.find("totWednesday").set("v.value",wednesday);
        component.find("totThursday").set("v.value",thursday);
        component.find("totFriday").set("v.value",friday);
        component.find("totSaturday").set("v.value",saturday);  
        var raw = component.find('totalRaw');
        $A.util.removeClass(raw,'Boxhide');
    },
    updateTotal: function(component,j){
        var day=0;
        var activeAssignmentLst = component.get('v.activeAssignmentLst');
        for (var i = 0; i < activeAssignmentLst.length; i++) {
            var tymList = activeAssignmentLst[i].TimeEntryList;                    
            if(tymList[j].totOfTimeEnries > 0 && tymList[j].totOfTimeEnries != null){
                day = day + tymList[j].totOfTimeEnries;
            } 
        } 
        var field = (j==0) ? 'totSunday' : (j==1) ? 'totMonday' : (j==2) ? 'totTuesday' : (j==3) ? 'totWednesday' : (j==4) ? 'totThursday' :(j==5)?'totFriday':'totSaturday';
        component.find(field).set("v.value",day);
    },
    upsertTymEntry : function(component, event, helper) {   
        var toUpdateTimeEntry  = component.get("v.toUpdateTimeEntry");    
        var newTimeEntry =  [];
        var errorBox = component.find("errorBox");
        for(var i=0; i<toUpdateTimeEntry.length ; i++){
            if(toUpdateTimeEntry[i].Hours__c != '' && toUpdateTimeEntry[i].Hours__c != null 
               && toUpdateTimeEntry[i].Description__c !='' && toUpdateTimeEntry[i].Description__c != null){
                newTimeEntry.push(toUpdateTimeEntry[i]);
            }
        }
        
        if(newTimeEntry.length == 0){            
            var errorBox = component.find("errorBox");
            $A.util.removeClass(errorBox,'Boxhide');
            component.set("v.ErrorMessge","  Message: You must enter data in at least one row to submit your time card.");   
            return null; 
        }
        var action = component.get("c.submitSave");  
        action.setParams({"TimeEntry": newTimeEntry});
        action.setCallback(this, function(response) {
            var state = response.getState();                    
            if (component.isValid() && state === "SUCCESS") {
                this.toggleClassInverse(component,'backdrop','slds-backdrop--'); 
                this.toggleClassInverse(component,'modalBox','slds-fade-in-');
                var cell =  $A.getComponent(component.get("v.source")); 
                cell.set("v.tymEntryList", response.getReturnValue()); 
                var tymEntryList = response.getReturnValue();
                var totalOfcell = 0;
                for(var i=0 ; i < tymEntryList.length ; i++){
                    totalOfcell = totalOfcell + tymEntryList[i].Hours__c;
                }
                cell.set('v.totDayHours', totalOfcell);
                this.updateTotal(component,cell.get("v.Day"));                      
            }
            else if (component.isValid() && state === "ERROR") { 
                var errors = response.getError();
                var err = JSON.stringify(errors);
                var ind = err.indexOf('message');
                err = err.substring(err.indexOf('message'),err.indexOf("}",err.indexOf('message')));
                $A.util.removeClass(errorBox,'Boxhide');
                component.set("v.ErrorMessge", err); 
                //alert(err);
            }
        });
        $A.enqueueAction(action);
    },
    toggleClass: function(component,componentId,className) {
        var modal = component.find(componentId);
        $A.util.removeClass(modal,'Boxhide');
        $A.util.removeClass(modal,className+'hide');
        $A.util.addClass(modal,className+'open');
    },    
    toggleClassInverse: function(component,componentId,className) {
        var modal = component.find(componentId);
        $A.util.addClass(modal,className+'hide');
        $A.util.removeClass(modal,className+'open');
        $A.util.addClass(modal,'Boxhide');
    },
    fillStoryPicklist : function(component)
    {
        var opt = component.get("v.storyMap");
        var storyToTaskMap = component.get("v.storyTaskMap");
        setTimeout(function(){ 
            var storySelect = document.getElementsByClassName("InputSelectStory");
            var taskSelect = document.getElementsByClassName("InputSelectTask");
            var taskList = document.getElementsByClassName("InputTaskList");
            var toUpdateTimeEntry = component.get('v.toUpdateTimeEntry');

            for(var j = 0 ; j < toUpdateTimeEntry.length ; j++)
            {
                taskSelect[j].setAttribute("disabled", true);
                
                if(typeof toUpdateTimeEntry[j].Story__c != 'undefined')
                {
                    for(var i = 0; i < opt.length; i++) 
                    {
                        if(toUpdateTimeEntry[j].Story__c == opt[i].recId)
                        {
                            storySelect[j].setAttribute("data-val", opt[i].recId);
                            storySelect[j].setAttribute("value", opt[i].recName);
                        }
                    }
                    if(storyToTaskMap[toUpdateTimeEntry[j].Story__c].length > 0)
                    {
                        for(var k = 0; k < storyToTaskMap[toUpdateTimeEntry[j].Story__c].length; k++)
                        {
                            var li = document.createElement("li");
                            li.appendChild(document.createTextNode(storyToTaskMap[toUpdateTimeEntry[j].Story__c][k].recName));
                            li.setAttribute("data-name",storyToTaskMap[toUpdateTimeEntry[j].Story__c][k].recName);
                            li.setAttribute("data-val",storyToTaskMap[toUpdateTimeEntry[j].Story__c][k].recId);
                            li.setAttribute("role", "presentation");
                            li.setAttribute("class", "typeaheadlist");
                            li.addEventListener("click", function(event){
                                    event.target.parentElement.parentElement.parentElement.firstChild.firstChild.setAttribute("value",event.target.getAttribute("data-name"));
                                    event.target.parentElement.parentElement.parentElement.firstChild.firstChild.setAttribute("data-val",event.target.getAttribute("data-val"));
                                    event.target.parentElement.parentElement.parentElement.classList.remove('slds-is-open');
                                    event.target.parentElement.parentElement.firstChild.classList.add('slds-hide');
                                });
                            taskList[j].appendChild(li);

                            if(toUpdateTimeEntry[j].Task__c == storyToTaskMap[toUpdateTimeEntry[j].Story__c][k].recId)
                            {
                                taskSelect[j].setAttribute("data-val", storyToTaskMap[toUpdateTimeEntry[j].Story__c][k].recId);
                                taskSelect[j].setAttribute("value", storyToTaskMap[toUpdateTimeEntry[j].Story__c][k].recName);
                            }
                        }
                        taskSelect[j].removeAttribute("disabled");
                        taskSelect[j].setAttribute("readOnly", "readOnly");
                    }
                }
            }
        }, 500);
    },
    onStorySelectChange : function(component, event, selectedStory)
    {
        var taskListElem = event.target.parentElement.parentElement.parentElement.parentElement.parentElement.parentElement.nextElementSibling.nextElementSibling.firstChild.firstChild.firstChild.lastChild.lastChild;
        var inputTextElem = event.target.parentElement.parentElement.parentElement.parentElement.parentElement.parentElement.nextElementSibling.nextElementSibling.firstChild.firstChild.firstChild.firstChild.firstChild;
        inputTextElem.removeAttribute("value");
        inputTextElem.removeAttribute("data-val");
        inputTextElem.setAttribute("disabled", true);
        for(var i = 0; i < taskListElem.children.length; i++)
        {
            if(i != 0)
            {
                taskListElem.removeChild(taskListElem.childNodes[i]);
            }
        }

        var action2 = component.get("c.getStoryTasks");
        action2.setParams({"storyId": selectedStory});
            action2.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && state ==="SUCCESS"){
                if(response.getReturnValue().length > 0)
                {
                    for(var i=0;i< response.getReturnValue().length;i++)
                    {
                        var li = document.createElement("li");
                        li.appendChild(document.createTextNode(response.getReturnValue()[i].recName));
                        li.setAttribute("data-name", response.getReturnValue()[i].recName);
                        li.setAttribute("data-val", response.getReturnValue()[i].recId);
                        li.setAttribute("role", "presentation");
                        li.setAttribute("class", "typeaheadlist");
                        li.addEventListener("click", function(event){
                                event.target.parentElement.parentElement.parentElement.firstChild.firstChild.setAttribute("value",event.target.getAttribute("data-name"));
                                event.target.parentElement.parentElement.parentElement.firstChild.firstChild.setAttribute("data-val",event.target.getAttribute("data-val"));
                                event.target.parentElement.parentElement.parentElement.classList.remove('slds-is-open');
                                event.target.parentElement.parentElement.firstChild.classList.add('slds-hide');
                            });
                        taskListElem.appendChild(li);
                    }
                    inputTextElem.removeAttribute("disabled");
                    inputTextElem.setAttribute("readOnly", "readOnly");
                }
            }
        });
        $A.enqueueAction(action2);
    },
})