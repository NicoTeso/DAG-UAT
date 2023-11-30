trigger DetalleVenta on Detalle_venta__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    TriggerFactory.createHandler(Detalle_venta__c.sObjectType);
}