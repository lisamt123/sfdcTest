({
    
    qsToEventMap: {
        'startURL'  : 'e.c:setStartUrl'
    },

    handleLogin: function (component, event, helpler) {
        var username = component.find("username").get("v.value");
        var password = component.find("password").get("v.value");
        var action = component.get("c.login");
        var startUrl = component.get("v.startUrl");
        
        startUrl = decodeURIComponent(startUrl);
        
        action.setParams({username:username, password:password, startUrl:startUrl});
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set("v.errorMessage",rtnValue);
                component.set("v.showError",true);
            }
        });
        $A.enqueueAction(action);
    },
    
    getIsUsernamePasswordEnabled : function (component, event, helpler) {
        var action = component.get("c.getIsUsernamePasswordEnabled");
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.isUsernamePasswordEnabled',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getIsSelfRegistrationEnabled : function (component, event, helpler) {
        var action = component.get("c.getIsSelfRegistrationEnabled");
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.isSelfRegistrationEnabled',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getCommunityForgotPasswordUrl : function (component, event, helpler) {
        var action = component.get("c.getForgotPasswordUrl");
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.communityForgotPasswordUrl',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getCommunitySelfRegisterUrl : function (component, event, helpler) {
        var action = component.get("c.getSelfRegistrationUrl");
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.communitySelfRegisterUrl',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },

    getMyCustomData : function (component, event, helpler) {
        var action = component.get("c.getMyCustomData");
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                console.log(rtnValue);
                var ProductionId = $A.get("$Label.c.Production_Org_Id");
                var baseURL = rtnValue.split("===")[0];
                var orgId = rtnValue.split("===")[2].substring(0, 15);
                if(orgId == ProductionId)
                {
                    component.set("v.isProduction", true);
                    var productionbaseURL = baseURL.replace("force","my.salesforce");
                    productionbaseURL += ("//servlet/networks/session/create?site="+$A.get("$Label.c.Site_Id")+"&refURL="+baseURL+"%2F10kcommunity%2Flogin&inst=36");
                    component.set("v.productionbaseURL", productionbaseURL);
                }
                else
                {
                    var sandboxbaseURL = "https://10k--"+baseURL.split("-")[0].replace("https://", "")+baseURL.split("-")[1].replace("10k","").replace("force","my.salesforce");
                    sandboxbaseURL += ("//servlet/networks/session/create?site="+$A.get("$Label.c.Site_Id")+"&refURL="+baseURL+"%2F10kcommunity%2Flogin&inst=2C");
                    component.set("v.sandboxbaseURL", sandboxbaseURL);
                }
                component.set("v.baseURL", baseURL);
                component.set("v.orgId", rtnValue.split("===")[2]);
            }
        });
        $A.enqueueAction(action);
    },
})