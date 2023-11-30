public class VehicleExternalController {
    
    public static VehicleExternalModel getVehicleSIMA(String vin, String concesionario) {
        return getVehicleSIMA(vin,concesionario,true);
    }
    public static VehicleExternalModel getVehicleSIMA(String vin, String concesionario, Boolean createError) {
        VehicleExternalModel respuesta;
		ResponseApi responseCallout;
        responseCallout = VehicleExternalCallout.getVehicleCallout(vin, concesionario);
        System.debug('VehicleExternalController.getVehicleSIMA responseCallout ' + responseCallout);
        if (responseCallout.Status.equalsIgnoreCase('OK')) {
        	respuesta = (VehicleExternalModel) JSON.deserialize(responseCallout.Message, VehicleExternalModel.class);
            system.debug('respuesta:'+ respuesta);
        }
        else if(createError){
        	Exception__c exc = new Exception__c ();
         	exc.idObjetos__c = vin + '/' + concesionario;
         	exc.Exception__c = responseCallout.ErrorCode + '//'+ responseCallout.Message;
         	exc.Linea__c = 12;
         	exc.Clase_Metodo__c = 'VehicleExternalController.getVehicleSIMA';
            if (Exception__c.SObjectType.getDescribe().isCreateable()){
                insert exc;
            }
     	}   
        return respuesta;
    }
}