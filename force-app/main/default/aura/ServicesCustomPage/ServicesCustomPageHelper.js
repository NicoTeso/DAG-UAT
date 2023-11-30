({
	doInit : function(component, event) {
	    var recordId = component.get("v.recordId");
        var action = component.get("c.doInitServiceCustom");
            action.setParams({
           	 	"recordId": recordId
        	});
			action.setCallback(this, function (resp) {
                console.log(resp.getState());
             var matricula='S/N';
             if (resp.getState() == 'SUCCESS') {
             	var responseJSON = resp.getReturnValue();
                var response = JSON.parse(responseJSON);
                if(response["Respuesta"]=="OK"){
                     if(response["MismaCuenta"]=="true"){
                         component.set("v.mismoAccount", true);
                         matricula = response["Matricula"];
                     }
                     else{
                         component.set("v.mismoAccount", false);
                         matricula = response["Matricula"];
                     }
                 }
                else {
                 	component.set("v.mismoAccount", false);
              
                 }
                this.setFocusedTabLabel(component, matricula);
                this.setFocusedTabIcon(component, matricula);
                    
             }
             else {
                    console.log('ERROR'); 
                    console.log(resp.getError());
                }
                
            });
            $A.enqueueAction(action);
	}, 
    setFocusedTabLabel : function(component, matricula) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: matricula
            });
        })
        .catch(function(error) {
            console.log(error);
        });
    }, 
    setFocusedTabIcon : function(component, matricula) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
                workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                    icon: "custom:custom31",
                iconAlt: matricula
            });
        })
        .catch(function(error) {
            console.log(error);
        });
    }
})