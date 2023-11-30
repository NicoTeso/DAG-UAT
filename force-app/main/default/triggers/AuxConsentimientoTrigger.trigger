trigger AuxConsentimientoTrigger on AuxConsentimiento__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    TriggerFactory.createHandler(AuxConsentimiento__c.sObjectType);
}