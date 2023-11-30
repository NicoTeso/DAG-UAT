public without sharing class NBK_VoiceCallManager {

    public static List<VoiceCall> relateCallTaskWithVoiceCall(List<VoiceCall> lVoiceCalls){

        Set<String> phoneVoiceCalls = new Set<String>();
        Set<Id> ownerVoiceCalls = new Set<Id>();
        String dateCTask;
        String cTaskInMin;
        String dateVcInMin;
        String vcInMin;

        for(VoiceCall vc : lVoiceCalls){
            phoneVoiceCalls.add(vc.ToPhoneNumber); 
            ownerVoiceCalls.add(vc.OwnerId); 
        }

        List <Call_Task__c> lCTask = [
            SELECT Id, RecordType.Name, CreatedDate, LastModifiedDate
            FROM Call_Task__c 
            WHERE Target_Phone__c IN :phoneVoiceCalls
            AND OwnerId IN :ownerVoiceCalls
        ]; 

        for(Call_Task__c cTask : lCTask){		
            for(VoiceCall vc : lVoiceCalls){
                dateCTask = string.valueOfGmt(cTask.CreatedDate);
                cTaskInMin = dateCTask.substring(0, 16);
                
                dateVcInMin = string.valueOfGmt(vc.CreatedDate);
                vcInMin	=	dateVcInMin.substring(0, 16);
                            
                if(cTaskInMin == vcInMin){
                    vc.Call_Task__c = cTask.Id;
                }		
            }  
        }

        System.debug('NBK_VoiceCallManager - relateCallTaskWithVoiceCall() - lVoiceCalls: ' + lVoiceCalls.size());

        try {
            update lVoiceCalls;
        } catch(Exception e) {
            System.debug('### NBK_VoiceCallManager - relateCallTaskWithVoiceCall() - error: ' + e);
        }

        return lVoiceCalls;
    }

    public static List<VoiceCall> searchVoiceCallWithFromPhoneNumber(List<VoiceCall> lVC){

        List<VoiceCall> lVoiceCalls = new List<VoiceCall>();

        for(VoiceCall vc : lVC){
            if (vc.Call_Task__c == null) {
                lVoiceCalls.add(vc);
            }
        }

        return lVoiceCalls;
    }
    
    public static Map<Id,Call_Task__c> createCallTask(List<VoiceCall> lVoiceCalls){

        Map<Id, Call_Task__c> mCallTask = new Map<Id, Call_Task__c>();

        for(VoiceCall vc : lVoiceCalls){
            if(vc.FromPhoneNumber__c != null && vc.Call_Task__c == null){
                Call_Task__c callTask = new Call_Task__c(
                    OwnerId = vc.OwnerId,
                    Status__c = 'Completada',
                    Target_Phone__c = vc.FromPhoneNumber__c,
                    Client__c = vc.Client__c
                );
                
                mCallTask.put(vc.Id, callTask);
            }
        }
        try {
            insert mCallTask.values();
        } catch(Exception e) {
            System.debug('### NBK_VoiceCallManager - createCallTask - error: ' + e);
        }
        return mCallTask;
    }

    public static List<VoiceCall> relateCallTaskWithFromPhoneNumber(List<VoiceCall> lVoiceCalls,  Map<Id, Call_Task__c> mCallTask){

        for(VoiceCall vc : lVoiceCalls){
            for (Id vcIdRelated : mCallTask.keySet()) {           
                if(vc.Id == vcIdRelated){
                    vc.Call_Task__c = mCallTask.get(vcIdRelated).Id;
                }
            }
        }

        System.debug('NBK_VoiceCallManager - relateCallTaskWithFromPhoneNumber() - lVoiceCalls.size(): ' + lVoiceCalls.size());

        try {
            update lVoiceCalls;
            System.debug('NBK_VoiceCallManager - relateCallTaskWithFromPhoneNumber() - lVoiceCalls: ' + lVoiceCalls);
        } catch(Exception e) {
            System.debug('### NBK_VoiceCallManager - relateCallTaskWithFromPhoneNumber() - error: ' + e);
        }

        return lVoiceCalls;
    }
}