({
    addHide : function(component) {
		var spinnerMain =  component.find("Spinner");
        $A.util.addClass(spinnerMain, "slds-hide");
	},
    
    removeHide: function(component) {
		var spinnerMain =  component.find("Spinner");
        $A.util.removeClass(spinnerMain, "slds-hide");
	},
    
	doManageReleaseHelper :function(component) {
        var releasAction = component.get("c.manageRelease");
        releasAction.setParams({ 'recId' : component.get("v.recordId")});
        releasAction.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {   
                this.doInitHelper(component,true);
            }
        });
        $A.enqueueAction(releasAction); 
    },
    showMessage :function(component) {
        document.getElementById("customMessage").classList.remove("slds-hide");
        setTimeout(function(){ 
            if(document.getElementById("customMessage") != null)
                document.getElementById("customMessage").classList.add("slds-hide");
        }, 5000);
    },
    doInitHelper :function(component,forceQuery) {
        var action                  = component.get("c.getManageReleaseArtifacts");
        var recordCount             = component.get("v.recordCount");
        var searchText              = typeof component.find("searchInText") == 'undefined' || typeof component.find("searchInText").get("v.value") == 'undefined' ? '' : component.find("searchInText").get("v.value").trim();
        var selectedMetadata        = component.get("v.selectedMetadata");
        var selectedSprint          = typeof component.get("v.selectedSprint") == 'undefined' ? '' : component.get("v.selectedSprint");
        var recordId                = component.get("v.recordId");
        var selectedMetadaListJSON  = JSON.stringify(component.get("v.metadataNameMapList"));
        var selectedStorySetJSON    = JSON.stringify(component.get("v.selectedStorySet"))
        action.setParams({ 
            'recId'                 : recordId, 
            'recordsLimit'          : recordCount.toString(),
            'searchText'            : encodeURIComponent(searchText.trim().replace(/ /g, "_")).replace(/\(/g, "%28").replace(/\)/g, "%29"),
            'selectedMetadataType'  : selectedMetadata,
            'selectedMetadaListJson': selectedMetadaListJSON,
            'selectedStoryString'   : selectedStorySetJSON,
            'selectedSprint'        : selectedSprint,
            'forceQuery'            : forceQuery
        });
        action.setCallback(this, function(response) {
        	var state = response.getState();
        	if (component.isValid() && state === "SUCCESS") { 
                var release = response.getReturnValue().release;
                if(release != null && release.Source__c == undefined || release.Source__r.Status__c != 'Active') {
                    component.set("v.message", "No active Source connection found for this Release, please add an active Source connection.");
                    component.set("v.messageType", "warning");
                    component.set("v.messageTitle", "Warning");
                    component.set("v.isInActiveConnection",true);
                    this.showMessage(component);
                    this.addHide(component);
                }
                else {
                    component.set("v.sprintOptions",response.getReturnValue().sprintList);
                    component.set("v.release",response.getReturnValue().release);
                    component.set("v.metadataOptions",response.getReturnValue().metadataOption);
                    component.set("v.selectedSprint",response.getReturnValue().selectedSprint);
                    component.set("v.storyInsideWrapper",response.getReturnValue().storyWrapperList);
                    component.set("v.metadataNameMapList",response.getReturnValue().wrapperListSelected);
                    component.set("v.metadataNameMapListComplete",response.getReturnValue().wrapperList);
                    component.set("v.selectedStorySet", response.getReturnValue().selectedStory);
                    component.set("v.recordCount", response.getReturnValue().recCount);
                    this.updateList(component,component.get('v.shortBy'));
                    console.log(response.getReturnValue().storyWrapperListToUpdate.length);
                    if(component.get("v.addMetadata"))
                        this.addMetadataTypeOptions(component);
                    else
                        this.addSprintOptions(component);
                    this.lazyLoadHelper(component,this);
                    this.addHide(component);
                    if(release.Source__r.Refresh_Running__c)
                        this.getConnectionRefreshStatus(component,this);
                    if(response.getReturnValue().storyWrapperListToUpdate.length > 0 && component.get("v.isUpdate")) {
                        $A.createComponent(
                            "c:UpdatedStoryArtifacts",
                            {
                                "storyWrapperListToUpdate"  : response.getReturnValue().storyWrapperListToUpdate,
                                "releaseId"                 : component.get("v.recordId"),
                            },
                            function(newItem, status, errorMessage) {
                                if (status === "SUCCESS") {
                                    var targetCmp   = component.find('UpdatedStoryArtifacts');
                                    var body        = targetCmp.get("v.body");
                                    body.push(newItem);
                                    targetCmp.set("v.body", body);
                                }
                                else if (status === "INCOMPLETE") {
                                    console.log("No response from server or client is offline.")
                                }
                                else if (status === "ERROR") {
                                    console.log("Error: " + errorMessage);
                                }
                            }
                        );
                    }
                    component.set("v.isUpdate",false);
                }
            }
            else if (state === "ERROR")
                this.showErrorMessage(component,response);
        });
        $A.enqueueAction(action);
    },
    showErrorMessage : function(component,response) {
        var errors = response.getError();
        if (errors) {
            errors.forEach( function (error) {

                if (error.message)
                    console.log(error.message);

                if (error.pageErrors) {
                    error.pageErrors.forEach( function(pageError) {
                        console.log(pageError.message);
                    });                 
                }

                if (error.fieldErrors) {
                    for (var fieldName in error.fieldErrors) {
                        error.fieldErrors[fieldName].forEach( function (errorList) { 
                            console.log(errorList.message + " Field Error on " + fieldName + " : ");
                        });                                
                    };                   
                } 
            }); 
        }
    },
    addMetadataTypeOptions : function(component) {
        var metadataOptionArray = component.get("v.metadataOptions");
        var metadataOpts = [];
        for (var i = 0; i < metadataOptionArray.length; i++) {
            if(metadataOptionArray[i].value == component.get("v.selectedMetadata"))
                metadataOpts.push({ "class": "optionClass", label: metadataOptionArray[i].label, value: metadataOptionArray[i].value, selected: "true" });
            else
                metadataOpts.push({ "class": "optionClass", label: metadataOptionArray[i].label, value: metadataOptionArray[i].value });
        }
        component.find("MetadataType").set("v.options", metadataOpts); 
    },
    addSprintOptions : function(component) {
        var SprintOptionArray = component.get("v.sprintOptions");
        var opts = [];
        for (var i = 0; i < SprintOptionArray.length; i++) {
            if(SprintOptionArray[i].value == component.get("v.selectedSprint"))
                opts.push({ "class": "optionClass", label: SprintOptionArray[i].label, value: SprintOptionArray[i].value, selected: "true" });
            else
                opts.push({ "class": "optionClass", label: SprintOptionArray[i].label, value: SprintOptionArray[i].value });
        } 
        component.find("currentSprints").set("v.options", opts);
    },
    lazyLoadHelper: function(component,helper) {
        var retRecords = component.get("v.metadataNameMapListComplete");
        if(component.get("v.addMetadata")) {
            document.getElementById("leftTable").innerHTML = "";
            retRecords.forEach(function(item,index1) {
                if(item.metadataType != '') {
                    item.metadataName.sort(helper.compareInner);
                    item.metadataName.forEach(function(field,index2) { 
                        var tableRow = document.createElement('tr');
                        tableRow.setAttribute("class", "firstSection");

                        var tableData = document.createElement('td');
                        var tableDataNode = document.createTextNode('+');
                        tableData.addEventListener("click", function(event){
                            helper.toggleRow(component, index1,index2, true);
                        });
                        tableData.setAttribute("style", "cursor :pointer;width:15px;");
                        tableData.appendChild(tableDataNode);
                        tableRow.appendChild(tableData);

                        var tableData2 = document.createElement('td');
                        var tableDataNode2 = document.createTextNode(decodeURIComponent(field.name.toString()));
                        tableData2.setAttribute("class", "wrap firstSectionDiv");
                        tableData2.setAttribute("style", "width:65%");
                        tableData2.setAttribute("class", "wrapColumn");
                        tableData2.setAttribute("title", decodeURIComponent(field.name.toString()));
                        tableData2.appendChild(tableDataNode2);
                        tableRow.appendChild(tableData2);

                        var tableData1 = document.createElement('td');
                        var tableDataNode1 = document.createTextNode(item.metadataType);
                        tableData1.setAttribute("style", "width:30%");
                        tableData1.setAttribute("class", "wrap");
                        tableData1.appendChild(tableDataNode1);
                        tableRow.appendChild(tableData1);
                        document.getElementById("leftTable").appendChild(tableRow);
                    });
                }
            });
        }
        document.getElementById("rightTable").innerHTML = "";
        retRecords = component.get("v.metadataNameMapList");
        retRecords.forEach(function(item,index3) {
            if(item.metadataType != '') {

                item.metadataName.sort(helper.compareInner);
                item.metadataName.forEach(function(field,index4) { 
                    var tableRow = document.createElement('tr');
                    tableRow.setAttribute("class", "secondSection");

                    var tableData = document.createElement('td');
                    var tableDataNode = document.createTextNode('x'); 
                    tableData.addEventListener("click", function(event){
                        helper.toggleRow(component, index3,index4, false);
                    });
                    tableData.setAttribute("style", "width:15px;cursor:pointer;");
                    tableData.appendChild(tableDataNode);
                    tableRow.appendChild(tableData);

                    var tableData2 = document.createElement('td');
                    var tableDataNode2 = document.createTextNode(decodeURIComponent(field.name.toString()));
                    tableData2.setAttribute("class", "secondSectionDiv wrapColumn");
                    tableData2.setAttribute("style", "width:40%");
                    tableData2.setAttribute("title", decodeURIComponent(field.name.toString()));
                    tableData2.appendChild(tableDataNode2);
                    tableRow.appendChild(tableData2);

                    var tableData4 = document.createElement('td');
                    var tableDataNode4 = document.createTextNode(typeof field.storyName == "undefined" ? '' : field.storyName);
                    tableData4.setAttribute("style", "width:70px");
                    tableData4.appendChild(tableDataNode4);
                    tableRow.appendChild(tableData4);

                    var tableData1 = document.createElement('td');
                    var tableDataNode1 = document.createTextNode(item.metadataType);
                    tableData1.setAttribute("style", "width:20%");
                    tableData1.appendChild(tableDataNode1);
                    tableRow.appendChild(tableData1);

                    var tableData3 = document.createElement('td');
                    tableData3.setAttribute("style", "width:120px;padding: .5rem 0;");
                    var select = document.createElement('select');
                    select.setAttribute("id", field.artifactId);
                    select.setAttribute("class", 'innerSelect select uiInput--select');
                    var option = document.createElement("option");
                    option.value = 'upsert';
                    option.text = 'Add/Update'
                    select.appendChild(option);
                    option = document.createElement("option");
                    option.value = 'delete';
                    option.text = 'Delete'
                    select.appendChild(option);
                    select.addEventListener("change", function(event){
                        helper.updateFinalResult(component,helper);
                    });
                    select.value = field.action;
                    tableData3.appendChild(select);
                    tableRow.appendChild(tableData3);

                    document.getElementById("rightTable").appendChild(tableRow);
                });
            }
        });
    },
    updateFinalResult : function(component,helper) {
        var selectedRecords = component.get("v.metadataNameMapList");
        selectedRecords.forEach(function(row,index5) {
            row.metadataName.forEach(function(rec,index6) { 
                var selectlist = document.getElementById(rec.artifactId);
                if(selectlist.value == 'delete')
                    rec.action = 'delete';
                else
                    rec.action = 'upsert';
            });
        });
        component.set("v.metadataNameMapList",selectedRecords);
    },
    updateArtifactsHelper :function(component) {
        var action = component.get("c.createArtifacts");
        action.setParams({ 'recId' : component.get("v.recordId"),'mapWrapperListJSON' : JSON.stringify(component.get("v.metadataNameMapList"))});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {   
               	component.set("v.message", "Artifacts have been updated succesfully.");
                component.set("v.messageType", "success");
                component.set("v.messageTitle", "Success");
                this.showMessage (component);
                $A.get("e.force:closeQuickAction").fire();
            }
            this.addHide(component);
        });
        $A.enqueueAction(action);
    },
    updateStoriesHelper :function(component,event) {
        var storyId     = event.getSource().get('v.name');
        var storyLabel  = event.getSource().get('v.label');
        var isCreate    = event.getSource().get('v.value') ? 'create' : 'remove';
        var action      = component.get("c.createReleaseStory");
        component.find("searchInText2").set("v.value",'');
        action.setParams({ 'recId' : component.get("v.recordId"),'storyId' : storyId,'action' :isCreate});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {

                var newRecords = response.getReturnValue();
                var rightList = component.get("v.metadataNameMapList");
                if(event.getSource().get('v.value')) {
                    if(newRecords.length > 0) {
                        for(var innerIndex = 0 ; innerIndex < newRecords.length ; innerIndex++ ) {
                            var count = 0;
                            for(var index = 0 ; index < rightList.length ; index++ ) {
                                if(rightList[index].metadataType == newRecords[innerIndex].metadataType) {
                                    for(var deepIndex = 0 ; deepIndex < newRecords[innerIndex].metadataName.length ;deepIndex++) {
                                        var metadataNameIndex = rightList[index].metadataName.findIndex(x => x.name === newRecords[innerIndex].metadataName[deepIndex].name);
                                        if( metadataNameIndex == -1)
                                            rightList[index].metadataName.push(newRecords[innerIndex].metadataName[deepIndex]);
                                        else {
                                            var storyName = rightList[index].metadataName[metadataNameIndex].storyName;
                                            rightList[index].metadataName[metadataNameIndex].storyName = typeof storyName == 'undefined' || storyName.trim() == '' ? storyLabel : storyName + ', ' + storyLabel;
                                        }
                                    }
                                }
                                else
                                    count++;
                            }
                            if(count == rightList.length) {
                                var innerobj = {"metadataType" :newRecords[innerIndex].metadataType , "metadataName":newRecords[innerIndex].metadataName};
                                rightList.push(innerobj);
                            }
                        }
                    }
                }
                else {
                    for(var index = 0 ; index < rightList.length ; index++ ) {
                        for(var innerIndex = 0 ; innerIndex < rightList[index].metadataName.length ;innerIndex++) {
                            var storyName = rightList[index].metadataName[innerIndex].storyName;
                            if(typeof storyName != 'undefined' && storyName != '' ) {
                                if(storyName == storyLabel) {
                                    if(rightList[index].metadataName.length == 1) {
                                        rightList.splice(index,1);
                                        index--;
                                        break;
                                    }
                                    else {
                                        rightList[index].metadataName.splice(innerIndex,1);
                                        innerIndex--;
                                    }
                                }
                            }
                        }
                    }
                }
                component.set("v.recordCount",0);
                component.set("v.metadataNameMapList",rightList);
                this.doInitHelper(component,false);
            }
        });
        $A.enqueueAction(action);
    },
    compare:function(a,b) {
        if (a.metadataType.toLowerCase() < b.metadataType.toLowerCase())
            return -1;
        if (a.metadataType.toLowerCase() > b.metadataType.toLowerCase())
            return 1;
        return 0;
    },
    compareInner:function(a,b) {
        if (a.name.toLowerCase() < b.name.toLowerCase())
            return -1;
        if (a.name.toLowerCase() > b.name.toLowerCase())
            return 1;
        return 0;
    },
    toggleRow : function(component, i,j, add) {
        var leftList = component.get("v.metadataNameMapListComplete");
        var rightList = component.get("v.metadataNameMapList");
        this.removeHide(component);
        if(add) {
            var count = 0;
            for(var index = 0 ; index < rightList.length ; index++ ) {
                if(rightList[index].metadataType == leftList[i].metadataType) {
                    rightList[index].metadataName.push(leftList[i].metadataName[j]);
                    rightList[index].metadataName.sort(this.compareInner);
                    break;
                }
                count++;
            }
            if(count == rightList.length) {
                var innerobj = {"metadataType" :leftList[i].metadataType , "metadataName":[leftList[i].metadataName[j]]};
                rightList.push(innerobj);
                rightList.sort(this.compare);
            }
            leftList[i].metadataName.splice(j,1);
        }
        else {
            var count = 0;
            for(var index = 0 ; index < leftList.length ; index++ ) {
                if(leftList[index].metadataType == rightList[i].metadataType) {
                    leftList[index].metadataName.push(rightList[i].metadataName[j]);
                    leftList[index].metadataName.sort(this.compareInner);
                    break;
                }
                count++;
            }
            if(count == leftList.length) {
                var innerobj = {"metadataType" :rightList[i].metadataType , "metadataName":[rightList[i].metadataName[j]]};
                leftList.push(innerobj);
                leftList.sort(this.compare);
            }
            rightList[i].metadataName.splice(j,1)
        }
        component.set("v.metadataNameMapListComplete",leftList);
        component.set("v.metadataNameMapList",rightList);
        this.lazyLoadHelper(component,this);
        this.addHide(component);
    }, 
    showOptionsHelper: function(component, searchTextId, trSectionType,searchText) {
        for(var i =0; i < document.getElementsByClassName(trSectionType+"Div").length; i++){
            if(searchText.length > 2) {
                if(searchText != '' && String(document.getElementsByClassName(trSectionType+"Div")[i].innerHTML).toLowerCase().indexOf(searchText.toLowerCase()) == -1)
                    document.getElementsByClassName(trSectionType)[i].style.display= "none";
                else
                    document.getElementsByClassName(trSectionType)[i].style.display= "";
            }
            else {
                document.getElementsByClassName(trSectionType)[i].style.display= "";
            }
        }
    },
    processSprintRetrieveStories: function(component,selectedSprintVar,helper) {
        var releasAction = component.get("c.retrieveStories");
        var selectedStorySetJSON    = JSON.stringify(component.get("v.selectedStorySet"))
        releasAction.setParams({ 'selectedSprint' : selectedSprintVar.get("v.value"), 'selectedStoryString' : selectedStorySetJSON});
        releasAction.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS")  
                component.set("v.storyInsideWrapper",response.getReturnValue());
            helper.addHide(component);
            this.updateList(component,component.get('v.shortBy'));
        });
        $A.enqueueAction(releasAction); 
    },
    getConnectionRefreshStatus : function(component,helper) {
        var action = component.get("c.connectionRefreshStatus");
        action.setParams({"recId": component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {   
                if(response.getReturnValue().Source__r.Refresh_Running__c) {
                    component.set("v.release",response.getReturnValue());
                    helper.getConnectionRefreshStatus(component,helper);
                }
                else {
                    component.set("v.release",response.getReturnValue());
                    this.removeHide(component);
                    this.doInitHelper(component,false);
                }
            }
        });
        $A.enqueueAction(action);
    },
    fixHeaderWidth: function() {
        if(document.getElementById('fixHeaderDiv') != null && typeof document.getElementById('fixHeaderDiv') != 'undefined')
            document.getElementById('fixHeaderDiv').style.width = document.getElementById('innerDiv').clientWidth+'px';
        if(document.getElementById('fixHeaderDiv2') != null && typeof document.getElementById('fixHeaderDiv2') != 'undefined')
            document.getElementById('fixHeaderDiv2').style.width = document.getElementById('selectedContainer').clientWidth+'px';
    },
    sortColumnHelper : function(component,event,helper) {
        var childNodes  = event.target.childNodes;
        var column      = event.target.getAttribute("id");
        component.set('v.shortBy',column);
        if(childNodes.length == 1 || childNodes.length >= 1 && childNodes[1].getAttribute('class') == 'down') {

            var symbol = document.createElement('i');
            helper.updateColumnHeaders();
            component.set('v.sortOrder','up')
            symbol.setAttribute("class", "up");
            symbol.setAttribute("Style", "pointer-events: none;");
            event.target.appendChild(symbol);
        }
        else {

            var symbol = document.createElement('i');
            helper.updateColumnHeaders();
            symbol.setAttribute("class", "down");
            component.set('v.sortOrder','down')
            symbol.setAttribute("Style", "pointer-events: none;");
            event.target.appendChild(symbol);
        }
        helper.updateList(component,column);

    },
    updateList : function(component,column) {
        var recordList = component.get('{!v.storyInsideWrapper}');
        recordList.sort(function(a,b) {

            var first   = !isNaN(a['story'][column]) && !isNaN(parseInt(a['story'][column])) ? parseInt(a['story'][column]) : a['story'][column].toLowerCase();
            var second  = !isNaN(b['story'][column]) && !isNaN(parseInt(b['story'][column])) ? parseInt(b['story'][column]) : b['story'][column].toLowerCase();

            if(component.get('v.sortOrder') == 'up') {
                if ( first < second )
                    return -1;
                if ( first > second )
                    return 1;
                return 0;
            }
            else {
                if ( first > second )
                    return -1;
                if ( first < second )
                    return 1;
                return 0;
            }
        });
        component.set('{!v.storyInsideWrapper}',recordList);
    },
    updateColumnHeaders : function() {
        var headers = document.getElementsByClassName('shortable');
        for(var count = 0 ; count < headers.length ; count++) {
            headers[count].innerHTML = headers[count].childNodes[0].textContent;
        }
    }
})