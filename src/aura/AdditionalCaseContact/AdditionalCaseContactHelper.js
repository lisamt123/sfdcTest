({
	showToast: function(component, event, title, message, type) 
    {
        var resultsToast = $A.get("e.force:showToast");
	  	resultsToast.setParams({
	      	"title": title,
	      	"message": message,
	      	"type": type
	  	});
	  	resultsToast.fire();
	},
})