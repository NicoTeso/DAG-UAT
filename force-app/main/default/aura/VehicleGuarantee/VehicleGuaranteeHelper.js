({
	doInit : function(component,event) {
		var recordId = component.get("v.recordId");
        var action = component.get("c.getShow");
            action.setParams({
           	 	"recordId": recordId
         	});
			action.setCallback(this, function (resp) {
            	console.log(resp.getState());
            	if (resp.getState() == 'SUCCESS') {
             		var responseJSON = resp.getReturnValue();
                	var response =JSON.parse(responseJSON);
                    component.set("v.recordAux", response );
                	/*if(response['respuesta']){
                        component.set("v.showDataGarantia", response['showGarantia']);
                        component.set("v.showDataExtGarantia", response['showExtGarantia']);
                 	}
                	else {
                        component.set("v.showDataGarantia", false);
                        component.set("v.showDataExtGarantia", false);
                 	}*/
              	}
            	 else {
            	        console.log('ERROR'); 
            	        console.log(resp.getError());
            	    }
            	});
            $A.enqueueAction(action);
 	}
	
})