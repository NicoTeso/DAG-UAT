({
	createServices : function(component,event) {
        var recordId = component.get("v.recordId");
        var fechaIni = component.get("v.DateInit");
        var fechaEnd = component.get("v.DateEnd");
        var action= component.get("c.getServices");
            action.setParams({
           	 	"recordId": recordId,
                "fechaIni": fechaIni,
                "fechaEnd": fechaEnd
                
        	});
			action.setCallback(this, function (resp) {
                console.log(resp.getState());
             	if (resp.getState() == 'SUCCESS') {
             		var responseJSON = resp.getReturnValue();
             	   var response =JSON.parse(responseJSON);
                    console.log(responseJSON);
                    if(response['Respuesta'] =='OK'){
                        component.set("v.Services", JSON.parse(response['Servicios']).Services);
                        component.set("v.DateInit", JSON.parse(response['DateInit']));
                        component.set("v.DateEnd", JSON.parse(response['DateEnd']));
                    }
                   
             	   
             	 //  component.set("v.ServiceNow", response.ServiceNow);
             	 //  component.set("v.ServiceAfter", response.ServiceAfter);
         		}
			});
            $A.enqueueAction(action);
        },
           
})