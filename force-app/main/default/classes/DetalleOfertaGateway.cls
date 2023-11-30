public class DetalleOfertaGateway {
    public static List<Detalle_Oferta__c> getDOfertaByOppId(String oppId) {
        List<Detalle_Oferta__c> listDOfertas = new List<Detalle_Oferta__c>();
        
        if (!String.isBlank(oppId)) {
            Map<String, List<Detalle_Oferta__c>> mapOppToListOfertas = DetalleOfertaGateway.getDOfertaByOppId(new List<String>{oppId});
            
            if (!mapOppToListOfertas.isEmpty()) {
                listDOfertas = mapOppToListOfertas.get(oppId); 
            }
        }
        
        return listDOfertas;
    }
    
    public static Map<String, List<Detalle_Oferta__c>> getDOfertaByOppId(List<String> listOppId) {
        Map<String, List<Detalle_Oferta__c>> mapOppTOListOferta = new Map<String, List<Detalle_Oferta__c>>();
        
        if (!listOppId.isEmpty()) {
            for (Detalle_Oferta__c dOferta : [SELECT Id, Opportunity__c, vin__c, Accessories__c,Services__c, Equipment__c,Financings__c, Total__c FROM Detalle_Oferta__c WHERE Opportunity__c in :listOppId]) {
                List<Detalle_Oferta__c> dOfertas = mapOppTOListOferta.containsKey(dOferta.Opportunity__c) ? mapOppTOListOferta.get(dOferta.Opportunity__c) : new List<Detalle_Oferta__c>();
                dOfertas.add(dOferta);
                mapOppTOListOferta.put(dOferta.Opportunity__c, dOfertas);
            }
        }
        
        return mapOppTOListOferta;
    }
    
    public static Map<String,Detalle_Oferta__c> getDOfertaVinByOppId(String oppId) {
        Map<String,Detalle_Oferta__c> mapDOfertas = new Map<String,Detalle_Oferta__c>();
        
        if (!String.isBlank(oppId)) {
            Map<String, Map<String,Detalle_Oferta__c>> mapOppToOfertasVin = DetalleOfertaGateway.getDOfertaVinByOppId(new List<String>{oppId});
            
            if (!mapOppToOfertasVin.isEmpty()) {
                mapDOfertas = mapOppToOfertasVin.get(oppId); 
            }
        }
        
        return mapDOfertas;
    }
    
    public static Map<String, Map<String,Detalle_Oferta__c>> getDOfertaVinByOppId(List<String> listOppId) {
        Map<String, Map<String,Detalle_Oferta__c>> mapOppTODOfertaVin = new Map<String, Map<String,Detalle_Oferta__c>>();
        
        if (!listOppId.isEmpty()) {
            for (Detalle_Oferta__c dOferta : [SELECT Id, Opportunity__c, vin__c, Accessories__c,Services__c, Equipment__c,Financings__c, Modalidad__c, colorDescription__c, Codigo_de_color__c, Codigo_de_Interior__c, interiorDescription__c,Total__c  FROM Detalle_Oferta__c WHERE Opportunity__c in :listOppId]) {
                Map<String,Detalle_Oferta__c> dOfertasVin = mapOppTODOfertaVin.containsKey(dOferta.Opportunity__c) ? mapOppTODOfertaVin.get(dOferta.Opportunity__c) : new Map<String,Detalle_Oferta__c>();
                dOfertasVin.put(dOferta.vin__c, dOferta);
                mapOppTODOfertaVin.put(dOferta.Opportunity__c, dOfertasVin);
            }
        }
        
        return mapOppTODOfertaVin;
    }
    
}