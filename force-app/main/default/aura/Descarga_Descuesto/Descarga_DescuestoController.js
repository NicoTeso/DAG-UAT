({
    doInit: function(component) {
        console.log("init");
    },
    downloadDocument : function(component, event, helper){
        var sendDataProc = component.get("v.sendData");
        var dataToSend = {
            "label" : "This is test"
        }; 
        sendDataProc(dataToSend, function(){
            //handle callback
        });
    },
    handleClick: function(component, event, helper)
    {  
        var returnValue;
        var action = component.get("c.getDiscountDetail");
        var recordId= component.get("v.recordId");
        action.setParams({
            "recordId": recordId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();                       
            console.log(state);
            if (state === "SUCCESS") {
                returnValue= response.getReturnValue();
         
                if(returnValue.Tipo_Canjeo__c=='Envío Email')
                {
                    location.href='mailto:'+returnValue.Email_de_envio__c+'?SUBJECT='+' DESCUENTO '+returnValue.Name+'&BODY=';
                }
                else if(returnValue.Tipo_Canjeo__c=='Código Promoción' || returnValue.Tipo_Canjeo__c=='Presentación Física')
                {
                    var modalBody;
                    $A.createComponent("c:DiscountModal", {recordId:recordId,CodigoPromocion:returnValue.Codigo_promocion__c,TipoCanjeo:returnValue.Tipo_Canjeo__c},
                                       function(content, status) {
                                           if (status === "SUCCESS") {
                                               modalBody = content;
                                               component.find('overlayLib').showCustomModal({
                                                   header: returnValue.Name,
                                                   body: modalBody,
                                                   showCloseButton: true,
                                                   closeCallback: function() {
                                                       //alert('Closed');
                                                   }
                                               })
                                           }
                                       });
                }
                else if(returnValue.Tipo_Canjeo__c=='Código QR')
                {
                    var modalBody;
                    var codigoPromocion;
                    if(returnValue.JO_Cuenta_Descuento__r != null && returnValue.JO_Cuenta_Descuento__r.length > 0)
                        codigoPromocion = returnValue.JO_Cuenta_Descuento__r[0].Codigo_Descuento__c;
                    $A.createComponent("c:DiscountModal", {recordId:recordId,CodigoPromocion:codigoPromocion,TipoCanjeo:returnValue.Tipo_Canjeo__c,GoogleAPI:'https://chart.googleapis.com/chart?chs=200x200&cht=qr&chl='},
                                        function(content, status) {
                                            if (status === "SUCCESS") {
                                                modalBody = content;
                                                component.find('overlayLib').showCustomModal({
                                                    header: returnValue.Name,
                                                    body: modalBody, 
                                                    showCloseButton: true,
                                                    closeCallback: function() {
                                                        //alert('Closed');
                                                    }
                                                })
                                            }
                                        });
                }
                else if(returnValue.Tipo_Canjeo__c=='URL QR')
                {
                    var modalBody;
                    $A.createComponent("c:DiscountModal", {recordId:recordId,CodigoPromocion:returnValue.Codigo_promocion__c,TipoCanjeo:returnValue.Tipo_Canjeo__c,GoogleAPI:'https://chart.googleapis.com/chart?chs=200x200&cht=qr&chl='},
                                        function(content, status) {
                                            if (status === "SUCCESS") {
                                                modalBody = content;
                                                component.find('overlayLib').showCustomModal({
                                                    header: returnValue.Name,
                                                    body: modalBody, 
                                                    showCloseButton: true,
                                                    closeCallback: function() {
                                                        //alert('Closed');
                                                    }
                                                })
                                            }
                                        });
                }
                console.log(JSON.stringify(returnValue));
            } else if (state === "INCOMPLETE") {
                
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }
                } 
            }
            
        });
        $A.enqueueAction(action);
    },
    manageFavourite: function(component, event, helper){
        var action = event.getSource().get('v.label');
        var discountId = component.get("v.recordId");
        var manFav = component.get("c.manageFavouriteDiscount");
        manFav.setParams({ discountId : discountId,
                            action : action});
        manFav.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var showToast = $A.get('e.force:showToast');
                showToast.setParams({
                        'title': 'Información: ',
                        'message': 'Descuento añadido a favoritos' });
                showToast.fire();
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
    }
})