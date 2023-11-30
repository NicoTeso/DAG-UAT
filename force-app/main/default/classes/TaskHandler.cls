public class TaskHandler implements ITriggerHandler {
    private TriggerExecutionHelper infoTrigger = new TriggerExecutionHelper();
    
    public TaskHandler(Schema.sObjectType soType) {
        InfoTrigger.setTipoHandler(soType);
    }
    
    public TriggerExecutionHelper getInfo() {
        return infoTrigger;
    }
    
    public void bulkBefore() {}
    
    public void bulkAfter() {}
    
    public void beforeInsert(sObject so) {}
    
    public void beforeUpdate(sObject old, sObject so) {}
    
    public void beforeDelete(sObject so) {}
    
    public void afterInsert(sObject so) {}
    
    public void afterUpdate(sObject old, sObject so) {}
    
    public void afterDelete(sObject so) {}
    
    public void andFinally() {}
}