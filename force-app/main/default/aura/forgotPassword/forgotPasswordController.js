({
    handleForgotPassword: function (component, event, helper) {
        console.log("FUERA DEL HELPLER");
        var username = component.find("username").get("v.value");
        username = username.trim(); username = username.replaceAll('(\\s+)', ' ');
        component.find("username").set("v.value",username);
        component.set("v.loading", true);
        helper.handleForgotPassword(component, event, helper);
    },
    onKeyUp: function(component, event, helper){
    //checks for "enter" key
    	console.log('onchange');
       var username = component.find("username").get("v.value");
        username = username.trim(); username = username.replaceAll('(\\s+)', ' ');
        component.find("username").set("v.value",username);
        
    },
     
 // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
       // make Spinner attribute true for display loading spinner 
        component.set("v.loading", true); 
   },
    
 // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
     // make Spinner attribute to false for hide loading spinner    
       component.set("v.loading", false);
    }
})