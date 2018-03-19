({
	doInit : function(component, event, helper)
	{
		helper.retrivePriceBook(component, event, helper);
	},
	saveWithProducts : function(component, event, helper) {
		helper.validateData(component, event, helper);
	},
	defaultCloseAction : function(component, event, helper)
	{
		component.destroy();
	},
	changeValue : function(component, event, helper)
	{
		var priceBookEntriesListJS = component.get("v.PriceBookEntriesList");
		for(var i = 0; i < priceBookEntriesListJS.length; i++) {
			if(i == event.getSource().get("v.name")) {
				if(event.getSource().get("v.value"))
					priceBookEntriesListJS[i].Product2.IsActive = false;
				else
					priceBookEntriesListJS[i].Product2.IsActive = true;
			}
		}
		component.set("v.PriceBookEntriesList", priceBookEntriesListJS);
	},
})