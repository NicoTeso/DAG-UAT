({
    handleForgotPassword: function (component, event, helper) {
        
        console.log('Inside handleForgotPassword');
        var username = component.find("username").get("v.value");
        if (component.find("username").get("v.validity").valid){
            var checkEmailUrl = component.get("v.checkEmailUrl");
            var wrongEmailUrlC = component.get("v.wrongEmailUrl");
            var action = component.get("c.forgotPasswordSend");
            action.setParams({userEmail:username, checkEmailUrl:checkEmailUrl, wrongEmailUrl:wrongEmailUrlC});
            action.setCallback(this, function(a) {
                 
                var rtnValue = a.getReturnValue();
                console.log('Response');
                var urlEvent = $A.get("e.force:navigateToURL");
                if(rtnValue == 'done'){ 
                    urlEvent.setParams({
                      "url": checkEmailUrl
                    });
                    
                }else{
                    urlEvent.setParams({
                      "url": wrongEmailUrlC
                    });
                }
                urlEvent.fire();
                console.log(rtnValue);
           });
           $A.enqueueAction(action);
        }else{
            console.log("Email not valid");
            component.set("v.loading", false);
        }
       

    }
})