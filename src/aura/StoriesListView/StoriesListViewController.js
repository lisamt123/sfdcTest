({
    
    doInit : function (component, event, helper) { 
        console.log("Story List doInit");
        var recID = component.get("v.recID");
        var firstLimit = '20';
        helper.getAllData (component,recID,firstLimit);//get all data 
    },
    /*this is handler method used to update lookup field value */
    handleAccountIdUpdate : function(component, event, helper) {       
        // Get the param from the Event
        var valueId = event.getParam("sObjectId");
        var fieldAPIName = event.getParam("fieldAPIName");
        
        //get current index
        var index = component.get("v.index");
        if(valueId != '' && valueId != undefined && index != -1){
            var storiesList = component.get("v.StoriesList");
            if(fieldAPIName == 'Epic__c'){
                storiesList[index].Epic__c = valueId;
            }
            if(fieldAPIName == 'Functional_Owner__c'){
                storiesList[index].Functional_Owner__c = valueId;
            }
            if(fieldAPIName == 'Project__c'){
                storiesList[index].Project__c = valueId;	
            }
            if(fieldAPIName == 'Sprint__c'){
                storiesList[index].Sprint__c = valueId;
            }
            component.set("v.StoriesList", storiesList);
        } 
        //if index is equal -1 then fill to new Story Attribute
        if(index == -1){
            var newStory = component.get("v.newStory");
            if(fieldAPIName == 'Epic__c'){
                newStory.Epic__c = valueId;
            }
            if(fieldAPIName == 'Functional_Owner__c'){
                newStory.Functional_Owner__c = valueId;
            }
            if(fieldAPIName == 'Project__c'){
                newStory.Project__c = valueId;	
            }
            if(fieldAPIName == 'Sprint__c'){
                newStory.Sprint__c = valueId;
            }
            component.set("v.newStory", newStory);
        }
    }, 
    /*this is handler method used to clear lookup field value */
    handleAccountIdClear : function(component, event, helper) {
        
        // Get the param from the Event
        var valueId = null ;
        var fieldAPIName = event.getParam("fieldAPIName");
        
        //get current index
        var index = component.get("v.index");
        
        if(index != -1){ 
            var storiesList = component.get("v.StoriesList");
            if(fieldAPIName == 'Epic__c'){
                storiesList[index].Epic__c = valueId;
            }
            if(fieldAPIName == 'Functional_Owner__c'){
                storiesList[index].Functional_Owner__c = valueId;
            }
            if(fieldAPIName == 'Project__c'){
                storiesList[index].Project__c = valueId;	
            }
            if(fieldAPIName == 'Sprint__c'){
                storiesList[index].Sprint__c = valueId;
            }
            component.set("v.StoriesList", storiesList);
        }  
        //if index is equal -1 then fill to new Story Attribute
        if(index == -1){
            var newStory = component.get("v.newStory");
            if(fieldAPIName == 'Epic__c'){
                newStory.Epic__c = valueId;
            }
            if(fieldAPIName == 'Functional_Owner__c'){
                newStory.Functional_Owner__c = valueId;
            }
            if(fieldAPIName == 'Project__c'){
                newStory.Project__c = valueId;	
            }
            if(fieldAPIName == 'Sprint__c'){
                newStory.Sprint__c = valueId;
            }
            component.set("v.newStory", newStory);
        }
    },  
    showSpinner : function (component, event, helper) {
        
    },
    hideSpinner : function (component, event, helper) {
        
    },
    //init required js funcion
    jsLoaded : function (component, event, helper) {
        console.log("JS Loaded");
        $( document ).ready(function() { 
            
            //on project select for filter
            $( "#ProjectDone" ).click(function() {
                var str = ''
                if($("#projectSelList :selected").val() == 'all'){
                    str += 'Any Project';
                    component.set("v.SprintsList", new Array());
                    component.set("v.EpicsList", new Array());//set none on sprint drop down list
                }
                else{
                    str += 'equals ' + $("#projectSelList :selected").text();               
                    helper.fillSprintAndEpic(component); //get sprint or epic list
                }                
                $("#projectFiler").html(str);
                $("#EpicFiler").html('None');
                $("#SprintFiler").html('None');
                $("#projectFilterPop").hide();
            });
            
            //on my stories for filter
            $( "#ShowMeDone" ).click(function() {
                if($('#allStories').is(':checked')){
                    $('#storiesFiler').html("All Stories");
                }
                else if($('#funOwner').is(':checked')){
                    $('#storiesFiler').html("My Stories - Functional Owner");
                }
                else if($('#delOwner').is(':checked')){
                    $('#storiesFiler').html("My Stories - Delivery Owner");
                }
                else if($('#qaOwner').is(':checked')){
                    $('#storiesFiler').html("My Stories - QA Owner");
                }
                $("#showMeFilterPop").hide();
            });
            
            //on project sprint for filter
            $('#SprintDone').click(function(){
                var str = ''
                if($("#SprintSelList :selected").val() == 'all')
                    str += 'None';
                else
                    str += 'equals ' + $("#SprintSelList :selected").text();
                $("#SprintFiler").html(str);
                $("#SprintFilterPop").hide();                               
                
            });
            
            //on project epic for filter
            $('#EpicDone').click(function(){
                var str = ''
                if($("#epicSelList :selected").val() == 'all')
                    str += 'None';
                else
                    str += 'equals ' + $("#epicSelList :selected").text();
                $("#EpicFiler").html(str);
                $("#epicFilterPop").hide();
            });
            
            //on project status for filter
            $( "#StatusDone" ).click(function() {
                var statusList = component.get("v.StatusList");
                var str ='equals ';
                
                for(var i= 0; i<statusList.length ; i++){
                    if($('#' + 'check'+i).is(":checked")){
                        str +=   statusList[i] + ', ';  
                    }                
                }
                
                if(str.endsWith(', ')){//remove extra ,
                    str = str.substring(0,str.lastIndexOf(', '));
                }
                
                if(str == 'equals '){
                    str = 'Any Status';   
                }
                
                $('#statusFiler').html(str);
                $("#statusFilterPop").hide();
            });
            
            $("#clearCheckBox").click(function(){
                var statusList = component.get("v.StatusList");
                for(var i= 0; i<statusList.length ; i++)
                    $("#"+"check"+i).attr('checked', false);
            });
            $('.imgIcon').each(function () { 
                if($(this).attr('id') != 'editMode'+index){
                    $(this).hide();
                } 
            });
            
        });
        
    },
    expand : function (component, event, helper) { 
        //show spinner
        helper.showSpinner(component);
        
        //get event param
        var selectedItem = event.currentTarget; 
        var index = selectedItem.dataset.index;
        component.set("v.index1",index);
        //set edit true / false
        var edit = selectedItem.dataset.edit;
        var recID = selectedItem.dataset.id;
        component.set("v.recID", recID);
        console.log(selectedItem+'==='+index+'==='+edit+'==='+recID);
        console.log(component.get("v.AllStoriesList")[index]);
        console.log(component.get("v.recID"));
        recID = component.get("v.recID");

        var action = component.get("c.getcurrentStory");
            action.setParams({ 'recordID' : recID });
            action.setCallback(this, function(response) 
            {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") 
                {   
                    
                    var textArea = document.createElement('textarea');
                    textArea.innerHTML = response.getReturnValue()['Description__c'];
                    response.getReturnValue()['Description__c'] = textArea.value;
                    var textArea1 = document.createElement('textarea');
                    textArea1.innerHTML = response.getReturnValue()['Technical_Design_Notes__c'];
                    response.getReturnValue()['Technical_Design_Notes__c'] = textArea1.value;
                    var textArea2 = document.createElement('textarea');
                    textArea2.innerHTML = response.getReturnValue()['Test_Scenarios__c'];
                    response.getReturnValue()['Test_Scenarios__c'] = textArea2.value;
                    component.set("v.tempStory", response.getReturnValue());
                    component.set("v.priority",response.getReturnValue()['Priority__c']);
                    console.log('current Story');
                    
                }
            });
        $A.enqueueAction(action);

        $('#storyRecordEdit').removeClass('slds-fade-in-close');        
        $('#storyRecordEdit').addClass('slds-fade-in-open');
        $('#backdrop').removeClass('slds-backdrop--close');        
        $('#backdrop').addClass('slds-backdrop--open');
        
        helper.hideSpinner(component);
    },
    decodeEntities :function(encodedString) 
    {
        var textArea = document.createElement('textarea');
        textArea.innerHTML = encodedString;
        return textArea.value;
    },
    hidestoryRecordView : function(component, event, helper)
    {
        $('#storyRecordEdit').removeClass('slds-fade-in-open');        
        $('#storyRecordEdit').addClass('slds-fade-in-close');
        $('#backdrop').removeClass('slds-backdrop--open');        
        $('#backdrop').addClass('slds-backdrop--close');
    },
    hidestoryRecordEdit : function(component, event, helper)
    {
        var recView = component.find("storyRecordEdit");
        $A.util.removeClass(recView, "slds-fade-in-open");
        $A.util.addClass(recView, "slds-fade-in-close");
        $('#backdrop').removeClass('slds-backdrop--open');        
        $('#backdrop').addClass('slds-backdrop--close');
    },
    showstoryRecordEdit : function(component, event, helper)
    {
        var recView = component.find("storyRecordEdit");
        $A.util.removeClass(recView, "slds-fade-in-close");
        $A.util.addClass(recView, "slds-fade-in-open");
        $('#backdrop').removeClass('slds-backdrop--close');        
        $('#backdrop').addClass('slds-backdrop--open');
        this.hidestoryRecordView(component);
    },
    viewEdit : function (component, event, helper) { 
        //get event param
		var selectedItem = event.currentTarget; 
        var index = selectedItem.dataset.index; 
        var value = selectedItem.dataset.value;
		helper.editMode(component, index, value);
    },
    cancelEdit : function (component, event, helper) { 
        var selectedItem = event.currentTarget; 
        var index = selectedItem.dataset.index; 
        var value = selectedItem.dataset.value;
        helper.cancelEdit(component, index);
        component.set("v.showid", value);
    },
    showModel : function (component, event, helper){
        component.set("v.index", -1);
        //get event param
        var selectedItem = event.currentTarget; 
        var modelId = selectedItem.dataset.modalid;
        helper.showModal(modelId);
    },
    saveStory : function (component, event, helper){
        //show modal
        helper.createStory(component, event, helper);  
        
        //helper.defaultSet(component);
        //component.reload();
    },
    cancelCreate : function (component, event, helper){       
        //get event param
        var selectedItem = event.currentTarget; 
        var modelId = selectedItem.dataset.modalid;
        //hide modal
        helper.hideModal(modelId);  
        //clear newStory 
        helper.clearCreateStory(component);
        $('#notify1').hide(); 
    },
    deleteStory : function (component, event, helper){
        var selectedItem = event.currentTarget; 
        var index = selectedItem.dataset.index;
        var modelId = selectedItem.dataset.modelId;
        component.set("v.index", index);   
        helper.deleteStory(component, index);
        $('#dropDown'+index).removeClass("slds-is-open");        
        //hide modal
        helper.hideModal(modelId);          
    },
    showMenu :function (component, event, helper){
        
        var selectedItem = event.currentTarget; 
        var index = selectedItem.dataset.index; 
        component.set("v.index", index);
        //on drop Down click
        $('.dropDown').each(function () { 
            if($(this).attr('id') != 'dropDown'+index){
                $(this).removeClass( "slds-is-open" );
                $('#editMode'+index).hide();
                $('#readMode'+index).show();
            } 
            else{
                if($('#editMode'+index).is(':hidden'))
                    $('#dropDown'+index).toggleClass( "slds-is-open" ); 
                $('#editMode'+index).hide();
                $('#readMode'+index).show();
            }
        });        
    },
    hideMenu : function (component, event, helper){
        
        var selectedItem = event.currentTarget; 
        var index = selectedItem.dataset.index; 
        component.set("v.index", index);
        component.find("editMode")[index].set("v.isTrue", false);
        helper.defaultSet(component);
        component.reload();
        
        $('#filerIcon').prop('disabled', false);
        $('#filerIcon').css('background', '#fff');
        $('#readMode'+index).show();
        $('.editMode').hide();
        $('.dropDown').show();
        $('.dropDown').removeClass("slds-is-open");
    },
    saveRec : function (component, event, helper){
        var selectedItem = event.currentTarget; 
        var index = selectedItem.dataset.index; 
        component.set("v.index", index);        
        helper.saveStory(component, index);
    },
    confirmDetele : function (component, event, helper){
        var index = component.get('v.index');
        helper.deleteStory(component, index);
    },
    cancelDetele : function (component, event, helper){
        //get event param
        var selectedItem = event.currentTarget; 
        var modelId = selectedItem.dataset.modalid;
        //hide modal
        helper.hideModal(modelId);
        var AllStoriesList = component.get("v.tempStoriesList");
        $("#totItems").html(AllStoriesList.length + ' items');// set total items
    },
    sortLst : function (component, event, helper){        
        var selectedItem = event.currentTarget; 
        var key = selectedItem.dataset.header;
        var lable = selectedItem.dataset.lable;
        
        var lastSortHeader = component.get("v.lastSortHeader");
        console.log("sort :::::"+key);
        
        $("#sortedBy").html("Sorted by "+lable);
        if(lastSortHeader == lable){
            helper.desSort(component, key, "v.tempStoriesList");
            
            key = key.replace('.','_');
            $("#"+key+'Up').hide();
            $("#"+key+'Down').show();
            component.set("v.lastSortHeader", 'None');
        }else{
            helper.sort(component, key, "v.tempStoriesList");
            
            key = key.replace('.','_');
            $("#"+key+'Up').show();
            $("#"+key+'Down').hide();
            component.set("v.lastSortHeader", lable); 
        }  
    },
    showPopover : function (component, event, helper) {
        var selectedItem = event.currentTarget; 
        var popoverid = selectedItem.dataset.popoverid;
        
        $(".slds-popover--panel").hide();
        $("#"+popoverid).show();
    },
    hideNotify : function (component, event, helper){
        $('#notify').hide();   
        $('#notify1').hide();
        $('#notify2').hide();   
        $('#notify3').hide();
    },
    removeFiler : function (component, event, helper) {
        helper.defaultSet(component);
        helper.toggleFilerMenu(component);
        var list = component.get("v.blankStoriesList");
        component.set("v.StoriesList",list);
        var recID = component.get("v.recID");
        var firstLimit = '20';
        $("#sortedBy").html("Sorted by none");
        helper.getAllData (component,recID,firstLimit);  
    },
    filter : function (component, event, helper) {
        //helper.filter(component, event, helper);
        var project = $("#projectSelList :selected").val();
        var sprint = $("#SprintSelList :selected").val();
        var epic = $("#epicSelList :selected").val();
        var usertype = $('#storiesFiler').html();
        var status = [];
        var userid = 'all';
        var firstList = [];
        var listLimit = 20;
        var filterBy = 'Filtered by ';
        var statusList = component.get("v.StatusList");   
        for(var i= 0; i<statusList.length ; i++)
        {
            if($('#' + 'check'+i).is(":checked"))
            {
                status.push($('#' + 'check'+i).attr("data-value1"));
            }
        }
        if($('#allStories').is(':checked')){}
        else
        {
            userid = component.get("v.CurrUserId");
        }
        console.log(project+'=='+sprint+'=='+epic+'=='+status+'=='+userid);

        var action = component.get("c.getfilteredStory");
            action.setParams({ 'project' : project,
                                'sprint' : sprint,
                                'epic'   : epic,
                                'status' : status,
                                'userid' : userid,
                                'usertype': usertype
                             });
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
                    console.log('Records filtered');
                }
            });
        $A.enqueueAction(action);
        if($("#projectSelList :selected").val() != 'all'){
            filterBy += 'Project, ';
        }
        if($("#SprintSelList :selected").val() != 'all'){
            filterBy += 'Sprint, ';
        }
        if($("#epicSelList :selected").val() != 'all'){
            filterBy += 'Epic, ';
        }
        var statusList = component.get("v.StatusList");  
        var i;
        for(i= 0; i<statusList.length ; i++){
            if($('#' + 'check'+i).is(":checked"))
                break ;            
        }
        if(i == statusList.length){ }
        else{filterBy += 'Stories Status, ';}
        if($('#allStories').is(':checked')){
            $("#pageHeader").html("All Stories");
        }
        else if($('#funOwner').is(':checked')){
            $("#pageHeader").html("My Stories - Functional Owner");
            filterBy += 'My Stories - Functional Owner, ';
        }
        else if($('#delOwner').is(':checked')){
            $("#pageHeader").html("My Stories - Delivery Owner");
            filterBy += 'My Stories - Delivery Owner, ';
        }
        else if($('#qaOwner').is(':checked')){
            $("#pageHeader").html("My Stories - QA Owner");
            filterBy += 'My Stories - QA Owner, ';
        }
        if(filterBy == 'Filtered by '){
            filterBy += 'None';    
        }
        else{
            filterBy = filterBy.substr(0,filterBy.lastIndexOf(',')); //remove last ,   
        }
        
        $('#filterBy').html(filterBy); 
        $("#sortedBy").html("Sorted by none");
        helper.toggleFilerMenu(component);
    },
    filterToggle : function(component, event, helper)
    {
        helper.toggleFilerMenu(component);
    },
    closeEditModal : function(component, event, helper)
    {
        var notifyid = event.getParam("notifyid");
        var err = event.getParam("err");
        var isSetTime = event.getParam("isSetTime");
        var type = event.getParam("type");
        console.log(notifyid+'=='+err+'=='+isSetTime+'=='+type);
        if(notifyid == "notifyNone")
        {
            $('#storyRecordEdit').removeClass('slds-fade-in-open');        
            $('#storyRecordEdit').addClass('slds-fade-in-close');
            $('#backdrop').removeClass('slds-backdrop--open');        
            $('#backdrop').addClass('slds-backdrop--close');
            $('#notify3').hide();
        }
        else
        {
            helper.showTost(component,notifyid,err,isSetTime,type);
        }
        
    },
})