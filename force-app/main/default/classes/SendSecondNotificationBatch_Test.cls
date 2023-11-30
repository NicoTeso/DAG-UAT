@isTest
public class SendSecondNotificationBatch_Test {

    
    @isTest
    static void sendReminderTest() {

        Case ca = new Case();
        ca.Marca__c = 'AUDI';
        ca.Origin ='Email';
        ca.Intencion_de_compra__c = 'Prueba';
        ca.SuppliedPhone = '918887765';
        ca.SuppliedEmail = 'case@test.com';
        ca.DateSecondNotification__c = datetime.now().addMinutes(-5);
        ca.DateTimeFirstSend__c = datetime.now().addMinutes(-50);
        ca.NotApplySecondSend__c = false;
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.RtCaseGestionAtencionCliente).getRecordTypeId();
        insert ca;        

        Test.startTest();
        
        Database.executeBatch(new SendSecondNotificationBatch());
        
        Test.stopTest();
    }    

}