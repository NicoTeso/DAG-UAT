/**
 * @description  : 
 * @author       : development@nubika.com 
**/
({
    checkOppositionRecord: function(component) {
         //Decision: 0 --> Error / 1 --> Not Registered / 2 --> Registered and accepted  / id --> Registered but old
        var action = component.get("c.checkOppositionRecord");         	                        
        action.setParams({ Acc : component.get("v.accountNIF")});
        action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {
                var responseId = response.getReturnValue();
                if(responseId == '1'){
                    component.set("v.checkOppositionStatus",'1');
                    component.set("v.output",""); 
                    component.set("v.screen",'2');
                } else if(responseId == '2') {
                    component.set("v.checkOppositionStatus",'2');
                    component.set("v.output",""); 
                    var b = component.get('c.registerUserHandler');
                    $A.enqueueAction(b);
                } else if(responseId == '0'){                        
                    component.set("v.output",$A.get("$Label.c.register_ProblemRecoveringConsent"));                        
                } else{
                    component.set("v.checkOppositionStatus",'3');                       
                    component.set("v.idConsentimiento", responseId);
                    component.set("v.screen",'2');
                    component.set("v.output",""); 
                }
            } else {
                component.set("v.output",$A.get("$Label.c.register_ProblemRecoveringConsent"));                                         
            }
        });
        $A.enqueueAction(action);
    },
    createConsentimiento : function(component,contactID,accepted) {   
          var action = component.get("c.createConsentimiento");         	                        
        	action.setParams({ accept : accepted, contactId : contactID});
            action.setCallback(this, function (response) {
                if (response.getState() === 'SUCCESS') {
                    if(accepted){
                        component.set("v.screen",'4');
                    }else{
                        component.set("v.screen",'5'); 
                    }
                } else {
                    component.set("v.output",$A.get("$Label.c.register_ProblemSavingConsent"));                                         
                }
            });
            $A.enqueueAction(action);
    },
    
    updateConsentimiento : function(component,idConsentimiento,accepted) {
          var action = component.get("c.updateConsentimiento");         	                                    
        	action.setParams({ accept : accepted, cntoId : idConsentimiento});
            action.setCallback(this, function (response) {
                if (response.getState() === 'SUCCESS') {
                      component.set("v.screen",'4');
                } else {
                    component.set("v.output",$A.get("$Label.c.register_ProblemSavingConsent"));                                         
                }
            });
            $A.enqueueAction(action);
    },
    validateDNI : function(nifValue) {
        console.log('CreateUserComponentHelper - validateDNI - nifValue: ', nifValue);
        var validChars = 'TRWAGMYFPDXBNJZSQVHLCKET';
        var nifRexp = /^[0-9]{8}[TRWAGMYFPDXBNJZSQVHLCKET]{1}$/i;
        var nieRexp = /^[XYZ]{1}[0-9]{7}[TRWAGMYFPDXBNJZSQVHLCKET]{1}$/i;
        var str = nifValue.toString().toUpperCase();
        if (!nifRexp.test(str) && !nieRexp.test(str) ){
            return false;
        }
        var nie = str
          .replace(/^[X]/, '0')
          .replace(/^[Y]/, '1')
          .replace(/^[Z]/, '2');
        var letter = str.substr(-1);
        console.log('CreateUserComponentHelper - validateDNI - letter: ', letter);
        var charIndex = parseInt(nie.substr(0, 8)) % 23;
        if (validChars.charAt(charIndex) === letter){
            return true;
        }
        return false;
    },
})