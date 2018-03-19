({
    getAllData : function(component,recID,listLimit) 
    {
        
        //Show spinner
        var storyLimit = listLimit;
        var thisId = document.getElementById('outerDiv');
        console.log('recID : '+recID+ ' ***listLimit : '+listLimit);
        this.showSpinner(component);
        var allStoriesList = component.get("v.tempStoriesList");
        var firstList = [];
        //get action getallStories
        if(component.get("v.StoriesList").length <= 0)
        {
            var action = component.get("c.getAllStories");
            
            action.setCallback(this, function(response) 
            {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") 
                {   
                    component.set("v.tempStoriesList", response.getReturnValue());
                    $("#totItems").html(response.getReturnValue().length+" items"); //set total no of items
                    for(var i= 0; i< parseInt(listLimit); i++)
                    {
                        if(i >= response.getReturnValue().length)
                        {
                            continue;
                        }
                        firstList.push(response.getReturnValue()[i]);
                    }
                    component.set("v.StoriesList",firstList);
                    component.set("v.AllStoriesList",firstList);
                    this.fillProjectSelList(component);
                    this.hideSpinner(component);
                }
            });
            $A.enqueueAction(action);
            
            //get action getCurrUserId
            var action3 = component.get("c.getCurrUserId");
            //set call back function to action3
            action3.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    //set result to attrubute CurrUserId
                    component.set("v.CurrUserId", response.getReturnValue());
                    console.log("Current User is success");
                }
            });
            $A.enqueueAction(action3);
            
            //get Status pick value added on 25/10
            var action4 = component.get("c.getStatusPickList");
            action4.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    component.set("v.StatusList", response.getReturnValue());
                    console.log("Status list success");               
                }
            });
            $A.enqueueAction(action4);
            
        }
        else
        {
            console.log('Entered Here');
            var limitChange = parseInt(listLimit) + 10;
            var updatedList = []
            for(var i = 0; i < limitChange; i++)
            {
                console.log(i);
                
                if(i >= allStoriesList.length)
                {
                    continue;
                }
                updatedList.push(component.get("v.tempStoriesList")[i]);
            }

            
            component.set("v.StoriesList",updatedList);
            component.set("v.AllStoriesList",updatedList);
            var spinn = document.getElementById("spinn");
            spinn.classList.add('hide');
            //helper.hideSpinner(component);
            console.log('Spinner hide');
            if(recID != "renderer")
            {
                this.fillProjectSelList(component);
            }
        }
        

    },

    //this method is used to fill Project sel list ites
    fillProjectSelList : function(component){
        //get all elements
        var storiesList = component.get("v.tempStoriesList");
        var projectLIst = [];  
        //var projectNames = '';
        
        for(var i = 0 ; i < storiesList.length ; i++){                    
            if( !(storiesList[i]['Project__r'] === undefined)){                                
                
                projectLIst.push(storiesList[i]['Project__r']);                  
            }
        }
        var a = {};
        for(var i = 0 ; i < projectLIst.length ; i++){
            var key = projectLIst[i].Id;
            a[key] = projectLIst[i];
        }
        var uqnique = [];
        for(var key in a){
            uqnique.push(a[key]);
        }
        component.set("v.ProjectsList", uqnique);// set to attrubute ProjectsList
        console.log('ProjectFilterList Filled');
        this.fillSprintAndEpic(component);
    },
    
    //this function is used to fill sprint and epic list after selecting project
    fillSprintAndEpic : function(component){
        var storiesList = component.get("v.tempStoriesList");
        var sprintslst = [];
        var sprintIdSet = new Set();        
        var epicslst = [];
        var epicIdSet = new Set();	
        var sprintNames = '';  
        var epicNames = '';
        
        for(var i = 0 ; i < storiesList.length ; i++){                    
            if( !(storiesList[i]['Sprint__r'] === undefined)){  
                if(storiesList[i]['Sprint__r'].Project__c == $("#projectSelList :selected").val())
                {
                    if(!sprintIdSet.has(storiesList[i]['Sprint__c']))
                    {
                        sprintslst.push(storiesList[i]['Sprint__r']);
                        sprintIdSet.add(storiesList[i]['Sprint__c']);
                    }
                }
            } 
            if( !(storiesList[i]['Epic__r'] === undefined)){  
               
                if(storiesList[i]['Epic__r'].Project__c == $("#projectSelList :selected").val())
                {
                    if(!epicIdSet.has(storiesList[i]['Epic__c']))
                    {
                        epicslst.push(storiesList[i]['Epic__r']);
                        epicIdSet.add(storiesList[i]['Epic__c']);
                    }
                                           
                }
            } 
        }
        
        //console.log('sprintslst'+sprintslst);
        sprintslst = sprintslst.filter(function(itm,i,sprintslst){
            return i==sprintslst.indexOf(itm);
        });
        
        //console.log('sprintslst'+sprintslst);
        epicslst = epicslst.filter(function(itm,i,epicslst){
            return i==epicslst.indexOf(itm);
        });
        
        component.set("v.SprintsList",sprintslst);
        component.set("v.EpicsList",epicslst);
    },
    createStory : function (component, event, helper){
        //Show spinner
        this.showSpinner(component);
        
        var newStory = component.get("v.newStory");// get newStroy attribute
        var action = component.get("c.submitCreate");// get submitCreate method
        action.setParams({ "stryObj" : newStory });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                this.clearCreateStory(component);
                this.toggleFilerMenu(component);
                
                var AllStoriesList = component.get("v.tempStoriesList");
                AllStoriesList.push(response.getReturnValue());
                component.set("v.tempStoriesList", AllStoriesList); 
                
                $("#totItems").html(AllStoriesList.length+" items");//set length
                this.fillProjectSelList(component);
                
                //Show Tost
                this.showTost(component,"notify","Story Record Saved SuccessFully.", true, "success");
                
                helper.hideModal('createStoryModal'); 
                component.filterList(component, event, helper);
               
                //Hide spinner                
                this.hideSpinner(component);
            }
            else if (component.isValid() && state === "ERROR") { 
                var errors = response.getError();
                console.log(JSON.stringify(errors));
                var err = JSON.stringify(errors);
                var ind = err.indexOf('message');
                err = 'Story Record Updated Abort. ' + err.substring(err.indexOf('message')+10,err.indexOf("}",err.indexOf('message'))-1);
                component.set("v.ErrorMessge", err); 
                
                this.showTost(component,"notify1",err, false, "error");
                
                //Hide spinner                
                this.hideSpinner(component);
                
                //alert(err);
            }
        });
        $A.enqueueAction(action);
    },
    saveStory : function(component, index){ 
        //Show spinner
        this.showSpinner(component);
        
        var StoriesList = component.get("v.StoriesList"); 
        var storyObj = StoriesList[index]; //get selected story
        var action = component.get("c.submitSave"); 
        
        var storyObj1 = {};
        for(var key in storyObj){
            if(!(key == 'Project__r' || key == 'Sprint__r' || key == 'Epic__r')){
                storyObj1[key] = storyObj[key];
            }           
        }
        //set required values
        storyObj1.sobjectType = 'Story__c';
        storyObj1.Description__c = component.find('Description__c').get("v.value");
        storyObj1.Test_Scenarios__c = component.find('Test_Scenarios__c').get("v.value");
        storyObj1.Level_of_Effort__c = component.find('Level_of_Effort__c').get("v.value");
        
        action.setParams({ "stryObj" : storyObj1 });
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            //alert(response.getState()); 
            if (component.isValid() && state === "SUCCESS") {
                //Show Tost
                this.showTost(component,"notify","Story Record Updated SuccessFully.", true, "success");
                this.cancelEdit(component, index);  
                //Hide spinner                
                this.hideSpinner(component);
            }
            else if (component.isValid() && state === "ERROR") { 
                var errors = response.getError();
                console.log(JSON.stringify(errors));
                var err = JSON.stringify(errors);
                var ind = err.indexOf('message');
                err = 'Story Record Updated Abort. ' + err.substring(err.indexOf('message')+10,err.indexOf("}",err.indexOf('message'))-1);
                component.set("v.ErrorMessge", err); 
                //Hide spinner                
                this.hideSpinner(component);
                //show tost
                this.showTost(component,"notify",err, false, "error");
                //alert(err);
            }
        });
        $A.enqueueAction(action);
    },
    deleteStory : function(component, index){ 
        //Show spinner
        this.showSpinner(component);        
        var StoriesList = component.get("v.StoriesList"); 
        var tempStoriesList = component.get("v.tempStoriesList");
        var storyObj = StoriesList[index]; //get selected story 
        
        var action = component.get("c.submitDelete");
        var storyObj1 = {};
        for(var key in storyObj){
            if(!(key == 'Project__r' || key == 'Sprint__r' || key == 'Epic__r')){
                storyObj1[key] = storyObj[key];
            }           
        }
        storyObj1.sobjectType = 'Story__c'; 
        
        action.setParams({ "stryObj" : storyObj1 });
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            if (component.isValid() && state === "SUCCESS") {
                this.hideModal("deleteModal");
                
                StoriesList.splice(index,1);
                
                component.set("v.StoriesList", StoriesList);
                var AllStoriesList = component.get("v.AllStoriesList");
                for(var i = 0 ; i < AllStoriesList.length ; i++){
                    if(AllStoriesList[i].Id == storyObj1.Id){
                        AllStoriesList.splice(index,1);
                        break ;
                    }
                }
                for(var i = 0 ; i < tempStoriesList.length ; i++){
                    if(tempStoriesList[i].Id == storyObj1.Id){
                        tempStoriesList.splice(index,1);
                        break ;
                    }
                }
                component.set("v.AllStoriesList", AllStoriesList);
                component.set("v.tempStoriesList", tempStoriesList);
                $("#totItems").html(tempStoriesList.length+" items");//set total no of items
                //Hide spinner                
                this.hideSpinner(component);
                
                //Show Tost
                this.showTost(component,"notify","Story Record Deleted SuccessFully.", true, "success");
            }
            else if (component.isValid() && state === "ERROR") { 
                var errors = response.getError();
                var err = JSON.stringify(errors);
                var ind = err.indexOf('message');
                err = 'Story Record Delete  Abort. ' + err.substring(err.indexOf('message')+10,err.indexOf("}",err.indexOf('message'))-1);
                component.set("v.ErrorMessge", err); 
                
                //Hide spinner                
                this.hideSpinner(component);
                this.showTost(component,"notify","Story Record Deleted UnsuccessFully.", true, "success");
                //alert(err);
            }
        });
        $A.enqueueAction(action);
    },
    defaultSet : function(component) {
        
        //default status
        var statusList = [];
        statusList = component.get("v.StatusList");
        
        for(var i= 0; i < statusList.length ; i++)
            $("#"+"check"+i).attr('checked', false);
        $("#statusFiler").html('Any Status');
        
        //default stories
        $('#allStories:hidden').prop("checked", true);
        $("#storiesFiler").html('All Stories');
        
        //default project
        $("#projectSelList option:eq(0)").prop('selected', true);
        $("#projectFiler").html('Any Projects'); 
        
        //default sprint
        $("#SprintSelList option:eq(0)").prop('selected', true);
        $("#SprintFiler").html('None');
        
        //default epic
        $("#epicSelList option:eq(0)").prop('selected', true);
        $("#EpicFiler").html('None');
        
        var AllStoriesList = component.get("v.tempStoriesList");
        //change Page header
        $("#pageHeader").html("All Stories");
        $('#filterBy').html('Filtered by None'); //set filtered by label
        $("#totItems").html(AllStoriesList.length + ' items');// set total items
        
    },
    toggleClass: function(component,componentId,className) {
        var comp = component.find(componentId);
        $A.util.toggleClass(comp, className);
        //console.log("toggleClass helper");
    },  
    toggleFilerMenu : function(component) {
        this.toggleClass(component,"filterMenu","slds-is-open");// show filter panel
        $(".slds-popover--panel").hide();//hide all popover        
    },
    
    //this function is used to sort .
    sort : function(component, key, comID){
        //collapse if any
        var index = component.get("v.index");
        if(parseInt(index) != -1)
        	this.collapseMode(component, index, '');
        
        //Show spinner
        this.showSpinner(component);
        
        var storiesList = component.get(comID);
        storiesList.sort(function(a, b) {            
            if(key.indexOf('.') == -1){
                var aID = a[key];
                var bID = b[key];
            }
            else{
                var obj = key.substring(0,key.indexOf('.'));
                var field = key.substring(key.indexOf('.')+1, key.length);
                var aID = undefined ;
                var bID = undefined ;
                if( !(a[obj] === undefined)){
                    aID = a[obj][field];                   
                }	
                if( !(b[obj] === undefined)){
                    bID = b[obj][field];
                }
            }
            
            if(aID === undefined || aID == ''  )
                return -1;
            else if(bID === undefined || bID == '')
                return 1;
                else{
                    if(isNaN(aID) || isNaN(bID)){
                        return (aID == bID) ? 0 : (aID > bID) ? 1 : -1;   
                    }else{
                        var a1 = parseInt(aID);
                        var a2 = parseInt(bID);
                        return a1 - a2 ;
                    }
                }
        });
        component.set(comID, storiesList);
        var recID = 'renderer';
        var firstLimit = component.get("v.StoriesList").length - 10;
        this.getAllData (component,recID,firstLimit);
        //hide spinner
        this.hideSpinner(component);
        //console.log("sort helper");
    },
    //this function is used to sort des. 
    desSort : function(component, key, comID){
        //collapse if any
        var index = component.get("v.index");
        if(parseInt(index) != -1)
        	this.collapseMode(component, index, '');
        
        //Show spinner
        this.showSpinner(component);
        var storiesList = component.get(comID);
        storiesList.sort(function(a, b) { 
            if(key.indexOf('.') == -1){
                var aID = a[key];
                var bID = b[key];                
            }
            else{
                var obj = key.substring(0,key.indexOf('.'));
                var field = key.substring(key.indexOf('.')+1, key.length);
                var aID = undefined ;
                var bID = undefined ;
                if(! (a[obj] === undefined))
                    aID = a[obj][field];
                if(! (b[obj] === undefined))
                    bID = b[obj][field];
            }
            if((aID === undefined || aID == '') ){
                return 1;
            }
            else if(bID === undefined || bID == '')
                return -1;
                else{
                    if(isNaN(aID) || isNaN(bID)){
                        return (aID == bID) ? 0 : (aID < bID) ? 1 : -1;    
                    }else{
                        var a1 = parseInt(aID);
                        var a2 = parseInt(bID);
                        return a2 - a1 ;
                    }
                }
        });
        component.set(comID , storiesList);
        var recID = 'renderer';
        var firstLimit = component.get("v.StoriesList").length - 10;
        this.getAllData (component,recID,firstLimit);
        //hide spinner
        this.hideSpinner(component);
        
    },
    //show spinner
    showSpinner : function(component){
        var myCmp = component.find("Spinner");
        $A.util.removeClass(myCmp, "hide");
    },
    //hide spinner
    hideSpinner : function(component){
        var myCmp = component.find("Spinner");
        $A.util.addClass(myCmp, "hide");
    },
    hideModal : function(key){
        //hide modal of key
        $('#'+key).removeClass('slds-fade-in-open');
        $('#'+key).addClass('slds-fade-in-close');
        
        //hide backdrop
        $('#backdrop').removeClass('slds-backdrop--open');
        $('#backdrop').addClass('slds-backdrop-in-close');
    },
    showModal : function(key){
        //hide modal of key
        $('#'+key).removeClass('slds-fade-in-close');
        $('#'+key).addClass('slds-fade-in-open');
        
        //hide backdrop
        $('#backdrop').removeClass('slds-backdrop--close');        
        $('#backdrop').addClass('slds-backdrop--open');
    },
    clearCreateStory : function(component){
        //clear lookups
    	component.find("newFunctional_Owner__c").clear1();
        component.find("newEpic__c").clear1();
        component.find("newSprint__c").clear1();
        component.find("newProject__c").clear1();
        component.set("v.newStory", { 'sobjectType': 'Story__c','Name': '','Story_Name__c': '',
                             'Status__c': '',
                             'Priority__c': '',
                             'Level_of_Effort__c': 0,
                             'Epic__c': null,
                             'Functional_Owner__c': null,
                             'Project__c': null,
                             'Sprint__c': null,
                             'Description__c': '',
                             'Test_Scenarios__c':'',
                             });
        //set empty to newStory
    },
    expandMode : function(component, index, edit){
        component.set("v.index", index);
        //disable all expand img        
        //show view mode
        $("#expandMode"+index).show(); //show expand mode
        $('#readMode'+index).hide(); //hide read mode
        $('.imgIcon').hide(); //hide expand img
    },
    collapseMode : function(component, index, edit){
        component.set("v.index", -1); //set index -1
        component.set("v.showid", null); //set show id null
        
        $('.viewMode').show(); //show view mode
        
        //hide view mode
        $("#expandMode"+index).hide(); //hide expand mode
        $('#readMode'+index).show(); //show read mode
        $('.imgIcon').show(); //show img expand
    },
    editMode : function(component, index, value){
        $(".viewMode").hide(); //hide view mode
        
        component.set("v.showid", value); //show view mode
        component.set("v.index", index); //set index
        
        $('#filerIcon').prop('disabled', true); //disabled filter icon
        $('#filerIcon').css('fill', '#fffff');
    },
    cancelEdit : function(component, index){
        //set edit mode visiable
        //this.defaultSet(component);
        
        $('#filerIcon').prop('disabled', false); //Enabled filter icon
        $('#filerIcon').css('fill', '#0070d2');
        
        $('.viewMode').show(); //view read mode
        
        component.set("v.showid", null); //set null 
        component.set("v.index", -1); //set -1 
        component.reload();
    },
    showTost : function(component, notifyid, err, isSetTime, type){
        component.set("v.ErrorMessge", err); 
        if(type == "success" ){
            if($('#'+notifyid).hasClass('slds-theme--error'))
                $('#'+notifyid).removeClass('slds-theme--error');
            $('#'+notifyid).addClass('slds-theme--success');
            if(notifyid == "notify2")
            {
                $('#storyRecordEdit').removeClass('slds-fade-in-open');        
                $('#storyRecordEdit').addClass('slds-fade-in-close');
                $('#backdrop').removeClass('slds-backdrop--open');        
                $('#backdrop').addClass('slds-backdrop--close');
                $('#notify3').hide();
            }
        }
        if(type == 'error'){
            if($('#'+notifyid).hasClass('slds-theme--success'))
                $('#'+notifyid).removeClass('slds-theme--success');
            $('#'+notifyid).addClass('slds-theme--error');
        }
        
        $('#'+notifyid).show();
        if(isSetTime)
        	setTimeout(function(){ 
            $('#'+notifyid).hide();
            $('#notify3').hide();
            var index = component.get("v.index1");
            var stry = component.get("v.tempStory");
            var storyList = component.get("v.StoriesList");
            var allstoryList = component.get("v.AllStoriesList");
            storyList[index] = stry;
            allstoryList[index] = stry;
            component.set("v.AllStoriesList", allstoryList);
            component.set("v.StoriesList", storyList);

             }, 5000);//show for 5 sec
    },
    filter : function (component, event, helper) {
        var AllStoriesList = component.get("v.tempStoriesList");
        var userid = component.get("v.CurrUserId");
        var StoriesList = [];
        
        var filterBy = 'Filtered by ';
        
        //function for filer acc to owner
        function filter5(element, index, arr){          
            if(element.CreatedById == userid ){
                return element ;
            }
        }
        
        //function for filter acc to status
        function filter1(element,index,arr){
            var statusList = component.get("v.StatusList");   
            for(var i= 0; i<statusList.length ; i++){
                if($('#' + 'check'+i).is(":checked")){
                    if(element.Status__c ==  $('#' + 'check'+i).attr("data-value1")){                        
                        return element;
                    }
                }
            }
        }
        
        //function for filter acc to project
        function filter2(element,index,arr){
            if(element.Project__c == $("#projectSelList :selected").val()) {
                return element ;
            }
        }
        
        //function for filter acc to sprint
        function filter3(element,index,arr){
            if(element.Sprint__c == $("#SprintSelList :selected").val()) {
                return element ;
            }
        }
        
        //function for filter acc to Epic
        function filter4(element,index,arr){
            if(element.Epic__c == $("#epicSelList :selected").val()) {
                return element ;
            }
        }
        
        var result1 = [];
        result1 = AllStoriesList;
        //apply filters
        //execute  filter acc to project 
        if($("#projectSelList :selected").val() != 'all'){
            result1 = result1.filter(filter2);
            filterBy += 'Project, ';
        }
        //execute  filter acc to Sprint 
        if($("#SprintSelList :selected").val() != 'all'){
            result1 = result1.filter(filter3);
            filterBy += 'Sprint, ';
        }
        //execute  filter acc to Epic
        if($("#epicSelList :selected").val() != 'all'){
            result1 = result1.filter(filter4);
            filterBy += 'Epic, ';
        }
        //execute  filter acc to status
        var statusList = component.get("v.StatusList");  
        var i;
        for(i= 0; i<statusList.length ; i++){
            if($('#' + 'check'+i).is(":checked"))
                break ;            
        }
        if(i == statusList.length){ }
        else{result1 = result1.filter(filter1); filterBy += 'Stories Status, ';}
        
        //execute  filter acc to stories
        if($('#allStories').is(':checked')){
            //result1 = AllStoriesList;
        }
        else if($('#funOwner').is(':checked')){
            $("#pageHeader").html("My Stories - Functional Owner");
            result1 = result1.filter(filter5);
            filterBy += 'My Stories - Functional Owner, ';
        }
        else if($('#delOwner').is(':checked')){
            $("#pageHeader").html("My Stories - Delivery Owner");
            result1 = result1.filter(filter5);
            filterBy += 'My Stories - Delivery Owner, ';
        }
        else if($('#qaOwner').is(':checked')){
            $("#pageHeader").html("My Stories - QA Owner");
            result1 = result1.filter(filter5);
            filterBy += 'My Stories - QA Owner, ';
        }
        //unique list elements
        result1=result1.filter(function(itm,i,statusList){
            return i==statusList.indexOf(itm);
        });
        
        
        if(filterBy == 'Filtered by '){
            filterBy += 'None';    
        }
        else{
            filterBy = filterBy.substr(0,filterBy.lastIndexOf(',')); //remove last ,   
        }
        
        $('#filterBy').html(filterBy); //set filtered by label
        $("#totItems").html(result1.length+" items");// set total items
        //$("#sortedBy").html("Sorted by None");// 
        
        component.set("v.StoriesList", result1); // set filtered list
        helper.toggleFilerMenu(component);
    },
})