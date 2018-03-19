({
	
    eventfire : function (component,event,helper){
        var index = component.get("v.index")
        console.log('change:',index);
        var AddRow = $A.get("e.c:AddRow");
        AddRow.setParams({
           "incrementRow": index
        });
        AddRow.fire();
    },
    pickAllocationChange : function (component,event,helper)
    {
        var pickAllocation = component.find('pickAllocation');
        var hoursInput = component.find("hoursInput");
        var br1 = component.find("br1");
        var br2 = component.find("br2");
        if(pickAllocation.get("v.value") == "")
        {
            $A.util.removeClass(hoursInput, 'hoursInput');
            $A.util.addClass(hoursInput, 'hoursInputShow');
            $A.util.addClass(br1, 'hoursInputShow');
            $A.util.addClass(br2, 'hoursInputShow');
            $A.util.removeClass(br1, 'hoursInput');
            $A.util.removeClass(br2, 'hoursInput');
        }
        else
        {
            $A.util.addClass(hoursInput, 'hoursInput');
            $A.util.removeClass(hoursInput, 'hoursInputShow');
            $A.util.addClass(br1, 'hoursInput');
            $A.util.addClass(br2, 'hoursInput');
            $A.util.removeClass(br1, 'hoursInputShow');
            $A.util.removeClass(br2, 'hoursInputShow');
        }
        console.log(pickAllocation.get("v.value"));
    }
})