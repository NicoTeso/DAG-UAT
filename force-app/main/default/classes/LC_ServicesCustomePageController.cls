public class LC_ServicesCustomePageController {
    
    @AuraEnabled
    public static String doInitServiceCustom(String recordId){
        String respuesta;
        Boolean mismaCuenta = false;
        Map<String,String> response = new Map<String,String>();
        Vehiculo__c vehiculo;
        if(!String.isBlank(recordId)){
             List<Vehiculo__c> vehiculos = [Select Id, Propietario__c,Depositario__c, Name From Vehiculo__c where Id =: recordId ];
            if(!vehiculos.isEmpty()){
                vehiculo = vehiculos[0];
                response.put('Respuesta', 'OK');
                if(vehiculo.Propietario__c == vehiculo.Depositario__c){
       				mismaCuenta = true;
                }
                response.put('MismaCuenta', String.valueOf(mismaCuenta));
                response.put('Matricula', vehiculo.Name);
            }
            else {
                response.put('Respuesta','KO');
            }
        }
        respuesta = JSON.serialize(response);
        return respuesta;
    }
    

}