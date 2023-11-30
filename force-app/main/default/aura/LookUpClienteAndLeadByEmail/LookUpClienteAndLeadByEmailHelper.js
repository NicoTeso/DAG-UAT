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
                    var list = JSON.parse( resp.getReturnValue() );
                    console.log("lista de cuentas: " + list);
                    console.log("primero: " + list[0]);
                    
                    if (list !== null && list.length > 0) {
                       cmp.set("v.mostrar", true);
                       cmp.set("v.data", list);
                        //$A.get('e.force:refreshView').fire();
                    }
                    else {
                        cmp.set("v.mostrar", false);
                    }
                        /*for (var i = 0; i < list.length; i++) {
                            
                           list[i].Email = list[i].PersonEmail;
                           list[i].Tipo =  list[i].RecordType.Name;
                            }*/
                       
                    //}
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
        
        var recordId = cmp.get("v.recordId");
		
        if (recordId != null && recordId != 'undefined') {
         	var action = cmp.get("c.getObject");
         	
            action.setParams({
           	 	"identificador": recordId
        	});
            
         	action.setCallback(this, function (resp) {
                if (resp.getState() === 'SUCCESS') {
                    var respuesta = resp.getReturnValue();
                    console.log('respuesta:'+ respuesta);
                    if (respuesta === 'LiveChatTranscript') {
                    	var actions = [{ label: 'Relacionar', name: 'Relacionar' }]
        				cmp.set('v.columns', [
            					{ label: 'Name', fieldName: 'Name', type: 'text' },
            					{ label: 'Email', fieldName: 'Email', type: 'text' },
            					{ label: 'Tipo', fieldName: 'Tipo', type: 'text' },
            					{ type: 'action', typeAttributes: { rowActions: actions } }
        				]);
                        cmp.set('v.title','Cuentas y Candidatos posibles');

                    }
                    else if (respuesta ==='Case') {
                        var actions = [{ label: 'Relacionar', name: 'Relacionar' }]
        				cmp.set('v.columns', [
            					{ label: 'Name', fieldName: 'Name', type: 'text' },
            					{ label: 'Email', fieldName: 'Email', type: 'text' },
            					{ label: 'Phone', fieldName: 'Phone', type: 'text' },
            					{ type: 'action', typeAttributes: { rowActions: actions } }
        				]);
                        cmp.set('v.title','Cuentas posibles');

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
    
    relacionar : function(cmp,row){
        console.log('entra en la relacion');
        var rows = cmp.get('v.data');
        //var rowIndex = rows.indexOf(row);
        var idAux = rows[rows.indexOf(row)].Id;
        var tipo = rows[rows.indexOf(row)].Tipo;
        var idRecord = cmp.get('v.recordId');
        console.log('id: '+idRecord+' idAux: ' + idAux+ ' tipo: '+ tipo);
        if(idRecord!= null && idRecord!= 'undefined' && idAux!= null && idAux!= 'undefined'){
            console.log('entro para hacer la relacion');
         	var action = cmp.get("c.relacionar");
         	action.setParams({
           	 	"id": idRecord,
                "idAux" : idAux,
                "tipo" : tipo
        	});
         	action.setCallback(this, function (resp) { 
            if (resp.getState() === 'SUCCESS') {
                console.log('relacionado estado' + resp.getState());
                var respuesta =  resp.getReturnValue();
                console.log('la respuesta:'+respuesta);
                //helper.showToast(respuesta);
                var toastEvent = $A.get("e.force:showToast");
        		toastEvent.setParams({
            		"title": "Relación",
            		"message": respuesta
            
        		});
        		toastEvent.fire();  
                $A.get('e.force:refreshView').fire();
                
                
             }
             else {
                console.log('ERROR'); 
                console.log(resp.getError());
            }
        });
        	$A.enqueueAction(action);
        }
    },
    
    showToast: function(msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Relación",
            "message": msg
            
        });
        toastEvent.fire();        
    }  
    
})