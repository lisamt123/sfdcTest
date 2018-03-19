({
	getAllData : function(component,recID) 
	{
        console.log('recID : '+recID);
        this.showSpinner(component);
        var allStoriesList = component.get("v.StoriesList");
        //var tempStoriesList = component.get("v.tempStoriesList");

        var action = component.get("c.getAllStories");
        action.setParams({ 
        	'recordID' : recID
            });
        action.setCallback(this, function(response) 
        {
            var state = response.getState();
            console.log('Response received');
            if (component.isValid() && state === "SUCCESS") 
            {           
                console.log("GetAllStories is success");
                component.set("v.tempStoriesList", response.getReturnValue());
                //$("#totItems").html(response.getReturnValue().length" items");
                this.hideSpinner(component);
                this.recursionCall(component);
            }
        });
        $A.enqueueAction(action);
        
        /*if(allStoriesList.length <= 0)
        {
	        var action3 = component.get("c.getCurrUserId");
	        action3.setCallback(this, function(response) 
	        {
	            var state = response.getState();
	            if (component.isValid() && state === "SUCCESS") 
	            {
	                component.set("v.CurrUserId", response.getReturnValue());
	                console.log("Current User is success");
	            }
	        });
	        $A.enqueueAction(action3);

	        var action4 = component.get("c.getStatusPickList");
        	action4.setCallback(this, function(response) 
        	{
            	var state = response.getState();
	            if (component.isValid() && state === "SUCCESS") 
	            {
	                component.set("v.StatusList", response.getReturnValue());
	                console.log("Status list success");                
	            }
	        });
	        $A.enqueueAction(action4); 
	    }*/
    },

    showSpinner : function(component)
    {
        var myCmp = component.find("Spinner");
        $A.util.removeClass(myCmp, "hide");
    },

    hideSpinner : function(component)
    {
        var myCmp = component.find("Spinner");
        $A.util.addClass(myCmp, "hide");
    },

    recursionCall : function(component) 
    {
        console.log('recursion function called');
        var storiesList = component.get("v.tempStoriesList");
        var lastRecId = storiesList[storiesList.length - 1]['Id'];
        console.log('Last RecID : '+lastRecId );
        var allStoriesList = component.get("v.StoriesList");
        var updatedList = []
        if(allStoriesList.length > 0)
        {
            for(var i = 0; i < allStoriesList.length; i++)
            {
                updatedList.push(component.get("v.StoriesList")[i]);
            }
            for(var i = 0; i < storiesList.length; i++)
            {
                updatedList.push(component.get("v.tempStoriesList")[i]);
            }
            setTimeout(function()
            { 
                component.set("v.StoriesList",updatedList);
                component.set("v.recID",lastRecId); 
            },  3000);
        }
        else
        {
            for(var i = 0; i < storiesList.length; i++)
            {
                updatedList.push(component.get("v.tempStoriesList")[i]);
            }
            setTimeout(function()
            { 
                component.set("v.StoriesList",updatedList);
                component.set("v.recID",lastRecId); 
            },  3000);
        }
        //this.fillProjectSelList(component);
        var recID = component.get("v.recID");
        console.log(recID+'lastRecId');
    },
})