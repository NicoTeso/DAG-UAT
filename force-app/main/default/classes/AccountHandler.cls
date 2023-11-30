public with sharing class AccountHandler implements ITriggerHandler {
    private TriggerExecutionHelper infoTrigger = new TriggerExecutionHelper();
    
    public Map<String, Pais__c> mapPaisById = new Map<String, Pais__c>();
    public Map<String, Map<String, Consentimientos__c>> mapConsentimientoValueByAccountId = new Map<String,Map<String, Consentimientos__c>>();
   	public Map<String, Map<String, Consentimientos__c>> mapConsentimientoValueByAccountIdToUpdate = new Map<String, Map<String, Consentimientos__c>>();
    public List<Delete_Account_Marketing__c> listDeleteAccToUpsert = new List<Delete_Account_Marketing__c>();
    public List<Delete_Account_Marketing__c> listDeleteAccToDelete = new List<Delete_Account_Marketing__c>();
    public List<Consentimientos__c> listConsentimientoTOInsert = new List<Consentimientos__c>();
    public User UsuarioInt = new User();
    public Map<String, Genero_de_Nombre__c> mapGenderNames = new Map<String, Genero_de_Nombre__c>();
    public Map<String,Invalid_Emails__c> mapInvalidEmailByEmail = new Map<String,Invalid_Emails__c>();
    public Map<String, Delete_Account_Marketing__c> mapRegIdToDAM = new Map<String, Delete_Account_Marketing__c>();
    public Map<String, Schema.RecordTypeInfo> rtMapConsentimientoByName = new Map<String, Schema.RecordTypeInfo>();
   
    public AccountHandler(Schema.sObjectType soType) {
        InfoTrigger.setTipoHandler(soType);
    }
    
    public TriggerExecutionHelper getInfo() {
        return infoTrigger;
    }
    
    public void bulkBefore() {
        mapPaisById.clear();
        mapGenderNames.clear();
        mapInvalidEmailByEmail.clear();
        listDeleteAccToUpsert.clear();
        listDeleteAccToDelete.clear();
        List<String> paisesId = new List<String>();
        List<String> lstNombrePais = new List<String>();
        List<String> listEmails = new List<String>();
	    List<String> listIds = new List<String>();
        
        UsuarioInt = CacheUtil.getIntegrador();
        
        if (Trigger.new != null) {
            for (SObject objeto : Trigger.New) {
                Account cuenta = (Account) objeto;
                
                if (cuenta.Pais__c != null) {
                    paisesId.add(cuenta.Pais__c);
                }

            }
        
            if (!paisesId.isEmpty()){
	            mapPaisById = PaisGateway.getPaisById(paisesId);	
            }

            for (SObject objeto : Trigger.New) {
                Account cuenta = (Account) objeto;

                if (cuenta.isPersonAccount) {

	                if (!cuenta.SyncMKTCloud__c) {
		                listIds.add(cuenta.Id);
                        listIds.add(cuenta.PersonContactId);
	                }
                    
                	if (cuenta.FirstName != null) {
                		string NombrePais = Accents.removeDiacritics(DataValidations.getFormattedName(cuenta.FirstName)) + (cuenta.Pais__c != null && mapPaisById.containsKey(cuenta.Pais__c) && !String.isBlank(mapPaisById.get(cuenta.Pais__c).ISO_31661_alfa2__c) ? '/' + mapPaisById.get(cuenta.Pais__c).ISO_31661_alfa2__c : '/ES');
                    	lstNombrePais.add(NombrePais);
                	}
                	if(cuenta.PersonEmail != null){
                    	listEmails.add(cuenta.PersonEmail);
                	}
                	if(cuenta.OtherEmail__pc != null){
                    	listEmails.add(cuenta.OtherEmail__pc);
                	}
                } else{
                	if(cuenta.Email__c != null){
                    	listEmails.add(cuenta.Email__c);
                	}
                	if(cuenta.Other_Email__c != null){
                    	listEmails.add(cuenta.Other_Email__c);
                	}
                }
            }

            
            if (!lstNombrePais.isEmpty()){
	            mapGenderNames = GenderNamesGateway.getGenderNamesByNombrePais(lstNombrePais);
            }    

            if(!listEmails.isEmpty()){
                mapInvalidEmailByEmail = InvalidEmailGateway.getInvalidEmailByEmail(listEmails);
            }   

            if (!listIds.isEmpty()){
	            mapRegIdToDAM = DeleteAccountMarketingGateway.getDAMByRegId(listIds);
            }   

            
        }
    }

    public void bulkAfter() {
        mapConsentimientoValueByAccountId.clear();
        mapConsentimientoValueByAccountIdToUpdate.clear();
        listDeleteAccToUpsert.clear();
        rtMapConsentimientoByName = Schema.SObjectType.Consentimientos__c.getRecordTypeInfosByName();

        
        if (Trigger.new != null) {
            List<String> listId = new List<String>();
            
            for (SObject objeto : Trigger.New) {
                Account cuenta = (Account) objeto;
                listId.add(cuenta.Id);
            }
            
            mapConsentimientoValueByAccountId = ConsentimientosGateway.getConsentimientosByAccountId(listId);
        }
    }

    public void beforeInsert(sObject so) {
        System.debug('BEFORE INSERT');
        Account acc = (Account) so;
        AccountHelper.validationsBefore(acc, mapPaisById, mapInvalidEmailByEmail);
        if (acc.isPersonAccount) {
            string NombrePais = Accents.removeDiacritics(DataValidations.getFormattedName(acc.FirstName)) + (acc.Pais__c != null && mapPaisById.containsKey(acc.Pais__c) && !String.isBlank(mapPaisById.get(acc.Pais__c).ISO_31661_alfa2__c) ? '/' + mapPaisById.get(acc.Pais__c).ISO_31661_alfa2__c : '/ES');
            system.debug('NombrePais: '+NombrePais);
            if (!mapGenderNames.isEmpty()){
	            acc.gender__pc = mapGenderNames.containsKey(NombrePais)? mapGenderNames.get(NombrePais).Genero_Asignado__c : null;
            }                                              
            system.debug('acc.gender__pc: '+acc.gender__pc);
        }    

        AccountHelper.transformationsBefore(acc, null);

        If (UsuarioInt != null) {
	        acc.OwnerId = UsuarioInt.Id;
        }                                     

        if (acc.isPersonAccount && 
          ((acc.PersonEmail != null || acc.PersonMobilePhone != null || 
            acc.OtherEmail__pc != null || acc.OtherMobilePhone__pc != null) &&
           (acc.ConCasosMKTImp__c || (acc.ConCasosMKTNoImp__c && acc.ConEcosistema__c) ||
            acc.ConTUA__c || acc.ConVehiculo__c || acc.ConEnvioFUMobility__c ||
           (acc.ConOportunidad__c && acc.ConEcosistema__c) ||
           (acc.IsCustomerPortal && acc.ConEcosistema__c)))) {
            acc.SyncMKTCloud__c = true;
            acc.SyncMKTCloud__pc = true;
        }    
    }
    
    public void beforeUpdate(sObject old, sObject so) {
        System.debug('BEFORE UPDATE');
        Account acc = (Account) so;
        Account accOld =(Account) old;
        AccountHelper.validationsBefore(acc, mapPaisById, mapInvalidEmailByEmail);
        if (acc.isPersonAccount) {
            system.debug('acc.FirstName: '+acc.FirstName);
            system.debug('accOld.FirstName: '+accOld.FirstName);
            if (acc.FirstName != accOld.FirstName || acc.Pais__c != accOld.Pais__c) {
                system.debug('entra a limpiar genero');
                acc.gender__pc = null;
            }
            if (acc.gender__pc == null) {
                string NombrePais = Accents.removeDiacritics(DataValidations.getFormattedName(acc.FirstName)) + (acc.Pais__c != null && mapPaisById.containsKey(acc.Pais__c) && !String.isBlank(mapPaisById.get(acc.Pais__c).ISO_31661_alfa2__c) ? '/' + mapPaisById.get(acc.Pais__c).ISO_31661_alfa2__c : '/ES');
                system.debug('NombrePais: '+NombrePais);
                if (!mapGenderNames.isEmpty()){
	                acc.gender__pc = mapGenderNames.containsKey(NombrePais)? mapGenderNames.get(NombrePais).Genero_Asignado__c : null;
                }                                              
                system.debug('acc.gender__pc: '+acc.gender__pc);
            }
        }    
        AccountHelper.transformationsBefore(acc, accOld);

        if (acc.isPersonAccount && 
          ((acc.PersonEmail != null || acc.PersonMobilePhone != null || 
            acc.OtherEmail__pc != null || acc.OtherMobilePhone__pc != null) &&
           (acc.ConCasosMKTImp__c || (acc.ConCasosMKTNoImp__c && acc.ConEcosistema__c) ||
            acc.ConTUA__c || acc.ConVehiculo__c || acc.ConEnvioFUMobility__c ||
           (acc.ConOportunidad__c && acc.ConEcosistema__c) ||
           (acc.IsCustomerPortal && acc.ConEcosistema__c)))) {
            acc.SyncMKTCloud__c = true;
            acc.SyncMKTCloud__pc = true;
            if (mapRegIdToDAM.containsKey(acc.Id)) {
	        	listDeleteAccToDelete.add(mapRegIdToDAM.get(acc.Id));
            }    
            if (mapRegIdToDAM.containsKey(acc.PersonContactId)) {
	        	listDeleteAccToDelete.add(mapRegIdToDAM.get(acc.PersonContactId));
            }    
        } else if (acc.SyncMKTCloud__c){
            acc.SyncMKTCloud__c = false;     
	        Delete_Account_Marketing__c dam = new Delete_Account_Marketing__c();
	        dam.RecordId__c = acc.Id;
	        dam.Fecha_eliminacion__c = Date.today().addDays(integer.valueOf(Label.DaysDeleteMKTCloud));
	        listDeleteAccToUpsert.add(dam);
	        if (acc.IsPersonAccount == true){
	            acc.SyncMKTCloud__pc = false;
		        Delete_Account_Marketing__c dam1 = new Delete_Account_Marketing__c();	
    	    	dam1.RecordId__c = acc.PersonContactId;
        		dam1.Fecha_eliminacion__c = Date.today().addDays(integer.valueOf(Label.DaysDeleteMKTCloud));
        		listDeleteAccToUpsert.add(dam1);
        	}
        }
        
    }
    
    public void beforeDelete(sObject so) {}
    
    public void afterInsert(sObject so) {
        Account cuenta = (Account) so;
       	String recordTypeDeveloperName = AccountGateway.getRecordTypeDeveloperNameById(cuenta.RecordTypeId);
        System.debug('recordTypeDeveloperName: ' + recordTypeDeveloperName);
        
        
    }
    
    public void afterUpdate(sObject old, sObject so) {
        Account cuenta = (Account) so;
       	String recordTypeDeveloperName = AccountGateway.getRecordTypeDeveloperNameById(cuenta.RecordTypeId);
        System.debug('recordTypeDeveloperName:'+ recordTypeDeveloperName);
        
        if (Label.RtAccountPerson.equalsIgnoreCase(recordTypeDeveloperName)) {
        	System.debug('mapConsentimientoValueByAccountId: ' + mapConsentimientoValueByAccountId);
            
            //Consentimientos
            if (mapConsentimientoValueByAccountId.containsKey(cuenta.Id)) {
                Map<String, Consentimientos__c> mapConsentimientoByValue = mapConsentimientoValueByAccountId.get(cuenta.Id);
                Boolean enviarSima = true;
                if(system.isBatch() || system.isFuture() || system.isQueueable()){
                    enviarSima = false;
                }
                system.debug('enviar a Sima:'+ enviarSima);
                //Email
                if (!String.isBlank(cuenta.PersonEmail)){ 
                    if (mapConsentimientoByValue.containsKey(cuenta.PersonEmail)) {
	                    Consentimientos__c consentimiento = mapConsentimientoByValue.get(cuenta.PersonEmail);
		                if (consentimiento != null && !Label.channelEmail.equalsIgnoreCase(consentimiento.Medio_de_contacto__c)) {
                        	Map<String,Consentimientos__c> mapConsentimientoByValueToUpdate = mapConsentimientoValueByAccountIdToUpdate.containsKey(cuenta.Id)
                            	? mapConsentimientoValueByAccountIdToUpdate.get(cuenta.Id) : new Map<String, Consentimientos__c>();
                        	Consentimientos__c consentimientosToUpdate = mapConsentimientoByValueToUpdate.containsKey(cuenta.PersonEmail)
                            	? mapConsentimientoByValueToUpdate.get(cuenta.PersonEmail) : new Consentimientos__c();
                        	consentimientosToUpdate.Id = consentimiento.Id;
                        	consentimientosToUpdate.Medio_de_contacto__c = Label.channelEmail;
                        	consentimientosToUpdate.EnviarAmulesoft__c = enviarSima;
                        	mapConsentimientoByValueToUpdate.put(cuenta.PersonEmail, consentimientosToUpdate);
                        	mapConsentimientoValueByAccountIdToUpdate.put(cuenta.Id, mapConsentimientoByValueToUpdate);
                    	}
                    } 
/*                    
                    else {
                        system.debug('pasa consentimiento 11');
				        Consentimientos__c consent = new Consentimientos__c();
						consent.ChannelValue__c = cuenta.PersonEmail;
						consent.Medio_de_contacto__c = Label.channelEmail;
						consent.RecordTypeId = rtMapConsentimientoByName.get('Email').getRecordTypeId();
						consent.CustomerSatisfaction__c = 'Unknown';
						consent.MarketResearch__c = 'Unknown';
						consent.EventInvitation__c = 'Unknown';
						consent.AfterSales__c = 'Unknown';
						consent.ProductSale__c = 'Unknown';
						consent.CustomerSatisfactionSMS__c = 'Unknown';
						consent.MarketResearchSMS__c = 'Unknown';
						consent.AfterSalesSMS__c = 'Unknown';
						consent.ProductSaleSMS__c = 'Unknown';
						consent.EventInvitationSMS__c = 'Unknown';
				        consent.EnviarAmulesoft__c = false;
                        consent.Contact__c = cuenta.PersonContactId;
                        listConsentimientoTOInsert.add(consent);
                    }
*/
                }
                
                //Telefono
                if (!String.isBlank(cuenta.Phone)){
                	if (mapConsentimientoByValue.containsKey(cuenta.Phone)){
                    	Consentimientos__c consentimiento = mapConsentimientoByValue.get(cuenta.Phone);
                    	if(consentimiento != null && !Label.channelPhone.equalsIgnoreCase(consentimiento.Medio_de_contacto__c)){
                        	Map<String,Consentimientos__c> mapConsentimientoByValueToUpdate = mapConsentimientoValueByAccountIdToUpdate.containsKey(cuenta.Id) ? mapConsentimientoValueByAccountIdToUpdate.get(cuenta.Id):new Map<String,Consentimientos__c>();
                        	Consentimientos__c consentimientosToUpdate = mapConsentimientoByValueToUpdate.containsKey(cuenta.Phone) ? mapConsentimientoByValueToUpdate.get(cuenta.Phone):new Consentimientos__c();
                        	consentimientosToUpdate.Id = consentimiento.Id;
                        	consentimientosToUpdate.Medio_de_contacto__c = Label.channelPhone;
                        	consentimientosToUpdate.EnviarAmulesoft__c = enviarSima;
                        	mapConsentimientoByValueToUpdate.put(cuenta.Phone, consentimientosToUpdate);
                        	mapConsentimientoValueByAccountIdToUpdate.put(cuenta.Id, mapConsentimientoByValueToUpdate);
                    	}
                    }
/*                    
                    else {
                        system.debug('pasa consentimiento 21');
				        Consentimientos__c consent = new Consentimientos__c();
						consent.ChannelValue__c = cuenta.Phone;
						consent.Medio_de_contacto__c = Label.channelPhone;
						consent.RecordTypeId = rtMapConsentimientoByName.get('Teléfono').getRecordTypeId();
						consent.CustomerSatisfaction__c = 'Unknown';
						consent.MarketResearch__c = 'Unknown';
						consent.EventInvitation__c = 'Unknown';
						consent.AfterSales__c = 'Unknown';
						consent.ProductSale__c = 'Unknown';
						consent.CustomerSatisfactionSMS__c = 'Unknown';
						consent.MarketResearchSMS__c = 'Unknown';
						consent.AfterSalesSMS__c = 'Unknown';
						consent.ProductSaleSMS__c = 'Unknown';
						consent.EventInvitationSMS__c = 'Unknown';
				        consent.EnviarAmulesoft__c = false;
                        consent.Contact__c = cuenta.PersonContactId;
                        listConsentimientoTOInsert.add(consent);
                    }
*/
                }    
                
                //Movil
                if (!String.isBlank(cuenta.PersonMobilePhone)){
                    
                    if (mapConsentimientoByValue.containsKey(cuenta.PersonMobilePhone)) {
                        Consentimientos__c consentimiento = mapConsentimientoByValue.get(cuenta.PersonMobilePhone);
                        
                        if (consentimiento != null && !Label.channelMobile.equalsIgnoreCase(consentimiento.Medio_de_contacto__c)) {
                            Map<String, Consentimientos__c> mapConsentimientoByValueToUpdate = mapConsentimientoValueByAccountIdToUpdate.containsKey(cuenta.Id)
                                ? mapConsentimientoValueByAccountIdToUpdate.get(cuenta.Id) : new Map<String,Consentimientos__c>();
                            Consentimientos__c consentimientosToUpdate = mapConsentimientoByValueToUpdate.containsKey(cuenta.PersonMobilePhone)
                                ? mapConsentimientoByValueToUpdate.get(cuenta.PersonMobilePhone) : new Consentimientos__c();
                            consentimientosToUpdate.Id = consentimiento.Id;
                            consentimientosToUpdate.Medio_de_contacto__c = Label.channelMobile;
                            consentimientosToUpdate.EnviarAmulesoft__c = enviarSima;
                            mapConsentimientoByValueToUpdate.put(cuenta.PersonMobilePhone, consentimientosToUpdate);
                            mapConsentimientoValueByAccountIdToUpdate.put(cuenta.Id, mapConsentimientoByValueToUpdate);
                        }
                    }
/*                    
                    else {
                        system.debug('pasa consentimiento 31');
				        Consentimientos__c consent = new Consentimientos__c();
						consent.ChannelValue__c = cuenta.PersonMobilePhone;
						consent.Medio_de_contacto__c = Label.channelMobile;
						consent.RecordTypeId = rtMapConsentimientoByName.get('Móvil').getRecordTypeId();
						consent.CustomerSatisfaction__c = 'Unknown';
						consent.MarketResearch__c = 'Unknown';
						consent.EventInvitation__c = 'Unknown';
						consent.AfterSales__c = 'Unknown';
						consent.ProductSale__c = 'Unknown';
						consent.CustomerSatisfactionSMS__c = 'Unknown';
						consent.MarketResearchSMS__c = 'Unknown';
						consent.AfterSalesSMS__c = 'Unknown';
						consent.ProductSaleSMS__c = 'Unknown';
						consent.EventInvitationSMS__c = 'Unknown';
				        consent.EnviarAmulesoft__c = false;
                        consent.Contact__c = cuenta.PersonContactId;
                        listConsentimientoTOInsert.add(consent);
                    }
*/                    
                }    
                
                //Otro Email
                if (!String.isBlank(cuenta.OtherEmail__pc)){
                    if (mapConsentimientoByValue.containsKey(cuenta.OtherEmail__pc)) {
                        Consentimientos__c consentimiento = mapConsentimientoByValue.get(cuenta.OtherEmail__pc);
                        
                        if (consentimiento != null && !Label.channelOtherEmail.equalsIgnoreCase(consentimiento.Medio_de_contacto__c)) {
                            Map<String,Consentimientos__c> mapConsentimientoByValueToUpdate = mapConsentimientoValueByAccountIdToUpdate.containsKey(cuenta.Id)
                                ? mapConsentimientoValueByAccountIdToUpdate.get(cuenta.Id) : new Map<String,Consentimientos__c>();
                            Consentimientos__c consentimientosToUpdate = mapConsentimientoByValueToUpdate.containsKey(cuenta.OtherEmail__pc)
                                ? mapConsentimientoByValueToUpdate.get(cuenta.OtherEmail__pc) : new Consentimientos__c();
                            consentimientosToUpdate.Id = consentimiento.Id;
                            consentimientosToUpdate.Medio_de_contacto__c = Label.channelOtherEmail;
                            consentimientosToUpdate.EnviarAmulesoft__c = enviarSima;
                            mapConsentimientoByValueToUpdate.put(cuenta.OtherEmail__pc, consentimientosToUpdate);
                            mapConsentimientoValueByAccountIdToUpdate.put(cuenta.Id, mapConsentimientoByValueToUpdate);
                        }
                    }
/*                    
                    else {
                        system.debug('pasa consentimiento 41');
				        Consentimientos__c consent = new Consentimientos__c();
						consent.ChannelValue__c = cuenta.OtherEmail__pc;
						consent.Medio_de_contacto__c = Label.channelOtherEmail;
						consent.RecordTypeId = rtMapConsentimientoByName.get('Email').getRecordTypeId();
						consent.CustomerSatisfaction__c = 'Unknown';
						consent.MarketResearch__c = 'Unknown';
						consent.EventInvitation__c = 'Unknown';
						consent.AfterSales__c = 'Unknown';
						consent.ProductSale__c = 'Unknown';
						consent.CustomerSatisfactionSMS__c = 'Unknown';
						consent.MarketResearchSMS__c = 'Unknown';
						consent.AfterSalesSMS__c = 'Unknown';
						consent.ProductSaleSMS__c = 'Unknown';
						consent.EventInvitationSMS__c = 'Unknown';
				        consent.EnviarAmulesoft__c = false;
                        system.debug('consent: '+consent);
                        listConsentimientoTOInsert.add(consent);
                        consent.Contact__c = cuenta.PersonContactId;
                        system.debug('listConsentimientoTOInsert: '+listConsentimientoTOInsert);
                    }
*/
                }
                
                //Otro telefono
                if (!String.isBlank(cuenta.PersonOtherPhone)){
                    if(mapConsentimientoByValue.containsKey(cuenta.PersonOtherPhone)) {
                        Consentimientos__c consentimiento = mapConsentimientoByValue.get(cuenta.PersonOtherPhone);
                        
                        if (consentimiento != null && !Label.channelOtherPhone.equalsIgnoreCase(consentimiento.Medio_de_contacto__c)) {
                            Map<String,Consentimientos__c> mapConsentimientoByValueToUpdate = mapConsentimientoValueByAccountIdToUpdate.containsKey(cuenta.Id)
                                ? mapConsentimientoValueByAccountIdToUpdate.get(cuenta.Id) : new Map<String,Consentimientos__c>();
                            Consentimientos__c consentimientosToUpdate = mapConsentimientoByValueToUpdate.containsKey(cuenta.PersonOtherPhone)
                                ? mapConsentimientoByValueToUpdate.get(cuenta.PersonOtherPhone) : new Consentimientos__c();
                            consentimientosToUpdate.Id = consentimiento.Id;
                            consentimientosToUpdate.Medio_de_contacto__c = Label.channelOtherPhone;
                            consentimientosToUpdate.EnviarAmulesoft__c = enviarSima;
                            mapConsentimientoByValueToUpdate.put(cuenta.PersonOtherPhone, consentimientosToUpdate);
                            mapConsentimientoValueByAccountIdToUpdate.put(cuenta.Id, mapConsentimientoByValueToUpdate);
                        }
                    }
/*                    
                    else {
                        system.debug('pasa consentimiento 51');
				        Consentimientos__c consent = new Consentimientos__c();
						consent.ChannelValue__c = cuenta.PersonOtherPhone;
						consent.Medio_de_contacto__c = Label.channelOtherPhone;
						consent.RecordTypeId = rtMapConsentimientoByName.get('Teléfono').getRecordTypeId();
						consent.CustomerSatisfaction__c = 'Unknown';
						consent.MarketResearch__c = 'Unknown';
						consent.EventInvitation__c = 'Unknown';
						consent.AfterSales__c = 'Unknown';
						consent.ProductSale__c = 'Unknown';
						consent.CustomerSatisfactionSMS__c = 'Unknown';
						consent.MarketResearchSMS__c = 'Unknown';
						consent.AfterSalesSMS__c = 'Unknown';
						consent.ProductSaleSMS__c = 'Unknown';
						consent.EventInvitationSMS__c = 'Unknown';
				        consent.EnviarAmulesoft__c = false;
                        consent.Contact__c = cuenta.PersonContactId;
                        listConsentimientoTOInsert.add(consent);
                    }
*/
                }    
                
                //Otro movil
                if (!String.isBlank(cuenta.OtherMobilePhone__pc)){
                    if (mapConsentimientoByValue.containsKey(cuenta.OtherMobilePhone__pc)) {
                        Consentimientos__c consentimiento = mapConsentimientoByValue.get(cuenta.OtherMobilePhone__pc);
                        
                        if (consentimiento != null && !Label.channelOtherMobile.equalsIgnoreCase(consentimiento.Medio_de_contacto__c)) {
                            Map<String,Consentimientos__c> mapConsentimientoByValueToUpdate = mapConsentimientoValueByAccountIdToUpdate.containsKey(cuenta.Id)
                                ? mapConsentimientoValueByAccountIdToUpdate.get(cuenta.Id) : new Map<String,Consentimientos__c>();
                            Consentimientos__c consentimientosToUpdate = mapConsentimientoByValueToUpdate.containsKey(cuenta.OtherMobilePhone__pc)
                                ? mapConsentimientoByValueToUpdate.get(cuenta.OtherMobilePhone__pc) : new Consentimientos__c();
                            consentimientosToUpdate.Id = consentimiento.Id;
                            consentimientosToUpdate.Medio_de_contacto__c = Label.channelOtherMobile;
                            consentimientosToUpdate.EnviarAmulesoft__c = enviarSima;
                            mapConsentimientoByValueToUpdate.put(cuenta.OtherMobilePhone__pc, consentimientosToUpdate);
                            mapConsentimientoValueByAccountIdToUpdate.put(cuenta.Id, mapConsentimientoByValueToUpdate);
                        }
                    }
/*                    
                    else {
				        Consentimientos__c consent = new Consentimientos__c();
						consent.ChannelValue__c = cuenta.OtherMobilePhone__pc;
						consent.Medio_de_contacto__c = Label.channelOtherMobile;
						consent.RecordTypeId = rtMapConsentimientoByName.get('Móvil').getRecordTypeId();
						consent.CustomerSatisfaction__c = 'Unknown';
						consent.MarketResearch__c = 'Unknown';
						consent.EventInvitation__c = 'Unknown';
						consent.AfterSales__c = 'Unknown';
						consent.ProductSale__c = 'Unknown';
						consent.CustomerSatisfactionSMS__c = 'Unknown';
						consent.MarketResearchSMS__c = 'Unknown';
						consent.AfterSalesSMS__c = 'Unknown';
						consent.ProductSaleSMS__c = 'Unknown';
						consent.EventInvitationSMS__c = 'Unknown';
				        consent.EnviarAmulesoft__c = false;
                        consent.Contact__c = cuenta.PersonContactId;
                        listConsentimientoTOInsert.add(consent);
                    }
*/
                }    
            }
        }
    }
    
    public void afterDelete(sObject so) {
        Account cuenta = (Account) so;
        Delete_Account_Marketing__c dam = new Delete_Account_Marketing__c();
        dam.RecordId__c = cuenta.Id;
        dam.Fecha_eliminacion__c = Date.today().addDays(integer.valueOf(Label.DaysDeleteMKTCloud));
        listDeleteAccToUpsert.add(dam);
        if (cuenta.IsPersonAccount == true){
	        Delete_Account_Marketing__c dam1 = new Delete_Account_Marketing__c();
    	    dam1.RecordId__c = cuenta.PersonContactId;
        	dam1.Fecha_eliminacion__c = Date.today().addDays(integer.valueOf(Label.DaysDeleteMKTCloud));
        	listDeleteAccToUpsert.add(dam1);
        }
    }
    
    public void andFinally() {
        if (!mapConsentimientoValueByAccountIdToUpdate.isEmpty()) {
            List<Consentimientos__c> listConsentimientoTOUpdate = new List<Consentimientos__c>();
            
            for (String accountId : mapConsentimientoValueByAccountIdToUpdate.keySet()) {
                Map<String, Consentimientos__c> mapConsentimientoByValue = mapConsentimientoValueByAccountIdToUpdate.get(accountId);
            	System.debug('mapConsentimientoByValue: ' + mapConsentimientoByValue);
                listConsentimientoTOUpdate.addAll(mapConsentimientoByValue.values());
            }
            
            update listConsentimientoTOUpdate;
        }
        
        system.debug('listConsentimientoTOInsert'+listConsentimientoTOInsert); 
        if(!listConsentimientoTOInsert.isEmpty()){
            insert listConsentimientoTOInsert;
        }
        if(!listDeleteAccToUpsert.isEmpty()){
            upsert listDeleteAccToUpsert;
        }
    }
}