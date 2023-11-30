({
	doInit : function(component, event, helper) {
		var pageRef = component.get("v.pageReference");
        var myValue = pageRef.state.c__recordId;
        component.set("v.recordId",myValue);
        console.log('#myValue '+myValue); 
        helper.doInit(component, event);
  },
})