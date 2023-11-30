public class AuxConsentimientoHandler implements ITriggerHandler {

    private TriggerExecutionHelper infoTrigger = new TriggerExecutionHelper();
    
    public Map<String, Schema.RecordTypeInfo> rtMapByDName = new Map<String, Schema.RecordTypeInfo>();
    public Map<String,Cliente_Concesionario__c> mapClienteConcesionarioById = new Map<String,Cliente_Concesionario__c>();
    public Map<String,Cliente_Concesionario__c> mapClienteConcesionarioByIdExternal = new Map<String,Cliente_Concesionario__c>();
    
    public Map<String,Concesionario__c> mapConcesionarioById = new Map<String,Concesionario__c>();
    public Map<String,Account> mapClientebyId = new Map<String,Account>();
    public Map<String,Contact> mapContactByAccountId = new Map<String,Contact>();
    
    public Map<String,Map<String,Consentimientos__c>> mapValueToConsentimientobyCliente = new Map<String,Map<String,Consentimientos__c>>();
    
    
    public AuxConsentimientoHandler(Schema.sObjectType soType){
        InfoTrigger.setTipoHandler(soType);
    }
    public TriggerExecutionHelper getInfo(){
        return infoTrigger;
    }
    public void bulkBefore(){}
    public void bulkAfter(){
        mapConcesionarioById.clear();
        mapValueToConsentimientobyCliente.clear();
        mapClienteConcesionarioById.clear();
        mapClienteConcesionarioByIdExternal.clear();
        mapClientebyId.clear();
        mapContactByAccountId.clear();
    
        if (Trigger.new != null) {
            rtMapByDName = Schema.SObjectType.Consentimientos__c.getRecordTypeInfosByDeveloperName();
            List<String> listAuxIdExt = new List<String>();
       		for (SObject objeto : Trigger.New) {
                AuxConsentimiento__c auxiliar = (AuxConsentimiento__c) objeto;
                if(!String.isBlank(auxiliar.CustomerId__c) && !String.isBlank(auxiliar.CompanyId__c) ){
                    String auxIdExt = auxiliar.CustomerId__c+'/'+auxiliar.CompanyId__c;
                    listAuxIdExt.add(auxIdExt);
                }
            }
            
            if(!listAuxIdExt.isEmpty()){
                List<String> cuentasId = new List<String>();
                //listConcesionarioId.addAll(mapClienteConcesionarioById.keySet());
                if(!listAuxIdExt.isEmpty()){
               		for(Cliente_Concesionario__c cConcesionario : [SELECT Id,Name,External_Id__c,Cliente__c,Concesionario__c,Id_Cliente_DMS__c,
														Concesionario__r.Id_Concesionario_Sima__c, Concesionario__r.Name
                                       					FROM Cliente_Concesionario__c
                                       					 WHERE  External_Id__c in : listAuxIdExt Limit 2000]){
             			mapClienteConcesionarioById.put(cConcesionario.Id, cConcesionario);
             			String idExternalAux = cConcesionario.Id_Cliente_DMS__c + '/'+ cConcesionario.Concesionario__r.Id_Concesionario_Sima__c;                                                
             			mapClienteConcesionarioByIdExternal.put(idExternalAux,cConcesionario);
                    	cuentasId.add(cConcesionario.Cliente__c);                                          
             		}
                }
                mapClientebyId = AccountGateway.getAccountById(cuentasId);
                mapContactByAccountId = ContactGateway.getContactByAccountId(cuentasId);
                mapValueToConsentimientobyCliente = ConsentimientosGateway.getConsentimientosByAccountId(cuentasId);
                
            }
            
        }     
    }
    public void beforeInsert(sObject so){
        AuxConsentimiento__c auxConsentimiento = (AuxConsentimiento__c) so;
        if ('SMS'.equalsIgnoreCase(auxConsentimiento.ContactChannel__c) ||'Call'.equalsIgnoreCase(auxConsentimiento.ContactChannel__c)) {
        	String replaced = DataValidations.clearPhone(auxConsentimiento.Contact__c);
            if(!auxConsentimiento.Contact__c.equalsIgnoreCase(replaced)){
                auxConsentimiento.limpiado__c = true;
                auxConsentimiento.Contact__c = replaced;
            }
            auxConsentimiento.Valido__c = DataValidations.validatePhone(auxConsentimiento.Contact__c)?true:false;
             
        }
        else if('Email'.equalsIgnoreCase(auxConsentimiento.ContactChannel__c)){
            auxConsentimiento.Contact__c = auxConsentimiento.Contact__c.toLowerCase();
            auxConsentimiento.Valido__c = DataValidations.validateEmail(auxConsentimiento.Contact__c)?true:false;
            
        }
    }
    public void beforeUpdate(sObject old, sObject so){}
    public void beforeDelete(sObject so){}
    public void afterInsert(sObject so){
        AuxConsentimiento__c auxConsentimiento = (AuxConsentimiento__c) so;
        String identificador = auxConsentimiento.CustomerId__c + '/'+ auxConsentimiento.companyId__c;
        if(auxConsentimiento.Valido__c && mapClienteConcesionarioByIdExternal.containsKey(identificador)){
            Cliente_Concesionario__c cConcesionario = mapClienteConcesionarioByIdExternal.get(identificador);
            Account cuenta = mapClientebyId.get(cConcesionario.Cliente__c);
            if(cuenta.IsPersonAccount){
            	Contact contacto = mapContactByAccountId.get(cConcesionario.Cliente__c);
            	Map<String,Consentimientos__c> mapValueToConsentimiento = mapValueToConsentimientobyCliente.containsKey(cuenta.Id)?mapValueToConsentimientobyCliente.get(cuenta.Id):new Map<String,Consentimientos__c>();
            	Consentimientos__c consent = mapValueToConsentimiento.containsKey(auxConsentimiento.Contact__c)?mapValueToConsentimiento.get(auxConsentimiento.Contact__c): new Consentimientos__c();
            	consent.Contact__c = contacto.Id;
            	consent.Fecha_de_captura__c = auxConsentimiento.ResponseDate__c;
            	if('Email'.equalsIgnoreCase(auxConsentimiento.ContactChannel__c)){
                	consent.ChannelValue__c =!String.isEmpty(auxConsentimiento.Contact__c)?auxConsentimiento.Contact__c.toLowerCase():'';
            
                	if(!String.isBlank(cuenta.PersonEmail) && consent.ChannelValue__c.equalsIgnoreCase(cuenta.PersonEmail)){
                    	consent.Medio_de_contacto__c = Label.channelEmail;
                	}
                	else if(!String.isBlank(cuenta.OtherEmail__pc) && consent.ChannelValue__c.equalsIgnoreCase(cuenta.OtherEmail__pc)){
                    	consent.Medio_de_contacto__c = Label.channelOtherEmail;
                	}
                	else{
                    	consent.Medio_de_contacto__c = Label.channelOther;
                	}
                	consent.RecordTypeId = rtMapByDName.get('Email').getRecordTypeId();
                	consent.AfterSales__c = auxConsentimiento.AfterSales__c;
                	consent.EnviarAmulesoft__c = false;
                	consent.CustomerSatisfaction__c = auxConsentimiento.CustomerSatisfaction__c;
                	consent.EventInvitation__c = auxConsentimiento.EventInvitation__c;
                	consent.MarketResearch__c = auxConsentimiento.MarketResearch__c;
                	consent.ProductSale__c = auxConsentimiento.ProductSale__c;
            	}
            	else{
                consent.ChannelValue__c =auxConsentimiento.Contact__c;
                if(DataValidations.isMobile(consent.ChannelValue__c)){
                    consent.RecordTypeId = rtMapByDName.get('Movil').getRecordTypeId();
                    if(!String.isBlank(cuenta.PersonMobilePhone) && cuenta.PersonMobilePhone.equalsIgnoreCase(consent.ChannelValue__c)){
                    	consent.Medio_de_contacto__c = Label.channelMobile;
                	}
                	else if(!String.isBlank(cuenta.OtherMobilePhone__pc) && cuenta.OtherMobilePhone__pc.equalsIgnoreCase(consent.ChannelValue__c)){
                    	consent.Medio_de_contacto__c = Label.channelOtherMobile;
                	}
                	else{
                    	consent.Medio_de_contacto__c = Label.channelOther;
                	}

                }
                else {
                    consent.RecordTypeId = rtMapByDName.get('Telefono').getRecordTypeId();
                    if(!String.isBlank(cuenta.Phone) && cuenta.Phone.equalsIgnoreCase(consent.ChannelValue__c)){
                    	consent.Medio_de_contacto__c = Label.channelPhone;
                	}
                	else if(!String.isBlank(cuenta.PersonOtherPhone) && cuenta.PersonOtherPhone.equalsIgnoreCase(consent.ChannelValue__c)){
                    	consent.Medio_de_contacto__c = Label.channelOtherPhone;
                	}
                	else{
                    	consent.Medio_de_contacto__c = Label.channelOther;
                	}
                }
                
                if('SMS'.equalsIgnoreCase(auxConsentimiento.ContactChannel__c)){
                	consent.AfterSalesSMS__c = auxConsentimiento.AfterSales__c;
                	consent.CustomerSatisfactionSMS__c = auxConsentimiento.CustomerSatisfaction__c;
                    consent.EnviarAmulesoft__c = false;
                	consent.EventInvitationSMS__c = auxConsentimiento.EventInvitation__c;
                	consent.MarketResearchSMS__c = auxConsentimiento.MarketResearch__c;
                	consent.ProductSaleSMS__c = auxConsentimiento.ProductSale__c;
                }
            	else if('Call'.equalsIgnoreCase(auxConsentimiento.ContactChannel__c)){
                	consent.AfterSales__c = auxConsentimiento.AfterSales__c;
                	consent.CustomerSatisfaction__c = auxConsentimiento.CustomerSatisfaction__c;
                    consent.EnviarAmulesoft__c = false;
                	consent.EventInvitation__c = auxConsentimiento.EventInvitation__c;
                	consent.MarketResearch__c = auxConsentimiento.MarketResearch__c;
                	consent.ProductSale__c = auxConsentimiento.ProductSale__c;
            	}
			}
            	mapValueToConsentimiento.put(consent.ChannelValue__c,consent);
            	mapValueToConsentimientobyCliente.put(cuenta.Id,mapValueToConsentimiento);
             }   
        }
    }
    public void afterUpdate(sObject old, sObject so){}
    public void afterDelete(sObject so){}
    public void andFinally(){
        if(!mapValueToConsentimientobyCliente.isEmpty()){
            Set<Consentimientos__c> conjuntoConsentimientos = new Set<Consentimientos__c>();
            for(String idCliente :mapValueToConsentimientobyCliente.keySet()){
                Map<String,Consentimientos__c> mapValueToConsentimiento = mapValueToConsentimientobyCliente.get(idCliente);
                conjuntoConsentimientos.addAll(mapValueToConsentimiento.values());
            }
            List<Consentimientos__c> listaConsentimientos = new List<Consentimientos__c>();
            listaConsentimientos.addAll(conjuntoConsentimientos);
            upsert listaConsentimientos;
        }
    }


}