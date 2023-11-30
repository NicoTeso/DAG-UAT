/**
 * @description  :
 * @author       : development@nubika.com
**/
@isTest
public class NBK_WhatsappReminderBatch_Test {

    private static final String CASE_APPOINTMENT_TYPE = NBK_GlobalConstants.CASE_APPOINTMENT_TYPE;
    private static final String CASE_PHONE_TYPE = NBK_GlobalConstants.CASE_PHONE_TYPE;
    private static final String CASE_VIDEOCALL_TYPE = NBK_GlobalConstants.CASE_VIDEOCALL_TYPE;
    private static final String CASE_GESTION_WHATSAPP_CLOSE_STATUS = NBK_GlobalConstants.CASE_GESTION_WHATSAPP_CLOSE_STATUS;
    private static final String CASE_GESTION_WHATSAPP_REASON_FOR_CLOSURE = NBK_GlobalConstants.CASE_GESTION_WHATSAPP_REASON_FOR_CLOSURE;

    @isTest
    static void testExecute() {

        // Set up test data
        Account account = new Account(Name = 'Test Account');
        insert account;

        // Create some cases with matching criteria
        Case matchingCase1 = new Case(TypeOfAppointment__c = CASE_APPOINTMENT_TYPE, Fecha_Hora_de_cita__c = Date.today().addDays(1), Status = CASE_GESTION_WHATSAPP_CLOSE_STATUS, Motivo_de_cierre__c = CASE_GESTION_WHATSAPP_REASON_FOR_CLOSURE, AccountId = account.Id, SuppliedPhone = '+1234567890');
        Case matchingCase2 = new Case(TypeOfAppointment__c = CASE_PHONE_TYPE, Fecha_Hora_de_cita__c = Date.today().addDays(1), Status = CASE_GESTION_WHATSAPP_CLOSE_STATUS, Motivo_de_cierre__c = CASE_GESTION_WHATSAPP_REASON_FOR_CLOSURE, AccountId = account.Id, SuppliedPhone = '+0987654321');
        Case caseToUpdate = new Case(TypeOfAppointment__c = CASE_APPOINTMENT_TYPE, Fecha_Hora_de_cita__c = Date.today().addDays(1), Status = CASE_GESTION_WHATSAPP_CLOSE_STATUS, Motivo_de_cierre__c = CASE_GESTION_WHATSAPP_REASON_FOR_CLOSURE, AccountId = account.Id, SuppliedPhone = '+1234567890');

        insert new List<Case>{matchingCase1, matchingCase2, caseToUpdate};

        // Run batch and check that the case was updated
        NBK_WhatsappReminderBatch batch = new NBK_WhatsappReminderBatch();
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();

        Case updatedCase = [SELECT Id, Enviar_plantilla_Recordatorio_de_cita__c FROM Case WHERE Id = :caseToUpdate.Id];
        System.assertEquals(true, updatedCase.Enviar_plantilla_Recordatorio_de_cita__c, 'Expected the case to have been updated with the reminder flag');
    }
}