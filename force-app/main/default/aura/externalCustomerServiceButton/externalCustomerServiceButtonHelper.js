({
	showToast: function(msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Envio a SIMA",
            "message": msg
            
        });
        toastEvent.fire();        
    }    
})