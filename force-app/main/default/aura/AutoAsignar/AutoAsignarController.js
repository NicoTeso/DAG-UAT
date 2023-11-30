({
    doInit: function(component, event, helper) {
        
        var action = component.get('c.getCurrentUserId'); 

        action.setCallback(this, function(result) {
            var state = result.getState(); 
            
            if (state == 'SUCCESS') {
                component.set("v.userId", result.getReturnValue());
                component.set("v.isUserIdLoaded", true);
            } else {
                helper.showToast("error", "Error!", "Error mientra busca el user id");
            }
        });
        
        $A.enqueueAction(action);        
        
    },
    handleSuccess : function(component, event, helper) {
        helper.showToast("success", "Success", "El caso fue asignado correctamente");
        $A.get('e.force:refreshView').fire();
    }    
})