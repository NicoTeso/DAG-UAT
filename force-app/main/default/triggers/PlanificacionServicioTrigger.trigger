trigger PlanificacionServicioTrigger on Planificacion_Servicio__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    TriggerFactory.createHandler(Planificacion_Servicio__c.sObjectType);
}