@IsTest
public with sharing class NBK_VoiceCallHandler_Batch_Test {

    @IsTest
    static void totalCallAttemptsBatchMethodTest() {
        Test.startTest();
        updateVoiceCallBatchMethodTest();
        Test.stopTest();
    }

    public static void updateVoiceCallBatchMethodTest() {

        Set<Id> ownerIds = new Set<Id>{UserInfo.getUserId()};
        Datetime startDate = DateTime.newInstance(2022, 01, 01, 00, 00, 00);
        Datetime endDate = DateTime.newInstance(2022, 01, 31, 23, 59, 59);

        Database.executeBatch(new NBK_VoiceCallHandler_Batch(ownerIds, startDate, endDate), 20);
    }
}