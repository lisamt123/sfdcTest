({
	showTost : function(component, notifyid, err, isSetTime, type){
        component.set("v.ErrorMessge", err); 
        
            if($('#'+notifyid).hasClass('slds-theme--success'))
                $('#'+notifyid).removeClass('slds-theme--success');
            $('#'+notifyid).addClass('slds-theme--error');
        
        $('#'+notifyid).show();
        if(isSetTime)
        	setTimeout(function(){ $('#'+notifyid).hide(); }, 5000);//show for 5 sec
    },
})