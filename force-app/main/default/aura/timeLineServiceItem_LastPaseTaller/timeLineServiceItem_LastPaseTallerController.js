({
	showSection : function(component, event, helper) {
		var showSection = component.get("v.show");
        if(showSection){
            component.set("v.show",false);
        }
        else {
            component.set("v.show",true);
        }
	}
})