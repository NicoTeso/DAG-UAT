({
    
    qsToEventMap: {
        'startURL'  : 'e.c:setStartUrl'
    },

    qsToEventMap2: {
        'expid'  : 'e.c:setExpId'
    },
    
    handleLogin: function (component, event, helpler) {
        const logger = component.find('logger');
        try{
            var username = component.get("v.username");
            var password = component.get("v.password");
            var action = component.get("c.login");
            var startUrl = component.get("v.startUrl");
            component.set("v.showError",false);
            
            startUrl = decodeURIComponent(startUrl);
            
            action.setParams({username:username, password:password, startUrl:startUrl});
            action.setCallback(this, function(a){
                var rtnValue = a.getReturnValue();
                if (rtnValue !== null) {
                    if(rtnValue == 'false'){
                        component.set("v.screen", '2');
                    } else {
                        component.set("v.errorMessage",rtnValue);
                        component.set("v.showError",true);
                    }
                }
            });
            $A.enqueueAction(action);
        } catch(e){
            console.error(e);
            logger.error(e.message);
            logger.saveLog();
        }
    },

    handleNext: function (component, event, helper) {
        const logger = component.find('logger');
        try{
            if(component.get("v.centralizarChecked") == true){
                var username = component.get("v.username");
                var action = component.get("c.updateUser");
                action.setParams({username:username});
                action.setCallback(this, function(a){
                    var rtnValue = a.getReturnValue();
                    if (rtnValue !== null) {
                        component.set("v.errorMessage",rtnValue);
                        component.set("v.showError",true);
                    } else {
                        this.handleLogin(component, event, helper);
                    }
                });
                $A.enqueueAction(action);
            } else {
                component.set("v.screen", '3');
            }
        } catch(e){
            console.error(e);
            logger.error(e.message);
            logger.saveLog();
        }
    },

    handleInicioButton: function (component, event, helper) {
        var url = component.get("v.loginURL");
        window.location.href = url;
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

    setBrandingCookie: function (component, event, helpler) {
        var expId = component.get("v.expid");
        if (expId) {
            var action = component.get("c.setExperienceId");
            action.setParams({expId:expId});
            action.setCallback(this, function(a){ });
            $A.enqueueAction(action);
        }
    }
})