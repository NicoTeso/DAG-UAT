public with sharing class DuplicateRecordItemHandler implements ITriggerHandler {
    private TriggerExecutionHelper infoTrigger = new TriggerExecutionHelper();
    
    public Map<String,DuplicateRecordItem> mapDRItemPrincipalByDRSetId = new Map<String,DuplicateRecordItem>();
    public List<Registros_Relacionados__c> listRegistroRelacionadosToUpsert = new List<Registros_Relacionados__c>();
    public Map<String,Account> mapAccountById = new Map<String,Account>();
    public DuplicateRecordItemHandler(Schema.sObjectType soType) {
        InfoTrigger.setTipoHandler(soType);
    }
    
    public TriggerExecutionHelper getInfo() {
        return infoTrigger;
    }
    
    public void bulkBefore() {
    
    }

    public void bulkAfter() {
        system.debug('Inicia el After');
        mapDRItemPrincipalByDRSetId.clear();
        listRegistroRelacionadosToUpsert.clear();
        List<String> listDRSetId = new List<String>();
        List<String> listAccountId = new List<String>();
        if(Trigger.old != null){
            for (SObject so : Trigger.old){
                DuplicateRecordItem dri =(DuplicateRecordItem) so;
                if(!String.isBlank(dri.DuplicateRecordSetId)){
                    listDRSetId.add(dri.DuplicateRecordSetId);
                }
                if(Account.sObjectType == dri.RecordId.getSObjectType()){
                    listAccountId.add(dri.RecordId);
                }
                
            }
            if(!listDRSetId.isEmpty()){
                mapDRItemPrincipalByDRSetId = DuplicateRecordItemGateway.getFirstDRItemByDRSetId(listDRSetId);
                for(DuplicateRecordItem driP :mapDRItemPrincipalByDRSetId.values()){
                    if(Account.sObjectType == driP.RecordId.getSObjectType()){
                   		listAccountId.add(driP.RecordId);
                	}
                }
            }
            if(!listAccountId.isEmpty()){
                mapAccountById = AccountGateway.getAllAccountById(listAccountId);
            }

        }
        
    }

    public void beforeInsert(sObject so) {}
    
    public void beforeUpdate(sObject old, sObject so) {}
    
    public void beforeDelete(sObject so) {}
    
    public void afterInsert(sObject so) {}
    
    public void afterUpdate(sObject old, sObject so) {}
    
    public void afterDelete(sObject so) {
        DuplicateRecordItem dri = (DuplicateRecordItem) so;
        system.debug('entra a record set Item');
        system.debug('dri.DuplicateRecordSetId: '+dri.DuplicateRecordSetId);
        system.debug('mapDRItemPrincipalByDRSetId: '+mapDRItemPrincipalByDRSetId);
        if(!String.isBlank(dri.DuplicateRecordSetId) && mapDRItemPrincipalByDRSetId.containsKey(dri.DuplicateRecordSetId)){
            DuplicateRecordItem driPrincipal = mapDRItemPrincipalByDRSetId.get(dri.DuplicateRecordSetId);
            
            Registros_Relacionados__c rrelacionados = new Registros_Relacionados__c();
            if(Account.sObjectType == dri.RecordId.getSObjectType()){
                system.debug('entra primer if');
                    Account cuenta = mapAccountById.get(dri.RecordId);
                	if(cuenta.IsPersonAccount){
                    	rrelacionados.Registro_Origen__c = cuenta.PersonContactId;
                	}
                	else {
                    	rrelacionados.Registro_Origen__c = dri.RecordId;
                	}
                }
            else{
                rrelacionados.Registro_Origen__c = dri.RecordId;
            }
            
            if(Account.sObjectType == driPrincipal.RecordId.getSObjectType()){
                system.debug('entra segundo if');
                    Account cuenta = mapAccountById.get(driPrincipal.RecordId);
                	if(cuenta.IsPersonAccount){
                    	rrelacionados.Registro_Destino__c = cuenta.PersonContactId;
                	}
                	else {
                    	rrelacionados.Registro_Destino__c = driPrincipal.RecordId;
                	}
                }
            else{
                rrelacionados.Registro_Destino__c = driPrincipal.RecordId;
            }
            
            listRegistroRelacionadosToUpsert.add(rrelacionados);
        }
        
        
    }
    
    public void andFinally() {
        
        if(!listRegistroRelacionadosToUpsert.isEmpty()){
            upsert listRegistroRelacionadosToUpsert;
        }
    }
}