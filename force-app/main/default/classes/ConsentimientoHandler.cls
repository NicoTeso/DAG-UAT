public class ConsentimientoHandler implements ITriggerHandler {
    private TriggerExecutionHelper infoTrigger = new TriggerExecutionHelper();
    
    public Map<String, Account> mapCuentaById = new Map<String, Account>();
    public Map<String, Contact> mapContactById = new Map<String, Contact>();
    public Map<String, Lead> mapLeadById = new Map<String, Lead>();
    public Map<String, Map<String, Consentimientos__c>> mapConsentimientovalueByContactId = new Map<String, Map<String, Consentimientos__c>>();
    public Map<String, Map<String, Consentimientos__c>> mapConsentimientovalueByLeadId = new Map<String, Map<String, Consentimientos__c>>();

    public List<Account> listCuentaToUpsert = new List<Account>();
    public Map<String, Account> mapCuentaByIdToUpdate = new Map<String, Account>();
    public Map<String, Lead> mapLeadByIdToUpdate = new Map<String, Lead>();
   
    public Map<String,Consentimientos__c> mapConsentimientosToUpsert = new Map<String,Consentimientos__c>();
    public List<String> listSendMulesoftConsentimientosByContactId = new List<String>();
        
    public ConsentimientoHandler(Schema.sObjectType soType) {
        InfoTrigger.setTipoHandler(soType);
    }
    
    public TriggerExecutionHelper getInfo() {
        return infoTrigger;
    }
    
    public void bulkBefore() {
       listSendMulesoftConsentimientosByContactId.clear();
       ConsentimientoHelper.createMap();
    }
    
    public void bulkAfter() {
        mapCuentaByIdToUpdate.clear();
        mapCuentaById.clear();
        mapContactById.clear();
        mapLeadById.clear();
        mapConsentimientovalueByContactId.clear();
        mapConsentimientovalueByLeadId.clear();
        listCuentaToUpsert.clear();
        mapConsentimientosToUpsert.clear();
        listSendMulesoftConsentimientosByContactId.clear();
        
        if (Trigger.new != null) {
            List<String> listContactId = new List<String>();
            List<String> listAccountId = new List<String>();
            List<String> listLeadId = new List<String>();
            
            for (SObject objeto : Trigger.New) {
                Consentimientos__c consentimiento = (Consentimientos__c) objeto;
                
                if (!String.isBlank(consentimiento.Contact__c)) {
                    listContactId.add(consentimiento.Contact__c);
                }

                if (!String.isBlank(consentimiento.Lead__c)) {
                    listLeadId.add(consentimiento.Lead__c);
                }
            }

            if (!listLeadId.isEmpty()) {
                mapLeadById = LeadGateway.getLeadIdByIds(listLeadId);
                system.debug('mapLeadById:' + mapLeadById);
                mapConsentimientovalueByLeadId = ConsentimientosGateway.getConsentimientosByLeads(listLeadId);
            	system.debug('mapConsentimientovalueByLeadId: '+ mapConsentimientovalueByLeadId);
            }
            
            if (!listContactId.isEmpty()) {
                mapContactById = ContactGateway.getContactById(listContactId);
                system.debug('mapContactById:' + mapContactById);
                mapConsentimientovalueByContactId = ConsentimientosGateway.getConsentimientosByContacts(listContactId);
            	system.debug('mapConsentimientovalueByContactId: '+ mapConsentimientovalueByContactId);
            }
            
            if (!mapContactById.isEmpty()) {
                for (Contact contacto :mapContactById.values()) {
                    if (!String.isBlank(contacto.AccountId)) {
                        listAccountId.add(contacto.AccountId);
                    }
                }
            }
            
            if (!listAccountId.isEmpty()) {
               mapCuentaById =  AccountGateway.getAccountById(listAccountId);
            }
        }
    }
    
    public void beforeInsert(sObject so) {
        System.debug('BEFORE INSERT');
        Consentimientos__c consent = (Consentimientos__c) so;
        system.debug('consentmientos fecha:'+ consent.Fecha_de_captura__c);
        ConsentimientoHelper.validationsBefore(consent);
        ConsentimientoHelper.transformationsBefore(consent);
        
        
        //mandar consentimiento
        if(consent.EnviarAmulesoft__c && consent.Contact__c != null && !listSendMulesoftConsentimientosByContactId.contains(consent.Contact__c) ){
        	listSendMulesoftConsentimientosByContactId.add(consent.Contact__c);
        }
        else if (!consent.EnviarAmulesoft__c){
            consent.EnviarAmulesoft__c = true;
        }
    }
    
    public void beforeUpdate(sObject old, sObject so) {
        System.debug('BEFORE UPDATE');
        Consentimientos__c oldConsentimiento = (Consentimientos__c) old;
        Consentimientos__c consentimiento = (Consentimientos__c) so;
        Map<String, Schema.RecordTypeInfo> rtMapByDName = Schema.SObjectType.Consentimientos__c.getRecordTypeInfosByDeveloperName();
        List<String> recordTypeIds = new List<String>();
        recordTypeIds.add(rtMapByDName.get('Email').getRecordTypeId());        
        recordTypeIds.add(rtMapByDName.get('Movil').getRecordTypeId());
        recordTypeIds.add(rtMapByDName.get('Telefono').getRecordTypeId());        
        recordTypeIds.add(rtMapByDName.get(Label.RtConsentimientoNoEcosistema).getRecordTypeId());        
        
        system.debug('old:'+oldConsentimiento);
        system.debug('new:'+consentimiento);
        system.debug('oldEnvioMulesoft:'+oldConsentimiento.EnviarAmulesoft__c);
        system.debug('newEnvioMulesoft:'+consentimiento.EnviarAmulesoft__c);
        system.debug('consentmientos fecha:'+ consentimiento.Fecha_de_captura__c);
        system.debug('recordTypeIds: '+ recordTypeIds);
        
        
        ConsentimientoHelper.validationsBefore(consentimiento);
        ConsentimientoHelper.transformationsBefore(consentimiento);
        ConsentimientoHelper.transforUnknown(consentimiento, oldConsentimiento);
        
        
        if (oldConsentimiento.Fecha_de_captura__c == consentimiento.Fecha_de_captura__c && !UserInfo.getName().contains('Integrador') ) {
            consentimiento.Fecha_de_captura__c = Datetime.now();
        }
        
        //mandar consentimiento
        if (consentimiento.EnviarAmulesoft__c ) {
            system.debug ('consentimiento.EnviarAmulesoft__c: '+consentimiento.EnviarAmulesoft__c);
            if (consentimiento.Contact__c != null && !listSendMulesoftConsentimientosByContactId.contains(consentimiento.Contact__c) &&
                recordTypeIds.contains(consentimiento.RecordTypeId) &&
               (consentimiento.AfterSales__c != oldConsentimiento.AfterSales__c                      
             || consentimiento.AfterSalesSMS__c != oldConsentimiento.AfterSalesSMS__c   
             || consentimiento.ChannelValue__c != oldConsentimiento.ChannelValue__c     
             || consentimiento.EventInvitation__c != oldConsentimiento.EventInvitation__c
             || consentimiento.EventInvitationSMS__c != oldConsentimiento.EventInvitationSMS__c     
             || consentimiento.MarketResearch__c != oldConsentimiento.MarketResearch__c 
             || consentimiento.MarketResearchSMS__c != oldConsentimiento.MarketResearchSMS__c
             || consentimiento.ProductSale__c != oldConsentimiento.ProductSale__c                   
             || consentimiento.ProductSaleSMS__c != oldConsentimiento.ProductSaleSMS__c
             || consentimiento.CustomerSatisfactionSales__c != oldConsentimiento.CustomerSatisfactionSales__c
             || consentimiento.CustomerSatisfactionAfterSales__c != oldConsentimiento.CustomerSatisfactionAfterSales__c
             || consentimiento.eave__c != oldConsentimiento.eave__c
             || consentimiento.insurance__c != oldConsentimiento.insurance__c)) { 
                system.debug('pasa por aqui'); 
                listSendMulesoftConsentimientosByContactId.add(consentimiento.Contact__c);
			}
        }
        else {
            consentimiento.EnviarAmulesoft__c = true;
        }
        
        if (consentimiento.realCommunicationDate__c != null && consentimiento.entryDate__c == null ){
            consentimiento.entryDate__c = consentimiento.realCommunicationDate__c.addDays(15);
        }
    }
    
    public void beforeDelete(sObject so) {}
    
    public void afterInsert(sObject so) {
        Consentimientos__c consentimiento = (Consentimientos__c) so;
        String recordTypeDN = ConsentimientosGateway.getRecordTypeDeveloperNameById(consentimiento.RecordTypeId);
        
        Contact contacto = !String.isBlank(consentimiento.Contact__c) && mapContactById.containsKey(consentimiento.Contact__c)? mapContactById.get(consentimiento.Contact__c): null;
        Map<String, Consentimientos__c> mapConsentimientoByValue = contacto != null && mapConsentimientovalueByContactId.containsKey(contacto.Id)
            ? mapConsentimientovalueByContactId.get(contacto.id) : new Map<String,Consentimientos__c>();
        Account cuenta = contacto != null && mapCuentaById.containsKey(contacto.AccountId) ? mapCuentaById.get(contacto.AccountId) : null;
        
        if (cuenta != null && cuenta.IsPersonAccount) {
            Account cuentaToUpdate = mapCuentaByIdToUpdate.containsKey(cuenta.Id) ? mapCuentaByIdToUpdate.get(cuenta.Id) : cuenta;
            
            if (Label.channelEmail.equalsIgnoreCase(consentimiento.Medio_de_contacto__c) && !consentimiento.ChannelValue__c.equalsIgnoreCase(cuenta.PersonEmail)) {
                cuentaToUpdate.PersonEmail = consentimiento.ChannelValue__c;
                mapCuentaByIdToUpdate.put(cuentaToUpdate.Id, cuentaToUpdate);
            } 
            else if (Label.channelMobile.equalsIgnoreCase(consentimiento.Medio_de_contacto__c) && !consentimiento.ChannelValue__c.equalsIgnoreCase(cuenta.PersonMobilePhone)) {
                cuentaToUpdate.PersonMobilePhone = consentimiento.ChannelValue__c;
                mapCuentaByIdToUpdate.put(cuentaToUpdate.Id, cuentaToUpdate);
            }
            else if (Label.channelPhone.equalsIgnoreCase(consentimiento.Medio_de_contacto__c) && !consentimiento.ChannelValue__c.equalsIgnoreCase(cuenta.Phone)) {
                cuentaToUpdate.Phone = consentimiento.ChannelValue__c;
                mapCuentaByIdToUpdate.put(cuentaToUpdate.Id, cuentaToUpdate);
            }
            else if (Label.channelOtherEmail.equalsIgnoreCase(consentimiento.Medio_de_contacto__c) && !consentimiento.ChannelValue__c.equalsIgnoreCase(cuenta.OtherEmail__pc)) {
                cuentaToUpdate.OtherEmail__pc = consentimiento.ChannelValue__c;
                mapCuentaByIdToUpdate.put(cuentaToUpdate.Id, cuentaToUpdate);
            }
            else if (Label.channelOtherMobile.equalsIgnoreCase(consentimiento.Medio_de_contacto__c) && !consentimiento.ChannelValue__c.equalsIgnoreCase(cuenta.OtherMobilePhone__pc)) {
                cuentaToUpdate.OtherMobilePhone__pc = consentimiento.ChannelValue__c;
                mapCuentaByIdToUpdate.put(cuentaToUpdate.Id, cuentaToUpdate);
            }
            else if (Label.channelOtherPhone.equalsIgnoreCase(consentimiento.Medio_de_contacto__c) && !consentimiento.ChannelValue__c.equalsIgnoreCase(cuenta.PersonOtherPhone)) {
                cuentaToUpdate.PersonOtherPhone = consentimiento.ChannelValue__c;
                mapCuentaByIdToUpdate.put(cuentaToUpdate.Id, cuentaToUpdate);
            } 
            
            Boolean consentimientoTarget;
            if(recordTypeDN.equalsIgnoreCase('Telefono') || recordTypeDN.equalsIgnoreCase('Movil')){
               consentimientoTarget = consentimiento.AfterSales__c.equalsIgnoreCase('Allow') ? true : false;
               system.debug('01.- consentimientoTarget: '+consentimientoTarget); 

            }
            else{
                consentimientoTarget = false;
               system.debug('02.- consentimientoTarget: '+consentimientoTarget); 
            }
            boolean consentimientoEcosistema = false;
            if (recordTypeDN.equalsIgnoreCase('Email') || recordTypeDN.equalsIgnoreCase('Movil')){
                if (consentimiento.AfterSales__c.equalsIgnoreCase('Allow') ||
                    consentimiento.AfterSalesSMS__c.equalsIgnoreCase('Allow') ||
                    consentimiento.EventInvitation__c.equalsIgnoreCase('Allow') ||
                    consentimiento.EventInvitationSMS__c.equalsIgnoreCase('Allow') ||
                    consentimiento.ProductSale__c.equalsIgnoreCase('Allow') ||
                    consentimiento.ProductSaleSMS__c.equalsIgnoreCase('Allow') ||
                    consentimiento.MarketResearch__c.equalsIgnoreCase('Allow') ||
                    consentimiento.MarketResearchSMS__c.equalsIgnoreCase('Allow')){    
                    consentimientoEcosistema = true;
	               system.debug('01.- consentimientoEcosistema: '+consentimientoEcosistema); 
                }        
            }
            else{
                consentimientoEcosistema = false;
               system.debug('02.- consentimientoEcosistema: '+consentimientoEcosistema); 
            }
            for (String key : mapConsentimientoByValue.keySet()) {
                 Consentimientos__c consentimientoAux = mapConsentimientoByValue.get(key);
                 String recordTypeDNAux = ConsentimientosGateway.getRecordTypeDeveloperNameById(consentimientoAux.RecordTypeId);
                 //Mirar si hay que actualizar otro consentimiento
                 if (!consentimiento.Medio_de_contacto__c.equalsIgnoreCase(Label.channelOther) && consentimientoAux.Id != consentimiento.Id && recordTypeDNAux.equalsIgnoreCase(recordTypeDN) && consentimiento.Medio_de_contacto__c.equalsIgnoreCase(consentimientoAux.Medio_de_contacto__c)) {
                    	consentimientoAux.Medio_de_contacto__c = Label.channelOther;
                        mapConsentimientosToUpsert.put(consentimientoAux.ChannelValue__c,consentimientoAux);
                 }
              	 //Mira si tiene que actualizar si hay consentimiento Target
                 if(!consentimientoTarget && consentimientoAux.AfterSales__c.equalsIgnoreCase('Allow') && (recordTypeDNAux.equalsIgnoreCase('Telefono') || recordTypeDNAux.equalsIgnoreCase('Movil'))){
                    consentimientoTarget = true;
                    system.debug('03.- consentimientoTarget: '+consentimientoTarget); 
                 }
                 if (!consentimientoEcosistema && (recordTypeDNAux.equalsIgnoreCase('Email') || recordTypeDNAux.equalsIgnoreCase('Movil')) && 
                    (consentimientoAux.AfterSales__c.equalsIgnoreCase('Allow') ||
                     consentimientoAux.AfterSalesSMS__c.equalsIgnoreCase('Allow') ||
                     consentimientoAux.EventInvitation__c.equalsIgnoreCase('Allow') ||
                     consentimientoAux.EventInvitationSMS__c.equalsIgnoreCase('Allow') ||
                     consentimientoAux.ProductSale__c.equalsIgnoreCase('Allow') ||
                     consentimientoAux.ProductSaleSMS__c.equalsIgnoreCase('Allow') ||
                     consentimientoAux.MarketResearch__c.equalsIgnoreCase('Allow') ||
                     consentimientoAux.MarketResearchSMS__c.equalsIgnoreCase('Allow'))){    
                     consentimientoEcosistema = true;
                     system.debug('03.- consentimientoEcosistema: '+consentimientoEcosistema); 
                 }
            }

            system.debug('04.- consentimientoTarget: '+consentimientoTarget);
            system.debug('04.- consentimientoEcosistema: '+consentimientoEcosistema); 
            system.debug('cuentaToUpdate.Consentimiento_target__c: '+cuentaToUpdate.Consentimiento_target__c);
            system.debug('cuentaToUpdate.ConEcosistema__c: '+cuentaToUpdate.ConEcosistema__c);
            
            if (cuentaToUpdate.Consentimiento_target__c != consentimientoTarget || cuentaToUpdate.ConEcosistema__c !=consentimientoEcosistema){
                cuentaToUpdate.Consentimiento_target__c = consentimientoTarget;
                cuentaToUpdate.ConEcosistema__c = consentimientoEcosistema;
                mapCuentaByIdToUpdate.put(cuentaToUpdate.Id, cuentaToUpdate);
            }
            
            if(recordTypeDN.equalsIgnoreCase(Label.RtConsentimientoFichaUnica)){
                if((cuentaToUpdate.AceptadoComunicacionesWAH__c || cuentaToUpdate.PoliticaPrivacidadAceptada__c) &&
                  (consentimiento.oppositionDate__c != null || consentimiento.entryDate__c == null || (consentimiento.entryDate__c != null && consentimiento.entryDate__c > Datetime.now()))){
                    cuentaToUpdate.AceptadoComunicacionesWAH__c = false;
                    cuentaToUpdate.PoliticaPrivacidadAceptada__c = false;
               		mapCuentaByIdToUpdate.put(cuentaToUpdate.Id, cuentaToUpdate);
                }
                if(cuentaToUpdate.isFichaUnica__c &&
                  (consentimiento.oppositionDate__c != null || consentimiento.entryDate__c == null || (consentimiento.entryDate__c != null && consentimiento.entryDate__c > Datetime.now()))){
                    cuentaToUpdate.isFichaUnica__c = false;
                    mapCuentaByIdToUpdate.put(cuentaToUpdate.Id, cuentaToUpdate);
                }
                if(!cuentaToUpdate.isFichaUnica__c && 
                   consentimiento.oppositionDate__c == null && consentimiento.entryDate__c != null && consentimiento.entryDate__c <=Datetime.now()){
                	cuentaToUpdate.isFichaUnica__c = true;
                    mapCuentaByIdToUpdate.put(cuentaToUpdate.Id, cuentaToUpdate);
                }
        	}
		}

        Lead candidato = !String.isBlank(consentimiento.Lead__c) && mapLeadById.containsKey(consentimiento.Lead__c)? mapLeadById.get(consentimiento.Lead__c): null;
        Map<String, Consentimientos__c> mapConsentimientoByValue2 = candidato != null && mapConsentimientovalueByLeadId.containsKey(candidato.Id)
            ? mapConsentimientovalueByLeadId.get(candidato.id) : new Map<String,Consentimientos__c>();
        
        if (candidato != null) {
            Lead candidatoToUpdate = mapLeadByIdToUpdate.containsKey(candidato.Id) ? mapLeadByIdToUpdate.get(candidato.Id) : candidato;
            boolean consentimientoEcosistema = false;
            if (recordTypeDN.equalsIgnoreCase('Email') || recordTypeDN.equalsIgnoreCase('Movil')){
                if (consentimiento.AfterSales__c.equalsIgnoreCase('Allow') ||
                    consentimiento.AfterSalesSMS__c.equalsIgnoreCase('Allow') ||
                    consentimiento.EventInvitation__c.equalsIgnoreCase('Allow') ||
                    consentimiento.EventInvitationSMS__c.equalsIgnoreCase('Allow') ||
                    consentimiento.ProductSale__c.equalsIgnoreCase('Allow') ||
                    consentimiento.ProductSaleSMS__c.equalsIgnoreCase('Allow') ||
                    consentimiento.MarketResearch__c.equalsIgnoreCase('Allow') ||
                    consentimiento.MarketResearchSMS__c.equalsIgnoreCase('Allow')){    
                    consentimientoEcosistema = true;
	               system.debug('01.- consentimientoEcosistema: '+consentimientoEcosistema); 
                }        
            }
            else{
                consentimientoEcosistema = false;
               system.debug('02.- consentimientoEcosistema: '+consentimientoEcosistema); 
            }
            for (String key : mapConsentimientoByValue2.keySet()) {
                 Consentimientos__c consentimientoAux = mapConsentimientoByValue2.get(key);
                 String recordTypeDNAux = ConsentimientosGateway.getRecordTypeDeveloperNameById(consentimientoAux.RecordTypeId);
                 if (!consentimientoEcosistema && (recordTypeDNAux.equalsIgnoreCase('Email') || recordTypeDNAux.equalsIgnoreCase('Movil')) && 
                    (consentimientoAux.AfterSales__c.equalsIgnoreCase('Allow') ||
                     consentimientoAux.AfterSalesSMS__c.equalsIgnoreCase('Allow') ||
                     consentimientoAux.EventInvitation__c.equalsIgnoreCase('Allow') ||
                     consentimientoAux.EventInvitationSMS__c.equalsIgnoreCase('Allow') ||
                     consentimientoAux.ProductSale__c.equalsIgnoreCase('Allow') ||
                     consentimientoAux.ProductSaleSMS__c.equalsIgnoreCase('Allow') ||
                     consentimientoAux.MarketResearch__c.equalsIgnoreCase('Allow') ||
                     consentimientoAux.MarketResearchSMS__c.equalsIgnoreCase('Allow'))){    
                     consentimientoEcosistema = true;
                     system.debug('03.- consentimientoEcosistema: '+consentimientoEcosistema); 
                 }
            }

            system.debug('04.- consentimientoEcosistema: '+consentimientoEcosistema); 
            system.debug('candidatoToUpdate.ConEcosistema__c: '+candidatoToUpdate.ConEcosistema__c);
            
            if (candidatoToUpdate.ConEcosistema__c !=consentimientoEcosistema){
                candidatoToUpdate.ConEcosistema__c = consentimientoEcosistema;
                mapLeadByIdToUpdate.put(candidatoToUpdate.Id, candidatoToUpdate);
            }
            
		}
        
    }
    
    public void afterUpdate(sObject old, sObject so) {
        Consentimientos__c oldConsentimiento = (Consentimientos__c) old;
        Consentimientos__c consentimiento = (Consentimientos__c) so;
        system.debug('old:' + oldConsentimiento);
        system.debug('new:' + consentimiento);
        system.debug('oldEnvioMulesoft:' + oldConsentimiento.EnviarAmulesoft__c);
        system.debug('newEnvioMulesoft:' + consentimiento.EnviarAmulesoft__c);
        String recordTypeDN = ConsentimientosGateway.getRecordTypeDeveloperNameById(consentimiento.RecordTypeId);
        Contact contacto = !String.isBlank(consentimiento.Contact__c) && mapContactById.containsKey(consentimiento.Contact__c)
            ? mapContactById.get(consentimiento.Contact__c): null;
        Map<String,Consentimientos__c> mapConsentimientoByValue = contacto != null && mapConsentimientovalueByContactId.containsKey(contacto.Id)
            ? mapConsentimientovalueByContactId.get(contacto.id) : new Map<String,Consentimientos__c>();
        Account cuenta = contacto != null && mapCuentaById.containsKey(contacto.AccountId) ? mapCuentaById.get(contacto.AccountId) : null;
        System.debug('cuenta: '+ cuenta);
        
        if (cuenta != null && cuenta.IsPersonAccount) {
            Account cuentaToUpdate = mapCuentaByIdToUpdate.containsKey(cuenta.Id)?mapCuentaByIdToUpdate.get(cuenta.Id):cuenta;
            system.debug('consentimiento: medio:'+ consentimiento.Medio_de_contacto__c);
            
            if (Label.channelEmail.equalsIgnoreCase(consentimiento.Medio_de_contacto__c) && !consentimiento.ChannelValue__c.equalsIgnoreCase(cuenta.PersonEmail)) {
                cuentaToUpdate.PersonEmail = consentimiento.ChannelValue__c;
                mapCuentaByIdToUpdate.put(cuentaToUpdate.Id, cuentaToUpdate);
            } 
            else if (Label.channelMobile.equalsIgnoreCase(consentimiento.Medio_de_contacto__c) && !consentimiento.ChannelValue__c.equalsIgnoreCase(cuenta.PersonMobilePhone)) {
                cuentaToUpdate.PersonMobilePhone = consentimiento.ChannelValue__c;
                mapCuentaByIdToUpdate.put(cuentaToUpdate.Id, cuentaToUpdate);
            }
            else if (Label.channelPhone.equalsIgnoreCase(consentimiento.Medio_de_contacto__c) && !consentimiento.ChannelValue__c.equalsIgnoreCase(cuenta.Phone)) {
                cuentaToUpdate.Phone = consentimiento.ChannelValue__c;
                mapCuentaByIdToUpdate.put(cuentaToUpdate.Id, cuentaToUpdate);
            }
            else if (Label.channelOtherEmail.equalsIgnoreCase(consentimiento.Medio_de_contacto__c) && !consentimiento.ChannelValue__c.equalsIgnoreCase(cuenta.OtherEmail__pc)) {
                cuentaToUpdate.OtherEmail__pc = consentimiento.ChannelValue__c;
                mapCuentaByIdToUpdate.put(cuentaToUpdate.Id, cuentaToUpdate);
            }
            else if (Label.channelOtherMobile.equalsIgnoreCase(consentimiento.Medio_de_contacto__c) && !consentimiento.ChannelValue__c.equalsIgnoreCase(cuenta.OtherMobilePhone__pc)) {
                cuentaToUpdate.OtherMobilePhone__pc = consentimiento.ChannelValue__c;
                mapCuentaByIdToUpdate.put(cuentaToUpdate.Id, cuentaToUpdate);
            }
            else if (Label.channelOtherPhone.equalsIgnoreCase(consentimiento.Medio_de_contacto__c) && !consentimiento.ChannelValue__c.equalsIgnoreCase(cuenta.PersonOtherPhone)) {
                cuentaToUpdate.PersonOtherPhone = consentimiento.ChannelValue__c;
                mapCuentaByIdToUpdate.put(cuentaToUpdate.Id, cuentaToUpdate);
            }
        	
            Boolean consentimientoTarget;
            if(recordTypeDN.equalsIgnoreCase('Telefono') || recordTypeDN.equalsIgnoreCase('Movil')){
               consentimientoTarget = consentimiento.AfterSales__c.equalsIgnoreCase('Allow') ? true : false;
               system.debug('05.- consentimientoTarget: '+consentimientoTarget); 

            }
            else{
                consentimientoTarget = false;
               system.debug('06.- consentimientoTarget: '+consentimientoTarget); 

            }
            boolean consentimientoEcosistema = false;
            if (recordTypeDN.equalsIgnoreCase('Email') || recordTypeDN.equalsIgnoreCase('Movil')){
                if (consentimiento.AfterSales__c.equalsIgnoreCase('Allow') ||
                    consentimiento.AfterSalesSMS__c.equalsIgnoreCase('Allow') ||
                    consentimiento.EventInvitation__c.equalsIgnoreCase('Allow') ||
                    consentimiento.EventInvitationSMS__c.equalsIgnoreCase('Allow') ||
                    consentimiento.ProductSale__c.equalsIgnoreCase('Allow') ||
                    consentimiento.ProductSaleSMS__c.equalsIgnoreCase('Allow') ||
                    consentimiento.MarketResearch__c.equalsIgnoreCase('Allow') ||
                    consentimiento.MarketResearchSMS__c.equalsIgnoreCase('Allow')){    
                    consentimientoEcosistema = true;
	               system.debug('05.- consentimientoEcosistema: '+consentimientoEcosistema); 
                }        
            }
            else{
                consentimientoEcosistema = false;
               system.debug('06.- consentimientoEcosistema: '+consentimientoEcosistema); 
            }
            
            for (String key : mapConsentimientoByValue.keySet()) {
                 Consentimientos__c consentimientoAux = mapConsentimientoByValue.get(key);
                 String recordTypeDNAux = ConsentimientosGateway.getRecordTypeDeveloperNameById(consentimientoAux.RecordTypeId);
                 //Mirar si hay que actualizar otro consentimiento
        	     if (!consentimiento.Medio_de_contacto__c.equalsIgnoreCase(Label.channelOther) && consentimientoAux.Id != consentimiento.Id && recordTypeDNAux.equalsIgnoreCase(recordTypeDN) && consentimiento.Medio_de_contacto__c.equalsIgnoreCase(consentimientoAux.Medio_de_contacto__c)) {
                     consentimientoAux.Medio_de_contacto__c = Label.channelOther;
                     mapConsentimientosToUpsert.put(consentimientoAux.ChannelValue__c,consentimientoAux);
                 }
                 	
                 //Mira si tiene que actualizar si hay consentimiento Target
                 if(!consentimientoTarget && consentimientoAux.AfterSales__c.equalsIgnoreCase('Allow') && (recordTypeDNAux.equalsIgnoreCase('Telefono') || recordTypeDNAux.equalsIgnoreCase('Movil'))){
                     consentimientoTarget = true;
                     system.debug('07.- consentimientoTarget: '+consentimientoTarget); 
                 }
                 
                 if (!consentimientoEcosistema && (recordTypeDNAux.equalsIgnoreCase('Email') || recordTypeDNAux.equalsIgnoreCase('Movil')) && 
                    (consentimientoAux.AfterSales__c.equalsIgnoreCase('Allow') ||
                     consentimientoAux.AfterSalesSMS__c.equalsIgnoreCase('Allow') ||
                     consentimientoAux.EventInvitation__c.equalsIgnoreCase('Allow') ||
                     consentimientoAux.EventInvitationSMS__c.equalsIgnoreCase('Allow') ||
                     consentimientoAux.ProductSale__c.equalsIgnoreCase('Allow') ||
                     consentimientoAux.ProductSaleSMS__c.equalsIgnoreCase('Allow') ||
                     consentimientoAux.MarketResearch__c.equalsIgnoreCase('Allow') ||
                     consentimientoAux.MarketResearchSMS__c.equalsIgnoreCase('Allow'))){    
                     consentimientoEcosistema = true;
                     system.debug('07.- consentimientoEcosistema: '+consentimientoEcosistema); 
                 }
            }
            
            system.debug('08.- consentimientoTarget: '+consentimientoTarget);
            system.debug('08.- consentimientoEcosistema: '+consentimientoEcosistema); 
            system.debug('cuentaToUpdate.Consentimiento_target__c: '+cuentaToUpdate.Consentimiento_target__c);
            system.debug('cuentaToUpdate.ConEcosistema__c: '+cuentaToUpdate.ConEcosistema__c);

            if (cuentaToUpdate.Consentimiento_target__c != consentimientoTarget || cuentaToUpdate.ConEcosistema__c !=consentimientoEcosistema){
                cuentaToUpdate.Consentimiento_target__c = consentimientoTarget;
                cuentaToUpdate.ConEcosistema__c = consentimientoEcosistema;
                mapCuentaByIdToUpdate.put(cuentaToUpdate.Id, cuentaToUpdate);
            }

            if(recordTypeDN.equalsIgnoreCase(Label.RtConsentimientoFichaUnica)){
                if((cuentaToUpdate.AceptadoComunicacionesWAH__c || cuentaToUpdate.PoliticaPrivacidadAceptada__c) &&
                  (consentimiento.oppositionDate__c != null || consentimiento.entryDate__c == null || (consentimiento.entryDate__c != null && consentimiento.entryDate__c > Datetime.now()))){
                    cuentaToUpdate.AceptadoComunicacionesWAH__c = false;
                    cuentaToUpdate.PoliticaPrivacidadAceptada__c = false;
               		mapCuentaByIdToUpdate.put(cuentaToUpdate.Id, cuentaToUpdate);
                }
                if(cuentaToUpdate.isFichaUnica__c &&
                  (consentimiento.oppositionDate__c != null || consentimiento.entryDate__c == null || (consentimiento.entryDate__c != null && consentimiento.entryDate__c > Datetime.now()))){
                    cuentaToUpdate.isFichaUnica__c = false;
                    mapCuentaByIdToUpdate.put(cuentaToUpdate.Id, cuentaToUpdate);
                }
                if(!cuentaToUpdate.isFichaUnica__c && 
                   consentimiento.oppositionDate__c == null && consentimiento.entryDate__c != null && consentimiento.entryDate__c <=Datetime.now()){
                	cuentaToUpdate.isFichaUnica__c = true;
                    mapCuentaByIdToUpdate.put(cuentaToUpdate.Id, cuentaToUpdate);
                }
        	}
        }

        
        Lead candidato = !String.isBlank(consentimiento.Lead__c) && mapLeadById.containsKey(consentimiento.Lead__c)? mapLeadById.get(consentimiento.Lead__c): null;
        Map<String, Consentimientos__c> mapConsentimientoByValue2 = candidato != null && mapConsentimientovalueByLeadId.containsKey(candidato.Id)
            ? mapConsentimientovalueByLeadId.get(candidato.id) : new Map<String,Consentimientos__c>();
        
        if (candidato != null) {
            Lead candidatoToUpdate = mapLeadByIdToUpdate.containsKey(candidato.Id) ? mapLeadByIdToUpdate.get(candidato.Id) : candidato;
            boolean consentimientoEcosistema = false;
            if (recordTypeDN.equalsIgnoreCase('Email') || recordTypeDN.equalsIgnoreCase('Movil')){
                if (consentimiento.AfterSales__c.equalsIgnoreCase('Allow') ||
                    consentimiento.AfterSalesSMS__c.equalsIgnoreCase('Allow') ||
                    consentimiento.EventInvitation__c.equalsIgnoreCase('Allow') ||
                    consentimiento.EventInvitationSMS__c.equalsIgnoreCase('Allow') ||
                    consentimiento.ProductSale__c.equalsIgnoreCase('Allow') ||
                    consentimiento.ProductSaleSMS__c.equalsIgnoreCase('Allow') ||
                    consentimiento.MarketResearch__c.equalsIgnoreCase('Allow') ||
                    consentimiento.MarketResearchSMS__c.equalsIgnoreCase('Allow')){    
                    consentimientoEcosistema = true;
	               system.debug('01.- consentimientoEcosistema: '+consentimientoEcosistema); 
                }        
            }
            else{
                consentimientoEcosistema = false;
               system.debug('02.- consentimientoEcosistema: '+consentimientoEcosistema); 
            }
            for (String key : mapConsentimientoByValue2.keySet()) {
                 Consentimientos__c consentimientoAux = mapConsentimientoByValue2.get(key);
                 String recordTypeDNAux = ConsentimientosGateway.getRecordTypeDeveloperNameById(consentimientoAux.RecordTypeId);
                 if (!consentimientoEcosistema && (recordTypeDNAux.equalsIgnoreCase('Email') || recordTypeDNAux.equalsIgnoreCase('Movil')) && 
                    (consentimientoAux.AfterSales__c.equalsIgnoreCase('Allow') ||
                     consentimientoAux.AfterSalesSMS__c.equalsIgnoreCase('Allow') ||
                     consentimientoAux.EventInvitation__c.equalsIgnoreCase('Allow') ||
                     consentimientoAux.EventInvitationSMS__c.equalsIgnoreCase('Allow') ||
                     consentimientoAux.ProductSale__c.equalsIgnoreCase('Allow') ||
                     consentimientoAux.ProductSaleSMS__c.equalsIgnoreCase('Allow') ||
                     consentimientoAux.MarketResearch__c.equalsIgnoreCase('Allow') ||
                     consentimientoAux.MarketResearchSMS__c.equalsIgnoreCase('Allow'))){    
                     consentimientoEcosistema = true;
                     system.debug('03.- consentimientoEcosistema: '+consentimientoEcosistema); 
                 }
            }

            system.debug('04.- consentimientoEcosistema: '+consentimientoEcosistema); 
            system.debug('candidatoToUpdate.ConEcosistema__c: '+candidatoToUpdate.ConEcosistema__c);
            
            if (candidatoToUpdate.ConEcosistema__c !=consentimientoEcosistema){
                candidatoToUpdate.ConEcosistema__c = consentimientoEcosistema;
                mapLeadByIdToUpdate.put(candidatoToUpdate.Id, candidatoToUpdate);
            }
            
		}
    }
    
    public void afterDelete(sObject so) {}
    
    public void andFinally() {
        system.debug('mapConsentimientosToUpsert: '+ mapConsentimientosToUpsert);
        if(!mapConsentimientosToUpsert.isEmpty()){
            update mapConsentimientosToUpsert.values();
        }
        system.debug('listCuentaToUpsert:'+mapCuentaByIdToUpdate);
        if (!mapCuentaByIdToUpdate.isEmpty()) {
            update mapCuentaByIdToUpdate.values();
        }
        system.debug('listLeadToUpsert:'+mapLeadByIdToUpdate);
        if (!mapLeadByIdToUpdate.isEmpty()) {
            update mapLeadByIdToUpdate.values();
        }
        system.debug('listSendMulesoftConsentimientosByContactId: '+ listSendMulesoftConsentimientosByContactId);
        if(!listSendMulesoftConsentimientosByContactId.isEmpty()){
            ExternalServiceController.sendConsentimientoMulesfoft(JSON.serialize(listSendMulesoftConsentimientosByContactId));
        }
    }
}