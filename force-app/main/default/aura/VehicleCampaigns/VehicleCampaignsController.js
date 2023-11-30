({
	doInit : function(component, event, helper) {
		helper.doInit(component,event);
	},
    refresh: function(component,event,helper){
        var ref = event.getParam("refrescar");
        if(ref == "true"){
            helper.refreshCampaigns(component,event);
        }
    }
})