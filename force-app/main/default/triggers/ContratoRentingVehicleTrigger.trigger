trigger ContratoRentingVehicleTrigger on Contrato_renting_vehiculo__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    TriggerFactory.createHandler(Contrato_renting_vehiculo__c.sObjectType);
}