trigger ContratoRentingTrigger on Contrato_renting__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    TriggerFactory.createHandler(Contrato_renting__c.sObjectType);
}