global class SendReminderProposalBatch implements Database.Batchable<sObject>, Schedulable,Database.AllowsCallouts{
 
    global Database.QueryLocator start(Database.BatchableContext bc) {

        return  Database.getQueryLocator([SELECT id, Origen_Renting__c, Status, Fecha_reminder__c, SuppliedEmail, Referencia_Email__c 
                                                FROM case 
                                               WHERE Origen_Renting__c = 'MYCARFLIX' AND
                                                     Status = :Label.StatusPropuestaEnviada AND
                                                     SuppliedEmail != null AND
                                                     Fecha_reminder__c = YESTERDAY]);
    }
    
    global void execute(Database.BatchableContext BC, List<case> lstCase) {

        String CasoError = ' ';

        List<Exception__c> listExceptionToInsert = new List<Exception__c>();
        
        try {
        
            Map<String,Case> mapCaseToUpdate =  new Map<String, Case>();
            Map<String,Case> mapCaseToSend =  new Map<String, Case>();
            Map<String,String> mapSDRelationship =  new Map<String,String>();
            Map<String,Attachment> mapAttachmentAux =  new Map<String,Attachment>();
            Map<String,Attachment> mapAttachment =  new Map<String,Attachment>();
    
            List<String> lstCaseID  = new List<String>();
    
            for(case caso:lstCase){
                lstCaseID.add(caso.Id);
            }    
    
            if (!lstCaseID.isEmpty()){
                List<SDOC__SDRelationship__c> lstSDRelationship = [SELECT id, SDOC__Case__c, SDOC__SDoc__c, 
                                                                          SDOC__SDoc__r.SDOC__Attachment_ID__c, SDOC__Document_Created_On__c 
                                                                     FROM SDOC__SDRelationship__c 
                                                                    WHERE SDOC__Case__c in :lstCaseID AND
                                                                          SDOC__SDoc__r.SDOC__Attachment_ID__c != null          
                                                                 ORDER BY SDOC__Document_Created_On__c DESC];
                 
                system.debug('lstSDRelationship: '+lstSDRelationship); 
                for (SDOC__SDRelationship__c SDRelationship:lstSDRelationship){
                    if (!mapSDRelationship.containsKey(SDRelationship.SDOC__Case__c)){
                        system.debug('SDRelationship.SDOC__Case__c: '+SDRelationship.SDOC__Case__c);
                        system.debug('SDRelationship.SDOC__SDoc__r.SDOC__Attachment_ID__c: '+SDRelationship.SDOC__SDoc__r.SDOC__Attachment_ID__c);
                        mapSDRelationship.put(SDRelationship.SDOC__Case__c, SDRelationship.SDOC__SDoc__r.SDOC__Attachment_ID__c);
                    }
                }
            }

            system.debug('mapSDRelationship: '+mapSDRelationship);

            List<String> lstSDocID  = mapSDRelationship.values(); 
            
            system.debug('lstSDocID: '+lstSDocID);
    
            if(!lstSDocID.isEmpty()){
    
                List<Attachment> files = [SELECT Id, Name, Body, ContentType FROM Attachment WHERE Id = :lstSDocID];
                
                for (Attachment file : files) {
                    mapAttachmentAux.put(file.Id, file);
                }
            }
            
            for (string IdCaso : mapSDRelationship.keySet()) {
                String DocID = mapSDRelationship.get(IdCaso);
                if (mapAttachmentAux.containsKey(DocID)){
                    mapAttachment.put(IdCaso, mapAttachmentAux.get(DocID));
                }    
            }
    
            String Plantilla = 'ReminderMycarflix';
            String fromEmail = Label.FromEmailMycarflix;
            String ultimoEnvio;
            EmailTemplate et;
                
            if (Plantilla != null){
                et = [SELECT Id, Subject FROM EmailTemplate WHERE Name = :Plantilla];
            }    
            
            for(case caso:lstCase){
                
                if (mapAttachment.containsKey(caso.Id)){
                                    
                    List <Messaging.EmailFileAttachment> efas = new List<Messaging.EmailFileAttachment>();  
                   
                    Attachment att = mapAttachment.get(caso.Id);
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    efa.setFileName(att.Name);
                    efa.setBody(att.Body);
                    efa.setContentType(att.ContentType);
                    efas.add(efa);
                                    
                    Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id,null , caso.Id);
                    mail.setHtmlBody(mail.getHtmlBody() + caso.Referencia_Email__c);
                    mail.setWhatId(caso.Id);
                    mail.setTreatTargetObjectAsRecipient(false);
                    mail.setOrgWideEmailAddressId(fromEmail);
                    List<String> sendTo = new list<String>{caso.SuppliedEmail};
                    mail.setToAddresses(sendTo);
                    mail.setSaveAsActivity(true);
                    if (!efas.isEmpty()){
                        mail.setFileAttachments(efas);  
                    }
                    casoError = caso.Id;
                        
                    Messaging.SendEmailResult[] emailSent = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
                        
                    system.debug('emailSent: '+emailSent);
                        
                    if (emailSent[0].isSuccess()) {
                        system.debug('entra por 1');
                        Case casoUpdate = new Case();
                        casoUpdate.Id = caso.Id;
                        casoUpdate.Status = Label.StatusReminderEnviado;
                        mapCaseToUpdate.put(casoUpdate.Id, casoUpdate);
                    }
                    else {
                        system.debug('entra por 2');
                        Exception__c exc = new Exception__c ();
                        exc.idObjetos__c = caso.Id;
                        exc.Exception__c = 'No se ha podido mandar el correo eletrónico '+ emailSent[0].getErrors();
                        exc.Linea__c = 88;
                        exc.Clase_Metodo__c = 'SendReminderProposalBatch.sendEmail';
                        listExceptionToInsert.add(exc);
                    }
                }
            }    
    
            if(!mapCaseToUpdate.isEmpty()){
                update mapCaseToUpdate.values();
            }
            
        } catch (Exception e) {
            System.debug('SendReminderProposalBatch.sendEmail ' + e.getStackTraceString());
            Exception__c exc = new Exception__c ();
            exc.idObjetos__c = CasoError;
            exc.Exception__c = e.getStackTraceString() + ' ' + e.getMessage();
            exc.Linea__c = e.getLineNumber();
            exc.Clase_Metodo__c = 'SendReminderProposalBatch.sendEmail';
            listExceptionToInsert.add(exc);
        }

        if(listExceptionToInsert != null && !listExceptionToInsert.isEmpty()) {
            insert listExceptionToInsert;
        }
       
    }   
    
    global void finish(Database.BatchableContext BC) {}
    
    // Scheduler
    public void execute(SchedulableContext sc) {
        Id batchJobId = Database.executeBatch(new SendReminderProposalBatch(),9);
    }

}