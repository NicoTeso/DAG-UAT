({
    echo : function(component, event) {
        component.set("v.Hide",true);
        var action = component.get("c.updatePermissions"); 
        $A.enqueueAction(action);
    },
    doInit : function(component, event) {
        component.set("v.Hide",true);
        var action = component.get("c.getPermissions"); action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {
                var responseId = response.getReturnValue();
                component.set("v.Hide",responseId);
            }
            
        });
        $A.enqueueAction(action);                                                                  
    }
})