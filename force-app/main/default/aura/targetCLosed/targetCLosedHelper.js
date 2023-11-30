({
	doInit: function (component, event){
		var recordId = component.get("v.recordId");
		console.log('record Id: '+ recordId);
        if (recordId) {
         	var action = component.get("c.getListClosedServices");
            action.setParams({
           	 	"recordId": recordId
        	});
            action.setCallback(this, function (resp) {
                if (resp.getState() === 'SUCCESS') {
                    console.log('state ' + resp.getState());
                    var response = JSON.parse( resp.getReturnValue() );
                    var listServices;
                    var show = false;
                    console.log('respuesta: '+ response);
                    if (response.respuesta =="OK") {
                        listServices = response.servicios;
                        var count= response.count;
                        var finalCount = response.finalCount;
                        component.set("v.data", listServices);
                        component.set("v.count", count);
                        component.set("v.finalCount", finalCount);
                        if (finalCount > 0) {
	                        component.set("v.show", true);
                        } else{
	                        component.set("v.show", false);
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
       
    },
     
    createColumns : function(component,event){
        component.set('v.columns', [  { label: 'Servicio',fieldName: 'Link', type: 'url', typeAttributes: { label: { fieldName: 'Name' }  } },
                                { label: 'F. Mantenimiento', fieldName: 'fMantenimiento', type: 'date', typeAttributes:{year: "numeric", month: "2-digit", day: "2-digit"}},
            					{ label: 'nº Llamadas', fieldName: 'intentos', type: 'integer' },
                                { label: 'Últ. Llamada', fieldName: 'ultLlamada', type: 'date', typeAttributes:{year: "numeric", month: "2-digit", day: "2-digit"} },
            					{ label: 'Estado', fieldName: 'estado', type: 'text' },
                                { label: 'Motivo', fieldName: 'motivo', type: 'text' },
                              	{ label: 'SubMotivo', fieldName: 'subMotivo', type: 'text'},
                               	{ label: 'Comenatrio', fieldName: 'comentario', type: 'text'}
                                    
            				]);
    },
    
    loadMoreData : function(component,event){
        var recordId = component.get("v.recordId");
        var sizeList = component.get("v.count");
        var total = component.get("v.finalCount");
        if(total > sizeList){
            var action = component.get("c.loadMoreServices");
        	action.setParams({
            "recordId" :  recordId,
            "intOffSet" : sizeList
        	});
        	action.setCallback(this, function(response) {
            	var state = response.getState();
            	if (state === "SUCCESS") {
                	var response = JSON.parse( response.getReturnValue() );
                	var listServices;
                	var show = false;
                	if (response.respuesta =="OK") {
                		listServices = response.servicios;
                	    if(listServices && listServices.length>0){
                        	var currentData = component.get('v.data');
                            var dataTotal = currentData.concat(listServices);
                			component.set("v.data",  dataTotal);
                            component.set("v.count", dataTotal.length);
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
    },
    
})