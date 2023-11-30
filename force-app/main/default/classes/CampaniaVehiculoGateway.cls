public class CampaniaVehiculoGateway {

	public static List<Campania_Vehiculo__c> getCampaniaVehiculoByVehicle(String id) {
        List<Campania_Vehiculo__c> lstCampania = new List<Campania_Vehiculo__c>();
        
        if (!String.isBlank(id)) {
            lstCampania = getCampaniaVehiculoByVehicle(new List<String>{id});
            
        }
        
        return lstCampania;
    }
    
    public static List<Campania_Vehiculo__c> getCampaniaVehiculoByVehicle(List<String> lstId) {
        List<Campania_Vehiculo__c> lstCampania = new List<Campania_Vehiculo__c>();
        
        if (!lstId.isEmpty()) {
            lstCampania = [Select Id, Name, Vehiculo__c, Codigo__c, Tipo__c, Descripcion__c, Concesionario__c, 
                           Centro__c, Depositario__c, Estado__c
                           From Campania_Vehiculo__c 
                           where Vehiculo__c = :lstId and Estado__c !='Cerrado' and Estado__c !='No aplica' 
                           LIMIT 2000];
        }
        
        return lstCampania;
    }
    

}