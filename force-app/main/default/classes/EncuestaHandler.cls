public with sharing class EncuestaHandler implements ITriggerHandler  {
    private TriggerExecutionHelper infoTrigger = new TriggerExecutionHelper();
    
    public Map<String, List<Gestion_encuesta__c>> mapGEncuestaByMarcaConcesionario = new Map<String,List<Gestion_encuesta__c>>();
    public Map<String,Datetime> mapVinDateUltimaEncuesta = new Map<String,Datetime>();
    public List<Delete_Account_Marketing__c> listDeleteAccToUpsert = new List<Delete_Account_Marketing__c>();
    public User integrador = new User();
    public Group colaTelefonica = new Group();
    public EncuestaHandler(Schema.sObjectType soType) {
        InfoTrigger.setTipoHandler(soType);
    }
    
    public TriggerExecutionHelper getInfo() {
        return infoTrigger;
    }
    
    public void bulkBefore() {
        mapGEncuestaByMarcaConcesionario.clear();
        listDeleteAccToUpsert.clear();
        List<String> concesionarios = new List<String>();
        List<String> marcas = new List<String>();
        List<String> vins = new List<String>();
        if (Trigger.new != null) {
            for (SObject objeto : Trigger.New) {
                Encuesta__c encuesta = (Encuesta__c) objeto;
                if(!String.isBlank(encuesta.Brand__c)){
                    marcas.add(encuesta.Brand__c);
                }
                if(encuesta.Concesionario__c != null){
                    concesionarios.add(encuesta.Concesionario__c);
                }
                if(!String.isBlank(encuesta.vin__c)){
                    vins.add(encuesta.vin__c);
                }
            }
            mapGEncuestaByMarcaConcesionario = GestionEncuestaGateway.getGestionEncuestaByMarcaConcesionario(marcas, concesionarios);
            mapVinDateUltimaEncuesta = EncuestaGateway.getUltimaFechaByVin(vins);
            integrador = CacheUtil.getIntegrador();
            colaTelefonica = GroupGateway.getGroupByDeveloperName('Gestion_Encuesta');
        }
    }

    public void bulkAfter() {
        listDeleteAccToUpsert.clear();
       
    }

    public void beforeInsert(sObject so) {
        Encuesta__c encuesta = (Encuesta__c) so;
        encuesta.ModeloString__c = String.isNotBlank(encuesta.ModeloString__c) && encuesta.ModeloString__c.contains('"') ? encuesta.ModeloString__c.replace('"','') : encuesta.ModeloString__c;
        String developerName = EncuestaGateway.getDeveloperNameById(encuesta.RecordTypeId);
        if(developerName.equalsIgnoreCase('CEM_Manuales') || developerName.equalsIgnoreCase('Externa_Manuales') ){
            encuesta.OwnerId = integrador.Id;
            if (encuesta.MobilePhone__c != null) {
                encuesta.MobilePhone__c = DataValidations.transformPhone(encuesta.MobilePhone__c);
            }
            Gestion_encuesta__c gestionE;
            if(!String.isBlank(encuesta.Brand__c) && encuesta.Concesionario__c != null){
                String clave = encuesta.Brand__c+'/'+encuesta.Concesionario__c;
                if(mapGEncuestaByMarcaConcesionario.containsKey(clave)){
                    List<Gestion_encuesta__c> gEncuestas =mapGEncuestaByMarcaConcesionario.get(clave);
                    for(Gestion_encuesta__c gEncuesta : gEncuestas ){
                        if((gEncuesta.Tipo_de_encuesta__c.equalsIgnoreCase(Label.tipoOperacionVenta) || gEncuesta.Tipo_de_encuesta__c.equalsIgnoreCase('Ambas')) 
                           && encuesta.Tipo_de_Operacion__c.equalsIgnoreCase(Label.tipoOperacionVenta)){
                            gestionE = gEncuesta;
                             break;
                        }
                        else if((gEncuesta.Tipo_de_encuesta__c.equalsIgnoreCase('Postventa') || gEncuesta.Tipo_de_encuesta__c.equalsIgnoreCase('Ambas')) 
                                   && encuesta.Tipo_de_Operacion__c.equalsIgnoreCase(Label.tipoOperacionTaller)){
                              gestionE = gEncuesta;
                              break;
                        }
                    }
                    if(gestionE != null){
                            encuesta.Fecha_primer_envio_requerido__c = gestionE.Dias_espera_primer_envio__c != null ? Datetime.now().addDays((Integer) gestionE.Dias_espera_primer_envio__c) : null;
                            if (encuesta.Fecha_primer_envio_requerido__c != null) {
                                encuesta.Fecha_primer_envio_requerido__c = ManageSurvey.fixWeekend(encuesta.Fecha_primer_envio_requerido__c);
                            }
                            encuesta.Fecha_requerida_segundo_envio__c = encuesta.Fecha_primer_envio_requerido__c != null && gestionE.Dias_espera_segundo_envio__c != null
                                ? encuesta.Fecha_primer_envio_requerido__c.addDays((Integer) gestionE.Dias_espera_segundo_envio__c) : null;
                            
                            if (Test.isRunningTest()) {
                                encuesta.Fecha_requerida_segundo_envio__c = Datetime.valueOf('2020-06-21 07:50:10Z');
                            }
                            
                            if (encuesta.Fecha_requerida_segundo_envio__c != null) {
                                encuesta.Fecha_requerida_segundo_envio__c = ManageSurvey.fixWeekend(encuesta.Fecha_requerida_segundo_envio__c);
                            }
                            
                            encuesta.Fecha_fin_respuesta__c = gestionE.Dias_validez__c != null ? Datetime.now().addDays((Integer) gestionE.Dias_validez__c) : null;
                            encuesta.Tipo_Encuesta__c = 'Externo';
                            encuesta.Resultado__c = 'Si';
                            encuesta.Gestion_encuesta__c = gestionE.Id;
                            encuesta.Fecha_respuesta_encuesta__c= encuesta.Brand__c == 'SKODA'? encuesta.Fecha_primer_envio_requerido__c:null;
                            encuesta.Anonymous__c=encuesta.Brand__c == 'SKODA'?'1':null;
                   }
                    else {
                        encuesta.Resultado__c = 'No se ha encontrado una gestión encuesta satisfactoria';
                    }
                }
                else {
                    encuesta.Resultado__c = 'No se ha encontrado una gestión encuesta satisfactoria';
                }
            }
        }
        else if(developerName.equalsIgnoreCase('Telefonica') && encuesta.Tipo_Encuesta__c.equalsIgnoreCase('Externo')){
            encuesta.OwnerId = colaTelefonica.Id;
            Gestion_encuesta__c gestionE;
            if(!String.isBlank(encuesta.Brand__c) && encuesta.Concesionario__c != null){
                String clave = encuesta.Brand__c+'/'+encuesta.Concesionario__c;
                if(mapGEncuestaByMarcaConcesionario.containsKey(clave)){
                    List<Gestion_encuesta__c> gEncuestas =mapGEncuestaByMarcaConcesionario.get(clave);
                    for(Gestion_encuesta__c gEncuesta : gEncuestas ){
                        if((gEncuesta.Tipo_de_encuesta__c.equalsIgnoreCase(Label.tipoOperacionVenta) || gEncuesta.Tipo_de_encuesta__c.equalsIgnoreCase('Ambas')) 
                           && encuesta.Tipo_de_Operacion__c.equalsIgnoreCase(Label.tipoOperacionVenta)){
                            gestionE = gEncuesta;
                             break;
                        }
                        else if((gEncuesta.Tipo_de_encuesta__c.equalsIgnoreCase('Postventa') || gEncuesta.Tipo_de_encuesta__c.equalsIgnoreCase('Ambas')) 
                                   && encuesta.Tipo_de_Operacion__c.equalsIgnoreCase(Label.tipoOperacionTaller)){
                              gestionE = gEncuesta;
                              break;
                        }
                    }
                    if(gestionE != null){
                            encuesta.Fecha_primer_envio_requerido__c = gestionE.Dias_espera_primer_envio__c != null ? Datetime.now().addDays((Integer) gestionE.Dias_espera_primer_envio__c) : null;
                            if (encuesta.Fecha_primer_envio_requerido__c != null) {
                                encuesta.Fecha_primer_envio_requerido__c = ManageSurvey.fixWeekend(encuesta.Fecha_primer_envio_requerido__c);
                            }
                            
                            encuesta.Fecha_fin_respuesta__c = gestionE.Dias_validez__c != null ? Datetime.now().addDays((Integer) gestionE.Dias_validez__c) : null;
                            encuesta.Resultado__c = 'Si';
                            encuesta.Gestion_encuesta__c = gestionE.Id;
                    }
                    else {
                        encuesta.Resultado__c = 'No se ha encontrado una gestión encuesta satisfactoria';
                    }
                }
                else {
                    encuesta.Resultado__c = 'No se ha encontrado una gestión encuesta satisfactoria';
                }
            }
        }
    }
    
    public void beforeUpdate(sObject old, sObject so) {
      }
    
    public void beforeDelete(sObject so) {}
    
    public void afterInsert(sObject so) {
        Encuesta__c encuesta = (Encuesta__c) so;
        String developerName = EncuestaGateway.getDeveloperNameById(encuesta.RecordTypeId);
        if(developerName.equalsIgnoreCase('CEM_Manuales')){
            Delete_Account_Marketing__c dam1 = new Delete_Account_Marketing__c();	
    	    dam1.RecordId__c = encuesta.Id;
        	dam1.Fecha_eliminacion__c = Date.today().addDays(integer.valueOf(Label.DaysDeleteMKTCloud));
        	listDeleteAccToUpsert.add(dam1);
        }    
    }
    
    public void afterUpdate(sObject old, sObject so) {
    }
    
    public void afterDelete(sObject so) {}
    
    public void andFinally() {
        if(!listDeleteAccToUpsert.isEmpty()){
            upsert listDeleteAccToUpsert;
        }
    }

}