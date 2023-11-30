public class PaseTallerGateway {
    
     public static Pase_de_taller__c getPaseTallerById(String id) {
        Pase_de_taller__c paseTaller;
        
        if (!String.isBlank(id)) {
            Map<String, Pase_de_taller__c> mapIdToPaseTaller = getPaseTallerById(new List<String>{id});
            paseTaller = mapIdToPaseTaller.containsKey(id) ? mapIdToPaseTaller.get(id) : null;
        }
        
        return paseTaller;
    }
    
    public static Map<String, Pase_de_taller__c> getPaseTallerById(List<String> lstIds) {
        Map<String, Pase_de_taller__c> mapIdToPaseTaller = new Map<String, Pase_de_taller__c>();
        
        if (!lstIds.isEmpty()) {
            for (Pase_de_taller__c paseTaller : [SELECT Id, Name, Concesionario__c, Centro__c, workshopOrderId__c, creationDate__c, receptionDate__c, deliveryDate__c, Vehiculo__c,
                                                 customerDepositary__c, customer__c, customerOwner__c, customerAmount__c, insuranceAmount__c, internalAmount__c,
                                                 warrantyAmount__c, deferenceAmount__c, campaignAmount__c, currencyType__c, serviceAdviser__c, workshopCode__c, kms__c, 
                                                 cancelDate__c, appointmentDate__c, appointmentId__c, Estado__c,
                                                 Centro__r.Activo__c, 
                                                 Centro__r.Gestiona_LEAD__c,
                                                 customerDepositary__r.Name,                                                   
                                                 customerDepositary__r.PersonEmail, 
                                                 customerDepositary__r.OtherEmail__pc, 
                                                 customerDepositary__r.PersonMobilePhone, 
                                                 customerDepositary__r.OtherMobilePhone__pc, 
                                                 customerDepositary__r.Phone, 
                                                 customerDepositary__r.PersonOtherPhone,
                                                 serviceAdviser__r.Name, serviceAdviser__r.Email__c, serviceAdviser__r.Phone__c,
                                                 Vehiculo__r.MarcaString__c, Vehiculo__r.Name, Vehiculo__r.modelDescription__c, Vehiculo__r.VIN__c, Vehiculo__r.ModeloString__c, customerDepositaryTXT__c
                                                 FROM Pase_de_taller__c
                                                WHERE Id in :lstIds LIMIT 2000]) {
                
                mapIdToPaseTaller.put(paseTaller.Id, paseTaller);
            }
        }
        
        return mapIdToPaseTaller;
    }

     public static Pase_de_taller__c getPaseTallerByWorkshopOrder(String workshopOrder) {
        Pase_de_taller__c paseTaller;
        
        if (!String.isBlank(workshopOrder)) {
            Map<String, Pase_de_taller__c> mapWorkshopOrderToPaseTaller = getPaseTallerByWorkshopOrder(new List<String>{workshopOrder});
            paseTaller = mapWorkshopOrderToPaseTaller.containsKey(workshopOrder) ? mapWorkshopOrderToPaseTaller.get(workshopOrder) : null;
        }
        
        return paseTaller;
    }
    
    public static Map<String, Pase_de_taller__c> getPaseTallerByWorkshopOrder(List<String> lstWorkshopOrder) {
        Map<String, Pase_de_taller__c> mapWorkshopOrderToPaseTaller = new Map<String, Pase_de_taller__c>();
        
        if (!lstWorkshopOrder.isEmpty()) {
            for (Pase_de_taller__c paseTaller : [SELECT Id, Name, Concesionario__c, Centro__c, workshopOrderId__c, creationDate__c, receptionDate__c, deliveryDate__c, Vehiculo__c,
                                                 customerDepositary__c, customer__c, customerOwner__c, customerAmount__c, insuranceAmount__c, internalAmount__c,
                                                 warrantyAmount__c, deferenceAmount__c, campaignAmount__c, currencyType__c, serviceAdviser__c, workshopCode__c, kms__c, 
                                                 cancelDate__c, appointmentDate__c, appointmentId__c, Estado__c,
                                                 Centro__r.Activo__c, 
                                                 Centro__r.Gestiona_LEAD__c,
                                                 customerDepositary__r.Name,                                                   
                                                 customerDepositary__r.PersonEmail, 
                                                 customerDepositary__r.OtherEmail__pc, 
                                                 customerDepositary__r.PersonMobilePhone, 
                                                 customerDepositary__r.OtherMobilePhone__pc, 
                                                 customerDepositary__r.Phone, 
                                                 customerDepositary__r.PersonOtherPhone,
                                                 DateBringFriend__c, customerDepositaryTXT__c
                                                 
                                                 FROM Pase_de_taller__c
                                                WHERE workshopOrderId__c in :lstWorkshopOrder LIMIT 2000]) {
                
                mapWorkshopOrderToPaseTaller.put(paseTaller.workshopOrderId__c, paseTaller);
            }
        }
        
        return mapWorkshopOrderToPaseTaller;
    }
    
    public static Pase_de_taller__c getLastPaseTallerByVehiculoId(String vehiculoId){
        Pase_de_taller__c paseTaller;
        if(!String.isBlank(vehiculoId)){
            Map<String, Pase_de_taller__c> mapGetLastPaseTallerByVehiculo = PaseTallerGateway.getLastPaseTallerByVehiculoId(new Set<String> {vehiculoId});
            if(!mapGetLastPaseTallerByVehiculo.isEmpty() && mapGetLastPaseTallerByVehiculo.containsKey(vehiculoId)){
                paseTaller = mapGetLastPaseTallerByVehiculo.get(vehiculoId);
            }
        }
        
        return paseTaller;
    }
    
    public static Map<String, Pase_de_taller__c> getLastPaseTallerByVehiculoId(Set<String> vehiculoIds){
        Map<String,Pase_De_taller__c> mapLastPaseTallerByVehiculo = new Map<String,Pase_de_taller__c>();
        for(Pase_de_taller__c pTaller :[Select Id, Name, Concesionario__c, Centro__c, workshopOrderId__c, creationDate__c, deliveryDate__c, Vehiculo__c, customerDepositary__c, customer__c, customerOwner__c, customerAmount__c,
                                        insuranceAmount__c, internalAmount__c, warrantyAmount__c, deferenceAmount__c, campaignAmount__c, currencyType__c, serviceAdviser__c, workshopCode__c, workshopDescription__c, kms__c, receptionDate__c 
                                        From Pase_de_taller__c
                                        Where Vehiculo__c in :vehiculoIds AND deliveryDate__c != null order by deliveryDate__c desc, CreatedDate desc LIMIT 2000]){
         	if(!mapLastPaseTallerByVehiculo.containsKey(pTaller.Vehiculo__c)){
            	mapLastPaseTallerByVehiculo.put(pTaller.Vehiculo__c, pTaller);                               
            }
        }
        return mapLastPaseTallerByVehiculo;
    }

    public static List<Pase_de_taller__c> getPaseTallerCancelByVehiculoId(String vehiculoId, String workshopOrderId){
        List<Pase_de_taller__c> PaseTallerCancel = new List<Pase_de_taller__c>();
        Map<string, Pase_de_taller__c> mapPaseTallerCancel = new Map<string,Pase_de_taller__c>();
        List<string> IdsPT = new list<string>();
        if(!String.isBlank(vehiculoId)){
            for(Pase_de_taller__c pTaller :[Select Id, Name, Concesionario__c, Centro__c, workshopOrderId__c, creationDate__c, deliveryDate__c, Vehiculo__c, customerDepositary__c, customer__c, customerOwner__c, customerAmount__c,
                                    insuranceAmount__c, internalAmount__c, warrantyAmount__c, deferenceAmount__c, campaignAmount__c, currencyType__c, serviceAdviser__c, workshopCode__c, workshopDescription__c, kms__c, receptionDate__c 
                                     From Pase_de_taller__c
                                     Where Vehiculo__c = :vehiculoId 
                                     AND Estado__c = 'Cita cancelada' 
                                     AND workshopOrderId__c != :workshopOrderId LIMIT 2000]){
                if(!mapPaseTallerCancel.containsKey(pTaller.Id)){
                    mapPaseTallerCancel.put(pTaller.Id, pTaller);
                    IdsPT.add(pTaller.Id);
                }
            }
	        if (!IdsPT.isEmpty()) {
                for(Planificacion_Servicio__c pServicio :[Select Id, Pase_de_taller__c 
                                            From Planificacion_Servicio__c Where Pase_de_taller__c in :IdsPT]){
                    if(mapPaseTallerCancel.containsKey(pServicio.Pase_de_taller__c)){
                        mapPaseTallerCancel.remove(pServicio.Pase_de_taller__c);
                    }
                }
            }    
        }    
        
        return mapPaseTallerCancel.values();
    }

    public static Map<String,Map<String, Pase_de_taller__c>> getPaseTallerByVehiculoIdOS(List<String> vehiculoIds){
        Map<string,Map<string, Pase_de_taller__c>> mapPaseTallerVehiculoOS = new Map<string,Map<string,Pase_de_taller__c>>();
	    if (!vehiculoIds.isEmpty()) {
            for(Pase_de_taller__c pTaller :[Select Id, Vehiculo__c, appointmentId__c 
                                            From Pase_de_taller__c
                                     Where Vehiculo__c = :vehiculoIds 
                                     AND appointmentId__c != null LIMIT 2000]){

                Map<String, Pase_de_taller__c> mapAux =  mapPaseTallerVehiculoOS.containsKey(pTaller.Vehiculo__c)
                    ? mapPaseTallerVehiculoOS.get(pTaller.Vehiculo__c) : new Map<String,Pase_de_taller__c>();
                if (!mapAux.containsKey(pTaller.appointmentId__c)) {
                     mapAux.put(pTaller.appointmentId__c, pTaller);                       
               	}
                mapPaseTallerVehiculoOS.put(pTaller.Vehiculo__c, mapAux);
	        }    
        }    
        
        return mapPaseTallerVehiculoOS;
    }
    
}