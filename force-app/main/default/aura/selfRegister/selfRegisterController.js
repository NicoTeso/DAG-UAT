({
    initialize: function(component, event, helper) {
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap}).fire();
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap2}).fire();
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s"));
        var politicaPriv = baseURL + '/s/politica-de-privacidad';
        var avisoLegal = baseURL + '/s/aviso-legal';
        var loginURL = baseURL + '/s/login';
        component.set("v.pPrivacidadURL", encodeURI(politicaPriv));
        component.set("v.avisoLegal", encodeURI(avisoLegal));
        component.set("v.loginURL", encodeURI(loginURL));
    },

    handleCheckDnibyAccount: function (component, event, helper) {
        helper.handleCheckDnibyAccount(component, event, helper);
    },

    handleSelfRegister: function (component, event, helpler) {
        helpler.handleSelfRegister(component, event, helpler);
    },

    handleNext: function (component, event, helper) {
        helper.handleNext(component, event, helper);
    },

    handleNextToScreen3: function (component, event, helper) {
        helper.handleNextToScreen3(component, event, helper);
    },

    handleNextToScreen4: function (component, event, helper) {
        helper.handleNextToScreen4(component, event, helper);
    },

    handleNextFromScreen5: function (component, event, helper) {
        helper.handleNextFromScreen5(component, event, helper);
    },

    handleInicioButton: function (component, event, helper) {
        helper.handleInicioButton(component, event, helper);
    },

    setStartUrl: function (component, event, helpler) {
        var startUrl = event.getParam('startURL');
        if(startUrl) {
            component.set("v.startUrl", startUrl);
        }
    },
    onKeyUp: function(component, event, helpler){
        //checks for "enter" key
        if (event.getParam('keyCode')===13) {
            helpler.handleSelfRegister(component, event, helpler);
        }
    },

    changeCentralizarCheck : function (component, event, helper) {
        helper.changeCentralizarCheck(component, event, helper);
    },

    changeOppositionCheck : function (component, event, helper) {
        helper.changeOppositionCheck(component, event, helper);
    }
})