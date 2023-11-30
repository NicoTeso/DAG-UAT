({	doInit : function(component, event, helper){},
	createJSON : function(component, event, helper) {
        let button = event.getSource();
    	button.set('v.disabled',true);
        console.log("Generating JSON...");
        var recordId = component.get("v.recordId");
        console.log("recordId:"+ recordId);
		var action = component.get("c.createAndSendJSON");
        action.setParams({
            recordId: recordId
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS"){
                var serverResponse = response.getReturnValue();
                helper.showToast(serverResponse);
            }  
            let button = event.getSource();
    		button.set('v.disabled',false);
        
            $A.get('e.force:refreshView').fire();
        });
        
        $A.enqueueAction(action);
	}
  	   
})