({
    	
    jsLoaded : function (component, event, helper){        
    }, 
    doInit : function (component, event, helper){
        helper.getInitData(component);  
    },
    doneRendering : function(component, event, helper){
        
    },
    mouseOver : function(component, event, helper){
        
    },
    onToday : function(component, event, helper){
    	helper.getInitData(component);
        var refreshEvent = component.find("cmp");
 		refreshEvent.refreshData();
    },
    setOutput : function(component, event, helper){
        component.set("v.selDate", component.find("date").get("v.value")); //set Selected Date
        var DayDate = new Date(component.find("date").get("v.value"));
        var day = DayDate.getDay(); 
        var i = ( (day == 0) ? 0 :  (day == 1) ? 6 : (day == 2) ? 5 : (day == 3) ? 4 : (day == 4) ? 3 : (day == 5) ? 2 : 1);
        DayDate.setDate(DayDate.getDate() + i);
        component.find("date").set("v.value", DayDate.getFullYear() + "/" + (DayDate.getMonth() + 1) + "/"
                      + (DayDate.getDate()) ) ;
        
        //call child method
        var refreshEvent = component.find("cmp");
 		refreshEvent.refreshData();
    },
    moveNext : function (component, event, helper){ 
        var DayDate = new Date(component.get("v.selDate"));
        if(DayDate == 'Invalid Date'){
            DayDate = new Date();
        }
        DayDate = new Date(DayDate.getFullYear(),  (DayDate.getMonth()), (DayDate.getDate() + 7)) ;//Date +7 days
        component.set("v.selDate", String(DayDate)); //set Date 
        var day = DayDate.getDay(); 
        var i = ( (day == 0) ? 7 :  (day == 1) ? 6 : (day == 2) ? 5 : (day == 3) ? 4 : (day == 4) ? 3 : (day == 5) ? 2 : 1);
        DayDate.setDate(DayDate.getDate() + i);
        component.find("date").set("v.value", DayDate.getFullYear() + "/" + (DayDate.getMonth() + 1) + "/"
                      + (DayDate.getDate()) ) ;
        
        //call chid method
        var refreshEvent = component.find("cmp");
 		refreshEvent.refreshData(); 
    },
    movePrev :function (component, event, helper){
        var DayDate = new Date(component.get("v.selDate"));
        if(DayDate == 'Invalid Date'){
            DayDate = new Date();
        }
        DayDate = new Date(DayDate.getFullYear(),  (DayDate.getMonth() ), (DayDate.getDate() - 7)) ;//Date -7 days
        component.set("v.selDate", String(DayDate)); //set date 
        var day = DayDate.getDay(); 
        var i = ( (day == 0) ? 7 :  (day == 1) ? 6 : (day == 2) ? 5 : (day == 3) ? 4 : (day == 4) ? 3 : (day == 5) ? 2 : 1);
        DayDate.setDate(DayDate.getDate() + i);
        component.find("date").set("v.value", DayDate.getFullYear() + "/" + (DayDate.getMonth() + 1) + "/"
                      + (DayDate.getDate() ) ) ;
        //call chid method
        var refreshEvent = component.find("cmp");
 		refreshEvent.refreshData(); 
    }
})