({
	update : function(component, event, helper) {
    	var tymEntry = component.get("v.tymEntryList");
        var updateEvent = component.getEvent("updateTime");
        var day = component.get("v.Day");
        var ass = component.get("v.assignment") ;
        var proj = component.get("v.clickedProject");
        var isStoryReq = component.get("v.isStoryRequired");
        var clickedProjectName = component.get("v.clickedProjectName");
        updateEvent.setParams({ "timeEntry": tymEntry ,"selectedDay" :day ,"selectedAssig" :ass ,"selectedProject" :proj ,"isStoryRequired" :isStoryReq,"clickedProjectName" :clickedProjectName}).fire();
	}    
})