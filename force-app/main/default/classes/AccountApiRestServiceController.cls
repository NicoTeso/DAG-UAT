public class AccountApiRestServiceController {
    private static Map<String, Schema.RecordTypeInfo> rtMapConsentimientoByName = Schema.SObjectType.Consentimientos__c.getRecordTypeInfosByName();
    
    /*
    * Método principal de inserción y actualización de un cliente y cliente concesionario
	*/
    public static ResponseApi upsertCliente(AccountApiRestModel req) {
        ResponseApi response = new ResponseApi();
        try {
        	String auxIdExternal = req.accountApi.customerId+'/'+ req.accountApi.companyId;

            list<Exception__c> listExcAnt = ExceptionGateway.getOppByIdObjetosAndClaseMetodo(auxIdExternal, 'AccountApiRestServiceController.upsertCliente');
            if (!listExcAnt.isEmpty()) { delete listExcAnt;}
            
            Concesionario__c concesionario = ConcesionarioGateway.getConcessionaireByCompanyId(req.accountApi.companyId);
             Boolean hayCC;
             if (concesionario.Es_propio__c) {
	             hayCC = false;
             } else {
	             hayCC = true;
             }
        	 Cliente_Concesionario__c clienteConcesionario = ClienteConcesionarioGateway.getClienteConcesionarioByIdExternal(auxIdExternal);
        	 system.debug('clienteConcesionario: '+clienteConcesionario);
             List<Cliente_Concesionario__c> listClienteConcesionario = new List<Cliente_Concesionario__c>();
             Account cliente;
        	 response.Message = '';
        	 Boolean buscar = false;
             if (clienteConcesionario != null) {
                 	hayCC = true;
                    // Encontrado mediante IDs externas
                    if (clienteConcesionario.Cliente__r.isPersonAccount != req.accountApi.isPersonAccount) {
						throw new CustomException('No coinciden los campos isPersonAccount');
					}
                 	// Si está informado el documento buscamos si existe una cuenta diferente con ese DNI, para unificarlas antes de actualizar
            		if(!String.isBlank(req.accountApi.documento)){
                        
                        Account master = AccountGateway.getAccountByDocumento(req.accountApi.documento);
                        //Account master = [select Id from account where id = :cliente1.Id limit 1]; 

                		if(master !=null && clienteConcesionario.Cliente__c != master.Id){
                            if(!String.isBlank(clienteConcesionario.Cliente__r.Documento__c) && !master.Documento__c.equalsIgnoreCase(clienteConcesionario.Cliente__r.Documento__c)){
                                throw new CustomException('Error de concoordancia en el documento');
                            }
						   //Account duplicates = [select Id, Documento__c from account where id = :clienteConcesionario.Cliente__c limit 1]; 
                           //if (duplicates.Documento__c == null){
                           //
                           mergeAccounts(master, clienteConcesionario.Cliente__c);
                           clienteConcesionario = ClienteConcesionarioGateway.getClienteConcesionarioByIdExternal(auxIdExternal);
                           } 
                        }
                 	
                    // Modificamos registro del cliente
					cliente = upsertCliente(req, clienteConcesionario.Cliente__c, response, hayCC);
                    buscar = true;
                    upsertClienteConcesionario(req, clienteConcesionario, cliente, concesionario);
                  
                }
            else if(!String.isBlank(req.accountApi.documento)){
                cliente = AccountGateway.getAccountByDocumento(req.accountApi.documento);
                if(cliente !=null){
                    cliente = upsertCliente(req, cliente.Id, response, hayCC);
                    upsertClienteConcesionario(req, null, cliente, concesionario);
                }
                else {
                    cliente = upsertCliente(req,'', response, hayCC);
                    upsertClienteConcesionario(req, null, cliente, concesionario);
                }
            }
            else{
                cliente = upsertCliente(req, '', response, hayCC);
                upsertClienteConcesionario(req, null, cliente, concesionario);
            }

            if (cliente.IsPersonAccount && Label.ConcesionariosIntegracion.contains(req.accountApi.companyId)) {
                system.debug('entra a envio');
                string cConcesionarioExternalId = req.accountApi.customerId+'/'+ req.accountApi.companyId;
                system.debug('cConcesionarioExternalId: '+cConcesionarioExternalId);
                system.debug('cliente.PersonContactId:  '+cliente.PersonContactId);
                ExternalServiceController.sendConsentimientoMulesoft2(cliente.PersonContactId, cConcesionarioExternalId);
            }
            
            //Respuesta, todo correcto 
            // Luego lo cambiamos con las excepciones etc
			response.Status = Label.errorStatus_Success;
        	response.Message += Label.responseMessage_Success + ' ';
        } catch(Exception e) {
            response.ErrorCode = '500';
            response.Status = Label.errorStatus_Error;
        	response.Message += Label.responseMessage_Error + ' ' + e.getMessage() + ' línea: ' + e.getLineNumber() + ' ; ';
            System.debug(response.Message);

            Exception__c exc = new Exception__c ();
            exc.idObjetos__c = req.accountApi.customerId+'/'+ req.accountApi.companyId;
            exc.Exception__c = e.getCause() + '// '+ e.getMessage();
            exc.Linea__c = e.getLineNumber();
            exc.JSON_Entrada__c = JSON.serialize(req);
            exc.Clase_Metodo__c = 'AccountApiRestServiceController.upsertCliente';
                        
            insert exc;
        }
        
        System.debug(response.Status);
        return response;
    }
    
    /*
    * Método principal de actualización de un cliente con los externalInfo mediante un cliente concesionario
	*/
    public static ResponseApi updateExternalInfoCliente(AccountApiRestModel req) {

        String auxIdExternal = req.accountApi.customerId+'/'+ req.accountApi.companyId;

        list<Exception__c> listExcAnt = ExceptionGateway.getOppByIdObjetosAndClaseMetodo(auxIdExternal, 'AccountApiRestServiceController.updateExternalInfoCliente');
        if (!listExcAnt.isEmpty()) { delete listExcAnt;}
        
        List<Account> listaCliente = [SELECT Id,
                                      		 IsPersonAccount,
                                      		 Occupation__pc,
                                      		 ChildrenCount__pc,
                                      	 	 PersonBirthdate,
                                      		 incomes__pc,
                                      		 position__pc,
                                      		 maritalStatus__pc,
                                        	 economicSector__pc
                                      FROM Account
                                      WHERE Id IN (SELECT Cliente__c
                                                   FROM Cliente_Concesionario__c
                                                  WHERE Id_Cliente_DMS__c = :req.accountApi.customerId
                                                   	AND Concesionario__r.Id_Concesionario_Sima__c = :req.accountApi.companyId)];
        Account cliente;
        ResponseApi response = new ResponseApi();     
        if (!listaCliente.isEmpty()) {
            cliente = listaCliente[0];
            if (cliente.IsPersonAccount == true){
	          	cliente.Occupation__pc = !String.isBlank(req.accountApi.occupation) ? req.accountApi.companyId + '-' + req.accountApi.occupation : null;
	            cliente.ChildrenCount__pc = !String.isBlank(req.accountApi.childrenCount) && req.accountApi.childrenCount.isNumeric() ? Integer.valueOf(req.accountApi.childrenCount) : null;
	            cliente.PersonBirthdate = !String.isBlank(req.accountApi.personBirthdate) ? Date.valueOf(req.accountApi.personBirthdate) : null;
	            cliente.incomes__pc = req.accountApi.incomes;
	            cliente.position__pc = req.accountApi.position;
	            cliente.maritalStatus__pc = req.accountApi.maritalStatus;
	            cliente.economicSector__pc = !String.isBlank(req.accountApi.economicSector) ? req.accountApi.companyId + '-' + req.accountApi.economicSector : null;
            
	            upsert cliente;
            }    
            
            response.Status = Label.errorStatus_Success;
        	response.Message = Label.responseMessage_Success;
        
        }
        else {
            //throw new CustomException(Label.errorStatus_Error);
            response.ErrorCode = '500';
            response.Status = Label.errorStatus_Error;
        	response.Message = 'No se ha encuentra al cliente para actualizarlo.';
            System.debug(response.Message);

            Exception__c exc = new Exception__c ();
            exc.idObjetos__c = req.accountApi.customerId+'/'+ req.accountApi.companyId;
            exc.Exception__c = response.Message;
            exc.Linea__c = 116;
            exc.JSON_Entrada__c = JSON.serialize(req);
            exc.Clase_Metodo__c = 'AccountApiRestServiceController.updateExternalInfoCliente';
                        
            insert exc;
        }
        
        
        return response;
    }
    
    /*
    * Método principal para actualizar consentimientos de un cliente
	*/
    public static ResponseApi upsertConsent(AccountApiRestModel req) {
        //Buscar al cliente y con esto 
        ResponseApi response = new ResponseApi();
        response.Message = '';
        String externalId = req.accountApi.customerId+'/'+ req.accountApi.companyId;
        try {
	        list<Exception__c> listExcAnt = ExceptionGateway.getOppByIdObjetosAndClaseMetodo(externalId, 'AccountApiRestServiceController.upsertConsent');
	        if (!listExcAnt.isEmpty()) { delete listExcAnt;}

	        Cliente_Concesionario__c cConcesionario = ClienteConcesionarioGateway.getClienteConcesionarioByIdExternal(req.accountApi.customerId, req.accountApi.companyId);
            
            if (cConcesionario != null) {
		        Contact contacto = ContactGateway.getContactByAccountId(cConcesionario.Cliente__c);
                if (contacto != null) {
                    Map<String, Consentimientos__c> mapConsentsByValue = new Map<String,Consentimientos__c>();
                    List<Consentimientos__c> listConsentimiento = ConsentimientosGateway.getConsentimientosByAccountId(cConcesionario.Cliente__c);
                    for(Consentimientos__c consentimiento : listConsentimiento ){
                        String recordTypeDN  = ConsentimientosGateway.getRecordTypeDeveloperNameById(consentimiento.recordTypeId);
                        if(recordTypeDN.equalsIgnoreCase('Email') || recordTypeDN.equalsIgnoreCase('Movil') || recordTypeDN.equalsIgnoreCase('Telefono')){
                            mapConsentsByValue.put(consentimiento.ChannelValue__c, consentimiento);
                        }
                        else if (recordTypeDN.equalsIgnoreCase(Label.RtConsentimientoNoEcosistema)){
                            mapConsentsByValue.put(consentimiento.Concesionario__r.Id_Concesionario_Sima__c, consentimiento);
                        }
                    }
                    Set<Consentimientos__c> lstConsentsToUpdate = new Set<Consentimientos__c >();
                    Map<String, Consentimientos__c> mapConsentimientoTuUpdateById = new Map<String, Consentimientos__c>();
                    Datetime consentDate = Datetime.valueOf(req.accountapi.DateConsent.replace('T',' '));
                    Map<String,Invalid_Emails__c> mapInvalidEmailByEmail = new Map<String,Invalid_Emails__c>();
                    
                    mapInvalidEmailByEmail.clear();
         			List<String> listEmails = new List<String>();
        
        			for (AccountApiRestModel.MethodsOfContactConsent consent : req.accountApi.methodOfContactConsent) {
            			if ((consent.channelType == Label.channelEmail) && (consent.channelValue != null)) {
                 			listEmails.add(consent.channelValue);
            			}
        			}
        
        			if(!listEmails.isEmpty()){
            			mapInvalidEmailByEmail = InvalidEmailGateway.getInvalidEmailByEmail(listEmails);
        			}   
                    
                    for (AccountApiRestModel.MethodsOfContactConsent consent : req.accountApi.methodOfContactConsent) {
                        String channelValue;
    
                        if(consent.purposeId.equalsIgnoreCase('CustomerSatisfactionSales') || consent.purposeId.equalsIgnoreCase('CustomerSatisfactionAfterSales') ||
                           consent.purposeId.equalsIgnoreCase('EAVE') || consent.purposeId.equalsIgnoreCase('Insurance') ){
                            String field = consent.purposeId.equalsIgnoreCase('EAVE')? 'eave__c':consent.purposeId + '__c';
                            Consentimientos__c consentimientoNoEcosistema;
                            if(mapConsentimientoTuUpdateById.containsKey(req.accountApi.companyId)){
                                consentimientoNoEcosistema = mapConsentimientoTuUpdateById.get(req.accountApi.companyId);
                            }
                            else{
                                if(mapConsentsByValue.containsKey(req.accountApi.companyId)){
                                    consentimientoNoEcosistema = mapConsentsByValue.get(req.accountApi.companyId);
                                }
//                                else if(consent.value.equalsIgnoreCase('Deny')) {
                                else {
                                    consentimientoNoEcosistema = new Consentimientos__c();
                                    consentimientoNoEcosistema.Contact__c = contacto.Id;
                                    consentimientoNoEcosistema.Concesionario__r = new Concesionario__c(Id_Concesionario_Sima__c = req.accountApi.companyId);
                                    consentimientoNoEcosistema.RecordTypeId = ConsentimientosGateway.getRecordTypeIdByDeveloperName(Label.RtConsentimientoNoEcosistema);
                                }
                            }
                            if (consentimientoNoEcosistema != null){
                                consentimientoNoEcosistema.put(field, consent.value);
                                consentimientoNoEcosistema.Fecha_de_captura__c = consentDate;
                                consentimientoNoEcosistema.EnviarAmulesoft__c = false;
                                mapConsentimientoTuUpdateById.put(req.accountApi.companyId, consentimientoNoEcosistema);
                            }            
                        }
                        else {
                            if (consent.channelType.equalsIgnoreCase('SMS') || consent.channelType.equalsIgnoreCase('Call')) {
                                String replaced = DataValidations.clearPhone(consent.channelValue);
                				consent.channelValue = replaced;
                            	channelValue =  DataValidations.validatePhone(consent.channelValue) ? DataValidations.transformPhone(consent.channelValue) : '';
                        	}
                            else {
                                channelValue = null;
                                if (!String.isBlank(consent.channelValue)){
                                    if(!DataValidations.validateEmail(consent.channelValue)){
                                        channelValue = null;
                                    }else if (mapInvalidEmailByEmail.containsKey(consent.channelValue)){    
                                        channelValue = null;
                                    }else {
                                        channelValue = consent.channelValue.toLowerCase();
                                    }
                                }
//                                channelValue = !String.isBlank(consent.channelValue)?consent.channelValue.toLowerCase(): consent.channelValue;
                            }
                        
                            if (!String.isBlank(channelValue) && mapConsentsByValue.containsKey(channelValue)) {
                            Consentimientos__c consentToUpdate = mapConsentsByValue.get(channelValue);
                            
                            if (consentToUpdate.Fecha_de_captura__c == null || (consentToUpdate.Fecha_de_captura__c != null && consentDate >= consentToUpdate.Fecha_de_captura__c)) {
                                consentToUpdate.Fecha_de_captura__c = consentDate;
                                consentToUpdate.EnviarAmulesoft__c = false;
                                String field = consent.purposeId;
                                
                                if (consent.channelType.equalsIgnoreCase('SMS')) {
                                    field += 'SMS__c';
                                }
                                else if (consent.channelType.equalsIgnoreCase('Call') || consent.channelType.equalsIgnoreCase('Email')) {
                                    field += '__c';
                                }
                                
                                consentToUpdate.put(field, consent.value);
                                mapConsentsByValue.put(channelValue, consentToUpdate);
                                mapConsentimientoTuUpdateById.put(consentToUpdate.Id, consentToUpdate);
                            }
                        }	
                        }
                       
                    }
                
                    if (!mapConsentimientoTuUpdateById.isEmpty()) {
                        upsert mapConsentimientoTuUpdateById.values();
                        ExternalServiceController.sendConsentimientoMulesoft(contacto.Id, cConcesionario.External_Id__c);
                    }
                    response.Status  = Label.errorStatus_Success;
        	        response.Message = Label.responseMessage_Success;
                }
                else {
                    response.Status  = Label.errorStatus_Success;
        	        response.Message = Label.responseMessage_Success;
//                    throw new CustomException('Consentimientos para cliente empresa');
                }
            }
            else {
                throw new CustomException('No existe cliente');
            }
        } catch(Exception e) {
            response.ErrorCode = '510';
            response.Status = Label.errorStatus_Error;
            response.Message = e.getMessage();

            Exception__c exc = new Exception__c ();
            exc.idObjetos__c = req.accountApi.customerId+'/'+ req.accountApi.companyId;
            exc.Exception__c = e.getCause() + '// '+ e.getMessage();
            exc.Linea__c = e.getLineNumber();
            exc.JSON_Entrada__c = JSON.serialize(req);
            exc.Clase_Metodo__c = 'AccountApiRestServiceController.upsertConsent';
            
            insert exc;
            
        }
        
        return response;
    }

    /*
    * eliminamos el cliente concesionario por anonimización del mismo en Sima
	*/
    public static ResponseApi CustomerRemoved(AccountApiRestModel req) {
        ResponseApi response = new ResponseApi();
        response.Message = '';
        String externalId = req.accountApi.customerId+'/'+ req.accountApi.companyId;
        Cliente_Concesionario__c cConcesionario = ClienteConcesionarioGateway.getClienteConcesionarioByIdExternal(req.accountApi.customerId, req.accountApi.companyId);
        try {
            if (cConcesionario != null) {
                delete cConcesionario;
            }
            AuxAccount__c auxAcc = AuxAccountGateway.getAuxAccountByExternalId(externalId);
            if (auxAcc != null){
                delete auxAcc;
            }    
            
            response.Message = Label.responseMessage_Success;
            response.Status = Label.errorStatus_Success;
        } catch(Exception e) {
            response.ErrorCode = '510';
            response.Status = Label.errorStatus_Error;
            response.Message = e.getMessage();

            Exception__c exc = new Exception__c ();
            exc.idObjetos__c = req.accountApi.customerId+'/'+ req.accountApi.companyId;
            exc.Exception__c = e.getCause() + '// '+ e.getMessage();
            exc.Linea__c = e.getLineNumber();
            exc.JSON_Entrada__c = JSON.serialize(req);
            exc.Clase_Metodo__c = 'AccountApiRestServiceController.CustomerRemoved';
            
            insert exc;
            
        }
        
        return response;
    }

    // Crea o actualiza registro cliente y consentimientos
    private static Account upsertCliente(AccountApiRestModel req, String idCliente, ResponseApi response, Boolean hayCC) {
        Map<String, Contact> mapAccountIdContacts = new Map<String, Contact>();
        Map<String, Consentimientos__c> mapConsentsByMethodValue = new Map<String, Consentimientos__c>();
        Map<String, Consentimientos__c> mapConsentsByMethoValueToUpsert = new Map<String, Consentimientos__c>();
        Map<String,Invalid_Emails__c> mapInvalidEmailByEmail = new Map<String,Invalid_Emails__c>();
        List<Consentimientos__c> lstConsents = new List<Consentimientos__c>();
       	Account cliente = new Account();
        if (req.accountApi.pais == null && req.accountApi.billingCountryIso != null) {
            req.accountApi.pais = req.accountApi.billingCountryIso;
        }
        List<String> lstCountries = new List<String>{req.accountApi.pais, req.accountApi.billingCountryIso, req.accountApi.shippingCountryIso};
		Map<String, Pais__c> mapCountries = PaisGateway.getPaisByAlfa2(lstCountries);
        Pais__c pais = mapCountries.get(req.accountApi.pais);
        System.debug('País: ' + pais);
        Pais__c billingCountry = mapCountries.get(req.accountApi.billingCountryIso);
        System.debug('billingCountry: ' + billingCountry);
        Pais__c shippingCountry = mapCountries.get(req.accountApi.shippingCountryIso);
        System.debug('shippingCountry: ' + shippingCountry);
        Boolean duplicado = false;
        Configuracion__c configuracion = Configuracion__c.getInstance();
        Integer limite = Integer.valueOf(configuracion.Limite_Cliente_Propio__c); 
        if (idCliente == '') {
            // Nuevo cliente
            Map<String, Schema.RecordTypeInfo> rtMapByDName = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
            String idRecordType = req.accountApi.isPersonAccount ? 
                rtMapByDName.get('PersonAccount').getRecordTypeId() : rtMapByDName.get('Cliente_Empresa').getRecordTypeId();
            cliente.RecordTypeId = idRecordType;
			cliente.Fecha_Alta_Sima__c = Datetime.now();
        }
        else {
            // Cliente ya existente
            // Buscamos sus contactos
            // Buscamos sus consentimientos
            cliente.Id = idCliente;
            //mapAccountIdContacts = ContactGateway.getContactByAccountId(new List<String>{idCliente});
            List<Consentimientos__c> lstConsentsByContact = [SELECT Id, ChannelValue__c, Medio_de_contacto__c, RecordTypeId
                                                         	 FROM Consentimientos__c
                                                         	 WHERE Contact__c IN
                                                         		(SELECT Id FROM Contact WHERE AccountId = :idCliente)];
            
        	for (Consentimientos__c consent : lstConsentsByContact) {
            	mapConsentsByMethodValue.put(consent.ChannelValue__c, consent);
        	}
        }
        
        if (!req.accountApi.isPersonAccount) {
            cliente.Name = req.accountApi.name;
        }
        else {
            cliente.FirstName = req.accountApi.firstName;
        	cliente.LastName = req.accountApi.lastName; 
        }
        
        cliente.Marca_registrada__c = req.accountApi.tradeName;
        cliente.Pais__c = pais != null ? pais.Id : null;
        
        // Keep old document type if document type in JSON is empty
        if (!String.isBlank(req.accountApi.tipoDocumento)) {
            cliente.Tipo_de_documento_cuenta_personal__c = Label.docType_VATId.equalsIgnoreCase(req.accountApi.tipoDocumento)
                || Label.docType_VATIdForForeigners.equalsIgnoreCase(req.accountApi.tipoDocumento)
                || Label.docType_Passport.equalsIgnoreCase(req.accountApi.tipoDocumento) 
                || Label.docType_OtherCountryVATId.equalsIgnoreCase(req.accountApi.tipoDocumento)
                ? req.accountApi.tipoDocumento : null;
        }
        
        if (!String.isBlank(req.accountApi.tipoDocumentoEmpresa)) {
            cliente.Tipo_de_documento_empresa__c = Label.docType_VATId.equalsIgnoreCase(req.accountApi.tipoDocumentoEmpresa)
                || Label.docType_OtherCountryVATId.equalsIgnoreCase(req.accountApi.tipoDocumentoEmpresa)
                ? req.accountApi.tipoDocumentoEmpresa : null;
        }

        // Keep old document number if document number in JSON is empty
        if (!String.isBlank(req.accountApi.documento)) {
            cliente.Documento__c = req.accountApi.documento.toUpperCase();
        }
        
        if (billingCountry != null) {
            cliente.BillingAddressId__c = req.accountApi.billingAddressId;
            if (!String.isBlank(req.accountApi.billingStreet)){
                cliente.BillingStreet = req.accountApi.billingStreet.length() < 255? req.accountApi.billingStreet.toUpperCase(): req.accountApi.billingStreet.toUpperCase().substring(0,254);
            } else if (!String.isBlank(req.accountApi.billingAddress)) {
                cliente.BillingStreet = req.accountApi.billingAddress.length() < 255? req.accountApi.billingAddress.toUpperCase(): req.accountApi.billingAddress.toUpperCase().substring(0,254);
            }
            if (!String.isBlank(req.accountApi.billingCity)) {
	        	cliente.BillingCity = req.accountApi.billingCity.length() < 40? req.accountApi.billingCity.toUpperCase() : req.accountApi.billingCity.toUpperCase().substring(0,39);
            }
        	cliente.BillingCountry = billingCountry != null ? billingCountry.Name.toUpperCase() : '';
            if (!String.isBlank(req.accountApi.billingPostalCode)) {
                cliente.BillingPostalCode = req.accountApi.billingPostalCode.length() < 20? req.accountApi.billingPostalCode.toUpperCase():req.accountApi.billingPostalCode.toUpperCase().substring(0,19);
            }
            if (!String.isBlank(req.accountApi.billingState)){
	        	cliente.BillingState = req.accountApi.billingState.length() < 80? req.accountApi.billingState.toUpperCase():req.accountApi.billingState.toUpperCase().substring(0,79);
            }
        }

        if (shippingCountry != null) {
            cliente.ShippingAddressId__c = req.accountApi.shippingAddressId;
            if (!String.isBlank(req.accountApi.shippingStreet)){
                cliente.ShippingStreet = req.accountApi.shippingStreet.length() < 255? req.accountApi.shippingStreet.toUpperCase(): req.accountApi.shippingStreet.toUpperCase().substring(0,254);
            } else if (!String.isBlank(req.accountApi.shippingAddress)) {
                cliente.ShippingStreet = req.accountApi.shippingAddress.length() < 255? req.accountApi.shippingAddress.toUpperCase(): req.accountApi.shippingAddress.toUpperCase().substring(0,254);
            }
            if (!String.isBlank(req.accountApi.shippingCity)) {
	        	cliente.ShippingCity = req.accountApi.shippingCity.length() < 40? req.accountApi.shippingCity.toUpperCase() : req.accountApi.shippingCity.toUpperCase().substring(0,39);
            }
        	cliente.ShippingCountry = shippingCountry != null ? shippingCountry.Name.toUpperCase() : '';
            if (!String.isBlank(req.accountApi.shippingPostalCode)) {
                cliente.ShippingPostalCode = req.accountApi.shippingPostalCode.length() < 20? req.accountApi.shippingPostalCode.toUpperCase():req.accountApi.shippingPostalCode.toUpperCase().substring(0,19);
            }
            if (!String.isBlank(req.accountApi.shippingState)){
	        	cliente.ShippingState = req.accountApi.shippingState.length() < 80? req.accountApi.shippingState.toUpperCase():req.accountApi.shippingState.toUpperCase().substring(0,79);
            }
        }
        
        cliente.ultima_modificacion_DMS__c = Datetime.now();
        cliente.typeCustomer__c = req.accountApi.typeCustomer != null ? req.accountApi.typeCustomer : null;
        cliente.drivingLicense__c = req.accountApi.drivingLicense != null ? req.accountApi.drivingLicense : null;
        
        system.debug(' 0 cliente.typeCustomer__c: '+cliente.typeCustomer__c);
        system.debug('0 cliente.drivingLicense__c: '+cliente.drivingLicense__c);
        
        
        // FORMAS DE CONTACTO En Cliente
        String errorCode = '';
        String errorMessage = '';

        mapInvalidEmailByEmail.clear();
        List<String> listEmails = new List<String>();
        
        for (AccountApiRestModel.MethodsOfContact methodsContact : req.accountApi.methodsOfContact) {
            if ((methodsContact.channel == Label.channelEmail) && (methodsContact.value != null)) {
                 listEmails.add(methodsContact.value);
            }
        }
        
        if(!listEmails.isEmpty()){
            mapInvalidEmailByEmail = InvalidEmailGateway.getInvalidEmailByEmail(listEmails);
        }   
        
        for (AccountApiRestModel.MethodsOfContact methodsContact : req.accountApi.methodsOfContact) {
            if (methodsContact.channel == Label.channelEmail) {
				if (!DataValidations.validateEmail(methodsContact.value)) {
                    methodsContact.value = null;
                } else if (mapInvalidEmailByEmail.containsKey(methodsContact.value)){    
                    methodsContact.value = null;
                }
                  
                if (methodsContact.value != null) {
					if (!req.accountApi.isPersonAccount) {
                    	if (String.isBlank(cliente.Email__c)) {
                        	cliente.Email__c = methodsContact.value;
                            methodsContact.channelFinal = Label.channelEmail;
                    	}
                    	else if(String.isBlank(cliente.Other_Email__c) && !cliente.Email__c.equalsIgnoreCase(methodsContact.value)) {
                        	cliente.Other_Email__c = methodsContact.value;
                            methodsContact.channelFinal = Label.channelOtherEmail;
                    	}
                	}
                	else {
                    	if (String.isBlank(cliente.PersonEmail)) {
                        	cliente.PersonEmail = methodsContact.value.toLowerCase();
                            methodsContact.channelFinal = Label.channelEmail;
                            
                            if (!mapConsentsByMethodValue.containsKey(cliente.PersonEmail)) {
                                Consentimientos__c consent = creaConsentimiento(cliente.PersonEmail, Label.channelEmail, 'Email');
                            	mapConsentsByMethoValueToUpsert.put(cliente.PersonEmail,consent);
                                //lstConsents.add(consent);
                            }
                            else {
                                // lo tenemos ya creado 
                                Consentimientos__c consent = mapConsentsByMethodValue.get(cliente.PersonEmail);
                                
                                if (!consent.Medio_de_contacto__c.equalsIgnoreCase(Label.channelEmail)) {
                                    consent.Medio_de_contacto__c = Label.channelEmail;
                                    mapConsentsByMethoValueToUpsert.put(cliente.PersonEmail,consent);
                                    //lstConsents.add(consent);
                                }
                            }
                    	}
                    	else if (String.isBlank(cliente.OtherEmail__pc) && !cliente.PersonEmail.equalsIgnoreCase(methodsContact.value) ) {
                        	cliente.OtherEmail__pc = methodsContact.value.toLowerCase();
                            methodsContact.channelFinal = Label.channelOtherEmail;
                            
                            if (!mapConsentsByMethodValue.containsKey(cliente.OtherEmail__pc)) {
                                Consentimientos__c consent = creaConsentimiento(cliente.OtherEmail__pc, Label.channelOtherEmail, 'Email');
                                mapConsentsByMethoValueToUpsert.put(cliente.OtherEmail__pc, consent);
                            	//lstConsents.add(consent);
                            }
                            else {
                                //lo tenemos ya creado 
                                Consentimientos__c consent = mapConsentsByMethodValue.get(cliente.OtherEmail__pc);
                                
                                if (!consent.Medio_de_contacto__c.equalsIgnoreCase(Label.channelOtherEmail)) {
                                    consent.Medio_de_contacto__c = Label.channelOtherEmail;
                                    mapConsentsByMethoValueToUpsert.put(cliente.OtherEmail__pc, consent);
                                    //lstConsents.add(consent);
                                }
                    		}
                        }
                    	else if (!cliente.PersonEmail.equalsIgnoreCase(methodsContact.value.toLowerCase()) && !cliente.OtherEmail__pc.equalsIgnoreCase(methodsContact.value.toLowerCase())) {
                            //Otro email para consentimiento
                            if (!mapConsentsByMethodValue.containsKey(methodsContact.value.toLowerCase())){
                                 Consentimientos__c consent = creaConsentimiento(methodsContact.value.toLowerCase(), Label.channelOther, 'Email');
                                 mapConsentsByMethoValueToUpsert.put(methodsContact.value.toLowerCase(), consent);
                                //lstConsents.add(consent);
                            }
                        }
                	}
                }
        	}    
            else if (methodsContact.channel == Label.channelWebsite) {
                cliente.Website = methodsContact.value;
            }
            else if (methodsContact.channel == Label.channelPhone || methodsContact.channel == Label.channelMobile) {
                
                // Telefónico
                // Limpiar valor del telefono
                String replaced = DataValidations.clearPhone(methodsContact.value);
                methodsContact.value = replaced;
                
                if (!DataValidations.validatePhone(methodsContact.value)){
                    methodsContact.value = null;
                }
                
                if (methodsContact.value != null) {
					System.debug('Es móvil: ' + DataValidations.isMobile(methodsContact.value));
                    String phone = DataValidations.transformPhone(methodsContact.value);
                    
                    if (DataValidations.isMobile(phone)) {
                        if (!req.accountApi.isPersonAccount) {
                    		if (String.isBlank(cliente.Mobile__c)) {
                        		cliente.Mobile__c = phone;
                                methodsContact.channelFinal = Label.channelMobile;
                            }
                    		else if (String.isBlank(cliente.Other_Mobile__c) && !cliente.Mobile__c.equalsIgnoreCase(phone)) {
                    			cliente.Other_Mobile__c	 = phone;
                                methodsContact.channelFinal = Label.channelOtherMobile;
                			}
                		}
                		else {
                     		if (String.isBlank(cliente.PersonMobilePhone)) {
                        		cliente.PersonMobilePhone = phone;
                                methodsContact.channelFinal = Label.channelMobile;
                                
                                if (!mapConsentsByMethodValue.containsKey(cliente.PersonMobilePhone)) {
                                	Consentimientos__c consent = creaConsentimiento(cliente.PersonMobilePhone, Label.channelMobile, 'Móvil');
                            		mapConsentsByMethoValueToUpsert.put(cliente.PersonMobilePhone, consent);
                                    //lstConsents.add(consent);
                            	}
                                else {
                                	// lo tenemos ya creado 
                                	Consentimientos__c consent = mapConsentsByMethodValue.get(cliente.PersonMobilePhone);
                                	
                                    if (!consent.Medio_de_contacto__c.equalsIgnoreCase(Label.channelMobile)) {
                                    	consent.Medio_de_contacto__c = Label.channelMobile;
                                        mapConsentsByMethoValueToUpsert.put(cliente.PersonMobilePhone, consent);
                                    	//lstConsents.add(consent);
                                	}
                            	}
                    		}
                    		else if (String.isBlank(cliente.OtherMobilePhone__pc) && !cliente.PersonMobilePhone.equalsIgnoreCase(phone)) {
                    			cliente.OtherMobilePhone__pc = phone;
                                methodsContact.channelFinal = Label.channelOtherMobile;
                                
                                if (!mapConsentsByMethodValue.containsKey(cliente.OtherMobilePhone__pc)) {
                                	Consentimientos__c consent = creaConsentimiento(cliente.OtherMobilePhone__pc, Label.channelOtherMobile, 'Móvil');
                            		mapConsentsByMethoValueToUpsert.put(cliente.OtherMobilePhone__pc, consent);
                                    //lstConsents.add(consent);
                            	}
                                else {
                                	// lo tenemos ya creado 
                                	Consentimientos__c consent = mapConsentsByMethodValue.get(cliente.OtherMobilePhone__pc);
                                	
                                    if (!consent.Medio_de_contacto__c.equalsIgnoreCase(Label.channelOtherMobile)) {
                                    	consent.Medio_de_contacto__c = Label.channelOtherMobile;
                                        mapConsentsByMethoValueToUpsert.put(cliente.OtherMobilePhone__pc, consent);
                                    	//lstConsents.add(consent);
                                	}
                            	}
                			}
                    		else if (!cliente.PersonMobilePhone.equalsIgnoreCase(phone) && !cliente.OtherMobilePhone__pc.equalsIgnoreCase(phone)) {
                                // consentimiento para los otros moviles
                                 if (!mapConsentsByMethodValue.containsKey(phone)) {
                                		Consentimientos__c consent = creaConsentimiento(phone, Label.channelOther, 'Móvil');
                           		 		mapConsentsByMethoValueToUpsert.put(phone, consent);
                                     //lstConsents.add(consent);
                            	 }
                            }
                		}
                    }
                    else {
                        if (!req.accountApi.isPersonAccount) {
                    		if (String.isBlank(cliente.Phone)) {
                        		cliente.Phone = phone;
                                methodsContact.channelFinal = Label.channelPhone;
                    		}
                    		else if (String.isBlank(cliente.Other_Phone__c) && !cliente.Phone.equalsIgnoreCase(phone)) {
                    			cliente.Other_Phone__c = phone;
                                methodsContact.channelFinal = Label.channelOtherPhone;
                			}
                		}
                		else {
                     		if (String.isBlank(cliente.Phone)) {
                        		cliente.Phone = phone;
                                methodsContact.channelFinal = Label.channelPhone;
                                
                                if (!mapConsentsByMethodValue.containsKey(cliente.Phone)) {
                                	Consentimientos__c consent = creaConsentimiento(cliente.Phone, Label.channelPhone, 'Teléfono');
                            		mapConsentsByMethoValueToUpsert.put(cliente.Phone, consent);
                                    //lstConsents.add(consent);
                            	}
                                else {
                                	// lo tenemos ya creado 
                                	Consentimientos__c consent = mapConsentsByMethodValue.get(cliente.Phone);
                                	
                                    if (!consent.Medio_de_contacto__c.equalsIgnoreCase(Label.channelPhone)) {
                                    	consent.Medio_de_contacto__c = Label.channelPhone;
                                        mapConsentsByMethoValueToUpsert.put(cliente.Phone, consent);
                                    	//lstConsents.add(consent);
                                	}
                            	}
                    		}
                    		else if (String.isBlank(cliente.PersonOtherPhone) && !cliente.Phone.equalsIgnoreCase(phone)) {
                    			cliente.PersonOtherPhone = phone;
                                methodsContact.channelFinal = Label.channelOtherPhone;
                                
                                if (!mapConsentsByMethodValue.containsKey(cliente.PersonOtherPhone)) {
                                	Consentimientos__c consent = creaConsentimiento(cliente.PersonOtherPhone, Label.channelOtherPhone, 'Teléfono');
                            		mapConsentsByMethoValueToUpsert.put(cliente.PersonOtherPhone, consent);
                                    //lstConsents.add(consent);
                            	}
                                else {
                                	// lo tenemos ya creado 
                                	Consentimientos__c consent = mapConsentsByMethodValue.get(cliente.PersonOtherPhone);
                                	
                                    if (!consent.Medio_de_contacto__c.equalsIgnoreCase(Label.channelOtherPhone)) {
                                    	consent.Medio_de_contacto__c = Label.channelOtherPhone;
                                        mapConsentsByMethoValueToUpsert.put(cliente.PersonOtherPhone, consent);
                                    	//lstConsents.add(consent);
                                	}
                            	}
                			}
                    		else if (!cliente.Phone.equalsIgnoreCase(phone) && !cliente.PersonOtherPhone.equalsIgnoreCase(phone)) {
                                // para otros telefonos guardar en consentimientos
                                if (!mapConsentsByMethodValue.containsKey(phone)){
                                		Consentimientos__c consent = creaConsentimiento(phone, Label.channelOther, 'Teléfono');
                           		 		mapConsentsByMethoValueToUpsert.put(phone, consent);
                                    //lstConsents.add(consent);
                            	 }
                            }
                		}
                    }
                }
            }
       	}

        if (errorCode != '' && errorMessage != '') {
            response.ErrorCode = errorCode;
			response.Message += errorMessage;
        }

        if (cliente.Id != null){
            Account cliente1 = AccountGateway.getAccountById(cliente.Id);
            if (req.accountApi.isPersonAccount){
	            if(!cliente1.Cliente_Propio__c && !hayCC){
    	            cliente.Cliente_Propio__c = true;
       		        cliente.Fecha_Limite_Cliente_Propio__c= Date.today().addDays(limite);
            	}
                if (cliente.PersonEmail != null && cliente.OtherEmail__pc == null && cliente1.OtherEmail__pc != null && cliente.PersonEmail == cliente1.OtherEmail__pc){
                    cliente.OtherEmail__pc = cliente1.PersonEmail;
                } 
                if (cliente.PersonMobilePhone != null && cliente.OtherMobilePhone__pc == null && cliente1.OtherMobilePhone__pc != null && cliente.PersonMobilePhone == cliente1.OtherMobilePhone__pc){
                    cliente.OtherMobilePhone__pc = cliente1.PersonMobilePhone;
                } 
                if (cliente.Phone != null && cliente.PersonOtherPhone == null && cliente1.PersonOtherPhone != null && cliente.Phone == cliente1.PersonOtherPhone){
                    cliente.PersonOtherPhone = cliente1.Phone;
                } 
            } else {
                if (cliente.Email__c != null && cliente.Other_Email__c == null && cliente1.Other_Email__c != null && cliente.Email__c == cliente1.Other_Email__c){
                    cliente.Other_Email__c = cliente1.Email__c;
                } 
                if (cliente.Mobile__c != null && cliente.Other_Mobile__c == null && cliente1.Other_Mobile__c != null && cliente.Mobile__c == cliente1.Other_Mobile__c){
                    cliente.Other_Mobile__c = cliente1.Mobile__c;
                } 
                if (cliente.Phone != null && cliente.Other_Phone__c == null && cliente1.Other_Phone__c != null && cliente.Phone == cliente1.Other_Phone__c){
                    cliente.Other_Phone__c = cliente1.Phone;
                } 
            }
            if (cliente.typeCustomer__c == null && cliente1.typeCustomer__c != null){
                cliente.typeCustomer__c = cliente1.typeCustomer__c;
            }
            if (cliente.drivingLicense__c == null && cliente1.drivingLicense__c != null){
                cliente.drivingLicense__c = cliente1.drivingLicense__c;
            }

        system.debug('10 cliente.typeCustomer__c: '+cliente.typeCustomer__c);
        system.debug('10 cliente.drivingLicense__c: '+cliente.drivingLicense__c);
        system.debug('11 cliente1.typeCustomer__c: '+cliente1.typeCustomer__c);
        system.debug('11 cliente1.drivingLicense__c: '+cliente1.drivingLicense__c);
            
        }    
        
        if (cliente.Id == null){
            // Find duplicates
            List<Account> lstDuplicates = new List<Account>();
            lstDuplicates.add(cliente);
            //Cambiamos de lugar los telefonos/emails o completamos el otro para tener un mayor exito en la busqueda de duplicados
            Account cliente1 = new Account(); 
            if(req.accountApi.isPersonAccount){
                cliente1.RecordTypeId = cliente.RecordTypeId;
                cliente1.FirstName = cliente.FirstName;
        	    cliente1.LastName = cliente.LastName; 
                if (cliente.OtherEmail__pc == null && cliente.PersonEmail != null) {
                    cliente1.OtherEmail__pc = cliente.PersonEmail;
                } else if (cliente.OtherEmail__pc != null && cliente.PersonEmail != null){
                    cliente1.OtherEmail__pc = cliente.PersonEmail;
                    cliente1.PersonEmail = cliente.OtherEmail__pc;
                }
                if (cliente.OtherMobilePhone__pc == null && cliente.PersonMobilePhone != null) {
                    cliente1.OtherMobilePhone__pc = cliente.PersonMobilePhone;
                } else if (cliente.OtherMobilePhone__pc != null && cliente.PersonMobilePhone != null){
                    cliente1.OtherMobilePhone__pc = cliente.PersonMobilePhone;
                    cliente1.PersonMobilePhone = cliente.OtherMobilePhone__pc;
                }
                if (cliente.PersonOtherPhone == null && cliente.Phone != null) {
                    cliente1.PersonOtherPhone = cliente.Phone;
                } else if (cliente.PersonOtherPhone != null && cliente.Phone != null) {
                    cliente1.PersonOtherPhone = cliente.Phone;
                    cliente1.Phone = cliente.PersonOtherPhone;
                }
            } else {
                cliente1.RecordTypeId = cliente.RecordTypeId;
                cliente1.Name = cliente.Name;
                if (cliente.Other_Email__c == null && cliente.Email__c != null) {
                    cliente1.Other_Email__c = cliente.Email__c;
                } else if (cliente.Other_Email__c != null && cliente.Email__c != null) {
                    cliente1.Other_Email__c = cliente.Email__c;
                    cliente1.Email__c = cliente.Other_Email__c;
                }
                if (cliente.Other_Mobile__c == null && cliente.Mobile__c != null) {
                    cliente1.Other_Mobile__c = cliente.Mobile__c;
                } else if (cliente.Other_Mobile__c != null && cliente.Mobile__c != null) {
                    cliente1.Other_Mobile__c = cliente.Mobile__c;
                    cliente1.Mobile__c = cliente.Other_Mobile__c;
                }
                if (cliente.Other_Phone__c == null && cliente.Phone != null) {
                    cliente1.Other_Phone__c = cliente.Phone;
                } else if (cliente.Other_Phone__c != null && cliente.Phone != null){
                    cliente1.Other_Phone__c = cliente.Phone;
                    cliente1.Phone = cliente.Other_Phone__c;
                }
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
                                    cliente.Id = auxAcc.Id;
                                    
                                    if (req.accountApi.isPersonAccount){

                                       cliente.PersonEmail = !String.isBlank(cliente.PersonEmail)?cliente.PersonEmail:auxAcc.PersonEmail;
                                       cliente.OtherEmail__pc = !String.isBlank(cliente.OtherEmail__pc)?cliente.OtherEmail__pc:auxAcc.OtherEmail__pc;
                                       cliente.PersonMobilePhone = !String.isBlank(cliente.PersonMobilePhone)?cliente.PersonMobilePhone:auxAcc.PersonMobilePhone;
                                       cliente.OtherMobilePhone__pc = !String.isBlank(cliente.OtherMobilePhone__pc)?cliente.OtherMobilePhone__pc:auxAcc.OtherMobilePhone__pc;
                                       cliente.Phone = !String.isBlank(cliente.Phone)?cliente.Phone:auxAcc.Phone;
                                       cliente.PersonOtherPhone = !String.isBlank(cliente.PersonOtherPhone)?cliente.PersonOtherPhone:auxAcc.PersonOtherPhone;
                                        
                                       if (cliente.PersonEmail == null && cliente.OtherEmail__pc != null ) {
                                           cliente.PersonEmail = cliente.OtherEmail__pc;
                                           cliente.OtherEmail__pc = null;
                                       }
                                       if (cliente.PersonEmail != null && cliente.OtherEmail__pc != null && cliente.PersonEmail == cliente.OtherEmail__pc){
                                           if (auxAcc.PersonEmail != null && auxAcc.PersonEmail != cliente.OtherEmail__pc) {
                                               cliente.OtherEmail__pc = auxAcc.PersonEmail;
                                           } else {
                                               cliente.OtherEmail__pc = null;
                                           }
                                       }
                                       if (cliente.OtherEmail__pc == null && auxAcc.PersonEmail != null && cliente.PersonEmail != null && auxAcc.PersonEmail != cliente.PersonEmail){
                                           cliente.OtherEmail__pc = auxAcc.PersonEmail;
                                       }
                                        
                                       if (cliente.PersonMobilePhone == null && cliente.OtherMobilePhone__pc != null ) {
                                           cliente.PersonMobilePhone = cliente.OtherMobilePhone__pc;
                                           cliente.OtherMobilePhone__pc = null;
                                       }
                                       if (cliente.PersonMobilePhone != null && cliente.OtherMobilePhone__pc != null && cliente.PersonMobilePhone == cliente.OtherMobilePhone__pc){
                                           if (auxAcc.PersonMobilePhone != null && auxAcc.PersonMobilePhone != cliente.OtherMobilePhone__pc) {
                                               cliente.OtherMobilePhone__pc = auxAcc.PersonMobilePhone;
                                           } else {
                                               cliente.OtherMobilePhone__pc = null;
                                           }
                                       }
                                       if (cliente.OtherMobilePhone__pc == null && auxAcc.PersonMobilePhone != null && cliente.PersonMobilePhone != null && auxAcc.PersonMobilePhone != cliente.PersonMobilePhone){
                                           cliente.OtherMobilePhone__pc = auxAcc.PersonMobilePhone;
                                       }
                                        
                                       if (cliente.Phone == null && cliente.PersonOtherPhone != null ) {
                                           cliente.Phone = cliente.PersonOtherPhone;
                                           cliente.PersonOtherPhone = null;
                                       }
                                       if (cliente.Phone != null && cliente.PersonOtherPhone != null && cliente.Phone == cliente.PersonOtherPhone){
                                           if (auxAcc.Phone != null && auxAcc.Phone != cliente.PersonOtherPhone) {
                                               cliente.PersonOtherPhone = auxAcc.Phone;
                                           } else {
                                               cliente.PersonOtherPhone = null;
                                           }
                                       }
                                       if (cliente.PersonOtherPhone == null && auxAcc.Phone != null && cliente.Phone != null && auxAcc.Phone != cliente.Phone){
                                           cliente.PersonOtherPhone = auxAcc.Phone;
                                       }
                                        
                                    }
                                    else {
                                       cliente.Email__c = !String.isBlank(cliente.Email__c)?cliente.Email__c:auxAcc.Email__c;
                                       cliente.Other_Email__c = !String.isBlank(cliente.Other_Email__c)?cliente.Other_Email__c:auxAcc.Other_Email__c;
                                       cliente.Phone = !String.isBlank(cliente.Phone)?cliente.Phone:auxAcc.Phone;
                                       cliente.Other_Phone__c = !String.isBlank(cliente.Other_Phone__c)?cliente.Other_Phone__c:auxAcc.Other_Phone__c;
                                       cliente.Mobile__c = !String.isBlank(cliente.Mobile__c)?cliente.Mobile__c:auxAcc.Mobile__c;
                                       cliente.Other_Mobile__c = !String.isBlank(cliente.Other_Mobile__c)?cliente.Other_Mobile__c:auxAcc.Other_Mobile__c;

                                       if (cliente.Email__c == null && cliente.Other_Email__c != null ) {
                                           cliente.Email__c = cliente.Other_Email__c;
                                           cliente.Other_Email__c = null;
                                       }
                                       if (cliente.Email__c != null && cliente.Other_Email__c != null && cliente.Email__c == cliente.Other_Email__c){
                                           if (auxAcc.Email__c != null && auxAcc.Email__c != cliente.Other_Email__c) {
                                               cliente.Other_Email__c = auxAcc.Email__c;
                                           } else {
                                               cliente.Other_Email__c = null;
                                           }
                                       }
                                       if (cliente.Other_Email__c == null && auxAcc.Email__c != null && cliente.Email__c != null && auxAcc.Email__c != cliente.Email__c){
                                           cliente.Other_Email__c = auxAcc.Email__c;
                                       }
                                        
                                       if (cliente.Mobile__c == null && cliente.Other_Mobile__c != null ) {
                                           cliente.Mobile__c = cliente.Other_Mobile__c;
                                           cliente.Other_Mobile__c = null;
                                       }
                                       if (cliente.Mobile__c != null && cliente.Other_Mobile__c != null && cliente.Mobile__c == cliente.Other_Mobile__c){
                                           if (auxAcc.Mobile__c != null && auxAcc.Mobile__c != cliente.Other_Mobile__c) {
                                               cliente.Other_Mobile__c = auxAcc.Mobile__c;
                                           } else {
                                               cliente.Other_Mobile__c = null;
                                           }
                                       }
                                       if (cliente.Other_Mobile__c == null && auxAcc.Mobile__c != null && cliente.Mobile__c != null && auxAcc.Mobile__c != cliente.Mobile__c){
                                           cliente.Other_Mobile__c = auxAcc.Mobile__c;
                                       }
                                        
                                       if (cliente.Phone == null && cliente.Other_Phone__c != null ) {
                                           cliente.Phone = cliente.Other_Phone__c;
                                           cliente.Other_Phone__c = null;
                                       }
                                       if (cliente.Phone != null && cliente.Other_Phone__c != null && cliente.Phone == cliente.Other_Phone__c){
                                           if (auxAcc.Phone != null && auxAcc.Phone != cliente.Other_Phone__c) {
                                               cliente.Other_Phone__c = auxAcc.Phone;
                                           } else {
                                               cliente.Other_Phone__c = null;
                                           }
                                       }
                                       if (cliente.Other_Phone__c == null && auxAcc.Phone != null && cliente.Phone != null && auxAcc.Phone != cliente.Phone){
                                           cliente.Other_Phone__c = auxAcc.Phone;
                                       }

                                    }
                                    
                                    duplicado = true;
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
                
        }
        
        if(duplicado){
            Account cliente1 = AccountGateway.getAccountById(cliente.Id);
            if(!cliente1.Cliente_Propio__c && !hayCC && cliente1.IsPersonAccount){
                cliente.Cliente_Propio__c = true;
                cliente.Fecha_Limite_Cliente_Propio__c= Date.today().addDays(limite);
            }
            if (cliente.typeCustomer__c == null && cliente1.typeCustomer__c != null){
                cliente.typeCustomer__c = cliente1.typeCustomer__c;
            }
            if (cliente.drivingLicense__c == null && cliente1.drivingLicense__c != null){
                cliente.drivingLicense__c = cliente1.drivingLicense__c;
            }
        system.debug('20 cliente.typeCustomer__c: '+cliente.typeCustomer__c);
        system.debug('20 cliente.drivingLicense__c: '+cliente.drivingLicense__c);
        system.debug('21 cliente1.typeCustomer__c: '+cliente1.typeCustomer__c);
        system.debug('21 cliente1.drivingLicense__c: '+cliente1.drivingLicense__c);
        } else if (cliente.Id == null){
            if(!hayCC && req.accountApi.isPersonAccount){
                cliente.Cliente_Propio__c = true;
                cliente.Fecha_Limite_Cliente_Propio__c= Date.today().addDays(limite);
            }
        }
        // Crear o actualizar Cuenta de cliente
       	upsert cliente;
        System.debug('INSERT CLIENTE: ' + cliente);
        
        // Añade el contacto relacionado con el cliente a los consentimientos
        Contact conCliente;
        //Si se ha encontrado por duplicado
         cliente = AccountGateway.getAccountById(cliente.Id);
        if(duplicado && cliente.IsPersonAccount){
              //buscamos nuevamente el contact
            mapAccountIdContacts = ContactGateway.getContactByAccountId(new List<String>{cliente.Id});
            conCliente = mapAccountIdContacts.get(cliente.Id);
            for (Consentimientos__c consent :[SELECT Id, ChannelValue__c, Medio_de_contacto__c, RecordTypeId,Contact__c
                                              FROM Consentimientos__c
                                              WHERE Contact__c =:conCliente.Id]) {
                if(mapConsentsByMethoValueToUpsert.containsKey(consent.ChannelValue__c)){
                    Consentimientos__c aux = mapConsentsByMethoValueToUpsert.get(consent.ChannelValue__c);
                    consent.Medio_de_contacto__c = aux.Medio_de_contacto__c;
                    consent.EnviarAmulesoft__c = false;
                    mapConsentsByMethoValueToUpsert.put(consent.ChannelValue__c, consent);
                }
                else {
                    consent.Medio_de_contacto__c = Label.channelOther;
                    mapConsentsByMethoValueToUpsert.put(consent.ChannelValue__c, consent);
        	}
        	}
        }
        else if(mapAccountIdContacts.isEmpty() && cliente.IsPersonAccount){
            mapAccountIdContacts = ContactGateway.getContactByAccountId(new List<String>{cliente.Id});
            conCliente = mapAccountIdContacts.get(cliente.Id);
        }
        else if(cliente.IsPersonAccount){
             conCliente = mapAccountIdContacts.get(cliente.Id);
        }
          
        //Ponemos a los consentimientos la relacion con el contacto y el tipo de medio de contacto correcto
        for(String value :mapConsentsByMethoValueToUpsert.keySet()){
            Consentimientos__c consent = mapConsentsByMethoValueToUpsert.get(value);
            if (cliente.PersonEmail != null && consent.ChannelValue__c == cliente.PersonEmail){
                consent.Medio_de_contacto__c = Label.channelEmail;
            }
            if (cliente.OtherEmail__pc != null && consent.ChannelValue__c == cliente.OtherEmail__pc){
                consent.Medio_de_contacto__c = Label.channelOtherEmail;
            }
            if (cliente.PersonMobilePhone != null && consent.ChannelValue__c == cliente.PersonMobilePhone){
                consent.Medio_de_contacto__c = Label.channelMobile;
            }
            if (cliente.OtherMobilePhone__pc != null && consent.ChannelValue__c == cliente.OtherMobilePhone__pc){
                consent.Medio_de_contacto__c = Label.channelOtherMobile;
            }
            if (cliente.Phone != null && consent.ChannelValue__c == cliente.Phone){
                consent.Medio_de_contacto__c = Label.channelPhone;
            }
            if (cliente.PersonOtherPhone != null && consent.ChannelValue__c == cliente.PersonOtherPhone){
                consent.Medio_de_contacto__c = Label.channelOtherPhone;
            }
            consent.contact__c = conCliente.Id;
            mapConsentsByMethoValueToUpsert.put(value,consent);
        }
        if (!mapConsentsByMethoValueToUpsert.isEmpty()) {
         	upsert mapConsentsByMethoValueToUpsert.values();
        }
      	system.debug('cliente:devuelto:'+cliente);
        return cliente;
    }
    
    // Crea instancia de  un consentimiento
    private static Consentimientos__c creaConsentimiento(String valor, String channel, String recordTypeName) {
        Consentimientos__c consent = new Consentimientos__c();
		consent.ChannelValue__c = valor;
		consent.Medio_de_contacto__c = channel;
		System.debug('recordtype: ' + rtMapConsentimientoByName);
		System.debug('recordtypeN :  ' + recordTypeName);

		consent.RecordTypeId = rtMapConsentimientoByName.get(recordTypeName).getRecordTypeId();
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
        
        return consent;
    }
    
    // Crea o actualiza registro "Cliente_Concesionario"
    private static void upsertClienteConcesionario(AccountApiRestModel req, Cliente_Concesionario__c clienteConcesionario,Account cliente, Concesionario__c concesionario) {
        List<Cliente_Concesionario__c> cConcesionarioToUpsert = new List<Cliente_Concesionario__c>();
        List<Cliente_Concesionario__c> cConcesionarios = ClienteConcesionarioGateway.searchClienteConcesionariosByAccountId(cliente.Id);
        
        if (clienteConcesionario == null) {
        	clienteConcesionario = new Cliente_Concesionario__c();
            clienteConcesionario.Concesionario__c = concesionario.Id;
            clienteConcesionario.Cliente__c = cliente.Id;
        }
        
        clienteConcesionario.Documento__c = !String.isBlank(req.accountApi.documento) ? req.accountApi.documento.toUpperCase() : cliente.Documento__c;
        clienteConcesionario.Id_Cliente_DMS__c = req.accountApi.customerId;		// y falla aqui ya que no esta declarado el clienteConcesionario
        clienteConcesionario.ID_BillingAddress__c = req.accountApi.billingAddressId;
        clienteConcesionario.ID_ShippingAddress__c = req.accountApi.shippingAddressId;
        clienteConcesionario.External_Id__c = req.accountApi.customerId +'/'+req.accountApi.companyId;
        clienteConcesionario.Origen__c = req.accountApi.origin == null? 'SIMA': req.accountApi.origin;
        System.debug('Estamos encima de los metodos de contacto: ' + req.accountApi.methodsOfContact);
        
        for (AccountApiRestModel.MethodsOfContact method : req.accountApi.methodsOfContact) {
            System.debug('MÉTODO DE CONTACTO: ' + method);
            
            if (method.channel == Label.channelWebsite) {
                clienteConcesionario.ID_Website__c = method.id;
            }
            else if (method.channel == Label.channelEmail && !String.isBlank(method.channelFinal) && method.value != null) {
                if (method.channelFinal.equalsIgnoreCase(Label.channelEmail)) {
                    clienteConcesionario.ID_Email__c = method.id;
                    clienteConcesionario.Email__c = method.value.toLowerCase();
                }
                else {
                    clienteConcesionario.ID_OtherEmail__c = method.id;
                    clienteConcesionario.OtherEmail__c = method.value.toLowerCase();
                }
            }
            else if ((method.channel == Label.channelMobile || method.channel == Label.channelPhone) && !String.isBlank(method.channelFinal) && method.value != null) {
                String phone = DataValidations.transformPhone(method.value);
                
                if (method.channelFinal.equalsIgnoreCase(Label.channelPhone)) {
                    clienteConcesionario.ID_Phone__c = method.id;
                    clienteConcesionario.Phone__c = phone;
                }
                else if(method.channelFinal.equalsIgnoreCase(Label.channelOtherPhone)) {
                    clienteConcesionario.ID_OtherPhone__c = method.id;
                    clienteConcesionario.OtherPhone__c = phone;
                }
                else if(method.channelFinal.equalsIgnoreCase(Label.channelMobile)) {
                    clienteConcesionario.ID_PersonMobilePhone__c = method.id;
                    clienteConcesionario.Mobile__c = phone;
                }
                else if (method.channelFinal.equalsIgnoreCase(Label.channelOtherMobile)) {
                    clienteConcesionario.ID_OtherPersonMobilePhone__c = method.id;
                    clienteConcesionario.OtherMobile__c = phone;
                }
            }
        }

        cConcesionarioToUpsert.add(clienteConcesionario);
        
        // Actualizar clienteConcesionarios relacionados con el cliente con el documento
        if (!cConcesionarios.isEmpty()) {
            for (Cliente_Concesionario__c cConcesionario : cConcesionarios) {
                if (!String.isBlank(req.accountApi.documento) && cConcesionario.Id != clienteConcesionario.Id ) {
                    cConcesionario.Documento__c = req.accountApi.documento.toUpperCase(); 
                    cConcesionarioToUpsert.add(cConcesionario);
                }
            }
        }
        List<Cliente_Concesionario__c> cConcesionarioExternal = new List<Cliente_Concesionario__c>();
        List<Cliente_Concesionario__c> cConcesionarioNotExternal = new List<Cliente_Concesionario__c>();
        if (!cConcesionarioToUpsert.isEmpty()) {
            for(Cliente_Concesionario__c cConcesionario : cConcesionarioToUpsert) {
                if(!String.isBlank(cConcesionario.External_Id__c)){
                    cConcesionarioExternal.add(cConcesionario);
                }
                else {
                    cConcesionarioNotExternal.add(cConcesionario);
                }
                
            }  

            if(!cConcesionarioExternal.isEmpty()){
//                upsert cConcesionarioExternal External_Id__c;
                Schema.SObjectField f = Cliente_Concesionario__c.Fields.External_Id__c;
                Database.UpsertResult [] cr = Database.upsert(cConcesionarioExternal, f); 
                for (Database.UpsertResult sr: cr) {
                     if (sr.isSuccess()) {
                         System.debug('Actualiza CConcesionario OK'+ sr.getId());
                     } else {
                         for(Database.Error err : sr.getErrors()) {
                             System.debug('Actualiza CConcesionario ERROR');
                             System.debug(err.getStatusCode() + ': ' + err.getMessage());
                             System.debug('Campos: ' + err.getFields());
                             
                             Exception__c exc = new Exception__c ();
                             exc.idObjetos__c = req.accountApi.customerId+'/'+ req.accountApi.companyId;
                             exc.Exception__c = err.getStatusCode() + '// ' + err.getMessage();
                             exc.Linea__c = 820;
                             exc.JSON_Entrada__c = JSON.serialize(req);
                             exc.Clase_Metodo__c = 'AccountApiRestServiceController.upsertClienteConcesionario';
                        
                             insert exc;
                         }
                     }       
                }
            }    
            
            if(!cConcesionarioNotExternal.isEmpty()){
                upsert cConcesionarioNotExternal;
            }
        }
    }

    private static void mergeAccounts(Account master, String duplicateId){
        Account duplicate = AccountGateway.getAccountById(duplicateId);
        system.debug('master: '+master);
        system.debug('duplicate: '+duplicate);
        Registros_Relacionados__c rr = new Registros_Relacionados__c();
        
        String DuplicateMergeString;
        List<String> listAccountId = new List<String> {master.Id, duplicateId};
        Map<String,Contact> mapContactByAccount = ContactGateway.getContactByAccountId(listAccountId);
        Map<String,Map<String,Consentimientos__c>> mapConsentimientoByAccount = ConsentimientosGateway.getConsentimientosByAccountId(listAccountId);
        AccountApiRestServiceController.mergeConsentimiento(master.id,duplicate.id,mapConsentimientoByAccount,mapContactByAccount);
        
        Account masterUpdate = new Account();
        if(duplicate.IsCustomerPortal){
            masterUpdate.Id = duplicate.Id;
            DuplicateMergeString = master.Id;
            rr.Registro_Origen__c = master.PersonContactId;
            rr.Registro_Destino__c = duplicate.PersonContactId;
        }
        else{
            masterUpdate.Id = master.Id;
            DuplicateMergeString = duplicate.Id;
        	rr.Registro_Origen__c = duplicate.PersonContactId;
        	rr.Registro_Destino__c = master.PersonContactId;
        
        }
        
        masterUpdate.Fecha_Alta_Sima__c = master.Fecha_Alta_Sima__c<duplicate.Fecha_Alta_Sima__c ? master.Fecha_Alta_Sima__c:duplicate.Fecha_Alta_Sima__c;
        masterUpdate.ultima_modificacion_DMS__c = master.ultima_modificacion_DMS__c> duplicate.ultima_modificacion_DMS__c ? master.ultima_modificacion_DMS__c : duplicate.ultima_modificacion_DMS__c;
        masterUpdate.Cliente_VN__c = master.Cliente_VN__c != duplicate.Cliente_VN__c ? true:master.Cliente_VN__c;
        if(master.Importe_VN__c != null && duplicate.Importe_VN__c != null){
            masterUpdate.Importe_VN__c = master.Importe_VN__c + duplicate.Importe_VN__c;
        }
        else{
        	masterUpdate.Importe_VN__c = master.Importe_VN__c != null ? master.Importe_VN__c:duplicate.Importe_VN__c;
        
        } 
        if(master.Fecha_primera_compra_VN__c != null && duplicate.Fecha_primera_compra_VN__c!= null){
            masterUpdate.Fecha_primera_compra_VN__c = master.Fecha_primera_compra_VN__c < duplicate.Fecha_primera_compra_VN__c ? master.Fecha_primera_compra_VN__c : duplicate.Fecha_primera_compra_VN__c;
        }
        else if(master.Fecha_primera_compra_VN__c != null ){
            masterUpdate.Fecha_primera_compra_VN__c = master.Fecha_primera_compra_VN__c;
        }
        else {
			masterUpdate.Fecha_primera_compra_VN__c = duplicate.Fecha_primera_compra_VN__c;            
        }
        if(master.Fecha_ultima_compra_VN__c != null && duplicate.Fecha_ultima_compra_VN__c!= null){
            masterUpdate.Fecha_ultima_compra_VN__c = master.Fecha_ultima_compra_VN__c < duplicate.Fecha_ultima_compra_VN__c ? duplicate.Fecha_ultima_compra_VN__c : master.Fecha_ultima_compra_VN__c;
        }
        else if(master.Fecha_ultima_compra_VN__c != null ){
            masterUpdate.Fecha_ultima_compra_VN__c = master.Fecha_ultima_compra_VN__c;
        }
        else {
			masterUpdate.Fecha_ultima_compra_VN__c = duplicate.Fecha_ultima_compra_VN__c;            
        }
        
        masterUpdate.Cliente_VO__c = master.Cliente_VO__c != duplicate.Cliente_VO__c ? true:master.Cliente_VO__c;
        if(master.Importe_VO__c != null && duplicate.Importe_VO__c != null){
            masterUpdate.Importe_VO__c = master.Importe_VO__c + duplicate.Importe_VO__c;
        }
        else{
        	masterUpdate.Importe_VO__c = master.Importe_VO__c != null ? master.Importe_VO__c:duplicate.Importe_VO__c;
        } 
        if(master.Fecha_primera_compra_VO__c != null && duplicate.Fecha_primera_compra_VO__c != null){
            masterUpdate.Fecha_primera_compra_VO__c = master.Fecha_primera_compra_VO__c < duplicate.Fecha_primera_compra_VO__c ? master.Fecha_primera_compra_VO__c : duplicate.Fecha_primera_compra_VO__c;
        }
        else if(master.Fecha_primera_compra_VO__c != null ){
            masterUpdate.Fecha_primera_compra_VO__c = master.Fecha_primera_compra_VO__c;
        }
        else {
			masterUpdate.Fecha_primera_compra_VO__c = duplicate.Fecha_primera_compra_VO__c;            
        }
        if(master.Fecha_ultima_compra_VO__c != null && duplicate.Fecha_ultima_compra_VO__c != null){
            masterUpdate.Fecha_ultima_compra_VO__c = master.Fecha_ultima_compra_VO__c > duplicate.Fecha_ultima_compra_VO__c ? master.Fecha_ultima_compra_VO__c : duplicate.Fecha_ultima_compra_VO__c;
        }
        else if(master.Fecha_ultima_compra_VO__c != null ){
            masterUpdate.Fecha_ultima_compra_VO__c = master.Fecha_ultima_compra_VO__c;
        }
        else {
			masterUpdate.Fecha_ultima_compra_VO__c = duplicate.Fecha_ultima_compra_VO__c;            
        }
        if(master.n_ventas_VO_3_ultimos_anos__c != null && duplicate.n_ventas_VO_3_ultimos_anos__c != null){
            masterUpdate.n_ventas_VO_3_ultimos_anos__c = master.n_ventas_VO_3_ultimos_anos__c + duplicate.n_ventas_VO_3_ultimos_anos__c;
        }
        else{
        	masterUpdate.n_ventas_VO_3_ultimos_anos__c = master.n_ventas_VO_3_ultimos_anos__c != null ? master.n_ventas_VO_3_ultimos_anos__c:duplicate.n_ventas_VO_3_ultimos_anos__c;
        } 
        
        masterUpdate.Cliente_Postventa__c = master.Cliente_Postventa__c != duplicate.Cliente_Postventa__c ? true:master.Cliente_Postventa__c;
        if(master.Importe_Postventa__c != null && duplicate.Importe_Postventa__c != null){
       		masterUpdate.Importe_Postventa__c = master.Importe_Postventa__c + duplicate.Importe_Postventa__c;
         }
        else{
        	masterUpdate.Importe_Postventa__c = master.Importe_Postventa__c != null ? master.Importe_Postventa__c : duplicate.Importe_Postventa__c;
        } 
        if(master.Fecha_primera_compra_Postventa__c != null && duplicate.Fecha_primera_compra_Postventa__c != null){
            masterUpdate.Fecha_primera_compra_Postventa__c = master.Fecha_primera_compra_Postventa__c < duplicate.Fecha_primera_compra_Postventa__c ? master.Fecha_primera_compra_Postventa__c : duplicate.Fecha_primera_compra_Postventa__c;
        }
        else if(master.Fecha_primera_compra_Postventa__c != null ){
            masterUpdate.Fecha_primera_compra_Postventa__c = master.Fecha_primera_compra_Postventa__c;
        }
        else {
			masterUpdate.Fecha_primera_compra_Postventa__c = duplicate.Fecha_primera_compra_Postventa__c;            
        }
        if(master.Fecha_ultima_compra_Postventa__c != null && duplicate.Fecha_ultima_compra_Postventa__c != null){
            masterUpdate.Fecha_ultima_compra_Postventa__c = master.Fecha_ultima_compra_Postventa__c > duplicate.Fecha_ultima_compra_Postventa__c ? master.Fecha_ultima_compra_Postventa__c : duplicate.Fecha_ultima_compra_Postventa__c;
        }
        else if(master.Fecha_ultima_compra_Postventa__c != null ){
            masterUpdate.Fecha_ultima_compra_Postventa__c = master.Fecha_ultima_compra_Postventa__c;
        }
        else {
			masterUpdate.Fecha_ultima_compra_Postventa__c = duplicate.Fecha_ultima_compra_Postventa__c;            
        }
        
        
        masterUpdate.Cliente_Recambios__c = master.Cliente_Recambios__c != duplicate.Cliente_Recambios__c ? true:master.Cliente_Recambios__c;
        if(master.Importe_Recambios__c != null && duplicate.Importe_Recambios__c != null){
       		masterUpdate.Importe_Recambios__c = master.Importe_Recambios__c + duplicate.Importe_Recambios__c;
        }
        else{
        	masterUpdate.Importe_Recambios__c = master.Importe_Recambios__c != null ? master.Importe_Recambios__c : duplicate.Importe_Recambios__c;
        } 
        if(master.Fecha_primera_compra_Recambios__c != null && duplicate.Fecha_primera_compra_Recambios__c != null){
            masterUpdate.Fecha_primera_compra_Recambios__c = master.Fecha_primera_compra_Recambios__c < duplicate.Fecha_primera_compra_Recambios__c ? master.Fecha_primera_compra_Recambios__c : duplicate.Fecha_primera_compra_Recambios__c;
        }
        else if(master.Fecha_primera_compra_Recambios__c != null ){
            masterUpdate.Fecha_primera_compra_Recambios__c = master.Fecha_primera_compra_Recambios__c;
        }
        else {
			masterUpdate.Fecha_primera_compra_Recambios__c = duplicate.Fecha_primera_compra_Recambios__c;            
        }
        if(master.Fecha_ltima_compra_Recambios__c != null && duplicate.Fecha_ltima_compra_Recambios__c != null){
            masterUpdate.Fecha_ltima_compra_Recambios__c = master.Fecha_ltima_compra_Recambios__c > duplicate.Fecha_ltima_compra_Recambios__c ? master.Fecha_ltima_compra_Recambios__c : duplicate.Fecha_ltima_compra_Recambios__c;
        }
        else if(master.Fecha_ltima_compra_Recambios__c != null ){
            masterUpdate.Fecha_ltima_compra_Recambios__c = master.Fecha_ltima_compra_Recambios__c;
        }
        else {
			masterUpdate.Fecha_ltima_compra_Recambios__c = duplicate.Fecha_ltima_compra_Recambios__c;            
        }
        
        
        masterUpdate.Cliente_Mobility__c = master.Cliente_Mobility__c != duplicate.Cliente_Mobility__c ? true:master.Cliente_Mobility__c;
        if(master.Importe_Mobility__c != null && duplicate.Importe_Mobility__c != null){
       		masterUpdate.Importe_Mobility__c = master.Importe_Mobility__c + duplicate.Importe_Mobility__c;
        }
        else{
        	masterUpdate.Importe_Mobility__c = master.Importe_Mobility__c != null ? master.Importe_Mobility__c : duplicate.Importe_Mobility__c;
        } 
        if(master.Fecha_primera_compra_Mobility__c != null && duplicate.Fecha_primera_compra_Mobility__c != null){
            masterUpdate.Fecha_primera_compra_Mobility__c = master.Fecha_primera_compra_Mobility__c < duplicate.Fecha_primera_compra_Mobility__c ? master.Fecha_primera_compra_Mobility__c : duplicate.Fecha_primera_compra_Mobility__c;
        }
        else if(master.Fecha_primera_compra_Mobility__c != null ){
            masterUpdate.Fecha_primera_compra_Mobility__c = master.Fecha_primera_compra_Mobility__c;
        }
        else {
			masterUpdate.Fecha_primera_compra_Mobility__c = duplicate.Fecha_primera_compra_Mobility__c;            
        }
        if(master.Fecha_ultima_compra_Mobility__c != null && duplicate.Fecha_ultima_compra_Mobility__c != null){
            masterUpdate.Fecha_ultima_compra_Mobility__c = master.Fecha_ultima_compra_Mobility__c > duplicate.Fecha_ultima_compra_Mobility__c ? master.Fecha_ultima_compra_Mobility__c : duplicate.Fecha_ultima_compra_Mobility__c;
        }
        else if(master.Fecha_ultima_compra_Mobility__c != null ){
            masterUpdate.Fecha_ultima_compra_Mobility__c = master.Fecha_ultima_compra_Mobility__c;
        }
        else {
			masterUpdate.Fecha_ultima_compra_Mobility__c = duplicate.Fecha_ultima_compra_Mobility__c;            
        }

        masterUpdate.Consentimiento_target__c = master.Consentimiento_target__c != duplicate.Consentimiento_target__c ? true:master.Consentimiento_target__c;
        if (master.IsPersonAccount == true) { 
            masterUpdate.PersonEmail = master.PersonEmail != null ? master.PersonEmail:duplicate.PersonEmail;
            masterUpdate.OtherEmail__pc = master.OtherEmail__pc != null ? master.OtherEmail__pc:duplicate.OtherEmail__pc;
            masterUpdate.Phone = master.Phone != null ? master.Phone:duplicate.Phone;
            masterUpdate.PersonOtherPhone = master.PersonOtherPhone != null ? master.PersonOtherPhone:duplicate.PersonOtherPhone;
            masterUpdate.PersonMobilePhone = master.PersonMobilePhone != null ? master.PersonMobilePhone:duplicate.PersonMobilePhone;
            masterUpdate.OtherMobilePhone__pc = master.OtherMobilePhone__pc != null ? master.OtherMobilePhone__pc:duplicate.OtherMobilePhone__pc;
	        masterUpdate.gender__pc = master.gender__pc != null ? master.gender__pc:duplicate.gender__pc;
	        masterUpdate.incomes__pc = master.incomes__pc != null ? master.incomes__pc:duplicate.incomes__pc;
	        masterUpdate.position__pc = master.position__pc != null ? master.position__pc:duplicate.position__pc;
	        masterUpdate.maritalStatus__pc = master.maritalStatus__pc != null ? master.maritalStatus__pc:duplicate.maritalStatus__pc;
	        masterUpdate.economicSector__pc = master.economicSector__pc != null ? master.economicSector__pc:duplicate.economicSector__pc;
            masterUpdate.Occupation__pc = master.Occupation__pc != null ? master.Occupation__pc:duplicate.Occupation__pc;
    
            if(master.ChildrenCount__pc != null && duplicate.ChildrenCount__pc != null){
                masterUpdate.ChildrenCount__pc = master.ChildrenCount__pc > duplicate.ChildrenCount__pc ? master.ChildrenCount__pc:duplicate.ChildrenCount__pc;
            }
            else if(master.ChildrenCount__pc != null ){
                masterUpdate.ChildrenCount__pc = master.ChildrenCount__pc;
            }
            else {
                masterUpdate.ChildrenCount__pc = duplicate.ChildrenCount__pc;            
            }
            
            masterUpdate.PersonBirthdate = master.PersonBirthdate != null ? master.PersonBirthdate:duplicate.PersonBirthdate;
        } else {
            masterUpdate.Email__c = master.Email__c != null ? master.Email__c:duplicate.Email__c;
            masterUpdate.Other_Email__c =  master.Other_Email__c != null ? master.Other_Email__c:duplicate.Other_Email__c;
            masterUpdate.Phone = master.Phone != null ? master.Phone:duplicate.Phone;
            masterUpdate.Other_Phone__c = master.Other_Phone__c != null ? master.Other_Phone__c:duplicate.Other_Phone__c;
            masterUpdate.Mobile__c = master.Mobile__c != null ? master.Mobile__c:duplicate.Mobile__c;
            masterUpdate.Other_Mobile__c = master.Other_Mobile__c != null ? master.Other_Mobile__c:duplicate.Other_Mobile__c;
        }
            
        masterUpdate.Pais__c = master.Pais__c != null ? master.Pais__c:duplicate.Pais__c;
        If (master.BillingStreet == null && duplicate.BillingStreet != null) {
            masterUpdate.BillingAddressId__c = duplicate.BillingAddressId__c;
            masterUpdate.BillingStreet = duplicate.BillingStreet;
            masterUpdate.BillingCity = duplicate.BillingCity;
            masterUpdate.BillingCountry = duplicate.BillingCountry;
            masterUpdate.BillingPostalCode = duplicate.BillingPostalCode;
            masterUpdate.BillingState = duplicate.BillingState;
        }
        If (master.ShippingStreet == null && duplicate.ShippingStreet != null) {
            masterUpdate.ShippingAddressId__c = duplicate.ShippingAddressId__c;
            masterUpdate.ShippingStreet = duplicate.ShippingStreet;
            masterUpdate.ShippingCity = duplicate.ShippingCity;
            masterUpdate.ShippingCountry = duplicate.ShippingCountry;
            masterUpdate.ShippingPostalCode = duplicate.ShippingPostalCode;
            masterUpdate.ShippingState = duplicate.ShippingState;
        }

        if(master.Fecha_ultima_factura__c != null && duplicate.Fecha_ultima_factura__c != null){
	        masterUpdate.Fecha_ultima_factura__c = master.Fecha_ultima_factura__c > duplicate.Fecha_ultima_factura__c ? master.Fecha_ultima_factura__c : duplicate.Fecha_ultima_factura__c;
        }
        else if(master.Fecha_ultima_factura__c != null ){
            masterUpdate.Fecha_ultima_factura__c = master.Fecha_ultima_factura__c;
        }
        else {
			masterUpdate.Fecha_ultima_factura__c = duplicate.Fecha_ultima_factura__c;            
        }
        
        if(master.Marca__c != null && duplicate.Marca__c != null){
	        List<string> marcas = new List<string>();
	        List<string> marcas1 = new List<string>();
            if (master.Marca__c != null) {
                system.debug('master.Marca__c: '+master.Marca__c );
                marcas.addAll(master.Marca__c.split(';'));
                system.debug('1_marcas:'+marcas);
            }
            if (duplicate.Marca__c != null) {
                system.debug('duplicate.Marca__c: '+duplicate.Marca__c );
                marcas1.addAll(duplicate.Marca__c.split(';'));
	            if (!marcas1.isEmpty()) {
 	                for(string marca1 : marcas1){
                        boolean encontrado = false;
	 	                for(string marca2 : marcas){
                            if (marca1 == marca2) {
                                encontrado = true;
                                break;
                            }
                        }
                        if (encontrado == false) {marcas.add(marca1);}
                    }
                }
            }
            if (!marcas.isEmpty()) {
                // recorremos la lista de grupos homogeneos
                for(Integer i =0 ; i<marcas.size();i++){
                    String marca = marcas[i];
                    if (i==0){
                        masterUpdate.Marca__c = marca;
                    } else{
                        masterUpdate.Marca__c += ';'+marca;
                    }
                }
                system.debug('masterUpdate.Marca__c:'+masterUpdate.Marca__c);
            }    
        }
        else if(master.Marca__c != null ){
            masterUpdate.Marca__c = master.Marca__c;
        }
        else {
			masterUpdate.Marca__c = duplicate.Marca__c;            
        }

        masterUpdate.Tipo_de_documento_cuenta_personal__c = master.Tipo_de_documento_cuenta_personal__c != null ? master.Tipo_de_documento_cuenta_personal__c:duplicate.Tipo_de_documento_cuenta_personal__c;                                                
        masterUpdate.Documento__c = master.Documento__c != null ? master.Documento__c:duplicate.Documento__c;
        masterUpdate.isFichaUnica__c = master.isFichaUnica__c || duplicate.isFichaUnica__c? true:false;
        if (master.typeCustomer__c != null) {
	        masterUpdate.typeCustomer__c = master.typeCustomer__c;
        } else {
	        masterUpdate.typeCustomer__c = duplicate.typeCustomer__c;
        }
        if (master.drivingLicense__c != null) {
	        masterUpdate.drivingLicense__c = master.drivingLicense__c;
        } else {
	        masterUpdate.drivingLicense__c = duplicate.drivingLicense__c;
        }

        masterUpdate.Cliente_Propio__c = master.Cliente_Propio__c || duplicate.Cliente_Propio__c? true:false;
        if (master.Cliente_Propio__c) {
            if (master.Fecha_Limite_Cliente_Propio__c != null && duplicate.Fecha_Limite_Cliente_Propio__c != null) {
		        masterUpdate.Fecha_Limite_Cliente_Propio__c = master.Fecha_Limite_Cliente_Propio__c > duplicate.Fecha_Limite_Cliente_Propio__c ? master.Fecha_Limite_Cliente_Propio__c : duplicate.Fecha_Limite_Cliente_Propio__c;
            } else {
                masterUpdate.Fecha_Limite_Cliente_Propio__c = master.Fecha_Limite_Cliente_Propio__c;
            }
        } else if (duplicate.Cliente_Propio__c) {
                masterUpdate.Fecha_Limite_Cliente_Propio__c = duplicate.Fecha_Limite_Cliente_Propio__c;
        }
        
        update masterUpdate;
        
        insert rr;
        
        Database.MergeResult results = Database.merge(masterUpdate, DuplicateMergeString);
    }
      
    private static void mergeConsentimiento(String masterId, String duplicateId, Map<String,Map<String,Consentimientos__c>> mapConsentimientoByAccounts, Map<String,Contact> mapContactByAccount){
		Map<String,Consentimientos__c> mapConsentimientoByClaveMaster =  mapConsentimientoByAccounts.containsKey(masterId)? mapConsentimientoByAccounts.get(masterId): new Map<String,Consentimientos__c>();
        Map<String,Consentimientos__c> mapConsentimientoByClaveDuplicate = mapConsentimientoByAccounts.containsKey(duplicateId)? mapConsentimientoByAccounts.get(duplicateId): new Map<String,Consentimientos__c>();
        Contact contacto =  mapContactByAccount.get(masterId);
        List<Consentimientos__c> listConsentimientoToUpdate = new List<Consentimientos__c>();
        List<Consentimientos__c> listConsentimientoDelete = new List<Consentimientos__c>();
        
        for(Consentimientos__c conse : mapConsentimientoByClaveDuplicate.values()){
            if(Label.RtConsentimientoEmail.equalsIgnoreCase(conse.RecordType.DeveloperName) || 
               Label.RtConsentimientoMobile.equalsIgnoreCase(conse.RecordType.DeveloperName) || 
               Label.RtConsentimientoPhone.equalsIgnoreCase(conse.RecordType.DeveloperName)){
           		   if(mapConsentimientoByClaveMaster.containsKey(conse.ChannelValue__c)){
               			Consentimientos__c conseAccount = mapConsentimientoByClaveMaster.get(conse.ChannelValue__c);
                        if((conseAccount.Fecha_de_captura__c != null && conse.Fecha_de_captura__c != null && conseAccount.Fecha_de_captura__c < conse.Fecha_de_captura__c)
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
         				}
                		else {
                			listConsentimientoDelete.add(conse);
                 		}
               		}
    	       	   else {
                    	conse.Contact__c = contacto != null? contacto.Id:null;
                    	conse.Lead__c = null;
                    	conse.EnviarAmulesoft__c = false;
                    	conse.Medio_de_contacto__c = Label.channelOther;
                    	listConsentimientoToUpdate.add(conse);
                	}    
               }
            else if(Label.RtConsentimientoInterLegMKTCCS.equalsIgnoreCase(conse.RecordType.DeveloperName)){
            			String identificador = conse.recordTypeId+'/'+conse.Concesionario__r.Id_Concesionario_Sima__c+'/'+conse.Marca__c;
                        if(mapConsentimientoByClaveMaster.containsKey(identificador)){
                        	Consentimientos__c conseAccount = mapConsentimientoByClaveMaster.get(identificador);
                            if(conse.LastModifiedDate>=conseAccount.LastModifiedDate){
                                listConsentimientoDelete.add(conseAccount);
                                conse.Contact__c = contacto != null? contacto.Id:null;
                    			conse.Lead__c = null;
                    			conse.EnviarAmulesoft__c = false;
                    			listConsentimientoToUpdate.add(conse); 
                            }
                            else{
                                listConsentimientoDelete.add(conse);
                            }
                        }
                        else {
                        	conse.Contact__c = contacto != null? contacto.Id:null;
                    		conse.Lead__c = null;
                    		conse.EnviarAmulesoft__c = false;
                    		listConsentimientoToUpdate.add(conse); 
                        }
            }
            else if(Label.RtConsentimientoNoEcosistema.equalsIgnoreCase(conse.RecordType.DeveloperName)){
            			String identificador = conse.Concesionario__r.Id_Concesionario_Sima__c;
                        if(mapConsentimientoByClaveMaster.containsKey(identificador)){
                        	Consentimientos__c conseAccount = mapConsentimientoByClaveMaster.get(identificador);
                            if(conse.LastModifiedDate >= conseAccount.LastModifiedDate){
                                listConsentimientoDelete.add(conseAccount);
                                conse.Contact__c = contacto != null? contacto.Id:null;
                    			conse.Lead__c = null;
                    			conse.EnviarAmulesoft__c = false;
                    			listConsentimientoToUpdate.add(conse); 
                            }
                            else{
                                listConsentimientoDelete.add(conse);
                            }
                        }
                        else {
                        	conse.Contact__c = contacto != null? contacto.Id:null;
                    		conse.Lead__c = null;
                    		conse.EnviarAmulesoft__c = false;
                    		listConsentimientoToUpdate.add(conse); 
                        }                                 
                  }
            else if(Label.RtConsentimientoEcosistemaDAG.equalsIgnoreCase(conse.RecordType.DeveloperName) ){}
            else if(Label.RtConsentimientoFichaUnica.equalsIgnoreCase(conse.RecordType.DeveloperName)){
            			String identificador = conse.recordTypeId;
                        if(mapConsentimientoByClaveMaster.containsKey(identificador)){
                        	Consentimientos__c conseAccount = mapConsentimientoByClaveMaster.get(identificador);
                            if(conse.oppositionDate__c == null && conseAccount.oppositionDate__c != null ){
                                listConsentimientoDelete.add(conseAccount);
                                conse.Contact__c = contacto != null? contacto.Id:null;
                    			conse.Lead__c = null;
                    			conse.EnviarAmulesoft__c = false;
                    			listConsentimientoToUpdate.add(conse); 
                            }
                            else{
                                listConsentimientoDelete.add(conse);
                            }
                        }
                        else {
                        	conse.Contact__c = contacto != null? contacto.Id:null;
                    		conse.Lead__c = null;
                    		conse.EnviarAmulesoft__c = false;
                    		listConsentimientoToUpdate.add(conse); 
                        }
            }
        }
        
        system.debug('listConsentimientoToUpdate:'+ listConsentimientoToUpdate);
        if (!listConsentimientoToUpdate.isEmpty()) {
            update listConsentimientoToUpdate;
        }
        
        system.debug('listConsentimientoDelete:'+ listConsentimientoDelete);
        if (!listConsentimientoDelete.isEmpty()) {
            Database.delete(listConsentimientoDelete);
        }
	}
    
}