public class ConsentimientosGateway {
    private static Map<String, Schema.RecordTypeInfo> rtMapByDeveloperName;
    private static Map<Id, Schema.RecordTypeInfo> rtMapById;
    
    public static String getRecordTypeIdByDeveloperName(String developerName) {
        if (rtMapByDeveloperName == null) {
            rtMapByDeveloperName = new Map<String,Schema.RecordTypeInfo>();
            rtMapByDeveloperName = Schema.SObjectType.Consentimientos__c.getRecordTypeInfosByDeveloperName();
        }
        
		return rtMapByDeveloperName.get(developerName).getRecordTypeId();
    }
    
    public static String getRecordTypeDeveloperNameById(String recordTypeId) {
        if (rtMapById == null) {
            rtMapById = new Map<Id,Schema.RecordTypeInfo>();
            rtMapById = Schema.SObjectType.Consentimientos__c.getRecordTypeInfosById();
        }
        
        system.debug('recordTypeId:' + recordTypeId);
        system.debug('rtMapById:' + rtMapById);
		return rtMapById.get(recordTypeId).getDeveloperName();
    }
    
    public static Map<String, Map<String, Consentimientos__c>> getConsentimientosByContacts(List<String> listContactId) {
        Map<String, Map<String, Consentimientos__c>> mapConsentimientovalueByContactId = new Map<String, Map<String, Consentimientos__c>>();
        List<String> recordTypeIds = new List<String>();
        recordTypeIds.add(getRecordTypeIdByDeveloperName('Email'));
        recordTypeIds.add(getRecordTypeIdByDeveloperName('Movil'));
        recordTypeIds.add(getRecordTypeIdByDeveloperName('Telefono'));
        String recordTypeIdESatisfacion = getRecordTypeIdByDeveloperName(Label.RtConsentimientoNoEcosistema);
        recordTypeIds.add(recordTypeIdESatisfacion);
        
        if (!listContactId.isEmpty()) {
            for(Consentimientos__c consentimiento : [SELECT Id, ChannelValue__c, Medio_de_contacto__c, RecordTypeId, RecordType.Name, Contact__c, Fecha_de_captura__c, AfterSales__c, AfterSalesSMS__c, CustomerSatisfaction__c, CustomerSatisfactionSMS__c, 
                                                    EnviarAmulesoft__c,EventInvitation__c, EventInvitationSMS__c, MarketResearch__c, MarketResearchSMS__c, ProductSale__c, ProductSaleSMS__c,
                                                    Concesionario__c,Concesionario__r.Id_Concesionario_Sima__c,CustomerSatisfactionAfterSales__c,CustomerSatisfactionSales__c, eave__c, Insurance__c
                                                    FROM Consentimientos__c
                                                    WHERE Contact__c in :listContactId AND RecordTypeId in :recordTypeIds]) {
                Map<String, Consentimientos__c> mapAux =  mapConsentimientovalueByContactId.containsKey(consentimiento.contact__c)
                    ? mapConsentimientovalueByContactId.get(consentimiento.contact__c) : new Map<String,Consentimientos__c>();
                if(recordTypeIdESatisfacion.equalsIgnoreCase(consentimiento.RecordTypeId)){
                     mapAux.put(consentimiento.Concesionario__r.Id_Concesionario_Sima__c, consentimiento);                       
               	}
               	else {
               		mapAux.put(consentimiento.ChannelValue__c, consentimiento);
                }
                mapConsentimientovalueByContactId.put(consentimiento.Contact__c, mapAux);
           }
       }     
        
        return mapConsentimientovalueByContactId;
    }
    
    public static Map<String, Consentimientos__c> getConsentimientosByContact(String contactId) {
        Map<String, Consentimientos__c> mapConsentimientovalue = new Map<String, Consentimientos__c>();
        List<String> recordTypeIds = new List<String>();
        recordTypeIds.add(getRecordTypeIdByDeveloperName('Email'));
        recordTypeIds.add(getRecordTypeIdByDeveloperName('Movil'));
        recordTypeIds.add(getRecordTypeIdByDeveloperName('Telefono'));
        String recordTypeIdESatisfacion = getRecordTypeIdByDeveloperName(Label.RtConsentimientoNoEcosistema);
        recordTypeIds.add(recordTypeIdESatisfacion);
        
        if (!String.isBlank(contactId)) {
            for(Consentimientos__c consentimiento : [SELECT Id, ChannelValue__c, Medio_de_contacto__c, RecordTypeId, RecordType.Name, Contact__c, Fecha_de_captura__c, AfterSales__c, AfterSalesSMS__c, CustomerSatisfaction__c, CustomerSatisfactionSMS__c, 
                                                    EnviarAmulesoft__c,EventInvitation__c, EventInvitationSMS__c, MarketResearch__c, MarketResearchSMS__c, ProductSale__c, ProductSaleSMS__c,
                                                    Concesionario__c,Concesionario__r.Id_Concesionario_Sima__c,CustomerSatisfactionAfterSales__c,CustomerSatisfactionSales__c, eave__c, Insurance__c
                                                    FROM Consentimientos__c
                                                    WHERE Contact__c = :contactId AND RecordTypeId in :recordTypeIds]) {
                if(recordTypeIdESatisfacion.equalsIgnoreCase(consentimiento.RecordTypeId)){
                     mapConsentimientovalue.put(consentimiento.Concesionario__r.Id_Concesionario_Sima__c, consentimiento);                       
               	}
               	else {
               		mapConsentimientovalue.put(consentimiento.ChannelValue__c, consentimiento);
                }
           }
       }     
        
        return mapConsentimientovalue;
    }
    
    
    //
    public static Map<String, Consentimientos__c> getConsentimientosValueByAccountIdLabels(String accountId) {
        Map<String, Consentimientos__c> mapConsentimientosByValue = new Map<String, Consentimientos__c>();
        List<String> recordTypeIds = new List<String>();
        recordTypeIds.add(getRecordTypeIdByDeveloperName('Email'));
        recordTypeIds.add(getRecordTypeIdByDeveloperName('Movil'));
        recordTypeIds.add(getRecordTypeIdByDeveloperName('Telefono'));
        if (!String.isBlank(accountId)) {
            for (Consentimientos__c consentimiento : [SELECT Id, ChannelValue__c, Medio_de_contacto__c, RecordTypeId, Contact__c, Fecha_de_captura__c,
                                                      		 toLabel(AfterSales__c), toLabel(AfterSalesSMS__c),toLabel(CustomerSatisfaction__c), toLabel(CustomerSatisfactionSMS__c),
                                                     		 EnviarAmulesoft__c,toLabel(EventInvitation__c), toLabel(EventInvitationSMS__c), toLabel(MarketResearch__c),
                                                      		 toLabel(MarketResearchSMS__c), toLabel(ProductSale__c), toLabel(ProductSaleSMS__c), toLabel(eave__c), toLabel(Insurance__c)
                                                      FROM Consentimientos__c
                                                      WHERE Contact__r.AccountId = :accountId AND RecordTypeId in : recordTypeIds]) {
                	if(!String.isBlank(consentimiento.ChannelValue__c)){
                    	mapConsentimientosByValue.put(consentimiento.ChannelValue__c, consentimiento);
                     }
             }   
        }
        
        return mapConsentimientosByValue;
    }
    
    public static Map<String, Consentimientos__c> getConsentimientosValueByAccountId(String accountId) {
        Map<String, Consentimientos__c> mapConsentimientosByValue = new Map<String, Consentimientos__c>();
        List<String> recordTypeIds = new List<String>();
        recordTypeIds.add(getRecordTypeIdByDeveloperName('Email'));
        recordTypeIds.add(getRecordTypeIdByDeveloperName('Movil'));
        recordTypeIds.add(getRecordTypeIdByDeveloperName('Telefono'));
        if (!String.isBlank(accountId)) {
            for (Consentimientos__c consentimiento : [SELECT Id, ChannelValue__c, Medio_de_contacto__c, RecordTypeId, Contact__c, Fecha_de_captura__c,
                                                      		 AfterSales__c, AfterSalesSMS__c, CustomerSatisfaction__c, CustomerSatisfactionSMS__c,
                                                     		 EnviarAmulesoft__c,EventInvitation__c, EventInvitationSMS__c, MarketResearch__c,
                                                      		 MarketResearchSMS__c, ProductSale__c, ProductSaleSMS__c, eave__c, Insurance__c
                                                      FROM Consentimientos__c
                                                      WHERE Contact__r.AccountId = :accountId AND RecordTypeId in : recordTypeIds]) {
                mapConsentimientosByValue.put(consentimiento.ChannelValue__c, consentimiento);
             }   
        }
        
        return mapConsentimientosByValue;
    }
    
    public static Map<String, Consentimientos__c> getConsentimientosValueByLeadId(String leadId){
        Map<String, Consentimientos__c> mapConsentimientosByValue = new Map<String, Consentimientos__c>();
        List<String> recordTypeIds = new List<String>();
        recordTypeIds.add(getRecordTypeIdByDeveloperName('Email'));
        recordTypeIds.add(getRecordTypeIdByDeveloperName('Movil'));
        recordTypeIds.add(getRecordTypeIdByDeveloperName('Telefono'));
        if (!String.isBlank(leadId)) {
            for (Consentimientos__c consentimiento : [SELECT Id, ChannelValue__c, Medio_de_contacto__c, RecordTypeId,
                                                      		 Contact__c, Fecha_de_captura__c,AfterSales__c, AfterSalesSMS__c, CustomerSatisfaction__c,
                                                    		 CustomerSatisfactionSMS__c, EnviarAmulesoft__c,EventInvitation__c, EventInvitationSMS__c,
                                                     		 MarketResearch__c, MarketResearchSMS__c, ProductSale__c, ProductSaleSMS__c, eave__c, Insurance__c
                                                      FROM Consentimientos__c
                                                      WHERE Lead__c = :leadId and recordTypeId in : recordTypeIds]) {
                mapConsentimientosByValue.put(consentimiento.ChannelValue__c, consentimiento);
             }   
        }
        
        return mapConsentimientosByValue;
    }
    
    public static Map<String, Map<String,Consentimientos__c>> getConsentimientosByLeadId(List<String> listLeadId) {
        Map<String, Map<String,Consentimientos__c>> mapConsentimientovalueByLeadId = new Map<String, Map<String, Consentimientos__c>>();
        List<String> recordTypeIds = new List<String>();
        recordTypeIds.add(getRecordTypeIdByDeveloperName('Email'));
        recordTypeIds.add(getRecordTypeIdByDeveloperName('Movil'));
        recordTypeIds.add(getRecordTypeIdByDeveloperName('Telefono'));
        if (!listLeadId.isEmpty()) {
            for (Consentimientos__c consentimiento : [SELECT Id,
                                                      		 ChannelValue__c,
                                                      		 Medio_de_contacto__c,
                                                      		 RecordTypeId, Contact__c,
                                                      		 Fecha_de_captura__c,
                                                      		 Lead__c,AfterSales__c,
                                                      		 AfterSalesSMS__c,
                                                      		 CustomerSatisfaction__c,
                                                      		 CustomerSatisfactionSMS__c,
                                                      		 EnviarAmulesoft__c,
                                                      		 EventInvitation__c, 
                                                      		 EventInvitationSMS__c, 
                                                      		 MarketResearch__c, 
                                                      		 MarketResearchSMS__c, 
                                                      		 ProductSale__c, 
                                                      		 ProductSaleSMS__c, 
                                                      		 eave__c, 
                                                      		 Insurance__c
                                                      FROM Consentimientos__c
                                                      WHERE Lead__c in :listLeadId and recordTypeId in : recordTypeIds]) {
                Map<String,Consentimientos__c> mapAux =  mapConsentimientovalueByLeadId.containsKey(consentimiento.Lead__c)
                    ? mapConsentimientovalueByLeadId.get(consentimiento.Lead__c) : new Map<String, Consentimientos__c>();
                mapAux.put(consentimiento.ChannelValue__c, consentimiento);
                mapConsentimientovalueByLeadId.put(consentimiento.Lead__c, mapAux);
           }
		}     
        
		return mapConsentimientovalueByLeadId;
    }
    
    //Devuelve todos los consentimientos y los separa según su clave
    //email -> channelValue  
    //telefono -> channelValue 
    //movil -> channelValue
    //interesLegitimo  MKT CSS -> 'rt+ concesionariosima/marca' 
    //interesLegitimo Lead ->'rt+ concesionariosima/marca'
    //FichaUnica ->'es unica' rt
    //NoEcosistema -> rt+ concesionario sima
    //ecosistemaDAG -> 
    public static Map<String,Map<String,Consentimientos__c>> getConsentimientosByAccountId(List<String> listAccountId) {
        Map<String, Map<String,Consentimientos__c>> mapConsentimientovalueByAccountId = new Map<String,Map<String,Consentimientos__c>>();
        
        if (!listAccountId.isEmpty()) {
            for(Consentimientos__c consentimiento : [SELECT Id,Name,LastModifiedDate, RecordTypeId, RecordType.DeveloperName,  Contact__c, Contact__r.AccountId, Concesionario__c,Concesionario__r.Id_Concesionario_Sima__c, Fecha_de_captura__c, 
                                                     ChannelValue__c, Medio_de_contacto__c, AfterSales__c, AfterSalesSMS__c, CustomerSatisfaction__c,CustomerSatisfactionSMS__c, EnviarAmulesoft__c,EventInvitation__c, EventInvitationSMS__c, MarketResearch__c, MarketResearchSMS__c,
                                                     ProductSale__c, ProductSaleSMS__c,CustomerSatisfactionAfterSales__c, CustomerSatisfactionSales__c,Marca__c, expectedCommunicationDate__c, realCommunicationDate__c, oppositionDate__c, entryDate__c, communicationType__c,
                                                     SMS__c, Email__c, Call__c, WhatsApp__c, legitimateInterest__c, noEcosystem__c, eave__c, Insurance__c
                                                     FROM Consentimientos__c WHERE Contact__r.AccountId in :listAccountId]) {
                Map<String,Consentimientos__c> mapAux = mapConsentimientovalueByAccountId.containsKey(consentimiento.contact__r.AccountId)?mapConsentimientovalueByAccountId.get(consentimiento.contact__r.AccountId): new Map<String,Consentimientos__c>();
                if(Label.RtConsentimientoEmail.equalsIgnoreCase(consentimiento.RecordType.DeveloperName) || 
                   Label.RtConsentimientoMobile.equalsIgnoreCase(consentimiento.RecordType.DeveloperName) || 
                   Label.RtConsentimientoPhone.equalsIgnoreCase(consentimiento.RecordType.DeveloperName)){
                   			mapAux.put(consentimiento.ChannelValue__c, consentimiento);
                 }
                else if(Label.RtConsentimientoInterLegMKTCCS.equalsIgnoreCase(consentimiento.RecordType.DeveloperName)){
                  			mapAux.put(consentimiento.recordTypeId+'/'+consentimiento.Concesionario__c+'/'+consentimiento.Marca__c, consentimiento);
                  
                  }
                else if(Label.RtConsentimientoNoEcosistema.equalsIgnoreCase(consentimiento.RecordType.DeveloperName)){
                  			mapAux.put(consentimiento.Concesionario__c, consentimiento); 
                                                       
                  }
                else if(Label.RtConsentimientoEcosistemaDAG.equalsIgnoreCase(consentimiento.RecordType.DeveloperName) ){}
                else if(Label.RtConsentimientoFichaUnica.equalsIgnoreCase(consentimiento.RecordType.DeveloperName)){
                    		system.debug('ficha Unica:' + consentimiento);
                            mapAux.put(consentimiento.recordTypeId, consentimiento); 
                  }
                mapConsentimientovalueByAccountId.put(consentimiento.Contact__r.AccountId, mapAux);
           }
       }     
        
        return mapConsentimientovalueByAccountId;
    }
    
    //Devuelve todo los consentimientos de una cuenta
    public static List<Consentimientos__c> getConsentimientosByAccountId(String accountId){
        List<Consentimientos__c> listConsentimientos = new List<Consentimientos__c>();
        
        if (!String.isBlank(accountId)) {
            listConsentimientos =  [SELECT Id, ChannelValue__c, Medio_de_contacto__c, RecordTypeId, RecordType.DeveloperName, Contact__c, Contact__r.AccountId, Fecha_de_captura__c,AfterSales__c, AfterSalesSMS__c, CustomerSatisfaction__c,
                                    CustomerSatisfactionSMS__c, EnviarAmulesoft__c,EventInvitation__c, EventInvitationSMS__c, MarketResearch__c, MarketResearchSMS__c, ProductSale__c, ProductSaleSMS__c,
                                    Concesionario__c,Concesionario__r.Id_Concesionario_Sima__c,CustomerSatisfactionAfterSales__c, CustomerSatisfactionSales__c, eave__c, Insurance__c
                                    FROM Consentimientos__c WHERE Contact__r.AccountId = :accountId];
       }     
        
        return listConsentimientos;
    }
    
    public static Consentimientos__c getConsentimientosFichaUnicaByContactId(String contactId){
        
        Consentimientos__c Consentimientos;
        List<Consentimientos__c> listConsentimientos = new List<Consentimientos__c>();
        List<String> recordTypeIds = new List<String>();
        recordTypeIds.add(getRecordTypeIdByDeveloperName('Ficha_unica'));
        
        if (!String.isBlank(contactId)) {
            listConsentimientos =  [SELECT Id, RecordTypeId, Contact__c, Concesionario__c,Concesionario__r.Id_Concesionario_Sima__c,
                                           communicationType__c,
                                           oppositionDate__c,
                                           expectedCommunicationDate__c,
                                           realCommunicationDate__c,
                                           entryDate__c
                                  FROM Consentimientos__c WHERE Contact__c = :contactId and recordTypeId in : recordTypeIds];
            if (!listConsentimientos.isEmpty()) {
                Consentimientos = listConsentimientos[0];
            }
        }     
        
        return Consentimientos;
    }

    public static List<Consentimientos__c> getConsentimientosInteresLegitimoByContactId(String contactId){
        List<Consentimientos__c> listConsentimientos = new List<Consentimientos__c>();
        List<String> recordTypeIds = new List<String>();
        recordTypeIds.add(getRecordTypeIdByDeveloperName('Interes_Legitimo_MKT_CCS'));
        
        if (!String.isBlank(contactId)) {
            listConsentimientos =  [SELECT Id, RecordTypeId, Contact__c, Concesionario__c,Concesionario__r.Id_Concesionario_Sima__c, Fecha_de_captura__c,
                                           communicationType__c, 
                                           oppositionDate__c,
                                           expectedCommunicationDate__c,
                                           realCommunicationDate__c,
                                           entryDate__c,
                                           Marca__c,
                                           Email__c, SMS__c, WhatsApp__c, Call__c, ProductSale__c, AfterSales__c
                                    FROM Consentimientos__c WHERE Contact__c = :contactId and recordTypeId in : recordTypeIds];
       }     
        
        return listConsentimientos;
    }

    public static Map<String,Map<String,Consentimientos__c>> getConsentimientosEncuestaByAccountId(List<String> listAccountId) {
        Map<String, Map<String,Consentimientos__c>> mapConsentimientovalueByAccountId = new Map<String,Map<String,Consentimientos__c>>();
        List<String> recordTypeIds = new List<String>();
        recordTypeIds.add(getRecordTypeIdByDeveloperName(Label.RtConsentimientoNoEcosistema));
        
        if (!listAccountId.isEmpty()) {
            for(Consentimientos__c consentimiento : [SELECT Id,Name,LastModifiedDate, RecordTypeId, RecordType.DeveloperName,  Contact__c, Contact__r.AccountId, Concesionario__c,Concesionario__r.Id_Concesionario_Sima__c, Fecha_de_captura__c, 
                                                     ChannelValue__c, Medio_de_contacto__c, AfterSales__c, AfterSalesSMS__c, CustomerSatisfaction__c,CustomerSatisfactionSMS__c, EnviarAmulesoft__c,EventInvitation__c, EventInvitationSMS__c, MarketResearch__c, MarketResearchSMS__c,
                                                     ProductSale__c, ProductSaleSMS__c,CustomerSatisfactionAfterSales__c, CustomerSatisfactionSales__c,Marca__c, expectedCommunicationDate__c, realCommunicationDate__c, oppositionDate__c, entryDate__c, communicationType__c,
                                                     SMS__c, Email__c, Call__c, WhatsApp__c, legitimateInterest__c, noEcosystem__c, eave__c, Insurance__c
                                                     FROM Consentimientos__c 
                                                     WHERE Contact__r.AccountId in :listAccountId and recordTypeId in : recordTypeIds]) {
                Map<String,Consentimientos__c> mapAux = mapConsentimientovalueByAccountId.containsKey(consentimiento.contact__r.AccountId)?mapConsentimientovalueByAccountId.get(consentimiento.contact__r.AccountId): new Map<String,Consentimientos__c>();
                mapAux.put(consentimiento.Concesionario__c, consentimiento); 
                mapConsentimientovalueByAccountId.put(consentimiento.Contact__r.AccountId, mapAux);
           }
       }     
        
       return mapConsentimientovalueByAccountId;
    }
    
    public static Map<String, Map<String, Consentimientos__c>> getConsentimientosByLeads(List<String> listLeadId) {
        Map<String, Map<String, Consentimientos__c>> mapConsentimientovalueByLeadId = new Map<String, Map<String, Consentimientos__c>>();
        List<String> recordTypeIds = new List<String>();
        recordTypeIds.add(getRecordTypeIdByDeveloperName('Email'));
        recordTypeIds.add(getRecordTypeIdByDeveloperName('Movil'));
        recordTypeIds.add(getRecordTypeIdByDeveloperName('Telefono'));
        
        if (!listLeadId.isEmpty()) {
            for(Consentimientos__c consentimiento : [SELECT Id, ChannelValue__c, Medio_de_contacto__c, RecordTypeId, RecordType.Name, Lead__c, Fecha_de_captura__c, AfterSales__c, AfterSalesSMS__c, CustomerSatisfaction__c, CustomerSatisfactionSMS__c, 
                                                    EnviarAmulesoft__c,EventInvitation__c, EventInvitationSMS__c, MarketResearch__c, MarketResearchSMS__c, ProductSale__c, ProductSaleSMS__c,
                                                    Concesionario__c,Concesionario__r.Id_Concesionario_Sima__c,CustomerSatisfactionAfterSales__c,CustomerSatisfactionSales__c, eave__c, Insurance__c
                                                    FROM Consentimientos__c
                                                    WHERE Lead__c in :listLeadId AND RecordTypeId in :recordTypeIds]) {
                Map<String, Consentimientos__c> mapAux =  mapConsentimientovalueByLeadId.containsKey(consentimiento.Lead__c)
                    ? mapConsentimientovalueByLeadId.get(consentimiento.Lead__c) : new Map<String,Consentimientos__c>();
               	mapAux.put(consentimiento.ChannelValue__c, consentimiento);
                mapConsentimientovalueByLeadId.put(consentimiento.Lead__c, mapAux);
           }
       }     
        
        return mapConsentimientovalueByLeadId;
    }
    
}