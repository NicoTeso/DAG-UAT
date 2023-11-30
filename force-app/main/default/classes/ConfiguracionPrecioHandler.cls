public class ConfiguracionPrecioHandler implements ITriggerHandler {
    private TriggerExecutionHelper infoTrigger = new TriggerExecutionHelper();
    Map<String,List<Planificacion_Servicio__c>> mapPlanServicioByCPrecio = new Map<String,List<Planificacion_Servicio__c>>();
    Map<String,Planificacion_Servicio__c> mapPServiceToUpdate = new Map<String,Planificacion_Servicio__c>();
    public ConfiguracionPrecioHandler(Schema.sObjectType soType) {
        InfoTrigger.setTipoHandler(soType);
    }
    
    public TriggerExecutionHelper getInfo() {
        return infoTrigger;
    }
    
    public void bulkBefore() {
    }

    public void bulkAfter() {
        mapPServiceToUpdate.clear();
        if (Trigger.new != null) {
            Set<String> conjId = new Set<String>();
            
            for (SObject objeto : Trigger.New) {
                Configuracion_precio__c cPrecio = (Configuracion_precio__c) objeto;
                conjId.add(cPrecio.Id);
            }
            mapPlanServicioByCPrecio = PlanificacionServicioGateway.getPlanServiceByConfiguracionPrecioId(conjId);
		}

        
    }

    public void beforeInsert(sObject so) {
    }
    
    public void beforeUpdate(sObject old, sObject so) {
    }
    
    public void beforeDelete(sObject so) {}
    
    public void afterInsert(sObject so) {
    }
    
    public void afterUpdate(sObject old, sObject so) {
        Configuracion_precio__c cPrecio = (Configuracion_precio__c) so;
        Configuracion_precio__c cPrecioOld = (Configuracion_precio__c) old;
        if(cPrecio.Precio__c != cPrecioOld.Precio__c && mapPlanServicioByCPrecio.containsKey(cPrecio.Id)){
            List<Planificacion_Servicio__c> listPService = mapPlanServicioByCPrecio.get(cPrecio.Id);
            for(Planificacion_Servicio__c pService : listPService){
                	pService.Precio__c = cPrecio.Precio__c;
                	mapPServiceToUpdate.put(pService.Id, pService);
                
            }
        }
    }
    
    public void afterDelete(sObject so) {}
    
    public void andFinally() {
        
        if(!mapPServiceToUpdate.isEmpty()){
            upsert mapPServiceToUpdate.values();
        }
      
    }
}