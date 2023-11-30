({  doInit : function(component, event, helper) {
              	helper.doInit(component,event);
        		helper.createColumns(component,event);
        		//helper.dataInit(component,event);
	},
    loadMoreDataPropietarios : function(component, event, helper){
        helper.loadMoreData(component,event,'Propietarios');
    },
    loadMoreDataCompradores: function(component, event, helper){
        helper.loadMoreData(component,event, 'Compradores');
    }, 
    loadMoreDataDepositarios: function(component, event, helper){
        helper.loadMoreData(component,event, 'Depositarios');
    }
    
   /* handleRowAction : function (component, event, helper){
        var action = event.getParam('action');
        var row = event.getParam('row');

        switch (action.name) {
            case 'Relacionar':
                helper.relacionar (component,row);
                break;
        }
         
       
        
    }*/
})