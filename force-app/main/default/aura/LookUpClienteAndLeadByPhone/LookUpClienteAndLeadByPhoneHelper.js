({
	doInit: function (component, event){
		var recordId = component.get("v.recordId");
        var sObjectName = component.get("v.sObjectName");
		console.log('record Id: '+ recordId);
        
        if (recordId != null && recordId != 'undefined') {
         	var action = component.get("c.getListResponsePhone");
         	
            action.setParams({
           	 	"id": recordId,
                "objectName": sObjectName
        	});
            
         	action.setCallback(this, function (resp) {
                if (resp.getState() === 'SUCCESS') {
                    console.log('state ' + resp.getState());
                    var list = JSON.parse( resp.getReturnValue() );
                    console.log("lista de cuentas: " + list);
                    
                    if (list !== null && list.length > 0) {
                       component.set("v.mostrar", true);
                       component.set("v.data", list);
                    }
                    else {
                        component.set("v.mostrar", false);
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
            component.set("v.mostrar", false);
        }
    },
    
    createColumns : function(component,event){
        var recordId = component.get("v.recordId");
		var sObjectName = component.get("v.sObjectName");
        if (recordId != null && recordId != 'undefined') {
         	if (sObjectName === 'MessagingSession') {
                    	var actions = [{ label: 'Relacionar', name: 'Relacionar' }]
        				component.set('v.columns', [
            					{ label: 'Name', fieldName: 'Name', type: 'text' },
            					{ label: 'Phone', fieldName: 'Phone', type: 'text' },
            					{ label: 'Tipo', fieldName: 'Tipo', type: 'text' },
            					{ type: 'action', typeAttributes: { rowActions: actions } }
        				]);
                        component.set('v.title','Cuentas y Candidatos posibles');

                    }
            else{
                console.log('No recogido el sObjectName');
            }
         }
         else {
         	console.log('ERROR'); 
            console.log('No recogido el recordId');
                }
    },
    
    relacionar : function(component,row){
        console.log('entra en la relacion');
        var rows = component.get('v.data');
        var idAux = rows[rows.indexOf(row)].Id;
        var tipo = rows[rows.indexOf(row)].Tipo;
        var idRecord = component.get('v.recordId');
        console.log('id: '+idRecord+' idAux: ' + idAux+ ' tipo: '+ tipo);
        if(idRecord!= null && idRecord!= 'undefined' && idAux!= null && idAux!= 'undefined'){
            console.log('entro para hacer la relacion');
         	var action = component.get("c.relacionar");
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