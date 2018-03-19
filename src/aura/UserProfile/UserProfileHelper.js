({
	readFile: function(component,file, helper) 
  	{
      
        
        var binary = "";
        var reader = new FileReader();
        reader.file = file;
        reader.onload = function(e)
        {
            var bytes = new Uint8Array(e.target.result);
            var length = bytes.byteLength;
            for (var i = 0; i < length; i++)
            {
                binary += String.fromCharCode(bytes[i]);
            }
            console.log('binary');
            helper.upload(component,btoa(binary),helper);
            
        }
        reader.readAsArrayBuffer(file);
        
    },
   	upload: function(component, base64Data,helper) 
   	{
        //var SelectRecord = component.find("SelectRecord").get("v.value");
        console.log('binary2');
        var action = component.get("c.saveProfilePicture");
        action.setParams({
            "fileContent": base64Data,
            "profileUserId": window.location.pathname.split('/profile/')[1]
        });
        
        action.setCallback(this, function(a) {
            component.set("v.userDetails",a.getReturnValue());
            $A.util.removeClass(component.find("modelshow"),'slds-fade-in-open');
        	$A.util.removeClass(component.find("bgfade"),'slds-backdrop--open');
        });
        //$A.run(function() {
            $A.enqueueAction(action); 
        //});
    }
        
})