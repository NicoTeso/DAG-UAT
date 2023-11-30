public class CampaniaVehiculoHandler implements ITriggerHandler{
    private TriggerExecutionHelper infoTrigger = new TriggerExecutionHelper();
    public User usuarioInt;
        
    public CampaniaVehiculoHandler(Schema.sObjectType soType) {
        InfoTrigger.setTipoHandler(soType);
    }
    
    public TriggerExecutionHelper getInfo() {
        return infoTrigger;
    }
    
    public void bulkBefore() {
        usuarioInt = CacheUtil.getIntegrador();
       
    }
        
    public void bulkAfter() {
        
    }
    
    public void beforeInsert(sObject so) {
        Campania_Vehiculo__c campaignVehiculo = (Campania_Vehiculo__c) so;
        campaignVehiculo.Estado__c = 'Sin Asignar';
        campaignVehiculo.OwnerId = usuarioInt.Id;
    }
    
    public void beforeUpdate(sObject old, sObject so) {
        Campania_Vehiculo__c campaignVehiculo = (Campania_Vehiculo__c) so;
        Campania_Vehiculo__c campaignVehiculoOld = (Campania_Vehiculo__c) old;
        
        String userid = UserInfo.getUserId();
        User usuarioInt = CacheUtil.getIntegrador();
        if(userid != usuarioInt.Id){
            campaignVehiculo.OwnerId = userId;
        	campaignVehiculo.Estado__c = campaignVehiculo.Estado__c.equalsIgnoreCase('Sin asignar')?'Asignado':campaignVehiculo.Estado__c;
        }
        
        if(campaignVehiculoOld.Estado__c != null && campaignVehiculoOld.Estado__c.equalsIgnoreCase(Label.EstadoNoAplica) && userid != usuarioInt.Id){
            	campaignVehiculo.addError('No puedes modificar esta campaña ya que no aplica.');
        }
        
        if (campaignVehiculo.FirstCallDate__c == null && campaignVehiculo.Numero_de_llamadas__c == '1'){
            campaignVehiculo.FirstCallDate__c = datetime.now();  
        }

        if (campaignVehiculo.SecondCallDate__c == null && campaignVehiculo.Numero_de_llamadas__c == '2'){
            campaignVehiculo.SecondCallDate__c = datetime.now();
        }

        if (campaignVehiculo.ThirdCallDate__c == null && campaignVehiculo.Numero_de_llamadas__c == '3'){
            campaignVehiculo.ThirdCallDate__c = datetime.now();
        }

        if (campaignVehiculo.FourthCallDate__c == null && campaignVehiculo.Numero_de_llamadas__c == '4'){
            campaignVehiculo.FourthCallDate__c = datetime.now();   
        }

        if (campaignVehiculo.FifthCallDate__c == null && campaignVehiculo.Numero_de_llamadas__c == '5'){
            campaignVehiculo.FifthCallDate__c = datetime.now(); 
        }

    }
    
    public void beforeDelete(sObject so) {}
    
    public void afterInsert(sObject so) {
        
    }
    
    public void afterUpdate(sObject old, sObject so) {
        
    }

    public void afterDelete(sObject so) {}
    
    public void andFinally() {
        
        
    }
}