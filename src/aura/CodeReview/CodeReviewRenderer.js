({
	// Your renderer method overrides go here
	afterRender : function(component, helper){
   		this.superAfterRender();
        
        window.onresize = function(event) {
            if(document.getElementById('artifactsListContainer') != null && typeof document.getElementById('artifactsListContainer') != 'undefined')
                document.getElementById("artifactsListContainer").style.height = (document.getElementById("modal-content-id-1").offsetHeight - 40) + 'px';
            if(document.getElementById('fixHeaderDiv') != null && typeof document.getElementById('fixHeaderDiv') != 'undefined')    
                document.getElementById('fixHeaderDiv').style.width = document.getElementById('artifactsListContainer').clientWidth + 'px';
        }
    },
    rerender : function(cmp, helper) {
        this.superRerender();
        if(cmp.get('v.flag')) {
            document.getElementById("artifactsListContainer").style.height 	= (document.getElementById("modal-content-id-1").offsetHeight - 40) + 'px';
        	document.getElementById('fixHeaderDiv').style.width 			= document.getElementById('artifactsListContainer').clientWidth + 'px';
            cmp.set('v.flag',false);
        }
    }
})