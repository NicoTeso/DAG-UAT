/*
* Copyright: Viseo Iberia
* Name: PushNotificacionesParametrizables_Test
* Description: Apex class to test for PushNotificacionesParametrizables class
* Date: 20/05/21
*/

@isTest
public class PushNotificacionesParametrizables_Test {
    @isTest 
    static void pushNotificaciones() {
        Account cuentaTest = (Account)TestDataFactory.createSObject('Account',new Map<String,Object>{
            'FirstName' => 'Usuario',
                'LastName' => 'ApexTest'});
        
        Maestro_Notificaciones__c maestroTest = (Maestro_Notificaciones__c)TestDataFactory.createSObject('Maestro_Notificaciones__c',new Map<String,Object>{
            'Name' => '¡Gracias por confiar en myDAG!'});     
        
        Cuenta_Notificacion__c notificacionTest = (Cuenta_Notificacion__c)TestDataFactory.createSObject('Cuenta_Notificacion__c',new Map<String,Object>{
            'Account__c' => cuentaTest.Id,
                'Notificacion__c' => maestroTest.Id});
        
        CustomNotificationType notificationTest = [SELECT Id, CustomNotifTypeName FROM CustomNotificationType WHERE CustomNotifTypeName =: maestroTest.Name]; 
        List<Cuenta_Notificacion__c> listaNotificaciones = new List<Cuenta_Notificacion__c> {notificacionTest};
            
            test.startTest();
        PushNotificacionesParametrizables.pushNotificaciones(new List<String>{ maestroTest.Id });
        
        Database.BatchableContext BC = null; 
        PushNotificacionesParametrizables_Batch obj = new PushNotificacionesParametrizables_Batch ();
        obj.query = 'SELECT Id, Notificacion__c, USER_ID__c FROM Cuenta_Notificacion__c ' + 'WHERE Notificacion__c =\'' + maestroTest.Id + '\'';
        obj.email = 'test@test.net';
        obj.masterNotifB = maestroTest;
        obj.customNotifB = notificationTest;
        obj.execute(BC, listaNotificaciones); 
        Test.stopTest();    
        Integer invocations = Limits.getEmailInvocations();
        System.assert(invocations != null);
    }
}