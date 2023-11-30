public class AuxAccountHandler implements ITriggerHandler  {
  
    public Map<String,Cliente_Concesionario__c> mapCConcesionarioByAuxAccountToUpsert = new Map<String,Cliente_Concesionario__c>(); //lista
    public Map<String,Account>mapClienteByAuxAccountToUpsert = new Map<String,Account>(); // lista
    
    public Map<String, Account> mapCuentaById = new Map<String,Account>();
    public Map<String, Contact> mapContactByAccountId = new Map<String,Contact>();
    public Map<String, Account> mapCuentaByDni = new Map<String,Account>();
    public Map<String, Account> mapCuentaByTelefono = new Map<String,Account>();
    public Map<String, Account> mapCuentaByOtherTelefono = new Map<String,Account>();
    public Map<String, Account> mapCuentaByEmail = new Map<String,Account>();
    public Map<String,Account> mapCuentaByOtherEmail = new Map<String,Account>();
    public Map<String,Account> mapCuentaByMobile = new Map<String,Account>();
   	public Map<String,Account> mapCuentaByOtherMobile = new Map<String,Account>();
    public Map<String,Cliente_Concesionario__c> mapClienteConcesionarioById = new Map<String,Cliente_Concesionario__c>();
    public Map<String,Cliente_Concesionario__c> mapClienteConcesionarioByIdExternal = new Map<String,Cliente_Concesionario__c>();
    
    public Map<String,String> mapDniAuxAccount = new Map<String,String>();
    public Map<String,String> mapEmailAuxAccount = new Map<String,String>();
    public Map<String,String> mapTelefonoAuxAccount = new Map<String,String>();

	public Map<String,Pais__c> mapPaisByidExt = new Map<String,Pais__c>();   
    public Map<String,Concesionario__c> mapConsecionarioByIdExt = new Map<String,Concesionario__c>();
    
    public Map<String, Schema.RecordTypeInfo> rtMapByDName = new Map<String, Schema.RecordTypeInfo>();
    public Map<String,Map<String,Consentimientos__c>> mapValueToConsentimientoByAccountId = new Map<String,Map<String,Consentimientos__c>>();
    
    private TriggerExecutionHelper infoTrigger = new TriggerExecutionHelper();
    
    
    public AuxAccountHandler(Schema.sObjectType soType) {
        InfoTrigger.setTipoHandler(soType);
    }
    
    public TriggerExecutionHelper getInfo() {
        return infoTrigger;
    }
    
    public void bulkBefore() {
        
    }

    public void bulkAfter() {
        /*
        mapCConcesionarioByAuxAccountToUpsert.clear();
    	mapClienteByAuxAccountToUpsert.clear();
    	mapCuentaById.clear();
        mapContactByAccountId.clear();
    	mapCuentaByDni.clear();
    	mapCuentaByTelefono.clear();
    	mapCuentaByEmail.clear();
    	mapCuentaByMobile.clear();
   		mapClienteConcesionarioById.clear();
    	mapClienteConcesionarioByIdExternal.clear();
    	mapDniAuxAccount.clear();
    	mapEmailAuxAccount.clear();
    	mapTelefonoAuxAccount.clear();
		mapPaisByidExt.clear();
    	mapConsecionarioByIdExt.clear();
        mapCuentaByOtherTelefono.clear();
        mapCuentaByOtherEmail.clear();
        mapCuentaByOtherMobile.clear();
    
        
        if (Trigger.new != null) {
            rtMapByDName = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
            List<String> listExternalId = new List<String>();
            List<String> listDNI = new List<String>();
            List<String> listEmail = new List<String>();
            List<String> listTelefono = new List<String>();
            List<String> listMobile = new List<String>();
            List<String> listCustomerId = new List<String>();
            List<String> listCompanyId = new List<String>();
            List<String> listPaisIdAux = new List<String>();
            for (SObject objeto : Trigger.New) {
                AuxAccount__c auxiliar = (AuxAccount__c) objeto;
                if(!String.isBlank(auxiliar.taxId_number_nuevo_txt__c)){
                    listDNI.add(auxiliar.taxId_number_nuevo_txt__c);
                }
                if(!String.isBlank(auxiliar.CustomerId__c) && !String.isBlank(auxiliar.CompanyId__c) ){
                    String externalID = auxiliar.CustomerId__c+'/'+auxiliar.CompanyId__c;
                    listExternalId.add(externalID);
                    listCustomerId.add(auxiliar.CustomerId__c);
                    listCompanyId.add(auxiliar.CompanyId__c);
                }
                
                
                if(!String.isBlank(auxiliar.countryIso31661__c)){
                    listPaisIdAux.add(auxiliar.countryIso31661__c);
                }
               
            }
            if(!listDNI.isEmpty()){
                
                List<String> listAccountAuxId = new List<String>();
            	for(Account cuenta :[Select Id,Name,isPersonAccount,Email__c,Other_Email__c, Phone,Other_Phone__c,Mobile__c,Other_Mobile__c,RecordTypeId, Documento__c
                                 	from Account Where  Documento__c != NULL AND Documento__c in : listDNI  limit 400]){
               
                	mapCuentaById.put(cuenta.Id, cuenta);
                    String documento = cuenta.Documento__c.toUpperCase();
                	mapCuentaByDni.put(documento, cuenta);
                	if(!cuenta.IsPersonAccount){ // es empresa
                    if(!String.isBlank(cuenta.Email__c)){
                        String emailAux = cuenta.Email__c+'/'+cuenta.Name;
                		mapCuentaByEmail.put(emailAux, cuenta);
                    }
                    if(!String.isBlank(cuenta.Other_Email__c)){
                        String emailAux2 = cuenta.Other_Email__c+'/'+cuenta.Name;
                    	mapCuentaByOtherEmail.put(emailAux2, cuenta);
                    }
                    if(!String.isBlank(cuenta.Mobile__c)){
                        String mobileAux = cuenta.Mobile__c+'/'+cuenta.Name;
                		mapCuentaByMobile.put(mobileAux, cuenta); 
                    }
                    if(!String.isBlank(cuenta.Other_Mobile__c)){
                        String mobileAux2 = cuenta.Other_Mobile__c+'/'+cuenta.Name;
                		mapCuentaByOtherMobile.put(mobileAux2, cuenta); 
                    }
                    if(!String.isBlank(cuenta.Phone)){
                        String telefonoAux =cuenta.Phone+'/'+cuenta.Name;
                		mapCuentaByTelefono.put(telefonoAux, cuenta);
                    }
                    if(!String.isBlank(cuenta.Other_Phone__c)){
                        String telefonoAux2 =cuenta.Other_Phone__c+'/'+cuenta.Name;
                		mapCuentaByOtherTelefono.put(telefonoAux2, cuenta);
                    }
                    
                 }
                	else {//es personal
                    listAccountAuxId.add(cuenta.Id);
                }
                }
                if(!listAccountAuxId.isEmpty()){
                    for(Contact contacto :[SELECT Id, FirstName,LastName,Email, Phone ,MobilePhone , OtherEmail__c , OtherPhone , OtherMobilePhone__c, AccountId FROM Contact where AccountId in :listAccountAuxId AND AccountId != NULL Limit 400]){
                    	Account cuenta = mapCuentaById.get(contacto.AccountId);
                        mapContactByAccountId.put(contacto.AccountId, contacto);
                        if(!String.isBlank(contacto.Email)){
                        	String emailAux = contacto.Email+'/'+contacto.FirstName +'/' + contacto.LastName;
                        	mapCuentaByEmail.put(emailAux, cuenta);
                    }
                    	if(!String.isBlank(contacto.OtherEmail__c)){
                        String emailAux2 = contacto.OtherEmail__c+'/'+contacto.FirstName +'/' + contacto.LastName;
                		mapCuentaByOtherEmail.put(emailAux2, cuenta);
                    }
                    	if(!String.isBlank(contacto.MobilePhone)){
                        String mobileAux = contacto.MobilePhone+'/'+contacto.FirstName +'/' + contacto.LastName;
                		mapCuentaByMobile.put(mobileAux, cuenta); 
                    }
                    	if(!String.isBlank(contacto.OtherMobilePhone__c)){
                        String mobileAux2 = contacto.OtherMobilePhone__c+'/'+contacto.FirstName+'/' + contacto.LastName;
                		mapCuentaByOtherMobile.put(mobileAux2, cuenta); 
                    }
                    	if(!String.isBlank(contacto.Phone)){
                        String telefonoAux =contacto.Phone+'/'+contacto.FirstName +'/' + contacto.LastName;
                		mapCuentaByTelefono.put(telefonoAux, cuenta);
                    }
                    	if(!String.isBlank(contacto.OtherPhone)){
                      	String telefonoAux2 = contacto.OtherPhone+'/'+contacto.FirstName +'/' + contacto.LastName;
                		mapCuentaByOtherTelefono.put(telefonoAux2, cuenta);
                    }
                	}
                }
            }
           
            if(!mapCuentaById.isEmpty()){
                List<String> auxIdAccount = new List<String>();
                auxIdAccount.addAll(mapCuentaById.keySet());
                mapValueToConsentimientoByAccountId = ConsentimientosGateway.getConsentimientosByAccountId(auxIdAccount);
            }
            
            if(!listExternalId.isEmpty()){
                mapConsecionarioByIdExt =  ConcesionarioGateway.getConcessionaireByCompanyId(listCompanyId);
            		for(Cliente_Concesionario__c cConcesionario : [SELECT Id,Name, Cliente__c,External_Id__c,Concesionario__c,Id_Cliente_DMS__c,
														Concesionario__r.Id_Concesionario_Sima__c, Concesionario__r.Name
                                       					FROM Cliente_Concesionario__c
                                       					 WHERE  External_Id__c in :listExternalId limit 400
                                                          ]){
             			mapClienteConcesionarioById.put(cConcesionario.Id, cConcesionario);
             			String idExternalAux = cConcesionario.Id_Cliente_DMS__c + '/'+ cConcesionario.Concesionario__r.Id_Concesionario_Sima__c;                                                
             			mapClienteConcesionarioByIdExternal.put(idExternalAux,cConcesionario);
             			}
            		
               }         
            if(!listPaisIdAux.isEmpty()){
                mapPaisByIdExt = PaisGateway.getPaisByAlfa2(listPaisIdAux);
            }
            
      	}
        */
    }

    public void beforeInsert(sObject so) {
       
    }
    
    public void beforeUpdate(sObject old, sObject so) {
       
    }
    
    public void beforeDelete(sObject so) {}
    
    public void afterInsert(sObject so) {
       /*
        AuxAccount__c auxiliar = (AuxAccount__c) so;
        String emailAux ='';
        String emailAuxOther ='';
        String telefonoAux ='';
        String telefonoAuxOther ='';
        String mobileAux='';
        String mobileAuxOther='';
        String name='';
        String lastname='';
        Boolean crear = true;
        String idExternal = auxiliar.customerId__c+'/'+auxiliar.companyId__c;
        
        // Limpiar valor del telefono
          String replacedTelefono = !String.isBlank(auxiliar.Phone__c) ?DataValidations.clearPhone(auxiliar.phone__c):'';
          String replacedTelefonoOther =!String.isBlank(auxiliar.OtherPhone__c)?DataValidations.clearPhone(auxiliar.otherphone__c):'';
          String replacedMobile = !String.isBlank(auxiliar.Mobile__c)?DataValidations.clearPhone(auxiliar.mobile__c):'';
          String replacedMobileOther =!String.isBlank(auxiliar.OtherMobile__c)? DataValidations.clearPhone(auxiliar.othermobile__c):'';
          
        if(auxiliar.PersonType__c.equalsIgnoreCase('NaturalPerson')){ //es persona
            name = auxiliar.name__c;
            if(String.isBlank(auxiliar.firstSurname__c) && String.isBlank(auxiliar.secondSurname__c) ){
                lastname = name;
            }
            else if (String.isBlank(auxiliar.secondSurname__c)){
                lastname = auxiliar.firstSurname__c;
            }
            else if(String.isBlank(auxiliar.firstSurname__c)){
                lastname = auxiliar.secondSurname__c;
            }
            else{
				lastname = auxiliar.firstSurname__c + ' '+ auxiliar.secondSurname__c;             
           }
            system.debug('lastname:'+lastname);
           // lastname =!String.isBlank(auxiliar.firstSurname__c) !String.isBlank(auxiliar.secondSurname__c)?auxiliar.firstSurname__c + ' '+ auxiliar.secondSurname__c:auxiliar.firstSurname__c;
        	String email = !String.isBlank( auxiliar.Email__c)?auxiliar.Email__c.toLowerCase():null;
            String email_aux2 = !String.isBlank( auxiliar.OtherEmail__c)?auxiliar.OtherEmail__c.toLowerCase():null;
            emailAux =!String.isBlank(lastname)? email+'/'+name +'/' + lastname:email+'/'+name ;
            emailAuxOther =!String.isBlank(lastname)? email_aux2+'/'+name +'/' + lastname:email_aux2+'/'+name ; //emailAux =!String.isBlank(auxiliar.secondSurname__c)?emailAux+ ' '+ auxiliar.secondSurname__c:emailAux;
        	telefonoAux =!String.isBlank(lastname)? replacedTelefono+'/'+name +'/' + lastname:replacedTelefono+'/'+name;
            telefonoAuxOther =!String.isBlank(lastname)? replacedTelefonoOther+'/'+name +'/' + lastname: replacedTelefonoOther+'/'+name;
            //telefonoAux =!String.isBlank(auxiliar.secondSurname__c)?telefonoAux + ' ' + auxiliar.secondSurname__c:telefonoAux;
        	mobileAux =!String.isBlank(lastname)? replacedMobile+'/'+name +'/' + lastname: replacedMobile+'/'+name;
            mobileAuxOther =!String.isBlank(lastname)? replacedMobileOther+'/'+name +'/' + lastname:replacedMobileOther+'/'+name;
            //mobileAux = !String.isBlank()?mobileAux + ' ' + auxiliar.secondSurname__c:mobileAux;
        }
        else{
            name = auxiliar.fiscalName__c;
            String email = !String.isBlank( auxiliar.Email__c)?auxiliar.Email__c.toLowerCase():null;
            String email_aux2 = !String.isBlank( auxiliar.OtherEmail__c)?auxiliar.OtherEmail__c.toLowerCase():null;
            emailAux = email+'/'+auxiliar.fiscalName__c;
            emailAuxOther = email_aux2+'/'+auxiliar.fiscalName__c;
        	telefonoAux = replacedTelefono+'/'+auxiliar.fiscalName__c;
            telefonoAuxOther = replacedTelefonoOther+'/'+auxiliar.fiscalName__c;
        	mobileAux = replacedMobile+'/'+auxiliar.fiscalName__c;
            mobileAuxOther = replacedMobileOther+'/'+auxiliar.fiscalName__c;
        }
        system.debug(' mobileAux: '+mobileAux+' emailAux: '+emailAux+' telefonoAux: '+telefonoAux);
        system.debug('mobileAuxOther: '+mobileAuxOther+' emailAuxOther: '+emailAuxOther+' telefonoAuxOther: '+telefonoAuxOther);
        
        if(mapClienteConcesionarioByIdExternal.containsKey(idExternal)){
            crear= false;
        }
        System.debug('mapa:'+ mapCuentaByDni);
        String documento = !String.isBlank(auxiliar.taxId_number_nuevo_txt__c)? auxiliar.taxId_number_nuevo_txt__c.toUpperCase():'';
        if(crear && !String.isBlank(documento) && mapCuentaByDni.containsKey(documento)){
            
            //existe en la bbdd mediante dni o se va a insertar
            //crear ClienteConcesionario (verificar que no esta creado)
            system.debug('cazado con el documento');
            crear = false;
            Account clienteAux = mapCuentaByDni.get(documento);
            //mirar si ya esta creado cliente y por tanto mirar si ya esta creado los consentimientos
            
            //mapClienteByAuxAccountToUpsert.put(auxiliar.Id,clienteAux);
            //String idExternal = auxiliar.customerId__c+auxiliar.companyId__c;
            if(!mapClienteConcesionarioByIdExternal.containsKey(idExternal)){
                Cliente_Concesionario__c cConcesionario = new Cliente_Concesionario__c();
                Concesionario__c con = mapConsecionarioByIdExt.get(auxiliar.CompanyId__c);
                cConcesionario.Concesionario__c = con.Id;
                if(String.isBlank(clienteAux.Id)){
                        	mapClienteByAuxAccountToUpsert.put(auxiliar.Id,clienteAux);
                    	}
                    	else{
                        	cConcesionario.Cliente__c= clienteAux.Id;
                            system.debug('clienteId:'+clienteAux.Id);
                    	}

                cConcesionario.Documento__c = clienteAux.Documento__c;
                cConcesionario.Id_Cliente_DMS__c = auxiliar.customerId__c;
                cConcesionario.External_Id__c = auxiliar.customerId__c+'/'+auxiliar.companyId__c;
                cConcesionario.customerId_actual__c = auxiliar.customerId_actual__c;
                cConcesionario.customerType_actual__c = auxiliar.customerType_actual__c;
                mapCConcesionarioByAuxAccountToUpsert.put(auxiliar.id, cConcesionario);
            }
            
            
            
        }
        else if (crear && !String.isBlank(emailAux) && mapCuentaByEmail.containsKey(emailAux)){
            //existe en la bbdd mediante email o se va a insertar
            //crear ClienteConcesionario
            system.debug('cazado con el email');
            Account clienteAux = mapCuentaByEmail.get(emailAux);
            if(auxiliar.PersonType__c.equalsIgnoreCase('NaturalPerson')){
                system.debug('mapContactByAccountId:'+ mapContactByAccountId);
                system.debug('cliente:'+ clienteAux);
                Contact contacto =!String.isBlank(clienteAux.Id)?mapContactByAccountId.get(clienteAux.Id):null;
                system.debug('contacto:'+ contacto);
                if((contacto == null && (!clienteAux.FirstName.equalsIgnoreCase(name) || !clienteAux.LastName.equalsIgnoreCase(lastname))) ||
                   (contacto != null && (!contacto.FirstName.equalsIgnoreCase(name) || !contacto.LastName.equalsIgnoreCase(lastname)))){
                    crear= true;
                    system.debug('crear nuevo:name'+name + ' /'+ clienteAux.FirstName);
                    system.debug('crear nuevo:lastname'+lastname + ' /'+ clienteAux.LastName);
                }
            	else{
                	crear=false;
                    if(!mapClienteConcesionarioByIdExternal.containsKey(idExternal)){
                		Cliente_Concesionario__c cConcesionario = new Cliente_Concesionario__c();
                		Concesionario__c con = mapConsecionarioByIdExt.get(auxiliar.CompanyId__c);
                        cConcesionario.Concesionario__c = con.Id;
                        if(String.isBlank(clienteAux.Id)){
                        	mapClienteByAuxAccountToUpsert.put(auxiliar.Id,clienteAux);
                    	}
                    	else{
                        	cConcesionario.Cliente__c= clienteAux.Id;
                            system.debug('clienteId:'+clienteAux.Id);
                    	}
                		cConcesionario.Documento__c = clienteAux.Documento__c;
                        cConcesionario.External_Id__c = auxiliar.customerId__c+'/'+auxiliar.companyId__c;
                		cConcesionario.Id_Cliente_DMS__c = auxiliar.customerId__c;
                        cConcesionario.ID_BillingAddress__c = auxiliar.Invoicing_addresses_id__c;
                        cConcesionario.ID_ShippingAddress__c = auxiliar.Delivering_addresses_id__c;
                        cConcesionario.customerId_actual__c = auxiliar.customerId_actual__c;
                		cConcesionario.customerType_actual__c = auxiliar.customerType_actual__c;
                        if(!String.isBlank(auxiliar.Email__c)){
                            cConcesionario.Email__c = auxiliar.Email__c.toLowerCase();
                			cConcesionario.ID_Email__c = auxiliar.ID_Email__c;
                        }
                        if(!String.isBlank(replacedMobile)){
                            cConcesionario.Mobile__c = replacedMobile;
                			cConcesionario.ID_PersonMobilePhone__c = auxiliar.ID_Mobile__c;
                        }
                      	if(!String.isBlank(replacedTelefono)){
                            cConcesionario.Phone__c = replacedTelefono;
                			cConcesionario.ID_Phone__c = auxiliar.ID_Phone__c;
                        }
                        if(!String.isBlank(auxiliar.OtherEmail__c)){
                            cConcesionario.OtherEmail__c = auxiliar.OtherEmail__c.toLowerCase();
                			cConcesionario.ID_OtherEmail__c = auxiliar.ID_OtherEmail__c;
                        }
                        if(!String.isBlank(replacedMobileOther)){
                            cConcesionario.OtherMobile__c = replacedMobileOther;
                			cConcesionario.ID_OtherPersonMobilePhone__c = auxiliar.ID_OtherMobile__c;
                        }
                        if(!String.isBlank(replacedTelefonoOther)){
                            cConcesionario.OtherPhone__c = replacedTelefonoOther;
                			cConcesionario.ID_OtherPhone__c = auxiliar.ID_OtherPhone__c;
                        }
                        mapCConcesionarioByAuxAccountToUpsert.put(auxiliar.id, cConcesionario);
            		}
				}        
            }
            else {
                if(!clienteAux.Name.equalsIgnoreCase(name)){
                    crear = true;
                    system.debug('crear nuevo:name empresa'+name + ' /'+ clienteAux.Name);
                   // system.debug('crear nuevo:lastname'+lastname + ' /'+ clienteAux.LastName);
                }
                else{
                    crear=false;
                	//mapClienteByAuxAccountToUpsert.put(auxiliar.Id,clienteAux);
            		//String idExternal = auxiliar.customerId__c+auxiliar.companyId__c;
            		if(!mapClienteConcesionarioByIdExternal.containsKey(idExternal)){
                		Cliente_Concesionario__c cConcesionario = new Cliente_Concesionario__c();
                		Concesionario__c con = mapConsecionarioByIdExt.get(auxiliar.CompanyId__c);
                		cConcesionario.Concesionario__c = con.Id;
                        if(String.isBlank(clienteAux.Id)){
                        	mapClienteByAuxAccountToUpsert.put(auxiliar.Id,clienteAux);
                    	}
                    	else{
                        	cConcesionario.Cliente__c= clienteAux.Id;
                    	}
                		cConcesionario.Documento__c = clienteAux.Documento__c;
                		cConcesionario.Id_Cliente_DMS__c = auxiliar.customerId__c;
                        cConcesionario.ID_ShippingAddress__c = auxiliar.Delivering_addresses_id__c;
                        cConcesionario.ID_ShippingAddress__c = auxiliar.Delivering_addresses_id__c;
        				cConcesionario.customerId_actual__c = auxiliar.customerId_actual__c;
                		cConcesionario.customerType_actual__c = auxiliar.customerType_actual__c;
                        if(!String.isBlank(auxiliar.Email__c)){
                            cConcesionario.Email__c = auxiliar.Email__c;
                			cConcesionario.ID_Email__c = auxiliar.ID_Email__c;
                        }
                        if(!String.isBlank(auxiliar.Mobile__c)){
                            cConcesionario.Mobile__c = auxiliar.Mobile__c;
                			cConcesionario.ID_PersonMobilePhone__c = auxiliar.ID_Mobile__c;
                        }
                      	if(!String.isBlank(auxiliar.Phone__c)){
                            cConcesionario.Phone__c = auxiliar.Phone__c;
                			cConcesionario.ID_Phone__c = auxiliar.ID_Phone__c;
                        }
                        if(!String.isBlank(auxiliar.OtherEmail__c)){
                            cConcesionario.OtherEmail__c = auxiliar.OtherEmail__c;
                			cConcesionario.ID_OtherEmail__c = auxiliar.ID_OtherEmail__c;
                        }
                        if(!String.isBlank(auxiliar.OtherMobile__c)){
                            cConcesionario.OtherMobile__c = auxiliar.OtherMobile__c;
                			cConcesionario.ID_OtherPersonMobilePhone__c = auxiliar.ID_OtherMobile__c;
                        }
                        if(!String.isBlank(auxiliar.OtherPhone__c)){
                            cConcesionario.OtherPhone__c = auxiliar.OtherPhone__c;
                			cConcesionario.ID_OtherPhone__c = auxiliar.ID_OtherPhone__c;
                        }
                        
                		mapCConcesionarioByAuxAccountToUpsert.put(auxiliar.id, cConcesionario);
            		}
                }
            }
        }
        else if(crear && !String.isBlank(telefonoAux) && mapCuentaByTelefono.containsKey(telefonoAux)){
            //existe en la bbdd mediante el telefono o se va a insertar
            // crear Cliente Concesionario
            system.debug('cazado con el telefono');
            Account clienteAux = mapCuentaByTelefono.get(telefonoAux);
            
            if(auxiliar.PersonType__c.equalsIgnoreCase('NaturalPerson')){
               Contact contacto =!String.isBlank(clienteAux.Id)?mapContactByAccountId.get(clienteAux.Id):null;
                if((contacto == null && (!clienteAux.FirstName.equalsIgnoreCase(name) || !clienteAux.LastName.equalsIgnoreCase(lastname))) ||
                   (contacto != null && (!contacto.FirstName.equalsIgnoreCase(name) || !contacto.LastName.equalsIgnoreCase(lastname)))){
                    crear= true;
                    system.debug('crear nuevo:name'+name + ' /'+ clienteAux.FirstName);
                    system.debug('crear nuevo:lastname'+lastname + ' /'+ clienteAux.LastName);
                }
            	else{
                	//mapClienteByAuxAccountToUpsert.put(auxiliar.Id,clienteAux);
            		//String idExternal = auxiliar.customerId__c+auxiliar.companyId__c;
            		crear = false;
            		if(!mapClienteConcesionarioByIdExternal.containsKey(idExternal)){
                		Cliente_Concesionario__c cConcesionario = new Cliente_Concesionario__c();
                		Concesionario__c con = mapConsecionarioByIdExt.get(auxiliar.CompanyId__c);
                		cConcesionario.Concesionario__c = con.Id;
                        if(String.isBlank(clienteAux.Id)){
                        	mapClienteByAuxAccountToUpsert.put(auxiliar.Id,clienteAux);
                    	}
                    	else{
                        	cConcesionario.Cliente__c= clienteAux.Id;
                            system.debug('clienteId:'+clienteAux.Id);
                    	}
                		cConcesionario.Documento__c = clienteAux.Documento__c;
                        cConcesionario.External_Id__c = auxiliar.customerId__c+'/'+auxiliar.companyId__c;
                		cConcesionario.Id_Cliente_DMS__c = auxiliar.customerId__c;
                        cConcesionario.ID_ShippingAddress__c = auxiliar.Delivering_addresses_id__c;
                        cConcesionario.ID_ShippingAddress__c = auxiliar.Delivering_addresses_id__c;
        				cConcesionario.customerId_actual__c = auxiliar.customerId_actual__c;
                		cConcesionario.customerType_actual__c = auxiliar.customerType_actual__c;
                        if(!String.isBlank(auxiliar.Email__c)){
                            cConcesionario.Email__c = auxiliar.Email__c;
                			cConcesionario.ID_Email__c = auxiliar.ID_Email__c;
                        }
                        if(!String.isBlank(auxiliar.Mobile__c)){
                            cConcesionario.Mobile__c = auxiliar.Mobile__c;
                			cConcesionario.ID_PersonMobilePhone__c = auxiliar.ID_Mobile__c;
                        }
                      	if(!String.isBlank(auxiliar.Phone__c)){
                            cConcesionario.Phone__c = auxiliar.Phone__c;
                			cConcesionario.ID_Phone__c = auxiliar.ID_Phone__c;
                        }
                        if(!String.isBlank(auxiliar.OtherEmail__c)){
                            cConcesionario.OtherEmail__c = auxiliar.OtherEmail__c;
                			cConcesionario.ID_OtherEmail__c = auxiliar.ID_OtherEmail__c;
                        }
                        if(!String.isBlank(auxiliar.OtherMobile__c)){
                            cConcesionario.OtherMobile__c = auxiliar.OtherMobile__c;
                			cConcesionario.ID_OtherPersonMobilePhone__c = auxiliar.ID_OtherMobile__c;
                        }
                        if(!String.isBlank(auxiliar.OtherPhone__c)){
                            cConcesionario.OtherPhone__c = auxiliar.OtherPhone__c;
                			cConcesionario.ID_OtherPhone__c = auxiliar.ID_OtherPhone__c;
                        }
                        
                		mapCConcesionarioByAuxAccountToUpsert.put(auxiliar.id, cConcesionario);
            		}
				}        
            }
            else {
                if(!clienteAux.Name.equalsIgnoreCase(name)){
                    crear = true;
                    system.debug('crear nuevo:name empresa'+name + ' /'+ clienteAux.Name);
                    //system.debug('crear nuevo:lastname'+lastname + ' /'+ clienteAux.LastName);
                }
                else{
                    crear=false;
                	//mapClienteByAuxAccountToUpsert.put(auxiliar.Id,clienteAux);
            		//String idExternal = auxiliar.customerId__c+auxiliar.companyId__c;
            		if(!mapClienteConcesionarioByIdExternal.containsKey(idExternal)){
                		Cliente_Concesionario__c cConcesionario = new Cliente_Concesionario__c();
                        Concesionario__c con = mapConsecionarioByIdExt.get(auxiliar.CompanyId__c);
                		cConcesionario.Concesionario__c = con.Id;
                        if(String.isBlank(clienteAux.Id)){
                        	mapClienteByAuxAccountToUpsert.put(auxiliar.Id,clienteAux);
                    	}
                    	else{
                        	cConcesionario.Cliente__c= clienteAux.Id;
                            system.debug('clienteId:'+clienteAux.Id);
                    	}

                		cConcesionario.Documento__c = clienteAux.Documento__c;
                		cConcesionario.Id_Cliente_DMS__c = auxiliar.customerId__c;
                        cConcesionario.ID_ShippingAddress__c = auxiliar.Delivering_addresses_id__c;
                        cConcesionario.ID_ShippingAddress__c = auxiliar.Delivering_addresses_id__c;
        				cConcesionario.customerId_actual__c = auxiliar.customerId_actual__c;
                		cConcesionario.customerType_actual__c = auxiliar.customerType_actual__c;
                        if(!String.isBlank(auxiliar.Email__c)){
                            cConcesionario.Email__c = auxiliar.Email__c;
                			cConcesionario.ID_Email__c = auxiliar.ID_Email__c;
                        }
                        if(!String.isBlank(auxiliar.Mobile__c)){
                            cConcesionario.Mobile__c = auxiliar.Mobile__c;
                			cConcesionario.ID_PersonMobilePhone__c = auxiliar.ID_Mobile__c;
                        }
                      	if(!String.isBlank(auxiliar.Phone__c)){
                            cConcesionario.Phone__c = auxiliar.Phone__c;
                			cConcesionario.ID_Phone__c = auxiliar.ID_Phone__c;
                        }
                        if(!String.isBlank(auxiliar.OtherEmail__c)){
                            cConcesionario.OtherEmail__c = auxiliar.OtherEmail__c;
                			cConcesionario.ID_OtherEmail__c = auxiliar.ID_OtherEmail__c;
                        }
                        if(!String.isBlank(auxiliar.OtherMobile__c)){
                            cConcesionario.OtherMobile__c = auxiliar.OtherMobile__c;
                			cConcesionario.ID_OtherPersonMobilePhone__c = auxiliar.ID_OtherMobile__c;
                        }
                        if(!String.isBlank(auxiliar.OtherPhone__c)){
                            cConcesionario.OtherPhone__c = auxiliar.OtherPhone__c;
                			cConcesionario.ID_OtherPhone__c = auxiliar.ID_OtherPhone__c;
                        }
                        
                		mapCConcesionarioByAuxAccountToUpsert.put(auxiliar.id, cConcesionario);
            		}
                }
            }
            
        }
        else if(crear && !String.isBlank(mobileAux) && mapCuentaByMobile.containsKey(mobileAux)){
            Account clienteAux = mapCuentaByMobile.get(mobileAux);
            system.debug('cazado con el movil');
            if(auxiliar.PersonType__c.equalsIgnoreCase('NaturalPerson')){
                Contact contacto =!String.isBlank(clienteAux.Id)?mapContactByAccountId.get(clienteAux.Id):null;
                if((contacto == null && (!clienteAux.FirstName.equalsIgnoreCase(name) || !clienteAux.LastName.equalsIgnoreCase(lastname))) ||
                   (contacto != null && (!contacto.FirstName.equalsIgnoreCase(name) || !contacto.LastName.equalsIgnoreCase(lastname)))){
                    crear= true;
                    system.debug('crear nuevo:name'+name + ' /'+ clienteAux.FirstName);
                    system.debug('crear nuevo:lastname'+lastname + ' /'+ clienteAux.LastName);
                }
            	else{
                    crear=false;
                	//mapClienteByAuxAccountToUpsert.put(auxiliar.Id,clienteAux);
            		//String idExternal = auxiliar.customerId__c+auxiliar.companyId__c;
            		if(!mapClienteConcesionarioByIdExternal.containsKey(idExternal)){
                		Cliente_Concesionario__c cConcesionario = new Cliente_Concesionario__c();
                		Concesionario__c con = mapConsecionarioByIdExt.get(auxiliar.CompanyId__c);
                		cConcesionario.Concesionario__c = con.Id;
                        if(String.isBlank(clienteAux.Id)){
                        	mapClienteByAuxAccountToUpsert.put(auxiliar.Id,clienteAux);
                    	}
                    	else{
                        	cConcesionario.Cliente__c= clienteAux.Id;
                    	}
                		cConcesionario.Documento__c = clienteAux.Documento__c;
                        cConcesionario.External_Id__c = auxiliar.customerId__c+'/'+auxiliar.companyId__c;
                		cConcesionario.Id_Cliente_DMS__c = auxiliar.customerId__c;
                        cConcesionario.ID_BillingAddress__c = auxiliar.Invoicing_addresses_id__c;
                        cConcesionario.ID_ShippingAddress__c = auxiliar.Delivering_addresses_id__c;
                        cConcesionario.customerId_actual__c = auxiliar.customerId_actual__c;
                		cConcesionario.customerType_actual__c = auxiliar.customerType_actual__c;
                        if(!String.isBlank(auxiliar.Email__c)){
                            cConcesionario.Email__c = auxiliar.Email__c;
                			cConcesionario.ID_Email__c = auxiliar.ID_Email__c;
                        }
                        if(!String.isBlank(auxiliar.Mobile__c)){
                            cConcesionario.Mobile__c = auxiliar.Mobile__c;
                			cConcesionario.ID_PersonMobilePhone__c = auxiliar.ID_Mobile__c;
                        }
                      	if(!String.isBlank(auxiliar.Phone__c)){
                            cConcesionario.Phone__c = auxiliar.Phone__c;
                			cConcesionario.ID_Phone__c = auxiliar.ID_Phone__c;
                        }
                        if(!String.isBlank(auxiliar.OtherEmail__c)){
                            cConcesionario.OtherEmail__c = auxiliar.OtherEmail__c;
                			cConcesionario.ID_OtherEmail__c = auxiliar.ID_OtherEmail__c;
                        }
                        if(!String.isBlank(auxiliar.OtherMobile__c)){
                            cConcesionario.OtherMobile__c = auxiliar.OtherMobile__c;
                			cConcesionario.ID_OtherPersonMobilePhone__c = auxiliar.ID_OtherMobile__c;
                        }
                        if(!String.isBlank(auxiliar.OtherPhone__c)){
                            cConcesionario.OtherPhone__c = auxiliar.OtherPhone__c;
                			cConcesionario.ID_OtherPhone__c = auxiliar.ID_OtherPhone__c;
                        }
                        
                		mapCConcesionarioByAuxAccountToUpsert.put(auxiliar.id, cConcesionario);
            		}
            	}        
            }
            else {
                if(!clienteAux.Name.equalsIgnoreCase(name)){
                    crear = true;
                    system.debug('crear nuevo:name empresa'+name + ' /'+ clienteAux.Name);
                    
                }
                else{
                    crear=false;
            		//mapClienteByAuxAccountToUpsert.put(auxiliar.Id,clienteAux);
            		//String idExternal = auxiliar.customerId__c+auxiliar.companyId__c;
            		if(!mapClienteConcesionarioByIdExternal.containsKey(idExternal)){
                		Cliente_Concesionario__c cConcesionario = new Cliente_Concesionario__c();
                		Concesionario__c con = mapConsecionarioByIdExt.get(auxiliar.CompanyId__c);
                		cConcesionario.Concesionario__c = con.Id;
                        if(String.isBlank(clienteAux.Id)){
                        	mapClienteByAuxAccountToUpsert.put(auxiliar.Id,clienteAux);
                    	}
                    	else{
                        	cConcesionario.Cliente__c= clienteAux.Id;
                            system.debug('clienteId:'+clienteAux.Id);
                    	}

                		cConcesionario.Documento__c = clienteAux.Documento__c;
                		cConcesionario.Id_Cliente_DMS__c = auxiliar.customerId__c;
                        cConcesionario.ID_BillingAddress__c = auxiliar.Invoicing_addresses_id__c;
        				cConcesionario.ID_ShippingAddress__c = auxiliar.Delivering_addresses_id__c;
                        cConcesionario.customerId_actual__c = auxiliar.customerId_actual__c;
                		cConcesionario.customerType_actual__c = auxiliar.customerType_actual__c;
                        if(!String.isBlank(auxiliar.Email__c)){
                            cConcesionario.Email__c = auxiliar.Email__c;
                			cConcesionario.ID_Email__c = auxiliar.ID_Email__c;
                        }
                        if(!String.isBlank(auxiliar.Mobile__c)){
                            cConcesionario.Mobile__c = auxiliar.Mobile__c;
                			cConcesionario.ID_PersonMobilePhone__c = auxiliar.ID_Mobile__c;
                        }
                      	if(!String.isBlank(auxiliar.Phone__c)){
                            cConcesionario.Phone__c = auxiliar.Phone__c;
                			cConcesionario.ID_Phone__c = auxiliar.ID_Phone__c;
                        }
                        if(!String.isBlank(auxiliar.OtherEmail__c)){
                            cConcesionario.OtherEmail__c = auxiliar.OtherEmail__c;
                			cConcesionario.ID_OtherEmail__c = auxiliar.ID_OtherEmail__c;
                        }
                        if(!String.isBlank(auxiliar.OtherMobile__c)){
                            cConcesionario.OtherMobile__c = auxiliar.OtherMobile__c;
                			cConcesionario.ID_OtherPersonMobilePhone__c = auxiliar.ID_OtherMobile__c;
                        }
                        if(!String.isBlank(auxiliar.OtherPhone__c)){
                            cConcesionario.OtherPhone__c = auxiliar.OtherPhone__c;
                			cConcesionario.ID_OtherPhone__c = auxiliar.ID_OtherPhone__c;
                        }
                        
                		mapCConcesionarioByAuxAccountToUpsert.put(auxiliar.id, cConcesionario);
            		}
            	 }
            }
            
        }
        else if (crear && !String.isBlank(emailAuxOther) && mapCuentaByOtherEmail.containsKey(emailAuxOther)){
            //existe en la bbdd mediante email o se va a insertar
            //crear ClienteConcesionario
            system.debug('cazado con el other email');
            Account clienteAux = mapCuentaByOtherEmail.get(emailAuxOther);
            if(auxiliar.PersonType__c.equalsIgnoreCase('NaturalPerson')){
                Contact contacto =!String.isBlank(clienteAux.Id)?mapContactByAccountId.get(clienteAux.Id):null;
                if((contacto == null && (!clienteAux.FirstName.equalsIgnoreCase(name) || !clienteAux.LastName.equalsIgnoreCase(lastname))) ||
                   (contacto != null && (!contacto.FirstName.equalsIgnoreCase(name) || !contacto.LastName.equalsIgnoreCase(lastname)))){
                 
                    crear= true;
                    system.debug('crear nuevo:name'+name + ' /'+ clienteAux.FirstName);
                    system.debug('crear nuevo:lastname'+lastname + ' /'+ clienteAux.LastName);
                }
            	else{
                	crear=false;
                    if(!mapClienteConcesionarioByIdExternal.containsKey(idExternal)){
                		Cliente_Concesionario__c cConcesionario = new Cliente_Concesionario__c();
                		Concesionario__c con = mapConsecionarioByIdExt.get(auxiliar.CompanyId__c);
                        cConcesionario.Concesionario__c = con.Id;
                        if(String.isBlank(clienteAux.Id)){
                        	mapClienteByAuxAccountToUpsert.put(auxiliar.Id,clienteAux);
                    	}
                    	else{
                        	cConcesionario.Cliente__c= clienteAux.Id;
                            system.debug('clienteId:'+clienteAux.Id);
                    	}
                		cConcesionario.Documento__c = clienteAux.Documento__c;
                        cConcesionario.External_Id__c = auxiliar.customerId__c+'/'+auxiliar.companyId__c;
                		cConcesionario.Id_Cliente_DMS__c = auxiliar.customerId__c;
                        cConcesionario.ID_BillingAddress__c = auxiliar.Invoicing_addresses_id__c;
                        cConcesionario.ID_ShippingAddress__c = auxiliar.Delivering_addresses_id__c;
                        cConcesionario.customerId_actual__c = auxiliar.customerId_actual__c;
                		cConcesionario.customerType_actual__c = auxiliar.customerType_actual__c;
                        if(!String.isBlank(auxiliar.Email__c)){
                            cConcesionario.Email__c = auxiliar.Email__c;
                			cConcesionario.ID_Email__c = auxiliar.ID_Email__c;
                        }
                        if(!String.isBlank(auxiliar.Mobile__c)){
                            cConcesionario.Mobile__c = auxiliar.Mobile__c;
                			cConcesionario.ID_PersonMobilePhone__c = auxiliar.ID_Mobile__c;
                        }
                      	if(!String.isBlank(auxiliar.Phone__c)){
                            cConcesionario.Phone__c = auxiliar.Phone__c;
                			cConcesionario.ID_Phone__c = auxiliar.ID_Phone__c;
                        }
                        if(!String.isBlank(auxiliar.OtherEmail__c)){
                            cConcesionario.OtherEmail__c = auxiliar.OtherEmail__c;
                			cConcesionario.ID_OtherEmail__c = auxiliar.ID_OtherEmail__c;
                        }
                        if(!String.isBlank(auxiliar.OtherMobile__c)){
                            cConcesionario.OtherMobile__c = auxiliar.OtherMobile__c;
                			cConcesionario.ID_OtherPersonMobilePhone__c = auxiliar.ID_OtherMobile__c;
                        }
                        if(!String.isBlank(auxiliar.OtherPhone__c)){
                            cConcesionario.OtherPhone__c = auxiliar.OtherPhone__c;
                			cConcesionario.ID_OtherPhone__c = auxiliar.ID_OtherPhone__c;
                        }
                        mapCConcesionarioByAuxAccountToUpsert.put(auxiliar.id, cConcesionario);
            		}
				}        
            }
            else {
                if(!clienteAux.Name.equalsIgnoreCase(name)){
                    crear = true;
                    system.debug('crear nuevo:name empresa'+name + ' /'+ clienteAux.Name);
                   // system.debug('crear nuevo:lastname'+lastname + ' /'+ clienteAux.LastName);
                }
                else{
                    crear=false;
                	//mapClienteByAuxAccountToUpsert.put(auxiliar.Id,clienteAux);
            		//String idExternal = auxiliar.customerId__c+auxiliar.companyId__c;
            		if(!mapClienteConcesionarioByIdExternal.containsKey(idExternal)){
                		Cliente_Concesionario__c cConcesionario = new Cliente_Concesionario__c();
                		Concesionario__c con = mapConsecionarioByIdExt.get(auxiliar.CompanyId__c);
                		cConcesionario.Concesionario__c = con.Id;
                        if(String.isBlank(clienteAux.Id)){
                        	mapClienteByAuxAccountToUpsert.put(auxiliar.Id,clienteAux);
                    	}
                    	else{
                        	cConcesionario.Cliente__c= clienteAux.Id;
                    	}
                		cConcesionario.Documento__c = clienteAux.Documento__c;
                		cConcesionario.Id_Cliente_DMS__c = auxiliar.customerId__c;
                        cConcesionario.ID_ShippingAddress__c = auxiliar.Delivering_addresses_id__c;
                        cConcesionario.ID_ShippingAddress__c = auxiliar.Delivering_addresses_id__c;
        				cConcesionario.customerId_actual__c = auxiliar.customerId_actual__c;
                		cConcesionario.customerType_actual__c = auxiliar.customerType_actual__c;
                        if(!String.isBlank(auxiliar.Email__c)){
                            cConcesionario.Email__c = auxiliar.Email__c;
                			cConcesionario.ID_Email__c = auxiliar.ID_Email__c;
                        }
                        if(!String.isBlank(auxiliar.Mobile__c)){
                            cConcesionario.Mobile__c = auxiliar.Mobile__c;
                			cConcesionario.ID_PersonMobilePhone__c = auxiliar.ID_Mobile__c;
                        }
                      	if(!String.isBlank(auxiliar.Phone__c)){
                            cConcesionario.Phone__c = auxiliar.Phone__c;
                			cConcesionario.ID_Phone__c = auxiliar.ID_Phone__c;
                        }
                        if(!String.isBlank(auxiliar.OtherEmail__c)){
                            cConcesionario.OtherEmail__c = auxiliar.OtherEmail__c;
                			cConcesionario.ID_OtherEmail__c = auxiliar.ID_OtherEmail__c;
                        }
                        if(!String.isBlank(auxiliar.OtherMobile__c)){
                            cConcesionario.OtherMobile__c = auxiliar.OtherMobile__c;
                			cConcesionario.ID_OtherPersonMobilePhone__c = auxiliar.ID_OtherMobile__c;
                        }
                        if(!String.isBlank(auxiliar.OtherPhone__c)){
                            cConcesionario.OtherPhone__c = auxiliar.OtherPhone__c;
                			cConcesionario.ID_OtherPhone__c = auxiliar.ID_OtherPhone__c;
                        }
                        
                		mapCConcesionarioByAuxAccountToUpsert.put(auxiliar.id, cConcesionario);
            		}
                }
            }
        }
        else if(crear && !String.isBlank(telefonoAuxOther) && mapCuentaByOtherTelefono.containsKey(telefonoAuxOther)){
            //existe en la bbdd mediante el telefono o se va a insertar
            // crear Cliente Concesionario
            system.debug('cazado con el other telefono');
            Account clienteAux = mapCuentaByOtherTelefono.get(telefonoAuxOther);
            
            if(auxiliar.PersonType__c.equalsIgnoreCase('NaturalPerson')){
                Contact contacto =!String.isBlank(clienteAux.Id)?mapContactByAccountId.get(clienteAux.Id):null;
                if((contacto == null && (!clienteAux.FirstName.equalsIgnoreCase(name) || !clienteAux.LastName.equalsIgnoreCase(lastname))) ||
                   (contacto != null && (!contacto.FirstName.equalsIgnoreCase(name) || !contacto.LastName.equalsIgnoreCase(lastname)))){
                    crear= true;
                    system.debug('crear nuevo:name'+name + ' /'+ clienteAux.FirstName);
                    system.debug('crear nuevo:lastname'+lastname + ' /'+ clienteAux.LastName);
                }
            	else{
                	//mapClienteByAuxAccountToUpsert.put(auxiliar.Id,clienteAux);
            		//String idExternal = auxiliar.customerId__c+auxiliar.companyId__c;
            		crear = false;
            		if(!mapClienteConcesionarioByIdExternal.containsKey(idExternal)){
                		Cliente_Concesionario__c cConcesionario = new Cliente_Concesionario__c();
                		Concesionario__c con = mapConsecionarioByIdExt.get(auxiliar.CompanyId__c);
                		cConcesionario.Concesionario__c = con.Id;
                        if(String.isBlank(clienteAux.Id)){
                        	mapClienteByAuxAccountToUpsert.put(auxiliar.Id,clienteAux);
                    	}
                    	else{
                        	cConcesionario.Cliente__c= clienteAux.Id;
                            system.debug('clienteId:'+clienteAux.Id);
                    	}
                		cConcesionario.Documento__c = clienteAux.Documento__c;
                        cConcesionario.External_Id__c = auxiliar.customerId__c+'/'+auxiliar.companyId__c;
                		cConcesionario.Id_Cliente_DMS__c = auxiliar.customerId__c;
                        cConcesionario.ID_ShippingAddress__c = auxiliar.Delivering_addresses_id__c;
                        cConcesionario.ID_ShippingAddress__c = auxiliar.Delivering_addresses_id__c;
        				cConcesionario.customerId_actual__c = auxiliar.customerId_actual__c;
                		cConcesionario.customerType_actual__c = auxiliar.customerType_actual__c;
                        if(!String.isBlank(auxiliar.Email__c)){
                            cConcesionario.Email__c = auxiliar.Email__c;
                			cConcesionario.ID_Email__c = auxiliar.ID_Email__c;
                        }
                        if(!String.isBlank(auxiliar.Mobile__c)){
                            cConcesionario.Mobile__c = auxiliar.Mobile__c;
                			cConcesionario.ID_PersonMobilePhone__c = auxiliar.ID_Mobile__c;
                        }
                      	if(!String.isBlank(auxiliar.Phone__c)){
                            cConcesionario.Phone__c = auxiliar.Phone__c;
                			cConcesionario.ID_Phone__c = auxiliar.ID_Phone__c;
                        }
                        if(!String.isBlank(auxiliar.OtherEmail__c)){
                            cConcesionario.OtherEmail__c = auxiliar.OtherEmail__c;
                			cConcesionario.ID_OtherEmail__c = auxiliar.ID_OtherEmail__c;
                        }
                        if(!String.isBlank(auxiliar.OtherMobile__c)){
                            cConcesionario.OtherMobile__c = auxiliar.OtherMobile__c;
                			cConcesionario.ID_OtherPersonMobilePhone__c = auxiliar.ID_OtherMobile__c;
                        }
                        if(!String.isBlank(auxiliar.OtherPhone__c)){
                            cConcesionario.OtherPhone__c = auxiliar.OtherPhone__c;
                			cConcesionario.ID_OtherPhone__c = auxiliar.ID_OtherPhone__c;
                        }
                        
                		mapCConcesionarioByAuxAccountToUpsert.put(auxiliar.id, cConcesionario);
            		}
				}        
            }
            else {
                if(!clienteAux.Name.equalsIgnoreCase(name)){
                    crear = true;
                    system.debug('crear nuevo:name empresa'+name + ' /'+ clienteAux.Name);
                    //system.debug('crear nuevo:lastname'+lastname + ' /'+ clienteAux.LastName);
                }
                else{
                    crear=false;
                	//mapClienteByAuxAccountToUpsert.put(auxiliar.Id,clienteAux);
            		//String idExternal = auxiliar.customerId__c+auxiliar.companyId__c;
            		if(!mapClienteConcesionarioByIdExternal.containsKey(idExternal)){
                		Cliente_Concesionario__c cConcesionario = new Cliente_Concesionario__c();
                        Concesionario__c con = mapConsecionarioByIdExt.get(auxiliar.CompanyId__c);
                		cConcesionario.Concesionario__c = con.Id;
                        if(String.isBlank(clienteAux.Id)){
                        	mapClienteByAuxAccountToUpsert.put(auxiliar.Id,clienteAux);
                    	}
                    	else{
                        	cConcesionario.Cliente__c= clienteAux.Id;
                            system.debug('clienteId:'+clienteAux.Id);
                    	}

                		cConcesionario.Documento__c = clienteAux.Documento__c;
                		cConcesionario.Id_Cliente_DMS__c = auxiliar.customerId__c;
                        cConcesionario.ID_ShippingAddress__c = auxiliar.Delivering_addresses_id__c;
                        cConcesionario.ID_ShippingAddress__c = auxiliar.Delivering_addresses_id__c;
        				cConcesionario.customerId_actual__c = auxiliar.customerId_actual__c;
                		cConcesionario.customerType_actual__c = auxiliar.customerType_actual__c;
                        if(!String.isBlank(auxiliar.Email__c)){
                            cConcesionario.Email__c = auxiliar.Email__c;
                			cConcesionario.ID_Email__c = auxiliar.ID_Email__c;
                        }
                        if(!String.isBlank(auxiliar.Mobile__c)){
                            cConcesionario.Mobile__c = auxiliar.Mobile__c;
                			cConcesionario.ID_PersonMobilePhone__c = auxiliar.ID_Mobile__c;
                        }
                      	if(!String.isBlank(auxiliar.Phone__c)){
                            cConcesionario.Phone__c = auxiliar.Phone__c;
                			cConcesionario.ID_Phone__c = auxiliar.ID_Phone__c;
                        }
                        if(!String.isBlank(auxiliar.OtherEmail__c)){
                            cConcesionario.OtherEmail__c = auxiliar.OtherEmail__c;
                			cConcesionario.ID_OtherEmail__c = auxiliar.ID_OtherEmail__c;
                        }
                        if(!String.isBlank(auxiliar.OtherMobile__c)){
                            cConcesionario.OtherMobile__c = auxiliar.OtherMobile__c;
                			cConcesionario.ID_OtherPersonMobilePhone__c = auxiliar.ID_OtherMobile__c;
                        }
                        if(!String.isBlank(auxiliar.OtherPhone__c)){
                            cConcesionario.OtherPhone__c = auxiliar.OtherPhone__c;
                			cConcesionario.ID_OtherPhone__c = auxiliar.ID_OtherPhone__c;
                        }
                        
                		mapCConcesionarioByAuxAccountToUpsert.put(auxiliar.id, cConcesionario);
            		}
                }
            }
            
        }
        else if(crear && !String.isBlank(mobileAuxOther) && mapCuentaByOtherMobile.containsKey(mobileAuxOther)){
            Account clienteAux = mapCuentaByOtherMobile.get(mobileAuxOther);
            system.debug('cazado con el other movil');
            if(auxiliar.PersonType__c.equalsIgnoreCase('NaturalPerson')){
                Contact contacto =!String.isBlank(clienteAux.Id)?mapContactByAccountId.get(clienteAux.Id):null;
                if((contacto == null && (!clienteAux.FirstName.equalsIgnoreCase(name) || !clienteAux.LastName.equalsIgnoreCase(lastname))) ||
                   (contacto != null && (!contacto.FirstName.equalsIgnoreCase(name) || !contacto.LastName.equalsIgnoreCase(lastname)))){
                 
                    crear= true;
                    system.debug('crear nuevo:name'+name + ' /'+ clienteAux.FirstName);
                    system.debug('crear nuevo:lastname'+lastname + ' /'+ clienteAux.LastName);
                }
            	else{
                    crear=false;
                	//mapClienteByAuxAccountToUpsert.put(auxiliar.Id,clienteAux);
            		//String idExternal = auxiliar.customerId__c+auxiliar.companyId__c;
            		if(!mapClienteConcesionarioByIdExternal.containsKey(idExternal)){
                		Cliente_Concesionario__c cConcesionario = new Cliente_Concesionario__c();
                		Concesionario__c con = mapConsecionarioByIdExt.get(auxiliar.CompanyId__c);
                		cConcesionario.Concesionario__c = con.Id;
                        if(String.isBlank(clienteAux.Id)){
                        	mapClienteByAuxAccountToUpsert.put(auxiliar.Id,clienteAux);
                    	}
                    	else{
                        	cConcesionario.Cliente__c= clienteAux.Id;
                    	}
                		cConcesionario.Documento__c = clienteAux.Documento__c;
                        cConcesionario.External_Id__c = auxiliar.customerId__c+'/'+auxiliar.companyId__c;
                		cConcesionario.Id_Cliente_DMS__c = auxiliar.customerId__c;
                        cConcesionario.ID_BillingAddress__c = auxiliar.Invoicing_addresses_id__c;
                        cConcesionario.ID_ShippingAddress__c = auxiliar.Delivering_addresses_id__c;
                        cConcesionario.customerId_actual__c = auxiliar.customerId_actual__c;
                		cConcesionario.customerType_actual__c = auxiliar.customerType_actual__c;
                        if(!String.isBlank(auxiliar.Email__c)){
                            cConcesionario.Email__c = auxiliar.Email__c;
                			cConcesionario.ID_Email__c = auxiliar.ID_Email__c;
                        }
                        if(!String.isBlank(auxiliar.Mobile__c)){
                            cConcesionario.Mobile__c = auxiliar.Mobile__c;
                			cConcesionario.ID_PersonMobilePhone__c = auxiliar.ID_Mobile__c;
                        }
                      	if(!String.isBlank(auxiliar.Phone__c)){
                            cConcesionario.Phone__c = auxiliar.Phone__c;
                			cConcesionario.ID_Phone__c = auxiliar.ID_Phone__c;
                        }
                        if(!String.isBlank(auxiliar.OtherEmail__c)){
                            cConcesionario.OtherEmail__c = auxiliar.OtherEmail__c;
                			cConcesionario.ID_OtherEmail__c = auxiliar.ID_OtherEmail__c;
                        }
                        if(!String.isBlank(auxiliar.OtherMobile__c)){
                            cConcesionario.OtherMobile__c = auxiliar.OtherMobile__c;
                			cConcesionario.ID_OtherPersonMobilePhone__c = auxiliar.ID_OtherMobile__c;
                        }
                        if(!String.isBlank(auxiliar.OtherPhone__c)){
                            cConcesionario.OtherPhone__c = auxiliar.OtherPhone__c;
                			cConcesionario.ID_OtherPhone__c = auxiliar.ID_OtherPhone__c;
                        }
                        
                		mapCConcesionarioByAuxAccountToUpsert.put(auxiliar.id, cConcesionario);
            		}
            	}        
            }
            else {
                if(!clienteAux.Name.equalsIgnoreCase(name)){
                    crear = true;
                    system.debug('crear nuevo:name empresa'+name + ' /'+ clienteAux.Name);
                    
                }
                else{
                    crear=false;
            		//mapClienteByAuxAccountToUpsert.put(auxiliar.Id,clienteAux);
            		//String idExternal = auxiliar.customerId__c+auxiliar.companyId__c;
            		if(!mapClienteConcesionarioByIdExternal.containsKey(idExternal)){
                		Cliente_Concesionario__c cConcesionario = new Cliente_Concesionario__c();
                		Concesionario__c con = mapConsecionarioByIdExt.get(auxiliar.CompanyId__c);
                		cConcesionario.Concesionario__c = con.Id;
                        if(String.isBlank(clienteAux.Id)){
                        	mapClienteByAuxAccountToUpsert.put(auxiliar.Id,clienteAux);
                    	}
                    	else{
                        	cConcesionario.Cliente__c= clienteAux.Id;
                            system.debug('clienteId:'+clienteAux.Id);
                    	}

                		cConcesionario.Documento__c = clienteAux.Documento__c;
                		cConcesionario.Id_Cliente_DMS__c = auxiliar.customerId__c;
                        cConcesionario.ID_BillingAddress__c = auxiliar.Invoicing_addresses_id__c;
        				cConcesionario.ID_ShippingAddress__c = auxiliar.Delivering_addresses_id__c;
                        cConcesionario.customerId_actual__c = auxiliar.customerId_actual__c;
                		cConcesionario.customerType_actual__c = auxiliar.customerType_actual__c;
                        if(!String.isBlank(auxiliar.Email__c)){
                            cConcesionario.Email__c = auxiliar.Email__c;
                			cConcesionario.ID_Email__c = auxiliar.ID_Email__c;
                        }
                        if(!String.isBlank(auxiliar.Mobile__c)){
                            cConcesionario.Mobile__c = auxiliar.Mobile__c;
                			cConcesionario.ID_PersonMobilePhone__c = auxiliar.ID_Mobile__c;
                        }
                      	if(!String.isBlank(auxiliar.Phone__c)){
                            cConcesionario.Phone__c = auxiliar.Phone__c;
                			cConcesionario.ID_Phone__c = auxiliar.ID_Phone__c;
                        }
                        if(!String.isBlank(auxiliar.OtherEmail__c)){
                            cConcesionario.OtherEmail__c = auxiliar.OtherEmail__c;
                			cConcesionario.ID_OtherEmail__c = auxiliar.ID_OtherEmail__c;
                        }
                        if(!String.isBlank(auxiliar.OtherMobile__c)){
                            cConcesionario.OtherMobile__c = auxiliar.OtherMobile__c;
                			cConcesionario.ID_OtherPersonMobilePhone__c = auxiliar.ID_OtherMobile__c;
                        }
                        if(!String.isBlank(auxiliar.OtherPhone__c)){
                            cConcesionario.OtherPhone__c = auxiliar.OtherPhone__c;
                			cConcesionario.ID_OtherPhone__c = auxiliar.ID_OtherPhone__c;
                        }
                        
                		mapCConcesionarioByAuxAccountToUpsert.put(auxiliar.id, cConcesionario);
            		}
            	 }
            }
            
            
        }
        
        system.debug('crear aaaa:'+ crear);
        if(crear) {
			// no existe en la bbdd 
			
            //crea cliente
			//crea Cliente Concesionario
            Account cliente = new Account();
            system.debug('crea nuevo cliente customerId:'+ auxiliar.customerId__c + 'companyId:'+ auxiliar.companyId__c );
            Cliente_Concesionario__c cConcesionario = new Cliente_Concesionario__c();
            Concesionario__c con = mapConsecionarioByIdExt.get(auxiliar.CompanyId__c);
            cConcesionario.Concesionario__c = con.Id;
            cConcesionario.Id_Cliente_DMS__c = auxiliar.customerId__c;
            cConcesionario.External_Id__c = auxiliar.customerId__c+'/'+auxiliar.companyId__c;
            cConcesionario.customerId_actual__c = auxiliar.customerId_actual__c;
            cConcesionario.customerType_actual__c = auxiliar.customerType_actual__c;
                
           
            //Pais del cliente
        	Pais__c pais = mapPaisByidExt.containsKey(auxiliar.countryISO31661__c)?mapPaisByidExt.get(auxiliar.countryISO31661__c):null;
        	cliente.Pais__c=pais != null?pais.Id:null;	
        
            String idRecordType = auxiliar.PersonType__c.equalsIgnoreCase('NaturalPerson') ?rtMapByDName.get('PersonAccount').getRecordTypeId() : rtMapByDName.get('Cliente_Empresa').getRecordTypeId();
            cliente.RecordTypeId = idRecordType;
			cliente.Fecha_Alta_Sima__c = auxiliar.creationDate__c;
            cliente.ultima_modificacion_DMS__c = auxiliar.ultima_actualizacion__c;
            
            if (!auxiliar.PersonType__c.equalsIgnoreCase('NaturalPerson')) {
            	cliente.Name = name;
        	}
        	else {
                cliente.Salutation = auxiliar.title__c;
            	cliente.FirstName = name;
                cliente.LastName = lastname;
        		//cliente.LastName = !String.isBlank(auxiliar.secondSurname__c)?cliente.LastName+' ' + auxiliar.secondSurname__c:cliente.LastName;
        		cliente.PersonBirthdate = auxiliar.birthdate__c;
                cliente.ChildrenCount__pc =!string.isBlank(auxiliar.numberOfChildren__c)? Double.valueOf(auxiliar.numberOfChildren__c):null;
                cliente.gender__pc = auxiliar.gender__c;
                cliente.Occupation__pc = !String.isBlank(auxiliar.occupationId__c)?auxiliar.companyId__c+'-'+auxiliar.occupationId__c:null;
                cliente.position__pc =auxiliar.positionId__c;
                cliente.incomes__pc = auxiliar.incomes__c;
                cliente.maritalStatus__pc = auxiliar.maritalStatusId__c;
                cliente.economicSector__pc = !String.isBlank(auxiliar.economicSectorId__c)?auxiliar.companyId__c+'-'+auxiliar.economicSectorId__c:null;
                
            }
        
        	cliente.Marca_registrada__c = !auxiliar.PersonType__c.equalsIgnoreCase('NaturalPerson')?auxiliar.tradeName__c:'';
        	cliente.Pais__c = pais != null ? pais.Id : null;
        
        
        if (!String.isBlank(auxiliar.taxId_documentType__c) && auxiliar.PersonType__c.equalsIgnoreCase('NaturalPerson') ) {
            cliente.Tipo_de_documento_cuenta_personal__c = Label.docType_VATId.equalsIgnoreCase(auxiliar.taxId_documentType__c)
                || Label.docType_VATIdForForeigners.equalsIgnoreCase(auxiliar.taxId_documentType__c)
                || Label.docType_Passport.equalsIgnoreCase(auxiliar.taxId_documentType__c) 
                || Label.docType_OtherCountryVATId.equalsIgnoreCase(auxiliar.taxId_documentType__c)
                ? auxiliar.taxId_documentType__c : null;
        }
        else if (!String.isBlank(auxiliar.taxId_documentType__c)) {
            cliente.Tipo_de_documento_empresa__c = Label.docType_VATId.equalsIgnoreCase(auxiliar.taxId_documentType__c)
                || Label.docType_OtherCountryVATId.equalsIgnoreCase(auxiliar.taxId_documentType__c)
                ? auxiliar.taxId_documentType__c : null;
        }

        
        if (!String.isBlank(auxiliar.taxId_number_nuevo_txt__c)) {
            cliente.Documento__c = auxiliar.taxId_number_nuevo_txt__c;
            cConcesionario.Documento__c = cliente.Documento__c;
            
       }
        cConcesionario.ID_BillingAddress__c = auxiliar.Invoicing_addresses_id__c;
        cliente.BillingStreet = auxiliar.Invoicing_addresses_street__c; 
        cliente.BillingCity = auxiliar.Invoicing_addresses_department__c;
        cliente.BillingCountry = auxiliar.Invoicing_addresses_CountryIso31661__c;
        cliente.BillingPostalCode = auxiliar.Invoicing_addresses_PostalCode__c;
        cliente.BillingState = auxiliar.Invoicing_addresses_region__c;
        //cliente.BillingState = req.accountApi.Invoicing_addresses_State__c;
        
        cConcesionario.ID_ShippingAddress__c = auxiliar.Delivering_addresses_id__c;
        cliente.ShippingStreet = auxiliar.Delivering_addresses_street__c; 
        cliente.ShippingCity = auxiliar.Delivering_addresses_department__c;
        cliente.ShippingCountry = auxiliar.Delivering_addresses_CountryIso31661__c;
        cliente.ShippingPostalCode = auxiliar.Delivering_addresses_PostalCode__c;
        cliente.ShippingState = auxiliar.Delivering_addresses_region__c;
        //cliente.ShippingState = req.accountApi.shippingState;

        cliente.ultima_modificacion_DMS__c = auxiliar.modificationDate__c;
        String email='';
        String otherEmail='';
         if (!String.isBlank(auxiliar.Email__c) &&  DataValidations.validateEmail(auxiliar.Email__c)) {
             email= auxiliar.Email__c;
					if (!auxiliar.PersonType__c.equalsIgnoreCase('NaturalPerson')) {
                    		cliente.Email__c = auxiliar.Email__c;
                            //methodsContact.channelFinal = Label.channelEmail;
                    }
                    else{
                        cliente.PersonEmail = auxiliar.Email__c;
                    }
            cConcesionario.Email__c=auxiliar.Email__c;
            cConcesionario.ID_Email__c =auxiliar.ID_Email__c; 
                 }
         if( !String.isBlank(auxiliar.OtherEmail__c)  && DataValidations.validateEmail(auxiliar.OtherEmail__c)) {
             otherEmail = auxiliar.OtherEmail__c;
                    if (!auxiliar.PersonType__c.equalsIgnoreCase('NaturalPerson')) {
                    		cliente.Other_Email__c = auxiliar.OtherEmail__c;
                            //methodsContact.channelFinal = Label.channelEmail;
                    }
                    else{
                        cliente.OtherEmail__pc = auxiliar.OtherEmail__c;
                    }
             cConcesionario.OtherEmail__c = auxiliar.OtherEmail__c;
             cConcesionario.ID_OtherEmail__c = auxiliar.Id_OtherEmail__c;        
                 }
            
          
          // Validar
          if (!String.isBlank(replacedTelefono) && DataValidations.validatePhone(replacedTelefono)) {
			    cliente.Phone = replacedTelefono;
                cConcesionario.ID_Phone__c = auxiliar.Id_Phone__c;
                cConcesionario.Phone__c = auxiliar.Phone__c;
            } 
          if (!String.isBlank(replacedTelefonoOther) && DataValidations.validatePhone(replacedTelefonoOther))   {  
                 if (!auxiliar.PersonType__c.equalsIgnoreCase('NaturalPerson')) {
                       cliente.Other_Phone__c = replacedTelefonoOther;
                     } 
            	else {
                	 cliente.PersonOtherPhone = replacedTelefonoOther;
            	}
                cConcesionario.ID_OtherPhone__c = auxiliar.ID_OtherPhone__c;
                cConcesionario.OtherPhone__c = auxiliar.OtherPhone__c;
            } 
            if(!String.isBlank(replacedMobile) && DataValidations.validatePhone(replacedMobile)){
                 if (!auxiliar.PersonType__c.equalsIgnoreCase('NaturalPerson')) {
                       cliente.Mobile__c = replacedMobile;
                     } 
            	else {
                	 cliente.PersonMobilePhone = replacedMobile;
            	}
                cConcesionario.ID_PersonMobilePhone__c = auxiliar.ID_Mobile__c;
                cConcesionario.Mobile__c = auxiliar.Mobile__c;
            }
            if(!String.isBlank(replacedMobileOther) && DataValidations.validatePhone(replacedMobileOther)){
                if (!auxiliar.PersonType__c.equalsIgnoreCase('NaturalPerson')) {
                       cliente.Other_Mobile__c = replacedMobileOther;
                     } 
            	else {
                	 cliente.OtherMobilePhone__pc = replacedMobileOther;
            	}
                cConcesionario.ID_OtherPersonMobilePhone__c = auxiliar.ID_OtherMobile__c;
                cConcesionario.OtherMobile__c = auxiliar.OtherMobile__c;
            }
             
        // Find duplicates
        List<Account> lstDuplicates = new List<Account>();
        lstDuplicates.add(cliente);
        
        if (Datacloud.FindDuplicates.findDuplicates(lstDuplicates).size() > 0) {
			Datacloud.FindDuplicatesResult resultFindDuplicate = Datacloud.FindDuplicates.findDuplicates(lstDuplicates)[0];
			List<Datacloud.MatchRecord> recordListMatch = resultFindDuplicate.getDuplicateResults()[0].getMatchResults()[0].getMatchRecords();
			
            if (!recordListMatch.isEmpty()) {
				Datacloud.MatchRecord recordMatch = recordListMatch[0];
				SObject record = recordMatch.getRecord();
				System.debug('RECORD duplicate : ' + record);
				Account auxAcc = (Account) record;
				
                if (auxAcc != null) {
                    cliente.Id = auxAcc.Id;
                    //cliente.Documento__c = auxAcc.Documento__c;
                    
                    cConcesionario.Cliente__c=auxAcc.Id;
                    system.debug('inserto id duplicado de cliente al cConcesionario:'+ auxAcc.Id+ ' '+ auxAcc.Name);
				}
				else {
					new customException('FAIL');
				}
			}
			else {
				System.debug('NO recordMatch');
                 mapClienteByAuxAccountToUpsert.put(auxiliar.Id,cliente);
			}
        }
        else {
            System.debug('NO DUPLICATES!');
            mapClienteByAuxAccountToUpsert.put(auxiliar.Id,cliente);
        }
            
        // Crear o actualizar Cuenta de cliente
        mapCConcesionarioByAuxAccountToUpsert.put(auxiliar.Id, cConcesionario);
           system.debug('antes de insertar  DNI map:'+ mapCuentaByDni);
        if(!String.isBlank(auxiliar.taxId_number_nuevo_txt__c) && !String.isBlank(cliente.Documento__c)){
            	String documentoAux = cliente.Documento__c.toUpperCase();
                mapCuentaByDni.put(documentoAux, cliente);
            }
        if(!String.isBlank(email)){
                String emailAux2 = !auxiliar.PersonType__c.equalsIgnoreCase('NaturalPerson')?email +'/' +name: email+'/'+name+'/'+lastname; 
            	mapCuentaByEmail.put(emailAux2, cliente);
            }
        if(!String.isBlank(replacedTelefono)){
                String telefAux = !auxiliar.PersonType__c.equalsIgnoreCase('NaturalPerson')?replacedTelefono +'/' +name: replacedTelefono+'/'+name+'/'+lastname; 
            	mapCuentaByTelefono.put(telefAux, cliente);
            }
        if(!String.isBlank(replacedMobile)){
                String MobileAux1 = !auxiliar.PersonType__c.equalsIgnoreCase('NaturalPerson')?replacedMobile +'/' +name: replacedMobile+'/'+name+'/'+lastname; 
            	mapCuentaByMobile.put(MobileAux1, cliente);
            }
        if(!String.isBlank(otherEmail)){
                String emailAux2 = !auxiliar.PersonType__c.equalsIgnoreCase('NaturalPerson')?otherEmail +'/' +name: otherEmail+'/'+name+'/'+lastname; 
            	mapCuentaByOtherEmail.put(emailAux2, cliente);
            }
        if(!String.isBlank(replacedTelefonoOther)){
                String telefAux = !auxiliar.PersonType__c.equalsIgnoreCase('NaturalPerson')?replacedTelefonoOther +'/' +name: replacedTelefonoOther+'/'+name+'/'+lastname; 
            	mapCuentaByOtherTelefono.put(telefAux, cliente);
            }
        if(!String.isBlank(replacedMobileOther)){
                String MobileAux1 = !auxiliar.PersonType__c.equalsIgnoreCase('NaturalPerson')?replacedMobileOther +'/' +name: replacedMobileOther+'/'+name+'/'+lastname; 
            	mapCuentaByOtherMobile.put(MobileAux1, cliente);
            }
       	//upsert cliente;
          
        }
        */
    }
    
    public void afterUpdate(sObject old, sObject so) {}
    
    public void afterDelete(sObject so) {}
    
    public void andFinally() {
        /*
        if(!mapClienteByAuxAccountToUpsert.isEmpty()){
            system.debug('mapClienteByAuxAccountToUpsert:'+ mapClienteByAuxAccountToUpsert.size());
            Set<Account> conjuntoCuentaToUpsert = new Set<Account>();
            conjuntoCuentaToUpsert.addAll(mapClienteByAuxAccountToUpsert.values());
            system.debug('conjuntoCuentaToUpsert:'+ conjuntoCuentaToUpsert.size());
            List<Account> cuentasAInsertar = new List<Account>();
            cuentasAInsertar.addAll(conjuntoCuentaToUpsert);
            system.debug('cuentasAInsertar:'+cuentasAInsertar.size());
            system.debug('cuentasAInsertar:'+cuentasAInsertar);
            //system.debug('cuenta50:'+ cuentasAInsertar[50]);
            upsert cuentasAInsertar;
            
            //upsert mapClienteByAuxAccountToUpsert.values();
        }
        if(!mapCConcesionarioByAuxAccountToUpsert.isEmpty()){
            for(String idAuxiliar :mapClienteByAuxAccountToUpsert.keySet()){
                Account cliente = mapClienteByAuxAccountToUpsert.get(idAuxiliar);
                Cliente_Concesionario__c cConcesionario = mapCConcesionarioByAuxAccountToUpsert.get(idAuxiliar);
                system.debug('clienteId:'+cliente.Id);
                if(String.isBlank(cliente.Id)){
                    mapCConcesionarioByAuxAccountToUpsert.remove(idAuxiliar);
                }
                else {
                    cConcesionario.Cliente__c = cliente.Id;
                	mapCConcesionarioByAuxAccountToUpsert.put(idAuxiliar, cConcesionario); 
                }
                
            }
            
            upsert mapCConcesionarioByAuxAccountToUpsert.values();
        }
        */
    }

}