({
	autoAsignar : function(component,event) {
		var item = component.get("v.itemDetail");
        var action = component.get("c.autoAsignarService");
            action.setParams({
           	 	"recordId": item.RecordId
         	});
			action.setCallback(this, function (resp) {
            	console.log(resp.getState());
            	if (resp.getState() == 'SUCCESS') {
             		var response = resp.getReturnValue();
                   if(response){
                       this.showToast('Autoasignar','La operación se ha realizado correctamente.');
                       this.refreshtime(component,event);
                    }
                    else{
                        this.showToast('Autoasignar','Ha ocurrido un error a la hora de autoasignar, Avise al administrador.');
                        console.log('ERROR Al asignar'); 
                    }
                 }
            	 else {
                        this.showToast('Autoasignar','Ha ocurrido un error a la hora de autoasignar, Avise al administrador.');
                        console.log(resp.getError());
            	 }
           	});
            $A.enqueueAction(action);
	},
    refreshtime : function(component,event){
        	var cmpEvent = component.getEvent("cmpRefresh");
        	cmpEvent.setParams({"refrescar" : "true"});
        	cmpEvent.fire();
    },
    createTask : function(component,event){
        var item = component.get("v.itemDetail");
        var newTask = component.get("v.newTask");
        if(item.propietario != null){
            newTask.WhoId = item.propietario;
        }
        else if (item.depositario) {
            newTask.WhoId = item.depositario;
        }
        newTask.WhatId = item.RecordId;
        var newTaskJson = JSON.stringify(newTask);
        var action = component.get("c.insertaTarea");
            action.setParams({
           	 	"tareaJson": newTaskJson
         	});
			action.setCallback(this, function (resp) {
            	console.log(resp.getState());
            	if (resp.getState() == 'SUCCESS') {
             		var response = resp.getReturnValue();
                   if(response){
                       this.showToast('Creación de tareas','Se ha creado una nueva tarea correctamente.');
                       this.refreshtime(component,event);
                    }
                    else{
                        this.showToast('Creación de tareas','No se ha podido crear una nueva tarea, Avise al administrador.');
                       
                    }
                 }
            	 else {
                       	this.showToast('Creación de tareas','No se ha podido crear una nueva tarea, Avise al administrador.');
                        console.log('ERROR'); 
            	        console.log(resp.getError());
            	 }
           	});
            $A.enqueueAction(action);
    }, 
    showToast: function(title,msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": msg
            
        });
        toastEvent.fire();        
    }  
    
})