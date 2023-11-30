({
    doInit : function(component, event, helper) {
    	helper.doInit(component, event);
    	//Al iniciar el componente, no necesita nada, solo es cuando se oprime al boton
	},
    
	buttonCase : function(component, event, helper) {
        console.log("empieza la edicion");
        var recordId = component.get("v.caseId");
        console.log("recordCase: " + recordId);
    	
        if (!recordId) {
            console.log("entro en la creación");
        	helper.createCase(component, event, helper);
           
		}
        else {
            helper.showCase(component, event);
        }
        
    },
        
    buttonLead : function(component, event, helper) {
        console.log("empieza la edicion");
        var recordId = component.get("v.leadId");
        console.log("recordCase: " + recordId);
    	
        if (!recordId) {
            console.log("entro en la creación del lead");
        	helper.createLead(component, event, helper);
           
		}
        else {
            helper.showLead(component, event);
        }
        
       
    }
})