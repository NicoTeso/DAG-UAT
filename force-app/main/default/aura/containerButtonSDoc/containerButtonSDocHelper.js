({
    doInit : function(component, event) {
        var recordId = component.get("v.recordId");
        var action= component.get("c.getUrlAttachment");
            action.setParams({
           	 	"recordId": recordId
         	});
			action.setCallback(this, function (resp) {
                console.log(resp.getState());
             	if(resp.getState() == 'SUCCESS'){
             		var responseJSON = resp.getReturnValue();
                    var response = JSON.parse(responseJSON);
                        if(response['respuesta'] == 'OK'){
                            console.log(response['URL']);
                            component.set("v.attachmentUrl",response['URL']);
                            component.set("v.show", true);
                        }
                    
                 }
         		
			});
            $A.enqueueAction(action);
        
    },
	handleSend : function(component, event) {
		var recordId = component.get("v.recordId");
        var action= component.get("c.sendBudget");
            action.setParams({
           	 	"recordId": recordId
         	});
			action.setCallback(this, function (resp) {
                console.log(resp.getState());
             	if (resp.getState() == 'SUCCESS') {
             		var response = resp.getReturnValue();
                    this.showToast(response);
         		}
			});
            $A.enqueueAction(action);
        },
    showToast: function(msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Envío de propuesta",
            "message": msg
            
        });
        toastEvent.fire();        
    }  
})