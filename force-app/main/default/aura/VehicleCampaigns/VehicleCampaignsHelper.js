({
	doInit : function(component,event) {
		var recordId = component.get("v.recordId");
        var action = component.get("c.getCampaignsByVehicle");
            action.setParams({
           	 	"recordId": recordId
         	});
			action.setCallback(this, function (resp) {
            	console.log(resp.getState());
            	if (resp.getState() == 'SUCCESS') {
             		var responseJSON = resp.getReturnValue();
                    var response = JSON.parse(responseJSON);
                	if(response.length >0){
                       	component.set("v.items", response);
                    	component.set("v.showData", true);
                    }
                 }
            	 else {
                        console.log('ERROR'); 
            	        console.log(resp.getError());
            	 }
           	});
            $A.enqueueAction(action);
 	},
    
    refreshCampaigns : function(component, event){
        var recordId = component.get("v.recordId");
        var action = component.get("c.getCampaignsByVehicle");
            action.setParams({
           	 	"recordId": recordId
         	});
			action.setCallback(this, function (resp) {
            	console.log(resp.getState());
            	if (resp.getState() == 'SUCCESS') {
             		var responseJSON = resp.getReturnValue();
                    var response = JSON.parse(responseJSON);
                	if(response.length >0){
                       	component.set("v.items", response);
                    	component.set("v.showData", true);
                    }
                 }
            	 else {
                        console.log('ERROR'); 
            	        console.log(resp.getError());
            	 }
           	});
            $A.enqueueAction(action);
    }
})