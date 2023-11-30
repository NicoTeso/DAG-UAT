trigger EncuestaTrigger on Encuesta__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    TriggerFactory.createHandler(Encuesta__c.sObjectType);
}