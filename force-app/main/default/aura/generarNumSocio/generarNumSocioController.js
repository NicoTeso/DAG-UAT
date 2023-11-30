({
    handleClick : function(cmp, event) {
        /*var check = cmp.find("PoliticaPriv").get("v.checked");*/
        /*if(check == false){				//Accepting comercial info no longer required
            cmp.set("v.checked",true);	
            console.log('checkedFalse');
            console.log(cmp.find("PoliticaPriv").get("v.value"));
        }else{*/
     //IMP 230720   var check = cmp.find("PoliticaPriv").get("v.checked");
        var action = cmp.get("c.actualizarCampo");
        //IMP 230720     action.setParams({ Accepted : check });
        
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s"));
        var URL = baseURL + '/s/alta-fidelity-card';
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url":  URL
                });
                urlEvent.fire();
                
                //"https://viseo-domingoalonsogroup.cs109.force.com/mydag/s/solicitud-fidelity-card"
                // Alert the user with the value returned 
                // from the server
                //alert("From server: " + response.getReturnValue());
                
                // You would typically fire a event here to trigger 
                // client-side notification that the server-side 
                // action is complete
            }
            else if (state === "INCOMPLETE") {
                // do something
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
    }
    //}
})