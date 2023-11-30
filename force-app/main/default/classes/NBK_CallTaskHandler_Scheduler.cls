/*-----------------------------------------------------------------------------------------
     Apex Class:        NBK_CallTaskHandler_Scheduler
     Created Date:      23/06/2021
     Author:            davidmartinez
------------------------------------------------------------------------------------------*/
global class NBK_CallTaskHandler_Scheduler implements Schedulable{

    global void execute(SchedulableContext sc) {
        System.debug('### NBK_CallTaskHandler_Scheduler - execute() - start');
        NBK_CallTaskHandler_Batch callTaskHandlerBatch = new NBK_CallTaskHandler_Batch();
        Id batchId = Database.executeBatch(callTaskHandlerBatch);
        System.debug('### NBK_CallTaskHandler_Scheduler - execute() - batchId: ' + batchId);
    }
}