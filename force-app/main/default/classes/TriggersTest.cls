@isTest
public class TriggersTest {

    public static void activaTriggers(){
        Triggers__c triggers = new Triggers__c();
        triggers.AuxAccountTrigger__c = true;
        triggers.AuxConsentimientoTrigger__c = true;
        triggers.AccountTrigger__c = true;
        triggers.CaseTrigger__c = true;
        triggers.ChatTranscriptTrigger__c = true;
        triggers.ConsentimientoTrigger__c = true;
        triggers.TaskTrigger__c = true;
        triggers.DetalleVentaTrigger__c = true;
        triggers.VehiculoTrigger__c = true;
        triggers.EncuestaTrigger__c = true;
        triggers.PaseTallerTrigger__c = true;
        triggers.MessagingSessionTrigger__c = true;
        triggers.LeadTrigger__c = true;
        triggers.RegistrosRelacionadosTrigger__c= true;
        triggers.ContactTrigger__c= true;
        triggers.DuplicateRecordItemTrigger__c= true;
        triggers.ContratoRentingTrigger__c= true;
        triggers.ContratoRentingVehiculoTrigger__c= true;
        triggers.Active_Migration__c = false;
        triggers.invalidEmailTrigger__c= true;
        triggers.EmailMessageTrigger__c= true;
       
        insert triggers; 
   }
}