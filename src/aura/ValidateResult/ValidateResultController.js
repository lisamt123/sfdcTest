({
	cancelClick : function(component, event, helper) {
        component.destroy();
    },
    expandSection : function(component, event, helper) {
        var dir = event.getSource().get("v.label");
        if(dir == 'Hide')
        	component.set("v.expand",false);
        else
        	component.set("v.expand",true);
    },
})