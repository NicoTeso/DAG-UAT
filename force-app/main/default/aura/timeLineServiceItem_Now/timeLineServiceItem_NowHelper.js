({
	refreshtime : function(component,event){
        	var cmpEvent = component.getEvent("cmpRefresh");
        	cmpEvent.setParams({"refrescar" : "true"});
        	cmpEvent.fire();
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