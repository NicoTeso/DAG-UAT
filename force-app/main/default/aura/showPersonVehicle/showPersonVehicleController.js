({
	doInit : function(component, event, helper) {
        helper.createColumns(component,event);
		helper.doInit(component,event);
	},
    loadMoreData: function(component, event, helper){
        helper.loadMoreData(component,event);
    },
    showDataVehicle: function(component,event,helper){
    	component.set("v.showTable", true);
	},
    hideDataVehicle: function(component, event, helper){
    	component.set("v.showTable", false);
	}
})