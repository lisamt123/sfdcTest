({
	// Your renderer method overrides go here
	afterRender : function(component, helper){
   		this.superAfterRender();
        
        window.onresize = function(event) {
            if(document.getElementById("modal-content-id-1") != null && typeof document.getElementById("modal-content-id-1") != 'undefined')
                helper.updateDivHeight(component);
        }
    },
    rerender : function(component, helper) {
        this.superRerender();
        if(component.get('v.flag')) {
            setTimeout(function(){ 
                helper.updateDivHeight(component);
            }, 100);
            component.set('v.flag',false);
        }
    }
})