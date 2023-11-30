public class LC_LookUpClienteAndLeadByPhoneController {

    @AuraEnabled
    public static String getListResponsePhone(String id, String objectName) {
        //Query 10 accounts
        List<LC_LookUpClienteAndLeadByPhoneController.Response> listResponse = new List<LC_LookUpClienteAndLeadByPhoneController.Response>();
        if(!String.isBlank(objectName) && objectName.equalsIgnoreCase('MessagingSession')){
        	MessagingSession mSession = MessagingSessionGateway.getMessagingSessionById(id);
            if(mSession != null){
                MessagingEndUser mEndUser =  MessagingEndUserGateway.getMessagingEndUserByMSessionId(mSession.MessagingEndUserId);
                List<String> partKeys = mEndUser.MessagingPlatformKey.split(':');
                String telefono = partKeys[1];
                if(!String.isBlank(telefono) && DataValidations.validatePhone(telefono)){
                    if(DataValidations.isMobile(telefono)){
                        for (Account cuenta : [SELECT Id, Name, IsPersonAccount, Mobile__c, Other_Mobile__c , PersonMobilePhone, OtherMobilePhone__pc 
                                   				FROM Account
                                   				WHERE Mobile__c = :telefono
                                   				OR Other_Mobile__c = :telefono
                                   				OR PersonMobilePhone = :telefono
                                   				OR OtherMobilePhone__pc = :telefono
                                                LIMIT 10]) {
                        	LC_LookUpClienteAndLeadByPhoneController.Response response = new LC_LookUpClienteAndLeadByPhoneController.Response();
            				response.Id = cuenta.Id;
            				response.Name = cuenta.Name;  
            				response.Phone = telefono;
            				response.Tipo = cuenta.IsPersonAccount ? 'C. Física' : 'C. Jurídico';
            				listResponse.add(response);    
                        }
                        
                    }
                    else {
                        for (Account cuenta : [SELECT Id, Name, IsPersonAccount, Phone , Other_Phone__c , PersonOtherPhone 
                                   FROM Account
                                   WHERE Phone = :telefono
                                   OR Other_Phone__c = :telefono
                                   OR PersonOtherPhone = :telefono
                                   LIMIT 10]) {
            				LC_LookUpClienteAndLeadByPhoneController.Response response = new LC_LookUpClienteAndLeadByPhoneController.Response();
            				response.Id = cuenta.Id;
            				response.Name = cuenta.Name;  
            				response.Phone = telefono;
            				response.Tipo = cuenta.IsPersonAccount ? 'C. Física' : 'C. Jurídico';
            				listResponse.add(response);
            			}
                    }
                    for(Lead candidato: [select id, MobilePhone, Phone, Name  from lead Where MobilePhone = : telefono OR Phone =: telefono LIMIT 10 ]){
                            LC_LookUpClienteAndLeadByPhoneController.Response response = new LC_LookUpClienteAndLeadByPhoneController.Response();
                			response.Id = candidato.Id;
                			response.Name = candidato.Name;  
                			response.Phone = telefono;
                			response.Tipo = 'Candidato';
                			listResponse.add(response);	
                        }
                }
            }
            
        }
       
        String respuestaJSON = JSON.serialize(listResponse);
        
        return respuestaJSON;
	}
    
	@AuraEnabled
    public static String relacionar(String id, String idAux, String tipo) {
        String respuesta = '';
        MessagingSession mSession;
        MessagingEndUser mEndUser;
        MessagingChannel mChannel;
        system.debug('entro en la relacion id:'+ id + ' idAux:'+ idAux);
        
        if (!String.isBlank(id) && !String.isBlank(idAux)) {
            system.debug('entro en el no es vacío y el tipo es : '+ tipo);
            mSession = MessagingSessionGateway.getMessagingSessionById(id);
            mEndUser = mSession.MessagingEndUserId != null ? MessagingEndUserGateway.getMessagingEndUserByMSessionId(mSession.MessagingEndUserId): new MessagingEndUser();
            mChannel = MessagingChannelGateway.getMessagingChannelById(mSession.MessagingChannelId);
            if (tipo.equalsIgnoreCase('C. Física')){
                Account cuenta = AccountGateway.getAccountById(idAux);
                Contact contacto = ContactGateway.getContactByAccountId(idAux);
                
                mEndUser.AccountId = idAux;
                mEndUser.contactId = contacto.Id;
                mEndUser.Name = cuenta.Name;
                upsert mEndUser;
                if(mSession.LeadId != null){
                    mSession.LeadId = null;
                    upsert mSession;
                }
                respuesta ='Se ha relacionado correctamente.';
          	}
            else if(tipo.equalsIgnoreCase('C. Jurídico')){
               Account cuenta = AccountGateway.getAccountById(idAux);
                
                mEndUser.AccountId = cuenta.Id;
                mEndUser.Name = cuenta.Name;
                upsert mEndUser;
                
                if(mSession.LeadId != null){
                    mSession.LeadId = null;
                    upsert mSession;
                }
                respuesta ='Se ha relacionado correctamente.';
            }
        	else if (tipo.equalsIgnoreCase('Candidato')) {
               Lead candidato = LeadGateway.getLeadById(idAux);
               if(mSession.EndUserAccountId == null && mSession.EndUserContactId == null && candidato != null){
                    mEndUser.Lead__c = candidato.Id;
                	mEndUser.Name = candidato.Name;
                	upsert mEndUser;
                
                	mSession.LeadId = candidato.Id;
                	upsert mSession;
                    respuesta='Se ha relacionado correctamente.';
                }
               else {
                    respuesta =mSession.EndUserAccountId != null?'Error al relacionar a un candidato. Cliente relacionado.': 'Error candidato no encontrado';
                }
                
        	}
            
        }
        else {
            respuesta ='Error en la identificación. Avise al administrador.';
        }
        return respuesta;
    }
    
    public class Response {
        public String Id {get;set;}
        public String Name {get;set;}
        public String Phone {get;set;}
        public String Tipo {get;set;}
    }
}