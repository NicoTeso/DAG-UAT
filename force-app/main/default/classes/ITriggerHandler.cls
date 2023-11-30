public interface ITriggerHandler {
    TriggerExecutionHelper getInfo();
    void bulkBefore();
 	void bulkAfter();
    void beforeInsert(sObject so);
    void beforeUpdate(sObject old, sObject so);
    void beforeDelete(sObject so);
    void afterInsert(sObject so);
    void afterUpdate(sObject old, sObject so);
    void afterDelete(sObject so);
    void andFinally();
}