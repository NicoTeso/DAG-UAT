/*
* Name: AnadirClientesNotificacion_Batch
* Developer: Viseo
* Description: Batch class to replace the flow A_adir_clientes_notificacion
* Date: 23/12/20
*/

global class AnadirClientesNotificacion_Batch implements Database.Batchable<sObject> {
    
    global String query;
    global String email;
    global Maestro_Notificaciones__c masterNotifB;
    global List<String> customNotifListB;
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('IMTest: ' + query);
        System.debug('IMTest: ' + email);
        System.debug('IMTest: ' + masterNotifB);
        System.debug('IMTest: ' + customNotifListB);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<User> userList) {
        
        List<Cuenta_Notificacion__c> cuentasCrear = new List<Cuenta_Notificacion__c>();
        
        for(User userRecord : userList){ //Aquí tenemos que elegir entre una de las listas dependiendo de la elegida por el usuario.
            System.debug(userRecord);
            //Se comprueba si el cliente ya exite en notificacion
            if(customNotifListB.contains(userRecord.AccountId)){
            }else{ //En el caso de que no exista empezamos con las asignaciones para las nuevas cuentas de notificación.
                Cuenta_Notificacion__c newNotifAcc = new Cuenta_Notificacion__c();
                newNotifAcc.Account__c = userRecord.AccountId;
                newNotifAcc.Notificacion__c = masterNotifB.Id;
                newNotifAcc.User_ID__c = userRecord.Id;
                cuentasCrear.add(newNotifAcc);
            }
        } 
        
        //Por último creamos las cuentas de notificación en el caso de que las hubiera.   
        if(!cuentasCrear.isEmpty()){
            try {
                insert(cuentasCrear);
            }
            catch (Exception e) {
                System.debug('Problem sending notification: ' + e.getMessage());
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
                mail.setToAddresses(new String[] {email});
                mail.setSenderDisplayName('Proceso de Envio de Notificaciones');
                mail.setSubject('Error al añadir clientes');
                mail.setPlainTextBody('No se ha podido completar la carga de clientes, error: ' + e.getMessage());
                
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                
                Exception__c exc = new Exception__c ();
                exc.Exception__c = e.getCause() + '// '+ e.getMessage();
                exc.Linea__c = e.getLineNumber();
                exc.Clase_Metodo__c = 'AnadirClientesNotificacion.anadirClientes';
                insert exc;
            }    
        }    
    }   
    
    global void finish(Database.BatchableContext BC){
        
        masterNotifB.Clientes_cargados__c = true;
        try{
            update(masterNotifB);
        }catch(Exception e){
            System.debug('Problem updating notification: ' + e.getMessage());
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    
            mail.setToAddresses(new String[] {email});
            mail.setSenderDisplayName('Proceso de Envio de Notificaciones');
            mail.setSubject('Error al añadir clientes');
            mail.setPlainTextBody('No se ha podido completar la carga de clientes, error: ' + e.getMessage());
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
            Exception__c exc = new Exception__c ();
            exc.Exception__c = e.getCause() + '// '+ e.getMessage();
            exc.Linea__c = e.getLineNumber();
            exc.Clase_Metodo__c = 'AnadirClientesNotificacion.finish';
            insert exc;
        }
        
    }
}