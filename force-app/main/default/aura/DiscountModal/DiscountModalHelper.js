({
    closeModal : function(cmp,event) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        var contactRec = event.getParams().response;
        console.log(JSON.stringify(contactRec));
        /*
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": cmp.get('v.recordId'),
            "slideDevName": "related"
        });
        
        navEvt.fire();
        */
    }
})