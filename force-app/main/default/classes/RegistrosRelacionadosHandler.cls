public with sharing class RegistrosRelacionadosHandler implements ITriggerHandler {
    private TriggerExecutionHelper infoTrigger = new TriggerExecutionHelper();
    
    public Map<String,List<Registros_Relacionados__c>> mapRRByDestinoId = new Map<String,List<Registros_Relacionados__c>>();
    public List<Registros_Relacionados__c> listRRelacionadosToUpdate = new List<Registros_Relacionados__c>();
    public RegistrosRelacionadosHandler(Schema.sObjectType soType) {
        InfoTrigger.setTipoHandler(soType);
    }
    
    public TriggerExecutionHelper getInfo() {
        return infoTrigger;
    }
    
    public void bulkBefore() {
    
    }

    public void bulkAfter() {
        mapRRByDestinoId.clear();
        listRRelacionadosToUpdate.clear();
        List<String> listROSetId = new List<String>();
        if(Trigger.new != null){
            for (SObject so : Trigger.new){
                Registros_Relacionados__c rrelacionados =(Registros_Relacionados__c) so;
                if(!String.isBlank(rrelacionados.Registro_Origen__c)){
                    listROSetId.add(rrelacionados.Registro_Origen__c);
                }
            }
            if(!listROSetId.isEmpty()){
                mapRRByDestinoId = RegistrosRelacionadosGateway.getRRDestinosByRegistroDestinoId(listROSetId);
            }
        }
    }

    public void beforeInsert(sObject so) {}
    
    public void beforeUpdate(sObject old, sObject so) {}
    
    public void beforeDelete(sObject so) {}
    
    public void afterInsert(sObject so) {
        Registros_Relacionados__c rRelacionados =(Registros_Relacionados__c) so;
            
        if(!String.isBlank(rRelacionados.Registro_Origen__c) && mapRRByDestinoId.containsKey(rRelacionados.Registro_Origen__c)){
            List<Registros_Relacionados__c> listRR = mapRRByDestinoId.get(rRelacionados.Registro_Origen__c);
            for(Registros_Relacionados__c rr :listRR){
                rr.Registro_Destino__c = rRelacionados.Registro_Destino__c;
                listRRelacionadosToUpdate.add(rr);
            }
        }
        
    }
    
    public void afterUpdate(sObject old, sObject so) {}
    
    public void afterDelete(sObject so) {
        
    }
    
    public void andFinally() {
        if(!listRRelacionadosToUpdate.isEmpty()){
            upsert listRRelacionadosToUpdate;
        }
        
    }
}