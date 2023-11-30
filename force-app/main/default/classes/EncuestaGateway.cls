public class EncuestaGateway {
    private static Map<String, Schema.RecordTypeInfo> rtMapByDeveloperName;
    private static Map<Id, Schema.RecordTypeInfo> rtMapById;
    
    public static String getRecordTypeIdByDeveloperName(String developerName) {
        if (rtMapByDeveloperName == null) {
            rtMapByDeveloperName = new Map<String,Schema.RecordTypeInfo>();
            rtMapByDeveloperName = Schema.SObjectType.Encuesta__c.getRecordTypeInfosByDeveloperName();
        }
        
		return rtMapByDeveloperName.get(developerName).getRecordTypeId();
    }
    
    public static String getDeveloperNameById(Id identificador) {
        if (rtMapById == null) {
            rtMapById = new Map<Id,Schema.RecordTypeInfo>();
            rtMapById = Schema.SObjectType.Encuesta__c.getRecordTypeInfosById();
        }
        
		return rtMapById.get(identificador).getDeveloperName();
    }
    
    public static Encuesta__c getEncuestaBySid(Id sid) {
        Encuesta__c encuesta;
        
        if (!String.isBlank(sid)) {
            Map<String, Encuesta__c> mapSidToEncuesta = getEncuestaBySid(new List<Id>{sid});
            
            if (!mapSidToEncuesta.isEmpty()) {
                encuesta = mapSidToEncuesta.get(sid);
            }
        }
        
        return encuesta;
    }

    public static Map<String, Encuesta__c> getEncuestaBySid(List<Id> lstSid) {
        Map<String, Encuesta__c> mapSidToEncuesta = new Map<String, Encuesta__c>();
        
        if (!lstSid.isEmpty()) {
            for (Encuesta__c encuesta : [SELECT Id, Name,
                                         Cliente__c, Cliente__r.Name, Cliente__r.PersonEmail, Cliente__r.Email__c, Cliente__r.IsPersonAccount,
                                         Respondido__c, Fecha_documento__c, ModeloString__c,Fecha_fin_respuesta__c, Brand__c, 
                                         Detalle_venta__r.Centro__c, Pase_de_taller__r.Centro__c,
                                         Detalle_venta__r.Vendedor__c, Pase_de_taller__r.serviceAdviser__c,
                                         Gestion_encuesta__r.Brand__c, Gestion_encuesta__r.Code__c, vin__c, Tipo_de_Operacion__c, EnvioFabrica__c, Gestion_encuesta__r.Concesionario_encuesta__r.Name, Gestion_encuesta__r.Concesionario__r.Name 
                                         FROM Encuesta__c
                                         WHERE Id in :lstSid LIMIT 2000]) {
                mapSidToEncuesta.put(encuesta.Id, encuesta);
                                             
            }
        }
        
        return mapSidToEncuesta;
    }
    
    public static Encuesta__c getEncuestaByDetalleVenta(String detalleVentaId) {
        Encuesta__c encuesta;
        
        if (!String.isBlank(detalleVentaId)) {
            List<Encuesta__c> encuestas = [select id, Respondido__c, Fecha_respuesta_encuesta__c from Encuesta__c where Detalle_venta__c =:detalleVentaId];
            if(!encuestas.isEmpty()){
                encuesta = encuestas[0];
            }
        }
        return encuesta;
    }
    
    public static Encuesta__c getEncuestaByPaseTaller(String paseTallerId) {
        Encuesta__c encuesta;
        
        if (!String.isBlank(paseTallerId)) {
            List<Encuesta__c> encuestas = [select id, Respondido__c, Fecha_respuesta_encuesta__c from Encuesta__c where Pase_de_taller__c =:paseTallerId];
            if(!encuestas.isEmpty()){
                encuesta = encuestas[0];
            }
        }
        return encuesta;
    }

    public static Map<String, Encuesta__c> getEncuestaByPaseTaller(List<String> lstId) {
        Map<String, Encuesta__c> mapIdToEncuesta = new Map<String, Encuesta__c>();
        
        if (!lstId.isEmpty()) {
            List<Encuesta__c> encuestas = [select id, Respondido__c, Fecha_respuesta_encuesta__c, Pase_de_taller__c from Encuesta__c where Pase_de_taller__c in :lstId LIMIT 2000];
            
            for (Encuesta__c encuesta : encuestas) {
                mapIdToEncuesta.put(encuesta.Pase_de_taller__c, encuesta);
            }
        }
        
        return mapIdToEncuesta;
    }
    
    
    public static Map<String,Datetime> getUltimaFechaByVin(List<String> vins){
        Map<String,Datetime> mapVinToUltimaFecha = new Map<String,Datetime>();
        if (!vins.isEmpty()) {
            for(Encuesta__c encuesta : [select id, Resultado__c, vin__c, createdDate, Respondido__c  from Encuesta__c where vin__c in :vins AND Resultado__c = 'Si']){
                Datetime  fechaActual = mapVinToUltimaFecha.containsKey(encuesta.vin__c)? mapVinToUltimaFecha.get(encuesta.vin__c):null;
                if ((fechaActual== null) || (fechaActual != null && fechaActual<encuesta.CreatedDate)) {
                    mapVinToUltimaFecha.put(encuesta.vin__c, encuesta.CreatedDate);
                }
            }
        }
    	return mapVinToUltimaFecha;
    }

}