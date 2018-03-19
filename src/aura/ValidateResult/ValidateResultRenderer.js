({
	// Your renderer method overrides go here
	afterRender : function(component, helper) {
   		this.superAfterRender();
        helper.updateDivHeight(component);
        window.onresize = function(event) {
            helper.updateDivHeight(component);
        }
    },
})