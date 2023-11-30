public class NBK_VoiceCallTriggerController extends TriggerHandler {
    private Map<Id, VoiceCall> mTriggerNew;
    public Map<Id, VoiceCall> mTriggerOld;
    public List<VoiceCall> lTriggerNew;
    private List<VoiceCall> lTriggerOld;

    public NBK_VoiceCallTriggerController(){
        this.mTriggerNew = (Map<Id, VoiceCall>) Trigger.newMap;
        this.mTriggerOld = (Map<Id, VoiceCall>) Trigger.oldMap;
        this.lTriggerNew = (List<VoiceCall>) Trigger.new;
        this.lTriggerOld = (List<VoiceCall>) Trigger.old;
    }

    public override void beforeInsert(){
        List<VoiceCall> lOutboundVoiceCalls = new List<VoiceCall>();

        for(VoiceCall vc : lTriggerNew){
            if(vc.CallType == 'Outbound'){
                lOutboundVoiceCalls.add(vc);
            }
        }

        NBK_VoiceCallTriggerHelper.setVoiceCallOwners(lTriggerNew);

        if(!lOutboundVoiceCalls.isEmpty()){
            NBK_VoiceCallTriggerHelper.setRelatedCallTasks(lOutboundVoiceCalls);
        }

        NBK_VoiceCallTriggerHelper.setPostSalesTopic(lTriggerNew);
    }

    public override void afterInsert(){
        List<VoiceCall> lOutboundVoiceCallsToProcess = new List<VoiceCall>();

        for(VoiceCall vc : lTriggerNew){
            if(vc.Call_Task__c != null){
                lOutboundVoiceCallsToProcess.add(vc);
            }
        }

        if(!lOutboundVoiceCallsToProcess.isEmpty()){
            NBK_VoiceCallTriggerHelper.incrementCallAttemps(lOutboundVoiceCallsToProcess);
        }
    }

    public override void afterUpdate(){
        List<VoiceCall> lOutboundVoiceCallsToComplete = new List<VoiceCall>();

        for(VoiceCall vc : lTriggerNew){
            if(vc.CallEndDateTime != null && vc.CallEndDateTime != mTriggerOld.get(vc.Id).CallEndDateTime){
                lOutboundVoiceCallsToComplete.add(vc);
            }
        }

        if(!lOutboundVoiceCallsToComplete.isEmpty()){
            NBK_VoiceCallTriggerHelper.closeRelatedCallTasks(lOutboundVoiceCallsToComplete);
        }
    }
}