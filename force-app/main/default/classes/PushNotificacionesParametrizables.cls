/*
* Name: PushNotificacionesParametrizables
* Developer: Viseo
* Description: Apex class to execute the batch PushNotificacionesParametrizables_Batch
* Date: 23/12/20
*/

public class PushNotificacionesParametrizables {
    
    @InvocableMethod(label='Send Notifications' description='Retrieve the account to send the custom notifications')
    public static void pushNotificaciones(List<String> masterNotifId){
        
        // Queries    
        Maestro_Notificaciones__c masterNotif = [SELECT Id, Name, Body__c, OwnerId, Destion_formula__c 
                                                 FROM Maestro_Notificaciones__c 
                                                 WHERE Id =: masterNotifId[0]]; 
        CustomNotificationType customNotif = [SELECT Id, CustomNotifTypeName 
                                              FROM CustomNotificationType 
                                              WHERE CustomNotifTypeName =: masterNotif.Name];       
        Network dagNetwork = [SELECT Id, Name FROM Network WHERE Name =: 'myDAG'];
        User notifUser = [SELECT Id, Email FROM User Where Id =: masterNotif.OwnerId];
        System.debug('The value is: ' + notifUser);
        
        PushNotificacionesParametrizables_Batch pushNotif = new PushNotificacionesParametrizables_Batch();
        pushNotif.query = 'SELECT Id, Notificacion__c, USER_ID__c FROM Cuenta_Notificacion__c ' + 'WHERE Notificacion__c =\'' + masterNotif.Id + '\'';
        System.debug('The value is: ' + pushNotif.query);
        pushNotif.email = notifUser.Email;
        pushNotif.masterNotifB = masterNotif;
        pushNotif.customNotifB = customNotif;
        Id batchProcessId = Database.executeBatch(pushNotif);
    }
    
}