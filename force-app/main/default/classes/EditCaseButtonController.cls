public class EditCaseButtonController {
    @AuraEnabled
    public static LiveChatTranscript getLiveChat(String id) {
        LiveChatTranscript chat;
        List<LiveChatTranscript> listChat = [SELECT Id,
                                                    CustomerName__c,
                                                    CustomerLastname__c,
                                                    CustomerEmail__c,
                                                    CustomerProblem__c,
                                                    AccountId,
                                                    ContactId,
                                                    LeadId,
                                             		CaseId,
                                                    Marca__c,
                                                    Modelo__c,
                                                    Unidad_de_negocio__c
                                 			 FROM LiveChatTranscript
                                             WHERE id = :id
                                             LIMIT 1]; 
        
        if (!listChat.isEmpty()) {
            chat = listChat[0];
        }
        
        return chat;
    }
    
    @AuraEnabled
    public static MessagingSession getMessagingSession(String id) {
        MessagingSession mSession;
        if(!String.isBlank(id)){
            mSession = MessagingSessionGateway.getMessagingSessionById(id);
        }
        system.debug('mSession:'+ mSession);
        return mSession;
    }
	
	@AuraEnabled
    public static String getCaseCreate(String id, String objectName){
        Case caso;
        if(objectName.equalsIgnoreCase('LiveChatTranscript')){
            LiveChatTranscript chat;
            List<LiveChatTranscript> listChat = [SELECT Id, CustomerName__c, CustomerLastname__c, CustomerEmail__c, CustomerProblem__c,
                                                    AccountId, ContactId, LeadId, CaseId, LiveChatButtonId, createdDate, Marca__c, Modelo__c, Unidad_de_negocio__c
                                             	FROM LiveChatTranscript WHERE id = :id LIMIT 1]; 
        	try{
        		if (!listChat.isEmpty()) {
            		chat = listChat[0];
            		List<configurationChat__mdt> confChats = [select id, chatId__c, DeveloperName, Label, Medio__c, Soporte__c, Subject__c  from configurationChat__mdt where chatId__c =:chat.LiveChatButtonId limit 1];
            		configurationChat__mdt confChat;
            		if(!confChats.isEmpty()){
            		    confChat = confChats[0];
            		}
            		String caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_chat').getRecordTypeId();
        			caso = new Case();
        			caso.RecordTypeId = caseRecordTypeId;
        			caso.CustomerEmail__c = chat.CustomerEmail__c;
        			caso.CustomerName__c= chat.CustomerName__c + ' ' + chat.CustomerLastname__c;
            		caso.SuppliedName = chat.CustomerName__c + ' ' + chat.CustomerLastname__c;
            		caso.SuppliedEmail = chat.CustomerEmail__c;
            		caso.CustomerProblem__c= chat.CustomerProblem__c;
        			caso.AccountId = chat.AccountId;
        			caso.ContactId = chat.ContactId;
        			caso.Lead__c = chat.LeadId;
                    caso.Marca__c = chat.Marca__c;
                    caso.Modelo__c = chat.Modelo__c;
                    caso.Unidad_de_negocio__c = chat.Unidad_de_negocio__c;
       	 			caso.Origin = 'Chat';
            		if(confChat != null){
            		    caso.Subject = confChat.Subject__c +' '+ chat.CreatedDate;
            			caso.Soporte__c = confChat.Soporte__c;
            		    caso.Medio__c = confChat.Medio__c;
            		}
            		insert caso;
            		chat.CaseId = caso.Id;
            		update chat;
        		}	
        	}catch(Exception e){
            	throw new AuraHandledException('Error: ' + e.getMessage());
        	}   	     
        }
        else if(objectName.equalsIgnoreCase('MessagingSession')){
            MessagingSession mSession = MessagingSessionGateway.getMessagingSessionById(id);
            if (mSession != null) {
                system.debug('Entra en mSession: '+ mSession);
                MessagingEndUser mUser = MessagingEndUserGateway.getMessagingEndUserByMSessionId(mSession.MessagingEndUserId);
                List<String> partKeys = mUser.MessagingPlatformKey.split(':');
            	String telefono = partKeys[1];
            	Account cuenta;
                if(mSession.EndUserAccountId != null){
                    cuenta = AccountGateway.getAccountById(mSession.EndUserAccountId);
                }
                caso = new Case();
                String caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_WhatsApp').getRecordTypeId();
        		caso.RecordTypeId = caseRecordTypeId;
                
                List<configurationWhatsApp__mdt> confWhats = [select id, channelId__c, DeveloperName, Label, Medio__c, Soporte__c, Subject__c  from configurationWhatsApp__mdt where channelId__c =:mSession.MessagingChannelId limit 1];
            	if(!confWhats.isEmpty()){
            		configurationWhatsApp__mdt confWhat = confWhats[0];
                    caso.Subject = confWhat.Subject__c +' '+ mSession.CreatedDate;
            		caso.Soporte__c = confWhat.Soporte__c;
            		caso.Medio__c = confWhat.Medio__c;
            	}
                if(cuenta != null){
                    caso.CustomerName__c = cuenta.Name;
            		caso.SuppliedName = cuenta.Name;
                    caso.AccountId = mSession.EndUserAccountId;
                
                }
                else {
                    caso.CustomerName__c= mSession.Nombre__c + ' ' + mSession.Apellidos__c;
            		caso.SuppliedName = mSession.Nombre__c + ' ' + mSession.Apellidos__c;
            	}
                //caso.CustomerName__c= mSession.Nombre__c + ' ' + mSession.Apellidos__c;
            	//caso.SuppliedName = mSession.Nombre__c + ' ' + mSession.Apellidos__c;
            	caso.SuppliedPhone = telefono ;
            	caso.CustomerProblem__c= mSession.Consulta__c;
                caso.Origin = mSession.ChannelType;
        	    caso.Lead__c = mSession.LeadId!= null ? mSession.LeadId:null;
                caso.ContactId = mSession.EndUserContactId != null ? mSession.EndUserContactId:null;
                caso.Marca__c = mSession.Marca__c;
                caso.Modelo__c = mSession.Modelo__c;
                caso.Unidad_de_negocio__c = mSession.Unidad_de_negocio__c;
                insert caso;
                
                mSession.CaseId = caso.Id;
            	update mSession;
                
            }
        }
        system.debug('caso:'+ caso);
        String caseId = caso != null ? caso.Id:null;
        
        return caseId;
    }
    
	/*
    @AuraEnabled
    public static String getCaseId(String id, String objectName){
        String casoId;
        if(objectName.equalsIgnoreCase('LiveChatTranscript')){
            LiveChatTranscript chat;
        	List<LiveChatTranscript> listChat = [SELECT Id, CaseId FROM LiveChatTranscript WHERE id = :id LIMIT 1]; 
        	
        	if (!listChat.isEmpty() && !String.isBlank(listChat[0].CaseId) ) {
        	    casoId = listChat[0].CaseId;
    		}
        }
        else if(objectName.equalsIgnoreCase('MessagingSession')){
            MessagingSession mSession = MessagingSessionGateway.getMessagingSessionById(id);
            if(mSession != null && !String.isBlank(mSession.CaseId )){
                casoId = mSession.CaseId;
            }
        }
        
        return casoId;
    }    
    */
    @AuraEnabled
    public static String getLeadCreate(String id, String objectName){
        Lead lead;
        if(objectName.equalsIgnoreCase('LiveChatTranscript')){
            LiveChatTranscript chat;
        	List<LiveChatTranscript> listChat = [SELECT Id,CustomerName__c,CustomerLastname__c,CustomerEmail__c,CustomerProblem__c,
                                                    	AccountId,ContactId,LeadId,CaseId
                                 			 	 FROM LiveChatTranscript WHERE id = :id LIMIT 1]; 
        	try{
        		if (!listChat.isEmpty()) {
        	    	chat = listChat[0];
        			lead = new Lead();
        			lead.Email = chat.CustomerEmail__c;
        			lead.FirstName= chat.CustomerName__c;
        	    	lead.LastName= chat.CustomerLastname__c;
        			insert lead;
        	    	chat.LeadId = lead.Id;
        	    	update chat;
        		}
        	}catch(Exception e){
        	    throw new AuraHandledException('Error: ' + e.getMessage());
        	}   
        }
        else if(objectName.equalsIgnoreCase('MessagingSession')){
            MessagingSession mSession = MessagingSessionGateway.getMessagingSessionById(id);
            if(mSession != null){
            	MessagingEndUser mUser = MessagingEndUserGateway.getMessagingEndUserByMSessionId(mSession.MessagingEndUserId);
            	List<String> partKeys = mUser.MessagingPlatformKey.split(':');
            	String telefono = partKeys[1];
            	lead = new Lead();
                if(!String.isBlank(mSession.Nombre__c)){
                    lead.FirstName = mSession.Nombre__c;
                    mUser.Name = mSession.Nombre__c;
                }
                if(!String.isBlank(mSession.Apellidos__c)){
                    lead.LastName = mSession.Apellidos__c;
                    mUser.Name +=' ' + mSession.Apellidos__c;
                }
                else {
                    lead.LastName = mUser.Name;
                }
        		
                lead.Phone = telefono;
        		insert lead;
                
        		mSession.LeadId = lead.Id;
                update mSession;
                
                mUser.Lead__c = lead.Id;
                update mUser;
            }
            
        }
        String leadId = lead != null ?lead.Id:null;
        return leadId;
    }
}