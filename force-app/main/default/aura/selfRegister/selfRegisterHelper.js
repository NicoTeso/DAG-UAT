({
    qsToEventMap: {
        'startURL'  : 'e.c:setStartUrl'
    },
    
    qsToEventMap2: {
        'expid'  : 'e.c:setExpId'
    },

    handleCheckDnibyAccount: function (component, event, helpler) {
        const logger = component.find('logger');
        try{
            var dni = component.get("v.dni");
            //var regConfirmUrl = component.get("v.regConfirmUrl");
            var action = component.get("c.checkDnibyAccount");

            action.setParams({dni:dni});
            action.setCallback(this, function(a){
                var rtnValue = a.getReturnValue();
                if (rtnValue !== null) {
                    component.set("v.errorMessage",rtnValue);
                    component.set("v.showError",true);
                } else {
                    this.handleGetAccountName(component, dni);
                    component.set("v.showError",false);
                    this.checkOppositionRecord(component);
                    //component.set("v.screen", '2');
                }
            });
            $A.enqueueAction(action);
        } catch(e){
            console.error(e);
            logger.error(e.message);
            logger.saveLog();
        }
    },

    handleSelfRegister: function (component, event, helpler) {
        const logger = component.find('logger');
        try{
            var dni = component.get("v.dni");
            var password = component.get("v.password");
            var confirmPassword = component.get("v.confirmPassword");
            //var regConfirmUrl = component.get("v.regConfirmUrl");
            var action = component.get("c.selfRegister");
            var startUrl = component.get("v.startUrl");
            
            startUrl = decodeURIComponent(startUrl);

            action.setParams({dni:dni, password:password, confirmPassword:confirmPassword, startUrl:startUrl}); //, regConfirmUrl:regConfirmUrl});
            action.setCallback(this, function(a){
                var rtnValue = a.getReturnValue();
                if (rtnValue !== null) {
                    component.set("v.errorMessage",rtnValue);
                    component.set("v.showError",true);
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
        var currentScreen = component.get("v.screen");
        if (currentScreen === '1') {
            var dni = component.get("v.dni");
            if (dni || dni.trim() !== '') {
                component.set("v.screen", '2');
            }
        }
    },

    handleNextToScreen3: function (component, event, helper) {
        var currentScreen = component.get("v.screen");
        var currentToggleChecked = component.get("v.toggleChecked");
        if (currentScreen === '2') {
            if(currentToggleChecked){
                component.set("v.screen", '3');
            } else {
                component.set("v.screen", '5');
            }
        }
    },

    handleNextToScreen4: function (component, event, helper) {
        var currentScreen = component.get("v.screen");
        if (currentScreen === '3') {
            component.set("v.screen", '4');
        }
    },

    handleNextFromScreen5: function (component, event, helper) {
        if(component.get("v.centralizarChecked") == true){
            component.set("v.screen", '2');
        } else if(component.get("v.oppositionChecked") == true){
            component.set("v.screen", '6');
            component.set("v.showAlreadyRegisteredLabel", false);
        }
    },

    handleInicioButton: function (component, event, helper) {
        var url = component.get("v.loginURL");
        window.location.href = url;
    },

    handleGetAccountName: function (component, dni) {
        var action = component.get("c.getAccountName");
        action.setParams({dni:dni});
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set("v.accountName", rtnValue);
            }
        });
    $A.enqueueAction(action);
    },

    changeCentralizarCheck : function(component,event,helper) {
        const logger = component.find('logger');
        try{
            component.set("v.buttonDisabled",true);
            if(component.get("v.centralizarChecked") == true){
                component.set("v.toggleChecked", true);
                component.set("v.oppositionChecked", false);
            }
        } catch(e){
            console.error(e);
            logger.error(e.message);
            logger.saveLog();
        }
    },

    changeOppositionCheck : function (component, event, helper) {
        const logger = component.find('logger');
        try{
            component.set("v.buttonDisabled", true);
            if(component.get("v.oppositionChecked") == true){
                component.set("v.toggleChecked", false);
                component.set("v.centralizarChecked", false);
            }
        } catch(e){
            console.error(e);
            logger.error(e.message);
            logger.saveLog();
        }
    },

    checkOppositionRecord: function(component) {
        const logger = component.find('logger');
        try{
            var action = component.get("c.checkOppositionRecord");
            action.setParams({ dni : component.get("v.dni")});
            action.setCallback(this, function (response) {
                if (response.getState() === 'SUCCESS') {
                    var responseId = response.getReturnValue();
                    if(responseId == '2'){
                        component.set("v.output","");
                        component.set("v.screen",'3');
                    } else {
                        component.set("v.output","");
                        component.set("v.screen",'2');
                    }
                } else {
                    component.set("v.output",$A.get("$Label.c.register_ProblemRecoveringConsent"));
                }
            });
            $A.enqueueAction(action);
        } catch(e){
            console.error(e);
            logger.error(e.message);
            logger.saveLog();
        }
    }

})