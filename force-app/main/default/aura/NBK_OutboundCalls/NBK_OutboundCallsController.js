({
    doInit : function(component, event, helper){
        var isVentaActiva = component.get("v.isVentaActiva");
        var currentRecordId = component.get("v.recordId");
        if(isVentaActiva){
            helper.ventaActivaInitComponent(component, currentRecordId);
        } else {
            helper.defaultInitComponent(component, currentRecordId);
        }
    },

    startOutboundCall : function (component, event, helper){
        var omniAPI = component.find("omniToolkit");
        omniAPI.getServicePresenceStatusId().then(function(result) {
            if(result.statusName.includes("Disponible") || result.statusName.includes("Accesorios") || result.statusName.includes("Gestión")){
                helper.updateTaskSendCall(component);
            } else {
                helper.showToast("warning", "", $A.get("$Label.c.OutboundCalls_OmniChannel_Connection_Warning"));
            }

        }).catch(function(error) {
            helper.showToast("warning", "", $A.get("$Label.c.OutboundCalls_OmniChannel_Connection_Warning"));
        });
    }
});