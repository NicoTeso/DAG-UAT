trigger MessagingSessionTrigger on MessagingSession (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    TriggerFactory.createHandler(MessagingSession.sObjectType);
}