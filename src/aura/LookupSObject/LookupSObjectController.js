({
    doInit : function (component, event, helper) {
        
        var value = component.get("v.value");
        console.log(value);
        var isInit = component.get("v.isInit");
        
        if(value != undefined && value != '' && value != null && isInit){
            console.log('----Alert----');
            console.log(value);
            // Update the Searchstring with the Label
            component.set("v.searchString", value);
            // Hide the Lookup List
            var lookupList = component.find("lookuplist");
            $A.util.addClass(lookupList, 'slds-hide');
            $A.util.removeClass(lookupList, 'slds-show');
            
            // Hide the Input Element
            var inputElement = component.find('lookup');
            $A.util.addClass(inputElement, 'slds-hide');
            
            // Show the Lookup pill
            var lookupPill = component.find("lookup-pill");
            $A.util.removeClass(lookupPill, 'slds-hide');
            
            // Lookup Div has selection
            var inputElement = component.find('lookup-div');
            $A.util.addClass(inputElement, 'slds-has-selection');   
            component.set("v.isInit", false);               
        }

        if(typeof value == 'undefined') {
            component.set("v.isInit", false);
        }

        //component.set("v.isInit", false);
    },
    doneRendering : function (component, event, helper) {
        doInit(component, event, helper);
        
    },
    /**
     * Search an SObject for a match
     */
    
    search : function(cmp, event, helper) {
        helper.doSearch(cmp);        
    },
    
    /**
     * Select an SObject from a list
     */
    select: function(cmp, event, helper) {
        helper.handleSelection(cmp, event);
    },
    
    /**
     * Clear the currently selected SObject
     */
    clear: function(cmp, event, helper) {
        helper.clearSelection(cmp);    
    },
    clearSelection :function(cmp, event, helper) {  
        // Clear the Searchstring
        cmp.set("v.searchString", '');
        
         // Hide the Lookup List
        var lookupList = cmp.find("lookuplist");
        $A.util.addClass(lookupList, 'slds-hide');
        $A.util.removeClass(lookupList, 'slds-show');
        
        
       
    }
})