({
    doInit: function (cmp, event){
		var recordId = cmp.get("v.recordId");
		console.log('record Id: '+ recordId);
        
        if (recordId != null && recordId != 'undefined') {
         	var action = cmp.get("c.getListResponse");
         	
            action.setParams({
           	 	"id": recordId
        	});
            action.setCallback(this, function (resp) {
                if (resp.getState() === 'SUCCESS') {
                    console.log('state ' + resp.getState());
                    var response = JSON.parse( resp.getReturnValue() );
                    var listCompradores;
                    var listPropietarios;
                    var listDepositarios;
                    var listTotal =[];
                    var compradoresBoolean = false;
                    var propietariosBoolean = false;
                    var depositariosBoolean = false;
                    console.log('respuesta: '+ response);
                    if (response !== null && response !=='undefined') {
                        cmp.set("v.responseInitial", response);
                        listCompradores = response.compradores;
                        listPropietarios = response.propietarios;
                        listDepositarios = response.depositarios;
                        if(listCompradores !== null && listCompradores.length > 0){
                            compradoresBoolean = true;
                        }
                        if(listPropietarios !== null && listPropietarios.length > 0){
                            propietariosBoolean = true;
                        }
                        if(listDepositarios !== null && listDepositarios.length > 0){
                            depositariosBoolean = true;
                        }
                        cmp.set("v.dataCompradores", listCompradores);
                        cmp.set("v.dataPropietarios", listPropietarios);
                        cmp.set("v.dataDepositarios", listDepositarios);
                        cmp.set("v.mostrarComprador", compradoresBoolean);
                        cmp.set("v.mostrarPropietario", propietariosBoolean);
                        cmp.set("v.mostrarDepositario", depositariosBoolean);
                        /*for(var i=0 ; i<listCompradores.length;i++){
                			listTotal.push({"Id":listCompradores[i].Id, "value":listCompradores[i]});
            			}
            			for(var i=0 ; i<listPropietarios.length;i++){
                			listTotal.push({"Id":listPropietarios[i].Id, "value":listPropietarios[i]});
            			}
            			for(var i=0 ; i<listDepositarios.length;i++){
                			listTotal.push({"Id":listDepositarios[i].Id, "value":listDepositarios[i]});
            			}
            			component.set('v.dataTotal', listTotal);*/
                    }
                    else {
                       cmp.set("v.mostrarComprador", compradoresBoolean);
                       cmp.set("v.mostrarPropietario", propietariosBoolean);
                       cmp.set("v.mostrarDepositario", depositariosBoolean);
                       
                    }
                       
                 }
                 else {
                    console.log('ERROR'); 
                    console.log(resp.getError());
                }
            });
            $A.enqueueAction(action);
            
        }
        else {
            cmp.set("v.mostrar", false);
        }
    },
     
    createColumns : function(cmp,event){
        cmp.set('v.columns', [  { label: 'Matrícula',fieldName: 'Link', type: 'url', typeAttributes: { label: { fieldName: 'Matricula' }  } },
            					{ label: 'Marca',cellAttributes: { class: { fieldName: 'Marca' } } },
            					{ label: 'Modelo', fieldName: 'Modelo', type: 'text' },
            					{ label: 'Garantia', fieldName: 'Garantia', type: 'text' },
                              	{ label: 'Configuración', fieldName: 'ConfiguracionLink', type: 'url', typeAttributes: { label: { fieldName: 'Configuracion' } }},
            					
            				]);
    },
    
    loadMoreData: function(component,event, tipo){
        var responseInitial = component.get("v.responseInitial");
        var sizeList;
        var total;
        if(tipo =='Compradores'){
            sizeList = component.get("v.dataCompradores").length;
            total = responseInitial.totalCompradores;
        }
        if(tipo == 'Depositarios'){
            sizeList = component.get("v.dataDepositarios").length;
            total = responseInitial.totalDepositarios;
        }
        if(tipo == 'Propietarios'){
            sizeList = component.get("v.dataPropietarios").length;
            total = responseInitial.totalPropietarios;
        }
        if(total > sizeList){
            var action = component.get("c.loadMore");
        	action.setParams({
            "recordId" :  responseInitial.recordId,
            "tipo" : tipo,
            "intOffSet" : sizeList
        	});
        	action.setCallback(this, function(response) {
            	var state = response.getState();
            	if (state === "SUCCESS") {
                var responseJSON = response.getReturnValue();
                var resp = JSON.parse(responseJSON);
                    if(resp && resp.lista.length>0){
                        if(resp.tipo =='Compradores'){
                            var currentData = component.get('v.dataCompradores');                
                			component.set("v.dataCompradores", currentData.concat(resp.lista));
                        }
                        else if(resp.tipo == 'Propietarios'){
                            var currentData = component.get('v.dataPropietarios');                
                			component.set("v.dataPropietarios", currentData.concat(resp.lista));
                        }
                        else if(resp.tipo == 'Depositarios'){
                            var currentData = component.get('v.dataDepositarios');                
                			component.set("v.dataDepositarios", currentData.concat(resp.lista));
                        }
                    }
           		}
         	
        	});
        	$A.enqueueAction(action);
        }
        
    },
    
    loadMoreDataCompradores: function(component,event){
        var responseInitial = component.get("v.responseInitial");
    },
    
    loadMoreDataDepositarios: function(component,event){
        var responseInitial = component.get("v.responseInitial");
    },
   
})