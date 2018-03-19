({
   afterRender : function(component, helper){
   		this.superAfterRender();
        var scroll = document.getElementById('outerDiv');
        var content = document.getElementById('innerDiv');
        var headerDiv = document.getElementById('fixHeaderDiv');
        
        scroll.onscroll = function(ev)
        {
        	console.log('Scrolling..');
            var total = scroll.scrollTop + scroll.clientHeight;
            if(total == content.clientHeight)
            {
            	console.log('Calling..');
            	var recID = 'renderer';
                var recLimit = component.get("v.StoriesList").length;
                helper.getAllData(component,recID,recLimit);
            } 
        }
        window.onresize = function(event) 
        {
            headerDiv.style.width = content.clientWidth+'px';
        }
    },
    rerender : function(cmp, helper)
    {
        this.superRerender();
        var content = document.getElementById('innerDiv');
        var headerDiv = document.getElementById('fixHeaderDiv');
        headerDiv.style.width = content.clientWidth+'px';
    }
})