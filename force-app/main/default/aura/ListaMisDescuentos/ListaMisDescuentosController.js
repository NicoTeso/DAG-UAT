({
    doInit : function(component, event, helper) {
        component.set('v.columns', [ {label: 'Descuento', fieldName: 'Name', type: 'text'}]);
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s"));
        component.set("v.baseUrl", encodeURI(baseURL));
        if(component.get("v.Type") == 'Favoritos'){
            component.set('v.isFavorite',true);  
        }
        var action = component.get("c.getDiscounts");
        
        action.setParams({ category : component.get("v.category"),
                          localizacion : component.get("v.localizacion"),
                          Type : component.get("v.Type")});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.searchResult',response.getReturnValue());
                var returnValues = response.getReturnValue();
                var categorias = component.get('v.categoriaPicklist');
                helper.locDescuentos = [];
                for(var i = 0; i < returnValues.length; i++) {
                    if(categorias.indexOf(returnValues[i].Categoria__c)  === -1)
                        categorias.push(returnValues[i].Categoria__c);
                    if(helper.locDescuentos.indexOf(returnValues[i].Localizacion_Padre__c)  === -1) {
                        helper.locDescuentos.push(returnValues[i].Localizacion_Padre__c);
                        helper.locDescuentos[returnValues[i].Localizacion_Padre__c] = [];
                    }
                    if(helper.locDescuentos[returnValues[i].Localizacion_Padre__c].indexOf(returnValues[i].Localizacion_Descuento__c) === -1)
                    	helper.locDescuentos[returnValues[i].Localizacion_Padre__c].push(returnValues[i].Localizacion_Descuento__c)
                }
                component.set('v.categoriaPicklist',categorias);
                component.set('v.locDescuentos',helper.locDescuentos);
            }
            else if (state === "INCOMPLETE") {
                // do something
                //	alert('failed');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    openPicklist: function(component, event) {
        if(component.get("v.truthy") == true){
            component.set('v.truthy',false);  
        }else{
            component.set("v.truthy",true);  
        }
    }, 
    changeCategory: function(component, event, helper){
        component.set("v.localizacion", "");
        component.set("v.localizacionBase", "");
        var a = component.get('c.doInit');
        $A.enqueueAction(a);
    },
    change: function(component, event, helper) {
        component.set("v.locPicklist", helper.locDescuentos[component.get("v.localizacionBase")]);
        component.set("v.localizacion", "");
        var a = component.get('c.doInit');
        $A.enqueueAction(a);
    }, 
    limpiaFiltro: function(component, event, helper) {
        component.set("v.localizacion", "");
        component.set("v.localizacionBase", "");
        component.set("v.category", "");
        var a = component.get('c.doInit');
        $A.enqueueAction(a);
    } ,
    manageFavourite: function(component, event, helper){
        var action = event.getSource().get('v.title');
        var discountId = event.getSource().get('v.value');
        var manFav = component.get("c.manageFavouriteDiscount");
        manFav.setParams({ discountId : discountId,
                            action : action});
        manFav.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(action == 'Favoritos'){
                    var showToast = $A.get('e.force:showToast');
                
                    showToast.setParams({
                            'title': 'Información: ',
                            'message': 'Descuento añadido a favoritos' });
                    showToast.fire();
                    setTimeout(function(){
                        location.reload();
                    }, 3000);
                    
                }
                if(action == 'Eliminar'){
                    var showToast = $A.get('e.force:showToast');
                
                    showToast.setParams({
                            'title': 'Información: ',
                            'message': 'Descuento eliminado de favoritos' });
                    showToast.fire();
                }
            }

            else if (state === "INCOMPLETE") {
                // do something
                //	alert('failed');
            }

            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(manFav);
        var a = component.get('c.doInit');
        $A.enqueueAction(a);
    }
})