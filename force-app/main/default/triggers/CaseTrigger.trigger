/**
 * @description  : 
 * @author       : development@nubika.com 
**/
trigger CaseTrigger on Case (after delete, after insert, after undelete, after update, before delete, before insert, before update) {

    if (TriggerHandler.areDisabled) return; 
    
    TriggerFactory.createHandler(Case.sObjectType);

    NBK_Triggers__c skipper = NBK_Triggers__c.getInstance();
    if(skipper == null || !skipper.Skip_Case_Trigger__c) {
        new NBK_CaseHandler().run();
    }
}