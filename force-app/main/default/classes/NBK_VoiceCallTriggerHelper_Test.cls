/**
 * @description  : 
 * @author       : Nubika Team <example@nubika.com>
 * @version      : 1.0.0
 * @date         : 31-05-2023
 * @group        : 
 * @see          : 
**/
@isTest
public class NBK_VoiceCallTriggerHelper_Test {
    @TestSetup
    public static void testSetup() {
        NBK_SetupClassTest.setupCaseManagementTestData();
    }

    public static void testAll() {
        Test.startTest();
        setVoiceCallOwnersTestMethod();
        Test.stopTest();
    }

    @IsTest
    static void setVoiceCallOwnersTest() {
        Test.startTest();
            setVoiceCallOwnersTestMethod();
        Test.stopTest();
    }

    private static void setVoiceCallOwnersTestMethod(){
        NBK_VoiceCallTriggerController handler = new NBK_VoiceCallTriggerController();
        
        List<VoiceCall> lTriggerNewData = (List<VoiceCall>) JSON.deserialize('[{"attributes":{"type":"VoiceCall","url":"/services/data/v53.0/sobjects/VoiceCall/0LQ5r0000004CEcGAM"}, "Id":"0LQ1i000000sVRHGA2", "OwnerId":"0055r000000lXQqAAM","CallType":"Outbound"}]', List<VoiceCall>.class);
        VoiceCall oldVoiceCall = new VoiceCall(Id = lTriggerNewData.get(0).Id, OwnerId = lTriggerNewData.get(0).OwnerId, CallType = lTriggerNewData.get(0).CallType, Call_Task__c = null);

        Call_Task__c ct = [SELECT Id FROM Call_Task__c LIMIT 1];        
        lTriggerNewData.get(0).Call_Task__c = ct.Id;
        
        handler.mTriggerOld = new Map<Id, VoiceCall>{oldVoiceCall.Id => oldVoiceCall};
        handler.lTriggerNew = lTriggerNewData;
        handler.beforeInsert();
        handler.afterInsert();

    }
}