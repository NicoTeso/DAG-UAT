({
	doInit : function(component,event) {
		var recordId = component.get("v.recordId");
        var action = component.get("c.getInit");
            action.setParams({
           	 	"recordId": recordId
         	});
			action.setCallback(this, function (resp) {
            	console.log(resp.getState());
            	if (resp.getState() == 'SUCCESS') {
             		var responseJSON = resp.getReturnValue();
                	var response =JSON.parse(responseJSON);
                	if(response['respuesta'] =='OK'){
                        if(response['modalidad'] !='KO'){
                        	component.set("v.showData", true);
                            component.set("v.titleContract", 'Contrato Mantenimiento: '+ response['modalidad']);
                            console.log('items ok:' + response['items'] );
                            if(response['items'] =='OK'){
                                component.set("v.showItems",true);
                            }
                            else{
                                component.set("v.showItems", false);
                            }
                        }
                        
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