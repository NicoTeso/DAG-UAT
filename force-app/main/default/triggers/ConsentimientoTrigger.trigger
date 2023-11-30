trigger ConsentimientoTrigger on Consentimientos__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    TriggerFactory.createHandler(Consentimientos__c.sObjectType);
}