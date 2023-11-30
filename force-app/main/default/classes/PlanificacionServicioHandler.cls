public class PlanificacionServicioHandler implements ITriggerHandler {
    private TriggerExecutionHelper infoTrigger = new TriggerExecutionHelper();
    public Group colaGestion = new Group();
    public User usuarioInt;
    public User usuarioACT;
    public Map<string,Map<string, Pase_de_taller__c>> mapPaseTallerVehiculoOS = new Map<string,Map<string,Pase_de_taller__c>>();
    
    public PlanificacionServicioHandler(Schema.sObjectType soType) {
        InfoTrigger.setTipoHandler(soType);
    }
    
    public TriggerExecutionHelper getInfo() {
        return infoTrigger;
    }
    public void bulkBefore() {
        colaGestion = GroupGateway.getGroupByDeveloperName('Gestion_de_Servicio');
        usuarioInt = CacheUtil.getIntegrador();
        usuarioACT = CacheUtil.getCurrentUser();
        mapPaseTallerVehiculoOS.clear();
        if (Trigger.new != null) {
            List<String> listvehiculoId = new List<String>();
            for(SObject objeto :Trigger.new){
                Planificacion_Servicio__c pServicio = (Planificacion_Servicio__c) objeto;
                
                if (pServicio.Orden_SIMA__c != null) {
                    listvehiculoId.add(pServicio.Vehiculo__c);
                }
            }
            if(!listvehiculoId.isEmpty()){
              	mapPaseTallerVehiculoOS = PaseTallerGateway.getPaseTallerByVehiculoIdOS(listvehiculoId);
            }
        }    
    }
    public void bulkAfter() {}
    public void beforeInsert(sObject so) {}
    public void beforeUpdate(sObject old, sObject so){
        String userid = UserInfo.getUserId();
        
        boolean Asignar = true;
        if (usuarioACT.Profile.Name == 'System Administrator' ||
            usuarioACT.Profile.Name == 'Integracion') {
	        Asignar = false;
        }
                
        Planificacion_Servicio__c pServicio = (Planificacion_Servicio__c) so;
        Planificacion_Servicio__c pServicioOld = (Planificacion_Servicio__c) old;
        if(pServicio.Estado__c.equalsIgnoreCase('Cerrado')){
            if(pServicio.OwnerId == colaGestion.Id && Asignar){
                pServicio.addError('No se puede cerrar, si no esta asignado');
            }
            
        }
        else if(pServicioOld.Estado__c.equalsIgnoreCase(Label.EstadoNoAplica) && 
                userid != usuarioInt.Id){
            	pServicio.addError('No puedes modificar esta planificación de servicio ya que no aplica.');
        }
        else {
            if(pServicio.OwnerId == colaGestion.Id && Asignar){
                pServicio.OwnerId = userId;
                pServicio.Estado__c = pServicio.Estado__c.equalsIgnoreCase('Sin asignar')?'Asignado':pServicio.Estado__c;
            }
        }

        if (pServicio.FirstCallDate__c == null && pServicio.Numero_de_llamadas__c == '1'){
            pServicio.FirstCallDate__c = datetime.now();  
        }

        if (pServicio.SecondCallDate__c == null && pServicio.Numero_de_llamadas__c == '2'){
            pServicio.SecondCallDate__c = datetime.now();
        }

        if (pServicio.ThirdCallDate__c == null && pServicio.Numero_de_llamadas__c == '3'){
            pServicio.ThirdCallDate__c = datetime.now();
        }

        if (pServicio.FourthCallDate__c == null && pServicio.Numero_de_llamadas__c == '4'){
            pServicio.FourthCallDate__c = datetime.now();   
        }

        if (pServicio.FifthCallDate__c == null && pServicio.Numero_de_llamadas__c == '5'){
            pServicio.FifthCallDate__c = datetime.now(); 
        }
        
        if ((pServicio.Orden_SIMA__c != null && pServicio.Pase_de_taller__c == null) ||
            (pServicio.Orden_SIMA__c != pServicioOld.Orden_SIMA__c)){  
            pServicio.Pase_de_taller__c = null;
		    Map<String, Pase_de_taller__c> mapAux =  mapPaseTallerVehiculoOS.containsKey(pServicio.Vehiculo__c)
                    ? mapPaseTallerVehiculoOS.get(pServicio.Vehiculo__c) : new Map<String,Pase_de_taller__c>();
            if (mapAux.containsKey(pServicio.Orden_SIMA__c)) {
                pServicio.Pase_de_taller__c = mapAux.get(pServicio.Orden_SIMA__c).id;
            }
        }
        
    }
    public void beforeDelete(sObject so) {}
    public void afterInsert(sObject so) {}
    public void afterUpdate(sObject old, sObject so) {}
    public void afterDelete(sObject so) {}
    public void andFinally() {}

}