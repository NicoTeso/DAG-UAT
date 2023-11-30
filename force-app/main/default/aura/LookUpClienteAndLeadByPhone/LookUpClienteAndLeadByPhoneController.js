({  doInit : function(component, event, helper) {
        	  	//component.get("v.sObjectName");
		      	helper.doInit(component,event);
        		helper.createColumns(component,event);
        		//helper.dataInit(component,event);
	},
    handleRowAction : function (component, event, helper){
        var action = event.getParam('action');
        var row = event.getParam('row');

        switch (action.name) {
            case 'Relacionar':
                helper.relacionar (component,row);
                break;
        }
         
       
        
    }
	
})