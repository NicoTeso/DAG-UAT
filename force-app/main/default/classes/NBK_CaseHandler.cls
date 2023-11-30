/**
 * @description  : 
 * @author       : development@nubika.com 
**/
public class NBK_CaseHandler extends TriggerHandler {
    public Map<Id, Case> mTriggerNew;
    public Map<Id, Case> mTriggerOld;
    public List<Case> lTriggerNew;
    public List<Case> lTriggerOld;

    public NBK_CaseHandler(){
        this.mTriggerNew = (Map<Id, Case>) Trigger.newMap;
        this.mTriggerOld = (Map<Id, Case>) Trigger.oldMap;
        this.lTriggerNew = (List<Case>) Trigger.new;
        this.lTriggerOld = (List<Case>) Trigger.old;
    }

    public override void beforeUpdate(){
        NBK_CaseTriggerHandler.rescheduleCases(mTriggerOld, mTriggerNew);
        NBK_CaseTriggerHandler.scheduleAssignCaseIdToMessagingSession(mTriggerNew, mTriggerOld);
    }

    public override void afterInsert(){
        NBK_CaseTriggerHandler.proccessCasesForLeadManagement(lTriggerNew);
    }
}