public class LC_containerButtonSDocController {

    @AuraEnabled
    public static String sendBudget(String recordId){
      String respuesta;
          if(!String.isBlank(recordId)){
          		List<SDOC__SDRelationship__c> listSDoc = [select id, SDOC__Case__c, SDOC__Case__r.Origen_Renting__c, SDOC__SDoc__c, SDOC__SDoc__r.SDOC__Attachment_ID__c, SDOC__Case__r.Campana__r.Name from SDOC__SDRelationship__c where Id =:recordId];
              	if(!listSDoc.isEmpty()){
                  	SDOC__SDRelationship__c sdoc = listSDoc[0];
                    String Plantilla;
                    String fromEmail;
                    if (sdoc.SDOC__Case__r.Origen_Renting__c == 'XTRAVANS'){
                        Plantilla = 'PropuestaXtravans';
                        fromEmail = Label.FromEmailXtravans;
                    } else if (sdoc.SDOC__Case__r.Origen_Renting__c == 'MYCARFLIX' && sdoc.SDOC__Case__r.Campana__r.Name != 'PEPECAR_LEADS'){
                        Plantilla = 'PropuestaMycarflix';
                        fromEmail = Label.FromEmailMycarflix;
                    } else if (sdoc.SDOC__Case__r.Origen_Renting__c == 'MYCARFLIX' && sdoc.SDOC__Case__r.Campana__r.Name == 'PEPECAR_LEADS'){
                        Plantilla = 'PropuestaMycarflixPepeCar';
                        fromEmail = Label.FromEmailMycarflix;
                    }
	                if (Plantilla != null){
                        EmailTemplate et = [SELECT Id, Subject FROM EmailTemplate WHERE Name = :Plantilla];
                        
                        Case caso = CaseGateway.getCaseById(sdoc.SDOC__Case__c);
                        
                        List <Messaging.EmailFileAttachment> efas = new List<Messaging.EmailFileAttachment>();  
                        List<Attachment> files = [SELECT Name, Body, ContentType FROM Attachment WHERE Id = :sdoc.SDOC__SDoc__r.SDOC__Attachment_ID__c];
                        if(!files.isEmpty()){
                            Attachment att = files[0];
                            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                            efa.setFileName(att.Name);
                            efa.setBody(att.Body);
                            efa.setContentType(att.ContentType);
                            efas.add(efa);
                        }
                        
                        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id,null , caso.Id);
                        mail.setHtmlBody(mail.getHtmlBody() + caso.Referencia_Email__c);
                        mail.setWhatId(caso.Id);
                        mail.setTreatTargetObjectAsRecipient(false);
                        //mail.setReplyTo('noreply@salesforce.com');
                
                        
                        mail.setOrgWideEmailAddressId(fromEmail);
                        List<String> sendTo = new list<String>{caso.SuppliedEmail};
                        mail.setToAddresses(sendTo);
                        mail.setSaveAsActivity(true);
                        if(!efas.isEmpty()){
                            mail.setFileAttachments(efas);  
                        }
                        Messaging.SendEmailResult[] emailSent = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
                        if (emailSent[0].isSuccess()) {
                            Case casoUpdate = new Case();
                            casoUpdate.Id = caso.Id;
                            caso.Status = Label.StatusPropuestaEnviada;
                            caso.Fecha_reminder__c = date.today().addDays(integer.valueOf(Label.DaysReminderMyCarflix));
                            update caso;
                            respuesta ='Operación realizada correctamente.';
                        }
                        else {
                            respuesta ='No se ha podido mandar el correo eletrónico. Intentelo más tarde';
                        }
                    }
                    else {
                         respuesta ='No se ha podido realizar la operación. No se puede derterminar la plantilla a enviar';
                    }
        }
              	else{
                	  respuesta ='No se ha podido realizar la operación. Contacte con el administrador.';
              	}
       	  }
          else {
               respuesta ='No se ha podido realizar la operación. Contacte con el administrador.';
          }
           
        return respuesta;
    }
    
    @AuraEnabled
    public static String getUrlAttachment(String recordId){
        Map<String,String> response = new Map<String,String>();
        if(!String.isBlank(recordId)){
        	List<SDOC__SDRelationship__c> listSDoc = [select id, SDOC__Case__c, SDOC__SDoc__c, SDOC__SDoc__r.SDOC__Attachment_ID__c from 	SDOC__SDRelationship__c where Id =:recordId];
            if(!listSDoc.isEmpty()){
            	SDOC__SDRelationship__c sdoc = listSDoc[0];
                if(!String.isBlank(sdoc.SDOC__SDoc__r.SDOC__Attachment_ID__c)){
                	response.put('respuesta', 'OK');
                    String URLString = URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.FileDownload?file=' + sdoc.SDOC__SDoc__r.SDOC__Attachment_ID__c;
                    system.debug('URL_String:'+ URLString);
                    response.put('URL',URLString);
                }
                else {
                	response.put('respuesta', 'KO');
                }
            }
            else {
            	response.put('respuesta', 'KO');
            }
       } 
        else {
            response.put('respuesta', 'KO');
        }
        String respuesta = JSON.serialize(response);
        return respuesta;
    }
}