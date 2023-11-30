trigger InvalidEmailTrigger on Invalid_Emails__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    TriggerFactory.createHandler(Invalid_Emails__c.sObjectType);
}