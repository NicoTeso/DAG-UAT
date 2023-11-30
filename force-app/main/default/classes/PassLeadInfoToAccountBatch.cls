global class PassLeadInfoToAccountBatch implements Database.Batchable<sObject>, Schedulable {
    
    public void execute(SchedulableContext sc) {
        Id batchJobId = Database.executeBatch(new PassLeadInfoToAccountBatch(),5);
    }
    
	global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([select id from DuplicateRecordSet]);
    }
    
    global void execute(Database.BatchableContext BC, List<DuplicateRecordSet> lstDuplicateSet) {
        Map<String, List<DuplicateRecordItem>> mapDuplicateSetToItems = new Map<String, List<DuplicateRecordItem>>();
        List<String> duplicateIdSet = new List<String>();
        List<String> leadId = new List<String>();
        List<String> accountId = new List<String>();
        system.debug('setDuplicados:' + lstDuplicateSet);
        
        for (DuplicateRecordSet duplicateSet: lstDuplicateSet) {
            duplicateIdSet.add(duplicateSet.Id);
        }
        
        for (DuplicateRecordItem item : [SELECT Id, RecordId, DuplicateRecordSetId FROM DuplicateRecordItem WHERE DuplicateRecordSetId in :duplicateIdSet]) {
            List<DuplicateRecordItem> duplicateItemAux = mapDuplicateSetToItems.containsKey(item.DuplicateRecordSetId)
                ? mapDuplicateSetToItems.get(item.DuplicateRecordSetId) : new List<DuplicateRecordItem>();
            
            if (Lead.sObjectType == item.RecordId.getSObjectType()) {
                leadId.add(item.RecordId);
            }
            else if (Account.sObjectType == item.RecordId.getSObjectType()) {
                accountId.add(item.RecordId);
            }
            
            duplicateItemAux.add(item);
            mapDuplicateSetToItems.put(item.DuplicateRecordSetId, duplicateItemAux);
        }
        
        Map<String, List<Case>> mapLeadCases = new Map<String, List<Case>>();
        Map<String, List<LiveChatTranscript>> mapLeadLiveChat = new Map<String, List<LiveChatTranscript>>();
        Map<String,Contact> mapContactByAccount = new Map<String,Contact>();
        Map<String,Map<String,Consentimientos__c>> mapConsentimientoByLead = new Map<String,Map<String,Consentimientos__c>>();
        Map<String,String> mapUserByProfileId = new Map<String,String>();
        List<String> profileIds = new List<String>();
        system.debug('leadIds:'+ leadId);
        system.debug('accountId:'+ accountId);
        
        if (!leadId.isEmpty()) {
            for (Case caso : [SELECT Id, Lead__c, AccountId, OwnerId, Owner.IsActive, Owner.ProfileId, Unidad_de_negocio__c FROM Case WHERE Lead__c in :leadId]) {
                List<Case> casesAux = mapLeadCases.containsKey(caso.Lead__c)?mapLeadCases.get(caso.Lead__c) : new List<Case>();
                casesAux.add(caso);
                mapLeadCases.put(caso.Lead__c, casesAux);
                if (!caso.Owner.IsActive) {
                    profileIds.add(caso.Owner.ProfileId);    
                }
            }
           
            if (!profileIds.isEmpty()) {
                for (User usuario : [SELECT Id, ProfileId FROM User WHERE ProfileId in :profileIds AND IsActive = true]) {
                    if (!mapUserByProfileId.containsKey(usuario.ProfileId)) {
                        mapUserByProfileId.put(usuario.ProfileId, usuario.Id);
                   }
                }    
            }
           
            System.debug('mapUserByProfileId: '+mapUserByProfileId); 
           
            for (LiveChatTranscript chat : [SELECT Id, LeadId, AccountId FROM LiveChatTranscript WHERE LeadId in :leadId]) {
                List<LiveChatTranscript> chatsAux = mapLeadLiveChat.containsKey(chat.LeadId)?mapLeadLiveChat.get(chat.LeadId) : new List<LiveChatTranscript>();
                chatsAux.add(chat);
                mapLeadLiveChat.put(chat.LeadId, chatsAux);
            }
            mapConsentimientoByLead = ConsentimientosGateway.getConsentimientosByLeadId(leadId);
        }

        if (!accountId.isEmpty()) {
            mapContactByAccount = ContactGateway.getContactByAccountId(accountId);
        }
        
        List<LiveChatTranscript> listChatToUpdate = new List<LiveChatTranscript>();
        List<Case> listCaseToUpdate = new List<Case>();
        List<Consentimientos__c> listConsentimientoToUpdate = new List<Consentimientos__c>();
        List<Id> listLeadToDelete = new List<Id>();
        List<Id> listDRecordSetDelete = new List<Id>();
        List<Id> listDRecordItemDelete = new List<Id>();
        List<Consentimientos__c> listConsentimientoDelete = new List<Consentimientos__c>();
        
        for (String duplicateId : mapDuplicateSetToItems.keySet()) {
            List<DuplicateRecordItem> duplicateItemAux = mapDuplicateSetToItems.get(duplicateId);
            system.debug('duplicateItemAux:' + duplicateItemAux);
            
            if (duplicateItemAux.size() ==  2) {
                Account accountAux;
                Lead leadAux;
                DuplicateRecordItem item1 = duplicateItemAux[0];
                DuplicateRecordItem item2 = duplicateItemAux[1];
                
                if (Lead.sObjectType == item1.RecordId.getSObjectType()) {
                	leadAux = new Lead(Id = item1.RecordId);
                    listDRecordItemDelete.add(item1.Id);
                    
                    if (Account.sObjectType == item2.RecordId.getSObjectType()) {
                        accountAux = new Account(Id = item2.RecordId);
                    }
            	}
            	else if (Account.sObjectType == item1.RecordId.getSObjectType()) {
                    accountAux = new Account(Id = item1.RecordId);
                    
                    if (Lead.sObjectType == item2.RecordId.getSObjectType()) {
                        leadAux = new Lead(Id = item2.RecordId);
                        listDRecordItemDelete.add(item2.Id);
                    }
                }
                
                if (accountAux != null && leadAux != null) {
                    Contact contacto = mapContactByAccount.containsKey(accountAux.Id)?mapContactByAccount.get(accountAux.Id) : null;
                    List<Case> casos = mapLeadCases.containsKey(leadAux.Id)?mapLeadCases.get(leadAux.Id) : null;
                    List<LiveChatTranscript> chats = mapLeadLiveChat.containsKey(leadAux.Id)?mapLeadLiveChat.get(leadAux.Id) : null;
                    Map<String,Consentimientos__c> mapConsentimientoByVaueLead =  mapConsentimientoByLead.containsKey(leadAux.Id)? mapConsentimientoByLead.get(leadAux.Id): new Map<String,Consentimientos__c>();
                    
                    system.debug('mapConsentimientoByVaueLead: '+mapConsentimientoByVaueLead);
                     
                    if (casos != null && !casos.isEmpty()) {
                        for(Case caso : casos) {
                            if (caso.Owner.IsActive == false) {
                                caso.OwnerId = mapUserByProfileId.containsKey(caso.Owner.ProfileId)?mapUserByProfileId.get(caso.Owner.ProfileId): caso.OwnerId; 
                            }
                            caso.AccountId = accountAux.Id;
                            caso.ContactId = contacto != null ? contacto.Id:null;
                            caso.Lead__c = null;
                            listCaseToUpdate.add(caso);
                        }
                    }

			        system.debug('listCaseToUpdate:'+ listCaseToUpdate);
			        if (!listCaseToUpdate.isEmpty()) {
			            update listCaseToUpdate;
			        }
                    
                    if (chats != null && !chats.isEmpty()) {
                        for (LiveChatTranscript chat : chats) {
                            chat.AccountId = accountAux.Id;
                            chat.ContactId = contacto != null ? contacto.id : null;
                            chat.LeadId = null;
                            listChatToUpdate.add(chat);
                        }
                    }

        			Map<String,Map<String,Consentimientos__c>> mapConsentimientoByAccount = new Map<String,Map<String,Consentimientos__c>>();
                    List<String> ListAccountId = new List<String>();
                    ListAccountId.add(accountAux.Id);
                    mapConsentimientoByAccount = ConsentimientosGateway.getConsentimientosByAccountId(ListAccountId);
                    Map<String,Consentimientos__c> mapConsentimientoByValueAccount = mapConsentimientoByAccount.containsKey(accountAux.Id)? mapConsentimientoByAccount.get(accountAux.Id): new Map<String,Consentimientos__c>();
                    system.debug('mapConsentimientoByValueAccount: '+mapConsentimientoByValueAccount);
                    
                    for(Consentimientos__c conse : mapConsentimientoByVaueLead.values()){
                        system.debug('conse: '+conse);
                        system.debug('mapConsentimientoByValueAccount.containsKey(conse.ChannelValue__c): '+mapConsentimientoByValueAccount.containsKey(conse.ChannelValue__c));
                        if(mapConsentimientoByValueAccount.containsKey(conse.ChannelValue__c)){
                            System.debug('entra por 1');
                            Consentimientos__c conseAccount = mapConsentimientoByValueAccount.get(conse.ChannelValue__c);
                            
                            if((conseAccount.Fecha_de_captura__c!= null && conse.Fecha_de_captura__c != null && conseAccount.Fecha_de_captura__c < conse.Fecha_de_captura__c)
                              ||(conseAccount.Fecha_de_captura__c == null && conse.Fecha_de_captura__c != null) ){
                               listConsentimientoDelete.add(conse);
                               	   conseAccount.AfterSales__c = conse.AfterSales__c;
                               	   conseAccount.AfterSalesSMS__c = conse.AfterSalesSMS__c;
                               	   conseAccount.CustomerSatisfaction__c = conse.CustomerSatisfaction__c;
                                   conseAccount.CustomerSatisfactionSMS__c = conse.CustomerSatisfactionSMS__c;
                                   conseAccount.EventInvitation__c= conse.EventInvitation__c;
                                   conseAccount.EventInvitationSMS__c = conse.EventInvitationSMS__c;
                                   conseAccount.Fecha_de_captura__c = conse.Fecha_de_captura__c;
                                   conseAccount.MarketResearch__c= conse.MarketResearch__c;
                                   conseAccount.MarketResearchSMS__c= conse.MarketResearchSMS__c;
                                   conseAccount.ProductSale__c= conse.ProductSale__c;
                                   conseAccount.ProductSaleSMS__c= conse.ProductSaleSMS__c;
                               	   conseAccount.EnviarAmulesoft__c = false;
                               listConsentimientoToUpdate.add(conseAccount);
                            System.debug('entra por 2 '+ conseAccount);
                            }
                            else {
                                listConsentimientoDelete.add(conse);
                            System.debug('entra por 3 '+ conse);
                            }
                        }
                        else {
                            conse.Contact__c = contacto != null? contacto.Id:null;
                            conse.Lead__c = null;
                            conse.EnviarAmulesoft__c = false;
                            conse.Medio_de_contacto__c = Label.channelOther;
                            listConsentimientoToUpdate.add(conse);
                            System.debug('entra por 4 '+ conse);
                        }
                    }
                    listLeadToDelete.add(leadAux.Id);
                    listDRecordSetDelete.add(duplicateId);
                }
            }
        }
        
        system.debug('listChatToUpdate:' + listChatToUpdate);
        if (!listChatToUpdate.isEmpty()) {
            update listChatToUpdate;
        }
        
        system.debug('listConsentimientoToUpdate:'+ listConsentimientoToUpdate);
        if (!listConsentimientoToUpdate.isEmpty()) {
            update listConsentimientoToUpdate;
        }
        
        system.debug('listConsentimientoDelete:'+ listConsentimientoDelete);
        if (!listConsentimientoDelete.isEmpty()) {
            Database.delete(listConsentimientoDelete);
        }

        system.debug('listDRecordSetDelete:'+ listDRecordSetDelete);
        system.debug('listDRecordItemDelete:'+ listDRecordItemDelete);
        if (!listDRecordSetDelete.isEmpty()) {
            if(!listDRecordItemDelete.isEmpty()){
                Database.delete(listDRecordItemDelete);
            }
            system.debug('listLeadToDelete:'+ listLeadToDelete);
        	if (!listLeadToDelete.isEmpty()) {
            	Database.delete(listLeadToDelete);
        	}

            Database.delete(listDRecordSetDelete);
        }
    }
    
    global void finish(Database.BatchableContext BC) {}
}