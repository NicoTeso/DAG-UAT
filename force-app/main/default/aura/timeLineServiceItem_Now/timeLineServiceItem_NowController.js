({
	showEditPanel : function(component, event, helper) {
		    component.set("v.isOpen",true);
  	},
    closeModel : function(component, event, helper) {
        	component.set("v.isOpen",false);
    },
    onRecordSuccess : function(component, event, helper){
        component.set("v.isOpen", false);
        helper.showToast('Actualización', 'La operación se ha realizado correctamente.');
        helper.refreshtime(component,event);
    }
})