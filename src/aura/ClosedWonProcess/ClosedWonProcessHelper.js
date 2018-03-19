({
    doInitHelper: function(component,helper) {
    },

    getOpportunityFields : function(component) {
        var action = component.get("c.getClosedWonOpportunity");
        var recordId = component.get("v.recordId");
        action.setParams({ 'recId' : recordId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") { 
                if(response.getReturnValue().oppRec.StageName != 'Closed Won') {
                    var toastEvent1 = $A.get("e.force:showToast");
                    toastEvent1.setParams({
                        "type": "error",
                        "message": "You cannot run the Create Agreement process until the Opportunity is Closed/Won."
                    });
                    toastEvent1.fire();
                    $A.get("e.force:closeQuickAction").fire();
                } else if(response.getReturnValue().oppRec.Agreement_Generated__c) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "error",
                        "message": "The Agreement for this Opportunity has already been generated. This process can only be run once."
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                } else {
                    component.set("v.closedWonOppRec",response.getReturnValue().oppRec);
                    component.set("v.accountId",response.getReturnValue().oppRec.AccountId);
                    component.set("v.oppTypePick",response.getReturnValue().oppType);
                    component.set("v.oppLeadSourcePick",response.getReturnValue().oppLeadSource);
                    component.set("v.section1", true);
                }
            }
        });
        $A.enqueueAction(action);
    },

    getOpportunityAgreement : function(component) {
        var action = component.get("c.getClosedWonOpportunityAggreement");
        var recordId = component.get("v.recordId");
        var accountId = component.get("v.accountId");
        action.setParams({ 'recId' : recordId , 'accId' : accountId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") { 
                if(response.getReturnValue().length > 0)
                {
                   component.set("v.agreementRecList",response.getReturnValue());
                }
            }
        });
        $A.enqueueAction(action);
    },



    checkSection : function(component,event,helper) {
        /* -------------------Section 1---------------------*/
        
          var ButtonEvent = event.getSource().getLocalId();
          var firstSectionProgress= component.find("firstSection");
          var secondSectionProgress= component.find("secondSection");
          var thirdSectionProgress= component.find("thirdSection");
          var progressPercent = component.find("progressPercent");

        if(ButtonEvent == 'buttonSection1') {
            var AgreementExpirationDate = component.find("endDate");
            var AgreementExpirationDateValue = AgreementExpirationDate.get("v.value");
            
            if($A.util.isEmpty(AgreementExpirationDateValue)){
                AgreementExpirationDate.set("v.errors", [{message:"End date is required."}]);
            }
            else{
                var isValid = true;
                var effectiveDate = component.get("v.closedWonOppRec").Start_Date__c;
                var expireDate = component.get("v.closedWonOppRec").End_Date__c;
                if(expireDate <= effectiveDate) {
                    isValid = false;
                    component.set("v.message", "The End date must be greater than the Start Date.");
                    component.set("v.messageType", "error");
                    component.set("v.messageTitle", "Error");
                    helper.showMessage(component);
                }
                if(isValid) {
                    if(component.get("v.isFirstCall")) {
                        this.getOpportunityAgreement(component);
                        component.set("v.isFirstCall", false);
                    }
                    component.set("v.section2",true);
                    component.set("v.section1",false);

                    
                    $A.util.removeClass(firstSectionProgress,'slds-progress__item slds-is-active');
                    $A.util.addClass(firstSectionProgress,'slds-progress__item slds-is-completed');

                    $A.util.addClass(secondSectionProgress,'slds-progress__item slds-is-active');
                    $A.util.removeClass(progressPercent,'slds-progress-bar__value percentProgress');
                    $A.util.addClass(progressPercent,'slds-progress-bar__value percentProgressHalf');
                }
            } 
        }
        else if(ButtonEvent == 'buttonSection2') {
            this.retriveProjectAssignment(component);
             component.set("v.section2",false);
             component.set("v.section3",true);
            
              $A.util.removeClass(secondSectionProgress,'slds-progress__item slds-is-completed');
              $A.util.addClass(thirdSectionProgress,'slds-progress__item slds-is-active');
             $A.util.removeClass(progressPercent,'slds-progress-bar__value percentProgressHalf');
             $A.util.addClass(progressPercent,'slds-progress-bar__value percentProgressfull');
        }
        else if(ButtonEvent == 'backButton1') {
            component.set("v.section2",false);
            component.set("v.section1",true);
            var firstSectionProgress= component.find("firstSection");
            $A.util.removeClass(firstSectionProgress,'slds-progress__item slds-is-completed');
            $A.util.addClass(firstSectionProgress,'slds-progress__item slds-is-active');
            var secondSectionProgress= component.find("secondSection");
            $A.util.removeClass(secondSectionProgress,'slds-progress__item slds-is-active');
            $A.util.removeClass(progressPercent,'slds-progress-bar__value percentProgressHalf');
             $A.util.addClass(progressPercent,'slds-progress-bar__value percentProgress');
        }
        else if(ButtonEvent == 'backButton2') {
            component.set("v.section2",true);
             component.set("v.section3",false);
           
             $A.util.removeClass(progressPercent,'slds-progress-bar__value percentProgressfull');
             $A.util.addClass(progressPercent,'slds-progress-bar__value percentProgressHalf');
             $A.util.removeClass(thirdSectionProgress,'slds-progress__item slds-is-active');
             $A.util.removeClass(secondSectionProgress,'slds-progress__item slds-is-completed');
            $A.util.addClass(secondSectionProgress,'slds-progress__item slds-is-active');
        }
    },

    retriveProjectAssignment : function(component,event,helper) {
        var action = component.get("c.retriveProjectAssigment");
        var agreementIdList = component.get("v.AgreementIdSet");
        action.setParams({
            "recId": component.get("v.recordId"),
            "agreementIdList": agreementIdList,
            "agreementEffectiveDate" : JSON.stringify(component.get("v.closedWonOppRec").Start_Date__c),
            "agreementExpireDate" : JSON.stringify(component.get("v.closedWonOppRec").End_Date__c)
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            if(state == "SUCCESS"){
                component.set("v.agreementAssignment",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }, 

    retriveProject:function(component,event,helper,buttonId,buttonClass) {
        var action = component.get("c.retriveProject");
        action.setParams(
            {"agreement_Id": buttonId}
        );
        action.setCallback(this,function(response) {
            var state = response.getState();
            if(state == "SUCCESS"){
                var result = response.getReturnValue();
                var responseList  = result;
               if(responseList.length != 0) {
                    responseList.forEach(function(item,index)
                    {
                        var btn_clicked = document.getElementById(buttonId);
                        var tr_referred = btn_clicked.parentNode.parentNode;

                        var tableRow = document.createElement('tr');
                        tableRow.setAttribute("class", "dataRow innerRow " + buttonId);

                        var tableData = document.createElement('td');
                        tableData.setAttribute("colspan", "2");
                        tableRow.appendChild(tableData);

                        var tableData1 = document.createElement('td');
                        tableData1.setAttribute("class", "slds-cell-wrap");
                        tableData1.innerHTML = item.Project__r.Name;
                        tableRow.appendChild(tableData1);
                        var tableData2 = document.createElement('td');
                        tableData2.setAttribute("colspan", "1");
                        tableRow.appendChild(tableData2);

                        tr_referred.parentNode.insertBefore(tableRow, tr_referred.nextSibling);
                    });
                }
                else {
                        var btn_clicked = document.getElementById(buttonId);
                        var tr_referred = btn_clicked.parentNode.parentNode;

                        var tableRow = document.createElement('tr');
                        tableRow.setAttribute("class", "dataRow innerRow " + buttonId);

                        var tableData = document.createElement('td');
                        tableData.setAttribute("colspan", "2");
                        tableData.setAttribute("class", "slds-cell-wrap");
                        tableRow.appendChild(tableData);
                        
                        var tableData1 = document.createElement('td');
                        tableData1.setAttribute("class", "slds-cell-wrap");
                        tableData1.innerHTML =  "No Project";
                        tableRow.appendChild(tableData1); 

                        var tableData2 = document.createElement('td');
                        tableData2.setAttribute("colspan", "1");
                        tableRow.appendChild(tableData2);
                        tr_referred.parentNode.insertBefore(tableRow, tr_referred.nextSibling);                   
                }
            }
        });
        $A.enqueueAction(action);
    },

    convertOpportunityProducts : function(component, event, helper) {
        var action = component.get("c.createNewAgreementAndRates");
        var agreementIdList = [];
        action.setParams({ 
            'recId' : component.get("v.recordId"),
            "agreementEffectiveDate" : JSON.stringify(component.get("v.closedWonOppRec").Start_Date__c),
            "agreementExpirationDate" : JSON.stringify(component.get("v.closedWonOppRec").End_Date__c),
            "agreementIdList" : agreementIdList,
            "oppRec" : component.get("v.closedWonOppRec")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") { 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "message": response.getReturnValue()
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
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

    saveWithReplacementHelper : function(component, event, helper) {

        var action = component.get("c.replaceAgreementsAndAssignments");
        action.setParams({ 
            'recId' : component.get("v.recordId"),
            "agreementEffectiveDate" : JSON.stringify(component.get("v.closedWonOppRec").Start_Date__c),
            "agreementExpirationDate" : JSON.stringify(component.get("v.closedWonOppRec").End_Date__c),
            "agreementIdList" : component.get("v.AgreementIdSet"),
            "wrapperListJSON" : JSON.stringify(component.get("v.agreementAssignment")),
            "oppRec" : component.get("v.closedWonOppRec")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") { 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "message": response.getReturnValue()
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
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
})