({
	doInit : function(component, event, helper) {
              	helper.doInit(component,event);
        		helper.createColumns(component,event);
	},
    loadMore : function(component, event, helper){
        helper.loadMoreData(component,event);
    },
    refresh: function(component,event,helper){
        var ref = event.getParam("refrescar");
        if(ref == "true"){
            helper.doInit(component,event);
        }
    }
})