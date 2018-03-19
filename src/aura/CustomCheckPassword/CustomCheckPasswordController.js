({
	handleReturnRedirect : function(component, event, helper)
    {
        window.location = window.location.origin + "/10kcommunity/s/login";
    },

    handleReturnForgot : function(component, event, helper)
    {
    	window.location = window.location.origin + "/10kcommunity/s/login/ForgotPassword";
    }
})