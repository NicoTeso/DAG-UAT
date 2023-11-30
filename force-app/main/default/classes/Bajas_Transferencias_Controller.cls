public class Bajas_Transferencias_Controller {
    
    public static Bajas_Transferencias_Model getVehicleDGTList(String operationType, String initialDate, String finalDate) {
        HttpResponse response;
        Bajas_Transferencias_Model respuesta;
        Boolean operationOK = false;
        operationOK = (operationType == 'transfer' || operationType == 'deregistered');

        
        response = Bajas_Transferencias_Callout.getVehiclesCallout(operationType, initialDate, finalDate);

        System.debug('Bajas_Transferencias_Controller.getVehicleDGTList response ' + response + 'getStatus ' + response.getStatus());
        System.debug('Bajas_Transferencias_Controller.getVehicleDGTList response body ' + response.getBody());
        if (operationOK && !String.isBlank(response.getStatus()) && response.getStatus().equalsIgnoreCase('OK')) {
        	respuesta = (Bajas_Transferencias_Model) JSON.deserialize(response.getBody(), Bajas_Transferencias_Model.class);
        }else {
            System.debug('Bajas_Transferencias_Controller.getVehicleDGTList else no OK');
            //if(Exception__c.SObjectType.getDescribe().isCreateable()){
                insert new Exception__c (
                    idObjetos__c = '', Exception__c = 'Error code: ' + response.getStatusCode() + ' // Mensaje de error: '+ response.getBody(), Linea__c = 11, Clase_Metodo__c = 'Bajas_Transferencias_Controller.getVehicleDGTList'
                );
            //}
     	}
        system.debug('Bajas_Transferencias_Controller.getVehicleDGTList respuesta:'+ respuesta);
        return respuesta;
    }
}