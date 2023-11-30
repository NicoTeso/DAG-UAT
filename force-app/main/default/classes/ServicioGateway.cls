public class ServicioGateway {
    
    public static List<Servicio__c> getServiciosByPaseTallerId(String paseTallerId){
        List<Servicio__c> servicios = new List<Servicio__c>();
        if(!String.isBlank(paseTallerId)){
            Map<String,List<Servicio__c>> mapServiciosByPaseTallerId = ServicioGateway.getServiciosByPaseTallerId(new Set<String>{paseTallerId});
            if(!mapServiciosByPaseTallerId.isEmpty() && mapServiciosByPaseTallerId.containsKey(paseTallerId)){
                servicios = mapServiciosByPaseTallerId.get(paseTallerId);
            }
        }
        return servicios;
    }

    public static Map<String,List<Servicio__c>> getServiciosByPaseTallerId(Set<String> paseTallerIds){
        Map<String, List<Servicio__c>> mapServiciosByPaseTallerId = new Map<String, List<Servicio__c>>();
        if(!paseTallerIds.isEmpty()){
            
            for(Servicio__c servicio :[Select Id, Name, Pase_de_taller__c, serviceType__c, serviceOrigin__c, partGroups__c, extenalId__c, serviceTypeCode__c, serviceOriginCode__c, PartGroupCode__c 
                					   From Servicio__c Where Pase_de_taller__c in : paseTallerIds]){
             	List<Servicio__c> servicios = mapServiciosByPaseTallerId.containsKey(servicio.Pase_de_taller__c) ? mapServiciosByPaseTallerId.get(servicio.Pase_de_taller__c): new List<Servicio__c>();
                servicios.add(servicio);
				mapServiciosByPaseTallerId.put(servicio.Pase_de_taller__c, servicios);                
            }
        }
        return mapServiciosByPaseTallerId;
    }
}