public class NBK_VoiceCallTriggerHelper {

    public static void setVoiceCallOwners(List<VoiceCall> lTriggerNew){
        String defaultOwner = Default_Voice_Call_Owner__c.getInstance().Default_Owner_Username__c;
        User defaultUser = [SELECT Id FROM User WHERE UserName = :defaultOwner LIMIT 1];
        
        if(defaultUser != NULL){
            for(VoiceCall vc :lTriggerNew){
                vc.OwnerId = defaultUser.Id;
            }
        }
    }

    public static void setPostSalesTopic(List<VoiceCall> lTriggerNew){
        Map<String, String> mTopicByPhone = getTopicByPhoneMap();
        Set<Id> sRelatedCallTask = new Set<Id>();
        Map<Id, Call_Task__c> mRelatedCallTaskById;

        for(VoiceCall vc : lTriggerNew){
            if(vc.Call_Task__c != NULL){
                sRelatedCallTask.add(vc.Call_Task__c);

            } else if (vc.CallType == 'Inbound' && mTopicByPhone.get(vc.ToPhoneNumber) != NULL){
                vc.Topic__c = mTopicByPhone.get(vc.ToPhoneNumber);
            }
        }

        if(sRelatedCallTask != NULL){
            mRelatedCallTaskById = new Map<Id, Call_Task__c> (
                [SELECT Id, Brand_Phone__c FROM Call_Task__c WHERE Id IN : sRelatedCallTask]
            );

            for(VoiceCall vc : lTriggerNew){
                if(vc.Call_Task__c != NULL && mRelatedCallTaskById.get(vc.Call_Task__c) != NULL){
                    String brandPhone = mRelatedCallTaskById.get(vc.Call_Task__c).Brand_Phone__c;
                    if(mTopicByPhone.get(brandPhone) != NULL){
                        vc.Topic__c = mTopicByPhone.get(brandPhone);
                    }
                }
            }
        }
    }

    public static void incrementCallAttemps(List<VoiceCall> lVoiceCall){
        Set<Id> relatedIds = new Set<Id>();
        Set<Id> relatedCaseIds = new Set<Id>();

        for (VoiceCall vc : lVoiceCall) {
            relatedIds.add(vc.Call_Task__c);
        }

        List <Call_Task__c> lCallTasks = [SELECT Id, Case__c, Call_Attempts__c, Total_Call_Attempts__c FROM Call_Task__c WHERE Id IN : relatedIds];

        for (Call_Task__c callTask : lCallTasks) {
            callTask.Call_Attempts__c = (callTask.Call_Attempts__c != NULL) ? ++callTask.Call_Attempts__c : 1;
            if (callTask.Total_Call_Attempts__c != NULL){
                Integer totalCallAttemps = Integer.valueOf(callTask.Total_Call_Attempts__c); 
                totalCallAttemps++;
                callTask.Total_Call_Attempts__c = String.valueOf(totalCallAttemps);
            }

            if(callTask.Case__c != NULL){
                relatedCaseIds.add(callTask.Case__c);
            }
        }

        update lCallTasks;

        List <Case> lct = [SELECT Id, Total_Attempts__c, Numero_de_llamadas__c
                            FROM Case
                            WHERE Id = :relatedCaseIds LIMIT 1];

        for(Case cs : lct){
            cs.Total_Attempts__c += 1;
            Integer totalCalls = Integer.valueOf(cs.Numero_de_llamadas__c);
            totalCalls++;
            cs.Numero_de_llamadas__c = String.valueOf(totalCalls);
        }

        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = false;
        Database.update(lct, dmo);
    }

    public static void setRelatedCallTasks(List<VoiceCall> lVoiceCalls){
        Map<Id, Map<String, Call_Task__c>> mVoiceCallByCustomerOwner = new Map<Id, Map<String, Call_Task__c>>();
        Set<String> sCustomerPhones = new set<String>();
        Map<Id, Id> mUserByParticipant = new Map<Id, Id>();
        Set<Id> sCallUsers = new Set<Id>();
        Set<Id> sConversationParts = new Set<Id>();

        for(VoiceCall vc : lVoiceCalls){
            sCustomerPhones.add(vc.ToPhoneNumber);
            sConversationParts.add(vc.CallerId);
        }

        for(ConversationParticipant cp : [SELECT Id, ParticipantEntityId FROM ConversationParticipant WHERE Id IN :sConversationParts]){
            if(cp.ParticipantEntityId != null){
                mUserByParticipant.put(cp.Id, cp.ParticipantEntityId);
            }
        }

        List<Call_Task__c> lRelatedCallTasks = [
            SELECT
                Id,
                OwnerId,
                Target_Phone__c,
                LastModifiedDate,
                Brand_Phone__c,
                RecordTypeId,
                Lead__c,
                Client__c
            FROM Call_Task__c
            WHERE Target_Phone__c IN :sCustomerPhones
                AND OwnerId IN :mUserByParticipant.values()
                AND Status__c = :NBK_GlobalConstants.VC_IN_PROGRESS_STATUS
                AND (LastModifiedDate = TODAY OR CreatedDate = TODAY)
            ORDER BY LastModifiedDate DESC
        ];

        for(Call_Task__c callTask : lRelatedCallTasks){
            if(mVoiceCallByCustomerOwner.get(callTask.OwnerId) == NULL){
                mVoiceCallByCustomerOwner.put(callTask.OwnerId, new Map<String, Call_Task__c>());
            }

            if(mVoiceCallByCustomerOwner.get(callTask.OwnerId).get(callTask.Target_Phone__c) == NULL){
                mVoiceCallByCustomerOwner.get(callTask.OwnerId).put(callTask.Target_Phone__c, callTask);
            }
        }

        for(VoiceCall vc : lVoiceCalls){
            Id voiceCallUser = mUserByParticipant.get(vc.CallerId);
            if(mVoiceCallByCustomerOwner.get(voiceCallUser) != NULL && mVoiceCallByCustomerOwner.get(voiceCallUser).get(vc.ToPhoneNumber) != NULL){
                Call_Task__c relatedCallTask = mVoiceCallByCustomerOwner.get(voiceCallUser).get(vc.ToPhoneNumber);
                vc.Call_Task__c = relatedCallTask.Id;
                vc.Client__c = relatedCallTask.Client__c;
                vc.Candidato__c = relatedCallTask.Lead__c;
                vc.FromPhoneNumber__c = relatedCallTask.Brand_Phone__c;
            }
        }
    }

    public static void closeRelatedCallTasks(List<VoiceCall> lVoiceCalls){
        Set<Id> relatedIds = new Set<Id>();

        for (VoiceCall vc : lVoiceCalls) {
            relatedIds.add(vc.Call_Task__c);
        }

        List<Call_Task__c> lRelatedCallTasks = [
            SELECT
                Id,
                Status__c
            FROM Call_Task__c
            WHERE Id IN : relatedIds
            AND RecordTypeId = : NBK_GlobalConstants.TASK_OUTBOUND_CALL_RT_ID
        ];

        for (Call_Task__c callTask : lRelatedCallTasks) {
            callTask.Status__c = NBK_GlobalConstants.TASK_COMPLETED_STATUS;
        }

        update lRelatedCallTasks;
    }

    private static Map<String, String> getTopicByPhoneMap(){
        Map<String, String> mTopicByPhone = new Map<String, String>();
        List<Phone_Config__c> lTopicsConfig = [SELECT Id, Phone__c, VoiceCall_Topic_Config__c FROM Phone_Config__c];

        for(Phone_Config__c topicConfig : lTopicsConfig){
            mTopicByPhone.put(topicConfig.Phone__c, topicConfig.VoiceCall_Topic_Config__c);
        }

        return mTopicByPhone;
    }
}