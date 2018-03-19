({
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
	}
    
})