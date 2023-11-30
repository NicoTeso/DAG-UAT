public with sharing class ContactHandler implements ITriggerHandler {
    private TriggerExecutionHelper infoTrigger = new TriggerExecutionHelper();
    
    public List<Delete_Account_Marketing__c> listDeleteAccToUpsert = new List<Delete_Account_Marketing__c>();
    
    public ContactHandler(Schema.sObjectType soType) {
        InfoTrigger.setTipoHandler(soType);
    }
    
    public TriggerExecutionHelper getInfo() {
        return infoTrigger;
    }
    
    public void bulkBefore() {
    
    }

    public void bulkAfter() {
        listDeleteAccToUpsert.clear();
    }

    public void beforeInsert(sObject so) {
    }
    
    public void beforeUpdate(sObject old, sObject so) {
    }
    
    public void beforeDelete(sObject so) {
        
    }
    
    public void afterInsert(sObject so) {
    }
    
    public void afterUpdate(sObject old, sObject so) {
    }
    
    public void afterDelete(sObject so) {
        Contact contacto = (Contact) so;
        Delete_Account_Marketing__c dam = new Delete_Account_Marketing__c();
        dam.RecordId__c = contacto.Id;
        dam.Fecha_eliminacion__c = Date.today().addDays(45);
        listDeleteAccToUpsert.add(dam);
        
    }
    
    public void andFinally() {
        
        if(!listDeleteAccToUpsert.isEmpty()){
            upsert listDeleteAccToUpsert;
        }
    }
}