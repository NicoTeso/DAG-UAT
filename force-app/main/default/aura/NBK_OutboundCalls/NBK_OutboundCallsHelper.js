({
    defaultInitComponent : function(component, currentRecordId){
        var action = component.get("c.initComponent");

        action.setParams({
            recordId : currentRecordId
        });

        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var responseWrapper = JSON.parse(response.getReturnValue());
                if (responseWrapper.success) {
                    if(responseWrapper.customerPhone){
                        component.set("v.customerPhoneSelected", responseWrapper.customerPhone);

                    }else {
                        var customerPhonesMap = [];
                        for(var key in responseWrapper.customerPhonesMap){
                            customerPhonesMap.push({value:responseWrapper.customerPhonesMap[key], key:key});
                        }

                        if(customerPhonesMap.length == 1){
                            component.set("v.customerPhoneSelected", customerPhonesMap[0].value);

                        } else {
                            component.set("v.customerPhonesMap", customerPhonesMap);
                            component.set("v.customerPhoneSelected", customerPhonesMap[0].value);
                        }
                    }

                    if(responseWrapper.brandPhone){
                        component.set("v.brandPhoneSelected", responseWrapper.brandPhone);

                    } else {
                        var brandPhonesMap = [];
                        for(var key in responseWrapper.brandPhonesMap){
                            brandPhonesMap.push({value:responseWrapper.brandPhonesMap[key], key:key});
                        }

                        component.set("v.brandPhonesMap", brandPhonesMap);
                        component.set("v.brandPhoneSelected", brandPhonesMap[0].value);
                    }

                } else {
                    this.showToast("error", "Error " + component.get("v.cmpTitle"), responseWrapper.errorMessage);
                }

            } else {
                this.showToast("error", "Error " + component.get("v.cmpTitle"),  $A.get("$Label.c.OutboundCalls_Call_Info_Error"));
            }
        });

        $A.enqueueAction(action);
    },

    ventaActivaInitComponent : function(component, currentRecordId){
        var action = component.get("c.initComponentVA");

        action.setParams({
            recordId : currentRecordId
        });

        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var responseWrapper = JSON.parse(response.getReturnValue());
                if (responseWrapper.success) {
                    var customerPhonesMap = [];
                    for(var key in responseWrapper.customerPhonesMap){
                        customerPhonesMap.push({value:responseWrapper.customerPhonesMap[key], key:key});
                    }

                    if(customerPhonesMap.length > 0){
                        component.set("v.customerPhonesMap", customerPhonesMap);
                        component.set("v.customerPhoneSelected", customerPhonesMap[0].value);
                    }

                    if(responseWrapper.brandPhone){
                        component.set("v.brandPhoneSelected", responseWrapper.brandPhone);
                    }

                } else {
                    this.showToast("error", "Error " + component.get("v.cmpTitle"), responseWrapper.errorMessage);
                }

            } else {
                this.showToast("error", "Error " + component.get("v.cmpTitle"),  $A.get("$Label.c.OutboundCalls_Call_Info_Error"));
            }
        });

        $A.enqueueAction(action);
    },

    showToast : function(type, title, msg){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "title": title,
            "message": msg
        });
        toastEvent.fire();
    },

    updateTaskSendCall: function(component) {
        var recordId = component.get("v.recordId");
        var customerPhone = component.get("v.customerPhoneSelected");
        var brandPhoneSelected = component.get("v.brandPhoneSelected");

        var action = component.get("c.updateOutboundCallTask");


        action.setParams({
            'recordId': recordId,
            'customerPhone': customerPhone,
            'brandPhoneSelected': brandPhoneSelected
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseWrapper = JSON.parse(response.getReturnValue());
                if (responseWrapper.success) {
                    component.find('clickToDial').click();                
                    $A.get('e.force:refreshView').fire();
                    //this.navigateToRecordObj(responseWrapper.caseId);               
                    
                }else{
                    this.showToast("error", "Error " + component.get("v.cmpTitle"), responseWrapper.errorMessage);
                }
            } else {
                this.showToast("error", "Error " + component.get("v.cmpTitle"), $A.get("$Label.c.OutboundCalls_Call_Task_Generation_Error"));
            }
        });

        $A.enqueueAction(action);
    },

    refreshFocusedTab : function(component) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.refreshTab({
                      tabId: focusedTabId,
                      includeAllSubtabs: true
             });
        })
        .catch(function(error) {
            console.log(error);
        });
    },

    navigateToRecordObj : function(objId) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": objId
        });
        navEvt.fire();
    }

});