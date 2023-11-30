trigger AuxAccountTrigger on AuxAccount__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    TriggerFactory.createHandler(AuxAccount__c.sObjectType);
}