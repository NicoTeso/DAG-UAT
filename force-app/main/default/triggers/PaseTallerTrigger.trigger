trigger PaseTallerTrigger on Pase_de_taller__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    TriggerFactory.createHandler(Pase_de_taller__c.sObjectType);
}