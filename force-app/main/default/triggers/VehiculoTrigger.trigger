trigger VehiculoTrigger on Vehiculo__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    TriggerFactory.createHandler(Vehiculo__c.sObjectType);
}