public class RegistrosRelacionadosGateway {
    
    public static Map<String, List<Registros_Relacionados__c>> getRRDestinosByRegistroDestinoId(List<String> lstId) {
        Map<String, List<Registros_Relacionados__c>> mapRRelacionadosByDestino = new Map<String, List<Registros_Relacionados__c>>();
        
        if (!lstId.isEmpty()) {
            List<Registros_Relacionados__c> lstRRelacionados = [SELECT Id, Name, Registro_Origen__c, Registro_Destino__c  
                                                    FROM  Registros_Relacionados__c 
                                    				WHERE Registro_Destino__c in :lstId ORDER BY Registro_Destino__c ];
            
            for (Registros_Relacionados__c rr  : lstRRelacionados) {
                List<Registros_Relacionados__c> listRR = mapRRelacionadosByDestino.containsKey(rr.Registro_Destino__c)?mapRRelacionadosByDestino.get(rr.Registro_Destino__c): new List<Registros_Relacionados__c>();
                listRR.add(rr);
                mapRRelacionadosByDestino.put(rr.Registro_Destino__c, listRR);
            }
        }
        
        return mapRRelacionadosByDestino;
    }
    
}