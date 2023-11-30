/**
 * @description  : 
 * @author       : development@nubika.com 
**/
({

        
    doInit: function(cmp) {
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s"));
        var politicaPriv = baseURL + '/s/politica-de-privacidad';
        var avisoLegal = baseURL + '/s/aviso-legal';
        var cerrarUrl = baseURL + '/s/login';
        var loginURL = baseURL + '/s/';                            
        cmp.set("v.pPrivacidadURL", encodeURI(politicaPriv));
        cmp.set("v.avisoLegal", encodeURI(avisoLegal));
        cmp.set("v.loginURL", encodeURI(loginURL));
        cmp.set("v.cerrarUrl", encodeURI(cerrarUrl));
    },

    checkNifAccount : function(component, event, helper) {  
        const logger = component.find('logger');
        try{
            var nifValue = component.find("Account").get("v.value");

            if(nifValue){
                component.set("v.showNIFError", false);
                var action = component.get("c.checkNifbyAccount");         	
                action.setParams({ Acc : component.get("v.accountNIF")});
                action.setCallback(this, function (response) {

                    try{
                        if (response.getState() === 'SUCCESS') {                                      
                            const result = response.getReturnValue();
                            const responseParsed = JSON.parse(result);
                            const responseId = responseParsed.dataJSON;
                            if(responseId === 'accountNotFound'){
                                component.set("v.output",$A.get("$Label.c.register_ClientNotVerified"));
                            }else if(responseId === 'noClientePropio'){
                                component.set("v.screen",'6'); 
                            }else if(responseId === 'userFound'){
                                component.set("v.output",$A.get("$Label.c.register_useralreadyExists"));
                            }else if(responseId === 'error'){
                                component.set("v.output",$A.get("$Label.c.register_ContactMailUnregistered"));
                            }else if(responseId !== 'accountNotFound' && responseId !== 'userFoundAndResetPassword' && responseId !== 'error'){
                                //personAccountId              
                                component.set("v.contactId",responseId);
                                helper.checkOppositionRecord(component);
                            }
                        } else {
                            component.set("v.output",$A.get("$Label.c.register_ContactMailUnregistered"));                                       
                        }
                    }catch(e){
                        console.error(e);
                        logger.error(e.message);
                        logger.saveLog();
                    }
                });
                $A.enqueueAction(action);      
            }else{
                console.log('CreateUserComponentController - checkNifAccount - Else');
                component.set("v.showNIFError", true);
            }
        }catch(e){
            logger.error(e.message);
            logger.saveLog();
        }
    },


    registerUserHandler: function(component,event,helper) {
        const logger = component.find('logger');
        try{
            var action = component.get("c.registerUser");
            component.set("v.accepted",true);
            action.setParams({ NIF : component.get("v.accountNIF")});
            action.setCallback(this, function (response) {
                try{
                    const returnValue = response.getReturnValue();
                    const parsedData = JSON.parse(returnValue);
                    if (parsedData.success) {    
                        component.set("v.screen",'4');
                        component.set('v.userName',parsedData.FirstName);
                    } else {
                        component.set("v.output",parsedData.errorMsg);
                    }
                }catch(e){
                    console.error(e);
                    logger.error(e.message);
                    logger.saveLog();
                }
            });
            $A.enqueueAction(action);
        }catch(e){
            console.error(e);
            logger.error(e.message);
            logger.saveLog();
        }
    },

	changeCentralizarCheck : function(component,event,helper) {
        const logger = component.find('logger');
        try{
            component.set("v.buttonDisabled",true);
            if(component.get("v.centralizarChecked") == true){
                component.set("v.oppositionChecked",false);
                component.set("v.toggleChecked",true);
            }else{
                if(component.get("v.oppositionChecked")== false){
                    component.set("v.buttonDisabled",false);
                }
                component.set("v.toggleChecked",false);	      
            }
        }catch(e){
            console.error(e);
            logger.error(e.message);
            logger.saveLog();
        }
    }, 

    changeOppositionCheck : function(component,event,helper) {   
        const logger = component.find('logger');
        try{     
            component.set("v.buttonDisabled",true);            
            if(component.get("v.oppositionChecked")== false){
                component.set("v.toggleChecked",true);
                if(component.get("v.centralizarChecked")== false){
                    component.set("v.buttonDisabled",false);
                }
            }else{
                if(component.get("v.centralizarChecked")== true){
                    component.set("v.buttonDisabled",false);
                }
                component.set("v.toggleChecked",false);
            }
        }catch(e){
            console.error(e);
            logger.error(e.message);
            logger.saveLog();
        }
    }, 

    nextStepUser: function(component,event,helper) {
        const logger = component.find('logger');
        try{
            if(component.get("v.screen") =='3'){
                component.set("v.accepted",false);
                var contactId = component.get("v.contactId");         
                helper.createConsentimiento(component,contactId,false);
                component.set("v.screen",'5');  
            }else{
                component.set("v.screen",'3');
            }
        }catch(e){
            console.error(e);
            logger.error(e.message);
            logger.saveLog();
        }
    }
})