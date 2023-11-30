({
    doInit: function (component, event) {
        var objectName = component.get("v.sObjectName");
        component.set("v.objectName", objectName);
    	var recordId = component.get("v.recordId");
        console.log("doInit recordId: " + recordId);
        var action;
        if (recordId !== null && recordId !== 'undefined' ) {
            if(objectName =='LiveChatTranscript'){
                action = component.get("c.getLiveChat");
            }
            else if(objectName =='MessagingSession'){
                action = component.get("c.getMessagingSession");
            }
            action.setParams({
           		 	"id": recordId
         		});
			action.setCallback(this, function (resp) {
            	 if (resp.getState() === 'SUCCESS') {
                    var response = resp.getReturnValue();
                    if(response.CaseId){
                        component.set("v.caseId", response.CaseId);
                    }
                    else{
                       // component.set("v.caseId", 'undefined');
                    }
                    if(response.LeadId){
                        component.set("v.leadId", response.LeadId);
                    }
                    else{
                        //component.set("v.leadId", 'undefined');
                    }
              	}
              	else {
              	      console.log('ERROR'); 
              	      console.log(resp.getError());
              	  }
            	});
            $A.enqueueAction(action);
        }
	},
    
	createCase: function (component, event, helper) {
    	var recordId = component.get("v.recordId");
        var objectName = component.get("v.sObjectName");
        console.log("createCase recordId: " + recordId);
        
        if (recordId !== null && recordId !== 'undefined') {
            console.log("sigue correctamente");
         	var action = component.get("c.getCaseCreate");
            action.setParams({
           	 	"id": recordId,
                "objectName": objectName
			});
			action.setCallback(this, function (resp) {
                if (resp.getState() === 'SUCCESS') {
                    console.log('state ' + resp.getState());
                    console.log('registroooo ' + resp.getReturnValue());
                    var responseId = resp.getReturnValue();
                    component.set("v.caseId", responseId);
                    $A.get('e.force:refreshView').fire();
                    if(responseId !== 'undefined'){
                        var editRecordEvent = $A.get("e.force:editRecord");
        				editRecordEvent.setParams({
            				"recordId": responseId
       				 	});
        				editRecordEvent.fire(); 
                    }
                   
            	 }
                 else {
                    console.log('ERROR'); 
                    console.log(resp.getError());
                    var errors = resp.getError();
					helper.handleErrors(errors);
				}
	               
            });
            
           $A.enqueueAction(action);
        }
	},
    
    showCase: function(cmp, event) {
    	var recordId = cmp.get("v.caseId");
        
    	if (recordId!=="") {
        	var editRecordEvent = $A.get("e.force:editRecord");
        	editRecordEvent.setParams({
            	"recordId": recordId
       		});
        	editRecordEvent.fire(); 
        }
	},
    
    createLead: function (cmp, event, helper) {
        console.log("record: empieza createLead");
    	var recordId = cmp.get("v.recordId");
        console.log("createLead recordId: " + recordId);
        var objectName = cmp.get("v.sObjectName");
        if (recordId !== null && recordId !== 'undefined') {
            console.log("sigue correctamente");
         	var action = cmp.get("c.getLeadCreate");
            action.setParams({
           	 	"id": recordId,
                "objectName": objectName
			});
			action.setCallback(this, function (resp) {
                if (resp.getState() === 'SUCCESS') {
                    console.log('state ' + resp.getState());
                    console.log('registroooo ' + resp.getReturnValue());
                    var responseId = resp.getReturnValue();
                    cmp.set("v.leadId", responseId);
                    $A.get('e.force:refreshView').fire();
                    if(responseId !== 'undefined'){
                        var editRecordEvent = $A.get("e.force:editRecord");
        				editRecordEvent.setParams({
            				"recordId": responseId
       				 	});
        				editRecordEvent.fire(); 
                    }
                   
            	 }
                 else {
                    console.log('ERROR'); 
                    console.log(resp.getError());
                    var errors = resp.getError();
					helper.handleErrors(errors);
                }
            });
            
           $A.enqueueAction(action);
        }
	},
    
    showLead: function(cmp, event) {
    	var recordId = cmp.get("v.leadId");
        
    	if (recordId !=="") {
        	var editRecordEvent = $A.get("e.force:editRecord");
        	editRecordEvent.setParams({
            	"recordId": recordId
       		});
        	editRecordEvent.fire(); 
        }
	},
    
    handleErrors : function(errors) {
    	// Configure error toast
    	let toastParams = {
    	    title: "Error",
    	    message: "Unknown error", // Default error message
        	type: "error"
    	};
    	// Pass the error message if any
    	if (errors && Array.isArray(errors) && errors.length > 0) {
    	    toastParams.message = errors[0].message;
    	}
    	// Fire error toast
    	let toastEvent = $A.get("e.force:showToast");
    	toastEvent.setParams(toastParams);
    	toastEvent.fire();
	}
})