public class LC_vehicleMaintenanceContractController {
    
    @AuraEnabled
    public static String getInit(String recordId){
       Map<String,String> response = new Map<String,String>();
        if(!String.isBlank(recordId)){
            List<Vehiculo__c> lstVehicles = [SELECT Id,Name,Concesionario__c,Propietario__c, Contrato_modalidad__c, Contrato_Servicio_1__c
                                     	  	FROM Vehiculo__c
                                    	  	WHERE Id = :recordId];
            if(!lstVehicles.isEmpty()){
                Vehiculo__c vehiculo = lstVehicles[0];
                response.put('respuesta','OK');
                String modalidad = !String.isBlank(vehiculo.Contrato_modalidad__c) ? vehiculo.Contrato_modalidad__c: 'KO';
                response.put('modalidad', modalidad);
                String items = !String.isBlank(vehiculo.Contrato_Servicio_1__c)?'OK':'KO';
                response.put('items',items);
            }
            else {
                response.put('respuesta', 'KO');
            }
        }
        else {
            response.put('respuesta', 'KO');
        }
        return JSON.serialize(response);
   }   

}