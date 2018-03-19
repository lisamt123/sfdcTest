({
	doInit : function(component, event, helper) 
	{
		helper.orderHistory(component,event,helper);
	},
	handlesingleOrder : function(component, event, helper)
	{
		var orderId = event.target.getAttribute("data-index");
		var orderName = event.target.getAttribute("data-name");
		console.log('Order Id : '+ orderId);
		$A.createComponent(
	        "c:OrderDetail",
	        {
	            "OrderId": orderId,
	            "OrderName": orderName
	        },
	        function(newItem, status, errorMessage){
	            if (status === "SUCCESS") {
	            	var targetCmp = component.find('ModalDialogOrder');
	                var body = targetCmp.get("v.body");
	                body.push(newItem);
	                targetCmp.set("v.body", body);
	            }
	            else if (status === "INCOMPLETE") {
	                console.log("No response from server or client is offline.")
	            }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
	            }
	        }
	    );
	},
	showLoading: function (cmp, event) {
        var spinner = cmp.find("Spinner");
        $A.util.removeClass(spinner, "slds-hide");
        $A.util.addClass(spinner, "slds-show");
    },
    hideLoading: function (cmp, event) {
        var spinner = cmp.find("Spinner");
        $A.util.addClass(spinner, "slds-hide");
        $A.util.removeClass(spinner, "slds-show");
    }
})