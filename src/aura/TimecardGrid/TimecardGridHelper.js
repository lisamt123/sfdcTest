({ 
    getInitData : function(component){
        var today = new Date();//today date
        var day = today.getDay(); 
        var i = ( (day == 0) ? 0 :  (day == 1) ? 6 : (day == 2) ? 5 : (day == 3) ? 4 : (day == 4) ? 3 : (day == 5) ? 2 : 1);
        component.set('v.toDayDate', today.getFullYear() + "-" + (today.getMonth() + 1) + "-"
                      + today.getDate());
        component.set("v.selDate", component.get("v.toDayDate")); 
        
        today.setDate(today.getDate() + i);
        component.find("date").set("v.value", today.getFullYear() + "/" + (today.getMonth() + 1) + "/"
                      + (today.getDate()) ) ;
    },                         
    
})