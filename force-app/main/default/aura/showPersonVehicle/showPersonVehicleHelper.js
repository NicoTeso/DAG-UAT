({
	doInit : function(component,event) {
        console.log("comienza doInit");
        var recordId = component.get("v.recordId");
        var tipo = component.get("v.title");
        var action = component.get("c.getInfoClient");
            action.setParams({
           	 	"recordId": recordId,
                "tipo": tipo
        	});
			action.setCallback(this, function (resp) {
                console.log(resp.getState());
             if (resp.getState() == 'SUCCESS') {
             	var responseJSON = resp.getReturnValue();
                if(responseJSON != "KO"){
                	var response =JSON.parse(responseJSON);
                    component.set("v.Response", response);
                    component.set("v.showData", true);
                    component.set("v.data", response.vehiculos);
                    if(response.vehiculos.length == 0){
                        component.set("v.showTable", false);
                        component.set("v.hasData", false);
                        component.set("v.showButton", false);
                    }
                    else if(response.vehiculos.length == 1){
                        component.set("v.showTable", false);
                        component.set("v.hasData", true);
                        component.set("v.showButton", false);
                    }
                    else {
                        component.set("v.showTable", false);
                        component.set("v.hasData", true);
                        component.set("v.showButton", true);
                        }
                 }
                 else {
                    component.set("v.showData", false);
                    component.set("v.showTable", false);
                    component.set("v.hasData", false);
                    component.set("v.showButton", false);
                 }
                
              }
              else {
                    console.log('ERROR'); 
                    console.log(resp.getError());
                }
                
            });
            $A.enqueueAction(action);
 	},
    createColumns : function(component,event){
        component.set('v.columns', [  { label: 'Matrícula',fieldName: 'identificador', type: 'url', typeAttributes: { label: { fieldName: 'matricula' }  } },
            					{ label: 'Marca',cellAttributes: { class: { fieldName: 'marca' } } }
            				]);
    },
    loadMoreData: function(component,event){
        var recordAux = component.get("v.Response");
        var tipo = component.get("v.title");
        var sizeList = component.get('v.data').length;
        console.log(sizeList);
        console.log(recordAux.total);
        if(recordAux.total > sizeList){
            var action = component.get("c.loadMore");
        	action.setParams({
            "recordId" :  recordAux.identificacion,
            "tipo" : tipo,
            "intOffSet" : sizeList
        	});
        	action.setCallback(this, function(response) {
            	var state = response.getState();
            	if (state === "SUCCESS") {
                var responseJSON = response.getReturnValue();
                var responseList = JSON.parse(responseJSON);
                    if(responseList && responseList.length>0){
                         var currentData = component.get('v.data');                
                		component.set("v.data", currentData.concat(responseList));
                    }
               
            }
         	
        	});
        	$A.enqueueAction(action);
        }
   }
})