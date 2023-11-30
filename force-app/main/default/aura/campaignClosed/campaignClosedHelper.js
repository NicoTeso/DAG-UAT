({
	doInit: function (component, event){
		var recordId = component.get("v.recordId");
		console.log('record Id: '+ recordId);
        if (recordId) {
         	var action = component.get("c.getListClosedCampaigns");
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
                        listServices = response.campanias;
                        var count= response.count;
                        var finalCount = response.finalCount;
                        component.set("v.data", listServices);
                        component.set("v.count", count);
                        component.set("v.finalCount", finalCount);
                        component.set("v.show", true);
                        
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
            					{ label: 'Últ. Llamada', fieldName: 'ultLlamada', type: 'date' },
            					{ label: 'Motivo', fieldName: 'motivo', type: 'text' },
                              	{ label: 'SubMotivo', fieldName: 'subMotivo', type: 'text'}
            				]);
    },
    
    loadMoreData : function(component,event){
        var recordId = component.get("v.recordId");
        var sizeList = component.get("v.count");
        var total = component.get("v.finalCount");
        if(total > sizeList){
            var action = component.get("c.loadMore");
        	action.setParams({
            "recordId" :  recordId,
            "intOffSet" : sizeList
        	});
        	action.setCallback(this, function(response) {
            	var state = response.getState();
            	if (state === "SUCCESS") {
                	var response = JSON.parse( resp.getReturnValue() );
                	var listServices;
                	var show = false;
                	if (response["respuesta"] =="OK") {
                		listServices = response["servicios"];
                	    var count= response["count"];
                	    var finalCount = response["countFinal"];
                   		component.set("v.data", listServices);
                    	component.set("v.count", count);
                    	component.set("v.finalCount", finalCount);
                    	component.set("v.show", true);
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