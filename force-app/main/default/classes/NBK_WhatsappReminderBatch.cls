/**
 * @description  :
 * @author       : development@nubika.com
**/
public class NBK_WhatsappReminderBatch implements Database.Batchable<SObject>{

    private String originalTransactionId;

    public Database.QueryLocator start(Database.BatchableContext BC){
        this.originalTransactionId = Logger.getTransactionId();
        Logger.info('Starting - NBK_WhatsappReminderBatch').addTag('NBK_WhatsappReminderBatch');
        Logger.saveLog();
        return Database.getQueryLocator([SELECT Id, CaseNumber, AccountId, SuppliedPhone, Enviar_plantilla_Recordatorio_de_cita__c
                                         FROM Case
                                         WHERE (TypeOfAppointment__c = :NBK_GlobalConstants.CASE_APPOINTMENT_TYPE
                                                OR TypeOfAppointment__c = :NBK_GlobalConstants.CASE_PHONE_TYPE
                                                OR TypeOfAppointment__c = :NBK_GlobalConstants.CASE_VIDEOCALL_TYPE)
                                            AND Fecha_Hora_de_cita__c = TOMORROW
                                            AND Status = :NBK_GlobalConstants.CASE_GESTION_WHATSAPP_CLOSE_STATUS
                                            AND Motivo_de_cierre__c = :NBK_GlobalConstants.CASE_GESTION_WHATSAPP_REASON_FOR_CLOSURE]);
     }

    public void execute(Database.BatchableContext BC, List<Case> scope){
        Logger.setParentLogTransactionId(this.originalTransactionId);
        try{
            List<Case> caseToUpdate = new List<Case>();
            for(Case caseToReminder : scope){
                caseToReminder.Enviar_plantilla_Recordatorio_de_cita__c = true;
                caseToUpdate.add(caseToReminder);
            }
            TriggerHandler.bypass('NBK_CaseHandler');
            update caseToUpdate;
        }catch(Exception e){
            Logger.error(e.getMessage() + ' at line \n' + e.getStackTraceString()).addTag('NBK_WhatsappReminderBatch');
        }
        Logger.saveLog();
     }

     public void finish(Database.BatchableContext BC){
        Logger.setParentLogTransactionId(this.originalTransactionId);
        Logger.info('Finishing running NBK_WhatsappReminderBatch').addTag('NBK_WhatsappReminderBatch');
        Logger.saveLog();
     }
}