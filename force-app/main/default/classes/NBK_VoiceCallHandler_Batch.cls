/*-----------------------------------------------------------------------------------------
     Apex Class:        NBK_VoiceCallHandler_Batch
     Created Date:      07/02/2022
     Author:            Daniel Bardera
------------------------------------------------------------------------------------------*/
global class NBK_VoiceCallHandler_Batch implements Database.Batchable<sObject> {

    private Set<Id> ownerIds;
    private Datetime startDate;
    private Datetime endDate;

    public NBK_VoiceCallHandler_Batch(
        Set<Id> ownerIds,
        Datetime startDate,
        Datetime endDate
    ){
        this.ownerIds = ownerIds;
        this.startDate = startDate;
        this.endDate = endDate;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {

        System.debug('### NBK_VoiceCallHandler_Batch - start()');

        String query =
                'SELECT Id, ToPhoneNumber, FromPhoneNumber__c, CreatedDate, Call_Task__c, OwnerId, Client__c ' +
                'FROM VoiceCall ' +
                'WHERE Topic__c = null AND Marca__c = null AND Call_Task__c = null ' +
                'AND CreatedDate > :startDate AND CreatedDate < :endDate ';

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<VoiceCall> lVoiceCalls) {

        System.debug('### NBK_VoiceCallHandler_Batch - execute()');

        Map<Id, Call_Task__c> mCallTask = new Map<Id, Call_Task__c>();
        
        NBK_VoiceCallManager.relateCallTaskWithVoiceCall(lVoiceCalls);

        lVoiceCalls = NBK_VoiceCallManager.searchVoiceCallWithFromPhoneNumber(lVoiceCalls);

        mCallTask = NBK_VoiceCallManager.createCallTask(lVoiceCalls);

        lVoiceCalls = NBK_VoiceCallManager.relateCallTaskWithFromPhoneNumber(lVoiceCalls, mCallTask);
    }

    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }
}