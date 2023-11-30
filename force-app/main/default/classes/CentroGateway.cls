public class CentroGateway {
	public static Centro__c getCenterById(String id) {
        Centro__c center;
        
        if (!String.isBlank(id)) {
            Map<String, Centro__c> mapIdToCenter = getCenterById(new List<String>{id});
            
            if (!mapIdToCenter.isEmpty()) {
                center = mapIdToCenter.get(id);
            }
        }
        
        return center;
    }
    
    public static Map<String, Centro__c> getCenterById(List<String> lstId) {
        Map<String, Centro__c> mapIdToCenter = new Map<String, Centro__c>();
        
        if (!lstId.isEmpty()) {
            List<Centro__c> lstCenters = [SELECT Id,
												 Name,
												 Concesionario__c,
												 Domicilio__c,
												 Id_Centro_Sima__c,
												 Imagen_centro__c,
												 Isla__c,
												 Marcas_VN__c,
												 Marcas_VO__c,
												 Telefono__c,
												 Venta_de_VN__c,
												 Venta_de_VO__c,
                                          		 CentroCdg__c,
                                          		 Concesionario__r.Id_Concesionario_Sima__c,
                                          		 Concesionario__r.Es_SIMA__c,
                                          		 Concesionario__r.Nombre_Comercial__c,
                                          		 Concesionario__r.Es_propio__c
                                          
                                     	  FROM Centro__c
                                    	  WHERE Id in :lstId
                                    	  LIMIT 2000];
            
            for (Centro__c center : lstCenters) {
                mapIdToCenter.put(center.Id, center);
            }
        }
        
        return mapIdToCenter;
    }

    public static Centro__c getCenterByIdCentroSima(String idCentroSima) {
        Centro__c center;
        
        if (!String.isBlank(idCentroSima)) {
            List<Centro__c> lstCenters = [SELECT Id,
												 Name,
												 Concesionario__c,
												 Domicilio__c,
												 Id_Centro_Sima__c,
												 Imagen_centro__c,
												 Isla__c,
												 Marcas_VN__c,
												 Marcas_VO__c,
												 Telefono__c,
												 Venta_de_VN__c,
												 Venta_de_VO__c,
                                           		 Concesionario__r.Id_Concesionario_Sima__c,
                                         		 Concesionario__r.Nombre_Comercial__c,
                                          		 Concesionario__r.Es_SIMA__c,
                                          		 Concesionario__r.Es_propio__c
                                          
                                     	  FROM Centro__c
                                    	  WHERE Id_Centro_Sima__c = :idCentroSima];
            
            if (!lstCenters.isEmpty()) {
                center = lstCenters[0];
            }
        }
        
        return center;
    }
    
     public static Map<String, Centro__c> getCenterByIdCentroSima(List<String> lstIdSima) {
        Map<String, Centro__c> mapIdToCenter = new Map<String, Centro__c>();
        
        if (!lstIdSima.isEmpty()) {
            List<Centro__c> lstCenters = [SELECT Id,
												 Name,
												 Concesionario__c,
												 Domicilio__c,
												 Id_Centro_Sima__c,
												 Imagen_centro__c,
												 Isla__c,
												 Marcas_VN__c,
												 Marcas_VO__c,
												 Telefono__c,
												 Venta_de_VN__c,
												 Venta_de_VO__c,
                                          		 CentroCdg__c,
                                          		 Concesionario__r.Id_Concesionario_Sima__c,
                                          		 Concesionario__r.Es_SIMA__c,
                                          		 Concesionario__r.Nombre_Comercial__c
                                     	  FROM Centro__c
                                    	  WHERE Id_Centro_Sima__c in :lstIdSima
                                    	  LIMIT 2000];
            
            for (Centro__c center : lstCenters) {
                mapIdToCenter.put(center.Id_Centro_Sima__c, center);
            }
        }
        
        return mapIdToCenter;
    }

    
     
}