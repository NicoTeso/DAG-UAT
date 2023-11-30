global class SendSecondNotificationBatch implements Database.Batchable<sObject>, Schedulable,Database.AllowsCallouts{
 
    global Database.QueryLocator start(Database.BatchableContext bc) {

        Map<String, Schema.RecordTypeInfo> rtMapByDName = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName();
        string rtATTCliente = rtMapByDName.get(Label.RtCaseGestionAtencionCliente).getRecordTypeId();
        datetime ahora = datetime.now();
        
        return  Database.getQueryLocator([SELECT id, DateSecondNotification__c, DateTimeFirstSend__c, NotApplySecondSend__c, 
                                                 RecordTypeId, Origin, SuppliedEmail, Referencia_Email__c 
                                                FROM case 
                                               WHERE RecordTypeId = :rtATTCliente AND
                                          		     DateSecondNotification__c < :ahora AND
                                                     DateTimeFirstSend__c != null AND
                                                     DateTimeSecondSend__c = null AND
                                                     SuppliedEmail != null AND
                                                     NotApplySecondSend__c = false AND
                                          		     Origin = 'Email' AND
                                                     Marca__C = 'AUDI']);
    }
    
    global void execute(Database.BatchableContext BC, List<case> lstCase) {

        String CasoError = ' ';

        List<Exception__c> listExceptionToInsert = new List<Exception__c>();
        
        try {
        
            Map<String,Case> mapCaseToUpdate =  new Map<String, Case>();
            Map<String,Case> mapCaseToSend =  new Map<String, Case>();
    
            String Plantilla = 'RespuestaATTClenteAudi_2';
            String fromEmail = Label.FromEmailAudiATTCliente;
            String ultimoEnvio;
            EmailTemplate et;
                
            if (Plantilla != null){
                et = [SELECT Id, Subject FROM EmailTemplate WHERE Name = :Plantilla];
            }    
            
            for(case caso:lstCase){
                
                    Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id,null , caso.Id);
                    mail.setHtmlBody(mail.getHtmlBody() + caso.Referencia_Email__c);
                    mail.setWhatId(caso.Id);
                    mail.setTreatTargetObjectAsRecipient(false);
                    mail.setOrgWideEmailAddressId(fromEmail);
                    List<String> sendTo = new list<String>{caso.SuppliedEmail};
                    mail.setToAddresses(sendTo);
                    mail.setSaveAsActivity(true);

                	casoError = caso.Id;
                        
                    Messaging.SendEmailResult[] emailSent = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
                        
                    system.debug('emailSent: '+emailSent);
                        
                    if (emailSent[0].isSuccess()) {
                        system.debug('entra por 1');
                        Case casoUpdate = new Case();
                        casoUpdate.Id = caso.Id;
	   	 	            casoUpdate.DateTimeSecondSend__c = datetime.now();
                        mapCaseToUpdate.put(casoUpdate.Id, casoUpdate);
                    }
                    else {
                        system.debug('entra por 2');
                        Exception__c exc = new Exception__c ();
                        exc.idObjetos__c = caso.Id;
                        exc.Exception__c = 'No se ha podido mandar el correo eletrónico '+ emailSent[0].getErrors();
                        exc.Linea__c = 52;
                        exc.Clase_Metodo__c = 'SendSecondNotificationBatch.sendEmail';
                        listExceptionToInsert.add(exc);
                    }
                }
   
            if(!mapCaseToUpdate.isEmpty()){
                update mapCaseToUpdate.values();
            }
            
        } catch (Exception e) {
            System.debug('SendSecondNotificationBatch.sendEmail ' + e.getStackTraceString());
            Exception__c exc = new Exception__c ();
            exc.idObjetos__c = CasoError;
            exc.Exception__c = e.getStackTraceString() + ' ' + e.getMessage();
            exc.Linea__c = e.getLineNumber();
            exc.Clase_Metodo__c = 'SendSecondNotificationBatch.sendEmail';
            listExceptionToInsert.add(exc);
        }

        if(listExceptionToInsert != null && !listExceptionToInsert.isEmpty()) {
            insert listExceptionToInsert;
        }
       
    }   
    
    global void finish(Database.BatchableContext BC) {}
    
    // Scheduler
    public void execute(SchedulableContext sc) {
        Id batchJobId = Database.executeBatch(new SendSecondNotificationBatch(),9);
    }

}