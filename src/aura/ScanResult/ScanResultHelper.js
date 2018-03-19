({
    retriveScanLogIssues:function(component,helper) {
        helper.showSpinner(component);
        var action = component.get("c.retriveScanLogIssues");
        action.setParams({
                "logId"         : component.get("v.logId"),
                'objectName'    : component.get("v.objctAPIName"),
                'recordsLimit'  : component.get("v.recordsLimit").toString(),
                "recId"         : component.get("v.recId")
            }
        );
        action.setCallback(this,function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                var result      = response.getReturnValue();
                var jsonObject  = result;
                var message     = jsonObject.activeStatus;
                if(jsonObject.length != 0) {
                    component.set('v.reviewIssueList',response.getReturnValue());
                    component.set('v.recordsLimit',jsonObject.length);
                    helper.updateList(component,component.get('v.shortBy'),helper);
                    //this.lazyLoadHelper(component,helper);
                }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    errors.forEach( function (error) {

                        if (error.message) {
                            component.set("v.message", error.message);
                            component.set("v.messageType", "error");
                            component.set("v.messageTitle", "Error");
                            helper.showMessage(component);                    
                        }

                        if (error.pageErrors) {
                            error.pageErrors.forEach( function(pageError) {
                                component.set("v.message", pageError.message);
                                component.set("v.messageType", "error");
                                component.set("v.messageTitle", "Error");
                                helper.showMessage(component);                   
                            });                 
                        }

                        if (error.fieldErrors) {
                            for (var fieldName in error.fieldErrors) {
                                error.fieldErrors[fieldName].forEach( function (errorList) { 
                                    component.set("v.message", errorList.message + " Field Error on " + fieldName + " : ");
                                    component.set("v.messageType", "error");
                                    component.set("v.messageTitle", "Error");
                                    helper.showMessage(component);                         
                                });                                
                            };                   
                        } 
                    }); 
                }
            }
        });
        $A.enqueueAction(action);
    },
    showMessage : function(component) {
        document.getElementById("customMessage").classList.remove("slds-hide");
        setTimeout(function(){ 
            if(document.getElementById("customMessage") != null){
                document.getElementById("customMessage").classList.add("slds-hide");
            }
        }, 5000);
    },
    //used to hide lightning spinner by adding class slds-hide to lightning:spinner 
    hideSpinner: function(component) {
        console.log("addhide");
        var spinnerMain =  component.find("Spinner");
        $A.util.addClass(spinnerMain, "slds-hide");
    },
    //used to show lightning spinner by removing class slds-hide to lightning:spnner   
    showSpinner: function(component) {
        console.log("removehide");
        var spinnerMain =  component.find("Spinner");
        $A.util.removeClass(spinnerMain, "slds-hide");
    },
    lazyLoadHelper: function(component,helper) {
        document.getElementById("leftTable").innerHTML = "";
        var retRecords = component.get("v.reviewIssueList");
        var count = 0;
        retRecords.forEach(function(item,index1) {
            var tableRow = document.createElement('tr');

            var tableData = document.createElement('td');
            var tableDataNode = document.createTextNode(item.artifactType);
            tableData.setAttribute("style", "width:20%;");
            tableData.appendChild(tableDataNode);
            tableRow.appendChild(tableData);
            
            var tableData1 = document.createElement('td');
            var tableDataNode1 = document.createTextNode(item.artifactName);
            tableData1.setAttribute("style", "width:20%");
            tableData1.setAttribute("class", "wrapColumn");
            tableData1.setAttribute("title", item.artifactName);
            tableData1.appendChild(tableDataNode1);
            tableRow.appendChild(tableData1);

            var tableData2 = document.createElement('td');
            var tableDataNode2 = document.createTextNode(item.lineNo);
            tableData2.setAttribute("style", "width:10%");
            tableData2.appendChild(tableDataNode2);
            tableRow.appendChild(tableData2);

            var tableData3 = document.createElement('td');
            var tableDataNode3 = document.createTextNode(item.severity);
            tableData3.setAttribute("style", "width:10%");
            tableData3.appendChild(tableDataNode3);
            tableRow.appendChild(tableData3);

            var tableData4 = document.createElement('td');
            var description = item.violation.split('###').length > 1 ? item.violation.split('###')[1] : item.violation;
            var tableDataNode4 = document.createTextNode(decodeURIComponent(description));
            tableData4.setAttribute("style", "width:40%");
            tableData4.appendChild(tableDataNode4);
            tableRow.appendChild(tableData4);

            document.getElementById("leftTable").appendChild(tableRow);
        });
        helper.hideSpinner(component);
    },
    sortColumnHelper : function(component,event,helper) {
    	var childNodes	= event.target.childNodes;
    	var column 		= event.target.getAttribute("id");
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
        helper.updateList(component,column,helper);

    },
    updateList : function(component,column,helper) {
        var recordList = component.get('{!v.reviewIssueList}');
        recordList.sort(function(a,b) {
            var first   = !isNaN(a[column]) && !isNaN(parseInt(a[column])) ? parseInt(a[column]) : a[column].toLowerCase();
            var second  = !isNaN(b[column]) && !isNaN(parseInt(b[column])) ? parseInt(b[column]) : b[column].toLowerCase();

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
        component.set('{!v.reviewIssueList}',recordList);
        helper.lazyLoadHelper(component,helper);
    },
    updateColumnHeaders : function() {
    	var headers = document.getElementsByClassName('shortable');
    	for(var count = 0 ; count < headers.length ; count++) {
    		headers[count].innerHTML = headers[count].childNodes[0].textContent;
    	}
    }
})