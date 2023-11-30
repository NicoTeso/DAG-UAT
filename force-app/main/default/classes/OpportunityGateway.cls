public class OpportunityGateway {
    /*No se utiliza por el momento
	public static Opportunity getOppById(String id) {
        Opportunity opp;
        
        if (!String.isBlank(id)) {
            Map<String, Opportunity> mapIdToOpp = getOppById(new List<String>{id});
            
            if (!mapIdToOpp.isEmpty()) {
                opp = mapIdToOpp.get(id);
            }
        }
        
        return opp;
    }
	*/    
    
    public static Map<String, Opportunity> getOppById(List<String> lstId) {
        Map<String, Opportunity> mapIdToOpp = new Map<String, Opportunity>();
        
        if (!lstId.isEmpty()) {
            List<Opportunity> lstCenters = [SELECT Id,
												   Name,
                                            	   ID_Oportunidad_DMS__c,
                                            	   Vendedor__c, 
                                            	   Fecha_de_completado__c,
                                            	   StageName,
                                            	   CampaignId,
                                                   Centro__c,
                                                   Vendedor__r.Name,
                                                   Vendedor__r.Email__c,
                                                   Account.Name,
                                                   Account.PersonEmail, 
                                                   Account.OtherEmail__pc, 
                                                   Account.PersonMobilePhone, 
                                                   Account.OtherMobilePhone__pc, 
                                                   Account.Phone, 
                                                   Account.PersonOtherPhone,   
                                                   Centro__r.Activo__c, 
                                                   Centro__r.Gestiona_LEAD__c,
                                                   Marca__c,
                                                   Centro__r.Id_Centro_Sima__c,
                                                   CompradorTXT__c
                                     	  	FROM Opportunity
                                    	  	WHERE Id in :lstId
                                    	  	LIMIT 2000];
            
            for (Opportunity opp : lstCenters) {
                mapIdToOpp.put(opp.Id, opp);
            }
        }
        
        return mapIdToOpp;
    }
    
    
    public static Opportunity getOppByIdVentaDMS(String idVentaDMS) {
        Opportunity opp;
        
        if (!String.isBlank(idVentaDMS)) {
            Map<String,Opportunity> mapOppByIdDMS = OpportunityGateway.getOppByIdVentaDMS(new List<String>{idVentaDMS});
            if (!mapOppByIdDMS.isEmpty()) {
                opp = mapOppByIdDMS.get(idVentaDMS);
            }
        }
        
        return opp;
    }
    
    public static Map<String,Opportunity> getOppByIdVentaDMS(List<String> listIdVentaDMS) {
        Map<String, Opportunity> mapOppByIdDMS = new Map<String,Opportunity>();
        
        if (!listIdVentaDMS.isEmpty()) {
            for(Opportunity opp :[SELECT Id,Name,ID_Oportunidad_DMS__c, Type, Concesionario__c, 
                                         Fecha_de_exito__c, AccountId, Vendedor__c, Fecha_de_completado__c, 
                                         StageName, CampaignId, Fecha_de_entrega__c, AdvertisingCommunications__c, 
                                         EndDateAdvertising__c, Dias_de_vencimiento__c, DateBringFriend__c, Campaign.Name, Marca__c,
                                         CompradorTXT__c 
                                  FROM Opportunity WHERE ID_Oportunidad_DMS__c  in :listIdVentaDMS]){
                mapOppByIdDMS.put(opp.ID_Oportunidad_DMS__c, opp);
            }
            
           
        }
        
        return mapOppByIdDMS;
    }
}