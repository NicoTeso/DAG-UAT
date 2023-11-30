trigger CampaniaVehiculo on Campania_Vehiculo__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    TriggerFactory.createHandler(Campania_Vehiculo__c.sObjectType);
}