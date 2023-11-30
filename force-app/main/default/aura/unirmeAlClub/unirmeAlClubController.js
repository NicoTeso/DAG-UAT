({
    handleClick : function(cmp, event) {
        cmp.set("v.disabled", true);
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s"));
        var URL = baseURL + '/s/alta-fidelity-card';
        var action = cmp.get("c.actualizarCampo");

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var updatePermission = cmp.get("c.updatePermissions"); 
                $A.enqueueAction(updatePermission);
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url":  URL
                });
                urlEvent.fire();
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
})