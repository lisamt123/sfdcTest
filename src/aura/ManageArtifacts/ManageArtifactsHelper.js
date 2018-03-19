({
    addHide : function(component) {
        var spinnerMain =  component.find("Spinner");
        $A.util.addClass(spinnerMain, "slds-hide");
    },
    
    removeHide: function(component) {
        var spinnerMain =  component.find("Spinner");
        $A.util.removeClass(spinnerMain, "slds-hide");
    },
    showMessage : function(component) {
        document.getElementById("customMessage").classList.remove("slds-hide");
        setTimeout(function(){ 
            if(document.getElementById("customMessage") != null){
                document.getElementById("customMessage").classList.add("slds-hide");
            }
        }, 5000);
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
    toggleRow : function(component, i,j, add,helper) {
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
                rightList.sort(helper.compare);
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
                leftList.sort(helper.compare);
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

    updateFinalResult : function(component,helper) {
        var selectedRecords = component.get("v.metadataNameMapList");
        selectedRecords.forEach(function(row,index5) {
            row.metadataName.forEach(function(rec,index6){ 
                var selectlist = document.getElementById(rec.artifactId);
                if(selectlist.value == 'delete')
                    rec.action = 'delete';
                else
                    rec.action = 'upsert';

            });
        });
        component.set("v.metadataNameMapList",selectedRecords);
    },

    lazyLoadHelper: function(component,helper) {
        document.getElementById("leftTable").innerHTML = "";
        document.getElementById("rightTable").innerHTML = "";
        var retRecords = component.get("v.metadataNameMapListComplete");
        retRecords.forEach(function(item,index1)
        {
            if(item.metadataType != '') {
                item.metadataName.sort(helper.compareInner);
                item.metadataName.forEach(function(field,index2){ 
                    var tableRow = document.createElement('tr');
                    tableRow.setAttribute("class", "firstSection");

                    var tableData = document.createElement('td');
                    var tableDataNode = document.createTextNode('+');
                    tableData.addEventListener("click", function(event){
                        helper.toggleRow(component, index1,index2, true,helper);
                    });
                    tableData.setAttribute("style", "width:15px;cursor:pointer;");
                    tableData.appendChild(tableDataNode);
                    tableRow.appendChild(tableData);

                    var tableData2 = document.createElement('td');
                    var tableDataNode2 = document.createTextNode(decodeURIComponent(field.name.toString()));
                    tableData2.setAttribute("class", "firstSectionDiv");
                    tableData2.setAttribute("style", "width:65%");
                    tableData2.setAttribute("class", "wrapColumn");
                    tableData2.setAttribute("title", decodeURIComponent(field.name.toString()));
                    tableData2.appendChild(tableDataNode2);
                    tableRow.appendChild(tableData2);

                    var tableData1 = document.createElement('td');
                    var tableDataNode1 = document.createTextNode(item.metadataType);
                    tableData1.setAttribute("style", "width:30%");
                    tableData1.appendChild(tableDataNode1);
                    tableRow.appendChild(tableData1);
                    document.getElementById("leftTable").appendChild(tableRow);
                });
            }
        });

        retRecords = component.get("v.metadataNameMapList");
        retRecords.forEach(function(item,index3)
        {
            if(item.metadataType != '') {
                item.metadataName.sort(helper.compareInner);
                item.metadataName.forEach(function(field,index4){ 
                    var tableRow = document.createElement('tr');
                    tableRow.setAttribute("class", "secondSection");

                    var tableData = document.createElement('td');
                    var tableDataNode = document.createTextNode('x');
                    tableData.addEventListener("click", function(event){
                        helper.toggleRow(component, index3,index4, false,helper);
                    });
                    tableData.setAttribute("style", "width:15px;cursor:pointer;");
                    tableData.appendChild(tableDataNode);
                    tableRow.appendChild(tableData);

                    var tableData2 = document.createElement('td');
                    var tableDataNode2 = document.createTextNode(decodeURIComponent(field.name.toString()));
                    tableData2.setAttribute("style", "width:50%");
                    tableData2.setAttribute("class", "secondSectionDiv wrapColumn");
                    tableData2.setAttribute("title", decodeURIComponent(field.name.toString()));
                    tableData2.appendChild(tableDataNode2);
                    tableRow.appendChild(tableData2);

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
                           
    refreshConnectHelper: function(component,Connection,helper) {
        var recordCount             = component.get("v.recordCount");
        var searchText              = component.find("searchInText").get("v.value");
        var selectedMetadata        = component.get("v.selectedMetadata");
        var action                  = component.get("c.getMetadataFunctionality");
        var recordId                = component.get("v.recordId");
        var artifactsTypeVar        = component.find("ArtifactsType");
        var selectedMetadaListJSON  = JSON.stringify(component.get("v.metadataNameMapList"));
        searchText                  = typeof searchText == 'undefined' ? '' : searchText.trim().replace(/ /g, "_");
        action.setParams({ 
            'recId'                 : recordId, 
            'selectedConnection'    : Connection,
            'recordsLimit'          : recordCount.toString(),
            'searchText'            : encodeURIComponent(searchText).replace(/\(/g, "%28").replace(/\)/g, "%29"),
            'selectedMetadataType'  : selectedMetadata,
            'selectedMetadaListJson': selectedMetadaListJSON});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {   
                var metadataOptionArray =[];
                var connectionArray = [];
                metadataOptionArray = response.getReturnValue().metadataOption;
                connectionArray = response.getReturnValue().connectionOption;
                var opts = [];
                var cons = [];
                for (var i = 0; i < metadataOptionArray.length; i++) {
                    if(metadataOptionArray[i].value == selectedMetadata)
                        opts.push({ "class": "optionClass", label: metadataOptionArray[i].label, value: metadataOptionArray[i].value, selected: "true" });
                    else
                        opts.push({ "class": "optionClass", label: metadataOptionArray[i].label, value: metadataOptionArray[i].value });
                } 
                if(Connection == null || Connection == '') {
                    for (var i = 0; i < connectionArray.length; i++) {
                        if(connectionArray[i].value == response.getReturnValue().selectedConnection)
                            cons.push({ "class": "optionClass", label: connectionArray[i].label, value: connectionArray[i].value,selected: "true" });
                        else
                            cons.push({ "class": "optionClass", label: connectionArray[i].label, value: connectionArray[i].value});
                    }
                    component.find("Connections").set("v.options", cons);
                }
                component.find("ArtifactsType").set("v.options", opts);
                component.set("v.metadataNameMapListComplete",response.getReturnValue().wrapperList);
                component.set("v.metadataNameMapList",response.getReturnValue().wrapperListSelected);
                component.set("v.storyName", response.getReturnValue().story.Name);
                component.set("v.recordCount", response.getReturnValue().recCount);
                component.set("v.isRefreshRunning", response.getReturnValue().isRefresh.Refresh_Running__c);
                component.set("v.connectionRec", response.getReturnValue().isRefresh);
                this.lazyLoadHelper(component,this);
                if(response.getReturnValue().selectedConnection == null || response.getReturnValue().selectedConnection == '' ){
                    component.set("v.isInActiveConnection", true);
                    component.set("v.message", "No active connection found for the Project of this Story, please add an active connection.");
                    component.set("v.messageType", "error");
                    component.set("v.messageTitle", "Error");
                    this.showMessage(component);
                }
                this.addHide(component);
                if(response.getReturnValue().isRefresh.Refresh_Running__c)
                    this.getConnectionRefreshStatus(component,helper);
            }                
        });
        $A.enqueueAction(action);
    },

    getConnectionRefreshStatus : function(component,helper)
    {
        var selectedConnection = component.get("v.connectionRec").Id;
        var action = component.get("c.connectionRefreshStatus");
        action.setParams({"currentConnection": selectedConnection});
        action.setCallback(this, function(response) 
        {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {   
                if(response.getReturnValue().Refresh_Running__c) {
                    component.set("v.isRefreshRunning", response.getReturnValue().Refresh_Running__c);
                    helper.getConnectionRefreshStatus(component,helper);
                }
                else {
                    component.set("v.isRefreshRunning", response.getReturnValue().Refresh_Running__c);
                    this.removeHide(component);
                    component.find("searchInText").set("v.value",'');
                    component.find("searchInText2").set("v.value",'');
                    this.refreshConnectHelper(component,selectedConnection,helper);
                }
            }
           
        });
        $A.enqueueAction(action);
    }
})