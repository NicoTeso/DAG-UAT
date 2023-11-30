public class CustomerLifetimeValueController {
    
    public static CustomerLifetimeValueModel getCustomerLifetimeValueList(String block) {
        HttpResponse response;
        CustomerLifetimeValueModel respuesta;
        
        response = CustomerLifetimeValueCallout.getCustomerLifetimeValueCallout(block);

        System.debug('CustomerLifetimeValueController.getCustomerLifetimeValueList response ' + response + 'getStatus ' + response.getStatus());
        System.debug('CustomerLifetimeValueController.getCustomerLifetimeValueList response body ' + response.getBody());
        if (!String.isBlank(response.getStatus()) && response.getStatus().equalsIgnoreCase('OK')) {
        	respuesta = (CustomerLifetimeValueModel) JSON.deserialize(response.getBody(), CustomerLifetimeValueModel.class);
        }else {
            System.debug('CustomerLifetimeValueController.getCustomerLifetimeValueList else no OK');
            //if(Exception__c.SObjectType.getDescribe().isCreateable()){
                insert new Exception__c (
                    idObjetos__c = '', Exception__c = 'Error code: ' + response.getStatusCode() + ' // Mensaje de error: '+ response.getBody(), Linea__c = 11, Clase_Metodo__c = 'CustomerLifetimeValueController.getCustomerLifetimeValueList'
                );
            //}
     	}
        system.debug('CustomerLifetimeValueController.getCustomerLifetimeValueList respuesta:'+ respuesta);
        return respuesta;
    }
}