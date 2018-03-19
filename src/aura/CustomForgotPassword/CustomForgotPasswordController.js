({
    handleForgotPassword: function (component, event, helper) {
        helper.handleForgotPassword(component, event, helper);
    },
    onKeyUp: function(component, event, helper){
        if (event.getParam('keyCode')===13) {
            helper.handleForgotPassword(component, event, helper);
        }
    },
    handleCancelRedirect : function(component, event, helper)
    {
        window.location = window.location.origin + "/10kcommunity/s/login";
    }
})