({
    doSearch: function(cmp) {
        var searchString = cmp.get('v.searchString');
        var inputElement = cmp.find('lookup');
        var lookupList = cmp.find('lookuplist');
        inputElement.set('v.errors', null);
        if (typeof searchString === 'undefined' || searchString.length < 2) {
            $A.util.addClass(lookupList, 'slds-hide');
            $A.util.removeClass(lookupList, 'slds-show');
            return;
        }
        $A.util.removeClass(lookupList, 'slds-hide');
        $A.util.addClass(lookupList, 'slds-show');
        cmp.set("v.searchEmpty",true);
        var sObjectAPIName = cmp.get('v.sObjectAPIName');
        var relatedSObjectFieldName = cmp.get('v.relatedSObjectFieldName');
        var sObjectRelatedId = cmp.get('v.sObjectRelatedId');
        var action = cmp.get('c.lookup');
        action.setAbortable();
        action.setParams({
            "searchString": searchString,
            "sObjectAPIName": sObjectAPIName,
            "relatedSObjectFieldName": relatedSObjectFieldName,
            "sObjectRelatedId": sObjectRelatedId

        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                var matches = response.getReturnValue();
                if (matches.length == 0) {
                    cmp.set('v.matches', null);
                    return;
                }
                cmp.set('v.matches', matches);
            } else if (state === "ERROR")
            {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.displayToast('Error', errors[0].message);
                    }
                } else {
                    this.displayToast('Error', 'Unknown error.');
                }
            }
        });
        $A.enqueueAction(action);
    },

    handleSelection: function(cmp, event) {
        var objectId = this.resolveId(event.currentTarget.id);
        var objectLabel = event.currentTarget.innerText;
        cmp.set('v.Value',objectId);
        cmp.set("v.searchString", objectLabel);
        var lookupList = cmp.find("lookuplist");
        $A.util.addClass(lookupList, 'slds-hide');
        $A.util.removeClass(lookupList, 'slds-show');
        var inputElement = cmp.find('lookup');
        $A.util.addClass(inputElement, 'slds-hide');
        $A.util.removeClass(inputElement, 'slds-show');
        var lookupPill = cmp.find("lookup-pill");
        $A.util.removeClass(lookupPill, 'slds-hide');
        $A.util.addClass(lookupPill, 'slds-show');
        var inputElement = cmp.find('lookup-div');
        $A.util.addClass(inputElement, 'slds-has-selection');

    },
    clearSelection: function(cmp) {
        cmp.set("v.searchString", '');
        cmp.set("v.Value",'');
        var lookupPill = cmp.find("lookup-pill");
        $A.util.addClass(lookupPill, 'slds-hide');
        $A.util.removeClass(lookupPill, 'slds-show');
        var inputElement = cmp.find('lookup');
        $A.util.removeClass(inputElement, 'slds-hide');
        $A.util.addClass(inputElement, 'slds-show');
        var inputElement = cmp.find('lookup-div');
        $A.util.removeClass(inputElement, 'slds-has-selection');
    },
    resolveId: function(elmId) {
        var i = elmId.lastIndexOf('_');
        return elmId.substr(i + 1);
    },
    displayToast: function(title, message) {
        var toast = $A.get("e.force:showToast");
        if (toast) {
            toast.setParams({
                "title": title,
                "message": message
            });
            toast.fire();
        } else {
            alert(title + ': ' + message);
        }
    },
    initialSelection : function(cmp, event, helper)
    {
        var inputElement = cmp.find('lookup');
        var lookupList = cmp.find('lookuplist');
        cmp.set("v.searchEmpty",false);
        var sObjectAPIName = cmp.get('v.sObjectAPIName');
        var action = cmp.get('c.initialData');
        var relatedSObjectFieldName = cmp.get('v.relatedSObjectFieldName');
        var sObjectRelatedId = cmp.get('v.sObjectRelatedId');
        action.setParams({
            "sObjectAPIName": sObjectAPIName,
            "relatedSObjectFieldName": relatedSObjectFieldName,
            "sObjectRelatedId": sObjectRelatedId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS"){
                var matches = response.getReturnValue();
                if (matches.length == 0) {
                    cmp.set('v.matches', null);
                    return;
                }
                cmp.set('v.matches', matches);
            } else if (state === "ERROR")
            {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.displayToast('Error', errors[0].message);
                    }
                } else {
                    this.displayToast('Error', 'Unknown error.');
                }
            }
            });
            $A.enqueueAction(action);
            $A.util.removeClass(lookupList, 'slds-hide');
            $A.util.addClass(lookupList, 'slds-show');
    },
    onInputBlur: function (component,e,helper) {
        helper.fadeOut(component,helper);
    },
    fadeOut: function(component, helper) {
        window.setTimeout(
            $A.getCallback(function() {
                if (component.isValid()) 
                {
                    $A.util.removeClass(component.find("lookup-pill"),'focus');
                    $A.util.addClass(component.find("lookuplist"), 'slds-hide');
                    $A.util.removeClass(component.find("lookuplist"), 'slds-show'); 
                }
            }), 250
        )
    }
})