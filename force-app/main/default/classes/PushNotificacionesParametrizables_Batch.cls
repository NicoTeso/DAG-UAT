/*
* Name: PushNotificacionesParametrizables_Batch
* Developer: Viseo
* Description: Batch class to replace the flow Push_Notificaciones_Parametrizables
* Date: 23/12/20
*/

global class PushNotificacionesParametrizables_Batch implements Database.Batchable<sObject> {
    
    global String query;
    global String email;
    global Maestro_Notificaciones__c masterNotifB;
    global CustomNotificationType customNotifB;
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Cuenta_Notificacion__c> accNotifList) {
        
        //Variables
        Set<String> accColection = new Set<String>();
        
        // process each batch of records default size is 200        
        for(Cuenta_Notificacion__c notifAcc : accNotifList){
            accColection.add(notifAcc.USER_ID__c);
        }
        
        //Manage the Target Page Reference
        /*
        String destino;
        String destinoNotif;
        switch on destino{
            when 'Mi perfil'{
                destinoNotif = '{"type": "standard__objectPage","attributes": {"objectApiName": "User_Profile","actionName": "list"}}';
            }
            when 'Club WAH'{
                destinoNotif = '{"type": "comm__namedPage","attributes": {"name": "clubmywah__c"}}';
            }
            when 'Descuentos'{
                destinoNotif = '{"type": "standard__objectPage","attributes": {"objectApiName": "Descuentos__c","actionName": "list"},"state":{"filterName":"Recent"}}';
                //IMP 10/02/2021 Se puede hacer que navegue a un registro en concreto en lugar de a un objeto con la siguiente instruccion:
                //IMP 10/02/2021  '{"type": "standard__recordPage","attributes": {"recordId": "a0o0Q00000ES70AQAT","objectApiName": "Descuentos__c","actionName": "view"},"state":{"filterName":"Recent"}}'
            }
            when 'Vehiculos'{
                destinoNotif = '{"type": "standard__objectPage","attributes": {"objectApiName": "list_a0e__c","actionName": "list"}}';
            }
            when 'Facturas'{
                destinoNotif = '{"type": "standard__objectPage","attributes": {"objectApiName": "Invoice_List__c","actionName": "list"}}';
            }
            when 'Citas de taller'{
                destinoNotif = '{"type": "comm__namedPage","attributes": {"name": "cita_taller__c"}}';
            }
        }
        */
        
        // Create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        
        // Set the contents for the notification
        notification.setTitle(masterNotifB.Name);
        notification.setBody(masterNotifB.Body__c);
        notification.setTargetPageRef(masterNotifB.Destion_formula__c);
        
        // Set the notification type and target
        notification.setNotificationTypeId(customNotifB.Id);
        //notification.setTargetPageRef();
        
        // Actually send the notification
        try {
            notification.send(accColection);
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
            mail.setToAddresses(new String[] {email});
            mail.setSenderDisplayName('Proceso de Envio de Notificaciones');
            mail.setSubject('Error al enviar notificaciones');
            mail.setPlainTextBody('No se ha podido completar el envio de notificaciones, error: ' + e.getMessage());
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            Exception__c exc = new Exception__c ();
            exc.Exception__c = e.getCause() + '// '+ e.getMessage();
            exc.Linea__c = e.getLineNumber();
            exc.Clase_Metodo__c = 'PushNotificacionesParametrizables_Batch.execute';
            insert exc;
        }         
    }   
    
    global void finish(Database.BatchableContext BC){
        
        
    }
}