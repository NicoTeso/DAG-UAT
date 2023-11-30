/*-----------------------------------------------------------------------------------------
     Apex Class:        NBK_RegisterCallLog_Controller
     Created Date:      30/03/2021
     Author:            davidmartinez
------------------------------------------------------------------------------------------*/

public with sharing class NBK_RegisterCallLog_Controller {

    @AuraEnabled
    public static void scheduleCall(String recordId, String mode, String timeInfo){

        System.debug('### NBK_RegisterCallLog_Controller - scheduleCall - recordId: ' + recordId);
        System.debug('### NBK_RegisterCallLog_Controller - scheduleCall - mode: ' + mode);
        System.debug('### NBK_RegisterCallLog_Controller - scheduleCall - timeInfo: ' + timeInfo);

        Call_Task__c callTask = getCallTask(recordId);

        if(mode.equals('AUTOMATIC_CALL')){
            Datetime today = System.now();
            Integer numberOfTries = Integer.valueOf(timeInfo);
            System.debug('### NBK_RegisterCallLog_Controller - scheduleCall - numberOfTries: ' + numberOfTries);

            today = today.addMinutes(getMinutesInterval(numberOfTries));
            callTask.Reschedule_Date__c = today;

        } else if(mode.equals('SPECIFIC_TIME')){
            Datetime specificValue = Datetime.valueOf(timeInfo.replace('T',' '));
            callTask.Reschedule_Date__c = specificValue.addSeconds(UserInfo.getTimeZone().getOffset(specificValue)/1000);
        }

        callTask.Reschedule__c = true;
        update callTask;

    }

    private static Call_Task__c getCallTask(String recordId){
        return [SELECT Id, Reschedule_Date__c FROM Call_Task__c WHERE Id = :recordId LIMIT 1];
    }

    private static Integer getMinutesInterval(Integer numberOfTries){
        try{
            String attempts = String.valueOf(numberOfTries);
            Automatic_Recall_Config__c automaticCallConfig = Automatic_Recall_Config__c.getInstance('Attempt ' + attempts);
            if(automaticCallConfig != null)
                return (Integer) automaticCallConfig.Minutes__c;
        } catch (Exception e){
            System.debug('### NBK_RegisterCallLog_Controller - getMinutesInterval() - error: ' + e);
        }
        return 0;
    }


}