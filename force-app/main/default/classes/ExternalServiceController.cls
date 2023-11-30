public class ExternalServiceController {
 
    //Para envio de customer y de lead 
    @future(callout=true)
    public static void createExternalLeadOrAccountMulesoft(String JSONCases, String JSONgLead) {
      List<Case> listaCasos = (List<Case>) JSON.deserialize(JSONCases, List<Case>.class);
      Map<String,Case> mapCaseById = new Map<String,Case>();
      String idsCasos = '';
      List<String> casosIds = new List<String>();
      Map<String, ResponseApi> mapCaseIdToResponse = new Map<String, ResponseApi>(); 
      Map<String, ResponseApi> mapCaseIdToResponseCustomer = new Map<String, ResponseApi>(); 
      for(Case caso :listaCasos){
            idsCasos+=caso.Id+',';
          	casosIds.add(caso.Id);
        }
	  try{
        mapCaseById = CaseGateway.getCaseById(casosIds);
        Gestion_Lead__c gLead = (Gestion_Lead__c) JSON.deserialize(JSONgLead, Gestion_Lead__c.class);
        String emailAsesor = '';
        
        //Map<String, Case> mapCaseById = new Map<String, Case>();
        Map<String, Centro__c> mapCentroById = new Map<String, Centro__c>();
        Map<String, Campaign> mapCampaignById = new Map<String, Campaign>();
        Map<String, Account> mapAccountById = new Map<String, Account>();
        Map<String, Lead> mapLeadById = new Map<String, Lead>();
        Map<String, Pais__c> mapPaisByName = new Map<String, Pais__c>();
        Map<String, Map<String, CampaignMember>> mapCOrLToCMByCampaignId = new Map<String,Map<String, CampaignMember>>();
        Map<String, Cliente_Concesionario__c> mapClienteConcesionarioByAccountId = new Map<String, Cliente_Concesionario__c>();
       	Map<String, Map<String, Consentimientos__c>> mapConsentimientovalueByLeadId = new Map<String, Map<String, Consentimientos__c>>();
        Map<String, Map<String, Consentimientos__c>> mapConsentimientovalueByAccountDuplicado = new Map<String, Map<String, Consentimientos__c>>();
        
        
        List<String> listConcesionarioIdSima = new List<String>();
        List<String> listCaseSendWithAccount = new List<String>();
        List<String> listCaseSendWithLead = new List<String>();
        List<String> listAccountId = new List<String>();
        List<String> listLeadId = new List<String>();
        List<String> listCentroId = new List<String>();
        List<String> listCampaignId = new List<String>();
        Map<String,String> mapAccountIdDuplicadobyCaseId = new Map<String,String>();
        
        Map<String, Cliente_Concesionario__c> mapCConcesionarioToInsertByCaseId = new Map<String, Cliente_Concesionario__c>();
        Map<String, Account> mapAccountToInsertByCaseId = new Map<String, Account>();
        Map<String, Map<String, CampaignMember>> mapCampaignMemberByCOrLByCampaigIdToInsert = new Map<String, Map<String, CampaignMember>>();
        List<Consentimientos__c> listConsentimientoToUpdate = new List<Consentimientos__c>();
        List<String> listConsentimientoIdToDelete = new List<String>();
        List<Consentimientos__c> listConsentimientoToDelete = new List<Consentimientos__c>();
        List<Case> listCaseToUpdate = new List<Case>();
        List<Lead> listLeadToDelete = new List<Lead>();
        List<String> listLeadIdToDelete = new List<String>();
        List<CampaignMember> listCampaignMemberToDelete = new List<CampaignMember>();
        Map<String, List<Case>> mapLeadToCases = new Map<String, List<Case>>();
        
        for (Case caso : mapCaseById.values()) {
            //mapCaseById.put(caso.Id, caso);
            
/*            if (caso.Centro__c != null) {
                listCentroId.add(caso.Centro__c);
            }
*/
            
            if (caso.Campana__c != null) {
                listCampaignId.add(caso.Campana__c);
            }
            
            if (caso.AccountId != null) {
                listCaseSendWithAccount.add(caso.id);
                listAccountId.add(caso.AccountId);
            }
            else if (caso.Lead__c != null) {
                listCaseSendWithLead.add(caso.Id);
                listLeadId.add(caso.Lead__c);
            }
        }
          
        if (gLead.Centro_destino__c != null) {
           listCentroId.add(gLead.Centro_destino__c);
        }
          
        //Centro 
        if (!listCentroId.isEmpty()) {
        	mapCentroById =  CentroGateway.getCenterById(listCentroId);
           
            for(Centro__c centro : mapCentroById.values()){
                if(!String.isBlank(centro.Concesionario__r.Id_Concesionario_Sima__c) && !listConcesionarioIdSima.contains(centro.Concesionario__r.Id_Concesionario_Sima__c)){
                    listConcesionarioIdSima.add(centro.Concesionario__r.Id_Concesionario_Sima__c);
                }
            }
        }
            
        //Asesor
        if (gLead.Asesor__c != null) {
            User asesor = UserGateway.getUserById(gLead.Asesor__c);
            emailAsesor = asesor.Email;
        } else if (gLead.EmailAsesor__c != null) {
            emailAsesor = gLead.EmailAsesor__c;
        }

        //Campaign
        if (!listCampaignId.isEmpty()) {
            mapCampaignById = CampaignGateway.getCampaignById(listCampaignId);
        }
          
        //Asociado con cliente
        if (!listAccountId.isEmpty()) {
            mapAccountById = AccountGateway.getAccountById(listAccountId);
            
            Map<String,Map<String,Consentimientos__c>> mapConsentimientosValueByAccountId = ConsentimientosGateway.getConsentimientosByAccountId(listAccountId);
            Map<String,List<Cliente_Concesionario__c>> mapAllClienteConcesionarioByAccountId =ClienteConcesionarioGateway.getclienteConcesionarioByAccountId(listAccountId);
            List<String> listaPaises = new List<String>();
            
            for (Account cuenta : mapAccountById.values()) {
                if (!String.isBlank(cuenta.ShippingCountry)) {
                    listaPaises.add(DataValidations.capitalizeString(cuenta.ShippingCountry));
                }
                
                if (!String.isBlank(cuenta.BillingCountry)) {
                    listaPaises.add(DataValidations.capitalizeString(cuenta.BillingCountry));
                }
            }
            
            mapPaisByName = PaisGateway.getPaisByName(listaPaises);
            
            for (Cliente_Concesionario__c cConcesionario : [SELECT Id, Id_Cliente_DMS__c, Cliente__c, Concesionario__c, Concesionario__r.Id_Concesionario_Sima__c
                                                            FROM Cliente_Concesionario__c
                                                            WHERE Cliente__c in :listAccountId
                                                            	AND Concesionario__r.Id_Concesionario_Sima__c in :listConcesionarioIdSima
                                                                AND Es_Seccion__c = false]) {
                if (!mapClienteConcesionarioByAccountId.containsKey(cConcesionario.Cliente__c)) {
                    mapClienteConcesionarioByAccountId.put(cConcesionario.Cliente__c, cConcesionario);
                }
            }
            
            for (String idCaso : listCaseSendWithAccount) {
                ExternalCustomerApiModel.CustomerApi externalCustomerApi = new ExternalCustomerApiModel.CustomerApi();
                ExternalLeadApiModel.LeadApi externalLeadApi = new ExternalLeadApiModel.LeadApi();
                ExternalLeadApiNewModel.LeadApi externalLeadApiNew = new ExternalLeadApiNewModel.LeadApi();
                ExternalConsentimientoApiModel.ConsentimientoApi externalConsentimientoApi = new ExternalConsentimientoApiModel.ConsentimientoApi();
                Case caso = mapCaseById.get(idCaso);
                Centro__c centro = gLead.Centro_destino__c != null && mapCentroById.containsKey(gLead.Centro_destino__c) ? mapCentroById.get(gLead.Centro_destino__c) : null;
                Campaign campania = caso.Campana__c != null && mapCampaignById.containsKey(caso.Campana__c) ? mapCampaignById.get(caso.Campana__c) : null;
                Account cuenta = caso.AccountId != null && mapAccountById.containsKey(caso.AccountId) ? mapAccountById.get(caso.AccountId) : null;
                
                if (mapClienteConcesionarioByAccountId.containsKey(caso.AccountId)) {
                    //Existe cliente Concesionario con ese concesionario
                    Cliente_Concesionario__c cConcesionario = mapClienteConcesionarioByAccountId.get(caso.AccountId);
                   
                    externalLeadApi = createExternalLead(caso, centro, campania, cConcesionario.Id_Cliente_DMS__c, emailAsesor,true);
                    system.debug ('createExternalLeadNew pasa por 1');
                    externalLeadApiNew = createExternalLeadNew(caso, centro, campania, cConcesionario.Id_Cliente_DMS__c, emailAsesor,true);
                    	ResponseApi respuesta;
                        if (date.today() < date.parse(label.startDiler)) {
                            respuesta = ExternalServiceCallout.createLeadApiCallout(externalLeadApi);
                        } else {
                            respuesta = ExternalServiceCallout.createLeadApiCalloutNew(externalLeadApiNew);
                        }
                        system.debug('Inma_respuesta:'+ respuesta); 
                    	mapCaseIdToResponse.put(caso.Id, respuesta);

                  
                        //Envio consentimiento
                        Map<String,Consentimientos__c> mapConsentimientoValue = mapConsentimientosValueByAccountId.containsKey(caso.AccountId) ? mapConsentimientosValueByAccountId.get(caso.AccountId): null;
            			List<Cliente_Concesionario__c> listAllClienteConcesionario = mapAllClienteConcesionarioByAccountId.containsKey(caso.AccountId) ? mapAllClienteConcesionarioByAccountId.get(caso.AccountId): null;
                    	if(listAllClienteConcesionario != null && mapConsentimientoValue != null ){
                       		externalConsentimientoApi = createExternalConsentimiento(mapConsentimientoValue.values(), listAllClienteConcesionario);
                    		ResponseApi respuestaConse = ExternalServiceCallout.sendConsentimientoApiCallout(externalConsentimientoApi);
							system.debug('respuestaConse:'+ respuestaConse);                 
                    	}
                    
                }
                else {
                    //No existe cliente concesionario con ese companyId a ese cliente.
                      externalCustomerApi = createExternalCustomer(caso, centro, cuenta, null, mapPaisByName);
                    	//enviar creación de cliente
                    	ResponseApi respuestaCustomer = ExternalServiceCallout.createAccountApiCallout(externalCustomerApi);
                    	mapCaseIdToResponseCustomer.put(caso.Id, respuestaCustomer);
                    	mapCaseIdToResponse.put(caso.Id, respuestaCustomer);

                    	if (respuestaCustomer.Status.equalsIgnoreCase('OK')) {
                        	externalLeadApi = createExternalLead(caso, centro, campania, respuestaCustomer.Message, emailAsesor, true);
                    system.debug ('createExternalLeadNew pasa por 2');
                        	externalLeadApiNew = createExternalLeadNew(caso, centro, campania, respuestaCustomer.Message, emailAsesor, true);
                    		ResponseApi respuesta;
                            if (date.today() < date.parse(label.startDiler)) {
                                respuesta = ExternalServiceCallout.createLeadApiCallout(externalLeadApi);
                            } else {
                                respuesta = ExternalServiceCallout.createLeadApiCalloutNew(externalLeadApiNew);
                            }
                            system.debug('Inma_respuesta:'+ respuesta); 
                        	mapCaseIdToResponse.put(caso.Id, respuesta);
                           
                        	Cliente_Concesionario__c cConcesionarioToInsert = createCconcesionario(cuenta, respuestaCustomer.Message, centro.Concesionario__c,centro.Concesionario__r.Id_Concesionario_Sima__c);
                        	mapCConcesionarioToInsertByCaseId.put(caso.Id, cConcesionarioToInsert);
                        
                        	Map<String,Consentimientos__c> mapConsentimientoValue = mapConsentimientosValueByAccountId.containsKey(caso.AccountId) ? mapConsentimientosValueByAccountId.get(caso.AccountId): null;
                        	List<Cliente_Concesionario__c> listAllClienteConcesionario = mapAllClienteConcesionarioByAccountId.containsKey(caso.AccountId)
                                ? mapAllClienteConcesionarioByAccountId.get(caso.AccountId) : new List<Cliente_Concesionario__c>();
                        	listAllClienteConcesionario.add(cConcesionarioToInsert);
                            
                            if (listAllClienteConcesionario != null && mapConsentimientoValue != null ) {
                            	externalConsentimientoApi = createExternalConsentimiento(mapConsentimientoValue.values(), listAllClienteConcesionario, centro);
                    			ResponseApi respuestaConse = ExternalServiceCallout.sendConsentimientoApiCallout(externalConsentimientoApi);
								system.debug('respuestaConse:'+ respuestaConse);
                        	}	
                    	}
                }
            }
        }
          
        //Asociado con lead
        if (!listLeadId.isEmpty()) {
            mapConsentimientovalueByLeadId = ConsentimientosGateway.getConsentimientosByLeadId(listLeadId);
            mapLeadById = LeadGateway.getLeadIdByIds(listLeadId);
            mapLeadToCases = CaseGateway.getCaseByLead(listLeadId);
            List<String> listaPaises = new List<String>();
            
            for (Lead candidato : mapLeadById.values()) {
                if (!String.isBlank(candidato.Country)) {
                    listaPaises.add(DataValidations.capitalizeString(candidato.Country));
                }
            }
            
            mapPaisByName = PaisGateway.getPaisByName(listaPaises);
         
            for (String idCaso : listCaseSendWithLead){
                ExternalCustomerApiModel.CustomerApi externalCustomerApi = new ExternalCustomerApiModel.CustomerApi();
                ExternalLeadApiModel.LeadApi externalLeadApi = new ExternalLeadApiModel.LeadApi();
                ExternalLeadApiNewModel.LeadApi externalLeadApiNew = new ExternalLeadApiNewModel.LeadApi();
                ExternalConsentimientoApiModel.ConsentimientoApi externalConsentimientoApi = new ExternalConsentimientoApiModel.ConsentimientoApi();
                Case caso = mapCaseById.get(idCaso);
                Centro__c centro = gLead.Centro_destino__c != null && mapCentroById.containsKey(gLead.Centro_destino__c) ? mapCentroById.get(gLead.Centro_destino__c) : null;
                Campaign campania = caso.Campana__c != null && mapCampaignById.containsKey(caso.Campana__c) ? mapCampaignById.get(caso.Campana__c) : null;
                Lead candidato = caso.Lead__c != null && mapLeadById.containsKey(caso.Lead__c) ? mapLeadById.get(caso.Lead__c) : null;
            	externalCustomerApi = createExternalCustomer(caso, centro, null, candidato, mapPaisByName);
                ResponseApi respuestaCustomer = ExternalServiceCallout.createAccountApiCallout(externalCustomerApi);
                mapCaseIdToResponseCustomer.put(caso.Id,respuestaCustomer);
				mapCaseIdToResponse.put(caso.Id, respuestaCustomer);
                	
                if (respuestaCustomer.Status.equalsIgnoreCase('OK')) {
                    listLeadIdToDelete.add(candidato.id);
                	externalLeadApi = createExternalLead(caso, centro, campania, respuestaCustomer.Message, emailAsesor, true);
                    system.debug ('createExternalLeadNew pasa por 3');
                	externalLeadApiNew = createExternalLeadNew(caso, centro, campania, respuestaCustomer.Message, emailAsesor, true);
                    ResponseApi respuesta;
                    if (date.today() < date.parse(label.startDiler)) {
                        respuesta = ExternalServiceCallout.createLeadApiCallout(externalLeadApi);
                    } else {
                        respuesta = ExternalServiceCallout.createLeadApiCalloutNew(externalLeadApiNew);
                    }
                    system.debug('Inma_respuesta:'+ respuesta); 
                    mapCaseIdToResponse.put(caso.Id, respuesta);
                    
                    Account cuenta = createAccount(candidato, caso, mapPaisByName);
                    if (!String.isBlank(cuenta.Id)) {
						Cliente_Concesionario__c cConcesionarioToInsert = createCconcesionario(cuenta, respuestaCustomer.Message, centro.Concesionario__c, centro.Concesionario__r.Id_Concesionario_Sima__c);
						mapCConcesionarioToInsertByCaseId.put(caso.Id, cConcesionarioToInsert); 
						caso.AccountId = cuenta.Id;
						mapCaseById.put(caso.Id, caso);
						mapAccountIdDuplicadobyCaseId.put(caso.Id, cuenta.Id);
						Map<String,Consentimientos__c> mapConsentimientoValue = mapConsentimientovalueByLeadId.containsKey(caso.Lead__c) ? mapConsentimientovalueByLeadId.get(caso.Lead__c): null;
                       	
                        if (mapConsentimientoValue != null ) {
                            externalConsentimientoApi = createExternalConsentimiento(mapConsentimientoValue.values(), new List<Cliente_Concesionario__c> {cConcesionarioToInsert}, centro);
                    		ResponseApi respuestaConse = ExternalServiceCallout.sendConsentimientoApiCallout(externalConsentimientoApi);
							system.debug('respuestaConse:'+ respuestaConse);
                        }
                    }
                    else {
                        mapAccountToInsertByCaseId.put(caso.Id,cuenta);
                        Cliente_Concesionario__c cConcesionarioToInsert = createCconcesionario(null, respuestaCustomer.Message, centro.Concesionario__c, centro.Concesionario__r.Id_Concesionario_Sima__c);
                        mapCConcesionarioToInsertByCaseId.put(caso.Id,cConcesionarioToInsert);
                        Map<String, Consentimientos__c> mapConsentimientoValue = mapConsentimientovalueByLeadId.containsKey(caso.Lead__c) ? mapConsentimientovalueByLeadId.get(caso.Lead__c) : null;

                        if (mapConsentimientoValue != null ) {
                            externalConsentimientoApi = createExternalConsentimiento(mapConsentimientoValue.values(), new List<Cliente_Concesionario__c> {cConcesionarioToInsert}, centro);
                    		ResponseApi respuestaConse = ExternalServiceCallout.sendConsentimientoApiCallout(externalConsentimientoApi);
							system.debug('respuestaConse:'+ respuestaConse);
                        }	
                    }
				}
        	}   
        }
        
        //Creamos Cuenta
        Map<String, Contact> mapContactByAccountId = new Map<String,Contact>();
        
		if (!mapAccountToInsertByCaseId.isEmpty()) {
            upsert mapAccountToInsertByCaseId.values();
            system.debug('insertar: mapAccountToInsertByCaseId'+ mapAccountToInsertByCaseId);
		}
         
        List<String> listCuentaId = new List<String>();
        List<String> listContactId = new List<String>();
        
        for (Account cuenta : mapAccountToInsertByCaseId.values()) {
         	listCuentaId.add(cuenta.Id);
		}
        
        //cuenta duplicado en caso de lead a la hora de intentar crear cuenta
        if (!mapAccountIdDuplicadoByCaseId.isEmpty()) {
            listCuentaId.addAll(mapAccountIdDuplicadobyCaseId.values());
            mapConsentimientovalueByAccountDuplicado = ConsentimientosGateway.getConsentimientosByAccountId(mapAccountIdDuplicadobyCaseId.values());
        }
        
        //Sacamos todos los contactos de las cuentas
        if (!listCuentaId.isEmpty()) {
        	mapContactByAccountId = ContactGateway.getContactByAccountId(listCuentaId);
            for(Contact contacto : mapContactByAccountId.values()){
                listContactId.add(contacto.Id);
            }
        }
        
        //Campaign
        if (!listCampaignId.isEmpty()) {
//            mapCampaignById = CampaignGateway.getCampaignById(listCampaignId);
            mapCOrLToCMByCampaignId = CampaignMemberGateway.getMapCOrLToCampaignMemberByCampaignId(listCampaignId,listContactId,listLeadId );
        }
       
        //Actualizacion de consentimientos y campaignMember de cliente duplicados
        if (!mapAccountIdDuplicadoByCaseId.isEmpty()) {
            for (String caseId : mapAccountIdDuplicadoByCaseId.keySet()) {
                String accountId = mapAccountIdDuplicadoByCaseId.get(caseId);
                Contact contacto = mapContactByAccountId.containsKey(accountId)?mapContactByAccountId.get(accountId):null;
                Case caso = mapCaseById.get(caseId);
                
                //Actualizacion consentimientos para cuentas duplicadas
                Map<String, Consentimientos__c> mapConsentimientoByValueLead = mapConsentimientovalueByLeadId.containsKey(caso.Lead__c)
                    ? mapConsentimientovalueByLeadId.get(caso.Lead__c) : null;
                Map<String, Consentimientos__c> mapConsentimientoByValue = mapConsentimientovalueByAccountDuplicado.containsKey(accountId)
                    ? mapConsentimientovalueByAccountDuplicado.get(accountId) : new Map<String,Consentimientos__c>();
                
                if (mapConsentimientoByValueLead != null ) {
                    for (Consentimientos__c consentimientoLead :mapConsentimientoByValueLead.values()){
                        if (mapConsentimientoByValue.containsKey(consentimientoLead.ChannelValue__c)) {
                            Consentimientos__c consentimientoToUpdate = mapConsentimientoByValue.get(consentimientoLead.ChannelValue__c);
                            consentimientoToUpdate.AfterSales__c= consentimientoLead.AfterSales__c;
                            consentimientoToUpdate.AfterSalesSMS__c = consentimientoLead.AfterSalesSMS__c;
                            consentimientoToUpdate.CustomerSatisfaction__c = consentimientoLead.CustomerSatisfaction__c;
                            consentimientoToUpdate.CustomerSatisfactionSMS__c = consentimientoLead.CustomerSatisfactionSMS__c;
                            consentimientoToUpdate.EventInvitation__c = consentimientoLead.EventInvitation__c;
                            consentimientoToUpdate.EventInvitationSMS__c = consentimientoLead.EventInvitationSMS__c;
                            consentimientoToUpdate.Fecha_de_captura__c = consentimientoLead.Fecha_de_captura__c;
                            consentimientoToUpdate.MarketResearch__c = consentimientoLead.MarketResearch__c;
                            consentimientoToUpdate.MarketResearchSMS__c = consentimientoLead.MarketResearchSMS__c;
                            consentimientoToUpdate.ProductSale__c = consentimientoLead.ProductSale__c;
                            consentimientoToUpdate.ProductSaleSMS__c = consentimientoLead.ProductSaleSMS__c;
                            consentimientoToUpdate.EnviarAmulesoft__c = false;
                            listConsentimientoToUpdate.add(consentimientoToUpdate);
                            listConsentimientoIdToDelete.add(consentimientoLead.Id);
                        }
                        else {
                            consentimientoLead.Contact__c =contacto != null ? contacto.Id : null;
                    		consentimientoLead.Lead__c = null;
                            consentimientoLead.EnviarAmulesoft__c = false;
                            listConsentimientoToUpdate.add(consentimientoLead);
                        }
                    }
                }  
               
                //Actualizacion campaignMember para clientes duplicados (Lead)
                if (!String.isBlank(caso.Campana__c)) {
                    Map<String,CampaignMember> mapCOrLToCM =  mapCOrLToCMByCampaignId.containsKey(caso.Campana__c) ?mapCOrLToCMByCampaignId.get(caso.Campana__c): new Map<String,CampaignMember>();
                    if(!mapCOrLToCM.containsKey(contacto.Id)){
                        Map<String,CampaignMember> mapCampaignMemberToInsert = mapCampaignMemberByCOrLByCampaigIdToInsert.containsKey(caso.Campana__c)?mapCampaignMemberByCOrLByCampaigIdToInsert.get(caso.Campana__c): new Map<String,CampaignMember>();
                        if(!mapCampaignMemberToInsert.containsKey(contacto.Id)){
                        	CampaignMember cMember = new CampaignMember();
                    		cMember.CampaignId = caso.Campana__c;
                    		cMember.ContactId = contacto.Id;
                    		cMember.Status = Label.StatustResponded;
                        	mapCampaignMemberToInsert.put(cMember.ContactId, cMember);
                        	mapCampaignMemberByCOrLByCampaigIdToInsert.put(caso.Campana__c, mapCampaignMemberToInsert);
                        }
                    }
                    if(!String.isBlank(caso.Lead__c) && mapCOrLToCM.containsKey(caso.Lead__c)){
                            listCampaignMemberToDelete.add( mapCOrLToCM.get(caso.Lead__c));
                        }
                }
             
                //Para los casos relacionados al lead anteriormente pasarlos a la cuenta duplicada
                List<Case> listCases = mapLeadToCases.containsKey(caso.Lead__c)?mapLeadToCases.get(caso.Lead__c): null;
                if (listCases != null){
                    for(Case casoLead :listCases){
                        if(casoLead.Id != caso.Id && !mapCaseById.containsKey(casoLead.Id) ){
                            casoLead.AccountId = accountId;
                            casoLead.ContactId = contacto.Id;
                            casoLead.Lead__c = null;
                            if (!casoLead.Owner.IsActive && casoLead.Unidad_de_negocio__c == Label.UnidadNegocioOpportunity){
                                casoLead.OwnerId = Label.UsuarioOpportunity;
                            }
                            if (!casoLead.Owner.IsActive && casoLead.Unidad_de_negocio__c == Label.UnidadNegocioMobility){
                                casoLead.OwnerId = Label.UsuarioMobility;
                            }
                            listCaseToUpdate.add(casoLead);
                        }
                    }
                }
              }
         }
        
        //Actualizacion de cliente concesionario y consentimientos a clientes nuevos insertados
        for(String caseId :mapAccountToInsertByCaseId.keySet()){
        	Account cuenta = mapAccountToInsertByCaseId.get(caseId);
            Contact contacto =  mapContactByAccountId.containsKey(cuenta.Id)?mapContactByAccountId.get(cuenta.Id):null;
            
            //Cliente concesionario
            Cliente_Concesionario__c cConcesionario = mapCConcesionarioToInsertByCaseId.get(caseId);
            cConcesionario.Cliente__c = cuenta.Id;
            mapCConcesionarioToInsertByCaseId.put(caseId,cConcesionario);
            
            //Para el consentimiento en caso de cuentas nuevos
             Case caso = mapCaseById.get(caseId);
             if(!String.isBlank(caso.Lead__c) && mapConsentimientovalueByLeadId.containsKey(caso.Lead__c)){
             	Map<String,Consentimientos__c> mapConsentimientoByValue = mapConsentimientovalueByLeadId.get(caso.Lead__c);
                for(Consentimientos__c consentimiento :mapConsentimientoByValue.values()){
                	consentimiento.Contact__c = contacto != null?contacto.Id: null;
                    consentimiento.Lead__c = null;
                    String developerNameCon = ConsentimientosGateway.getRecordTypeDeveloperNameById(consentimiento.RecordTypeId);
                    if(developerNameCon.equalsIgnoreCase(Label.RtConsentimientoEmail)){
                    	consentimiento.Medio_de_contacto__c = Label.channelEmail;
                    }
                    else if(developerNameCon.equalsIgnoreCase(Label.RtConsentimientoMobile)){
                    	consentimiento.Medio_de_contacto__c = Label.channelMobile;
                    }
                    else if (developerNameCon.equalsIgnoreCase(Label.RtConsentimientoPhone)){
                    	consentimiento.Medio_de_contacto__c = Label.channelPhone;
                    }
                    listConsentimientoToUpdate.add(consentimiento);
                 }
             }
            
            //Para CampaigMember en caso de cuentas nuevas
            if(!String.isBlank(caso.Campana__c)){
                    Map<String,CampaignMember> mapCOrLToCM =  mapCOrLToCMByCampaignId.containsKey(caso.Campana__c) ?mapCOrLToCMByCampaignId.get(caso.Campana__c): new Map<String,CampaignMember>();
                    if(!mapCOrLToCM.containsKey(contacto.Id)){
                        Map<String,CampaignMember> mapCampaignMemberToInsert = mapCampaignMemberByCOrLByCampaigIdToInsert.containsKey(caso.Campana__c)?mapCampaignMemberByCOrLByCampaigIdToInsert.get(caso.Campana__c): new Map<String,CampaignMember>();
                        if(!mapCampaignMemberToInsert.containsKey(contacto.Id)){
                        	CampaignMember cMember = new CampaignMember();
                    		cMember.CampaignId = caso.Campana__c;
                    		cMember.ContactId = contacto.Id;
                    		cMember.Status = Label.StatustResponded;
                        	mapCampaignMemberToInsert.put(cMember.ContactId, cMember);
                        	mapCampaignMemberByCOrLByCampaigIdToInsert.put(caso.Campana__c, mapCampaignMemberToInsert);
                        }
                    }
                    if(!String.isBlank(caso.Lead__c) && mapCOrLToCM.containsKey(caso.Lead__c)){
                            listCampaignMemberToDelete.add( mapCOrLToCM.get(caso.Lead__c));
                        }
                }
            
            //Para los casos relacionados al lead anteriormente pasarlos a la nueva cuenta
            List<Case> listCases = mapLeadToCases.containsKey(caso.Lead__c)?mapLeadToCases.get(caso.Lead__c): null;
            if (listCases != null){
                    for(Case casoLead :listCases){
                        if(casoLead.Id != caso.Id && !mapCaseById.containsKey(casoLead.Id) ){
                            casoLead.AccountId = cuenta.Id;
                            casoLead.ContactId = contacto.Id;
                            casoLead.Lead__c = null;
                            if (!casoLead.Owner.IsActive && casoLead.Unidad_de_negocio__c == Label.UnidadNegocioOpportunity){
                                casoLead.OwnerId = Label.UsuarioOpportunity;
                            }
                            if (!casoLead.Owner.IsActive && casoLead.Unidad_de_negocio__c == Label.UnidadNegocioMobility){
                                casoLead.OwnerId = Label.UsuarioMobility;
                            }
                            listCaseToUpdate.add(casoLead);
                        }
                    }
                }
                
        }
		//Creamos cliente Concesionario
        if(!mapCConcesionarioToInsertByCaseId.isEmpty()){
            Schema.SObjectField f = Cliente_Concesionario__c.Fields.External_Id__c;
			Database.UpsertResult [] cr = Database.upsert(mapCConcesionarioToInsertByCaseId.values(), f);
            //upsert mapCConcesionarioToInsertByCaseId.values();
        }
        
        //Actualizamos consentimientos a los clientes nuevos insertados
        if(!listConsentimientoToUpdate.isEmpty()){
            UPDATE listConsentimientoToUpdate;
        }
        //Eliminamos consentimientos de los lead
        if (!listConsentimientoIdToDelete.isEmpty()){
            listConsentimientoToDelete = [select id from Consentimientos__c where id IN :listConsentimientoIdToDelete];
            if(!listConsentimientoToDelete.isEmpty()){
                delete listConsentimientoToDelete;
            }
        }
        
        //Insercion de campaingMember
        if(!mapCampaignMemberByCOrLByCampaigIdToInsert.isEmpty()){
            List<CampaignMember> listCampaignMemberToInsert = new List<CampaignMember>();
            for(String campaignId :mapCampaignMemberByCOrLByCampaigIdToInsert.keySet()){
                Map<String,CampaignMember> mapCampaignMemberToInsert = mapCampaignMemberByCOrLByCampaigIdToInsert.get(campaignId);
            	listCampaignMemberToInsert.addAll(mapCampaignMemberToInsert.values());
            }
            Insert listCampaignMemberToInsert;
       }
        
        //Eliminacion de CampaignMember
        if(!listCampaignMemberToDelete.isEmpty()){
            Delete listCampaignMemberToDelete;
        }
        
        Map<String,Opportunity> mapIdExternalOpps = new Map<String,Opportunity>();
        

        //Actualización del caso y asociamos el caso a la cuenta cuando es lead
        system.debug('Antes de la modificacion del caso');
        for (String idCaso :mapCaseIdToResponse.keySet()) {
            Case caso = mapCaseById.get(idCaso);
            caso.Id = idCaso;
            ResponseApi respuesta = mapCaseIdToResponse.get(idCaso);
            ResponseApi respuestaCustomer = mapCaseIdToResponseCustomer.get(idCaso);
            system.debug('case:'+ caso);
            system.debug('mapAccountToInsertByCaseId:'+ mapAccountToInsertByCaseId);
            //caso.EnvioMulesoft__c = respuesta != null && respuesta.Status.equalsIgnoreCase('OK')?respuesta.Status:'Error';
            //caso.Error_Mulesoft__c = respuesta.Message.length() > 255 ? respuesta.Message.substring(0, 255) : respuesta.Message;
            if (respuesta != null) {
                if (respuesta.Status.equalsIgnoreCase('OK')) {
                    caso.EnvioMulesoft__c = respuesta.Status;
                    if (respuesta.Message != '') {
                        
                        caso.Error_Mulesoft__c = respuesta.Message;
                        caso.ErrorMulesoft__c='';
                        caso.Status = Label.StatusClosed;
                        caso.Motivo_de_cierre__c = Label.motivoCierreAutomatico;
    
                        Centro__c centro = gLead.Centro_destino__c != null && mapCentroById.containsKey(gLead.Centro_destino__c) ? mapCentroById.get(gLead.Centro_destino__c) : null;
                        Opportunity opp = new Opportunity();
                        opp.Name = gLead.Centro_destino__c != null ?centro.Concesionario__r.Nombre_Comercial__c+'/'+centro.Name+'/':respuesta.Message;
                        opp.Centro__c = gLead.Centro_destino__c;
                        opp.Concesionario__c = centro != null? centro.Concesionario__c:caso.Concesionario__c;
                        opp.CloseDate = Date.today().addMonths(1);
                        opp.StageName = 'Qualification';
                        opp.ID_Oportunidad_DMS__c = respuesta.Message;
                        opp.AccountId = caso.AccountId != null ? caso.AccountId : mapAccountToInsertByCaseId.get(idCaso).Id;
                        opp.CampaignId = !String.isBlank(caso.Campana__c) ? caso.Campana__c : null;
                        system.debug('caso.RecommendByName__c: '+caso.RecommendByName__c);
                        opp.RecommendByName__c = !String.isBlank(caso.RecommendByName__c) ? caso.RecommendByName__c : null;
                        system.debug('opp.RecommendByName__c: '+opp.RecommendByName__c);
                        mapIdExternalOpps.put(caso.Error_Mulesoft__c, opp);
                       // lstOpps.add(opp);
                       // si aplica se envia email al asesor
                        if (caso.sendAdditionalEmail__c == true && emailAsesor != null) {
                            system.debug('Entra a enviar despues de ir a Sima');
                            EmailTemplate et = [SELECT Id, Subject FROM EmailTemplate WHERE Name = 'newLeadToAsesor'];
                            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id,null , caso.Id);
                            String[] sendTo = new String[] { emailAsesor };
                            mail.setToAddresses(sendTo);
                            mail.setSaveAsActivity(true);
                        
                            //Enviar el email
                            Messaging.SendEmailResult[] emailSent = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                        }        

                    } else {

                        caso.Error_Mulesoft__c = '';
                        caso.ErrorMulesoft__c='';
                        caso.Status = Label.StatusClosed;
                        caso.Motivo_de_cierre__c = Label.motivoCierreDerivadoConcesionarioAutomatico;

                        if (caso.sendAdditionalEmail__c == true && emailAsesor != null) {
                            system.debug('Entra a enviar despues de ir a Sima');
                            EmailTemplate et = [SELECT Id, Subject FROM EmailTemplate WHERE Name = 'newLeadToAsesor'];
                            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id,null , caso.Id);
                            String[] sendTo = new String[] { emailAsesor };
                            mail.setToAddresses(sendTo);
                            mail.setSaveAsActivity(true);
                        
                            //Enviar el email
                            Messaging.SendEmailResult[] emailSent = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                        }        

                    }
                }
            	else if(isError504TimeOut(respuesta.Message)) {
                    caso.EnvioMulesoft__c = 'Error';
                    caso.Error_Mulesoft__c = respuesta.Message;
                    caso.ErrorMulesoft__c = '504 Gateway Time-out';
                }
                else {
                    caso.EnvioMulesoft__c = 'Error';
                    if (respuesta.Message != null && !string.isBlank(respuesta.Message)) {
                        caso.Error_Mulesoft__c = respuesta.Message;
                        ErrorMulesoftModel error = (ErrorMulesoftModel) JSON.deserialize(respuesta.Message, ErrorMulesoftModel.class);
                        caso.ErrorMulesoft__c='';
                        caso.ErrorMulesoft__c += !String.isBlank(error.code) ? 'code: ' + error.code + '\n':'';
                        caso.ErrorMulesoft__c += !String.isBlank(error.reason) ? 'reason: ' + error.reason + '\n':'';
                        caso.ErrorMulesoft__c += !String.isBlank(error.error) ? 'error: ' + error.error + '\n':'';
                        caso.ErrorMulesoft__c += !String.isBlank(error.errorDescription) ? 'errorDescription: ' + error.errorDescription + '\n':'';
                        caso.ErrorMulesoft__c += !String.isBlank(error.errorMessage) ? 'errorMessage: '+ error.errorMessage + '\n':'';
                    } else {
                        caso.Error_Mulesoft__c = respuesta.Status;
                    }
                }
            }
            else if (respuestaCustomer != null) {
                if (!respuestaCustomer.Status.equalsIgnoreCase('OK')) {
                    if (isError504TimeOut(respuestaCustomer.Message)) {
                    	caso.EnvioMulesoft__c = 'Error';
                    	caso.Error_Mulesoft__c = respuestaCustomer.Message;
                    	caso.ErrorMulesoft__c = '504 Gateway Time-out';
                	}
                	else {
                    	caso.EnvioMulesoft__c = 'Error';
                        if (respuestaCustomer.Message != null && !string.isBlank(respuestaCustomer.Message)) {
                            caso.Error_Mulesoft__c = respuestaCustomer.Message;
                            ErrorMulesoftModel error = (ErrorMulesoftModel) JSON.deserialize(respuestaCustomer.Message, ErrorMulesoftModel.class);
                            caso.ErrorMulesoft__c='';
                            caso.ErrorMulesoft__c += !String.isBlank(error.code) ? 'code: ' + error.code + '\n':'';
                            caso.ErrorMulesoft__c += !String.isBlank(error.reason) ? 'reason: ' + error.reason + '\n':'';
                            caso.ErrorMulesoft__c += !String.isBlank(error.error) ? 'error: ' + error.error + '\n':'';
                            caso.ErrorMulesoft__c += !String.isBlank(error.errorDescription) ? 'errorDescription: ' + error.errorDescription + '\n':'';
                            caso.ErrorMulesoft__c += !String.isBlank(error.errorMessage) ? 'errorMessage: '+ error.errorMessage + '\n':'';
                        } else {
                            caso.Error_Mulesoft__c = respuestaCustomer.Status;
                        }
                	}	
                }
            }
    
            if (!String.isBlank(caso.Lead__c) ) {
                if (mapAccountToInsertByCaseId.containsKey(idCaso)) {
                    caso.AccountId = mapAccountToInsertByCaseId.get(idCaso).Id;
                }
                
                //caso.AccountId = mapAccountToInsertByCaseId.get(idCaso).id;
                caso.ContactId = caso.AccountId != null && mapContactByAccountId.containsKey(caso.AccountId)?mapContactByAccountId.get(caso.AccountId).Id:null;

                system.debug('Inma1 caso.ContactId: '+caso.ContactId);
                system.debug('Inma1 caso.Lead__c: '+caso.Lead__c);
                   
                if (caso.ContactId != null && caso.Lead__c != null) {
                    Registros_Relacionados__c rr = new Registros_Relacionados__c();
                    rr.Registro_Origen__c = caso.Lead__c;
                    rr.Registro_Destino__c = caso.ContactId;
                    insert rr;
                }
                
                caso.Lead__c = caso.AccountId!=null?null:caso.Lead__c;

                
            }
            
            listCaseToUpdate.add(caso);
        }
        
        if (!mapIdExternalOpps.isEmpty()) {
            insert mapIdExternalOpps.values();
        }
        for(Case caso :listCaseToUpdate){
              if(mapIdExternalOpps.containsKey(caso.Error_Mulesoft__c)){
                  Opportunity opp =  mapIdExternalOpps.get(caso.Error_Mulesoft__c);
                  caso.Opportunity__c = opp.Id;
              }
          }
        
        system.debug('listCaseToUpdate:'+ listCaseToUpdate);
        if(!listCaseToUpdate.isEmpty()){
            update listCaseToUpdate;
        }
        
        //Eliminamos Lead
        if(!listLeadIdToDelete.isEmpty()){
            listLeadToDelete = [select id from lead where id IN :listLeadIdToDelete];
            if(!listLeadToDelete.isEmpty()){
                delete listLeadToDelete;
            }
        }
          
     }catch(Exception e){
         Exception__c exc = new Exception__c ();
         exc.idObjetos__c = idsCasos.length()>254?idsCasos.substring(0, 254):idsCasos;
         exc.Exception__c = e.getCause() + '// '+ e.getMessage();
         exc.Linea__c = e.getLineNumber();
         exc.Clase_Metodo__c = 'ExternalServiceController.createExternalLeadOrAccountMulesoft (future)';
         if (!mapCaseIdToResponseCustomer.isEmpty()) {
             exc.JSON_Entrada__c = 'respuestaCustomer:'+mapCaseIdToResponseCustomer;
         }   
         if (!mapCaseIdToResponse.isEmpty()) {
             exc.JSON_Entrada__c += 'respuesta:'+mapCaseIdToResponse;
         }   
         insert exc;
     }   
    }
    
    //Para envio de customer y de lead: para el boton con un solo caso
    public static String createExternalLeadOrAccountMulesoftSec(String JSONCases, String JSONgLead) {
      system.debug('entra a createExternalLeadOrAccountMulesoftSec');
      String respuestaMetodo='';
      ResponseApi respuesta;  
      ResponseApi respuestaCustomer;  
      Case caso = (Case) JSON.deserialize(JSONCases, Case.class);
      try{
        caso.Error_Mulesoft__c='';
        caso.EnvioMulesoft__c ='';
        caso.ErrorMulesoft__c ='';
        Gestion_Lead__c gLead = (Gestion_Lead__c) JSON.deserialize(JSONgLead, Gestion_Lead__c.class);
        Map<String, Pais__c> mapPaisByName = new Map<String, Pais__c>();
        List<Cliente_Concesionario__c> listClienteConcesionario= new List<Cliente_Concesionario__c>();
       	List<Case> casesLead = new List<Case>();
        List<Case> casesToUpdate = new List<Case>();
        
        String concesionarioIdSima = '';
        String emailAsesor = '';
        Centro__c Centro;
        Campaign campaign;
        Account cuenta;
        Lead candidato;
        Map<String,Consentimientos__c> mapConsentimientosValue;
        Map<String,CampaignMember> mapCOrLToCMByCampaignId = new Map<String,CampaignMember>();
        CampaignMember campaignMemberToInsert;
        CampaignMember campaignMemberTODelete;
        System.debug('antes de ExternalCustomerApiModel.CustomerApi');
        ExternalCustomerApiModel.CustomerApi externalCustomerApi = new ExternalCustomerApiModel.CustomerApi();
        System.debug('despues de ExternalCustomerApiModel.CustomerApi');
        ExternalLeadApiModel.LeadApi externalLeadApi = new ExternalLeadApiModel.LeadApi();
        ExternalLeadApiNewModel.LeadApi externalLeadApiNew = new ExternalLeadApiNewModel.LeadApi();
        ExternalConsentimientoApiModel.ConsentimientoApi externalConsentimientoApi = new ExternalConsentimientoApiModel.ConsentimientoApi();
        List<Consentimientos__c> listConsentimientoToUpdate = new List<Consentimientos__c>();
        List<String> listConsentimientoIdToDelete = new List<String>();
        List<Consentimientos__c> listConsentimientoToDelete = new List<Consentimientos__c>();
        Cliente_Concesionario__c cConcesionarioToInsert;
        Account cuentaAux;
        Account cuentaToInsert;
        Boolean duplicado = false;

        // Center
        if (gLead.Centro_destino__c != null) {
            centro = CentroGateway.getCenterById(gLead.Centro_destino__c);
            concesionarioIdSima = !String.isBlank(centro.Concesionario__r.Id_Concesionario_Sima__c)? centro.Concesionario__r.Id_Concesionario_Sima__c:'';
        }
          
        //Asesor
        if (gLead.Asesor__c != null) {
            User asesor = UserGateway.getUserById(gLead.Asesor__c);
            emailAsesor = asesor.Email;
        } else if (gLead.EmailAsesor__c != null) {
            emailAsesor = gLead.EmailAsesor__c;
        }

            // Campaign
        	if (caso.Campana__c != null) {
            	campaign = CampaignGateway.getCampaignById(caso.Campana__c);
        	}
          
        //Mediante cliente 
        if (caso.AccountId != null) {
            cuenta = AccountGateway.getAccountById(caso.AccountId);
          	List<String> listaPaises = new List<String>();
            if (!String.isBlank(cuenta.ShippingCountry)) {
            	listaPaises.add(DataValidations.capitalizeString(cuenta.ShippingCountry));
            }
            
            if (!String.isBlank(cuenta.BillingCountry)) {
            	listaPaises.add(DataValidations.capitalizeString(cuenta.BillingCountry));
            }
            
            if (!listaPaises.isEmpty()) {
                mapPaisByName = PaisGateway.getPaisByName(listaPaises);
            }
            
            mapConsentimientosValue = ConsentimientosGateway.getConsentimientosValueByAccountId(cuenta.Id);
            
            Cliente_Concesionario__c cConcesionario;
            listClienteConcesionario = ClienteConcesionarioGateway.searchClienteConcesionariosByAccountIdInt(cuenta.Id);
            for (Cliente_Concesionario__c cConcesionarioQ : listClienteConcesionario ) {
            	if (concesionarioIdSima.equalsIgnoreCase(cConcesionarioQ.Concesionario__r.Id_Concesionario_Sima__c)) {
                	cConcesionario = cConcesionarioQ;
                }
			}
            
            if (cConcesionario != null) {
                //Existe cliente Concesionario con ese concesionario
                externalLeadApi = createExternalLead(caso, centro, campaign, cConcesionario.Id_Cliente_DMS__c, emailAsesor,false);
                    system.debug ('createExternalLeadNew pasa por 4');
                externalLeadApiNew = createExternalLeadNew(caso, centro, campaign, cConcesionario.Id_Cliente_DMS__c, emailAsesor,false);

                if (date.today() < date.parse(label.startDiler)) {
                	respuesta = ExternalServiceCallout.createLeadApiCallout(externalLeadApi);
                } else {
                	respuesta = ExternalServiceCallout.createLeadApiCalloutNew(externalLeadApiNew);
                }
                system.debug('Inma_respuesta:'+ respuesta); 
                
                if (listClienteConcesionario != null && mapConsentimientosValue != null) {
                	externalConsentimientoApi = createExternalConsentimiento(mapConsentimientosValue.values(), listClienteConcesionario);
                    ResponseApi respuestaConse = ExternalServiceCallout.sendConsentimientoApiCallout(externalConsentimientoApi);
					system.debug('respuestaConse:'+ respuestaConse);                 
                }
                
                if (respuesta.Status.equalsIgnoreCase('OK')) {
                    caso.EnvioMulesoft__c = respuesta.Status;
                	caso.Error_Mulesoft__c = respuesta.Message;
                    caso.ErrorMulesoft__c='';
                    caso.Status = Label.StatusClosed;
                    caso.Motivo_de_cierre__c = Label.motivoCierreOportunidad;
                }
                else {
                    caso.EnvioMulesoft__c = 'Error';
	                if (respuesta.Message != null && !string.isBlank(respuesta.Message)) {
                        caso.Error_Mulesoft__c = respuesta.Message;
                        ErrorMulesoftModel error = (ErrorMulesoftModel) JSON.deserialize(respuesta.Message, ErrorMulesoftModel.class);
                        caso.ErrorMulesoft__c='';
                        caso.ErrorMulesoft__c += !String.isBlank(error.code) ? 'code: ' + error.code + '\n':'';
                        caso.ErrorMulesoft__c += !String.isBlank(error.reason) ? 'reason: ' + error.reason + '\n':'';
                        caso.ErrorMulesoft__c += !String.isBlank(error.error) ? 'error: ' + error.error + '\n':'';
                        caso.ErrorMulesoft__c += !String.isBlank(error.errorDescription) ? 'errorDescription: ' + error.errorDescription + '\n':'';
                        caso.ErrorMulesoft__c += !String.isBlank(error.errorMessage) ? 'errorMessage: '+ error.errorMessage + '\n':'';
                    } else {
                        caso.Error_Mulesoft__c = respuesta.Status;
                    }
                    respuestaMetodo ='Ha ocurrido un error. Revise parámetros de envio.';
                }
            }
            else {
               //No existe cliente concesionario con ese companyId a ese cliente.
               externalCustomerApi = createExternalCustomer(caso, centro, cuenta, null, mapPaisByName);
               //enviar creación de cliente
               respuestaCustomer = ExternalServiceCallout.createAccountApiCallout(externalCustomerApi);
                
                if (respuestaCustomer.Status.equalsIgnoreCase('OK')) {
               		externalLeadApi = createExternalLead(caso, centro, campaign, respuestaCustomer.Message, emailAsesor,false);
                    system.debug ('createExternalLeadNew pasa por 5');
               		externalLeadApiNew = createExternalLeadNew(caso, centro, campaign, respuestaCustomer.Message, emailAsesor,false);
                    if (date.today() < date.parse(label.startDiler)) {
                        respuesta = ExternalServiceCallout.createLeadApiCallout(externalLeadApi);
                    } else {
                        respuesta = ExternalServiceCallout.createLeadApiCalloutNew(externalLeadApiNew);
                    }
                    system.debug('Inma_respuesta:'+ respuesta); 
                	cConcesionarioToInsert = createCconcesionario(cuenta, respuestaCustomer.Message, centro.Concesionario__c, centro.Concesionario__r.Id_Concesionario_Sima__c);
                	if(listClienteConcesionario != null && mapConsentimientosValue != null ){
                		listClienteConcesionario.add(cConcesionarioToInsert);
                    	externalConsentimientoApi = createExternalConsentimiento(mapConsentimientosValue.values(), listClienteConcesionario, centro);
                    	ResponseApi respuestaConse = ExternalServiceCallout.sendConsentimientoApiCallout(externalConsentimientoApi);
						system.debug('respuestaConse:'+ respuestaConse);
                 	}
                    
                   //Actualizar caso
                   if (respuesta.Status.equalsIgnoreCase('OK')) {
                       caso.EnvioMulesoft__c = respuesta.Status;
                	   caso.Error_Mulesoft__c = respuesta.Message; 
                       caso.ErrorMulesoft__c='';
                       caso.Status = Label.StatusClosed;
                       caso.Motivo_de_cierre__c = Label.motivoCierreOportunidad;
                   }
                   else {
                       caso.EnvioMulesoft__c = 'Error';
	                   if (respuesta.Message != null && !string.isBlank(respuesta.Message)) {
                           caso.Error_Mulesoft__c = respuesta.Message;
                           ErrorMulesoftModel error = (ErrorMulesoftModel) JSON.deserialize(respuesta.Message, ErrorMulesoftModel.class);
                           caso.ErrorMulesoft__c='';
                           caso.ErrorMulesoft__c += !String.isBlank(error.code) ? 'code: ' + error.code + '\n':'';
                           caso.ErrorMulesoft__c += !String.isBlank(error.reason) ? 'reason: ' + error.reason + '\n':'';
                           caso.ErrorMulesoft__c += !String.isBlank(error.error) ? 'error: ' + error.error + '\n':'';
                           caso.ErrorMulesoft__c += !String.isBlank(error.errorDescription) ? 'errorDescription: ' + error.errorDescription + '\n':'';
                           caso.ErrorMulesoft__c += !String.isBlank(error.errorMessage) ? 'errorMessage: '+ error.errorMessage + '\n':'';
                       } else {
                           caso.Error_Mulesoft__c = respuesta.Status;
                       }
                   	   respuestaMetodo ='Ha ocurrido un error. Revise parámetros de envio.';
                   }
				}
				else {
                	caso.EnvioMulesoft__c = respuestaCustomer.Status;
	                if (respuestaCustomer.Message != null && !string.isBlank(respuestaCustomer.Message)) {
                        caso.Error_Mulesoft__c = respuestaCustomer.Message;
                        ErrorMulesoftModel error = (ErrorMulesoftModel) JSON.deserialize(respuestaCustomer.Message, ErrorMulesoftModel.class);
                        caso.ErrorMulesoft__c='';
                        caso.ErrorMulesoft__c += !String.isBlank(error.code) ? 'code: ' + error.code + '\n':'';
                        caso.ErrorMulesoft__c += !String.isBlank(error.reason) ? 'reason: ' + error.reason + '\n':'';
                        caso.ErrorMulesoft__c += !String.isBlank(error.error) ? 'error: ' + error.error + '\n':'';
                        caso.ErrorMulesoft__c += !String.isBlank(error.errorDescription) ? 'errorDescription: ' + error.errorDescription + '\n':'';
                        caso.ErrorMulesoft__c += !String.isBlank(error.errorMessage) ? 'errorMessage: '+ error.errorMessage + '\n':'';
                    } else {
                        caso.Error_Mulesoft__c = respuestaCustomer.Status;
                    }
                    respuestaMetodo ='Ha ocurrido un error. Revise parámetros de envio.';
                }
        	}
        }
        //Mediante lead
        else if (caso.Lead__c != null) {
            candidato = LeadGateway.getLeadById(caso.Lead__c);
            mapConsentimientosvalue = ConsentimientosGateway.getConsentimientosValueByLeadId(candidato.Id);
            casesLead = CaseGateway.getCaseByLead(caso.Lead__c);
            
            externalCustomerApi = createExternalCustomer(caso, centro, null, candidato, mapPaisByName);
            respuestaCustomer = ExternalServiceCallout.createAccountApiCallout(externalCustomerApi);
            
            if (respuestaCustomer.Status.equalsIgnoreCase('OK')) {
            	externalLeadApi = createExternalLead(caso, centro, campaign, respuestaCustomer.Message, emailAsesor, false);
                    system.debug ('createExternalLeadNew pasa por 6');
            	externalLeadApiNew = createExternalLeadNew(caso, centro, campaign, respuestaCustomer.Message, emailAsesor, false);
                if (date.today() < date.parse(label.startDiler)) {
                	respuesta = ExternalServiceCallout.createLeadApiCallout(externalLeadApi);
                } else {
                	respuesta = ExternalServiceCallout.createLeadApiCalloutNew(externalLeadApiNew);
                }
                system.debug('Inma_respuesta:'+ respuesta); 
                cuentaAux = createAccount(candidato, caso, mapPaisByName);
                System.debug('CUENTA AUX' + cuentaAux);
                
                if (!String.isBlank(cuentaAux.Id)) {
                	cConcesionarioToInsert = createCconcesionario(cuentaAux, respuestaCustomer.Message, centro.Concesionario__c, centro.Concesionario__r.Id_Concesionario_Sima__c);
                    caso.AccountId = cuentaAux.Id;
                    duplicado = true;
                    
                    if (mapConsentimientosValue != null ) {
						externalConsentimientoApi = createExternalConsentimiento(mapConsentimientosValue.values(), new List<Cliente_Concesionario__c> {cConcesionarioToInsert}, centro);
						ResponseApi respuestaConse = ExternalServiceCallout.sendConsentimientoApiCallout(externalConsentimientoApi);
						system.debug('respuestaConse:'+ respuestaConse);
                    }
                }
                else {
                    cuentaToInsert = cuentaAux;
                    cConcesionarioToInsert = createCconcesionario(null, respuestaCustomer.Message, centro.Concesionario__c, centro.Concesionario__r.Id_Concesionario_Sima__c);
                    
                    if (mapConsentimientosValue != null ) {
                     	externalConsentimientoApi = createExternalConsentimiento(mapConsentimientosValue.values(), new List<Cliente_Concesionario__c> {cConcesionarioToInsert}, centro);
                   		ResponseApi respuestaConse = ExternalServiceCallout.sendConsentimientoApiCallout(externalConsentimientoApi);
						system.debug('respuestaConse:'+ respuestaConse);
                    }
               }
               
               if (respuesta.Status.equalsIgnoreCase('OK')) {
                    caso.EnvioMulesoft__c = respuesta.Status;
                	caso.Error_Mulesoft__c = respuesta.Message;
                    caso.ErrorMulesoft__c='';
                    caso.Status = Label.StatusClosed;
                    caso.Motivo_de_cierre__c = Label.motivoCierreOportunidad;
                }
                else {
                    caso.EnvioMulesoft__c = 'Error';
	                if (respuesta.Message != null && !string.isBlank(respuesta.Message)) {
                        caso.Error_Mulesoft__c = respuesta.Message;
                        ErrorMulesoftModel error = (ErrorMulesoftModel) JSON.deserialize(respuesta.Message, ErrorMulesoftModel.class);
                        caso.ErrorMulesoft__c='';
                        caso.ErrorMulesoft__c += !String.isBlank(error.code) ? 'code: ' + error.code + '\n':'';
                        caso.ErrorMulesoft__c += !String.isBlank(error.reason) ? 'reason: ' + error.reason + '\n':'';
                        caso.ErrorMulesoft__c += !String.isBlank(error.error) ? 'error: ' + error.error + '\n':'';
                        caso.ErrorMulesoft__c += !String.isBlank(error.errorDescription) ? 'errorDescription: ' + error.errorDescription + '\n':'';
                        caso.ErrorMulesoft__c += !String.isBlank(error.errorMessage) ? 'errorMessage: '+ error.errorMessage + '\n':'';
                    } else {
                        caso.Error_Mulesoft__c = respuesta.Status;
                    }
                    respuestaMetodo ='Ha ocurrido un error. Revise parámetros de envio.';
                }
            }
            else {
                caso.EnvioMulesoft__c = 'Error';
                if (respuestaCustomer.Message != null && !string.isBlank(respuestaCustomer.Message)) {
                    caso.Error_Mulesoft__c = respuestaCustomer.Message;
                    ErrorMulesoftModel error = (ErrorMulesoftModel) JSON.deserialize(respuestaCustomer.Message, ErrorMulesoftModel.class);
                    caso.ErrorMulesoft__c='';
                    caso.ErrorMulesoft__c += !String.isBlank(error.code) ? 'code: ' + error.code + '\n':'';
                    caso.ErrorMulesoft__c += !String.isBlank(error.reason) ? 'reason: ' + error.reason + '\n':'';
                    caso.ErrorMulesoft__c += !String.isBlank(error.error) ? 'error: ' + error.error + '\n':'';
                    caso.ErrorMulesoft__c += !String.isBlank(error.errorDescription) ? 'errorDescription: ' + error.errorDescription + '\n':'';
                    caso.ErrorMulesoft__c += !String.isBlank(error.errorMessage) ? 'errorMessage: '+ error.errorMessage + '\n':'';
                } else {
                    caso.Error_Mulesoft__c = respuestaCustomer.Status;
                }
                respuestaMetodo ='Ha ocurrido un error. Revise parámetros de envio.';
            }
        } 
        
        Contact contacto;
        if (cuentaToInsert != null) {
            system.debug('1 cuentaToInsert:'+cuentaToInsert);           
            upsert cuentaToInsert;
            cConcesionarioToInsert.Cliente__c = cuentaToInsert.Id;
            contacto = ContactGateway.getContactByAccountId(cuentaToInsert.Id);
            caso.AccountId = cuentaToInsert.Id;
            caso.ContactId = contacto.Id;
            system.debug('Inma11 caso.ContactId: '+caso.ContactId);
            system.debug('Inma11 caso.Lead__c: '+caso.Lead__c);
                   
            if (caso.ContactId != null && caso.Lead__c != null) {
               Registros_Relacionados__c rr = new Registros_Relacionados__c();
               rr.Registro_Origen__c = caso.Lead__c;
               rr.Registro_Destino__c = caso.ContactId;
               insert rr;
            }
        }
        
        if (cConcesionarioToInsert != null) {
            if(!String.isBlank(cConcesionarioToInsert.External_Id__c)){
                Schema.SObjectField f = Cliente_Concesionario__c.Fields.External_Id__c;
				Database.upsert( cConcesionarioToInsert, f);
            }else{
                upsert cConcesionarioToInsert;
            }
            
        }
        
          
        //Para el paso de lead a cuentas
        if (duplicado && candidato != null && respuestaCustomer.Status.equalsIgnoreCase('OK')) {
            contacto = ContactGateway.getContactByAccountId(cuentaAux.Id);
            caso.ContactId = contacto.Id;
            Map<String,Consentimientos__c> mapConsentimientosValueAccount = ConsentimientosGateway.getConsentimientosValueByAccountId(cuentaAux.Id);
            
            if (mapConsentimientosvalue != null ) {
				for (Consentimientos__c consentimientoLead : mapConsentimientosvalue.values()) {
					if (mapConsentimientosValueAccount.containsKey(consentimientoLead.ChannelValue__c)) {
						Consentimientos__c consentimientoToUpdate = mapConsentimientosValueAccount.get(consentimientoLead.ChannelValue__c);
						consentimientoToUpdate.AfterSales__c= consentimientoLead.AfterSales__c;
						consentimientoToUpdate.AfterSalesSMS__c = consentimientoLead.AfterSalesSMS__c;
                        consentimientoToUpdate.CustomerSatisfaction__c = consentimientoLead.CustomerSatisfaction__c;
                        consentimientoToUpdate.CustomerSatisfactionSMS__c = consentimientoLead.CustomerSatisfactionSMS__c;
						consentimientoToUpdate.EventInvitation__c = consentimientoLead.EventInvitation__c;
						consentimientoToUpdate.EventInvitationSMS__c = consentimientoLead.EventInvitationSMS__c;
						consentimientoToUpdate.Fecha_de_captura__c = consentimientoLead.Fecha_de_captura__c;
						consentimientoToUpdate.MarketResearch__c = consentimientoLead.MarketResearch__c;
						consentimientoToUpdate.MarketResearchSMS__c = consentimientoLead.MarketResearchSMS__c;
						consentimientoToUpdate.ProductSale__c = consentimientoLead.ProductSale__c;
						consentimientoToUpdate.ProductSaleSMS__c = consentimientoLead.ProductSaleSMS__c;
						listConsentimientoToUpdate.add(consentimientoToUpdate);
						listConsentimientoIdToDelete.add(consentimientoLead.Id);
                    }
                    else {
                        consentimientoLead.Contact__c =contacto != null? contacto.Id:null;
                    	consentimientoLead.Lead__c = null;
                    	listConsentimientoToUpdate.add(consentimientoLead);
                    }
                }
			}  
            // Campaign
        	if (caso.Campana__c != null) {
//            	campaign = CampaignGateway.getCampaignById(caso.Campana__c);
            	mapCOrLToCMByCampaignId = CampaignMemberGateway.getMapCOrLToCampaignMemberByCampaignId(campaign.Id,contacto.id, candidato.Id);
        	}
        
             //Actualizacion campaignMember para clientes duplicados (Lead)
             if (contacto != null && !String.isBlank(caso.Campana__c) && !mapCOrLToCMByCampaignId.isEmpty() && !mapCOrLToCMByCampaignId.containsKey(contacto.Id)) {
             	campaignMemberToInsert = new CampaignMember();
                campaignMemberToInsert.CampaignId = caso.Campana__c;
                campaignMemberToInsert.ContactId = contacto.Id;
                campaignMemberToInsert.Status = Label.StatustResponded;
             }

             if (!mapCOrLToCMByCampaignId.isEmpty() && mapCOrLToCMByCampaignId.containsKey(caso.Lead__c)) {
                 campaignMemberToDelete = mapCOrLToCMByCampaignId.get(caso.Lead__c);
             }
            
            //Para los casos relacionados al lead anteriormente pasarlos a la cuenta duplicada
            for (Case casoLead : casesLead) {
            	if (casoLead.Id != caso.Id) {
                	casoLead.AccountId = caso.AccountId;
                    casoLead.ContactId = contacto.Id;
                    casoLead.Lead__c = null;
                    if (!casoLead.Owner.IsActive && casoLead.Unidad_de_negocio__c == Label.UnidadNegocioOpportunity){
                        casoLead.OwnerId = Label.UsuarioOpportunity;
                    }
                    if (!casoLead.Owner.IsActive && casoLead.Unidad_de_negocio__c == Label.UnidadNegocioMobility){
                        casoLead.OwnerId = Label.UsuarioMobility;
                    }
                    casesToUpdate.add(casoLead);
                 }
             }
        }
        else if (candidato != null && respuestaCustomer.Status.equalsIgnoreCase('OK')) {
            for (Consentimientos__c consentimientoLead :mapConsentimientosvalue.values()) {
                consentimientoLead.Contact__c =contacto != null? contacto.Id:null;
                consentimientoLead.Lead__c = null;
                String developerNameCon = ConsentimientosGateway.getRecordTypeDeveloperNameById(consentimientoLead.RecordTypeId);
                if(developerNameCon.equalsIgnoreCase(Label.RtConsentimientoEmail)){
                	consentimientoLead.Medio_de_contacto__c = Label.channelEmail;
                }
                else if(developerNameCon.equalsIgnoreCase(Label.RtConsentimientoMobile)){
                  	consentimientoLead.Medio_de_contacto__c = Label.channelMobile;
                }
                else if (developerNameCon.equalsIgnoreCase(Label.RtConsentimientoPhone)){
                   	consentimientoLead.Medio_de_contacto__c = Label.channelPhone;
                }
                listConsentimientoToUpdate.add(consentimientoLead);
            }
            // Campaign
        	if (caso.Campana__c != null) {
            	campaign = CampaignGateway.getCampaignById(caso.Campana__c);
            	mapCOrLToCMByCampaignId = CampaignMemberGateway.getMapCOrLToCampaignMemberByCampaignId(campaign.Id,contacto.id, candidato.Id);
        	}
            if (contacto != null && !String.isBlank(caso.Campana__c) && !mapCOrLToCMByCampaignId.isEmpty() && !mapCOrLToCMByCampaignId.containsKey(contacto.Id)) {
             	campaignMemberToInsert = new CampaignMember();
                campaignMemberToInsert.CampaignId = caso.Campana__c;
                campaignMemberToInsert.ContactId = contacto.Id;
                campaignMemberToInsert.Status = Label.StatustResponded;
            }
            
            if (mapCOrLToCMByCampaignId.containsKey(caso.Lead__c)) {
				campaignMemberToDelete = mapCOrLToCMByCampaignId.get(caso.Lead__c);
            }
            
           //Para los casos relacionados al lead anteriormente pasarlos a la cuenta
            for (Case casoLead :casesLead) {
            	if (casoLead.Id != caso.Id) {
                	casoLead.AccountId = caso.AccountId;
                    casoLead.ContactId = caso.ContactId;
                    casoLead.Lead__c = null;
                    if (!casoLead.Owner.IsActive && casoLead.Unidad_de_negocio__c == Label.UnidadNegocioOpportunity){
                        casoLead.OwnerId = Label.UsuarioOpportunity;
                    }
                    if (!casoLead.Owner.IsActive && casoLead.Unidad_de_negocio__c == Label.UnidadNegocioMobility){
                        casoLead.OwnerId = Label.UsuarioMobility;
                    }

                    casesToUpdate.add(casoLead);
                 }
             }
        }
        
        //actualizamos consentimientos
        if (!listConsentimientoToUpdate.isEmpty()) {
            update listConsentimientoToUpdate;
        }
        
        //insertamos miembro de campaña
        if (campaignMemberToInsert != null) {
            insert campaignMemberToInsert;
        }
        
        //eliminamos miembro de campaña
        if (campaignMemberToDelete != null) {
            delete campaignMemberToDelete;
        }
        
        //if (respuestaCustomer != null && respuestaCustomer.Status.equalsIgnoreCase('OK') && candidato != null) {
          //  caso.Lead__c = null;
          //  delete candidato;
        //}
        if (respuestaCustomer != null) {
			if (!respuestaCustomer.Status.equalsIgnoreCase('OK')) {
				if (isError504TimeOut(respuestaCustomer.Message)) {
					caso.EnvioMulesoft__c = 'Error';
                    caso.Error_Mulesoft__c = respuestaCustomer.Message;
                    caso.ErrorMulesoft__c = '504 Gateway Time-out';
                }
                else {
					caso.EnvioMulesoft__c = 'Error';
	                if (respuestaCustomer.Message != null && !string.isBlank(respuestaCustomer.Message)) {
                        caso.Error_Mulesoft__c = respuestaCustomer.Message;
                        ErrorMulesoftModel error = (ErrorMulesoftModel) JSON.deserialize(respuestaCustomer.Message, ErrorMulesoftModel.class);
                        caso.ErrorMulesoft__c='';
                        caso.ErrorMulesoft__c += !String.isBlank(error.code) ? 'code: ' + error.code + '\n':'';
                        caso.ErrorMulesoft__c += !String.isBlank(error.reason) ? 'reason: ' + error.reason + '\n':'';
                        caso.ErrorMulesoft__c += !String.isBlank(error.error) ? 'error: ' + error.error + '\n':'';
                        caso.ErrorMulesoft__c += !String.isBlank(error.errorDescription) ? 'errorDescription: ' + error.errorDescription + '\n':'';
                        caso.ErrorMulesoft__c += !String.isBlank(error.errorMessage) ? 'errorMessage: '+ error.errorMessage + '\n':'';
                    } else {
                        caso.Error_Mulesoft__c = respuestaCustomer.Status;
                    }
                }	
           	}
            else if (candidato != null) {
                caso.Lead__c = null;
				List<Lead> listLeadToDelete = [select id from lead where id = :candidato.id];

				if(!listLeadToDelete.isEmpty()){
					delete listLeadToDelete;
				}
            }
        }
        
        if (respuesta != null) {
                if (respuesta.Status.equalsIgnoreCase('OK')) {
                	caso.EnvioMulesoft__c = respuesta.Status;
                    if (respuesta.Message != ''){
                        
                        caso.Error_Mulesoft__c = respuesta.Message;
                        caso.ErrorMulesoft__c='';
                        caso.Status = Label.StatusClosed;
                        caso.Motivo_de_cierre__c = Label.motivoCierreOportunidad;
                    
                        Opportunity opp = new Opportunity();
                        opp.Name =centro != null? centro.Concesionario__r.Nombre_Comercial__c+'/'+centro.Name+'/': respuesta.Message ;
                        opp.Centro__c = centro != null?centro.Id: caso.centro__c;
                        opp.Concesionario__c = centro != null?centro.Concesionario__c: caso.Concesionario__c;
                        opp.CloseDate = Date.today().addMonths(1);
                        opp.StageName = 'Qualification';
                        opp.ID_Oportunidad_DMS__c = respuesta.Message;
                        opp.AccountId = caso.AccountId != null ? caso.AccountId : cuentaToInsert.Id;
                        opp.CampaignId = !String.isBlank(caso.Campana__c) ? caso.Campana__c : null;
                        system.debug('caso.RecommendByName__c: '+caso.RecommendByName__c);
                        opp.RecommendByName__c = !String.isBlank(caso.RecommendByName__c) ? caso.RecommendByName__c : null;
                        system.debug('opp.RecommendByName__c: '+opp.RecommendByName__c);
                        insert opp;
                        caso.Opportunity__c = opp.Id;
    
                        // si aplica se envia email al asesor
                        if (caso.sendAdditionalEmail__c == true && emailAsesor != null) {
                            system.debug('Entra a enviar despues de ir a Sima');
                            EmailTemplate et = [SELECT Id, Subject FROM EmailTemplate WHERE Name = 'newLeadToAsesor'];
                            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id,null , caso.Id);
                            String[] sendTo = new String[] { emailAsesor };
                            mail.setToAddresses(sendTo);
                            mail.setSaveAsActivity(true);
                        
                            //Enviar el email
                            Messaging.SendEmailResult[] emailSent = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                        }        

                    } else {

                        caso.Error_Mulesoft__c = respuesta.Message;
                        caso.ErrorMulesoft__c='';
                        caso.Status = Label.StatusClosed;
                        caso.Motivo_de_cierre__c = Label.motivoCierreDerivadoConcesionario;
                        // si aplica se envia email al asesor
                        if (caso.sendAdditionalEmail__c == true && emailAsesor != null) {
                            system.debug('Entra a enviar despues de ir a Sima');
                            EmailTemplate et = [SELECT Id, Subject FROM EmailTemplate WHERE Name = 'newLeadToAsesor'];
                            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id,null , caso.Id);
                            String[] sendTo = new String[] { emailAsesor };
                            mail.setToAddresses(sendTo);
                            mail.setSaveAsActivity(true);
                        
                            //Enviar el email
                            Messaging.SendEmailResult[] emailSent = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                        }        

                    }
               }
            	else if(isError504TimeOut(respuesta.Message)) {
                    caso.EnvioMulesoft__c = 'Error';
                    caso.Error_Mulesoft__c = respuesta.Message;
                    caso.ErrorMulesoft__c = '504 Gateway Time-out';
                }
                else {
                    caso.EnvioMulesoft__c = 'Error';
                    if (respuesta.Message != null && !string.isBlank(respuesta.Message)) {
                        caso.Error_Mulesoft__c = respuesta.Message;
                        ErrorMulesoftModel error = (ErrorMulesoftModel) JSON.deserialize(respuesta.Message, ErrorMulesoftModel.class);
                        caso.ErrorMulesoft__c='';
                        caso.ErrorMulesoft__c += !String.isBlank(error.code)?'code: '+ error.code +'\n':'';
                        caso.ErrorMulesoft__c += !String.isBlank(error.reason)?'reason: ' + error.reason + '\n':'';
                        caso.ErrorMulesoft__c += !String.isBlank(error.error) ?'error: ' + error.error + '\n':'';
                        caso.ErrorMulesoft__c += !String.isBlank(error.errorDescription)? 'errorDescription: '+error.errorDescription+ '\n':'';
                        caso.ErrorMulesoft__c += !String.isBlank(error.errorMessage)?'errorMessage: '+ error.errorMessage +'\n':'';
                    } else {
                        caso.Error_Mulesoft__c = respuesta.Status;
                    }
                }
            }
        
        casesToUpdate.add(caso);
        update casesToUpdate;
        respuestaMetodo = caso.EnvioMulesoft__c.equalsIgnoreCase('OK')?'Operación completada con éxito':'Ha ocurrido un error. Revise parámetros de envio.';
        }catch(Exception e){
         respuestaMetodo = 'Ha ocurrido un error. Póngase en contacto con el administrador.';
         Exception__c exc = new Exception__c ();
         exc.idObjetos__c = caso.Id;
         exc.Exception__c = e.getCause() + '// '+ e.getMessage();
         exc.Linea__c = e.getLineNumber();
         exc.Clase_Metodo__c = 'ExternalServiceController.createExternalLeadOrAccountMulesoftSec';
         if (respuestaCustomer != null) {
             exc.JSON_Entrada__c = 'respuestaCustomer:'+respuestaCustomer;
         }   
         if (respuesta != null) {
             exc.JSON_Entrada__c += 'respuesta:'+respuesta;
         }   
         insert exc;
     }   
    
        return respuestaMetodo;
    }
    
    //Para envio de consentimientos
    @future(callout=true)
    public static void sendConsentimientoMulesfoft(String JSONListContact) {
      List<String> listaContacto = (List<String>) JSON.deserialize(JSONListContact, List<String>.class);
      String contactosId ='';
      for(String contacto : listaContacto){
            contactosId+=contacto+',';
        }
      try{
        Map<String,Contact> mapContactById = ContactGateway.getContactById(listaContacto);
        
        Map<String,Map<String,Consentimientos__c>>  mapConsentimientosByContacts = ConsentimientosGateway.getConsentimientosByContacts(listaContacto);
        
        //Cliente Concesionario
        Map<String,List<Cliente_Concesionario__c>> mapCConcesionariosByAccountId = new Map<String,List<Cliente_Concesionario__c>>();
        List<String> listAccountId = new List<String>();
        if(!mapContactById.isEmpty()){
            for(Contact contacto :mapContactById.values()){
                if(!String.isBlank(contacto.AccountId) && contacto.Account.IsPersonAccount){
                    listAccountId.add(contacto.AccountId);
                }
            }
            if(!listAccountId.isEmpty()){
                mapCConcesionariosByAccountId = ClienteConcesionarioGateway.getclienteConcesionarioByAccountId(listAccountId);
            }
            
        }
        
        for(String contactoId :listaContacto){
            Contact contacto = mapContactById.containsKey(contactoId) ? mapContactById.get(contactoId):null;
        	List<Cliente_Concesionario__c> listCconcesionario = !String.isBlank(contacto.AccountId) && mapCConcesionariosByAccountId.containsKey(contacto.AccountId) ? mapCConcesionariosByAccountId.get(contacto.AccountId):null;
            Map<String,Consentimientos__c> mapConsentimiento = contacto != null && mapConsentimientosByContacts.containsKey(contacto.Id) ? mapConsentimientosByContacts.get(contacto.Id):null;
            if(listCconcesionario != null && mapConsentimiento != null ){
                ExternalConsentimientoApiModel.ConsentimientoApi externalConsentimientoApi = createExternalConsentimiento(mapConsentimiento.values(), listCconcesionario);
                    system.debug('externalConsentimientoApi0: '+externalConsentimientoApi);
                ResponseApi respuesta = ExternalServiceCallout.sendConsentimientoApiCallout(externalConsentimientoApi);
                system.debug('respuesta::'+ respuesta);
                if(!respuesta.ErrorCode.equalsIgnoreCase('200')){
                    Exception__c exc = new Exception__c ();
         			exc.idObjetos__c = contactosId.length()>254?contactosId.substring(0, 254):contactosId;
         			exc.Exception__c = 'Error de Respuesta: ' + respuesta.ErrorCode + 'Mensaje de respuesta: ' + respuesta.Message;
                    exc.JSON_Entrada__c = JSON.serialize(externalConsentimientoApi);
         			exc.Linea__c = 1024;
         			exc.Clase_Metodo__c = 'ExternalServiceController.sendConsentimientoMulesfoft(future)';
         			insert exc;
                }
            }
        }
        }catch(Exception e){
         Exception__c exc = new Exception__c ();
         exc.idObjetos__c = contactosId.length()>254?contactosId.substring(0, 254):contactosId;
         exc.Exception__c = e.getCause() + '// '+ e.getMessage();
         exc.Linea__c = e.getLineNumber();
         exc.Clase_Metodo__c = 'ExternalServiceController.sendConsentimientoMulesfoft(future)';
         insert exc;
     }   
    
    }
    
    //Para envio de consentimientos sin un cliente
    @future(callout=true)
    public static void sendConsentimientoMulesoft(String contactId, String externalCustomerId ) {
      try{
          if(!String.isBlank(contactId)){
                Contact contacto = ContactGateway.getContactById(contactId);
        		Map<String,Consentimientos__c>  mapConsentimiento = ConsentimientosGateway.getConsentimientosByContact(contacto.Id);
        		List<Cliente_Concesionario__c> cConcesionarios = ClienteConcesionarioGateway.searchClienteConcesionariosByAccountIdInt(contacto.AccountId);
       			Integer remove;
        		if(cConcesionarios != null && cConcesionarios.size()>1 && mapConsentimiento != null ){
        		    for(Integer i=0;i<cConcesionarios.size();i++){
            		    if(!String.isBlank(cConcesionarios[i].External_Id__c) && cConcesionarios[i].External_Id__c.equalsIgnoreCase(externalCustomerId)){
                		    remove=i;
                		    break;
                		}
            		}
            		if(remove != null){
                		cConcesionarios.remove(remove);
            		}
            		ExternalConsentimientoApiModel.ConsentimientoApi externalConsentimientoApi = createExternalConsentimiento(mapConsentimiento.values(), cConcesionarios);
                    system.debug('externalConsentimientoApi1: '+externalConsentimientoApi);
                	ResponseApi respuesta = ExternalServiceCallout.sendConsentimientoApiCallout(externalConsentimientoApi);
                	system.debug('respuesta::'+ respuesta);
        		}
          }
       }catch(Exception e){
         Exception__c exc = new Exception__c ();
         exc.idObjetos__c = contactId;
         exc.Exception__c = e.getCause() + '// '+ e.getMessage();
         exc.Linea__c = e.getLineNumber();
         exc.Clase_Metodo__c = 'ExternalServiceController.sendConsentimientoMulesoft(future)';
         insert exc;
     }  
	}    
    
    //Para envio de consentimientos a un cliente concreto
    @future(callout=true)
    public static void sendConsentimientoMulesoft2(String contactId, String externalCustomerId ) {
      try{
          if(!String.isBlank(contactId)){
                Contact contacto = ContactGateway.getContactById(contactId);
        		Map<String,Consentimientos__c>  mapConsentimiento = ConsentimientosGateway.getConsentimientosByContact(contacto.Id);
                List<Cliente_Concesionario__c> cConcesionarios = new List<Cliente_Concesionario__c>();
                cConcesionarios.add(ClienteConcesionarioGateway.getClienteConcesionarioByIdExternal(externalCustomerId)); 
            	ExternalConsentimientoApiModel.ConsentimientoApi externalConsentimientoApi = createExternalConsentimiento(mapConsentimiento.values(), cConcesionarios);
                system.debug('externalConsentimientoApi: '+externalConsentimientoApi);
                ResponseApi respuesta = ExternalServiceCallout.sendConsentimientoApiCallout(externalConsentimientoApi);
                system.debug('respuesta::'+ respuesta);
          }
       }catch(Exception e){
         Exception__c exc = new Exception__c ();
         exc.idObjetos__c = contactId;
         exc.Exception__c = e.getCause() + '// '+ e.getMessage();
         exc.Linea__c = e.getLineNumber();
         exc.Clase_Metodo__c = 'ExternalServiceController.sendConsentimientoMulesoft2(future)';
         insert exc;
     }  
	}    
    
    @future(callout=true)
    public static void sendExternalLeadOrAccountVO(String JSONCases, String JSONgLead) {
      List<Case> listaCasos = (List<Case>) JSON.deserialize(JSONCases, List<Case>.class);
      String idsCasos = '';
      ResponseApi respuestaCustomer;  
      for(Case caso :listaCasos){
            idsCasos+=caso.Id+',';
        }
      try{
        Gestion_Lead__c gLead = (Gestion_Lead__c) JSON.deserialize(JSONgLead, Gestion_Lead__c.class);
        String emailAsesor = '';
        Boolean enviado = false;
        Map<String, Case> mapCaseById = new Map<String, Case>();
        Map<String, Centro__c> mapCentroById = new Map<String, Centro__c>();
        Map<String, Campaign> mapCampaignById = new Map<String, Campaign>();
        Map<String, Account> mapAccountById = new Map<String, Account>();
        Map<String, Lead> mapLeadById = new Map<String, Lead>();
        Map<String, Pais__c> mapPaisByName = new Map<String, Pais__c>();
        Map<String, Map<String, CampaignMember>> mapCOrLToCMByCampaignId = new Map<String,Map<String, CampaignMember>>();
        Map<String, Map<String, Cliente_Concesionario__c>> mapClienteConcesionarioByAccountId = new Map<String, Map<String, Cliente_Concesionario__c>>();
       	Map<String, Map<String, Consentimientos__c>> mapConsentimientovalueByLeadId = new Map<String, Map<String, Consentimientos__c>>();
        Map<String, Map<String, Consentimientos__c>> mapConsentimientovalueByAccountDuplicado = new Map<String, Map<String,Consentimientos__c>>();
        Map<String, List<Case>> mapLeadToCases = new Map<String,List<Case>>();
        
        List<String> listConcesionarioId = new List<String>();
        List<String> listCaseSendWithAccount = new List<String>();
        List<String> listCaseSendWithLead = new List<String>();
        List<String> listAccountId = new List<String>();
        List<String> listLeadId = new List<String>();
        List<String> listCentroId = new List<String>();
        List<String> listCampaignId = new List<String>();
        Map<String, String> mapAccountIdDuplicadobyCaseId = new Map<String,String>();
        
        Map<String, Cliente_Concesionario__c> mapCConcesionarioToInsertByCaseId = new Map<String, Cliente_Concesionario__c>();
        Map<String, Account> mapAccountToInsertByCaseId = new Map<String, Account>();
        Map<String, Map<String, CampaignMember>> mapCampaignMemberByCOrLByCampaigIdToInsert = new Map<String, Map<String,CampaignMember>>();
        List<Consentimientos__c> listConsentimientoToUpdate = new List<Consentimientos__c>();
        List<String> listConsentimientoIdToDelete = new List<String>();
        List<Consentimientos__c> listConsentimientoToDelete = new List<Consentimientos__c>();
        List<Case> listCaseToUpdate = new List<Case>();
        List<Lead> listLeadToDelete = new List<Lead>();
        List<String> listLeadIdToDelete = new List<String>();
        List<CampaignMember> listCampaignMemberToDelete = new List<CampaignMember>();
        Map<String, Messaging.SingleEmailMessage> mapCasoMessaging = new Map<String, Messaging.SingleEmailMessage>();
        Map<String, Case> mapCaaseToUpdateEmail = new Map<String, Case>();
        EmailTemplate et = [SELECT Id, Subject, Body FROM EmailTemplate WHERE Name = 'newLeadToAsesorVO'];
        
        for (Case caso : listaCasos) {
            mapCaseById.put(caso.Id, caso);
/*            
            if (caso.Centro__c != null) {
                listCentroId.add(caso.Centro__c);
            }
*/            
            if (caso.Campana__c != null) {
                listCampaignId.add(caso.Campana__c);
            }
            
            if (caso.AccountId != null) {
                listCaseSendWithAccount.add(caso.id);
                listAccountId.add(caso.AccountId);
            }
            else if (caso.Lead__c != null) {
                listCaseSendWithLead.add(caso.Id);
                listLeadId.add(caso.Lead__c);
            }
        }

        if (gLead.Centro_destino__c != null) {
            listCentroId.add(gLead.Centro_destino__c);
        }
          
        //Centro 
        if (!listCentroId.isEmpty()) {
        	mapCentroById =  CentroGateway.getCenterById(listCentroId);
           
            for (Centro__c centro : mapCentroById.values()) {
                if (centro.Concesionario__c != null && !listConcesionarioId.contains(centro.Concesionario__c)) {
                    listConcesionarioId.add(centro.Concesionario__c);
                }
            }
        }
        
        //Asesor
        if (gLead.Asesor__c != null) {
            User asesor = UserGateway.getUserById(gLead.Asesor__c);
            emailAsesor = asesor.Email;
        } else if (gLead.EmailAsesor__c != null) {
            emailAsesor = gLead.EmailAsesor__c;
        }
        
        //Asociado con cliente
        if (!listAccountId.isEmpty()) {
            mapAccountById = AccountGateway.getAccountById(listAccountId);
            
            Map<String, Map<String, Consentimientos__c>> mapConsentimientosValueByAccountId = ConsentimientosGateway.getConsentimientosByAccountId(listAccountId);
            Map<String, List<Cliente_Concesionario__c>> mapAllClienteConcesionarioByAccountId = ClienteConcesionarioGateway.getclienteConcesionarioByAccountId(listAccountId);
            
            for (Cliente_Concesionario__c cConcesionario : [SELECT Id, Id_Cliente_DMS__c, Cliente__c, Concesionario__c, Concesionario__r.Id_Concesionario_Sima__c
                                                             FROM Cliente_Concesionario__c
                                                            WHERE Cliente__c in :listAccountId
                                                              AND Es_Seccion__c = false]) {
                Map<String, Cliente_Concesionario__c> mapClienteCByConcesionario = mapClienteConcesionarioByAccountId.containsKey(cConcesionario.Cliente__c)
                    ? mapClienteConcesionarioByAccountId.get(cConcesionario.Cliente__c) : new Map<String, Cliente_Concesionario__c>();
                mapClienteCByConcesionario.put(cConcesionario.Concesionario__c, cConcesionario);
                mapClienteConcesionarioByAccountId.put(cConcesionario.Cliente__c, mapClienteCByConcesionario);
            }
            
            for (String idCaso : listCaseSendWithAccount) {
                ExternalConsentimientoApiModel.ConsentimientoApi externalConsentimientoApi = new ExternalConsentimientoApiModel.ConsentimientoApi();
                ExternalCustomerApiModel.CustomerApi externalCustomerApi = new ExternalCustomerApiModel.CustomerApi();
                Case caso = mapCaseById.get(idCaso);
                Centro__c centro = gLead.Centro_destino__c != null && mapCentroById.containsKey(gLead.Centro_destino__c) ? mapCentroById.get(gLead.Centro_destino__c) : null;
                Campaign campania = caso.Campana__c != null && mapCampaignById.containsKey(caso.Campana__c) ? mapCampaignById.get(caso.Campana__c) : null;
                Account cuenta = caso.AccountId != null && mapAccountById.containsKey(caso.AccountId) ? mapAccountById.get(caso.AccountId) : null;
                System.debug('CUENTA CASO: ' + cuenta);
                
                if (mapClienteConcesionarioByAccountId.containsKey(cuenta.Id)) {
                    Map<String, Cliente_Concesionario__c> mapClienteCByConcesionario = mapClienteConcesionarioByAccountId.get(caso.AccountId);
                    
                    if (mapClienteCByConcesionario.containsKey(centro.Concesionario__c)) {
                        caso.EnvioMulesoft__c = 'Envio email';
                        mapCaseById.put(caso.Id, caso);
                            
                        Map<String,Consentimientos__c> mapConsentimientoValue = mapConsentimientosValueByAccountId.containsKey(caso.AccountId)
                            ? mapConsentimientosValueByAccountId.get(caso.AccountId) : null;
                        List<Cliente_Concesionario__c> listAllClienteConcesionario = mapAllClienteConcesionarioByAccountId.containsKey(caso.AccountId)
                            ? mapAllClienteConcesionarioByAccountId.get(caso.AccountId) : null;
                        
                        if (listAllClienteConcesionario != null && mapConsentimientoValue != null) {
                            externalConsentimientoApi = createExternalConsentimiento(mapConsentimientoValue.values(), listAllClienteConcesionario);
                            ResponseApi respuestaConse = ExternalServiceCallout.sendConsentimientoApiCallout(externalConsentimientoApi);
                            system.debug('respuestaConse:'+ respuestaConse);                 
                        }
                    }
                    else {
                        externalCustomerApi = createExternalCustomer(caso, centro, cuenta, null, mapPaisByName);
                        respuestaCustomer = ExternalServiceCallout.createAccountApiCallout(externalCustomerApi);
                        
                        if (respuestaCustomer.Status.equalsIgnoreCase('OK')) {
                            caso.EnvioMulesoft__c = 'Envio email';
                            mapCaseById.put(caso.Id, caso);
                            Cliente_Concesionario__c cliConc = createCconcesionario(cuenta, respuestaCustomer.Message, centro.Concesionario__c, centro.Concesionario__r.Id_Concesionario_Sima__c);
                        	mapCConcesionarioToInsertByCaseId.put(caso.Id, cliConc); 
                            Map<String,Consentimientos__c> mapConsentimientoValue = mapConsentimientosValueByAccountId.containsKey(caso.AccountId) ? mapConsentimientosValueByAccountId.get(caso.AccountId): null;
                            List<Cliente_Concesionario__c> listAllClienteConcesionario = mapAllClienteConcesionarioByAccountId.containsKey(caso.AccountId) ? mapAllClienteConcesionarioByAccountId.get(caso.AccountId): null;
                            if (cliConc != null) {
                                listAllClienteConcesionario.add(cliConc);
                                if (listAllClienteConcesionario != null && mapConsentimientoValue != null) {
                                    externalConsentimientoApi = createExternalConsentimiento(mapConsentimientoValue.values(), listAllClienteConcesionario, centro);
                                    ResponseApi respuestaConse = ExternalServiceCallout.sendConsentimientoApiCallout(externalConsentimientoApi);
                                    system.debug('respuestaConse:'+ respuestaConse);                 
                                }
                            }    
                        }
                        else {
                            caso.EnvioMulesoft__c = 'Error';
                            if (respuestaCustomer.Message != null && !string.isBlank(respuestaCustomer.Message)) {
                                caso.Error_Mulesoft__c = respuestaCustomer.Message;
                                ErrorMulesoftModel error = (ErrorMulesoftModel) JSON.deserialize(respuestaCustomer.Message, ErrorMulesoftModel.class);
                                caso.ErrorMulesoft__c='';
                                caso.ErrorMulesoft__c += !String.isBlank(error.code) ? 'code: ' + error.code + '\n':'';
                                caso.ErrorMulesoft__c += !String.isBlank(error.reason) ? 'reason: ' + error.reason + '\n':'';
                                caso.ErrorMulesoft__c += !String.isBlank(error.error) ? 'error: ' + error.error + '\n':'';
                                caso.ErrorMulesoft__c += !String.isBlank(error.errorDescription) ? 'errorDescription: ' + error.errorDescription + '\n':'';
                                caso.ErrorMulesoft__c += !String.isBlank(error.errorMessage) ? 'errorMessage: '+ error.errorMessage + '\n':'';
                            } else {
                                caso.Error_Mulesoft__c = respuestaCustomer.Status;
                            }
                            mapCaseById.put(caso.Id, caso);
                        }
                    }
                }
                else {
                    externalCustomerApi = createExternalCustomer(caso, centro, cuenta, null, mapPaisByName);
                    respuestaCustomer = ExternalServiceCallout.createAccountApiCallout(externalCustomerApi);
                    
                    if (respuestaCustomer.Status.equalsIgnoreCase('OK')) {
                    	Cliente_Concesionario__c cliConc = createCconcesionario(cuenta, respuestaCustomer.Message, centro.Concesionario__c, centro.Concesionario__r.Id_Concesionario_Sima__c);
                        mapCConcesionarioToInsertByCaseId.put(caso.Id, cliConc); 
                        caso.EnvioMulesoft__c = 'Envio email';
                        mapCaseById.put(caso.Id, caso);
                        
                                
                        Map<String, Consentimientos__c> mapConsentimientoValue = mapConsentimientosValueByAccountId.containsKey(caso.AccountId)
                            ? mapConsentimientosValueByAccountId.get(caso.AccountId) : null;
                        List<Cliente_Concesionario__c> listAllClienteConcesionario = mapAllClienteConcesionarioByAccountId.containsKey(caso.AccountId)
                            ? mapAllClienteConcesionarioByAccountId.get(caso.AccountId) : new List<Cliente_Concesionario__c>();
                        if (cliConc != null) {
                        	listAllClienteConcesionario.add(cliConc);
                            
                            if (listAllClienteConcesionario != null && mapConsentimientoValue != null) {
                                externalConsentimientoApi = createExternalConsentimiento(mapConsentimientoValue.values(), listAllClienteConcesionario, centro);
                                ResponseApi respuestaConse = ExternalServiceCallout.sendConsentimientoApiCallout(externalConsentimientoApi);
                                System.debug('respuestaConse:'+ respuestaConse);                 
                            }
                        }   
                    }
                    else {
                        caso.EnvioMulesoft__c = 'Error';
                        if (respuestaCustomer.Message != null && !string.isBlank(respuestaCustomer.Message)) {
                            caso.Error_Mulesoft__c = respuestaCustomer.Message;
                            ErrorMulesoftModel error = (ErrorMulesoftModel) JSON.deserialize(respuestaCustomer.Message, ErrorMulesoftModel.class);
                            caso.ErrorMulesoft__c='';
                            caso.ErrorMulesoft__c += !String.isBlank(error.code) ? 'code: ' + error.code + '\n':'';
                            caso.ErrorMulesoft__c += !String.isBlank(error.reason) ? 'reason: ' + error.reason + '\n':'';
                            caso.ErrorMulesoft__c += !String.isBlank(error.error) ? 'error: ' + error.error + '\n':'';
                            caso.ErrorMulesoft__c += !String.isBlank(error.errorDescription) ? 'errorDescription: ' + error.errorDescription + '\n':'';
                            caso.ErrorMulesoft__c += !String.isBlank(error.errorMessage) ? 'errorMessage: '+ error.errorMessage + '\n':'';
                        } else {
                            caso.Error_Mulesoft__c = respuestaCustomer.Status;
                        }
                        mapCaseById.put(caso.Id, caso);
                    }
                }
            }
        }
        
        //Asociado con lead
        if (!listLeadId.isEmpty()) {
            mapConsentimientovalueByLeadId = ConsentimientosGateway.getConsentimientosByLeadId(listLeadId);
            mapLeadById = LeadGateway.getLeadIdByIds(listLeadId);
            mapLeadToCases = CaseGateway.getCaseByLead(listLeadId);
            List<String> listaPaises = new List<String>();
            
            for (Lead candidato : mapLeadById.values()) {
                if (!String.isBlank(candidato.Country)) {
                    listaPaises.add(DataValidations.capitalizeString(candidato.Country));
                }
            }
            
            mapPaisByName = PaisGateway.getPaisByName(listaPaises);
        	for (String idCaso : listCaseSendWithLead) {
                ExternalConsentimientoApiModel.ConsentimientoApi externalConsentimientoApi = new ExternalConsentimientoApiModel.ConsentimientoApi();
                ExternalCustomerApiModel.CustomerApi externalCustomerApi = new ExternalCustomerApiModel.CustomerApi();
                Case caso = mapCaseById.get(idCaso);
                Centro__c centro = gLead.Centro_destino__c != null && mapCentroById.containsKey(gLead.Centro_destino__c) ? mapCentroById.get(gLead.Centro_destino__c) : null;
                Campaign campania = caso.Campana__c != null && mapCampaignById.containsKey(caso.Campana__c) ? mapCampaignById.get(caso.Campana__c) : null;
                Lead candidato = caso.Lead__c != null && mapLeadById.containsKey(caso.Lead__c) ? mapLeadById.get(caso.Lead__c) : null;
            	externalCustomerApi = createExternalCustomer(caso, centro, null, candidato, mapPaisByName);
                respuestaCustomer = ExternalServiceCallout.createAccountApiCallout(externalCustomerApi);
                if (respuestaCustomer.Status.equalsIgnoreCase('OK')) {
                	listLeadIdToDelete.add(candidato.id);
                    Account cuenta = createAccount(candidato, caso, mapPaisByName);
                    
                    if (!String.isBlank(cuenta.Id)) {
						Cliente_Concesionario__c cConcesionarioToInsert = createCconcesionario(cuenta, respuestaCustomer.Message, centro.Concesionario__c, centro.Concesionario__r.Id_Concesionario_Sima__c);
						mapCConcesionarioToInsertByCaseId.put(caso.Id, cConcesionarioToInsert); 
						caso.AccountId = cuenta.Id;
                        mapAccountIdDuplicadobyCaseId.put(caso.Id, cuenta.Id);
						Map<String,Consentimientos__c> mapConsentimientoValue = mapConsentimientovalueByLeadId.containsKey(caso.Lead__c) ? mapConsentimientovalueByLeadId.get(caso.Lead__c): null;
                       	
                        if (mapConsentimientoValue != null ) {
                            externalConsentimientoApi = createExternalConsentimiento(mapConsentimientoValue.values(), new List<Cliente_Concesionario__c> {cConcesionarioToInsert}, centro);
                    		ResponseApi respuestaConse = ExternalServiceCallout.sendConsentimientoApiCallout(externalConsentimientoApi);
							system.debug('respuestaConse:'+ respuestaConse);
                        }
                    }
                    else {
                        mapAccountToInsertByCaseId.put(caso.Id,cuenta);
                        Cliente_Concesionario__c cConcesionarioToInsert = createCconcesionario(null, respuestaCustomer.Message, centro.Concesionario__c, centro.Concesionario__r.Id_Concesionario_Sima__c);
                        mapCConcesionarioToInsertByCaseId.put(caso.Id,cConcesionarioToInsert);
                        Map<String, Consentimientos__c> mapConsentimientoValue = mapConsentimientovalueByLeadId.containsKey(caso.Lead__c) ? mapConsentimientovalueByLeadId.get(caso.Lead__c) : null;

                        if (mapConsentimientoValue != null ) {
                            externalConsentimientoApi = createExternalConsentimiento(mapConsentimientoValue.values(), new List<Cliente_Concesionario__c> {cConcesionarioToInsert}, centro);
                    		ResponseApi respuestaConse = ExternalServiceCallout.sendConsentimientoApiCallout(externalConsentimientoApi);
							system.debug('respuestaConse:'+ respuestaConse);
                        }	
                    }
				    caso.EnvioMulesoft__c = 'Envio email';
                	mapCaseById.put(caso.Id, caso);
                }
                else {
                	caso.EnvioMulesoft__c = 'Error';
                    if (respuestaCustomer.Message != null && !string.isBlank(respuestaCustomer.Message)) {
                        caso.Error_Mulesoft__c = respuestaCustomer.Message;
                        ErrorMulesoftModel error = (ErrorMulesoftModel) JSON.deserialize(respuestaCustomer.Message, ErrorMulesoftModel.class);
                        caso.ErrorMulesoft__c='';
                        caso.ErrorMulesoft__c += !String.isBlank(error.code) ? 'code: ' + error.code + '\n':'';
                        caso.ErrorMulesoft__c += !String.isBlank(error.reason) ? 'reason: ' + error.reason + '\n':'';
                        caso.ErrorMulesoft__c += !String.isBlank(error.error) ? 'error: ' + error.error + '\n':'';
                        caso.ErrorMulesoft__c += !String.isBlank(error.errorDescription) ? 'errorDescription: ' + error.errorDescription + '\n':'';
                        caso.ErrorMulesoft__c += !String.isBlank(error.errorMessage) ? 'errorMessage: '+ error.errorMessage + '\n':'';
                    } else {
                        caso.Error_Mulesoft__c = respuestaCustomer.Status;
                    }
                	mapCaseById.put(caso.Id, caso);
                }
        	}
        }
        
        //Creamos Cuenta
        Map<String, Contact> mapContactByAccountId = new Map<String, Contact>();
        
		if (!mapAccountToInsertByCaseId.isEmpty()) {
           	Insert mapAccountToInsertByCaseId.values();
           	system.debug('insertar: mapAccountToInsertByCaseId'+ mapAccountToInsertByCaseId);
		}
        	
        List<String> listCuentaId = new List<String>();
        List<String> listContactId = new List<String>();
        
       	for (Account cuenta : mapAccountToInsertByCaseId.values()) {
        		listCuentaId.add(cuenta.Id);
		}
        
        //cuenta duplicado en caso de lead a la hora de intentar crear cuenta
        if (!mapAccountIdDuplicadoByCaseId.isEmpty()) {
           	listCuentaId.addAll(mapAccountIdDuplicadobyCaseId.values());
           	mapConsentimientovalueByAccountDuplicado = ConsentimientosGateway.getConsentimientosByAccountId(mapAccountIdDuplicadobyCaseId.values());
       	}
        
        //Sacamos todos los contactos de las cuentas
        if (!listCuentaId.isEmpty()) {
        	mapContactByAccountId = ContactGateway.getContactByAccountId(listCuentaId);
            for(Contact contacto : mapContactByAccountId.values()){
                listContactId.add(contacto.Id);
            }
        }
        
        //Campaign
        if (!listCampaignId.isEmpty()) {
            mapCampaignById = CampaignGateway.getCampaignById(listCampaignId);
            mapCOrLToCMByCampaignId = CampaignMemberGateway.getMapCOrLToCampaignMemberByCampaignId(listCampaignId, listContactId,listLeadId);
        }
        
        //Actualizacion de consentimientos y campaignMember de cliente duplicados
        if (!mapAccountIdDuplicadoByCaseId.isEmpty()) {
            	for (String caseId : mapAccountIdDuplicadoByCaseId.keySet()) {
                	String accountId = mapAccountIdDuplicadoByCaseId.get(caseId);
                	Contact contacto = mapContactByAccountId.containsKey(accountId)?mapContactByAccountId.get(accountId):null;
                	Case caso = mapCaseById.get(caseId);
                	
                	//Actualizacion consentimientos para cuentas duplicadas
                	Map<String, Consentimientos__c> mapConsentimientoByValueLead = mapConsentimientovalueByLeadId.containsKey(caso.Lead__c)
                	    ? mapConsentimientovalueByLeadId.get(caso.Lead__c) : null;
                	Map<String, Consentimientos__c> mapConsentimientoByValue = mapConsentimientovalueByAccountDuplicado.containsKey(accountId)
                    	? mapConsentimientovalueByAccountDuplicado.get(accountId) : new Map<String,Consentimientos__c>();
                
                	if (mapConsentimientoByValueLead != null ) {
                    	for (Consentimientos__c consentimientoLead :mapConsentimientoByValueLead.values()){
                        	if (mapConsentimientoByValue.containsKey(consentimientoLead.ChannelValue__c)) {
                            	Consentimientos__c consentimientoToUpdate = mapConsentimientoByValue.get(consentimientoLead.ChannelValue__c);
                            	consentimientoToUpdate.AfterSales__c= consentimientoLead.AfterSales__c;
                            	consentimientoToUpdate.AfterSalesSMS__c = consentimientoLead.AfterSalesSMS__c;
                                consentimientoToUpdate.CustomerSatisfaction__c = consentimientoLead.CustomerSatisfaction__c;
                                consentimientoToUpdate.CustomerSatisfactionSMS__c = consentimientoLead.CustomerSatisfactionSMS__c;
                            	consentimientoToUpdate.EventInvitation__c = consentimientoLead.EventInvitation__c;
                            	consentimientoToUpdate.EventInvitationSMS__c = consentimientoLead.EventInvitationSMS__c;
                            	consentimientoToUpdate.Fecha_de_captura__c = consentimientoLead.Fecha_de_captura__c;
                            	consentimientoToUpdate.MarketResearch__c = consentimientoLead.MarketResearch__c;
                            	consentimientoToUpdate.MarketResearchSMS__c = consentimientoLead.MarketResearchSMS__c;
                            	consentimientoToUpdate.ProductSale__c = consentimientoLead.ProductSale__c;
                            	consentimientoToUpdate.ProductSaleSMS__c = consentimientoLead.ProductSaleSMS__c;
                            	consentimientoToUpdate.EnviarAmulesoft__c = false;
                            	listConsentimientoToUpdate.add(consentimientoToUpdate);
                            	listConsentimientoIdToDelete.add(consentimientoLead.Id);
                        	}
                        	else {
                            	consentimientoLead.Contact__c =contacto != null ? contacto.Id : null;
                    			consentimientoLead.Lead__c = null;
                            	consentimientoLead.EnviarAmulesoft__c = false;
                    			listConsentimientoToUpdate.add(consentimientoLead);
                        	}	
                    	}
                	}  
               
	                //Actualizacion campaignMember para clientes duplicados (Lead)
    	            if (!String.isBlank(caso.Campana__c)) {
    	                Map<String,CampaignMember> mapCOrLToCM =  mapCOrLToCMByCampaignId.containsKey(caso.Campana__c) ?mapCOrLToCMByCampaignId.get(caso.Campana__c): new Map<String,CampaignMember>();
    	                if(!mapCOrLToCM.containsKey(contacto.Id)){
    	                    Map<String,CampaignMember> mapCampaignMemberToInsert = mapCampaignMemberByCOrLByCampaigIdToInsert.containsKey(caso.Campana__c)?mapCampaignMemberByCOrLByCampaigIdToInsert.get(caso.Campana__c): new Map<String,CampaignMember>();
    	                    if(!mapCampaignMemberToInsert.containsKey(contacto.Id)){
    	                    	CampaignMember cMember = new CampaignMember();
    	                		cMember.CampaignId = caso.Campana__c;
    	                		cMember.ContactId = contacto.Id;
    	                		cMember.Status = Label.StatustResponded;
    	                    	mapCampaignMemberToInsert.put(cMember.ContactId, cMember);
    	                    	mapCampaignMemberByCOrLByCampaigIdToInsert.put(caso.Campana__c, mapCampaignMemberToInsert);
    	                    }
    	                }
    	                if(!String.isBlank(caso.Lead__c) && mapCOrLToCM.containsKey(caso.Lead__c)){
        	                    listCampaignMemberToDelete.add( mapCOrLToCM.get(caso.Lead__c));
        	                }
        	        }
                    
                    //Para los casos relacionados al lead anteriormente pasarlos a la cuenta duplicada
                	List<Case> listCases = mapLeadToCases.containsKey(caso.Lead__c)?mapLeadToCases.get(caso.Lead__c): null;
                	if (listCases != null){
                    	for(Case casoLead :listCases){
                        	if(casoLead.Id != caso.Id && !mapCaseById.containsKey(casoLead.Id) ){
                            	casoLead.AccountId = accountId;
                            	casoLead.ContactId = contacto.Id;
                                casoLead.Lead__c = null;
                                if (!casoLead.Owner.IsActive && casoLead.Unidad_de_negocio__c == Label.UnidadNegocioOpportunity){
                                    casoLead.OwnerId = Label.UsuarioOpportunity;
                                }
                                if (!casoLead.Owner.IsActive && casoLead.Unidad_de_negocio__c == Label.UnidadNegocioMobility){
                                    casoLead.OwnerId = Label.UsuarioMobility;
                                }
                            	listCaseToUpdate.add(casoLead);
                        	}
                    	}
                	}
            	}
         	}
        
        	//Actualizacion de cliente concesionario y consentimientos a clientes nuevos insertados
        	for (String caseId :mapAccountToInsertByCaseId.keySet()) {
        		Account cuenta = mapAccountToInsertByCaseId.get(caseId);
            	Contact contacto =  mapContactByAccountId.containsKey(cuenta.Id)?mapContactByAccountId.get(cuenta.Id):null;
            
            	//Cliente concesionario
            	Cliente_Concesionario__c cConcesionario = mapCConcesionarioToInsertByCaseId.get(caseId);
            	cConcesionario.Cliente__c = cuenta.Id;
            	mapCConcesionarioToInsertByCaseId.put(caseId,cConcesionario);
            
            	//Para el consentimiento en caso de cuentas nuevos
            	 Case caso = mapCaseById.get(caseId);
            	 if(!String.isBlank(caso.Lead__c) && mapConsentimientovalueByLeadId.containsKey(caso.Lead__c)){
            	 	Map<String,Consentimientos__c> mapConsentimientoByValue = mapConsentimientovalueByLeadId.get(caso.Lead__c);
            	    for(Consentimientos__c consentimiento :mapConsentimientoByValue.values()){
            	    	consentimiento.Contact__c = contacto != null?contacto.Id: null;
            	        consentimiento.Lead__c = null;
                        String developerNameCon = ConsentimientosGateway.getRecordTypeDeveloperNameById(consentimiento.RecordTypeId);
                    	if(developerNameCon.equalsIgnoreCase(Label.RtConsentimientoEmail)){
                    		consentimiento.Medio_de_contacto__c = Label.channelEmail;
                    	}
                    	else if(developerNameCon.equalsIgnoreCase(Label.RtConsentimientoMobile)){
                    		consentimiento.Medio_de_contacto__c = Label.channelMobile;
                    	}
                    	else if (developerNameCon.equalsIgnoreCase(Label.RtConsentimientoPhone)){
                    		consentimiento.Medio_de_contacto__c = Label.channelPhone;
                    	}
            	        listConsentimientoToUpdate.add(consentimiento);
            	     }
            	 }
            
            	//Para CampaigMember en caso de cuentas nuevas
            	if(!String.isBlank(caso.Campana__c)){
                	    Map<String,CampaignMember> mapCOrLToCM =  mapCOrLToCMByCampaignId.containsKey(caso.Campana__c) ?mapCOrLToCMByCampaignId.get(caso.Campana__c): new Map<String,CampaignMember>();
                	    if(!mapCOrLToCM.containsKey(contacto.Id)){
                	        Map<String,CampaignMember> mapCampaignMemberToInsert = mapCampaignMemberByCOrLByCampaigIdToInsert.containsKey(caso.Campana__c)?mapCampaignMemberByCOrLByCampaigIdToInsert.get(caso.Campana__c): new Map<String,CampaignMember>();
                	        if(!mapCampaignMemberToInsert.containsKey(contacto.Id)){
                	        	CampaignMember cMember = new CampaignMember();
                	    		cMember.CampaignId = caso.Campana__c;
                	    		cMember.ContactId = contacto.Id;
                	    		cMember.Status = Label.StatustResponded;
                	        	mapCampaignMemberToInsert.put(cMember.ContactId, cMember);
                	        	mapCampaignMemberByCOrLByCampaigIdToInsert.put(caso.Campana__c, mapCampaignMemberToInsert);
                	        }
                	    }
                	    if(!String.isBlank(caso.Lead__c) && mapCOrLToCM.containsKey(caso.Lead__c)){
                	            listCampaignMemberToDelete.add( mapCOrLToCM.get(caso.Lead__c));
                	        }
                	}
                
                //Para los casos relacionados al lead anteriormente pasarlos a la nueva cuenta
            	List<Case> listCases = mapLeadToCases.containsKey(caso.Lead__c)?mapLeadToCases.get(caso.Lead__c): null;
            	if (listCases != null){
                    for(Case casoLead :listCases){
                        if(casoLead.Id != caso.Id && !mapCaseById.containsKey(casoLead.Id) ){
                            casoLead.AccountId = cuenta.Id;
                            casoLead.ContactId = contacto.Id;
                            casoLead.Lead__c = null;
                            if (!casoLead.Owner.IsActive && casoLead.Unidad_de_negocio__c == Label.UnidadNegocioOpportunity){
                                casoLead.OwnerId = Label.UsuarioOpportunity;
                            }
                            if (!casoLead.Owner.IsActive && casoLead.Unidad_de_negocio__c == Label.UnidadNegocioMobility){
                                casoLead.OwnerId = Label.UsuarioMobility;
                            }
                            listCaseToUpdate.add(casoLead);
                        }
                    }
                }
        	}
			
            //Creamos cliente Concesionario
            system.debug('mapCConcesionarioToInsertByCaseId:'+ mapCConcesionarioToInsertByCaseId);
        	if(!mapCConcesionarioToInsertByCaseId.isEmpty()){
        	    Insert mapCConcesionarioToInsertByCaseId.values();
        	}
        	//Actualizamos consentimientos a los clientes nuevos insertados
        	if(!listConsentimientoToUpdate.isEmpty()){
            	UPDATE listConsentimientoToUpdate;
        	}
            //Eliminamos consentimientos de los lead
            if (!listConsentimientoIdToDelete.isEmpty()){
                listConsentimientoToDelete = [select id from Consentimientos__c where id IN :listConsentimientoIdToDelete];
                if(!listConsentimientoToDelete.isEmpty()){
                    delete listConsentimientoToDelete;
                }
            }

        	//Insercion de campaingMember
        	if (!mapCampaignMemberByCOrLByCampaigIdToInsert.isEmpty()) {
            	List<CampaignMember> listCampaignMemberToInsert = new List<CampaignMember>();
            	
                for (String campaignId : mapCampaignMemberByCOrLByCampaigIdToInsert.keySet()) {
                	Map<String,CampaignMember> mapCampaignMemberToInsert = mapCampaignMemberByCOrLByCampaigIdToInsert.get(campaignId);
            		listCampaignMemberToInsert.addAll(mapCampaignMemberToInsert.values());
            	}
                
                insert listCampaignMemberToInsert;
       		}
            
        	//Eliminacion de CampaignMember
        	if (!listCampaignMemberToDelete.isEmpty()) {
            	Delete listCampaignMemberToDelete;
        	}

        	//Actualización del caso y asociamos el caso a la cuenta cuando es lead
        	//creación del mensaje envio 
        	for (String idCaso : mapCaseById.keySet()) {
                Case caso = mapCaseById.get(idCaso);
                Centro__c centro = gLead.Centro_destino__c != null && mapCentroById.containsKey(gLead.Centro_destino__c) ? mapCentroById.get(gLead.Centro_destino__c) : null;
                Cliente_Concesionario__c cConcesionario;
                system.debug('mapCConcesionarioToInsertByCaseId'+mapCConcesionarioToInsertByCaseId);
                system.debug('mapClienteConcesionarioByAccountId'+mapClienteConcesionarioByAccountId);
                system.debug('caso.AccountId'+ caso.AccountId);
                
                if (caso.EnvioMulesoft__c.equalsIgnoreCase('Envio email')) {
                	if (mapCConcesionarioToInsertByCaseId.containsKey(caso.Id)) {
                    	cConcesionario = mapCConcesionarioToInsertByCaseId.get(caso.Id);
                    }
                    else if (caso.AccountId != null && mapClienteConcesionarioByAccountId.containsKey(caso.AccountId)) {
                        Map<String, Cliente_Concesionario__c> mapClienteCByConcesionario = mapClienteConcesionarioByAccountId.get(caso.AccountId);
                        
                        if (mapClienteCByConcesionario.containsKey(centro.Concesionario__c)) {
                            cConcesionario = mapClienteCByConcesionario.get(centro.Concesionario__c);
                        }   
                    }
                        
                    if (cConcesionario != null) {
                        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id, cConcesionario.Id , caso.Id);
                        String[] sendTo = new String[] { emailAsesor };
                        mail.setToAddresses(sendTo);
                        mail.setTargetObjectId(null);
                        mail.setSaveAsActivity(true);
                        mapCasoMessaging.put(caso.Id, mail);
                    }
				}
			}

        	//Envio de emails 
        	try {
            	if (!mapCasoMessaging.isEmpty()) {
            		system.debug('envio de emails:'+ mapCasoMessaging );
            		Messaging.SendEmailResult[] emailSent = Messaging.sendEmail(mapCasoMessaging.values());
            
            		if (emailSent[0].isSuccess()) {
                        system.debug('enviado ok');
               			enviado = true;
            		}
        		}
        	} catch(EmailException e) {
            	enviado = false;
        	}

        	system.debug('Antes de la modificacion del caso');
        	
        	for (String idCaso : mapCaseById.keySet()) {
            	Case caso = mapCaseById.get(idCaso);
            	system.debug('case:'+ caso);
            	system.debug('mapAccountToInsertByCaseId:'+ mapAccountToInsertByCaseId);
                
                //Si se ha enviado 
        		if (enviado) {
            		caso.Status = Label.StatusClosed;
            		caso.Motivo_de_cierre__c = Label.motivoCierreAutomatico;
            	}
                else {
                    caso.Error_Mulesoft__c= !String.isEmpty(caso.Error_Mulesoft__c)?caso.Error_Mulesoft__c:'Error envio email';
                }
                
                if (!String.isBlank(caso.Lead__c) ) {
                    if (mapAccountToInsertByCaseId.containsKey(idCaso) ) {
                        caso.AccountId = mapAccountToInsertByCaseId.get(idCaso).Id;
                    }
                    caso.ContactId = caso.AccountId != null && mapContactByAccountId.containsKey(caso.AccountId)?mapContactByAccountId.get(caso.AccountId).Id:null;

                    system.debug('Inma2 caso.ContactId: '+caso.ContactId);
                    system.debug('Inma2 caso.Lead__c: '+caso.Lead__c);
                       
                    if (caso.ContactId != null && caso.Lead__c != null) {
                        Registros_Relacionados__c rr = new Registros_Relacionados__c();
                        rr.Registro_Origen__c = caso.Lead__c;
                        rr.Registro_Destino__c = caso.ContactId;
                        insert rr;
                    }
                    
                    caso.Lead__c = caso.AccountId!=null?null:caso.Lead__c;
                }
                
            	listCaseToUpdate.add(caso);
        	}
            
        	system.debug('listCaseToUpdate:'+ listCaseToUpdate);
            
        	if (!listCaseToUpdate.isEmpty()) {
            	Update listCaseToUpdate;
        	}
            
        	//Eliminamos Lead
        	if (!listLeadIdToDelete.isEmpty()) {
                listLeadToDelete = [select id from lead where id IN :listLeadIdToDelete];
                if (!listLeadToDelete.isEmpty()) {
                    delete listLeadToDelete;
                }
        	}
		//actualizar casos de fallos, por ejemplos de las respuestas no Ok de creación de cliente en SIMA
		}catch(Exception e){
         Exception__c exc = new Exception__c ();
         exc.idObjetos__c = idsCasos.length()>254?idsCasos.substring(0, 254):idsCasos;
         exc.Exception__c = e.getCause() + '// '+ e.getMessage();
         exc.Linea__c = e.getLineNumber();
         exc.Clase_Metodo__c = 'ExternalServiceController.sendExternalLeadOrAccountVO (future)';
         if (respuestaCustomer != null) {
             exc.JSON_Entrada__c = 'respuestaCustomer:'+respuestaCustomer;
         }   
         insert exc;
     }   
    
    }
    
    public static String sendExternalLeadOrAccountVOSec(String JSONCases, String JSONgLead) {
     String respuestaMetodo='';
     Case caso = (Case) JSON.deserialize(JSONCases, Case.class);
     ResponseApi respuestaCustomer;  
     try {
        caso.Error_Mulesoft__c='';
        caso.EnvioMulesoft__c ='';
        caso.ErrorMulesoft__c ='';
        Gestion_Lead__c gLead = (Gestion_Lead__c) JSON.deserialize(JSONgLead, Gestion_Lead__c.class);
        String emailAsesor = '';
        Boolean enviado = false;
        Map<String, Pais__c> mapPaisByName = new Map<String, Pais__c>();
        
        List<Cliente_Concesionario__c> listClienteConcesionario= new List<Cliente_Concesionario__c>();
       	List<Case> casesLead = new List<Case>();
        List<Case> casesToUpdate = new List<Case>();
        
        String concesionarioIdSima = '';
        Centro__c Centro;
        Campaign campaign;
        Account cuenta;
        Lead candidato;
        Map<String,Consentimientos__c> mapConsentimientosValue;
        Map<String,CampaignMember> mapCOrLToCMByCampaignId = new Map<String,CampaignMember>();
        CampaignMember campaignMemberToInsert;
        CampaignMember campaignMemberTODelete;
        ExternalCustomerApiModel.CustomerApi externalCustomerApi = new ExternalCustomerApiModel.CustomerApi();
        ExternalLeadApiModel.LeadApi externalLeadApi = new ExternalLeadApiModel.LeadApi();
        ExternalConsentimientoApiModel.ConsentimientoApi externalConsentimientoApi = new ExternalConsentimientoApiModel.ConsentimientoApi();
        List<Consentimientos__c> listConsentimientoToUpdate = new List<Consentimientos__c>();
        List<String> listConsentimientoIdToDelete = new List<String>();
        List<Consentimientos__c> listConsentimientoToDelete = new List<Consentimientos__c>();
        Cliente_Concesionario__c cConcesionarioToInsert;
        Account cuentaAux;
        Account cuentaToInsert;
        Boolean duplicado = false;
        EmailTemplate et = [SELECT Id, Subject, Body FROM EmailTemplate WHERE Name = 'newLeadToAsesorVO'];
        Cliente_Concesionario__c cConcesionario;

        // Center
        if (gLead.Centro_destino__c != null) {
            centro = CentroGateway.getCenterById(gLead.Centro_destino__c);
            concesionarioIdSima = !String.isBlank(centro.Concesionario__r.Id_Concesionario_Sima__c)? centro.Concesionario__r.Id_Concesionario_Sima__c:'';
        }
         
        //Asesor
        if (gLead.Asesor__c != null) {
            User asesor = UserGateway.getUserById(gLead.Asesor__c);
            emailAsesor = asesor.Email;
        } else if (gLead.EmailAsesor__c != null) {
            emailAsesor = gLead.EmailAsesor__c;
        }

         //Mediante cliente 
        if (caso.AccountId != null) {
            cuenta = AccountGateway.getAccountById(caso.AccountId);
            mapConsentimientosValue = ConsentimientosGateway.getConsentimientosValueByAccountId(cuenta.Id);
            
            listClienteConcesionario = ClienteConcesionarioGateway.searchClienteConcesionariosByAccountIdInt(cuenta.Id);
            
            for (Cliente_Concesionario__c cConcesionarioQ : listClienteConcesionario ) {
            	if (concesionarioIdSima.equalsIgnoreCase(cConcesionarioQ.Concesionario__r.Id_Concesionario_Sima__c)) {
                	cConcesionario = cConcesionarioQ;
                }
			}
            
            if (cConcesionario != null) {
                //Existe cliente Concesionario con ese concesionario
                    caso.EnvioMulesoft__c = 'Envio email';
                    
                    if (listClienteConcesionario != null && mapConsentimientosValue != null) {
                        externalConsentimientoApi = createExternalConsentimiento(mapConsentimientosValue.values(), listClienteConcesionario);
                        ResponseApi respuestaConse = ExternalServiceCallout.sendConsentimientoApiCallout(externalConsentimientoApi);
                        system.debug('respuestaConse:'+ respuestaConse);                 
            		}
            }
            else {
                
				externalCustomerApi = createExternalCustomer(caso, centro, cuenta, candidato, mapPaisByName);
                respuestaCustomer = ExternalServiceCallout.createAccountApiCallout(externalCustomerApi);
                if (respuestaCustomer.Status.equalsIgnoreCase('OK')) {
					caso.EnvioMulesoft__c = 'Envio email';
                    cConcesionarioToInsert = createCconcesionario(cuenta, respuestaCustomer.Message, centro.Concesionario__c, centro.Concesionario__r.Id_Concesionario_Sima__c);
                    listClienteConcesionario.add(cConcesionarioToInsert);
                    
					if (listClienteConcesionario != null && mapConsentimientosValue != null) {
						externalConsentimientoApi = createExternalConsentimiento(mapConsentimientosValue.values(), listClienteConcesionario, centro);
						ResponseApi respuestaConse = ExternalServiceCallout.sendConsentimientoApiCallout(externalConsentimientoApi);
						system.debug('respuestaConse:'+ respuestaConse);                 
					}
				}
				else {
					caso.EnvioMulesoft__c = 'Error';
                    if (respuestaCustomer.Message != null && !string.isBlank(respuestaCustomer.Message)) {
                        caso.Error_Mulesoft__c = respuestaCustomer.Message;
                        ErrorMulesoftModel error = (ErrorMulesoftModel) JSON.deserialize(respuestaCustomer.Message, ErrorMulesoftModel.class);
                        caso.ErrorMulesoft__c='';
                        caso.ErrorMulesoft__c += !String.isBlank(error.code) ? 'code: ' + error.code + '\n':'';
                        caso.ErrorMulesoft__c += !String.isBlank(error.reason) ? 'reason: ' + error.reason + '\n':'';
                        caso.ErrorMulesoft__c += !String.isBlank(error.error) ? 'error: ' + error.error + '\n':'';
                        caso.ErrorMulesoft__c += !String.isBlank(error.errorDescription) ? 'errorDescription: ' + error.errorDescription + '\n':'';
                        caso.ErrorMulesoft__c += !String.isBlank(error.errorMessage) ? 'errorMessage: '+ error.errorMessage + '\n':'';
                    } else {
                        caso.Error_Mulesoft__c = respuestaCustomer.Status;
                    }
				}
        	}
        }
        
        //Mediante lead
        else if (caso.Lead__c != null) {
            candidato = LeadGateway.getLeadById(caso.Lead__c);
            mapConsentimientosvalue = ConsentimientosGateway.getConsentimientosValueByLeadId(candidato.Id);
            casesLead = CaseGateway.getCaseByLead(caso.Lead__c);
            List<String> listaPaises = new List<String>();
            
            if (!String.isBlank(candidato.Country)) {
                listaPaises.add(DataValidations.capitalizeString(candidato.Country));
            }
            System.debug('ANTES externalCustomerApi');  
            System.debug('caso: '+caso);
            System.debug('centro: '+centro);
            System.debug('centro: '+centro);
            System.debug('candidato: '+candidato);
            System.debug('mapPaisByName: '+mapPaisByName);
            externalCustomerApi = createExternalCustomer(caso, centro, null, candidato, mapPaisByName);

            System.debug('ANTES ExternalServiceCallout.createAccountApiCallout');  
            respuestaCustomer = ExternalServiceCallout.createAccountApiCallout(externalCustomerApi);
            
            if (respuestaCustomer.Status.equalsIgnoreCase('OK')) {
                cuenta = createAccount(candidato, caso, mapPaisByName);
                
            	if (!String.isBlank(cuenta.Id)) {
                	cConcesionarioToInsert = createCconcesionario(cuenta, respuestaCustomer.Message, centro.Concesionario__c, centro.Concesionario__r.Id_Concesionario_Sima__c);
                    caso.AccountId = cuenta.Id;
                    duplicado = true;
                    
                    if (mapConsentimientosValue != null ) {
						externalConsentimientoApi = createExternalConsentimiento(mapConsentimientosValue.values(), new List<Cliente_Concesionario__c> {cConcesionarioToInsert}, centro);
						ResponseApi respuestaConse = ExternalServiceCallout.sendConsentimientoApiCallout(externalConsentimientoApi);
						system.debug('respuestaConse:' + respuestaConse);
                    }
                }
                else {
                    cuentaToInsert = cuenta;
                    cConcesionarioToInsert = createCconcesionario(null, respuestaCustomer.Message, centro.Concesionario__c, centro.Concesionario__r.Id_Concesionario_Sima__c);
                    
                    if (mapConsentimientosValue != null ) {
                     	externalConsentimientoApi = createExternalConsentimiento(mapConsentimientosValue.values(), new List<Cliente_Concesionario__c> {cConcesionarioToInsert}, centro);
                   		ResponseApi respuestaConse = ExternalServiceCallout.sendConsentimientoApiCallout(externalConsentimientoApi);
						system.debug('respuestaConse:'+ respuestaConse);
                    }                    
               }
                caso.EnvioMulesoft__c = 'Envio email';
            }
            else {
				caso.EnvioMulesoft__c = 'Error';
                if (respuestaCustomer.Message != null && !string.isBlank(respuestaCustomer.Message)) {
                    caso.Error_Mulesoft__c = respuestaCustomer.Message;
                    ErrorMulesoftModel error = (ErrorMulesoftModel) JSON.deserialize(respuestaCustomer.Message, ErrorMulesoftModel.class);
                    caso.ErrorMulesoft__c='';
                    caso.ErrorMulesoft__c += !String.isBlank(error.code) ? 'code: ' + error.code + '\n':'';
                    caso.ErrorMulesoft__c += !String.isBlank(error.reason) ? 'reason: ' + error.reason + '\n':'';
                    caso.ErrorMulesoft__c += !String.isBlank(error.error) ? 'error: ' + error.error + '\n':'';
                    caso.ErrorMulesoft__c += !String.isBlank(error.errorDescription) ? 'errorDescription: ' + error.errorDescription + '\n':'';
                    caso.ErrorMulesoft__c += !String.isBlank(error.errorMessage) ? 'errorMessage: '+ error.errorMessage + '\n':'';
                } else {
                    caso.Error_Mulesoft__c = respuestaCustomer.Status;
                }
            }
        } 
        
        Contact contacto;
        
        if (cuentaToInsert != null) {
            system.debug('2 cuentaToInsert:'+cuentaToInsert);           
            upsert cuentaToInsert;
            cConcesionarioToInsert.Cliente__c = cuentaToInsert.Id;
            contacto = ContactGateway.getContactByAccountId(cuentaToInsert.Id);
            caso.AccountId = cuentaToInsert.Id;
            caso.ContactId = contacto.Id;
            system.debug('Inma21 caso.ContactId: '+caso.ContactId);
            system.debug('Inma21 caso.Lead__c: '+caso.Lead__c);
                   
            if (caso.ContactId != null && caso.Lead__c != null) {
               Registros_Relacionados__c rr = new Registros_Relacionados__c();
               rr.Registro_Origen__c = caso.Lead__c;
               rr.Registro_Destino__c = caso.ContactId;
               insert rr;
            }
        }
        
        if (cConcesionarioToInsert != null) {
            upsert cConcesionarioToInsert;
            cConcesionario = cConcesionarioToInsert;
        }
        
        //Para el paso de lead a cuentas
        if (duplicado && candidato != null && respuestaCustomer.Status.equalsIgnoreCase('OK')) {
            contacto = ContactGateway.getContactByAccountId(caso.AccountId);
            caso.ContactId = contacto.Id;
            Map<String, Consentimientos__c> mapConsentimientosValueAccount = ConsentimientosGateway.getConsentimientosValueByAccountId(caso.AccountId);
            
            if (mapConsentimientosvalue != null ) {
				for (Consentimientos__c consentimientoLead : mapConsentimientosvalue.values()) {
					if (mapConsentimientosValueAccount.containsKey(consentimientoLead.ChannelValue__c)) {
						Consentimientos__c consentimientoToUpdate = mapConsentimientosValueAccount.get(consentimientoLead.ChannelValue__c);
						consentimientoToUpdate.AfterSales__c= consentimientoLead.AfterSales__c;
						consentimientoToUpdate.AfterSalesSMS__c = consentimientoLead.AfterSalesSMS__c;
                        consentimientoToUpdate.CustomerSatisfaction__c = consentimientoLead.CustomerSatisfaction__c;
                        consentimientoToUpdate.CustomerSatisfactionSMS__c = consentimientoLead.CustomerSatisfactionSMS__c;
						consentimientoToUpdate.EventInvitation__c = consentimientoLead.EventInvitation__c;
						consentimientoToUpdate.EventInvitationSMS__c = consentimientoLead.EventInvitationSMS__c;
						consentimientoToUpdate.Fecha_de_captura__c = consentimientoLead.Fecha_de_captura__c;
						consentimientoToUpdate.MarketResearch__c = consentimientoLead.MarketResearch__c;
						consentimientoToUpdate.MarketResearchSMS__c = consentimientoLead.MarketResearchSMS__c;
						consentimientoToUpdate.ProductSale__c = consentimientoLead.ProductSale__c;
						consentimientoToUpdate.ProductSaleSMS__c = consentimientoLead.ProductSaleSMS__c;
						listConsentimientoToUpdate.add(consentimientoToUpdate);
						listConsentimientoIdToDelete.add(consentimientoLead.Id);
                    }
                    else {
                        consentimientoLead.Contact__c = contacto != null? contacto.Id : null;
                    	consentimientoLead.Lead__c = null;
                    	listConsentimientoToUpdate.add(consentimientoLead);
                    }
                }
			}  
            // Campaign
        	if (caso.Campana__c != null) {
            	//lstCampaignId.add(caso.Campana__c);
            	campaign = CampaignGateway.getCampaignById(caso.Campana__c);
            	mapCOrLToCMByCampaignId = CampaignMemberGateway.getMapCOrLToCampaignMemberByCampaignId(campaign.Id, contacto.Id, candidato.Id);
        	}
        
             //Actualizacion campaignMember para clientes duplicados (Lead)
             if (contacto != null && !String.isBlank(caso.Campana__c) && !mapCOrLToCMByCampaignId.isEmpty() && !mapCOrLToCMByCampaignId.containsKey(contacto.Id)) {
             	campaignMemberToInsert = new CampaignMember();
                campaignMemberToInsert.CampaignId = caso.Campana__c;
                campaignMemberToInsert.ContactId = contacto.Id;
                campaignMemberToInsert.Status = Label.StatustResponded;
             }

             if (!mapCOrLToCMByCampaignId.isEmpty() && mapCOrLToCMByCampaignId.containsKey(caso.Lead__c)) {
                 campaignMemberToDelete = mapCOrLToCMByCampaignId.get(caso.Lead__c);
             }
            
            //Para los casos relacionados al lead anteriormente pasarlos a la cuenta duplicada
            for (Case casoLead : casesLead) {
            	if (casoLead.Id != caso.Id) {
                	casoLead.AccountId = caso.AccountId;
                    casoLead.ContactId = contacto.Id;
                    casoLead.Lead__c = null;
                    if (!casoLead.Owner.IsActive && casoLead.Unidad_de_negocio__c == Label.UnidadNegocioOpportunity){
                        casoLead.OwnerId = Label.UsuarioOpportunity;
                    }
                    if (!casoLead.Owner.IsActive && casoLead.Unidad_de_negocio__c == Label.UnidadNegocioMobility){
                        casoLead.OwnerId = Label.UsuarioMobility;
                    }
                    casesToUpdate.add(casoLead);
                 }
             }
        }
        else if (candidato != null && respuestaCustomer.Status.equalsIgnoreCase('OK')) {
            for (Consentimientos__c consentimientoLead :mapConsentimientosvalue.values()) {
                consentimientoLead.Contact__c =contacto != null? contacto.Id:null;
                consentimientoLead.Lead__c = null;
                String developerNameCon = ConsentimientosGateway.getRecordTypeDeveloperNameById(consentimientoLead.RecordTypeId);
                    if(developerNameCon.equalsIgnoreCase(Label.RtConsentimientoEmail)){
                    	consentimientoLead.Medio_de_contacto__c = Label.channelEmail;
                    }
                    else if(developerNameCon.equalsIgnoreCase(Label.RtConsentimientoMobile)){
                    	consentimientoLead.Medio_de_contacto__c = Label.channelMobile;
                    }
                    else if (developerNameCon.equalsIgnoreCase(Label.RtConsentimientoPhone)){
                    	consentimientoLead.Medio_de_contacto__c = Label.channelPhone;
                    }
                listConsentimientoToUpdate.add(consentimientoLead);
            }
            // Campaign
	        if (caso.Campana__c != null) {
    	        //lstCampaignId.add(caso.Campana__c);
            	campaign = CampaignGateway.getCampaignById(caso.Campana__c);
        	    mapCOrLToCMByCampaignId = CampaignMemberGateway.getMapCOrLToCampaignMemberByCampaignId(campaign.Id,contacto.Id, candidato.Id );
        	}
        
            if (contacto != null && !String.isBlank(caso.Campana__c) && !mapCOrLToCMByCampaignId.isEmpty() && !mapCOrLToCMByCampaignId.containsKey(contacto.Id)) {
             	campaignMemberToInsert = new CampaignMember();
                campaignMemberToInsert.CampaignId = caso.Campana__c;
                campaignMemberToInsert.ContactId = contacto.Id;
                campaignMemberToInsert.Status = Label.StatustResponded;
            }
            
            if (mapCOrLToCMByCampaignId.containsKey(caso.Lead__c)) {
				campaignMemberToDelete = mapCOrLToCMByCampaignId.get(caso.Lead__c);
            }

           //Para los casos relacionados al lead anteriormente pasarlos a la cuenta
            for (Case casoLead :casesLead) {
            	if (casoLead.Id != caso.Id) {
                	casoLead.AccountId = caso.AccountId;
                    casoLead.ContactId = caso.ContactId;
                    casoLead.Lead__c = null;
                    if (!casoLead.Owner.IsActive && casoLead.Unidad_de_negocio__c == Label.UnidadNegocioOpportunity){
                        casoLead.OwnerId = Label.UsuarioOpportunity;
                    }
                    if (!casoLead.Owner.IsActive && casoLead.Unidad_de_negocio__c == Label.UnidadNegocioMobility){
                        casoLead.OwnerId = Label.UsuarioMobility;
                    }
                    casesToUpdate.add(casoLead);
                 }
             }
        }
        
        //actualizamos consentimientos
        if (!listConsentimientoToUpdate.isEmpty()) {
            update listConsentimientoToUpdate;
        }
        
        //insertamos miembro de campaña
        if (campaignMemberToInsert != null) {
            insert campaignMemberToInsert;
        }
        
        //eliminamos miembro de campaña
        if (campaignMemberToDelete != null) {
            delete campaignMemberToDelete;
        }
        
        if (respuestaCustomer != null) {
			if (!respuestaCustomer.Status.equalsIgnoreCase('OK')) {
				if (isError504TimeOut(respuestaCustomer.Message)) {
					caso.EnvioMulesoft__c = 'Error';
                    caso.Error_Mulesoft__c = respuestaCustomer.Message;
                    caso.ErrorMulesoft__c = '504 Gateway Time-out';
                }
                else {
					caso.EnvioMulesoft__c = 'Error';
                    if (respuestaCustomer.Message != null && !string.isBlank(respuestaCustomer.Message)) {
                        caso.Error_Mulesoft__c = respuestaCustomer.Message;
                        ErrorMulesoftModel error = (ErrorMulesoftModel) JSON.deserialize(respuestaCustomer.Message, ErrorMulesoftModel.class);
                        caso.ErrorMulesoft__c='';
                        caso.ErrorMulesoft__c += !String.isBlank(error.code) ? 'code: ' + error.code + '\n':'';
                        caso.ErrorMulesoft__c += !String.isBlank(error.reason) ? 'reason: ' + error.reason + '\n':'';
                        caso.ErrorMulesoft__c += !String.isBlank(error.error) ? 'error: ' + error.error + '\n':'';
                        caso.ErrorMulesoft__c += !String.isBlank(error.errorDescription) ? 'errorDescription: ' + error.errorDescription + '\n':'';
                        caso.ErrorMulesoft__c += !String.isBlank(error.errorMessage) ? 'errorMessage: '+ error.errorMessage + '\n':'';
                    } else {
                        caso.Error_Mulesoft__c = respuestaCustomer.Status;
                    }
                }	
           	}
            else if (candidato != null) {
                caso.Lead__c = null;
				List<Lead> listLeadToDelete = [select id from lead where id = :candidato.id];

				if(!listLeadToDelete.isEmpty()){
					delete listLeadToDelete;
				}
            }
        }
        
        // Envío email
        try {
             if (caso.EnvioMulesoft__c.equalsIgnoreCase('Envio email')) {
                Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id, cConcesionario.Id, caso.Id);
            	String[] sendTo = new String[] { emailAsesor };
            	mail.setToAddresses(sendTo);
            	mail.setTargetObjectId(null);
            	mail.setSaveAsActivity(true);
            	Messaging.SendEmailResult[] emailSent = Messaging.sendEmail(new Messaging.Email[] { mail });
            
            	if (emailSent[0].isSuccess()) {
            	   enviado = true;
            	   caso.Status = Label.StatusClosed;
           		   caso.Motivo_de_cierre__c = Label.motivoCierreOportunidad;
            	}
			}
        } catch(EmailException e) {
			enviado = false;
        }
        
        if(!enviado && String.isBlank(caso.Error_Mulesoft__c)){
            caso.Error_Mulesoft__c ='Error envio email';
        }
        
        update caso;
        respuestaMetodo = caso.EnvioMulesoft__c.equalsIgnoreCase('Envio email') ? 'Operación completada con éxito' : 'Ha ocurrido un error. Revise parámetros de envio.';
        }catch(Exception e){
         respuestaMetodo = 'Ha ocurrido un error. Póngase en contacto con el administrador.';
         Exception__c exc = new Exception__c ();
         exc.IdObjetos__c = caso.Id;
         exc.Exception__c = e.getCause() + '// '+ e.getMessage();
         exc.Linea__c = e.getLineNumber();
         exc.Clase_Metodo__c = 'ExternalServiceController.sendExternalLeadOrAccountVOSec';
         if (respuestaCustomer != null) {
             exc.JSON_Entrada__c = 'respuestaCustomer:'+respuestaCustomer;
         }   
         insert exc;
     }   
    
        return respuestaMetodo ;
    }
    
    /*
		el metodo es similar o tiene la misma funcionalidad que createExternalLeadOrAccountMulesoft solo que no envia api 
	*/
    public static String sendExternalLedOrAccountEmailSec(String JSONCases, String JSONgLead) {
      system.debug('empieza: sendExternalLedOrAccountEmailSec');
      String respuestaMetodo='';
      Case caso = (Case) JSON.deserialize(JSONCases, Case.class);
      try{
        caso.Error_Mulesoft__c='';
        caso.EnvioMulesoft__c ='';
        caso.ErrorMulesoft__c ='';
        Gestion_Lead__c gLead = (Gestion_Lead__c) JSON.deserialize(JSONgLead, Gestion_Lead__c.class);
        
        //Sacar datos del caso para buscar cuenta, lead, campania, etc
        Map<String, Pais__c> mapPaisByName = new Map<String, Pais__c>();
        List<Cliente_Concesionario__c> listClienteConcesionario= new List<Cliente_Concesionario__c>();
       	List<Case> casesLead = new List<Case>();
        List<Case> casesToUpdate = new List<Case>();
        
        String concesionarioIdSima = '';
        String emailAsesor = '';
        Centro__c Centro;
        Campaign campaign;
        Account cuenta;
        Lead candidato;
        Map<String,Consentimientos__c> mapConsentimientosValue;
        Map<String,CampaignMember> mapCOrLToCMByCampaignId = new Map<String,CampaignMember>();
        CampaignMember campaignMemberToInsert;
        CampaignMember campaignMemberTODelete;
        ExternalCustomerApiModel.CustomerApi externalCustomerApi = new ExternalCustomerApiModel.CustomerApi();
        ExternalLeadApiModel.LeadApi externalLeadApi = new ExternalLeadApiModel.LeadApi();
        ExternalConsentimientoApiModel.ConsentimientoApi externalConsentimientoApi = new ExternalConsentimientoApiModel.ConsentimientoApi();
        List<Consentimientos__c> listConsentimientoToUpdate = new List<Consentimientos__c>();
        List<String> listConsentimientoIdToDelete = new List<String>();
        List<Consentimientos__c> listConsentimientoToDelete = new List<Consentimientos__c>();
        Cliente_Concesionario__c cConcesionarioToInsert;
        Account cuentaAux;
        Account cuentaToInsert;
        Boolean duplicado = false;

        // Center
        if (gLead.Centro_destino__c != null) {
            centro = CentroGateway.getCenterById(gLead.Centro_destino__c);
            concesionarioIdSima = !String.isBlank(centro.Concesionario__r.Id_Concesionario_Sima__c)? centro.Concesionario__r.Id_Concesionario_Sima__c:'';
        }
          
        //Asesor
        if (gLead.Asesor__c != null) {
            User asesor = UserGateway.getUserById(gLead.Asesor__c);
            emailAsesor = asesor.Email;
        } else if (gLead.EmailAsesor__c != null) {
            emailAsesor = gLead.EmailAsesor__c;
        }
        
        //Armar el mensaje (puede ser construyendo otro metodo de creación del email) (el body sacarlo de la template ,la dirección de envio el del email del asesor )
        EmailTemplate et = [SELECT Id, Subject FROM EmailTemplate WHERE Name = 'newLeadToAsesor'];
        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id,null , caso.Id);
        String[] sendTo = new String[] { emailAsesor };
        mail.setToAddresses(sendTo);
        //mail.setCharset('Domingo Alonso');
        //mail.setSubject('Account or Lead created');
        //mail.setTemplateId(et.Id);
        //mail.setWhatId(caso.Id);
        mail.setSaveAsActivity(true);
        
        //Enviar el email
        Messaging.SendEmailResult[] emailSent = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        // Solo enviamos un email
        if (emailSent[0].isSuccess()) {
            caso.EnvioMulesoft__c='Envio Email';
            caso.Status = Label.StatusClosed;
           	caso.Motivo_de_cierre__c = Label.motivoCierreOportunidad;
			//Mediante cliente 
            if (caso.AccountId != null) {
                cuenta = AccountGateway.getAccountById(caso.AccountId);
                List<String> listaPaises = new List<String>();
                
                if (!String.isBlank(cuenta.ShippingCountry)) {
                    listaPaises.add(DataValidations.capitalizeString(cuenta.ShippingCountry));
                }
                
                if (!String.isBlank(cuenta.BillingCountry)) {
                    listaPaises.add(DataValidations.capitalizeString(cuenta.BillingCountry));
                }
                
                if (!listaPaises.isEmpty()) {
                    mapPaisByName = PaisGateway.getPaisByName(listaPaises);
                }
                
                mapConsentimientosValue = ConsentimientosGateway.getConsentimientosValueByAccountId(cuenta.Id);
                
                Cliente_Concesionario__c cConcesionario;
                listClienteConcesionario = ClienteConcesionarioGateway.searchClienteConcesionariosByAccountIdInt(cuenta.Id);
                
                for (Cliente_Concesionario__c cConcesionarioQ : listClienteConcesionario ) {
                    if (centro.Concesionario__c == cConcesionarioQ.Concesionario__c) {
                        cConcesionario = cConcesionarioQ;
                    }
                }
                
                if (cConcesionario == null) {
                    cConcesionarioToInsert = createCconcesionario(cuenta, '', centro.Concesionario__c, centro.Concesionario__r.Id_Concesionario_Sima__c);
                }   
                if (listClienteConcesionario != null && mapConsentimientosValue != null ){
                       externalConsentimientoApi = createExternalConsentimiento(mapConsentimientosValue.values(), listClienteConcesionario, centro);
                }
            }
            //Mediante lead
            if (caso.Lead__c != null) {
                candidato = LeadGateway.getLeadById(caso.Lead__c);
                mapConsentimientosValue = ConsentimientosGateway.getConsentimientosValueByLeadId(candidato.Id);
                casesLead = CaseGateway.getCaseByLead(caso.Lead__c);
            
                cuentaAux = createAccount(candidato, caso, mapPaisByName);
                if (!String.isBlank(cuentaAux.Id)) {
                	cConcesionarioToInsert = createCconcesionario(cuentaAux, '', centro.Concesionario__c, centro.Concesionario__r.Id_Concesionario_Sima__c);
                	caso.AccountId = cuentaAux.Id;
                	duplicado = true;
                }
                else {
                	cuentaToInsert = cuentaAux;
                	cConcesionarioToInsert = createCconcesionario(null, '', centro.Concesionario__c, centro.Concesionario__r.Id_Concesionario_Sima__c);
                }
            }
            
            Contact contacto;
            
            if (cuentaToInsert != null) {
            system.debug('3 cuentaToInsert:'+cuentaToInsert);           
                upsert cuentaToInsert;
                cConcesionarioToInsert.Cliente__c = cuentaToInsert.Id;
                contacto = ContactGateway.getContactByAccountId(cuentaToInsert.Id);
                caso.AccountId = cuentaToInsert.Id;
                caso.ContactId = contacto.Id;
                system.debug('Inma31 caso.ContactId: '+caso.ContactId);
                system.debug('Inma31 caso.Lead__c: '+caso.Lead__c);
                       
                if (caso.ContactId != null && caso.Lead__c != null) {
                   Registros_Relacionados__c rr = new Registros_Relacionados__c();
                   rr.Registro_Origen__c = caso.Lead__c;
                   rr.Registro_Destino__c = caso.ContactId;
                   insert rr;
                }
            }
            
            if (cConcesionarioToInsert != null) {
                insert cConcesionarioToInsert;
            }
            
            //Para el paso de lead a cuentas
            if (duplicado && candidato != null){
                contacto = ContactGateway.getContactByAccountId(cuentaAux.Id);
                caso.ContactId = contacto.Id;
                Map<String,Consentimientos__c> mapConsentimientosValueAccount = ConsentimientosGateway.getConsentimientosValueByAccountId(cuentaAux.Id);
                
                if (mapConsentimientosvalue != null ) {
                        for(Consentimientos__c consentimientoLead :mapConsentimientosvalue.values()){
                            if(mapConsentimientosValueAccount.containsKey(consentimientoLead.ChannelValue__c)){
                                Consentimientos__c consentimientoToUpdate = mapConsentimientosValueAccount.get(consentimientoLead.ChannelValue__c);
                                consentimientoToUpdate.AfterSales__c= consentimientoLead.AfterSales__c;
                                consentimientoToUpdate.AfterSalesSMS__c = consentimientoLead.AfterSalesSMS__c;
                                consentimientoToUpdate.CustomerSatisfaction__c = consentimientoLead.CustomerSatisfaction__c;
                                consentimientoToUpdate.CustomerSatisfactionSMS__c = consentimientoLead.CustomerSatisfactionSMS__c;
                                consentimientoToUpdate.EventInvitation__c = consentimientoLead.EventInvitation__c;
                                consentimientoToUpdate.EventInvitationSMS__c = consentimientoLead.EventInvitationSMS__c;
                                consentimientoToUpdate.Fecha_de_captura__c = consentimientoLead.Fecha_de_captura__c;
                                consentimientoToUpdate.MarketResearch__c = consentimientoLead.MarketResearch__c;
                                consentimientoToUpdate.MarketResearchSMS__c = consentimientoLead.MarketResearchSMS__c;
                                consentimientoToUpdate.ProductSale__c = consentimientoLead.ProductSale__c;
                                consentimientoToUpdate.ProductSaleSMS__c = consentimientoLead.ProductSaleSMS__c;
                                listConsentimientoToUpdate.add(consentimientoToUpdate);
                                listConsentimientoIdToDelete.add(consentimientoLead.Id);
                            }
                            else{
                                consentimientoLead.Contact__c =contacto != null? contacto.Id:null;
                                consentimientoLead.Lead__c = null;
                                listConsentimientoToUpdate.add(consentimientoLead);
                            }
                        }
                    }  
                // Campaign
        		if (caso.Campana__c != null) {
            		campaign = CampaignGateway.getCampaignById(caso.Campana__c);
            		mapCOrLToCMByCampaignId = CampaignMemberGateway.getMapCOrLToCampaignMemberByCampaignId(campaign.Id,contacto.Id, candidato.Id );
        		}
        
                //Actualizacion campaignMember para clientes duplicados (Lead)
                if (contacto != null && !String.isBlank(caso.Campana__c) && !mapCOrLToCMByCampaignId.isEmpty() && !mapCOrLToCMByCampaignId.containsKey(contacto.Id)) {
                    campaignMemberToInsert = new CampaignMember();
                    campaignMemberToInsert.CampaignId = caso.Campana__c;
                    campaignMemberToInsert.ContactId = contacto.Id;
                	campaignMemberToInsert.Status = Label.StatustResponded;
				}
                
				if (!mapCOrLToCMByCampaignId.isEmpty() && mapCOrLToCMByCampaignId.containsKey(caso.Lead__c)) {
                     campaignMemberToDelete = mapCOrLToCMByCampaignId.get(caso.Lead__c);
                 }
                
                //Para los casos relacionados al lead anteriormente pasarlos a la cuenta duplicada
            	for(Case casoLead :casesLead){
            		if (casoLead.Id != caso.Id) {
                		casoLead.AccountId = caso.AccountId;
                    	casoLead.ContactId = contacto.Id;
                        casoLead.Lead__c = null;
                        if (!casoLead.Owner.IsActive && casoLead.Unidad_de_negocio__c == Label.UnidadNegocioOpportunity){
                            casoLead.OwnerId = Label.UsuarioOpportunity;
                        }
                        if (!casoLead.Owner.IsActive && casoLead.Unidad_de_negocio__c == Label.UnidadNegocioMobility){
                            casoLead.OwnerId = Label.UsuarioMobility;
                        }
                    	casesToUpdate.add(casoLead);
                 	}
             	}
            
            }
            else if (candidato != null) {
                for (Consentimientos__c consentimientoLead : mapConsentimientosvalue.values()) {
                    consentimientoLead.Contact__c = contacto != null ? contacto.Id : null;
                    consentimientoLead.Lead__c = null;
                    String developerNameCon = ConsentimientosGateway.getRecordTypeDeveloperNameById(consentimientoLead.RecordTypeId);
                    if(developerNameCon.equalsIgnoreCase(Label.RtConsentimientoEmail)){
                    	consentimientoLead.Medio_de_contacto__c = Label.channelEmail;
                    }
                    else if(developerNameCon.equalsIgnoreCase(Label.RtConsentimientoMobile)){
                    	consentimientoLead.Medio_de_contacto__c = Label.channelMobile;
                    }
                    else if (developerNameCon.equalsIgnoreCase(Label.RtConsentimientoPhone)){
                    	consentimientoLead.Medio_de_contacto__c = Label.channelPhone;
                    }
                
                    listConsentimientoToUpdate.add(consentimientoLead);
                }
                // Campaign
        		if (caso.Campana__c != null) {
            		campaign = CampaignGateway.getCampaignById(caso.Campana__c);
            		mapCOrLToCMByCampaignId = CampaignMemberGateway.getMapCOrLToCampaignMemberByCampaignId(campaign.Id,contacto.Id, candidato.Id );
        		}
        
                if (contacto != null && !String.isBlank(caso.Campana__c) && !mapCOrLToCMByCampaignId.isEmpty() && !mapCOrLToCMByCampaignId.containsKey(contacto.Id)) {
                    campaignMemberToInsert = new CampaignMember();
                    campaignMemberToInsert.CampaignId = caso.Campana__c;
                    campaignMemberToInsert.ContactId = contacto.Id;
                    campaignMemberToInsert.Status = Label.StatustResponded;
                }
                
                if (mapCOrLToCMByCampaignId.containsKey(caso.Lead__c)) {
                     campaignMemberToDelete = mapCOrLToCMByCampaignId.get(caso.Lead__c);
                 }
                
                //Para los casos relacionados al lead anteriormente pasarlos a la cuenta
            	for(Case casoLead :casesLead){
            		if(casoLead.Id != caso.Id){
                		casoLead.AccountId = caso.AccountId;
                    	casoLead.ContactId = caso.ContactId;
                        casoLead.Lead__c = null;
                        if (!casoLead.Owner.IsActive && casoLead.Unidad_de_negocio__c == Label.UnidadNegocioOpportunity){
                            casoLead.OwnerId = Label.UsuarioOpportunity;
                        }
                        if (!casoLead.Owner.IsActive && casoLead.Unidad_de_negocio__c == Label.UnidadNegocioMobility){
                            casoLead.OwnerId = Label.UsuarioMobility;
                        }
                    	casesToUpdate.add(casoLead);
                 	}
             	}
            }
            
            //actualizamos consentimientos
            if (!listConsentimientoToUpdate.isEmpty()) {
                update listConsentimientoToUpdate;
            }
            
            //insertamos miembro de campaña
            if (campaignMemberToInsert != null) {
                insert campaignMemberToInsert;
            }
            
            //eliminamos miembro de campaña
            if (campaignMemberToDelete != null) {
                delete campaignMemberToDelete;
            }
            
            if (candidato != null) {
                caso.Lead__c = null;
				List<Lead> listLeadToDelete = [select id from lead where id = :candidato.id];

				if(!listLeadToDelete.isEmpty()){
					delete listLeadToDelete;
				}
            }
            casesToUpdate.add(caso);
            update casesToUpdate;
            respuestaMetodo = 'Operación completada con éxito';
        }
        else {
            respuestaMetodo = 'Ha ocurrido un error. Revise parámetros de envio.';
        }
        }catch(Exception e){
         respuestaMetodo = 'Ha ocurrido un error. Póngase en contacto con el administrador.';
         Exception__c exc = new Exception__c ();
         exc.IdObjetos__c = caso.Id;
         exc.Exception__c = e.getCause() + '// '+ e.getMessage();
         exc.Linea__c = e.getLineNumber();
         exc.Clase_Metodo__c = 'ExternalServiceController.sendExternalLeadOrAccountEmailSec';
         insert exc;
     }   
        return respuestaMetodo;
    }
    
    @future(callout = true)
    public static void sendExternalLeadOrAccountEmail(String JSONCases, String JSONgLead) {
      List<Case> listaCasos = (List<Case>) JSON.deserialize(JSONCases, List<Case>.class);
      String idsCasos = '';
      for(Case caso :listaCasos){
            idsCasos+=caso.Id+',';
        }
      try{
        Gestion_Lead__c gLead = (Gestion_Lead__c) JSON.deserialize(JSONgLead, Gestion_Lead__c.class);
        String emailAsesor = '';
        Boolean enviado = false;
        Map<String, Case> mapCaseById = new Map<String, Case>();
        Map<String, Centro__c> mapCentroById = new Map<String, Centro__c>();
        Map<String, Campaign> mapCampaignById = new Map<String, Campaign>();
        Map<String, Account> mapAccountById = new Map<String, Account>();
        Map<String, Lead> mapLeadById = new Map<String, Lead>();
        Map<String, Pais__c> mapPaisByName = new Map<String, Pais__c>();
        Map<String, Map<String, CampaignMember>> mapCOrLToCMByCampaignId = new Map<String,Map<String, CampaignMember>>();
        Map<String, Map<String, Cliente_Concesionario__c>> mapClienteConcesionarioByAccountId = new Map<String, Map<String, Cliente_Concesionario__c>>();
       	Map<String, Map<String, Consentimientos__c>> mapConsentimientovalueByLeadId = new Map<String, Map<String, Consentimientos__c>>();
        Map<String, Map<String, Consentimientos__c>> mapConsentimientovalueByAccountDuplicado = new Map<String, Map<String,Consentimientos__c>>();
        Map<String, List<Case>> mapLeadToCases = new Map<String,List<Case>>();
        
        List<String> listConcesionarioId = new List<String>();
        List<String> listCaseSendWithAccount = new List<String>();
        List<String> listCaseSendWithLead = new List<String>();
        List<String> listAccountId = new List<String>();
        List<String> listLeadId = new List<String>();
        List<String> listCentroId = new List<String>();
        List<String> listCampaignId = new List<String>();
        Map<String,String> mapAccountIdDuplicadobyCaseId = new Map<String,String>();
        
        Map<String, Cliente_Concesionario__c> mapCConcesionarioToInsertByCaseId = new Map<String, Cliente_Concesionario__c>();
        Map<String, Account> mapAccountToInsertByCaseId = new Map<String, Account>();
        Map<String, Map<String, CampaignMember>> mapCampaignMemberByCOrLByCampaigIdToInsert = new Map<String, Map<String,CampaignMember>>();
        List<Consentimientos__c> listConsentimientoToUpdate = new List<Consentimientos__c>();
        List<String> listConsentimientoIdToDelete = new List<String>();
        List<Consentimientos__c> listConsentimientoToDelete = new List<Consentimientos__c>();
        List<Case> listCaseToUpdate = new List<Case>();
        List<Lead> listLeadToDelete = new List<Lead>();
        List<String> listLeadIdToDelete = new List<String>();
        List<CampaignMember> listCampaignMemberToDelete = new List<CampaignMember>();
        Map<String, Messaging.SingleEmailMessage> mapCasoMessaging = new Map<String, Messaging.SingleEmailMessage>();
        Map<String, Case> mapCaaseToUpdateEmail = new Map<String, Case>();
        EmailTemplate et = [SELECT Id, Subject FROM EmailTemplate WHERE Name = 'newLeadToAsesor'];
        
        for (Case caso : listaCasos) {
            mapCaseById.put(caso.Id, caso);
/*           
            if (caso.Centro__c != null) {
                listCentroId.add(caso.Centro__c);
            }
*/            
            if (caso.Campana__c != null) {
                listCampaignId.add(caso.Campana__c);
            }
            
            if (caso.AccountId != null) {
                listCaseSendWithAccount.add(caso.id);
                listAccountId.add(caso.AccountId);
            }
            else if (caso.Lead__c != null) {
                listCaseSendWithLead.add(caso.Id);
                listLeadId.add(caso.Lead__c);
            }
        }
          
        if (gLead.Centro_destino__c != null) {
            listCentroId.add(gLead.Centro_destino__c);
        }
          
        //Centro 
        if (!listCentroId.isEmpty()) {
			system.debug('centro:'+ listCentroId);            
        	mapCentroById =  CentroGateway.getCenterById(listCentroId);
           
            for(Centro__c centro : mapCentroById.values()){
                if(centro.Concesionario__c != null && !listConcesionarioId.contains(centro.Concesionario__c)){
                    listConcesionarioId.add(centro.Concesionario__c);
                    system.debug('listaConcesionario:'+ listConcesionarioId);
                }
            }
        }
            
        //Asesor
        if (gLead.Asesor__c != null) {
            User asesor = UserGateway.getUserById(gLead.Asesor__c);
            emailAsesor = asesor.Email;
        } else if (gLead.EmailAsesor__c != null) {
            emailAsesor = gLead.EmailAsesor__c;
        }
        
        //Asociado con cliente
        if (!listAccountId.isEmpty()) {
            mapAccountById = AccountGateway.getAccountById(listAccountId);
            
            Map<String, Map<String, Consentimientos__c>> mapConsentimientosValueByAccountId = ConsentimientosGateway.getConsentimientosByAccountId(listAccountId);
            Map<String, List<Cliente_Concesionario__c>> mapAllClienteConcesionarioByAccountId =ClienteConcesionarioGateway.getclienteConcesionarioByAccountId(listAccountId);
            
            for (Cliente_Concesionario__c cConcesionario : [SELECT Id, Id_Cliente_DMS__c, Cliente__c, Concesionario__c, Concesionario__r.Id_Concesionario_Sima__c
                                                             FROM Cliente_Concesionario__c
                                                            WHERE Cliente__c in :listAccountId
                                                              AND concesionario__c in :listConcesionarioId
                                                              AND Es_Seccion__c = false]) {
                Map<String,Cliente_Concesionario__c> mapClienteCByConcesionario =mapClienteConcesionarioByAccountId.containsKey(cConcesionario.Cliente__c)?mapClienteConcesionarioByAccountId.get(cConcesionario.Cliente__c): new Map<String,Cliente_Concesionario__c>();
                mapClienteCByConcesionario.put(cConcesionario.Concesionario__c, cConcesionario);
                mapClienteConcesionarioByAccountId.put(cConcesionario.Cliente__c,mapClienteCByConcesionario);
            }
            
            for (String idCaso : listCaseSendWithAccount) {
                ExternalConsentimientoApiModel.ConsentimientoApi externalConsentimientoApi = new ExternalConsentimientoApiModel.ConsentimientoApi();
                Case caso = mapCaseById.get(idCaso);
                Centro__c centro = gLead.Centro_destino__c != null && mapCentroById.containsKey(gLead.Centro_destino__c) ? mapCentroById.get(gLead.Centro_destino__c) : null;
                Campaign campania = caso.Campana__c != null && mapCampaignById.containsKey(caso.Campana__c) ? mapCampaignById.get(caso.Campana__c) : null;
                Account cuenta = caso.AccountId != null && mapAccountById.containsKey(caso.AccountId) ? mapAccountById.get(caso.AccountId) : null;
                
                Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id,null , caso.Id);
        		String[] sendTo = new String[] { emailAsesor };
        		mail.setToAddresses(sendTo);
                //mail.setSubject('Account or Lead created');
        		//mail.setTemplateId(et.Id);
        		//mail.setWhatId(caso.Id);
        		mail.setSaveAsActivity(true);
                mapCasoMessaging.put(caso.Id, mail);
                caso.EnvioMulesoft__c = 'Envio email';
                mapCaseById.put(caso.Id, caso);
        		    
                Map<String,Consentimientos__c> mapConsentimientoValue = mapConsentimientosValueByAccountId.containsKey(caso.AccountId) ? mapConsentimientosValueByAccountId.get(caso.AccountId): null;
            	List<Cliente_Concesionario__c> listAllClienteConcesionario = mapAllClienteConcesionarioByAccountId.containsKey(caso.AccountId) ? mapAllClienteConcesionarioByAccountId.get(caso.AccountId): null;
                if(listAllClienteConcesionario != null && mapConsentimientoValue != null ){
                    	externalConsentimientoApi = createExternalConsentimiento(mapConsentimientoValue.values(), listAllClienteConcesionario);
                    	ResponseApi respuestaConse = ExternalServiceCallout.sendConsentimientoApiCallout(externalConsentimientoApi);
						system.debug('respuestaConse:'+ respuestaConse);                 
                    }
                  
                //Mirar si existe clienteConcesionario
                if (mapClienteConcesionarioByAccountId.containsKey(caso.AccountId)) {
                    //Existe cliente Concesionario con ese concesionario
                    Map<String,Cliente_Concesionario__c> mapClienteCByConcesionario = mapClienteConcesionarioByAccountId.get(caso.AccountId);
                    if(mapClienteCByConcesionario.containsKey(centro.Concesionario__c)){
                        //existe cConcesionario
                        Cliente_Concesionario__c cConcesionario = mapClienteCByConcesionario.get(centro.Concesionario__c);
                    }
                    else {
                         Cliente_Concesionario__c cConcesionario = createCconcesionario(cuenta, null, centro.Concesionario__c, centro.Concesionario__r.Id_Concesionario_Sima__c);
                         mapCConcesionarioToInsertByCaseId.put(caso.Id,cConcesionario);
                    }
                }
                else {
                     Cliente_Concesionario__c cConcesionario = createCconcesionario(cuenta, null, centro.Concesionario__c, centro.Concesionario__r.Id_Concesionario_Sima__c);
                     mapCConcesionarioToInsertByCaseId.put(caso.Id,cConcesionario);
                }
            }
        }
        
        //Asociado con lead
        if (!listLeadId.isEmpty()) {
            mapConsentimientovalueByLeadId = ConsentimientosGateway.getConsentimientosByLeadId(listLeadId);
            mapLeadById = LeadGateway.getLeadIdByIds(listLeadId);
            mapLeadToCases = CaseGateway.getCaseByLead(listLeadId);
        
            for (String idCaso : listCaseSendWithLead) {
                ExternalConsentimientoApiModel.ConsentimientoApi externalConsentimientoApi = new ExternalConsentimientoApiModel.ConsentimientoApi();
                Case caso = mapCaseById.get(idCaso);
                Centro__c centro = gLead.Centro_destino__c != null && mapCentroById.containsKey(gLead.Centro_destino__c) ? mapCentroById.get(gLead.Centro_destino__c) : null;
                Campaign campania = caso.Campana__c != null && mapCampaignById.containsKey(caso.Campana__c) ? mapCampaignById.get(caso.Campana__c) : null;
                Lead candidato = caso.Lead__c != null && mapLeadById.containsKey(caso.Lead__c) ? mapLeadById.get(caso.Lead__c) : null;
            	
                Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id,null , caso.Id);
        		String[] sendTo = new String[] { emailAsesor };
        		mail.setToAddresses(sendTo);
                //mail.setCharset('Domingo Alonso');
        		//mail.setSubject('Account or Lead created');
        		//mail.setTemplateId(et.Id);
        		//mail.setWhatId(caso.Id);
        		mail.setSaveAsActivity(true);
                mapCasoMessaging.put(caso.Id, mail);
                caso.EnvioMulesoft__c = 'Envio email';
                
                listLeadIdToDelete.add(candidato.id);
                Account cuenta = createAccount(candidato, caso, mapPaisByName);
                if (!String.isBlank(cuenta.Id)) {
					Cliente_Concesionario__c cConcesionarioToInsert = createCconcesionario(cuenta, null, centro.Concesionario__c, centro.Concesionario__r.Id_Concesionario_Sima__c);
					mapCConcesionarioToInsertByCaseId.put(caso.Id, cConcesionarioToInsert); 
					caso.AccountId = cuenta.Id;
					mapCaseById.put(caso.Id, caso);
					mapAccountIdDuplicadobyCaseId.put(caso.Id, cuenta.Id);
				}
                else {
                    mapAccountToInsertByCaseId.put(caso.Id,cuenta);
                    Cliente_Concesionario__c cConcesionarioToInsert = createCconcesionario(null, null, centro.Concesionario__c, centro.Concesionario__r.Id_Concesionario_Sima__c);
                    mapCConcesionarioToInsertByCaseId.put(caso.Id,cConcesionarioToInsert);
                }
                mapCaseById.put(caso.Id, caso);
        	}
        }

        //Envio de emails 
        if (!mapCasoMessaging.isEmpty()) {
            system.debug('envio de emails:'+ mapCasoMessaging );
            Messaging.SendEmailResult[] emailSent = Messaging.sendEmail(mapCasoMessaging.values());
            
            if (emailSent[0].isSuccess()) {
               enviado = true;
            }
        }
        
        //Si se ha enviado 
        if (enviado) {
            //Creamos Cuenta
        	Map<String, Contact> mapContactByAccountId = new Map<String, Contact>();
        	List<String> listContactId = new List<String>();
			if (!mapAccountToInsertByCaseId.isEmpty()) {
            	Insert mapAccountToInsertByCaseId.values();
            	system.debug('insertar: mapAccountToInsertByCaseId'+ mapAccountToInsertByCaseId);
			}
        	
            List<String> listCuentaId = new List<String>();
       		for (Account cuenta : mapAccountToInsertByCaseId.values()) {
         		listCuentaId.add(cuenta.Id);
			}
        
        	//cuenta duplicado en caso de lead a la hora de intentar crear cuenta
        	if (!mapAccountIdDuplicadoByCaseId.isEmpty()) {
            	listCuentaId.addAll(mapAccountIdDuplicadobyCaseId.values());
            	mapConsentimientovalueByAccountDuplicado = ConsentimientosGateway.getConsentimientosByAccountId(mapAccountIdDuplicadobyCaseId.values());
        	}
        
        	//Sacamos todos los contactos de las cuentas
        	if (!listCuentaId.isEmpty()) {
        		mapContactByAccountId = ContactGateway.getContactByAccountId(listCuentaId);
                for(Contact contacto : mapContactByAccountId.values()){
                    listContactId.add(contacto.id);
                }
        	}
        
             //Campaign
        	if (!listCampaignId.isEmpty()) {
            	mapCampaignById = CampaignGateway.getCampaignById(listCampaignId);
            	mapCOrLToCMByCampaignId = CampaignMemberGateway.getMapCOrLToCampaignMemberByCampaignId(listCampaignId,listContactId,listLeadId );
        	}
       
        	//Actualizacion de consentimientos y campaignMember de cliente duplicados
        	if (!mapAccountIdDuplicadoByCaseId.isEmpty()) {
            	for (String caseId : mapAccountIdDuplicadoByCaseId.keySet()) {
                	String accountId = mapAccountIdDuplicadoByCaseId.get(caseId);
                	Contact contacto = mapContactByAccountId.containsKey(accountId)?mapContactByAccountId.get(accountId):null;
                	Case caso = mapCaseById.get(caseId);
                	
                	//Actualizacion consentimientos para cuentas duplicadas
                	Map<String, Consentimientos__c> mapConsentimientoByValueLead = mapConsentimientovalueByLeadId.containsKey(caso.Lead__c)
                	    ? mapConsentimientovalueByLeadId.get(caso.Lead__c) : null;
                	Map<String, Consentimientos__c> mapConsentimientoByValue = mapConsentimientovalueByAccountDuplicado.containsKey(accountId)
                    	? mapConsentimientovalueByAccountDuplicado.get(accountId) : new Map<String,Consentimientos__c>();
                
                	if (mapConsentimientoByValueLead != null ) {
                    	for (Consentimientos__c consentimientoLead :mapConsentimientoByValueLead.values()){
                        	if (mapConsentimientoByValue.containsKey(consentimientoLead.ChannelValue__c)) {
                            	Consentimientos__c consentimientoToUpdate = mapConsentimientoByValue.get(consentimientoLead.ChannelValue__c);
                            	consentimientoToUpdate.AfterSales__c= consentimientoLead.AfterSales__c;
                            	consentimientoToUpdate.AfterSalesSMS__c = consentimientoLead.AfterSalesSMS__c;
                                consentimientoToUpdate.CustomerSatisfaction__c = consentimientoLead.CustomerSatisfaction__c;
                                consentimientoToUpdate.CustomerSatisfactionSMS__c = consentimientoLead.CustomerSatisfactionSMS__c;
                            	consentimientoToUpdate.EventInvitation__c = consentimientoLead.EventInvitation__c;
                            	consentimientoToUpdate.EventInvitationSMS__c = consentimientoLead.EventInvitationSMS__c;
                            	consentimientoToUpdate.Fecha_de_captura__c = consentimientoLead.Fecha_de_captura__c;
                            	consentimientoToUpdate.MarketResearch__c = consentimientoLead.MarketResearch__c;
                            	consentimientoToUpdate.MarketResearchSMS__c = consentimientoLead.MarketResearchSMS__c;
                            	consentimientoToUpdate.ProductSale__c = consentimientoLead.ProductSale__c;
                            	consentimientoToUpdate.ProductSaleSMS__c = consentimientoLead.ProductSaleSMS__c;
                            	consentimientoToUpdate.EnviarAmulesoft__c = false;
                            	listConsentimientoToUpdate.add(consentimientoToUpdate);
                            	listConsentimientoIdToDelete.add(consentimientoLead.Id);
                        	}
                        	else {
                            	consentimientoLead.Contact__c =contacto != null ? contacto.Id : null;
                    			consentimientoLead.Lead__c = null;
                            	consentimientoLead.EnviarAmulesoft__c = false;
                    			listConsentimientoToUpdate.add(consentimientoLead);
                        	}	
                    	}
                	}  
               
	                //Actualizacion campaignMember para clientes duplicados (Lead)
    	            if (!String.isBlank(caso.Campana__c)) {
    	                Map<String,CampaignMember> mapCOrLToCM =  mapCOrLToCMByCampaignId.containsKey(caso.Campana__c) ?mapCOrLToCMByCampaignId.get(caso.Campana__c): new Map<String,CampaignMember>();
    	                if(!mapCOrLToCM.containsKey(contacto.Id)){
    	                    Map<String,CampaignMember> mapCampaignMemberToInsert = mapCampaignMemberByCOrLByCampaigIdToInsert.containsKey(caso.Campana__c)?mapCampaignMemberByCOrLByCampaigIdToInsert.get(caso.Campana__c): new Map<String,CampaignMember>();
    	                    if(!mapCampaignMemberToInsert.containsKey(contacto.Id)){
    	                    	CampaignMember cMember = new CampaignMember();
    	                		cMember.CampaignId = caso.Campana__c;
    	                		cMember.ContactId = contacto.Id;
    	                		cMember.Status = Label.StatustResponded;
    	                    	mapCampaignMemberToInsert.put(cMember.ContactId, cMember);
    	                    	mapCampaignMemberByCOrLByCampaigIdToInsert.put(caso.Campana__c, mapCampaignMemberToInsert);
    	                    }
    	                }
    	                if(!String.isBlank(caso.Lead__c) && mapCOrLToCM.containsKey(caso.Lead__c)){
        	                    listCampaignMemberToDelete.add( mapCOrLToCM.get(caso.Lead__c));
        	                }
        	        }
                    
                    //Para los casos relacionados al lead anteriormente pasarlos a la cuenta duplicada
                	List<Case> listCases = mapLeadToCases.containsKey(caso.Lead__c)?mapLeadToCases.get(caso.Lead__c): null;
                	
                    if (listCases != null) {
                    	for (Case casoLead :listCases) {
                        	if (casoLead.Id != caso.Id && !mapCaseById.containsKey(casoLead.Id)) {
                            	casoLead.AccountId = accountId;
                            	casoLead.ContactId = contacto.Id;
                                casoLead.Lead__c = null;
                                if (!casoLead.Owner.IsActive && casoLead.Unidad_de_negocio__c == Label.UnidadNegocioOpportunity){
                                    casoLead.OwnerId = Label.UsuarioOpportunity;
                                }
                                if (!casoLead.Owner.IsActive && casoLead.Unidad_de_negocio__c == Label.UnidadNegocioMobility){
                                    casoLead.OwnerId = Label.UsuarioMobility;
                                }
                            	listCaseToUpdate.add(casoLead);
                        	}
                    	}
                	}
            	}
         	}
        
        	//Actualizacion de cliente concesionario y consentimientos a clientes nuevos insertados
        	for(String caseId :mapAccountToInsertByCaseId.keySet()){
        		Account cuenta = mapAccountToInsertByCaseId.get(caseId);
            	Contact contacto =  mapContactByAccountId.containsKey(cuenta.Id)?mapContactByAccountId.get(cuenta.Id):null;
            
            	//Cliente concesionario
            	Cliente_Concesionario__c cConcesionario = mapCConcesionarioToInsertByCaseId.get(caseId);
            	cConcesionario.Cliente__c = cuenta.Id;
            	mapCConcesionarioToInsertByCaseId.put(caseId, cConcesionario);
            
            	//Para el consentimiento en caso de cuentas nuevos
            	 Case caso = mapCaseById.get(caseId);
                
            	 if (!String.isBlank(caso.Lead__c) && mapConsentimientovalueByLeadId.containsKey(caso.Lead__c)) {
            	 	Map<String, Consentimientos__c> mapConsentimientoByValue = mapConsentimientovalueByLeadId.get(caso.Lead__c);
            	    
                     for (Consentimientos__c consentimiento : mapConsentimientoByValue.values()) {
            	    	consentimiento.Contact__c = contacto != null?contacto.Id: null;
            	        consentimiento.Lead__c = null;
                        String developerNameCon = ConsentimientosGateway.getRecordTypeDeveloperNameById(consentimiento.RecordTypeId);
                    	if(developerNameCon.equalsIgnoreCase(Label.RtConsentimientoEmail)){
                    		consentimiento.Medio_de_contacto__c = Label.channelEmail;
                    	}
                    	else if(developerNameCon.equalsIgnoreCase(Label.RtConsentimientoMobile)){
                    		consentimiento.Medio_de_contacto__c = Label.channelMobile;
                    	}
                    	else if (developerNameCon.equalsIgnoreCase(Label.RtConsentimientoPhone)){
                    		consentimiento.Medio_de_contacto__c = Label.channelPhone;
                    	}
                
            	        listConsentimientoToUpdate.add(consentimiento);
            	     }
            	 }
            
            	//Para CampaigMember en caso de cuentas nuevas
            	if (!String.isBlank(caso.Campana__c)) {
					Map<String,CampaignMember> mapCOrLToCM =  mapCOrLToCMByCampaignId.containsKey(caso.Campana__c) ?mapCOrLToCMByCampaignId.get(caso.Campana__c): new Map<String,CampaignMember>();
					if (!mapCOrLToCM.containsKey(contacto.Id)){
						Map<String,CampaignMember> mapCampaignMemberToInsert = mapCampaignMemberByCOrLByCampaigIdToInsert.containsKey(caso.Campana__c)
							? mapCampaignMemberByCOrLByCampaigIdToInsert.get(caso.Campana__c) : new Map<String,CampaignMember>();
                	        
						if (!mapCampaignMemberToInsert.containsKey(contacto.Id)) {
							CampaignMember cMember = new CampaignMember();
							cMember.CampaignId = caso.Campana__c;
							cMember.ContactId = contacto.Id;
							cMember.Status = Label.StatustResponded;
							mapCampaignMemberToInsert.put(cMember.ContactId, cMember);
							mapCampaignMemberByCOrLByCampaigIdToInsert.put(caso.Campana__c, mapCampaignMemberToInsert);
						}
					}
                    
					if (!String.isBlank(caso.Lead__c) && mapCOrLToCM.containsKey(caso.Lead__c)) {
						listCampaignMemberToDelete.add( mapCOrLToCM.get(caso.Lead__c));
					}
				}
                
                //Para los casos relacionados al lead anteriormente pasarlos a la nueva cuenta
            	List<Case> listCases = mapLeadToCases.containsKey(caso.Lead__c)?mapLeadToCases.get(caso.Lead__c): null;
            	
                if (listCases != null) {
                    for (Case casoLead : listCases) {
                        if (casoLead.Id != caso.Id && !mapCaseById.containsKey(casoLead.Id)) {
                            casoLead.AccountId = cuenta.Id;
                            casoLead.ContactId = contacto.Id;
                            casoLead.Lead__c = null;
                            if (!casoLead.Owner.IsActive && casoLead.Unidad_de_negocio__c == Label.UnidadNegocioOpportunity){
                                casoLead.OwnerId = Label.UsuarioOpportunity;
                            }
                            if (!casoLead.Owner.IsActive && casoLead.Unidad_de_negocio__c == Label.UnidadNegocioMobility){
                                casoLead.OwnerId = Label.UsuarioMobility;
                            }
                            listCaseToUpdate.add(casoLead);
                        }
                    }
                }
        	}
			
            //Creamos cliente Concesionario
            system.debug('mapCConcesionarioToInsertByCaseId:'+ mapCConcesionarioToInsertByCaseId);
        	if(!mapCConcesionarioToInsertByCaseId.isEmpty()){
        	    Insert mapCConcesionarioToInsertByCaseId.values();
        	}
        	//Actualizamos consentimientos a los clientes nuevos insertados
        	if(!listConsentimientoToUpdate.isEmpty()){
            	UPDATE listConsentimientoToUpdate;
        	}
        	//Eliminamos consentimientos de los lead
            if (!listConsentimientoIdToDelete.isEmpty()){
                listConsentimientoToDelete = [select id from Consentimientos__c where id IN :listConsentimientoIdToDelete];
                if(!listConsentimientoToDelete.isEmpty()){
                    delete listConsentimientoToDelete;
                }
            }
            
        	//Insercion de campaingMember
        	if (!mapCampaignMemberByCOrLByCampaigIdToInsert.isEmpty()) {
            	List<CampaignMember> listCampaignMemberToInsert = new List<CampaignMember>();
            	
                for (String campaignId : mapCampaignMemberByCOrLByCampaigIdToInsert.keySet()) {
                	Map<String,CampaignMember> mapCampaignMemberToInsert = mapCampaignMemberByCOrLByCampaigIdToInsert.get(campaignId);
            		listCampaignMemberToInsert.addAll(mapCampaignMemberToInsert.values());
            	}
                
                insert listCampaignMemberToInsert;
       		}
            
        	//Eliminacion de CampaignMember
        	if (!listCampaignMemberToDelete.isEmpty()) {
            	Delete listCampaignMemberToDelete;
        	}

        	//Actualización del caso y asociamos el caso a la cuenta cuando es lead
        	system.debug('Antes de la modificacion del caso');
        	
            for (String idCaso : mapCaseById.keySet()) {
            	Case caso = mapCaseById.get(idCaso);
            	system.debug('case:'+ caso);
            	system.debug('mapAccountToInsertByCaseId:'+ mapAccountToInsertByCaseId);
            	caso.Status = Label.StatusClosed;
            	caso.Motivo_de_cierre__c = Label.motivoCierreAutomatico;
            	
                if (!String.isBlank(caso.Lead__c) ) {
                    if (mapAccountToInsertByCaseId.containsKey(idCaso) ) {
                        caso.AccountId = mapAccountToInsertByCaseId.get(idCaso).Id;
                    }
                    
                    //caso.AccountId = mapAccountToInsertByCaseId.get(idCaso).id;
                    caso.ContactId = caso.AccountId != null && mapContactByAccountId.containsKey(caso.AccountId)?mapContactByAccountId.get(caso.AccountId).Id:null;

                    system.debug('Inma3 caso.ContactId: '+caso.ContactId);
                    system.debug('Inma3 caso.Lead__c: '+caso.Lead__c);
                       
                    if (caso.ContactId != null && caso.Lead__c != null) {
                        Registros_Relacionados__c rr = new Registros_Relacionados__c();
                        rr.Registro_Origen__c = caso.Lead__c;
                        rr.Registro_Destino__c = caso.ContactId;
                        insert rr;
                    }
                    
                    caso.Lead__c = caso.AccountId!=null?null:caso.Lead__c;
                }
                
            	listCaseToUpdate.add(caso);
        	}
            
        	system.debug('listCaseToUpdate:'+ listCaseToUpdate);
            
        	if (!listCaseToUpdate.isEmpty()) {
            	Update listCaseToUpdate;
        	}
            
        	//Eliminamos Lead
        	if (!listLeadIdToDelete.isEmpty()) {
                listLeadToDelete = [select id from lead where id IN :listLeadIdToDelete];
                if (!listLeadToDelete.isEmpty()) {
                    delete listLeadToDelete;
                }
        	}
		}
        }catch(Exception e){
         Exception__c exc = new Exception__c ();
         exc.idObjetos__c = idsCasos.length()>254?idsCasos.substring(0, 254):idsCasos;
         exc.Exception__c = e.getCause() + '// '+ e.getMessage();
         exc.Linea__c = e.getLineNumber();
         exc.Clase_Metodo__c = 'ExternalServiceController.sendExternalLeadOrAccountEmail';
         insert exc;
     }   
    }
    
    public static ExternalLeadApiModel.leadApi createExternalLead(Case infoCase, Centro__c centro, Campaign campania, String idClienteExterno, String emailAsesor, Boolean automatico) {
        ExternalLeadApiModel.LeadApi extLead = new ExternalLeadApiModel.LeadApi();
        extLead.companyId = centro.Concesionario__r.Id_Concesionario_Sima__c;
        extLead.caseId = infoCase.Id;
        extLead.salesCenterCode = centro.CentroCdg__c;
        extLead.brandCode =  infoCase.Marca__c;
        extLead.salesmanEmail = emailAsesor;
        extLead.customerId = idClienteExterno;
        //extLead.agendaTask = new List<ExternalLeadApiModel.AgendaTask>();
        ExternalLeadApiModel.AgendaTask agendaTask = new ExternalLeadApiModel.AgendaTask();
        agendaTask.scheduledDate = String.valueOf(Datetime.now().addHours(2).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
        List<String> intenciones = !String.isBlank(infoCase.Intencion_de_compra__c)?infoCase.Intencion_de_compra__c.split(';') : new List<String>();
        String intencionCompra = '';
        
        for (Integer i = 0; i < intenciones.size(); i++) {
            if (i == intenciones.size() - 1) {
                intencionCompra += CaseGateway.getIntencionCompraLabel(intenciones[i]);
            }
            else {
                intencionCompra += CaseGateway.getIntencionCompraLabel(intenciones[i]) + ';';
            }
        }
        
        List<String> modelos = !String.isBlank(infoCase.Modelo__c) ? infoCase.Modelo__c.split(';') : new List<String>();
        String modelo = '';
        
        for (Integer i = 0; i < modelos.size(); i++) {
            if (i == modelos.size() - 1) {
                modelo += CaseGateway.getModeloLabel(modelos[i]);
            }
            else{
                modelo += CaseGateway.getModeloLabel(modelos[i]) + ';';
            }
        }
        
        String campaignName = campania != null ?' Campaña: ' +campania.Name:'';
        String linea0 = automatico?'Automático ':'';
        String linea1 = 'Caso SF: '+ infoCase.CaseNumber + ' Intención de compra: ' + intencionCompra
            + ' Modelo: ' + modelo + campaignName+'\r\n';
        String linea2 = 'Teléfono: '+ infoCase.SuppliedPhone + ' Email: ' + infoCase.SuppliedEmail
            + ' Preferencia de contacto: ' + CaseGateway.getPreferenciaContactoLabel(infoCase.Preferencia_de_contacto__c);
            //+ ' Horario de contacto: ' + CaseGateway.getHorarioContactoLabel(infoCase.Horario_de_contacto__c) + '\r\n';
        
        if (!String.isBlank(infoCase.Horario_de_contacto__c)) {
            linea2 += ' Horario de contacto: ' + CaseGateway.getHorarioContactoLabel(infoCase.Horario_de_contacto__c) + '\r\n';
        }
        else {
            linea2 += '\r\n';
        }
        
        String linea3 = infoCase.Fecha_Hora_de_cita__c != null ? 'Fecha hora cita con cliente: '+String.valueOf(infoCase.Fecha_Hora_de_cita__c)+'\r\n':'';
        String linea4 = !String.isBlank(infoCase.Description)?'Descripción: '+infoCase.Description+'\r\n':'';
        String linea5 = !String.isBlank(infoCase.Comments)?'Comentario: '+infoCase.Comments+'\r\n':'';
        String linea6 = !String.isBlank(infoCase.VIN__c)?'VIN: '+ infoCase.VIN__c+'\r\n':'';
        String linea7 = !String.isBlank(infoCase.descmodel__c)?'Descripción del modelo: '+ infoCase.descmodel__c+ '\r\n':'';
        String linea8 = !String.isBlank(infoCase.colorCar__c)?'Color del vehículo: '+ infoCase.colorCar__c + '\r\n':'';
        String linea9 = !String.isBlank(infoCase.insideCar__c)?'Interior: '+ infoCase.insideCar__c+'\r\n':'';
        String linea10 = !String.isBlank(infoCase.equipaments__c)?'Equipamientos: '+ infoCase.equipaments__c+'\r\n':'';
        String linea11 = !String.isBlank(infoCase.packages__c)?'Paquetes: '+ infoCase.packages__c+'\r\n':'';
        String linea12 = !String.isBlank(infoCase.MarketingCode__c)?'Código de marketing: '+ infoCase.MarketingCode__c+'\r\n':'';
        String linea13 = !String.isBlank(infoCase.urlConfiguration__c)?'URL configuración: '+ infoCase.urlConfiguration__c+'\r\n':'';
		String linea14 = !String.isBlank(infoCase.Cuota_Financiacion__c)?'Financiación - Cuota: '+ infoCase.Cuota_Financiacion__c+ ' Aplazamiento: '+ infoCase.Aplazamiento_Financiacion__c + ' Entrada: '+ infoCase.Entrada_Financiacion__c +'\r\n':'';
        
        system.debug('linea0: '+linea0);
        system.debug('linea1: '+linea1);
        system.debug('linea2: '+linea2);
        system.debug('linea3: '+linea3);
        system.debug('linea4: '+linea4);
        system.debug('linea6: '+linea6);
        system.debug('linea7: '+linea7);
        system.debug('linea8: '+linea8);
        system.debug('linea9: '+linea9);
        system.debug('linea10: '+linea10);
        system.debug('linea11: '+linea11);
        system.debug('linea12: '+linea12);
        system.debug('linea13: '+linea13);
        system.debug('linea14: '+linea14);
        
        /*
        String linea12;
            
        if (String.isBlank(infoCase.urlConfiguration__c)) {
            linea12 = '';
        }
        else if (infoCase.urlConfiguration__c.substringBetween('configurationId=','&') != null) {
            linea12 = 'ID configuración: '+ infoCase.urlConfiguration__c.substringBetween('configurationId=','&')+'\r\n';
        }
        else if (!String.isBlank(infoCase.urlConfiguration__c.substringAfter('configurationId='))) {
            linea12 = 'ID configuración: '+ infoCase.urlConfiguration__c.substringAfter('configurationId=')+'\r\n';
        }
        else {
            linea12 = '';
        }
        */
        
        agendaTask.remarks =linea0 + linea1 + linea2 +linea3 + linea6 + linea7 + linea8 + linea9 + linea10 + linea11 + linea12 + linea13 + linea14 + linea4 + linea5;		
        System.debug('agendaTask.remarks:'+agendaTask.remarks);
        extLead.agendaTask=agendaTask;

        return extLead;
    }

    public static ExternalLeadApiNewModel.leadApi createExternalLeadNew(Case infoCase, Centro__c centro, Campaign campania, String idClienteExterno, String emailAsesor, Boolean automatico) {
        ExternalLeadApiNewModel.LeadApi extLead = new ExternalLeadApiNewModel.LeadApi();
        
        system.debug('InfoCase:'+infoCase);
        extLead.salesCenterCode = centro.CentroCdg__c;
        extLead.salesCenterName = centro.Name;
        extLead.companyId = centro.Concesionario__r.Id_Concesionario_Sima__c;
        extLead.brandName = infoCase.Marca__c;
        extLead.externalId = infoCase.Id;

        List<String> intenciones = !String.isBlank(infoCase.Intencion_de_compra__c)?infoCase.Intencion_de_compra__c.split(';') : new List<String>();
        String intencionCompra = '';
        
        for (Integer i = 0; i < intenciones.size(); i++) {
            if (i == intenciones.size() - 1) {
                intencionCompra += CaseGateway.getIntencionCompraLabel(intenciones[i]);
            }
            else {
                intencionCompra += CaseGateway.getIntencionCompraLabel(intenciones[i]) + ';';
            }
        }

        extLead.leadIntention = intencionCompra;
        system.debug('infoCase.Lead_Score__c:'+infoCase.Lead_Score__c);
        extLead.leadScore = infoCase.Lead_Score__c != null?String.valueOf(infoCase.Lead_Score__c).replace('.',',') :'';
         
        ExternalLeadApiNewModel.Assignment assignment = new ExternalLeadApiNewModel.Assignment();
        assignment.salesmanEmail = emailAsesor;

        assignment.assignAutomatically = campania.Name != null && Label.CampaignsAsignacionDirecta.contains(campania.Name) ?'true':'false';
        extLead.assignment = assignment;

        ExternalLeadApiNewModel.Customer customer = new ExternalLeadApiNewModel.Customer();
        customer.customerId = idClienteExterno;
        customer.email = infoCase.SuppliedEmail;
        customer.phone = infoCase.SuppliedPhone;

        customer.contactPreference =  'Canal: ' + CaseGateway.getPreferenciaContactoLabel(infoCase.Preferencia_de_contacto__c);
        if (!String.isBlank(infoCase.Horario_de_contacto__c)) {
            customer.contactPreference += ' Horario de contacto: ' + CaseGateway.getHorarioContactoLabel(infoCase.Horario_de_contacto__c);
        }
        if (infoCase.Fecha_Hora_de_cita__c != null) {
            customer.contactPreference += ' Fecha hora cita con cliente: '+String.valueOf(infoCase.Fecha_Hora_de_cita__c);
        }    
        
        extLead.customer = customer;

        ExternalLeadApiNewModel.MeetingDetails meetingDetails = new ExternalLeadApiNewModel.MeetingDetails();
        meetingDetails.scheduledDate = String.valueOf(Datetime.now().addHours(2).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
        extLead.meetingDetails = meetingDetails;

        List<String> modelos = !String.isBlank(infoCase.Modelo__c) ? infoCase.Modelo__c.split(';') : new List<String>();
        String modelo = '';
        
        for (Integer i = 0; i < modelos.size(); i++) {
            if (i == modelos.size() - 1) {
                modelo += CaseGateway.getModeloLabel(modelos[i]);
            }
            else{
                modelo += CaseGateway.getModeloLabel(modelos[i]) + ',';
            }
        }
        
        ExternalLeadApiNewModel.Vehicle vehicle = new ExternalLeadApiNewModel.Vehicle();
        if (infoCase.descmodel__c != null) {
            vehicle.model = !String.isBlank(modelo)? modelo + ' - ' + infoCase.descmodel__c:infoCase.descmodel__c;
        } else {
            vehicle.model = modelo;
        }
        vehicle.model = modelo + infoCase.descmodel__c;
        vehicle.vin = infoCase.VIN__c;
        vehicle.color = infoCase.colorCar__c;
        vehicle.inside = infoCase.insideCar__c;
        vehicle.equipment = infoCase.equipaments__c;
        vehicle.packages = infoCase.packages__c;
        vehicle.marketingCode = infoCase.MarketingCode__c;
        vehicle.configurationURL = infoCase.urlConfiguration__c;
        extLead.vehicle = vehicle;

        ExternalLeadApiNewModel.Campaign campaign = new ExternalLeadApiNewModel.Campaign();
        campaign.Name = campania.Name;
//        campaign.Description = '';
//        campaign.ExpirationDate = '';
        if (infoCase.RecommendById__c != null) {
	        campaign.customerId = infoCase.RecommendById__c.substringBefore('/');
        }
        extLead.campaign = campaign;
        

        ExternalLeadApiNewModel.Financing financing = new ExternalLeadApiNewModel.Financing();
        financing.quota = infoCase.Cuota_Financiacion__c;
        financing.postponements = infoCase.Aplazamiento_Financiacion__c;
        financing.downPayment = infoCase.Entrada_Financiacion__c;
        extLead.financing = financing;

        extLead.description = infoCase.Description;
        extLead.comment = infoCase.Comments;
        
        
        String campaignName = campania != null ?' Campañia: ' +campania.Name:'';
        String linea0 = automatico?'Automático ':'';
        String linea1 = 'Caso SF: '+ infoCase.CaseNumber + ' Intención de compra: ' + intencionCompra
            + ' Modelo: ' + modelo + campaignName+'\r\n';
        String linea2 = 'Teléfono: '+ infoCase.SuppliedPhone + ' Email: ' + infoCase.SuppliedEmail
            + ' Preferencia de contacto: ' + CaseGateway.getPreferenciaContactoLabel(infoCase.Preferencia_de_contacto__c);
            //+ ' Horario de contacto: ' + CaseGateway.getHorarioContactoLabel(infoCase.Horario_de_contacto__c) + '\r\n';
        
        if (!String.isBlank(infoCase.Horario_de_contacto__c)) {
            linea2 += ' Horario de contacto: ' + CaseGateway.getHorarioContactoLabel(infoCase.Horario_de_contacto__c) + '\r\n';
        }
        else {
            linea2 += '\r\n';
        }
        
        String linea3 = infoCase.Fecha_Hora_de_cita__c != null ? 'Fecha hora cita con cliente: '+String.valueOf(infoCase.Fecha_Hora_de_cita__c)+'\r\n':'';
        String linea4 = !String.isBlank(infoCase.Description)?'Descripción: '+infoCase.Description+'\r\n':'';
        String linea5 = !String.isBlank(infoCase.Comments)?'Comentario: '+infoCase.Comments+'\r\n':'';
        String linea6 = !String.isBlank(infoCase.VIN__c)?'VIN: '+ infoCase.VIN__c+'\r\n':'';
        String linea7 = !String.isBlank(infoCase.descmodel__c)?'Descripción del modelo: '+ infoCase.descmodel__c+ '\r\n':'';
        String linea8 = !String.isBlank(infoCase.colorCar__c)?'Color del vehículo: '+ infoCase.colorCar__c + '\r\n':'';
        String linea9 = !String.isBlank(infoCase.insideCar__c)?'Interior: '+ infoCase.insideCar__c+'\r\n':'';
        String linea10 = !String.isBlank(infoCase.equipaments__c)?'Equipamientos: '+ infoCase.equipaments__c+'\r\n':'';
        String linea11 = !String.isBlank(infoCase.packages__c)?'Paquetes: '+ infoCase.packages__c+'\r\n':'';
        String linea12 = !String.isBlank(infoCase.MarketingCode__c)?'Código de marketing: '+ infoCase.MarketingCode__c+'\r\n':'';
        String linea13 = !String.isBlank(infoCase.urlConfiguration__c)?'URL configuración: '+ infoCase.urlConfiguration__c+'\r\n':'';
		String linea14 = !String.isBlank(infoCase.Cuota_Financiacion__c)?'Financiación - Cuota: '+ infoCase.Cuota_Financiacion__c+ ' Aplazamiento: '+ infoCase.Aplazamiento_Financiacion__c + ' Entrada: '+ infoCase.Entrada_Financiacion__c +'\r\n':'';
        
        system.debug('linea0: '+linea0);
        system.debug('linea1: '+linea1);
        system.debug('linea2: '+linea2);
        system.debug('linea3: '+linea3);
        system.debug('linea4: '+linea4);
        system.debug('linea6: '+linea6);
        system.debug('linea7: '+linea7);
        system.debug('linea8: '+linea8);
        system.debug('linea9: '+linea9);
        system.debug('linea10: '+linea10);
        system.debug('linea11: '+linea11);
        system.debug('linea12: '+linea12);
        system.debug('linea13: '+linea13);
        system.debug('linea14: '+linea14);
        
        extLead.remarks =linea0 + linea1 + linea2 +linea3 + linea6 + linea7 + linea8 + linea9 + linea10 + linea11 + linea12 + linea13 + linea14 + linea4 + linea5;		
        System.debug('extLead.remarks:'+extLead.remarks);
        
        String JSONrequest = JSON.serialize(extLead);
        system.debug('JSON_Inma:'+ JSONrequest);


        return extLead;
    }
    
    public static ExternalCustomerApiModel.CustomerApi createExternalCustomer(Case infoCase, Centro__c centro, Account cuenta, Lead candidato, Map<String, Pais__c> mapPaisByName) {
        ExternalCustomerApiModel.CustomerApi extCustomer = new ExternalCustomerApiModel.CustomerApi();
        ExternalCustomerApiModel.TaxId taxCustomer = new ExternalCustomerApiModel.TaxId();
        
        extCustomer.companyId = centro.Concesionario__r.Id_Concesionario_Sima__c;
        extCustomer.accountId =infoCase.AccountId;
        extCustomer.leadId =infoCase.Lead__c;

        if (cuenta != null) {
            if (cuenta.IsPersonAccount) {
                extCustomer.name = cuenta.FirstName;
                
                if (!String.isBlank(cuenta.LastName)) {
                	List<String> apellidos = cuenta.LastName.Split(' ');
        			extCustomer.firstSurname = apellidos.get(0);
                	extCustomer.secondSurname = '';
                	
                    for (integer i = 1; i < apellidos.size(); i++) {
                        extCustomer.secondSurname += apellidos.get(i) + ' ';
                    }
                }
                extCustomer.title = cuenta.Salutation;
                
                if (!String.isBlank(cuenta.Documento__c)) {
                    extCustomer.taxId = new ExternalCustomerApiModel.TaxId();
                    taxCustomer.num =cuenta.Documento__c;
                	taxCustomer.documentType = cuenta.Tipo_de_documento_cuenta_personal__c;
                	taxCustomer.personType =Label.AccountPerson;
                    extCustomer.taxId = taxCustomer;
                }
                extCustomer.personType = Label.AccountPerson;
                
                if(!String.isBlank(infoCase.SuppliedEmail)){
                    extCustomer.methodsOfContact = extCustomer.methodsOfContact==null ? new List<ExternalCustomerApiModel.MethodOfContact>():extCustomer.methodsOfContact;
                	ExternalCustomerApiModel.MethodOfContact metodoContacto = new ExternalCustomerApiModel.MethodOfContact();
					metodoContacto.channel =Label.channelEmail;
                    metodoContacto.value = InfoCase.SuppliedEmail.toLowerCase();
                    metodoContacto.isDefault = false;
                    extCustomer.methodsOfContact.add(metodoContacto);
                }
                if(!String.isBlank(infoCase.SuppliedPhone)){
                    extCustomer.methodsOfContact = extCustomer.methodsOfContact==null ? new List<ExternalCustomerApiModel.MethodOfContact>():extCustomer.methodsOfContact;
                	ExternalCustomerApiModel.MethodOfContact metodoContacto = new ExternalCustomerApiModel.MethodOfContact();
					String tipo = DataValidations.isMobile(infoCase.SuppliedPhone)? Label.channelMobile : Label.channelPhone;
                    metodoContacto.channel =tipo;
                    metodoContacto.value = infoCase.SuppliedPhone;
                    metodoContacto.isDefault = false;
                    extCustomer.methodsOfContact.add(metodoContacto);
                }
            }
            else {
                extCustomer.fiscalName = !String.isBlank(cuenta.Name)? cuenta.Name:'';
                
                if(!String.isBlank(cuenta.Documento__c)){
                    extCustomer.taxId = new ExternalCustomerApiModel.TaxId();
                    taxCustomer.num = cuenta.Documento__c;
                	taxCustomer.documentType = cuenta.Tipo_de_documento_empresa__c;
                	taxCustomer.personType =Label.AccountEmpresa;
                    extCustomer.taxId = taxCustomer;
                
                }
                extCustomer.personType = Label.AccountEmpresa;
                
                if(!String.isBlank(infoCase.SuppliedEmail)){
                    extCustomer.methodsOfContact = extCustomer.methodsOfContact==null ? new List<ExternalCustomerApiModel.MethodOfContact>():extCustomer.methodsOfContact;
                	ExternalCustomerApiModel.MethodOfContact metodoContacto = new ExternalCustomerApiModel.MethodOfContact();
					metodoContacto.channel =Label.channelEmail;
                    metodoContacto.value = InfoCase.SuppliedEmail.toLowerCase();
                    metodoContacto.isDefault = false;
                    extCustomer.methodsOfContact.add(metodoContacto);
                }
                if(!String.isBlank(infoCase.SuppliedPhone)){
                    extCustomer.methodsOfContact = extCustomer.methodsOfContact==null ? new List<ExternalCustomerApiModel.MethodOfContact>():extCustomer.methodsOfContact;
                	ExternalCustomerApiModel.MethodOfContact metodoContacto = new ExternalCustomerApiModel.MethodOfContact();
					String tipo = DataValidations.isMobile(infoCase.SuppliedPhone)? Label.channelMobile : Label.channelPhone;
                    metodoContacto.channel =tipo;
                    metodoContacto.value = infoCase.SuppliedPhone;
                    metodoContacto.isDefault = false;
                    extCustomer.methodsOfContact.add(metodoContacto);
                }
            }
            
            extCustomer.tradeName =cuenta.Marca_registrada__c;
            extCustomer.countryIso31661 =cuenta.Pais__c != null?cuenta.Pais__r.ISO_31661_alfa2__c:'ES';
          	
            String paisBilling = !String.isBlank(cuenta.BillingCountry)?DataValidations.capitalizeString(cuenta.BillingCountry):'';
            /*if(!String.isBlank(cuenta.BillingStreet) && !String.isBlank(paisBilling) && mapPaisByName.containsKey(paisBilling) && mapPaisByName.get(paisBilling).ISO_31661_alfa2__c=='ES' && !String.isBlank(cuenta.BillingState) ){
            	extCustomer.addresses = extCustomer.addresses ==null? new List<ExternalCustomerApiModel.Address>():extCustomer.addresses;
                ExternalCustomerApiModel.Address direccion = new ExternalCustomerApiModel.Address();
            	ExternalCustomerApiModel.Purpose purpose = new ExternalCustomerApiModel.Purpose();
                direccion.purposes = new List<String>();
            	direccion.city = !String.isBlank(cuenta.BillingCity)? cuenta.BillingCity: '';
                List<String> regionDepartment = !String.isBlank(cuenta.BillingState)?cuenta.BillingState.split('/'):null;
                if(regionDepartment != null && regionDepartment.size()>1){
                    direccion.region =regionDepartment[0];
                    direccion.department = regionDepartment[1];
                }
            	direccion.street = cuenta.BillingStreet;
                direccion.countryIso31661 = mapPaisByName.get(paisBilling).ISO_31661_alfa2__c;
           		direccion.postalCode =!String.isBlank(cuenta.BillingPostalCode)? cuenta.BillingPostalCode:'';
                direccion.streetTypeId ='CL';
                direccion.purposes.add('Taxes');
                extCustomer.addresses.add(direccion);
            }
            else if(!String.isBlank(paisBilling) && mapPaisByName.containsKey(paisBilling) && !mapPaisByName.get(paisBilling).ISO_31661_alfa2__c.equalsIgnoreCase('ES') ) {
                ExternalCustomerApiModel.Address direccion = new ExternalCustomerApiModel.Address();
            	ExternalCustomerApiModel.Purpose purpose = new ExternalCustomerApiModel.Purpose();
            	extCustomer.addresses = extCustomer.addresses ==null? new List<ExternalCustomerApiModel.Address>():extCustomer.addresses;
                
                direccion.purposes = new List<String>();
            	direccion.foreignFullAddress = cuenta.BillingStreet;
                direccion.city ='';
            	direccion.department = '';
                direccion.region = '';
            	direccion.countryIso31661 = mapPaisByName.get(paisBilling).ISO_31661_alfa2__c;
           		direccion.postalCode ='';
                direccion.streetTypeId ='CL';
                direccion.purposes.add('Taxes');
                extCustomer.addresses.add(direccion);
            }
            */
            String paisShipping = !String.isBlank(cuenta.ShippingCountry)?DataValidations.capitalizeString(cuenta.ShippingCountry):'';
            /*if(!String.isBlank(cuenta.ShippingStreet) && !String.isBlank(paisShipping) && mapPaisByName.containsKey(paisShipping) && mapPaisByName.get(paisShipping).ISO_31661_alfa2__c=='ES' && !String.isBlank(cuenta.ShippingStreet) && !String.isBlank(cuenta.ShippingState)){
                ExternalCustomerApiModel.Address direccionShipping = new ExternalCustomerApiModel.Address();
            	ExternalCustomerApiModel.Purpose purposeShipping = new ExternalCustomerApiModel.Purpose();
            	extCustomer.addresses = extCustomer.addresses ==null? new List<ExternalCustomerApiModel.Address>():extCustomer.addresses;
                direccionShipping.purposes = new List<String>();
            	
                direccionShipping.city= cuenta.ShippingCity;
                List<String> regionDepartment = !String.isBlank(cuenta.ShippingState)?cuenta.ShippingState.split('/'):null;
                if(regionDepartment != null && regionDepartment.size()>1){
                    direccionShipping.region =regionDepartment[0];
                    direccionShipping.department = regionDepartment[1];
                }
            	
            	//direccionShipping.department = cuenta.ShippingState;
                //direccionShipping.region = cuenta.ShippingState;
            	direccionShipping.street = cuenta.ShippingStreet;
                direccionShipping.countryIso31661 = mapPaisByName.get(paisShipping).ISO_31661_alfa2__c;
           		direccionShipping.postalCode =cuenta.ShippingPostalCode;
                direccionShipping.streetTypeId ='CL';
                direccionShipping.purposes.add('Delivering');
                extCustomer.addresses.add(direccionShipping);
            }
            else if(!String.isBlank(paisShipping) && mapPaisByName.containsKey(paisShipping) && !mapPaisByName.get(paisShipping).ISO_31661_alfa2__c.equalsIgnoreCase('ES')) {
                ExternalCustomerApiModel.Address direccionShipping = new ExternalCustomerApiModel.Address();
            	ExternalCustomerApiModel.Purpose purposeShipping = new ExternalCustomerApiModel.Purpose();
            	extCustomer.addresses = extCustomer.addresses ==null? new List<ExternalCustomerApiModel.Address>():extCustomer.addresses;
                direccionShipping.purposes = new List<String>();
            	
                direccionShipping.foreignFullAddress = cuenta.ShippingStreet;
                direccionShipping.city = '';
            	direccionShipping.department ='';
                direccionShipping.region = '';
            	direccionShipping.countryIso31661 = mapPaisByName.get(paisShipping).ISO_31661_alfa2__c;
           		direccionShipping.postalCode ='';
                direccionShipping.streetTypeId ='CL';
                direccionShipping.purposes.add('Delivering');
                extCustomer.addresses.add(direccionShipping);
            }
        	*/
		}
        else if (candidato != null) {
            extCustomer.name = candidato.FirstName;
            
            if (!String.isBlank(candidato.LastName)) {
                	List<String> apellidos = candidato.LastName.Split(' ');
        			extCustomer.firstSurname = apellidos.get(0);
                	extCustomer.secondSurname = '';
                	
                    for (integer i = 1; i<apellidos.size(); i++) {
                        extCustomer.secondSurname += apellidos.get(i) + ' ';
                    }
                }
            extCustomer.title = candidato.Salutation;
            extCustomer.personType = Label.AccountPerson;
            
            if (!String.isBlank(infoCase.SuppliedEmail)) {
                	extCustomer.methodsOfContact = extCustomer.methodsOfContact == null ? new List<ExternalCustomerApiModel.MethodOfContact>() : extCustomer.methodsOfContact;
                	ExternalCustomerApiModel.MethodOfContact metodoContacto = new ExternalCustomerApiModel.MethodOfContact();
					metodoContacto.channel =Label.channelEmail;
                    metodoContacto.value = infoCase.SuppliedEmail.toLowerCase();
                    metodoContacto.isDefault = false;
                    extCustomer.methodsOfContact.add(metodoContacto);
            }
            
            if(!String.isBlank(infoCase.SuppliedPhone)){
                	extCustomer.methodsOfContact = extCustomer.methodsOfContact==null ? new List<ExternalCustomerApiModel.MethodOfContact>():extCustomer.methodsOfContact;
                	ExternalCustomerApiModel.MethodOfContact metodoContacto = new ExternalCustomerApiModel.MethodOfContact();
					String tipo = DataValidations.isMobile(infoCase.SuppliedPhone)? Label.channelMobile : Label.channelPhone;
                    metodoContacto.channel = tipo;
                    metodoContacto.value = infoCase.SuppliedPhone;
                    metodoContacto.isDefault = false;
                    extCustomer.methodsOfContact.add(metodoContacto);
                }
            
            
            String pais = !String.isBlank(candidato.Country)?DataValidations.capitalizeString(candidato.Country):'';
            extCustomer.countryIso31661 =!String.isBlank(pais) && mapPaisByName.containsKey(pais)?mapPaisByName.get(pais).ISO_31661_alfa2__c:'ES';
            /*
            if(!String.isBlank(pais) && !String.isBlank(pais) && mapPaisByName.containsKey(pais) && mapPaisByName.get(pais).ISO_31661_alfa2__c=='ES' ){
            	extCustomer.addresses = extCustomer.addresses ==null? new List<ExternalCustomerApiModel.Address>():extCustomer.addresses;
                ExternalCustomerApiModel.Address direccion = new ExternalCustomerApiModel.Address();
            	ExternalCustomerApiModel.Purpose purpose = new ExternalCustomerApiModel.Purpose();
                direccion.purposes = new List<String>();
            	
                direccion.city = !String.isBlank(candidato.City)? candidato.City: '';
            	direccion.department = !String.isBlank(candidato.State)? candidato.State:'';
                direccion.region = !String.isBlank(candidato.State)? candidato.State:'';
            	direccion.street = candidato.Street;
                direccion.countryIso31661 = mapPaisByName.get(pais).ISO_31661_alfa2__c;
           		direccion.postalCode =!String.isBlank(candidato.PostalCode)? candidato.PostalCode:'';
                direccion.streetTypeId ='CL';
                direccion.purposes.add('Taxes');
                extCustomer.addresses.add(direccion);
            }
            else if(!String.isBlank(pais) && mapPaisByName.containsKey(pais) && !mapPaisByName.get(pais).ISO_31661_alfa2__c.equalsIgnoreCase('ES') ) {
                ExternalCustomerApiModel.Address direccion = new ExternalCustomerApiModel.Address();
            	ExternalCustomerApiModel.Purpose purpose = new ExternalCustomerApiModel.Purpose();
            	extCustomer.addresses = extCustomer.addresses ==null? new List<ExternalCustomerApiModel.Address>():extCustomer.addresses;
                
                direccion.purposes = new List<String>();
            	direccion.foreignFullAddress = candidato.Street;
                direccion.city = !String.isBlank(candidato.City)? candidato.City: '';
            	direccion.department = !String.isBlank(candidato.State)? candidato.State:'';
                direccion.region = !String.isBlank(candidato.State)? candidato.State:'';
            	direccion.countryIso31661 = mapPaisByName.get(pais).ISO_31661_alfa2__c;
           		direccion.postalCode =!String.isBlank(candidato.PostalCode)? candidato.PostalCode:'';
                direccion.streetTypeId ='CL';
                direccion.purposes.add('Taxes');
                extCustomer.addresses.add(direccion);
            }
           	*/
        	}
        
        return extCustomer;
    }
	
    public static ExternalConsentimientoApiModel.ConsentimientoApi createExternalConsentimiento(List<Consentimientos__c> listConsentimiento, List<Cliente_Concesionario__c> listCconcesionario) {
        ExternalConsentimientoApiModel.ConsentimientoApi extConsentimiento = new ExternalConsentimientoApiModel.ConsentimientoApi();
        
        List<ExternalConsentimientoApiModel.consentimientos> listConsentimientosExt = new List<ExternalConsentimientoApiModel.consentimientos>();
        List<ExternalConsentimientoApiModel.customers> listCustomers = new List<ExternalConsentimientoApiModel.customers>();
        List<ExternalConsentimientoApiModel.consentimientosCustom> listConsentimientosCustomExt = new List<ExternalConsentimientoApiModel.consentimientosCustom>();
        for(Cliente_Concesionario__c cConcesionario :listCconcesionario){
            ExternalConsentimientoApiModel.customers customers = new ExternalConsentimientoApiModel.customers();
            if(!String.isBlank(cConcesionario.Id_Cliente_DMS__c)){
                customers.companyId = cConcesionario.Concesionario__r.Id_Concesionario_Sima__c;
            	customers.customerId = cConcesionario.Id_Cliente_DMS__c;
            	listCustomers.add(customers);
            }
        }
        
        for(Consentimientos__c consentimiento :listConsentimiento){
            system.debug('consentimiento:'+ consentimiento);
            String recordTypeDV = ConsentimientosGateway.getRecordTypeDeveloperNameById(consentimiento.RecordTypeId);
            extConsentimiento.fecha = extConsentimiento.fecha == null || extConsentimiento.fecha < consentimiento.Fecha_de_captura__c ? consentimiento.Fecha_de_captura__c : extConsentimiento.fecha;
            
            if(recordTypeDV.equalsIgnoreCase(Label.RtConsentimientoNoEcosistema)){
                ExternalConsentimientoApiModel.consentimientosCustom consentimientoExt = new ExternalConsentimientoApiModel.consentimientosCustom();
                consentimientoExt.companyId = consentimiento.Concesionario__r.Id_Concesionario_Sima__c;
                consentimientoExt.CustomerSatisfactionAfterSales = consentimiento.CustomerSatisfactionAfterSales__c;
                consentimientoExt.CustomerSatisfactionAfterSalesSMS = consentimiento.CustomerSatisfactionAfterSales__c;
                consentimientoExt.CustomerSatisfactionSales = consentimiento.CustomerSatisfactionSales__c;
                consentimientoExt.CustomerSatisfactionSalesSMS = consentimiento.CustomerSatisfactionSales__c;
                consentimientoExt.EAVE = consentimiento.eave__c;
                consentimientoExt.Insurance = consentimiento.Insurance__c;
                listConsentimientosCustomExt.add(consentimientoExt);
            }
            else {
                ExternalConsentimientoApiModel.consentimientos consentimientoExt = new ExternalConsentimientoApiModel.consentimientos();
                
                if (recordTypeDV.equalsIgnoreCase('Movil')) {
                    consentimientoExt.ChannelType = 'Mobile';
                    String mas34 = consentimiento.ChannelValue__c.substring(0, 3);
                     system.debug('mas34:'+mas34);
                    
                    if(mas34.equalsIgnoreCase('+34')){
                        ExternalConsentimientoApiModel.consentimientos consentimientoExtDup = new ExternalConsentimientoApiModel.consentimientos();
                        String channelValue = consentimiento.ChannelValue__c.substring(3, consentimiento.ChannelValue__c.length());
                        system.debug('sin +34:  '+ channelValue);
                        consentimientoExtDup.ChannelValue = channelValue;
                        consentimientoExtDup.ChannelType = 'Mobile';
                        consentimientoExtDup.AfterSales = consentimiento.AfterSales__c;
                        consentimientoExtDup.AfterSalesSMS = consentimiento.AfterSalesSMS__c;
                        consentimientoExtDup.CustomerSatisfaction = consentimiento.CustomerSatisfaction__c;
                        consentimientoExtDup.CustomerSatisfactionSMS = consentimiento.CustomerSatisfactionSMS__c;
                        consentimientoExtDup.EventInvitation = consentimiento.EventInvitation__c;
                        consentimientoExtDup.EventInvitationSMS = consentimiento.EventInvitationSMS__c;
                        consentimientoExtDup.MarketResearch = consentimiento.MarketResearch__c;
                        consentimientoExtDup.MarketResearchSMS = consentimiento.MarketResearchSMS__c;
                        consentimientoExtDup.ProductSale = consentimiento.ProductSale__c;
                        consentimientoExtDup.ProductSaleSMS = consentimiento.ProductSaleSMS__c;
                        system.debug('consentimientoExtDup:'+ consentimientoExtDup);
                        listConsentimientosExt.add(consentimientoExtDup);
                    }
                } 
                else if (recordTypeDV.equalsIgnoreCase('Telefono')) {
                    consentimientoExt.ChannelType = 'Phone';
                    String mas34 = consentimiento.ChannelValue__c.substring(0, 3);
                     system.debug('mas34:'+mas34);
                    
                    if (mas34.equalsIgnoreCase('+34')) {
                        ExternalConsentimientoApiModel.consentimientos consentimientoExtDup = new ExternalConsentimientoApiModel.consentimientos();
                        String channelValue = consentimiento.ChannelValue__c.substring(3, consentimiento.ChannelValue__c.length());
                        system.debug('sin +34:  '+ channelValue);
                        consentimientoExtDup.ChannelValue = channelValue;
                        consentimientoExtDup.ChannelType = 'Phone';
                        consentimientoExtDup.AfterSales = consentimiento.AfterSales__c;
                        consentimientoExtDup.AfterSalesSMS = consentimiento.AfterSalesSMS__c;
                        consentimientoExtDup.CustomerSatisfaction = consentimiento.CustomerSatisfaction__c;
                        consentimientoExtDup.CustomerSatisfactionSMS = consentimiento.CustomerSatisfactionSMS__c;                        consentimientoExtDup.EventInvitation = consentimiento.EventInvitation__c;
                        consentimientoExtDup.EventInvitationSMS = consentimiento.EventInvitationSMS__c;
                        consentimientoExtDup.MarketResearch = consentimiento.MarketResearch__c;
                        consentimientoExtDup.MarketResearchSMS = consentimiento.MarketResearchSMS__c;
                        consentimientoExtDup.ProductSale = consentimiento.ProductSale__c;
                        consentimientoExtDup.ProductSaleSMS = consentimiento.ProductSaleSMS__c;
                        system.debug('consentimientoExtDup:'+ consentimientoExtDup);
                        listConsentimientosExt.add(consentimientoExtDup);
                    }
                }
                else {
                    consentimientoExt.ChannelType = recordTypeDV;
                }
                
                consentimientoExt.ChannelValue = consentimiento.ChannelValue__c;
                consentimientoExt.AfterSales = consentimiento.AfterSales__c;
                consentimientoExt.AfterSalesSMS = consentimiento.AfterSalesSMS__c;
                consentimientoExt.CustomerSatisfaction = consentimiento.CustomerSatisfaction__c;
                consentimientoExt.CustomerSatisfactionSMS = consentimiento.CustomerSatisfactionSMS__c;
                consentimientoExt.EventInvitation = consentimiento.EventInvitation__c;
                consentimientoExt.EventInvitationSMS = consentimiento.EventInvitationSMS__c;
                consentimientoExt.MarketResearch = consentimiento.MarketResearch__c;
                consentimientoExt.MarketResearchSMS = consentimiento.MarketResearchSMS__c;
                consentimientoExt.ProductSale = consentimiento.ProductSale__c;
                consentimientoExt.ProductSaleSMS = consentimiento.ProductSaleSMS__c;
                listConsentimientosExt.add(consentimientoExt);
        	}
        }
        
        extConsentimiento.customers = listCustomers;
        extConsentimiento.consentimientos = listConsentimientosExt;
        extConsentimiento.consentCustom = listConsentimientosCustomExt;
        return extConsentimiento;
    }
    
    public static ExternalConsentimientoApiModel.ConsentimientoApi createExternalConsentimiento(List<Consentimientos__c> listConsentimiento, List<Cliente_Concesionario__c> listCconcesionario, Centro__c centro) {
        ExternalConsentimientoApiModel.ConsentimientoApi extConsentimiento = new ExternalConsentimientoApiModel.ConsentimientoApi();
        List<ExternalConsentimientoApiModel.consentimientos> listConsentimientosExt = new List<ExternalConsentimientoApiModel.consentimientos>();
        List<ExternalConsentimientoApiModel.customers> listCustomers = new List<ExternalConsentimientoApiModel.customers>();
        List<ExternalConsentimientoApiModel.consentimientosCustom> listConsentimientosCustomExt = new List<ExternalConsentimientoApiModel.consentimientosCustom>();
        for(Cliente_Concesionario__c cConcesionario :listCconcesionario){
            if(!String.isBlank(cConcesionario.Id_Cliente_DMS__c)){
            	ExternalConsentimientoApiModel.customers customers = new ExternalConsentimientoApiModel.customers();
            	customers.companyId = cConcesionario.Concesionario__r.Id_Concesionario_Sima__c != null?cConcesionario.Concesionario__r.Id_Concesionario_Sima__c:centro.Concesionario__r.Id_Concesionario_Sima__c;
            	customers.customerId = cConcesionario.Id_Cliente_DMS__c;
            	listCustomers.add(customers);
           }
        }
        
        for(Consentimientos__c consentimiento :listConsentimiento){
            String recordTypeDV = ConsentimientosGateway.getRecordTypeDeveloperNameById(consentimiento.RecordTypeId);
            extConsentimiento.fecha = extConsentimiento.fecha == null || extConsentimiento.fecha <consentimiento.Fecha_de_captura__c ? consentimiento.Fecha_de_captura__c:extConsentimiento.fecha;
        
            if(recordTypeDV.equalsIgnoreCase(Label.RtConsentimientoNoEcosistema)){
                ExternalConsentimientoApiModel.consentimientosCustom consentimientoExt = new ExternalConsentimientoApiModel.consentimientosCustom();
                consentimientoExt.companyId = consentimiento.Concesionario__r.Id_Concesionario_Sima__c;
                consentimientoExt.CustomerSatisfactionAfterSales = consentimiento.CustomerSatisfactionAfterSales__c;
                consentimientoExt.CustomerSatisfactionAfterSalesSMS = consentimiento.CustomerSatisfactionAfterSales__c;
                consentimientoExt.CustomerSatisfactionSales = consentimiento.CustomerSatisfactionSales__c;
                consentimientoExt.CustomerSatisfactionSalesSMS = consentimiento.CustomerSatisfactionSales__c;
                consentimientoExt.EAVE = consentimiento.eave__c;
                consentimientoExt.Insurance = consentimiento.Insurance__c;
                listConsentimientosCustomExt.add(consentimientoExt);
            }
            else{
                system.debug('consentimiento:'+ consentimiento);
                ExternalConsentimientoApiModel.consentimientos consentimientoExt = new ExternalConsentimientoApiModel.consentimientos();
                if(recordTypeDV.equalsIgnoreCase('Movil')){
                    consentimientoExt.ChannelType = 'Mobile';
                    String mas34 = consentimiento.ChannelValue__c.substring(0, 3);
                     system.debug('mas34:'+mas34);
                    if(mas34.equalsIgnoreCase('+34')){
                        ExternalConsentimientoApiModel.consentimientos consentimientoExtDup = new ExternalConsentimientoApiModel.consentimientos();
                        String channelValue = consentimiento.ChannelValue__c.substring(3, consentimiento.ChannelValue__c.length());
                        system.debug('sin +34:  '+ channelValue);
                        consentimientoExtDup.ChannelValue = channelValue;
                        consentimientoExtDup.ChannelType = 'Mobile';
                        consentimientoExtDup.AfterSales = consentimiento.AfterSales__c;
                        consentimientoExtDup.AfterSalesSMS = consentimiento.AfterSalesSMS__c;
                        consentimientoExtDup.CustomerSatisfaction = consentimiento.CustomerSatisfaction__c;
                        consentimientoExtDup.CustomerSatisfactionSMS = consentimiento.CustomerSatisfactionSMS__c;
                        consentimientoExtDup.EventInvitation = consentimiento.EventInvitation__c;
                        consentimientoExtDup.EventInvitationSMS = consentimiento.EventInvitationSMS__c;
                        consentimientoExtDup.MarketResearch = consentimiento.MarketResearch__c;
                        consentimientoExtDup.MarketResearchSMS = consentimiento.MarketResearchSMS__c;
                        consentimientoExtDup.ProductSale = consentimiento.ProductSale__c;
                        consentimientoExtDup.ProductSaleSMS = consentimiento.ProductSaleSMS__c;
                        system.debug('consentimientoExtDup:'+ consentimientoExtDup);
                        listConsentimientosExt.add(consentimientoExtDup);
                    }
                } 
                else if (recordTypeDV.equalsIgnoreCase('Telefono')){
                    consentimientoExt.ChannelType = 'Phone';
                    String mas34= consentimiento.ChannelValue__c.substring(0, 3);
                    system.debug('mas34:'+mas34);
                    if(mas34.equalsIgnoreCase('+34')){
                        ExternalConsentimientoApiModel.consentimientos consentimientoExtDup = new ExternalConsentimientoApiModel.consentimientos();
                        String channelValue = consentimiento.ChannelValue__c.substring(3, consentimiento.ChannelValue__c.length());
                        system.debug('sin +34:'+ channelValue);
                        consentimientoExtDup.ChannelValue =channelValue;
                        consentimientoExtDup.ChannelType = 'Phone';
                        consentimientoExtDup.AfterSales = consentimiento.AfterSales__c;
                        consentimientoExtDup.AfterSalesSMS = consentimiento.AfterSalesSMS__c;
                        consentimientoExtDup.CustomerSatisfaction = consentimiento.CustomerSatisfaction__c;
                        consentimientoExtDup.CustomerSatisfactionSMS = consentimiento.CustomerSatisfactionSMS__c;
                        consentimientoExtDup.EventInvitation = consentimiento.EventInvitation__c;
                        consentimientoExtDup.EventInvitationSMS = consentimiento.EventInvitationSMS__c;
                        consentimientoExtDup.MarketResearch = consentimiento.MarketResearch__c;
                        consentimientoExtDup.MarketResearchSMS = consentimiento.MarketResearchSMS__c;
                        consentimientoExtDup.ProductSale = consentimiento.ProductSale__c;
                        consentimientoExtDup.ProductSaleSMS = consentimiento.ProductSaleSMS__c;
                        system.debug('consentimientoExtDup:'+ consentimientoExtDup);
                        listConsentimientosExt.add(consentimientoExtDup);
                    }
                }
                else {
                    consentimientoExt.ChannelType = recordTypeDV;
                }
                consentimientoExt.ChannelValue = consentimiento.ChannelValue__c;
                consentimientoExt.AfterSales = consentimiento.AfterSales__c;
                consentimientoExt.AfterSalesSMS = consentimiento.AfterSalesSMS__c;
                consentimientoExt.CustomerSatisfaction = consentimiento.CustomerSatisfaction__c;
                consentimientoExt.CustomerSatisfactionSMS = consentimiento.CustomerSatisfactionSMS__c;
                consentimientoExt.EventInvitation = consentimiento.EventInvitation__c;
                consentimientoExt.EventInvitationSMS = consentimiento.EventInvitationSMS__c;
                consentimientoExt.MarketResearch = consentimiento.MarketResearch__c;
                consentimientoExt.MarketResearchSMS = consentimiento.MarketResearchSMS__c;
                consentimientoExt.ProductSale = consentimiento.ProductSale__c;
                consentimientoExt.ProductSaleSMS = consentimiento.ProductSaleSMS__c;
                listConsentimientosExt.add(consentimientoExt);
       		}
        }
        
        extConsentimiento.customers = listCustomers;
        extConsentimiento.consentimientos = listConsentimientosExt;
        extConsentimiento.consentCustom = listConsentimientosCustomExt;
        return extConsentimiento;
    }
    
    private static Cliente_Concesionario__c createCconcesionario(Account cuenta, String idSima, String idExConcesionario, String idExConc) {
        Cliente_Concesionario__c cConcesionario = new Cliente_Concesionario__c();
        
        if (cuenta != null) {
            cConcesionario.Cliente__c = cuenta.Id;
        	cConcesionario.Documento__c = cuenta.Documento__c;
        }
        
        if (!String.isBlank(idExConcesionario)) {
            cConcesionario.Concesionario__c = idExConcesionario;
        }
        
        if (!String.isBlank(idSima)) {
            cConcesionario.Id_Cliente_DMS__c = idSima;
            cConcesionario.External_Id__c = idSima + '/' + idExConc;
            cConcesionario.Origen__c = 'SIMA';
        }
        
        return cConcesionario;
    }
    
    private static Account createAccount(Lead candidato, Case caso, Map<String, Pais__c> mapPaisByName) {
        Account cuenta = new Account();
        cuenta.RecordTypeId = AccountGateway.getRecordTypeIdByDeveloperName('PersonAccount');
        cuenta.FirstName = candidato.FirstName;
        cuenta.LastName = candidato.LastName;
        cuenta.Salutation = candidato.Salutation;
        cuenta.PersonEmail = !String.isBlank(caso.SuppliedEmail)? caso.SuppliedEmail.toLowerCase():candidato.Email;
        Boolean esMovil = DataValidations.isMobile(caso.SuppliedPhone);
        cuenta.Phone = !String.isBlank(caso.SuppliedPhone) && !esMovil ? caso.SuppliedPhone: '';
        cuenta.PersonMobilePhone = !String.isBlank(caso.SuppliedPhone) && esMovil ? caso.SuppliedPhone:'';
        cuenta.Pais__c= mapPaisByName.containsKey(candidato.Country)?mapPaisByName.get(candidato.Country).Id:null;
        cuenta.BillingCity = candidato.City;
        cuenta.BillingCountry = !String.isBlank(candidato.Country)?candidato.Country.toUpperCase():null;
        cuenta.BillingPostalCode = candidato.PostalCode;
        cuenta.BillingState = candidato.State;
        cuenta.BillingStreet = candidato.Street;
        
        //Miramos posibles duplicados
        List<Account> lstDuplicates = new List<Account>();
        lstDuplicates.add(cuenta);
        //Cambiamos de lugar los telefonos/emails o completamos el otro para tener un mayor exito en la busqueda de duplicados
        Account cliente1 = new Account(); 
        cliente1.RecordTypeId = cuenta.RecordTypeId;
        cliente1.FirstName = cuenta.FirstName;
        cliente1.LastName = cuenta.LastName; 
        if (cuenta.OtherEmail__pc == null && cuenta.PersonEmail != null) {
            cliente1.OtherEmail__pc = cuenta.PersonEmail;
        } 
        if (cuenta.OtherMobilePhone__pc == null && cuenta.PersonMobilePhone != null) {
            cliente1.OtherMobilePhone__pc = cuenta.PersonMobilePhone;
        }
        if (cuenta.PersonOtherPhone == null && cuenta.Phone != null) {
            cliente1.PersonOtherPhone = cuenta.Phone;
        }
        lstDuplicates.add(cliente1);

        System.debug('=====>LSTDUPS: ' + lstDuplicates);

        if (Datacloud.FindDuplicates.findDuplicates(lstDuplicates).size() > 0) {
            for (Datacloud.FindDuplicatesResult resultFindDuplicate: Datacloud.FindDuplicates.findDuplicates(lstDuplicates)){
                 System.debug('=====>LSTDUPSRESULT0: ' + resultFindDuplicate);
                 for (Datacloud.DuplicateResult recordDuplicate: resultFindDuplicate.getDuplicateResults()){
                      System.debug('recordDuplicate:'+recordDuplicate);
                      String ruleDuplicateDN = recordDuplicate.getDuplicateRule();
                      if(!ruleDuplicateDN.equalsIgnoreCase('PAccountLead')){
                            List<Datacloud.MatchRecord> recordListMatch = recordDuplicate.getMatchResults()[0].getMatchRecords();
                            System.debug('=====>RECORDLISTMATCH: ' + recordListMatch);
                            if (!recordListMatch.isEmpty()) {
                                Datacloud.MatchRecord recordMatch = recordListMatch[0];
                                SObject record = recordMatch.getRecord();
                                System.debug('RECORD: ' + record);
                                Account auxAcc = (Account) record;
                        
                                if (auxAcc != null) {
                                    system.debug('auxAcc:'+auxAcc);
                                    cuenta.Id = auxAcc.Id;
                                    cuenta.PersonEmail = !String.isBlank(cuenta.PersonEmail)?cuenta.PersonEmail:auxAcc.PersonEmail;
                                    cuenta.OtherEmail__pc = !String.isBlank(cuenta.OtherEmail__pc)?cuenta.OtherEmail__pc:auxAcc.OtherEmail__pc;
                                    cuenta.PersonMobilePhone = !String.isBlank(cuenta.PersonMobilePhone)?cuenta.PersonMobilePhone:auxAcc.PersonMobilePhone;
                                    cuenta.OtherMobilePhone__pc = !String.isBlank(cuenta.OtherMobilePhone__pc)?cuenta.OtherMobilePhone__pc:auxAcc.OtherMobilePhone__pc;
                                    cuenta.Phone = !String.isBlank(cuenta.Phone)?cuenta.Phone:auxAcc.Phone;
                                    cuenta.PersonOtherPhone = !String.isBlank(cuenta.PersonOtherPhone)?cuenta.PersonOtherPhone:auxAcc.PersonOtherPhone;
                                        
                                    if (cuenta.PersonEmail == null && cuenta.OtherEmail__pc != null ) {
                                           cuenta.PersonEmail = cuenta.OtherEmail__pc;
                                           cuenta.OtherEmail__pc = null;
                                    }
                                    if (cuenta.PersonEmail != null && cuenta.OtherEmail__pc != null && cuenta.PersonEmail == cuenta.OtherEmail__pc){
                                        if (auxAcc.PersonEmail != null && auxAcc.PersonEmail != cuenta.OtherEmail__pc) {
                                               cuenta.OtherEmail__pc = auxAcc.PersonEmail;
                                    	} else {
                                               cuenta.OtherEmail__pc = null;
                                        }
                                    }
                                    if (cuenta.OtherEmail__pc == null && auxAcc.PersonEmail != null && cuenta.PersonEmail != null && auxAcc.PersonEmail != cuenta.PersonEmail){
                                           cuenta.OtherEmail__pc = auxAcc.PersonEmail;
                                    }
                                        
                                    if (cuenta.PersonMobilePhone == null && cuenta.OtherMobilePhone__pc != null ) {
                                           cuenta.PersonMobilePhone = cuenta.OtherMobilePhone__pc;
                                           cuenta.OtherMobilePhone__pc = null;
                                    }
                                    if (cuenta.PersonMobilePhone != null && cuenta.OtherMobilePhone__pc != null && cuenta.PersonMobilePhone == cuenta.OtherMobilePhone__pc){
                                        if (auxAcc.PersonMobilePhone != null && auxAcc.PersonMobilePhone != cuenta.OtherMobilePhone__pc) {
                                               cuenta.OtherMobilePhone__pc = auxAcc.PersonMobilePhone;
                                        } else {
                                               cuenta.OtherMobilePhone__pc = null;
                                        }
                                    }
                                    if (cuenta.OtherMobilePhone__pc == null && auxAcc.PersonMobilePhone != null && cuenta.PersonMobilePhone != null && auxAcc.PersonMobilePhone != cuenta.PersonMobilePhone){
                                           cuenta.OtherMobilePhone__pc = auxAcc.PersonMobilePhone;
                                    }
                                        
                                    if (cuenta.Phone == null && cuenta.PersonOtherPhone != null ) {
                                           cuenta.Phone = cuenta.PersonOtherPhone;
                                           cuenta.PersonOtherPhone = null;
                                    }
                                    if (cuenta.Phone != null && cuenta.PersonOtherPhone != null && cuenta.Phone == cuenta.PersonOtherPhone){
                                           if (auxAcc.Phone != null && auxAcc.Phone != cuenta.PersonOtherPhone) {
                                               cuenta.PersonOtherPhone = auxAcc.Phone;
                                           } else {
                                               cuenta.PersonOtherPhone = null;
                                           }
                                    }
                                    if (cuenta.PersonOtherPhone == null && auxAcc.Phone != null && cuenta.Phone != null && auxAcc.Phone != cuenta.Phone){
                                           cuenta.PersonOtherPhone = auxAcc.Phone;
                                    }
                                        
                                    break; 
                                }
                                else {
                                   new customException('FAIL');
                                }
                            }
                            else {
                                System.debug('NO recordMatch');
                            }
                      } 		
                      else {
                            system.debug('Duplicado con Lead crear registro duplicado: regla:'+ ruleDuplicateDN);
                            system.debug('duplicado:'+  recordDuplicate.getMatchResults()[0].getMatchRecords());
                      }
                 }
            }                                       
        }    
        else {
            System.debug('NO DUPLICATES!');
        }
        
        return cuenta;
    }
    
    public static Boolean isError504TimeOut(String htmlString) {
        string HTML_TAG_PATTERN = '504 Gateway Time-out';
        pattern myPattern = pattern.compile(HTML_TAG_PATTERN);
		matcher myMatcher = myPattern.matcher(htmlString);
        return myMatcher.find();
    }

    @future
    public static void sendExternalEmailFeedback(String JSONCases) {
      List<Case> listaCasos = (List<Case>) JSON.deserialize(JSONCases, List<Case>.class);
      String idsCasos = '';
      for(Case caso :listaCasos){
            idsCasos+=caso.Id+',';
        }
      try{
        Boolean enviado = false;
        Map<String, Case> mapCaseById = new Map<String, Case>();
        Map<String, Centro__c> mapCentroById = new Map<String, Centro__c>();
        Map<String, Campaign> mapCampaignById = new Map<String, Campaign>();
        Map<String, Account> mapAccountById = new Map<String, Account>();
        Map<String, Lead> mapLeadById = new Map<String, Lead>();
        Map<String, Pais__c> mapPaisByName = new Map<String, Pais__c>();
        Map<String, Map<String, CampaignMember>> mapCOrLToCMByCampaignId = new Map<String,Map<String, CampaignMember>>();
        Map<String, Map<String, Cliente_Concesionario__c>> mapClienteConcesionarioByAccountId = new Map<String, Map<String, Cliente_Concesionario__c>>();
       	Map<String, Map<String, Consentimientos__c>> mapConsentimientovalueByLeadId = new Map<String, Map<String, Consentimientos__c>>();
        Map<String, Map<String, Consentimientos__c>> mapConsentimientovalueByAccountDuplicado = new Map<String, Map<String,Consentimientos__c>>();
        Map<String, List<Case>> mapLeadToCases = new Map<String,List<Case>>();
        
        List<String> listConcesionarioId = new List<String>();
        List<String> listCaseSendWithAccount = new List<String>();
        List<String> listCaseSendWithLead = new List<String>();
        List<String> listAccountId = new List<String>();
        List<String> listLeadId = new List<String>();
        List<String> listCentroId = new List<String>();
        List<String> listCampaignId = new List<String>();
        Map<String,String> mapAccountIdDuplicadobyCaseId = new Map<String,String>();
        
        Map<String, Cliente_Concesionario__c> mapCConcesionarioToInsertByCaseId = new Map<String, Cliente_Concesionario__c>();
        Map<String, Account> mapAccountToInsertByCaseId = new Map<String, Account>();
        Map<String, Map<String, CampaignMember>> mapCampaignMemberByCOrLByCampaigIdToInsert = new Map<String, Map<String,CampaignMember>>();
        List<Case> listCaseToUpdate = new List<Case>();
        List<CampaignMember> listCampaignMemberToDelete = new List<CampaignMember>();
        Map<String, Messaging.SingleEmailMessage> mapCasoMessaging = new Map<String, Messaging.SingleEmailMessage>();
        Map<String, Case> mapCaaseToUpdateEmail = new Map<String, Case>();
        EmailTemplate et = [SELECT Id, Subject FROM EmailTemplate WHERE Name = 'Feedback_Asesores'];
        
        for (Case caso : listaCasos) {
            mapCaseById.put(caso.Id, caso);

            if (caso.AccountId != null) {
                listCaseSendWithAccount.add(caso.id);
                listAccountId.add(caso.AccountId);
            }
        }
        
        //Asociado con cliente
        if (!listAccountId.isEmpty()) {
            mapAccountById = AccountGateway.getAccountById(listAccountId);
            
            for (String idCaso : listCaseSendWithAccount) {
                Case caso = mapCaseById.get(idCaso);
                Account cuenta = caso.AccountId != null && mapAccountById.containsKey(caso.AccountId) ? mapAccountById.get(caso.AccountId) : null;
                
                Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id,null , caso.Id);
                switch on caso.Marca__c {
                  when 'DUCATI'{mail.setOrgWideEmailAddressId(Label.FromEmailDucati);}
                  when else {mail.setOrgWideEmailAddressId(Label.FromEmailOPP);}
                }

				List<String> sendTo = new List<String>();                
                switch on caso.Marca__c {
                  when 'DUCATI'{sendTo = caso.SalesmanEmail__c.split(';');}
                  when else {sendTo = caso.SacEmail__c.split(';');}
                }
        		mail.setToAddresses(sendTo);
                //mail.setSubject('Account or Lead created');
        		//mail.setTemplateId(et.Id);
        		//mail.setWhatId(caso.Id);
        		mail.setSaveAsActivity(true);
                mapCasoMessaging.put(caso.Id, mail);
                mapCaseById.put(caso.Id, caso);
        		    
            }
        }
        
        //Envio de emails 
        if (!mapCasoMessaging.isEmpty()) {
            system.debug('envio de emails:'+ mapCasoMessaging );
            Messaging.SendEmailResult[] emailSent = Messaging.sendEmail(mapCasoMessaging.values());
            
            if (emailSent[0].isSuccess()) {
               enviado = true;
            }
        }
        
        //Si se ha enviado 
        if (enviado) {
        
            for (String idCaso : mapCaseById.keySet()) {
            	Case caso = mapCaseById.get(idCaso);
            	system.debug('case:'+ caso);
            	system.debug('mapAccountToInsertByCaseId:'+ mapAccountToInsertByCaseId);
                if (caso.Marca__c == 'HONDA' || 
                    caso.Marca__c == 'HONDA MOTOS' || 
                    caso.Marca__c == 'CITROËN') {
                    caso.Status = Label.StatusClosed;
                    caso.Motivo_de_cierre__c = Label.motivoCierreDerivadoSac;
                        
                    listCaseToUpdate.add(caso);
                } else if (caso.Marca__c == 'DUCATI') {
                    caso.Status = Label.StatusClosed;
                    caso.Motivo_de_cierre__c = Label.motivoCierreDerivadoAsesor;
                        
                    listCaseToUpdate.add(caso);
                }
        	}
            
        	system.debug('listCaseToUpdate:'+ listCaseToUpdate);
            
        	if (!listCaseToUpdate.isEmpty()) {
            	Update listCaseToUpdate;
        	}
            
		}
        }catch(Exception e){
         Exception__c exc = new Exception__c ();
         exc.idObjetos__c = idsCasos.length()>254?idsCasos.substring(0, 254):idsCasos;
         exc.Exception__c = e.getCause() + '// '+ e.getMessage();
         exc.Linea__c = e.getLineNumber();
         exc.Clase_Metodo__c = 'ExternalServiceController.sendExternalEmailFeedbaack';
         insert exc;
     }   
    }

    @future
    public static void sendExternalEmailATTCliente(String JSONCases) {
      List<Case> listaCasos = (List<Case>) JSON.deserialize(JSONCases, List<Case>.class);
      String idsCasos = '';
      for(Case caso :listaCasos){
            idsCasos+=caso.Id+',';
        }
      try{
        Boolean enviado = false;
        Map<String, Case> mapCaseById = new Map<String, Case>();
        Map<String, Centro__c> mapCentroById = new Map<String, Centro__c>();
        Map<String, Campaign> mapCampaignById = new Map<String, Campaign>();
        Map<String, Account> mapAccountById = new Map<String, Account>();
        Map<String, Lead> mapLeadById = new Map<String, Lead>();
        Map<String, Pais__c> mapPaisByName = new Map<String, Pais__c>();
        Map<String, Map<String, CampaignMember>> mapCOrLToCMByCampaignId = new Map<String,Map<String, CampaignMember>>();
        Map<String, Map<String, Cliente_Concesionario__c>> mapClienteConcesionarioByAccountId = new Map<String, Map<String, Cliente_Concesionario__c>>();
       	Map<String, Map<String, Consentimientos__c>> mapConsentimientovalueByLeadId = new Map<String, Map<String, Consentimientos__c>>();
        Map<String, Map<String, Consentimientos__c>> mapConsentimientovalueByAccountDuplicado = new Map<String, Map<String,Consentimientos__c>>();
        Map<String, List<Case>> mapLeadToCases = new Map<String,List<Case>>();
        
        List<String> listConcesionarioId = new List<String>();
        List<String> listCaseSendWithAccount = new List<String>();
        List<String> listCaseSendWithLead = new List<String>();
        List<String> listAccountId = new List<String>();
        List<String> listLeadId = new List<String>();
        List<String> listCentroId = new List<String>();
        List<String> listCampaignId = new List<String>();
        Map<String,String> mapAccountIdDuplicadobyCaseId = new Map<String,String>();
        
        Map<String, Cliente_Concesionario__c> mapCConcesionarioToInsertByCaseId = new Map<String, Cliente_Concesionario__c>();
        Map<String, Account> mapAccountToInsertByCaseId = new Map<String, Account>();
        Map<String, Map<String, CampaignMember>> mapCampaignMemberByCOrLByCampaigIdToInsert = new Map<String, Map<String,CampaignMember>>();
        List<Case> listCaseToUpdate = new List<Case>();
        List<CampaignMember> listCampaignMemberToDelete = new List<CampaignMember>();
        Map<String, Messaging.SingleEmailMessage> mapCasoMessaging = new Map<String, Messaging.SingleEmailMessage>();
        Map<String, Case> mapCaaseToUpdateEmail = new Map<String, Case>();
        Map<String, EmailTemplate> mapEmailTemplate = new Map<String, EmailTemplate>();
        
        for (EmailTemplate et : [SELECT Name, Id, Subject FROM EmailTemplate WHERE Name IN ('RespuestaATTClenteHY',
																							'RespuestaATTClenteDucati',
																							'RespuestaATTClenteAudi',
																							'RespuestaATTClenteSK',
																							'RespuestaATTClenteVWT')]){
            mapEmailTemplate.put(et.Name, et);
        }

          
        for (Case caso : listaCasos) {
            mapCaseById.put(caso.Id, caso);
            listCaseSendWithAccount.add(caso.id);
        }
        
        //Asociado con cliente
        if (!listCaseSendWithAccount.isEmpty()) {
            
            for (String idCaso : listCaseSendWithAccount) {
                Case caso = mapCaseById.get(idCaso);
                EmailTemplate et;
                switch on caso.Marca__c {
                  when 'AUDI'{et = mapEmailTemplate.get('RespuestaATTClenteAudi');}
                  when 'SKODA'{et = mapEmailTemplate.get('RespuestaATTClenteSK');}
                  when 'VOLKSWAGEN'{et = mapEmailTemplate.get('RespuestaATTClenteVWT');}
                  when 'VW COMERCIALES'{et = mapEmailTemplate.get('RespuestaATTClenteVWT');}
                  when 'HYUNDAI'{et = mapEmailTemplate.get('RespuestaATTClenteHY');}
                  when 'DUCATI'{et = mapEmailTemplate.get('RespuestaATTClenteDucati');}
                  when else {continue;}
                }

                Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id,null , caso.Id);
                mail.setHtmlBody(mail.getHtmlBody() + caso.Referencia_Email__c);
                switch on caso.Marca__c {
                  when 'AUDI'{mail.setOrgWideEmailAddressId(Label.FromEmailAudiATTCliente);}
                  when 'SKODA'{mail.setOrgWideEmailAddressId(Label.FromEmailSkodaATTCliente);}
                  when 'VOLKSWAGEN'{mail.setOrgWideEmailAddressId(Label.FromEmailVWTATTCliente);}
                  when 'VW COMERCIALES'{mail.setOrgWideEmailAddressId(Label.FromEmailVWTATTCliente);}
                  when 'HYUNDAI'{mail.setOrgWideEmailAddressId(Label.FromEmailHyundaiATTCliente);}
                  when 'DUCATI'{mail.setOrgWideEmailAddressId(Label.FromEmailDucatiATTCliente);}
                  when else {continue;}
                }

				List<String> sendTo = new List<String>();                
                sendTo.add(caso.SuppliedEmail);
        		mail.setToAddresses(sendTo);
        		mail.setSaveAsActivity(true);
                mapCasoMessaging.put(caso.Id, mail);
                mapCaseById.put(caso.Id, caso);
        		    
            }
        }
        
        //Envio de emails 
        if (!mapCasoMessaging.isEmpty()) {
            system.debug('envio de emails:'+ mapCasoMessaging );
            Messaging.SendEmailResult[] emailSent = Messaging.sendEmail(mapCasoMessaging.values());
            
            system.debug('emailSent[0].isSuccess(): ' + emailSent[0].isSuccess());
            if (emailSent[0].isSuccess()) {
               enviado = true;
            }
            
	    }
        //Si se ha enviado 
        if (enviado) {
        
            for (String idCaso : mapCaseById.keySet()) {
            	Case caso = mapCaseById.get(idCaso);
            	system.debug('case:'+ caso);
                caso.DateTimeFirstSend__c = datetime.now();
                listCaseToUpdate.add(caso);
        	}
            
        	system.debug('listCaseToUpdate:'+ listCaseToUpdate);
            
        	if (!listCaseToUpdate.isEmpty()) {
            	Update listCaseToUpdate;
        	}

	    }

            
        }catch(Exception e){
         Exception__c exc = new Exception__c ();
         exc.idObjetos__c = idsCasos.length()>254?idsCasos.substring(0, 254):idsCasos;
         exc.Exception__c = e.getCause() + '// '+ e.getMessage();
         exc.Linea__c = e.getLineNumber();
         exc.Clase_Metodo__c = 'ExternalServiceController.sendExternalEmailATTCliente';
         insert exc;
     }   
    }
    
    @future
    public static void sendExternalEmailXtravansDiario(String JSONCases) {
      List<Case> listaCasos = (List<Case>) JSON.deserialize(JSONCases, List<Case>.class);
      String idsCasos = '';
      for(Case caso :listaCasos){
            idsCasos+=caso.Id+',';
        }
      try{
        Boolean enviado = false;
        Map<String, Case> mapCaseById = new Map<String, Case>();
        Map<String, Centro__c> mapCentroById = new Map<String, Centro__c>();
        Map<String, Campaign> mapCampaignById = new Map<String, Campaign>();
        Map<String, Account> mapAccountById = new Map<String, Account>();
        Map<String, Lead> mapLeadById = new Map<String, Lead>();
        Map<String, Pais__c> mapPaisByName = new Map<String, Pais__c>();
        Map<String, Map<String, CampaignMember>> mapCOrLToCMByCampaignId = new Map<String,Map<String, CampaignMember>>();
        Map<String, Map<String, Cliente_Concesionario__c>> mapClienteConcesionarioByAccountId = new Map<String, Map<String, Cliente_Concesionario__c>>();
       	Map<String, Map<String, Consentimientos__c>> mapConsentimientovalueByLeadId = new Map<String, Map<String, Consentimientos__c>>();
        Map<String, Map<String, Consentimientos__c>> mapConsentimientovalueByAccountDuplicado = new Map<String, Map<String,Consentimientos__c>>();
        Map<String, List<Case>> mapLeadToCases = new Map<String,List<Case>>();
        
        List<String> listConcesionarioId = new List<String>();
        List<String> listCaseSendWithAccount = new List<String>();
        List<String> listCaseSendWithLead = new List<String>();
        List<String> listAccountId = new List<String>();
        List<String> listLeadId = new List<String>();
        List<String> listCentroId = new List<String>();
        List<String> listCampaignId = new List<String>();
        Map<String,String> mapAccountIdDuplicadobyCaseId = new Map<String,String>();
        
        Map<String, Cliente_Concesionario__c> mapCConcesionarioToInsertByCaseId = new Map<String, Cliente_Concesionario__c>();
        Map<String, Account> mapAccountToInsertByCaseId = new Map<String, Account>();
        Map<String, Map<String, CampaignMember>> mapCampaignMemberByCOrLByCampaigIdToInsert = new Map<String, Map<String,CampaignMember>>();
        List<Case> listCaseToUpdate = new List<Case>();
        List<CampaignMember> listCampaignMemberToDelete = new List<CampaignMember>();
        Map<String, Messaging.SingleEmailMessage> mapCasoMessaging = new Map<String, Messaging.SingleEmailMessage>();
        Map<String, Case> mapCaaseToUpdateEmail = new Map<String, Case>();
        EmailTemplate et = [SELECT Id, Subject FROM EmailTemplate WHERE Name = 'PropuestaXtravansDiario'];
        
        for (Case caso : listaCasos) {
            mapCaseById.put(caso.Id, caso);
            listCaseSendWithAccount.add(caso.id);
        }
        
        //Asociado con cliente
        if (!listCaseSendWithAccount.isEmpty()) {
            
            for (String idCaso : listCaseSendWithAccount) {
                Case caso = mapCaseById.get(idCaso);
                
                Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id,null , caso.Id);
                mail.setHtmlBody(mail.getHtmlBody() + caso.Referencia_Email__c);
                mail.setOrgWideEmailAddressId(Label.FromEmailXtravans);
                List<String> sendTo = new List<String>();
                if (!String.isBlank(caso.SuppliedEmail) && !String.isEmpty(caso.SuppliedEmail)) {
                    sendTo.add(caso.SuppliedEmail);
                }
        		mail.setToAddresses(sendTo);
        		mail.setSaveAsActivity(true);
                if (!sendTo.isEmpty()){
	                mapCasoMessaging.put(caso.Id, mail);
	                mapCaseById.put(caso.Id, caso);
                }
        		    
            }
        }
        
        //Envio de emails 
        if (!mapCasoMessaging.isEmpty()) {
            system.debug('envio de emails:'+ mapCasoMessaging );
            Messaging.SendEmailResult[] emailSent = Messaging.sendEmail(mapCasoMessaging.values());
            
            if (emailSent[0].isSuccess()) {
               enviado = true;
            }
        }
        
        //Si se ha enviado 
        if (enviado) {
        
            for (String idCaso : mapCaseById.keySet()) {
            	Case caso = mapCaseById.get(idCaso);
            	system.debug('case:'+ caso);
            	system.debug('mapAccountToInsertByCaseId:'+ mapAccountToInsertByCaseId);
            	caso.Status = Label.StatusPropuestaEnviada;
                
            	listCaseToUpdate.add(caso);
        	}
            
        	system.debug('listCaseToUpdate:'+ listCaseToUpdate);
            
        	if (!listCaseToUpdate.isEmpty()) {
            	Update listCaseToUpdate;
        	}
            
		}
        }catch(Exception e){
         Exception__c exc = new Exception__c ();
         exc.idObjetos__c = idsCasos.length()>254?idsCasos.substring(0, 254):idsCasos;
         exc.Exception__c = e.getCause() + '// '+ e.getMessage();
         exc.Linea__c = e.getLineNumber();
         exc.Clase_Metodo__c = 'ExternalServiceController.sendExternalEmailXtravansDiario';
         insert exc;
     }   
    }

    @future 
    public static void sendExternalEmailXtravansVehicleDelivered(String JSONCases) {
        
      List<Contrato_renting_vehiculo__c> listaContratosRentingV = (List<Contrato_renting_vehiculo__c>) JSON.deserialize(JSONCases, List<Contrato_renting_vehiculo__c>.class);
      String idsContratoRentingVehiculo = '';
      for(Contrato_renting_vehiculo__c ContratoRentingVehiculo: listaContratosRentingV){
            idsContratoRentingVehiculo+=ContratoRentingVehiculo.Id+',';
        }
      try{
        Boolean enviado = false;
        Map<String, Contrato_renting_vehiculo__c> mapContratoRentingVehiculoById = new Map<String, Contrato_renting_vehiculo__c>();
        
        List<String> listContratoRentingVehiculoSendWithAccount = new List<String>();

        List<Contrato_renting__c> listContratoRentingToUpdate = new List<Contrato_renting__c>();
          
        Map<String, Messaging.SingleEmailMessage> mapContratoRentingVehiculoMessaging = new Map<String, Messaging.SingleEmailMessage>();
        EmailTemplate et = [SELECT Id, Subject FROM EmailTemplate WHERE Name = 'MantenimientoAccidenteXtravans'];
        
        for (Contrato_renting_vehiculo__c ContratoRentingVehiculo :listaContratosRentingV) {
            mapContratoRentingVehiculoById.put(ContratoRentingVehiculo.Id, ContratoRentingVehiculo);
            listContratoRentingVehiculoSendWithAccount.add(ContratoRentingVehiculo.id);
        }
        
        //Asociado con cliente
        if (!listContratoRentingVehiculoSendWithAccount.isEmpty()) {
            
            for (String idContratoRentingVehiculo : listContratoRentingVehiculoSendWithAccount) {
                Contrato_renting_vehiculo__c ContratoRentingVehiculo = mapContratoRentingVehiculoById.get(idContratoRentingVehiculo);
                
                Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id,null , ContratoRentingVehiculo.Contrato_Marco__c);
                mail.setHtmlBody(mail.getHtmlBody());
                mail.setOrgWideEmailAddressId(Label.FromEmailXtravans);
                List<String> sendTo = new List<String>();
                if (!String.isBlank(ContratoRentingVehiculo.Email_envio__c) && !String.isEmpty(ContratoRentingVehiculo.Email_envio__c)) {
                    sendTo.add(ContratoRentingVehiculo.Email_envio__c);
                }
        		mail.setToAddresses(sendTo);
        		mail.setSaveAsActivity(true);
                if (!sendTo.isEmpty()){
	                mapContratoRentingVehiculoMessaging.put(ContratoRentingVehiculo.Id, mail);
                    mapContratoRentingVehiculoById.put(ContratoRentingVehiculo.Id, ContratoRentingVehiculo);
                }
        		    
            }
        }
        
        //Envio de emails 
        if (!mapContratoRentingVehiculoMessaging.isEmpty()) {
            system.debug('envio de emails:'+ mapContratoRentingVehiculoMessaging );
            Messaging.SendEmailResult[] emailSent = Messaging.sendEmail(mapContratoRentingVehiculoMessaging.values());
            
            if (emailSent[0].isSuccess()) {
               enviado = true;
            }
        }
        
        //Si se ha enviado 
        if (enviado) {
        
            for (String idContratoRentingVehiculo : mapContratoRentingVehiculoById.keySet()) {
            	Contrato_renting_vehiculo__c ContratoRentingVehiculo = mapContratoRentingVehiculoById.get(idContratoRentingVehiculo);
                Contrato_renting__c ContratoRenting = new Contrato_renting__c();
                ContratoRenting.id = ContratoRentingVehiculo.Contrato_Marco__c;
                ContratoRenting.Fecha_envio__c = date.today();
                
            	listContratoRentingToUpdate.add(ContratoRenting);
        	}
            
        	system.debug('listContratoRentingToUpdate:'+ listContratoRentingToUpdate);
            
        	if (!listContratoRentingToUpdate.isEmpty()) {
            	Update listContratoRentingToUpdate;
        	}
            
		}
          
        }catch(Exception e){
         Exception__c exc = new Exception__c ();
         exc.idObjetos__c = idsContratoRentingVehiculo.length()>254?idsContratoRentingVehiculo.substring(0, 254):idsContratoRentingVehiculo;
         exc.Exception__c = e.getCause() + '// '+ e.getMessage();
         exc.Linea__c = e.getLineNumber();
         exc.Clase_Metodo__c = 'ExternalServiceController.sendExternalEmailXtravansDiario';
         insert exc;
     }   
    }
    
}