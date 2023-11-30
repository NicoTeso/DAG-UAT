/**
 * @description       : 
 * @author            : alberto.martinez@nubika.com
 * @group             : 
 * @last modified on  : 11-15-2021
 * @last modified by  : alberto.martinez@nubika.com
**/
public class NBK_MessagingEndUserTriggerHandler extends TriggerHandler{

    @TestVisible private Map<Id, MessagingEndUser> mTriggerNew;
    @TestVisible private Map<Id, MessagingEndUser> mTriggerOld;
    @TestVisible private List<MessagingEndUser> lTriggerNew;
    @TestVisible private List<MessagingEndUser> lTriggerOld;

    public NBK_MessagingEndUserTriggerHandler(){
        this.mTriggerNew = (Map<Id, MessagingEndUser>) Trigger.newMap;
        this.mTriggerOld = (Map<Id, MessagingEndUser>) Trigger.oldMap;
        this.lTriggerNew = (List<MessagingEndUser>) Trigger.new;
        this.lTriggerOld = (List<MessagingEndUser>) Trigger.old;
    }

    public override void afterInsert(){
        NBK_MessagingEndUserTriggerHandlerHelper.mappingLeadsByPhone(lTriggerNew, new Map<Id, MessagingEndUser>());
    }

    public override void afterUpdate(){
        NBK_MessagingEndUserTriggerHandlerHelper.mappingLeadsByPhone(lTriggerNew, mTriggerOld);
    }
}