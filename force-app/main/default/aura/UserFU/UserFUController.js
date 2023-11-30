({
    echo : function(component, event) {
      
    },
    doInit : function(component, event) {
        var action = component.get("c.checkOppositionRecordByUser"); 
        	action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {
                var responseId = response.getReturnValue();
                if(responseId != '2'){
                         var urlEvent = $A.get("e.force:navigateToURL");
                         var urlString = window.location.href;
        				 var baseURL = urlString.substring(0, urlString.indexOf("/s"));
                        urlEvent.setParams({
                            "url": baseURL
                        });
                        urlEvent.fire();
            
                }
                    
                console.log('Success');           
                console.log(responseId);                
            }else{
               console.log('Error');           
            }
        });   
        $A.enqueueAction(action); 
    }
})