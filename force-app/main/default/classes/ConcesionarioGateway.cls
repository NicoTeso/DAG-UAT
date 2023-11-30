public class ConcesionarioGateway {

    public static Concesionario__c getConcessionaireById(String id) {
        Concesionario__c concessionaire;
        
        if (!String.isBlank(id)) {
            Map<String, Concesionario__c> mapIdToConcessionaire = getConcessionaireById(new List<String>{id});
            
            if (!mapIdToConcessionaire.isEmpty()) {
                concessionaire = mapIdToConcessionaire.get(id);
            }
        }
        
        return concessionaire; 
    }    
    
    public static Map<String, Concesionario__c> getConcessionaireById(List<String> lstId) {
        Map<String, Concesionario__c> mapIdToConcessionaire = new Map<String, Concesionario__c>();
        
        if (!lstId.isEmpty()) {
            List<Concesionario__c> lstConcessionaires = [SELECT Id,
												 				Name,
												 				CIF__c,
												 				Domicilio__c,
												 				Es_propio__c,
												 				Es_SIMA__c,
												 				Id_Concesionario_Sima__c,
												 				Imagen_concesionario__c,
												 				Integrado_con_SIMA__c,
												 				Red_Comercial__c,
												 				Telefono__c,
												 				Web__c
                                     	  				 FROM Concesionario__c
                                     	  				 WHERE Id in :lstId
                                     	  				 LIMIT 2000];
            
            for (Concesionario__c concessionaire : lstConcessionaires) {
                mapIdToConcessionaire.put(concessionaire.Id, concessionaire);
            }
        }
        
        return mapIdToConcessionaire;
    }
    
    public static Concesionario__c getConcessionaireByCompanyId(String companyId) {
        Concesionario__c concessionaire;
        
        if (!String.isBlank(companyId)) {
            Map<String, Concesionario__c> mapConcessionaires = ConcesionarioGateway.getConcessionaireByCompanyId(new List<String>{companyId});
            if (!mapConcessionaires.isEmpty()) {
                concessionaire = mapConcessionaires.get(companyId);
            }
        }
        
        return concessionaire;
    }
    
    public static Map<String, Concesionario__c> getConcessionaireByCompanyId(List<String> lstcompanyId) {
        Map<String, Concesionario__c> mapCompanyIdToConcessionaire = new Map<String, Concesionario__c>();
        
        if (!lstcompanyId.isEmpty()) {
            List<Concesionario__c> lstConcessionaires = [SELECT Id,
												 				Name,
												 				CIF__c,
												 				Domicilio__c,
												 				Es_propio__c,
												 				Es_SIMA__c,
												 				Id_Concesionario_Sima__c,
												 				Imagen_concesionario__c,
												 				Integrado_con_SIMA__c,
												 				Red_Comercial__c,
												 				Telefono__c,
												 				Web__c
                                     	  				 FROM Concesionario__c
                                     	  				 WHERE Id_Concesionario_Sima__c  in :lstcompanyId
                                     	  				 LIMIT 2000];
            
            for (Concesionario__c concessionaire : lstConcessionaires) {
                mapCompanyIdToConcessionaire.put(concessionaire.Id_Concesionario_Sima__c, concessionaire);
            }
        }
        
        return mapCompanyIdToConcessionaire;
    }
    
    public static Concesionario__c getConcessionaireByCIF(String cif){
        Concesionario__c concesionario;
         List<Concesionario__c> lstConcessionaires = [SELECT Id, Name, CIF__c, Domicilio__c, Es_propio__c, Es_SIMA__c, Id_Concesionario_Sima__c,
												 	  Imagen_concesionario__c, Integrado_con_SIMA__c, Red_Comercial__c, Telefono__c, Web__c, Agente_con_taller__c
                                     	  			 FROM Concesionario__c
                                     	  			 WHERE CIF__c = :cif
                                     	  			 LIMIT 2000];
        if(!lstConcessionaires.isEmpty()){
            concesionario = lstConcessionaires[0];
        }
        return concesionario;
    }

}