({
	doInit : function (component, event, helper) { 
        console.log("Story List doInit");
        var recID = component.get("v.recID");
        helper.getAllData (component,recID);
    },
})