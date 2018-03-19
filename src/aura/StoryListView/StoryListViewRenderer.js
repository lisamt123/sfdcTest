({
	afterRender : function(component, helper){
   		this.superAfterRender();
        //this.superRerender();
        // do custom rerendering here
        var scroll = document.getElementById('outerDiv');
        var content = document.getElementById('innerDiv');
        scroll.onscroll = function(ev)
        {
        	console.log('Scrolling..');
            var total = scroll.scrollTop + scroll.clientHeight;
            if(total == content.clientHeight)
            {
            	console.log('Calling..');
            	var recID = component.get("v.recID");
                helper.getAllData(component,recID);
            } 
        }
    }
})