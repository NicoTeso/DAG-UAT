public class GestionEncuestaGateway {

    public static Gestion_encuesta__c getGestionEncuestaById(String id) {
        Gestion_encuesta__c gEncuesta;
        
        if (!String.isBlank(id)) {
            Map<String, Gestion_encuesta__c> mapIdToGEncuesta = getGestionEncuestaById(new List<String>{id});
            
            if (!mapIdToGEncuesta.isEmpty()) {
                gEncuesta = mapIdToGEncuesta.get(id);
            }
        }
        
        return gEncuesta;
    }

    public static Map<String, Gestion_encuesta__c> getGestionEncuestaById(List<String> lstId) {
        Map<String, Gestion_encuesta__c> mapIdToGEncuesta = new Map<String, Gestion_encuesta__c>();
        
        if (!lstId.isEmpty()) {
            List<Gestion_encuesta__c> lstGEncuesta = [SELECT  Id,Name, Concesionario_encuesta__c, Genera_encuesta_externa__c, URL_SA__c, URL_AS__c,Hora_envio__c,
                                                      Dias_espera_segundo_envio__c, Dias_espera_desde_ultimo_envio__c, Dias_validez__c,Project__c, Country__c, Numeric_country_code__c,
                                                      Study_SA__c, Study_AS__c, Centro_encuesta__c, Car_type__c,Serial_number__c, SurveyTech__c, IntType__c, TypeDesCode__c, Code__c,
                                                      Language__c, Brand__c, BrandCode__c,Concesionario__c, Dias_espera_primer_envio__c, Activa__c, Tipo_de_encuesta__c
                                     				  FROM Gestion_encuesta__c WHERE Id in :lstId LIMIT 2000];
            
            for (Gestion_encuesta__c gEncuesta : lstGEncuesta) {
                mapIdToGEncuesta.put(gEncuesta.Id, gEncuesta);
            }
        }
        
        return mapIdToGEncuesta;
    }
    
    //UTILIZADO PARA CEM MANUALES
    public Static Map<String,List<Gestion_encuesta__c>> getGestionEncuestaByMarcaConcesionario(List<String> marcas, List<String> concesionarios){
        Map<String,List<Gestion_encuesta__c>> mapMarcaConcesionarioToGestionEncuesta = new Map<String,List<Gestion_encuesta__c>>();
        if(!marcas.isEmpty() && !concesionarios.isEmpty()){
            for (Gestion_encuesta__c gEncuesta : [SELECT  Id,Name, Concesionario_encuesta__c, Genera_encuesta_externa__c, URL_SA__c, URL_AS__c,Hora_envio__c,
                                                      Dias_espera_segundo_envio__c, Dias_espera_desde_ultimo_envio__c, Dias_validez__c,Project__c, Country__c, Numeric_country_code__c,
                                                      Study_SA__c, Study_AS__c, Centro_encuesta__c, Car_type__c,Serial_number__c, SurveyTech__c, IntType__c, TypeDesCode__c, Code__c,
                                                      Language__c, Brand__c, BrandCode__c,Concesionario__c, Dias_espera_primer_envio__c, Activa__c, Tipo_de_encuesta__c
                                     				  FROM Gestion_encuesta__c WHERE Brand__c in :marcas AND Concesionario_encuesta__c in :Concesionarios AND Activa__c = true LIMIT 2000]) {
                          String clave = gEncuesta.Brand__c+'/'+gEncuesta.Concesionario_encuesta__c;
                       	  List<Gestion_encuesta__c> gEncuestas = mapMarcaConcesionarioToGestionEncuesta.containsKey(clave)?mapMarcaConcesionarioToGestionEncuesta.get(clave):new List<Gestion_encuesta__c>();
                          gEncuestas.add(gEncuesta);
                          mapMarcaConcesionarioToGestionEncuesta.put(clave, gEncuestas);                                
            }
        }
        return mapMarcaConcesionarioToGestionEncuesta;
    }
   
}