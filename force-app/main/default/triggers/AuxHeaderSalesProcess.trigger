trigger AuxHeaderSalesProcess on AuxHeaderSalesProcess__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    TriggerFactory.createHandler(AuxHeaderSalesProcess__c.sObjectType);
}