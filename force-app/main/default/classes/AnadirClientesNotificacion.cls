/*
* Name: AnadirClientesNotificacion
* Developer: Viseo
* Description: Apex class to execute the batch AnadirClientesNotificacion_Batch
* Date: 23/12/20
*/

public class AnadirClientesNotificacion {
    
    @InvocableMethod(label='Add Clients' description='Add clients to the master of notifications')
    public static void anadirClientes(List<String> masterNotifId){
        
        // Variables
        String query;
        List<String> notifAccs = new List<String>();    // Lista que contiene las Cuenta Notificación.
        List<Cuenta_Notificacion__c> cuentasCrear = new List<Cuenta_Notificacion__c>(); //Lista que contendrá las cuentas a crear.
        
        //Processing the information received from the flow
        String masterNotif = masterNotifId[0];
        List<String> lstmasterNotif = masterNotif.split(',');
        String masterId = lstmasterNotif[0].remove('[');
        String tipoCliente = lstmasterNotif[1].remove(']');        
        
        // Queries    
        Maestro_Notificaciones__c masterNotifRecord = [SELECT Id, OwnerId 
                                                       FROM Maestro_Notificaciones__c 
                                                       WHERE Id =: masterId];
        Profile externalAPP = [SELECT Id, Name 
                               FROM Profile 
                               WHERE Name=: 'External App Login DAG'];
        User notifUser = [SELECT Id, Email 
                          FROM User 
                          WHERE Id =: masterNotifRecord.OwnerId];
        
        // Extraemos las cuentas de notificacion que estan relacionadas con el maestro de notificaciones.
        for (Cuenta_Notificacion__c notifAcc : [SELECT Id, Notificacion__c, Account__c 
                                                FROM Cuenta_Notificacion__c 
                                                WHERE Notificacion__c =: masterId]){
                                                    notifAccs.add(notifAcc.Account__c);
                                                }
        //Dependiendo de la opción escogida recuperaremos los usuarios seleccionados
        
        if(tipoCliente.equals('Todos')){
            query = 'SELECT Id, ProfileId, CommunityNickname, IsActive, AccountId, Contact.Account.AceptadoComunicacionesWAH__c FROM User ' + 'WHERE ProfileId =\'' + ExternalAPP.Id + '\' AND IsActive = true AND Contact.Account.PoliticaPrivacidadAceptada__c = true';
        }else if(tipoCliente.equals('Socio')){
            query = 'SELECT Id, ProfileId, CommunityNickname, IsActive, AccountId, Contact.Account.AceptadoComunicacionesWAH__c FROM User ' + 'WHERE ProfileId =\'' + ExternalAPP.Id + '\' AND IsActive = true AND Contact.Account.Socio_WAH__pc = true';
        }else if(tipoCliente.equals('Socio WAH')){
            query = 'SELECT Id, ProfileId, CommunityNickname, IsActive, AccountId, Contact.Account.AceptadoComunicacionesWAH__c FROM User ' + 'WHERE ProfileId =\'' + ExternalAPP.Id + '\' AND IsActive = true AND Contact.Account.PoliticaPrivacidadAceptada__c = true AND Contact.Account.Socio_WAH__pc = true AND Contact.Account.AceptadoComunicacionesWAH__c = true';
        }else if(tipoCliente.equals('Socio No WAH')){
            query = 'SELECT Id, ProfileId, CommunityNickname, IsActive, AccountId, Contact.Account.AceptadoComunicacionesWAH__c FROM User ' + 'WHERE ProfileId =\'' + ExternalAPP.Id + '\' AND IsActive = true AND Contact.Account.PoliticaPrivacidadAceptada__c = true AND Contact.Account.Socio_WAH__pc = true AND Contact.Account.AceptadoComunicacionesWAH__c = false';
        }else if(tipoCliente.equals('No Socio')){
            query = 'SELECT Id, ProfileId, CommunityNickname, IsActive, AccountId, Contact.Account.AceptadoComunicacionesWAH__c FROM User ' + 'WHERE ProfileId =\'' + ExternalAPP.Id + '\' AND IsActive = true AND Contact.Account.PoliticaPrivacidadAceptada__c = true AND Contact.Account.Socio_WAH__pc = false AND Contact.Account.AceptadoComunicacionesWAH__c = false';
        }

        AnadirClientesNotificacion_Batch addClients = new AnadirClientesNotificacion_Batch();
        addClients.query = query;
        addClients.email = notifUser.Email;
        addClients.masterNotifB = masterNotifRecord;
        addClients.customNotifListB = notifAccs;
        Id batchProcessId = Database.executeBatch(addClients);

        
    } 
}