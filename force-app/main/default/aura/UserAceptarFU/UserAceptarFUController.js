({
    echo : function(component, event) {
        console.log('Accepted: '+ component.get("v.toggleChecked"));
        if(! component.get("v.antiDobleCheck")){
            component.set("v.antiDobleCheck",true);
            var action = component.get("c.acceptConsentimiento"); 
            action.setParams({ accept : component.get("v.toggleChecked")});
            action.setCallback(this, function (response) {
                    if (response.getState() === 'SUCCESS') {
                       console.log('ACCEPTED');
                        if(component.get("v.toggleChecked") == false){
                            component.set("v.Hide",true);
                        }else {
                             var urlEvent = $A.get("e.force:navigateToURL");
                             var urlString = window.location.href;
                             var baseURL = urlString.substring(0, urlString.indexOf("/s"));
                            urlEvent.setParams({
                                "url": baseURL
                            });
                            urlEvent.fire();
                            component.set("v.screen",'4');
                        }
                    } else {
                        console.log('ERROR'); 
                        console.log(response.getError());
                    }
                });
            $A.enqueueAction(action);
        }
    },
        updateFU : function(component, event) {
        var action = component.get("c.acceptFU"); 
        action.setParams({ accept : component.get("v.toggleChecked")});
        action.setCallback(this, function (response) {
                if (response.getState() === 'SUCCESS') {
                    if(component.get("v.toggleChecked")){
                        var urlEvent = $A.get("e.force:navigateToURL");
                         var urlString = window.location.href;
        				 var baseURL = urlString.substring(0, urlString.indexOf("/s"));
                        urlEvent.setParams({
                            "url": baseURL
                        });
                        urlEvent.fire();
                        component.set("v.screen",'4');
                    }else{
                         component.set("v.screen",'3');
                    }
                         
                } else {
                    console.log('ERROR'); 
                    console.log(response.getError());
                }
            });
        $A.enqueueAction(action);
    },
    changeCentralizarCheck : function(component,event,helper) {
        component.set("v.buttonDisabled",true);            
        console.log('changeCentralizarCheck' + component.get("v.centralizarChecked"));
        if(component.get("v.centralizarChecked") == true){
			component.set("v.oppositionChecked",false);
            component.set("v.toggleChecked",true);
        }else{
            if(component.get("v.oppositionChecked")== false){
                component.set("v.buttonDisabled",false);
            }
            component.set("v.toggleChecked",false);	      
        }
    }, 
    changeOppositionCheck : function(component,event,helper) {
         console.log(' changeOppositionCheck');
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
    }, 
        nextStepUser: function(component,event,helper) {
          component.set("v.screen",'2');  
    },
    doInit : function(component, event) {
        var action = component.get("c.checkOppositionRecordByUser"); 
        	action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {
                var responseId = response.getReturnValue();
                if(responseId == '1'){
                    console.log(responseId);
                    component.set("v.aprovalProcces",true);
                }else if(responseId == 'noClientePropio'){
                    component.set("v.noClientePropio",true);
                }else if(responseId != '2'){
                    component.set("v.notAprovalProcces",true);
                }
                console.log('Success');                         
                console.log(responseId);                         
            }else{
               console.log('Error');           
            }
        });   
        $A.enqueueAction(action); 
    }


})