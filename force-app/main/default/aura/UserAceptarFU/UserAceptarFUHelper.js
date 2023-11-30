({
 createConsentimiento : function(component) {
    if(! component.get("v.antiDobleCheck")){
        component.set("v.antiDobleCheck",true);
           console.log('createConsentimiento');
          var action = component.get("c.createConsentimiento");         	
            console.log(contactID);
            console.log(accepted);
        	action.setParams({ accept : accepted, contactId : contactID});
            action.setCallback(this, function (response) {
                if (response.getState() === 'SUCCESS') {
                    if(accepted){
                        component.set("v.screen",'4');
                    }else{
                        component.set("v.screen",'5');  
                    }
                } else {
                    component.set("v.output","Hay un problema al guardar su consentimiento, por favor pongase en contacto con nosotros a través de mydag@domingoalonsogroup.com"); 
                    console.log('ERROR'); 
                    console.log(response.getError());
                }
            });
            $A.enqueueAction(action);
        }
    }
})