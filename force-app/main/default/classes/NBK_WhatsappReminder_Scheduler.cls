/*-----------------------------------------------------------------------------------------
     Apex Class:        NBK_WhatsappReminder_Scheduler
     Created Date:      07/09/2021
     Author:            Alberto Sanchez
------------------------------------------------------------------------------------------*/
global class NBK_WhatsappReminder_Scheduler implements Schedulable{
    
    global void execute(SchedulableContext sc) {
        System.debug('### NBK_WhatsappReminder_Scheduler - execute() - start');
        NBK_WhatsappReminderBatch whatsappReminderBatch = new NBK_WhatsappReminderBatch();
        Id batchId = Database.executeBatch(whatsappReminderBatch);
        System.debug('### NBK_WhatsappReminder_Scheduler - execute() - batchId: ' + batchId);
    }
}