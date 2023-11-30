public class ExternalCustomerServiceController {
    /*
    @future(callout=true)
    public static void createExternalLeadOrAccountMulesoft(String JSONCases, String JSONgLead) {
        List<Case> listaCasos = (List<Case>) JSON.deserialize(JSONCases, List<Case>.class);
        Gestion_Lead__c gLead = (Gestion_Lead__c) JSON.deserialize(JSONgLead, Gestion_Lead__c.class);
        String emailAsesor = '';
        
        Map<String, Case> mapCaseById = new Map<String, Case>();
        Map<String, Centro__c> mapCentroById = new Map<String, Centro__c>();
        Map<String, Campaign> mapCampaignById = new Map<String, Campaign>();
        Map<String, Account> mapAccountById = new Map<String, Account>();
        Map<String, Lead> mapLeadById = new Map<String, Lead>();
        Map<String, Pais__c> mapPaisByName = new Map<String, Pais__c>();
        Map<String, Cliente_Concesionario__c> mapClienteConcesionarioByAccountId = new Map<String, Cliente_Concesionario__c>();
       	Map<String, Map<String,Consentimientos__c>> mapConsentimientovalueByLeadId = new Map<String, Map<String,Consentimientos__c>>();
        Map<String, ResponseApi> mapCaseIdToResponse = new Map<String, ResponseApi>(); 
        
        List<String> listConcesionarioIdSima = new List<String>();
        List<String> listCaseSendWithAccount = new List<String>();
        List<String> listCaseSendWithLead = new List<String>();
        List<String> listAccountId = new List<String>();
        List<String> listLeadId = new List<String>();
        List<String> listCentroId = new List<String>();
        List<String> listCampaignId = new List<String>();
        //List<String> listAccountIDu
        
        Map<String,Cliente_Concesionario__c> mapCConcesionarioToInsertByCaseId = new Map<String,Cliente_Concesionario__c>();
        Map<String,Account> mapAccountToInsertByCaseId = new Map<String,Account>();
        List<Consentimientos__c> listConsentimientoToUpdate = new List<Consentimientos__c>();
        List<Case> listCaseToUpdate = new List<Case>();
        List<Lead> listLeadToDelete = new List<Lead>();
        
        
        for (Case caso : listaCasos) {
            mapCaseById.put(caso.Id, caso);
            
            if (caso.Centro__c != null) {
                listCentroId.add(caso.Centro__c);
            }
            
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
        
        //Centro 
        if (!listCentroId.isEmpty()) {
			system.debug('centro:'+ listCentroId);            
        	mapCentroById =  CentroGateway.getCenterById(listCentroId);
           
            for(Centro__c centro : mapCentroById.values()){
                if(!String.isBlank(centro.Concesionario__r.Id_Concesionario_Sima__c) && !listConcesionarioIdSima.contains(centro.Concesionario__r.Id_Concesionario_Sima__c)){
                    listConcesionarioIdSima.add(centro.Concesionario__r.Id_Concesionario_Sima__c);
                    system.debug('listaConcesionario:'+ listConcesionarioIdSima);
                }
            }
        }
        
        //Campaign
        if (!listCampaignId.isEmpty()) {
            mapCampaignById = CampaignGateway.getCampaignById(listCampaignId);
        }
            
        //Asesor
        if (gLead.Asesor__c != null) {
            User asesor = UserGateway.getUserById(gLead.Asesor__c);
            emailAsesor = asesor.Email;
        }
        
        //Asociado con cliente
        if (!listAccountId.isEmpty()) {
            mapAccountById = AccountGateway.getAccountById(listAccountId);
            
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
                                                            	AND Concesionario__r.Id_Concesionario_Sima__c in :listConcesionarioIdSima]) {
                if (!mapClienteConcesionarioByAccountId.containsKey(cConcesionario.Cliente__c)) {
                    mapClienteConcesionarioByAccountId.put(cConcesionario.Cliente__c, cConcesionario);
                }
            }
            
            for (String idCaso : listCaseSendWithAccount) {
                ExternalCustomerApiModel.CustomerApi externalCustomerApi = new ExternalCustomerApiModel.CustomerApi();
                ExternalLeadApiModel.LeadApi externalLeadApi = new ExternalLeadApiModel.LeadApi();
                Case caso = mapCaseById.get(idCaso);
                Centro__c centro = caso.Centro__c != null && mapCentroById.containsKey(caso.Centro__c) ? mapCentroById.get(caso.Centro__c) : null;
                Campaign campania = caso.Campana__c != null && mapCampaignById.containsKey(caso.Campana__c) ? mapCampaignById.get(caso.Campana__c) : null;
                Account cuenta = caso.AccountId != null && mapAccountById.containsKey(caso.AccountId) ? mapAccountById.get(caso.AccountId) : null;
                
                if (mapClienteConcesionarioByAccountId.containsKey(caso.AccountId)) {
                    //Existe cliente Concesionario con ese concesionario
                    Cliente_Concesionario__c cConcesionario = mapClienteConcesionarioByAccountId.get(caso.AccountId);
                    externalLeadApi = createExternalLead(caso, centro, campania, cConcesionario.Id_Cliente_DMS__c, emailAsesor);
                    ResponseApi respuesta = ExternalCustomerServiceCallout.createLeadApiCallout(externalLeadApi);
                    mapCaseIdToResponse.put(caso.Id, respuesta);
                }
                else {
                    //No existe cliente concesionario con ese companyId a ese cliente.
                    externalCustomerApi = createExternalCustomer(caso, centro, cuenta, null, mapPaisByName);
                    //enviar creación de cliente
                    ResponseApi respuestaCustomer = ExternalCustomerServiceCallout.createAccountApiCallout(externalCustomerApi);
                    
                    if (respuestaCustomer.Status.equalsIgnoreCase('OK')) {
                        externalLeadApi = createExternalLead(caso, centro, campania, respuestaCustomer.Message, emailAsesor);
                    	ResponseApi respuesta = ExternalCustomerServiceCallout.createLeadApiCallout(externalLeadApi);
                        mapCaseIdToResponse.put(caso.Id, respuesta);
                        
                        Cliente_Concesionario__c cConcesionarioToInsert = createCconcesionario(cuenta, respuestaCustomer.Message, centro.Concesionario__c);
                        mapCConcesionarioToInsertByCaseId.put(caso.Id, cConcesionarioToInsert);
                    }
                    else {
                       mapCaseIdToResponse.put(caso.Id, respuestaCustomer);
                   }
               	}
            }
        }
        
        //Asociado con lead
        if (!listLeadId.isEmpty()) {
            mapConsentimientovalueByLeadId = ConsentimientosGateway.getConsentimientosByLeadId(listLeadId);
            mapLeadById = LeadGateway.getLeadIdByIds(listLeadId);
            
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
                Case caso = mapCaseById.get(idCaso);
                Centro__c centro = caso.Centro__c != null && mapCentroById.containsKey(caso.Centro__c) ? mapCentroById.get(caso.Centro__c) : null;
                Campaign campania = caso.Campana__c != null && mapCampaignById.containsKey(caso.Campana__c) ? mapCampaignById.get(caso.Campana__c) : null;
                Lead candidato = caso.Lead__c != null && mapLeadById.containsKey(caso.Lead__c) ? mapLeadById.get(caso.Lead__c) : null;
            	
                externalCustomerApi = createExternalCustomer(caso, centro, null, candidato, mapPaisByName);
                ResponseApi respuestaCustomer = ExternalCustomerServiceCallout.createAccountApiCallout(externalCustomerApi);
                
                if (respuestaCustomer.Status.equalsIgnoreCase('OK')) {
                	externalLeadApi = createExternalLead(caso, centro, campania, respuestaCustomer.Message, emailAsesor);
                    ResponseApi respuesta = ExternalCustomerServiceCallout.createLeadApiCallout(externalLeadApi);
                    mapCaseIdToResponse.put(caso.Id, respuesta);
                    
                    Account cuenta = createAccount(candidato, caso, mapPaisByName);
                    if(!String.isBlank(cuenta.Id)){
                       Cliente_Concesionario__c cConcesionarioToInsert = createCconcesionario(cuenta, respuestaCustomer.Message, centro.Concesionario__c);
                       mapCConcesionarioToInsertByCaseId.put(caso.Id,cConcesionarioToInsert); 
                       caso.AccountId = cuenta.Id;
                       mapCaseById.put(caso.Id,caso);
                    }
                    else{
                       mapAccountToInsertByCaseId.put(caso.Id,cuenta);
                       Cliente_Concesionario__c cConcesionarioToInsert = createCconcesionario(null, respuestaCustomer.Message, centro.Concesionario__c);
                       mapCConcesionarioToInsertByCaseId.put(caso.Id,cConcesionarioToInsert);
                    }
                    if(respuesta.Status.equalsIgnoreCase('OK')){
                        listLeadToDelete.add(candidato);
                    }
                    
                    
                 }
                else {
                     ResponseApi respuesta = new ResponseApi();
                     mapCaseIdToResponse.put(caso.Id, respuestaCustomer);
                }
         	}   
        }
        
        //Creamos Cuenta
        Map<String, Contact> mapContactByAccountId = new Map<String,Contact>();
        if(!mapAccountToInsertByCaseId.isEmpty()){
            Insert mapAccountToInsertByCaseId.values();
            system.debug('insertar: mapAccountToInsertByCaseId'+ mapAccountToInsertByCaseId);
            //Para el consentimiento
            List<String> listCuentaId = new List<String>();
            for(Account cuenta:mapAccountToInsertByCaseId.values()){
                listCuentaId.add(cuenta.Id);
            }
            if(!listCuentaId.isEmpty()){
                mapContactByAccountId = ContactGateway.getContactByAccountId(listCuentaId);
            }
            
            for(String caseId :mapAccountToInsertByCaseId.keySet()){
                Account cuenta = mapAccountToInsertByCaseId.get(caseId);
                //Cliente concesionario
                Cliente_Concesionario__c cConcesionario = mapCConcesionarioToInsertByCaseId.get(caseId);
                cConcesionario.Cliente__c = cuenta.Id;
                mapCConcesionarioToInsertByCaseId.put(caseId,cConcesionario);
                
                //Para el consentimiento
                Case caso = mapCaseById.get(caseId);
                if(!String.isBlank(caso.Lead__c) && mapConsentimientovalueByLeadId.containsKey(caso.Lead__c)){
                    Map<String,Consentimientos__c> mapConsentimientoByValue = mapConsentimientovalueByLeadId.get(caso.Lead__c);
                    for(Consentimientos__c consentimiento :mapConsentimientoByValue.values()){
                        consentimiento.Contact__c = mapContactByAccountId.get(cuenta.Id).Id;
                        consentimiento.Lead__c = null;
                        listConsentimientoToUpdate.add(consentimiento);
                    }
                    
                }
                    
             }
            
        }
		//Creamos cliente Concesionario
        if(!mapCConcesionarioToInsertByCaseId.isEmpty()){
            Insert mapCConcesionarioToInsertByCaseId.values();
        }
        
        //Actualizamos consentimientos
        if(!listConsentimientoToUpdate.isEmpty()){
            UPDATE listConsentimientoToUpdate;
        }
        
        
        //Actualización del caso y asociamos el caso a la cuenta cuando es lead
        system.debug('Antes de la modificacion del caso');
        for (String idCaso :mapCaseIdToResponse.keySet()) {
            Case caso = mapCaseById.get(idCaso);
            caso.Id = idCaso;
            ResponseApi respuesta = mapCaseIdToResponse.get(idCaso);
            system.debug('case:'+ caso);
            system.debug('mapAccountToInsertByCaseId:'+ mapAccountToInsertByCaseId);
            caso.EnvioMulesoft__c = respuesta.Status.equalsIgnoreCase('OK')?respuesta.Status:'Error';
            caso.Error_Mulesoft__c = respuesta.Message.length() > 255 ? respuesta.Message.substring(0, 255) : respuesta.Message;
            if(!String.isBlank(caso.Lead__c) && mapAccountToInsertByCaseId.containsKey(idCaso) ){
                caso.AccountId = mapAccountToInsertByCaseId.get(idCaso).id;
                caso.ContactId = caso.AccountId != null && mapContactByAccountId.containsKey(caso.AccountId)?mapContactByAccountId.get(caso.AccountId).Id:null;
                caso.Lead__c = null;
            }
            system.debug('casoo a actualizar:caso'+ caso);
            system.debug('casoo a actualizar:Account'+ caso.AccountId);
            listCaseToUpdate.add(caso);
        }
        system.debug('listCaseToUpdate:'+ listCaseToUpdate);
        if(!listCaseToUpdate.isEmpty()){
            Update listCaseToUpdate;
        }
        
        //Eliminamos Lead
        if(!listLeadToDelete.isEmpty()){
            delete listLeadToDelete;
        }
    }
    
    public static void createExternalLeadOrAccountMulesoftSec(String JSONCases, String JSONgLead) {
        Case caso = (Case) JSON.deserialize(JSONCases, Case.class);
        Gestion_Lead__c gLead = (Gestion_Lead__c) JSON.deserialize(JSONgLead, Gestion_Lead__c.class);
        String emailAsesor = '';
        
        Map<String, Case> mapCaseById = new Map<String, Case>();
        Map<String, Centro__c> mapCentroById = new Map<String, Centro__c>();
        Map<String, Campaign> mapCampaignById = new Map<String, Campaign>();
        Map<String, Account> mapAccountById = new Map<String, Account>();
        Map<String, Lead> mapLeadById = new Map<String, Lead>();
        Map<String, Pais__c> mapPaisByName = new Map<String, Pais__c>();
        Map<String, Cliente_Concesionario__c> mapClienteConcesionarioByAccountId = new Map<String, Cliente_Concesionario__c>();
       	
        Map<String, ResponseApi> mapCaseIdToResponse = new Map<String, ResponseApi>(); 
        
        List<String> lstConcesionarioIdSima = new List<String>();
        List<String> lstCaseSendWithAccount = new List<String>();
        List<String> lstCaseSendWithLead = new List<String>();
        List<String> lstAccountId = new List<String>();
        List<String> lstLeadId = new List<String>();
        List<String> lstCentroId = new List<String>();
        List<String> lstCampaignId = new List<String>();
        
        Map<String, Cliente_Concesionario__c> mapCConcesionarioToInsertByCaseId = new Map<String,Cliente_Concesionario__c>();
        Map<String, Account> mapAccountToInsertByCaseId = new Map<String,Account>();
        List<Case> listCaseToUpdate = new List<Case>();
        
        
        mapCaseById.put(caso.Id, caso);
        
        // Center
        if (caso.Centro__c != null) {
            lstCentroId.add(caso.Centro__c);
            System.debug('CENTRO: ' + lstCentroId);
            mapCentroById = CentroGateway.getCenterById(lstCentroId);
            
            for (Centro__c centro : mapCentroById.values()) {
                if(!String.isBlank(centro.Concesionario__r.Id_Concesionario_Sima__c) && !lstConcesionarioIdSima.contains(centro.Concesionario__r.Id_Concesionario_Sima__c)) {
                    lstConcesionarioIdSima.add(centro.Concesionario__r.Id_Concesionario_Sima__c);
                    system.debug('lstaConcesionario:'+ lstConcesionarioIdSima);
                }
            }
        }
        
        // Campaign
        if (caso.Campana__c != null) {
            lstCampaignId.add(caso.Campana__c);
            mapCampaignById = CampaignGateway.getCampaignById(lstCampaignId);
        }
        
        if (caso.AccountId != null) {
        	lstCaseSendWithAccount.add(caso.Id);
            lstAccountId.add(caso.AccountId);
        }
        else if (caso.Lead__c != null) {
        	lstCaseSendWithLead.add(caso.Id);
            lstLeadId.add(caso.Lead__c);
        }
         
        //Asesor
        if (gLead.Asesor__c != null) {
            User asesor = UserGateway.getUserById(gLead.Asesor__c);
            emailAsesor = asesor.Email;
        }
        /*
        //Asociado con cliente
        if (!lstAccountId.isEmpty()) {
            mapAccountById = AccountGateway.getAccountById(lstAccountId);
            
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
                                                            	AND Concesionario__r.Id_Concesionario_Sima__c in :listConcesionarioIdSima]) {
                if (!mapClienteConcesionarioByAccountId.containsKey(cConcesionario.Cliente__c)) {
                    mapClienteConcesionarioByAccountId.put(cConcesionario.Cliente__c, cConcesionario);
                }
            }
            
            for (String idCaso : listCaseSendWithAccount) {
                ExternalCustomerApiModel.CustomerApi externalCustomerApi = new ExternalCustomerApiModel.CustomerApi();
                ExternalLeadApiModel.LeadApi externalLeadApi = new ExternalLeadApiModel.LeadApi();
                Case caso = mapCaseById.get(idCaso);
                Centro__c centro = caso.Centro__c != null && mapCentroById.containsKey(caso.Centro__c) ? mapCentroById.get(caso.Centro__c) : null;
                Campaign campania = caso.Campana__c != null && mapCampaignById.containsKey(caso.Campana__c) ? mapCampaignById.get(caso.Campana__c) : null;
                Account cuenta = caso.AccountId != null && mapAccountById.containsKey(caso.AccountId) ? mapAccountById.get(caso.AccountId) : null;
                
                if (mapClienteConcesionarioByAccountId.containsKey(caso.AccountId)) {
                    //Existe cliente Concesionario con ese concesionario
                    Cliente_Concesionario__c cConcesionario = mapClienteConcesionarioByAccountId.get(caso.AccountId);
                    externalLeadApi = createExternalLead(caso, centro, campania, cConcesionario.Id_Cliente_DMS__c, emailAsesor);
                    ResponseApi respuesta = ExternalCustomerServiceCallout.createLeadApiCallout(externalLeadApi);
                    mapCaseIdToResponse.put(caso.Id, respuesta);
                }
                else {
                    //No existe cliente concesionario con ese companyId a ese cliente.
                    externalCustomerApi = createExternalCustomer(caso, centro, cuenta, null, mapPaisByName);
                    //enviar creación de cliente
                    ResponseApi respuestaCustomer = ExternalCustomerServiceCallout.createAccountApiCallout(externalCustomerApi);
                    if(respuestaCustomer.Status.equalsIgnoreCase('OK')){
                        externalLeadApi = createExternalLead(caso, centro, campania, respuestaCustomer.Message, emailAsesor);
                    	ResponseApi respuesta = ExternalCustomerServiceCallout.createLeadApiCallout(externalLeadApi);
                        //Guardar para crear cliente concesionario, crear metodo de crear clienteConcesionario
                        //if(respuesta.Status.equalsIgnoreCase(errorStatus_Success)){
                            //Account cuenta = creaClienteConcesionario(cuenta,)
                        //}
                    	mapCaseIdToResponse.put(caso.Id, respuesta);
                    }
                    else {
                        
                    	mapCaseIdToResponse.put(caso.Id, respuestaCustomer);
                   }
               	}
            }
        }
        //Asociado con lead
        if (!listLeadId.isEmpty()) {
            for (String idCaso : listCaseSendWithLead){
                ExternalCustomerApiModel.CustomerApi externalCustomerApi = new ExternalCustomerApiModel.CustomerApi();
                ExternalLeadApiModel.LeadApi externalLeadApi = new ExternalLeadApiModel.LeadApi();
                Case caso = mapCaseById.get(idCaso);
                Centro__c centro = caso.Centro__c != null && mapCentroById.containsKey(caso.Centro__c) ? mapCentroById.get(caso.Centro__c) : null;
                Campaign campania = caso.Campana__c != null && mapCampaignById.containsKey(caso.Campana__c) ? mapCampaignById.get(caso.Campana__c) : null;
                Lead candidato = caso.Lead__c != null && mapLeadById.containsKey(caso.Lead__c) ? mapLeadById.get(caso.Lead__c) : null;
            	
                externalCustomerApi = createExternalCustomer(caso, centro, null, candidato, mapPaisByName);
               ResponseApi respuestaCustomer = ExternalCustomerServiceCallout.createAccountApiCallout(externalCustomerApi);
                if (respuestaCustomer.Status.equalsIgnoreCase('OK')) {
                	externalLeadApi = createExternalLead(caso, centro, campania, respuestaCustomer.Message, emailAsesor);
                    ResponseApi respuesta = ExternalCustomerServiceCallout.createLeadApiCallout(externalLeadApi);
                    mapCaseIdToResponse.put(caso.Id, respuesta);
                    //Guardar para crear cliente y cliente concesionario, crear método de crear clienteConcesionario, cliente
                        //if(respuesta.Status.equalsIgnoreCase(errorStatus_Success)){
                            //Account cuenta = creaClienteConcesionario(cuenta,)
                        //}
                }
                else {
                     mapCaseIdToResponse.put(caso.Id, respuestaCustomer);
                    }
         	}   
        }
        
        //Creamos Cuenta
        
        //Creamos cliente Concesionario
        //
        //Actualización del caso y asociamos el caso a la cuenta
        for (String idCaso :mapCaseIdToResponse.keySet()){
            Case caso = new Case();
            caso.Id = idCaso;
            ResponseApi respuesta = mapCaseIdToResponse.get(idCaso);
            caso.EnvioMulesoft__c = respuesta.Status;
            caso.Error_Mulesoft__c = respuesta.Message.length()>255?respuesta.Message.substring(0,255):respuesta.Message;
            listCaseToUpdate.add(caso);
        }*/
/*    }
    
    public static ExternalLeadApiModel.leadApi createExternalLead(Case infoCase, Centro__c centro, Campaign campania, String idClienteExterno, String emailAsesor) {
        ExternalLeadApiModel.LeadApi extLead = new ExternalLeadApiModel.LeadApi();
        extLead.companyId = centro.Concesionario__r.Id_Concesionario_Sima__c;
        extLead.caseId = infoCase.Id;
        extLead.salesCenterCode = centro.CentroCdg__c;
        extLead.brandCode =  infoCase.Marca__c;
        extLead.salesmanEmail = emailAsesor;
        extLead.customerId = idClienteExterno;
        //extLead.agendaTask = new List<ExternalLeadApiModel.AgendaTask>();
        ExternalLeadApiModel.AgendaTask agendaTask = new ExternalLeadApiModel.AgendaTask();
        agendaTask.scheduledDate = String.valueOf(Datetime.now().addHours(1).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
        //Línea 1: “Intención de compra: “ + (nos lo pidieron de selección multiple, en la landing a día de hoy solo va a llegar 1 pero OPP puede seleccionar varios)  por lo tanto concatenaríamos los valores que ve el cliente no internos, separados por comas + “ Modelo: “ + modelo + “ Campaña: “ + campaña
		//Límea 2: “Teléfono : “ + SuppliedPhone + “ Email: “ + SuppliedEmail + “ Preferencia de contacto: “ Preferencia_de_contacto__c + “ Horario de contacto: “ Horario_de_contacto__c
		//Línea 3: “ Fecha hora cita con cliente: “ Fecha_Hora_de_cita__c  Solo poner la línea si tiene datos la descripción
		//Línea 4: “ Comentario: “   Solo poner la línea si tiene datos la descripción
		//Línea 5 en adelante: Description  Solo poner la línea si tiene datos la descripción
		String campaignName = campania != null ?' Campañia: ' +campania.Name:'';
        
        Schema.DescribeFieldResult fieldIntencionDeCompra = Case.Intencion_de_compra__c.getDescribe();
        Map<String, String> mapIntencionDeCompraLabels = new Map<String, String>();
        
        for (Schema.PicklistEntry ple : fieldIntencionDeCompra.getPicklistValues()) {
            mapIntencionDeCompraLabels.put(ple.getValue(), ple.getLabel());
        }
        
        Schema.DescribeFieldResult fieldModelo = Case.Modelo__c.getDescribe();
        Map<String, String> mapModeloLabels = new Map<String, String>();
        
        for (Schema.PicklistEntry ple : fieldModelo.getPicklistValues()) {
            mapModeloLabels.put(ple.getValue(), ple.getLabel());
        }
        
        Schema.DescribeFieldResult fieldPreferenciaDeContacto = Case.Preferencia_de_contacto__c.getDescribe();
        Map<String, String> mapPreferenciaDeContactoLabels = new Map<String, String>();
        
        for (Schema.PicklistEntry ple : fieldPreferenciaDeContacto.getPicklistValues()) {
            mapPreferenciaDeContactoLabels.put(ple.getValue(), ple.getLabel());
        }
        
        Schema.DescribeFieldResult fieldHorarioDeContacto = Case.Horario_de_contacto__c.getDescribe();
        Map<String, String> mapHorarioDeContactoLabels = new Map<String, String>();
        
        for (Schema.PicklistEntry ple : fieldPreferenciaDeContacto.getPicklistValues()) {
            mapHorarioDeContactoLabels.put(ple.getValue(), ple.getLabel());
        }
        
		String linea1 = 'Intención de compra: ' + mapIntencionDeCompraLabels.get(infoCase.Intencion_de_compra__c) + ' Modelo: '+ mapModeloLabels.get(infoCase.Modelo__c) + campaignName+'\r\n';
        String linea2 = 'Teléfono: '+ infoCase.SuppliedPhone +' Email: '+ infoCase.SuppliedEmail + ' Preferencia de contacto: '+ mapPreferenciaDeContactoLabels.get(infoCase.Preferencia_de_contacto__c) + ' Horario de contacto: ' + mapHorarioDeContactoLabels.get(infoCase.Horario_de_contacto__c) + '\r\n';
        String linea3 = infoCase.Fecha_Hora_de_cita__c != null ?'Fecha hora cita con cliente: '+String.valueOf(infoCase.Fecha_Hora_de_cita__c)+'\r\n':'';
        String linea4 = !String.isBlank(infoCase.Comments)?'Comentario: '+infoCase.Comments+'\r\n':'';
        String linea5 = !String.isBlank(infoCase.Description)?'Descripción: '+infoCase.Description+'\r\n':'';
        agendaTask.remarks = linea1 + linea2 +linea3 +linea4 +linea5;			// Qué es esto?
        //extLead.agendaTask.add(agendaTask);
		extLead.agendaTask=agendaTask;

        return extLead;
    }
    
    public static ExternalCustomerApiModel.CustomerApi createExternalCustomer(Case infoCase, Centro__c centro, Account cuenta, Lead candidato, Map<String, Pais__c> mapPaisByName) {
        ExternalCustomerApiModel.CustomerApi extCustomer = new ExternalCustomerApiModel.CustomerApi();
        ExternalCustomerApiModel.TaxId taxCustomer = new ExternalCustomerApiModel.TaxId();
        
        //extCustomer.taxIds = new List<ExternalCustomerApiModel.TaxId>();
       
        //extCustomer.addresses = new List<ExternalCustomerApiModel.Address>();
        //extCustomer.methodsOfContact = new List<ExternalCustomerApiModel.MethodOfContact>();
        
        extCustomer.companyId = centro.Concesionario__r.Id_Concesionario_Sima__c;
        extCustomer.accountId =infoCase.AccountId;
        extCustomer.leadId =infoCase.Lead__c;

        //extCustomer.accountId =!String.isBlank(infoCase.AccountId)?infoCase.AccountId:'';
        //extCustomer.leadId =!String.isBlank(infoCase.Lead__c)?infoCase.Lead__c:'';
        
        if (cuenta != null) {
            if (cuenta.IsPersonAccount) {
                extCustomer.name =cuenta.FirstName;
                //extCustomer.name =!String.isBlank(cuenta.FirstName)?cuenta.FirstName:'';
                
                if (!String.isBlank(cuenta.LastName)) {
                	List<String> apellidos = cuenta.LastName.Split(' ');
        			extCustomer.firstSurname = apellidos.get(0);
                	extCustomer.secondSurname = '';
                	
                    for (integer i = 1; i<apellidos.size(); i++) {
                        extCustomer.secondSurname += apellidos.get(i) + ' ';
                    }
                }
                /*else {
                    extCustomer.firstSurname='';
                    extCustomer.secondSurname = '';
                }
                */
        /*        extCustomer.title = cuenta.Salutation;
                if(!String.isBlank(cuenta.Documento__c)){
                    extCustomer.taxId = new ExternalCustomerApiModel.TaxId();
                    taxCustomer.num =cuenta.Documento__c;
                	taxCustomer.documentType = cuenta.Tipo_de_documento_cuenta_personal__c;
                	taxCustomer.personType =Label.AccountPerson;
                    extCustomer.taxId = taxCustomer;
                }
                /*
                extCustomer.title = !String.isBlank(cuenta.Salutation)?cuenta.Salutation:'';
                taxCustomer.num = !String.isBlank(cuenta.Documento__c)?cuenta.Documento__c:'';
                taxCustomer.documentType = !String.isBlank(cuenta.Documento__c)?cuenta.Tipo_de_documento_cuenta_personal__c:null;
                taxCustomer.personType =!String.isBlank(cuenta.Documento__c)?Label.AccountPerson:'';*/
     /*           extCustomer.personType = Label.AccountPerson;
                
                if(!String.isBlank(cuenta.PersonEmail)){
                    extCustomer.methodsOfContact = extCustomer.methodsOfContact==null ? new List<ExternalCustomerApiModel.MethodOfContact>():extCustomer.methodsOfContact;
                	ExternalCustomerApiModel.MethodOfContact metodoContacto = new ExternalCustomerApiModel.MethodOfContact();
					metodoContacto.channel =Label.channelEmail;
                    metodoContacto.value = cuenta.PersonEmail;
                    metodoContacto.isDefault = false;
                    extCustomer.methodsOfContact.add(metodoContacto);
                }
                if(!String.isBlank(cuenta.phone)){
                    extCustomer.methodsOfContact = extCustomer.methodsOfContact==null ? new List<ExternalCustomerApiModel.MethodOfContact>():extCustomer.methodsOfContact;
                	ExternalCustomerApiModel.MethodOfContact metodoContacto = new ExternalCustomerApiModel.MethodOfContact();
					metodoContacto.channel =Label.channelPhone;
                    metodoContacto.value = cuenta.phone;
                    metodoContacto.isDefault = false;
                    extCustomer.methodsOfContact.add(metodoContacto);
                }
                if(!String.isBlank(cuenta.PersonMobilePhone)){
                    extCustomer.methodsOfContact = extCustomer.methodsOfContact==null ? new List<ExternalCustomerApiModel.MethodOfContact>():extCustomer.methodsOfContact;
                	ExternalCustomerApiModel.MethodOfContact metodoContacto = new ExternalCustomerApiModel.MethodOfContact();
					metodoContacto.channel =Label.channelMobile;
                    metodoContacto.value = cuenta.PersonMobilePhone;
                    metodoContacto.isDefault = false;
                    extCustomer.methodsOfContact.add(metodoContacto);
                }
                if(!String.isBlank(cuenta.OtherEmail__pc)){
                    extCustomer.methodsOfContact = extCustomer.methodsOfContact==null ? new List<ExternalCustomerApiModel.MethodOfContact>():extCustomer.methodsOfContact;
                	ExternalCustomerApiModel.MethodOfContact metodoContacto = new ExternalCustomerApiModel.MethodOfContact();
					metodoContacto.channel =Label.channelEmail;
                    metodoContacto.value = cuenta.OtherEmail__pc;
                    metodoContacto.isDefault = false;
                    extCustomer.methodsOfContact.add(metodoContacto);
                }
                if(!String.isBlank(cuenta.OtherMobilePhone__pc)){
                    extCustomer.methodsOfContact = extCustomer.methodsOfContact==null ? new List<ExternalCustomerApiModel.MethodOfContact>():extCustomer.methodsOfContact;
                	ExternalCustomerApiModel.MethodOfContact metodoContacto = new ExternalCustomerApiModel.MethodOfContact();
					metodoContacto.channel =Label.channelMobile;
                    metodoContacto.value = cuenta.OtherMobilePhone__pc;
                    metodoContacto.isDefault = false;
                    extCustomer.methodsOfContact.add(metodoContacto);
                }
                if(!String.isBlank(cuenta.PersonOtherPhone)){
                    extCustomer.methodsOfContact = extCustomer.methodsOfContact==null ? new List<ExternalCustomerApiModel.MethodOfContact>():extCustomer.methodsOfContact;
                	ExternalCustomerApiModel.MethodOfContact metodoContacto = new ExternalCustomerApiModel.MethodOfContact();
					metodoContacto.channel =Label.channelPhone;
                    metodoContacto.value = cuenta.PersonOtherPhone;
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
                
                if(!String.isBlank(cuenta.Email__c)){
                    extCustomer.methodsOfContact = extCustomer.methodsOfContact==null ? new List<ExternalCustomerApiModel.MethodOfContact>():extCustomer.methodsOfContact;
                	ExternalCustomerApiModel.MethodOfContact metodoContacto = new ExternalCustomerApiModel.MethodOfContact();
					metodoContacto.channel =Label.channelEmail;
                    metodoContacto.value = cuenta.Email__c;
                    metodoContacto.isDefault = false;
                    extCustomer.methodsOfContact.add(metodoContacto);
                }
                if(!String.isBlank(cuenta.phone)){
                    extCustomer.methodsOfContact = extCustomer.methodsOfContact==null ? new List<ExternalCustomerApiModel.MethodOfContact>():extCustomer.methodsOfContact;
                	ExternalCustomerApiModel.MethodOfContact metodoContacto = new ExternalCustomerApiModel.MethodOfContact();
					metodoContacto.channel =Label.channelPhone;
                    metodoContacto.value = cuenta.phone;
                    metodoContacto.isDefault = false;
                    extCustomer.methodsOfContact.add(metodoContacto);
                }
                if(!String.isBlank(cuenta.Mobile__c)){
                    extCustomer.methodsOfContact = extCustomer.methodsOfContact==null ? new List<ExternalCustomerApiModel.MethodOfContact>():extCustomer.methodsOfContact;
                	ExternalCustomerApiModel.MethodOfContact metodoContacto = new ExternalCustomerApiModel.MethodOfContact();
					metodoContacto.channel =Label.channelMobile;
                    metodoContacto.value = cuenta.Mobile__c;
                    metodoContacto.isDefault = false;
                    extCustomer.methodsOfContact.add(metodoContacto);
                }
                if(!String.isBlank(cuenta.Other_Email__c)){
                    extCustomer.methodsOfContact = extCustomer.methodsOfContact==null ? new List<ExternalCustomerApiModel.MethodOfContact>():extCustomer.methodsOfContact;
                	ExternalCustomerApiModel.MethodOfContact metodoContacto = new ExternalCustomerApiModel.MethodOfContact();
					metodoContacto.channel =Label.channelEmail;
                    metodoContacto.value = cuenta.Other_Email__c;
                    metodoContacto.isDefault = false;
                    extCustomer.methodsOfContact.add(metodoContacto);
                }
                if(!String.isBlank(cuenta.Other_Mobile__c)){
                    extCustomer.methodsOfContact = extCustomer.methodsOfContact==null ? new List<ExternalCustomerApiModel.MethodOfContact>():extCustomer.methodsOfContact;
                	ExternalCustomerApiModel.MethodOfContact metodoContacto = new ExternalCustomerApiModel.MethodOfContact();
					metodoContacto.channel =Label.channelMobile;
                    metodoContacto.value = cuenta.Other_Mobile__c;
                    metodoContacto.isDefault = false;
                    extCustomer.methodsOfContact.add(metodoContacto);
                }
                if(!String.isBlank(cuenta.Other_Phone__c)){
                    extCustomer.methodsOfContact = extCustomer.methodsOfContact==null ? new List<ExternalCustomerApiModel.MethodOfContact>():extCustomer.methodsOfContact;
                	ExternalCustomerApiModel.MethodOfContact metodoContacto = new ExternalCustomerApiModel.MethodOfContact();
					metodoContacto.channel =Label.channelPhone;
                    metodoContacto.value = cuenta.Other_Phone__c;
                    metodoContacto.isDefault = false;
                    extCustomer.methodsOfContact.add(metodoContacto);
                }
                
            }
            extCustomer.tradeName =cuenta.Marca_registrada__c;
            extCustomer.countryIso31661 =cuenta.Pais__c != null?cuenta.Pais__r.ISO_31661_alfa2__c:'ES';
          	/*
            extCustomer.tradeName = !String.isBlank(cuenta.Marca_registrada__c)? cuenta.Marca_registrada__c:'';
            extCustomer.countryIso31661 = !String.isBlank(cuenta.Pais__r.ISO_31661_alfa2__c)? cuenta.Pais__r.ISO_31661_alfa2__c:'';
          	*/
			//extCustomer.taxIds.add(taxCustomer);
    /*        String paisBilling = !String.isBlank(cuenta.BillingCountry)?DataValidations.capitalizeString(cuenta.BillingCountry):'';
            if(!String.isBlank(cuenta.BillingStreet) && !String.isBlank(paisBilling) && mapPaisByName.containsKey(paisBilling) && mapPaisByName.get(paisBilling).ISO_31661_alfa2__c=='ES' ){
            	extCustomer.addresses = extCustomer.addresses ==null? new List<ExternalCustomerApiModel.Address>():extCustomer.addresses;
                ExternalCustomerApiModel.Address direccion = new ExternalCustomerApiModel.Address();
            	ExternalCustomerApiModel.Purpose purpose = new ExternalCustomerApiModel.Purpose();
                direccion.purposes = new List<String>();
            	direccion.city = !String.isBlank(cuenta.BillingCity)? cuenta.BillingCity: '';
            	direccion.department = !String.isBlank(cuenta.BillingState)? cuenta.BillingState:'';
                direccion.region = !String.isBlank(cuenta.BillingState)? cuenta.BillingState:'';
            	direccion.street = cuenta.BillingStreet;
                direccion.countryIso31661 = mapPaisByName.get(paisBilling).ISO_31661_alfa2__c;
           		direccion.postalCode =!String.isBlank(cuenta.BillingPostalCode)? cuenta.BillingPostalCode:'';
                direccion.streetTypeId ='CL';
                //direccion.foreignFullAddress = '';
                //purpose.RegisteredOffice = 'Taxes';
                direccion.purposes.add('Taxes');
                //direccion.purposes.add(purpose);
                extCustomer.addresses.add(direccion);
            }
            else if(!String.isBlank(paisBilling) && mapPaisByName.containsKey(paisBilling) && !mapPaisByName.get(paisBilling).ISO_31661_alfa2__c.equalsIgnoreCase('ES') ) {
                ExternalCustomerApiModel.Address direccion = new ExternalCustomerApiModel.Address();
            	ExternalCustomerApiModel.Purpose purpose = new ExternalCustomerApiModel.Purpose();
            	extCustomer.addresses = extCustomer.addresses ==null? new List<ExternalCustomerApiModel.Address>():extCustomer.addresses;
                
                direccion.purposes = new List<String>();
            	direccion.foreignFullAddress = cuenta.BillingStreet;
                direccion.city = !String.isBlank(cuenta.BillingCity)? cuenta.BillingCity: '';
            	direccion.department = !String.isBlank(cuenta.BillingState)? cuenta.BillingState:'';
                direccion.region = !String.isBlank(cuenta.BillingState)? cuenta.BillingState:'';
            	//direccion.street = '';
                direccion.countryIso31661 = mapPaisByName.get(paisBilling).ISO_31661_alfa2__c;
           		direccion.postalCode =!String.isBlank(cuenta.BillingPostalCode)? cuenta.BillingPostalCode:'';
                direccion.streetTypeId ='CL';
                //purpose.RegisteredOffice = 'Taxes';
                direccion.purposes.add('Taxes');
                //direccion.purposes.add(purpose);
                extCustomer.addresses.add(direccion);

                
            }
            
            String paisShipping = !String.isBlank(cuenta.ShippingCountry)?DataValidations.capitalizeString(cuenta.ShippingCountry):'';
            if(!String.isBlank(cuenta.ShippingStreet) && !String.isBlank(paisShipping) && mapPaisByName.containsKey(paisShipping) && mapPaisByName.get(paisShipping).ISO_31661_alfa2__c=='ES' ){
                ExternalCustomerApiModel.Address direccionShipping = new ExternalCustomerApiModel.Address();
            	ExternalCustomerApiModel.Purpose purposeShipping = new ExternalCustomerApiModel.Purpose();
            	extCustomer.addresses = extCustomer.addresses ==null? new List<ExternalCustomerApiModel.Address>():extCustomer.addresses;
                direccionShipping.purposes = new List<String>();
            	
                direccionShipping.city= cuenta.ShippingCity;
            	direccionShipping.department = cuenta.ShippingState;
                direccionShipping.region = cuenta.ShippingState;
            	
            	direccionShipping.street = cuenta.ShippingStreet;
                direccionShipping.countryIso31661 = mapPaisByName.get(paisShipping).ISO_31661_alfa2__c;
           		direccionShipping.postalCode =cuenta.ShippingPostalCode;
                direccionShipping.streetTypeId ='CL';
                //purposeShipping.RegisteredOffice = 'Delivering';
                direccionShipping.purposes.add('Delivering');
                //direccionShipping.purposes.add(purposeShipping);
				//direccionShipping.streetTypeId ='Delivering'; 
				extCustomer.addresses.add(direccionShipping);
            }
            else if(!String.isBlank(paisShipping) && mapPaisByName.containsKey(paisShipping) && !mapPaisByName.get(paisShipping).ISO_31661_alfa2__c.equalsIgnoreCase('ES')) {
                ExternalCustomerApiModel.Address direccionShipping = new ExternalCustomerApiModel.Address();
            	ExternalCustomerApiModel.Purpose purposeShipping = new ExternalCustomerApiModel.Purpose();
            	extCustomer.addresses = extCustomer.addresses ==null? new List<ExternalCustomerApiModel.Address>():extCustomer.addresses;
                direccionShipping.purposes = new List<String>();
            	
                direccionShipping.foreignFullAddress = cuenta.ShippingStreet;
                direccionShipping.city = cuenta.ShippingCity;
            	direccionShipping.department =cuenta.ShippingState;
                direccionShipping.region = cuenta.ShippingState;
            	//direccion.street = '';
                direccionShipping.countryIso31661 = mapPaisByName.get(paisShipping).ISO_31661_alfa2__c;
           		direccionShipping.postalCode =cuenta.ShippingPostalCode;
                direccionShipping.streetTypeId ='CL';
                purposeShipping.RegisteredOffice = 'Delivering';
                direccionShipping.purposes.add('Delivering');
                //direccionShipping.purposes.add(purposeShipping);
                extCustomer.addresses.add(direccionShipping);
                
            }
    
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
            if(!String.isBlank(candidato.Email)){
                	extCustomer.methodsOfContact = extCustomer.methodsOfContact==null ? new List<ExternalCustomerApiModel.MethodOfContact>():extCustomer.methodsOfContact;
                	ExternalCustomerApiModel.MethodOfContact metodoContacto = new ExternalCustomerApiModel.MethodOfContact();
					metodoContacto.channel =Label.channelEmail;
                    metodoContacto.value = candidato.Email;
                    metodoContacto.isDefault = false;
                    extCustomer.methodsOfContact.add(metodoContacto);
                }
            if(!String.isBlank(candidato.phone)){
                	extCustomer.methodsOfContact = extCustomer.methodsOfContact==null ? new List<ExternalCustomerApiModel.MethodOfContact>():extCustomer.methodsOfContact;
                	ExternalCustomerApiModel.MethodOfContact metodoContacto = new ExternalCustomerApiModel.MethodOfContact();
					metodoContacto.channel =Label.channelPhone;
                    metodoContacto.value = candidato.phone;
                    metodoContacto.isDefault = false;
                    extCustomer.methodsOfContact.add(metodoContacto);
                }
            if(!String.isBlank(candidato.MobilePhone)){
                	extCustomer.methodsOfContact = extCustomer.methodsOfContact==null ? new List<ExternalCustomerApiModel.MethodOfContact>():extCustomer.methodsOfContact;
                	ExternalCustomerApiModel.MethodOfContact metodoContacto = new ExternalCustomerApiModel.MethodOfContact();
					metodoContacto.channel =Label.channelMobile;
                    metodoContacto.value = candidato.MobilePhone;
                    metodoContacto.isDefault = false;
                    extCustomer.methodsOfContact.add(metodoContacto);
                }
            String pais = !String.isBlank(candidato.Country)?DataValidations.capitalizeString(candidato.Country):'';
            extCustomer.countryIso31661 =!String.isBlank(pais) && mapPaisByName.containsKey(pais)?mapPaisByName.get(pais).ISO_31661_alfa2__c:'ES';
            
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
           }
        
        return extCustomer;
    }
	
    private static Cliente_Concesionario__c createCconcesionario(Account cuenta, String idSima, String idExConcesionario){
        Cliente_Concesionario__c cConcesionario = new Cliente_Concesionario__c();
        if(cuenta != null){
            cConcesionario.Cliente__c = cuenta.Id;
        	cConcesionario.Documento__c = cuenta.Id;
        
        }
        if(!String.isBlank(idExConcesionario)){
            cConcesionario.Concesionario__c = idExConcesionario;
        }
        if(!String.isBlank(idSima)){
            cConcesionario.Id_Cliente_DMS__c = idSima;
        }
        return cConcesionario;
    }
    
    private static Account createAccount(Lead candidato, Case caso, Map<String, Pais__c> mapPaisByName){
        Account cuenta = new Account();
        cuenta.RecordTypeId = AccountGateway.getRecordTypeIdByDeveloperName('PersonAccount');
        cuenta.FirstName = candidato.FirstName;
        cuenta.LastName = candidato.LastName;
        cuenta.Salutation = candidato.Salutation;
        cuenta.PersonEmail = !String.isBlank(caso.SuppliedEmail)? caso.SuppliedEmail.toLowerCase():candidato.Email;
        cuenta.Phone = !String.isBlank(caso.SuppliedPhone)? caso.SuppliedPhone: candidato.phone;
        cuenta.PersonMobilePhone = !String.isBlank(caso.Movil__c)?caso.Movil__c:candidato.MobilePhone;
        cuenta.Pais__c= mapPaisByName.containsKey(candidato.Country)?mapPaisByName.get(candidato.Country).Id:null;
        cuenta.BillingCity = candidato.City;
        cuenta.BillingCountry = !String.isBlank(candidato.Country)?candidato.Country.toUpperCase():null;
        cuenta.BillingPostalCode = candidato.PostalCode;
        cuenta.BillingState = candidato.State;
        cuenta.BillingStreet = candidato.Street;
        //Miramos posibles duplicados
        List<Account> lstDuplicates = new List<Account>();
        lstDuplicates.add(cuenta);
        
        if (Datacloud.FindDuplicates.findDuplicates(lstDuplicates).size() > 0) {
			Datacloud.FindDuplicatesResult resultFindDuplicate = Datacloud.FindDuplicates.findDuplicates(lstDuplicates)[0];
			List<Datacloud.MatchRecord> recordListMatch = resultFindDuplicate.getDuplicateResults()[0].getMatchResults()[0].getMatchRecords();
			if (!recordListMatch.isEmpty()) {
				Datacloud.MatchRecord recordMatch = recordListMatch[0];
				SObject record = recordMatch.getRecord();
				System.debug('RECORD: ' + record);
				Account auxAcc = (Account) record;
				
                if (auxAcc != null) {
                    cuenta.Id = auxAcc.Id;
                }
			}
			else {
				System.debug('NO recordMatch');
			}
        }
        else {
            System.debug('NO DUPLICATES!');
        }
        return cuenta;
        
    }*/
    
}