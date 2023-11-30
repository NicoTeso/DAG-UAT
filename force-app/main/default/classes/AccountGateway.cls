public class AccountGateway {
    private static Map<String, Schema.RecordTypeInfo> rtMapByDeveloperName;
    private static Map<Id, Schema.RecordTypeInfo> rtMapById;
    
    public static String getRecordTypeIdByDeveloperName(String developerName) {
        if (rtMapByDeveloperName == null) {
            rtMapByDeveloperName = new Map<String, Schema.RecordTypeInfo>();
            rtMapByDeveloperName = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
        }
      
        return rtMapByDeveloperName.get(developerName).getRecordTypeId();
    }
    
    public static String getRecordTypeDeveloperNameById(String recordTypeId) {
        if (rtMapById == null) {
            rtMapById = new Map<Id, Schema.RecordTypeInfo>();
            rtMapById = Schema.SObjectType.Account.getRecordTypeInfosById();
        }
        
    System.debug('recordTypeId: ' + recordTypeId);
    System.debug('rtMapById: ' + rtMapById);
        
    return rtMapById.get(recordTypeId).getDeveloperName();
    }
    
    public static Account getAccountById(String id) {
        Account acc;
        
        if (!String.isBlank(id)) {
            Map<String, Account> mapIdToAccount = getAccountById(new List<String>{id});
            
            if (!mapIdToAccount.isEmpty()) {
                acc = mapIdToAccount.get(id);
            }
        }
        
        return acc;
    }

    public static Map<String, Account> getAccountById(List<String> lstId) {
        Map<String, Account> mapIdToAccount = new Map<String, Account>();
        
        if (!lstId.isEmpty()) {
            List<Account> lstAccounts = [SELECT Id,
                                           FirstName,
                                                LastName,
                                                isPersonAccount,
                                                PersonEmail,
                                                Email__c,
                                                Other_Email__c,
                                             	OtherEmail__pc,
                                                Phone,
                                                Other_Phone__c,
                                             	PersonOtherPhone, 
                                                PersonMobilePhone,
                                             	Mobile__c,
                                                Other_Mobile__c,
                                             	OtherMobilePhone__pc,
                                             	RecordTypeId,
                                                Name,
                                                Marca_registrada__c,
                                                Pais__c,
                                             	Pais__r.ISO_31661_alfa2__c,
                                                Tipo_de_documento_cuenta_personal__c,
                                                Tipo_de_documento_empresa__c,
                                                Documento__c,
                                                Salutation,
                                             	BillingAddressId__c,
                                                BillingStreet,
                                                BillingCity,
                                                BillingCountry,
                                                BillingPostalCode,
                                                BillingState,
                                             	ShippingAddressId__c,
                                                ShippingStreet,
                                                ShippingCity,
                                                ShippingCountry,
                                                ShippingPostalCode,
                                                ShippingState,
                                                Cliente_VN__c,
                                             	Fecha_primera_compra_VN__c,
                                             	Fecha_ultima_compra_VN__c,
                                               	Importe_VN__c,
                                                Cliente_Postventa__c,
                                                Fecha_primera_compra_Postventa__c,
                                                Fecha_ultima_compra_Postventa__c,
                                                Importe_Postventa__c,
                                                Cliente_Recambios__c,
                                                Fecha_primera_compra_Recambios__c,
                                                Fecha_ltima_compra_Recambios__c,
                                                Importe_Recambios__c,
                                                Cliente_VO__c,
                                                Fecha_primera_compra_VO__c, 
                                                Fecha_ultima_compra_VO__c,
                                                Importe_VO__c,
                                                PersonContactId,
                                                Consentimiento_target__c,
                                             	Fecha_Alta_Sima__c,
                                             	ultima_modificacion_DMS__c,
                        						Fecha_ultima_factura__c,
                        						Marca__c,
                        						IsCustomerPortal,
    	                                        Occupation__pc,
                                             	ChildrenCount__pc,
                                              	PersonBirthdate,
                                             	gender__pc,
                                             	incomes__pc,
                                             	position__pc,
                                             	maritalStatus__pc,
                                             	economicSector__pc,
                                                Cliente_Propio__c,
                                                Fecha_Limite_Cliente_Propio__c,
                                                AceptadoComunicacionesWAH__c,
                                                n_ventas_VO_3_ultimos_anos__c,
                                                isFichaUnica__c,
                                                PoliticaPrivacidadAceptada__c,
                                                drivingLicense__c,
                                                typeCustomer__c,
 												Cliente_Mobility__c,
												Fecha_primera_compra_Mobility__c,
												Fecha_ultima_compra_Mobility__c,
												Importe_Mobility__c,
												ConCasosMKTImp__c,
												ConCasosMKTNoImp__c,
												ConEcosistema__c,
												SyncMKTCloud__c,
												ConTUA__c,
												ConVehiculo__c,
												ConEnvioFUMobility__c,
												LimiteEnvioFUMobility__c,
												ConOportunidad__c
                                         
                                       FROM Account
                                      WHERE Id in :lstId
                                      LIMIT 2000];
            
            for (Account acc : lstAccounts) {
                mapIdToAccount.put(acc.Id, acc);
            }
        }
        
        return mapIdToAccount;
    }
    public static Map<String, Account> getAllAccountById(List<String> lstId) {
        Map<String, Account> mapIdToAccount = new Map<String, Account>();
        
        if (!lstId.isEmpty()) {
            List<Account> lstAccounts = [SELECT Id,
                                           FirstName,
                                                LastName,
                                                isPersonAccount,
                                                PersonEmail,
                                                Email__c,
                                                Other_Email__c,
                                             	OtherEmail__pc,
                                                Phone,
                                                Other_Phone__c,
                                             	PersonOtherPhone, 
                                                PersonMobilePhone,
                                             	Mobile__c,
                                                Other_Mobile__c,
                                             	OtherMobilePhone__pc,
                                             	RecordTypeId,
                                                Name,
                                                Marca_registrada__c,
                                                Pais__c,
                                             	Pais__r.ISO_31661_alfa2__c,
                                                Tipo_de_documento_cuenta_personal__c,
                                                Tipo_de_documento_empresa__c,
                                                Documento__c,
                                                Salutation,
                                             	BillingAddressId__c,
                                                BillingStreet,
                                                BillingCity,
                                                BillingCountry,
                                                BillingPostalCode,
                                                BillingState,
                                             	ShippingAddressId__c,
                                                ShippingStreet,
                                                ShippingCity,
                                                ShippingCountry,
                                                ShippingPostalCode,
                                                ShippingState,
                                                Cliente_VN__c,
                                             	Fecha_primera_compra_VN__c,
                                             	Fecha_ultima_compra_VN__c,
                                               	Importe_VN__c,
                                               	Cliente_Postventa__c,
                                                Fecha_primera_compra_Postventa__c,
                                                Fecha_ultima_compra_Postventa__c,
                                                Importe_Postventa__c,
                                                Cliente_Recambios__c,
                                                Fecha_primera_compra_Recambios__c,
                                                Fecha_ltima_compra_Recambios__c,
                                                Importe_Recambios__c,
                                                Cliente_VO__c,
                                                Fecha_primera_compra_VO__c, 
                                                Fecha_ultima_compra_VO__c,
                                                Importe_VO__c,
                                                PersonContactId,
                                                Consentimiento_target__c, 
                                             	Fecha_Alta_Sima__c,
                                             	ultima_modificacion_DMS__c,
                        						Fecha_ultima_factura__c,
 												Cliente_Mobility__c,
												Fecha_primera_compra_Mobility__c,
												Fecha_ultima_compra_Mobility__c,
												Importe_Mobility__c,
												ConCasosMKTImp__c,
												ConCasosMKTNoImp__c,
												ConEcosistema__c,
												SyncMKTCloud__c,
												ConTUA__c,
												ConVehiculo__c,
												ConEnvioFUMobility__c,
												LimiteEnvioFUMobility__c,
												ConOportunidad__c
                                         
                                       FROM Account
                                      WHERE Id in :lstId 
                                      ALL ROWS];
            
            for (Account acc : lstAccounts) {
                mapIdToAccount.put(acc.Id, acc);
            }
        }
        
        return mapIdToAccount;
    }
    
    public static Account getAccountByDocumento(String documento) {
        Account acc;
        
        if (!String.isBlank(documento)) {
            Map<String, Account> mapDocumentoToAccount = getAccountByDocumento(new List<String>{documento.toUpperCase()});
            
            if (!mapDocumentoToAccount.isEmpty()) {
                acc = mapDocumentoToAccount.get(documento.toUpperCase());
            }
        }
        
        return acc;
    }

    public static Map<String, Account> getAccountByDocumento(List<String> lstDocumento) {
        Map<String, Account> mapDocumentoToAccount = new Map<String, Account>();
        
        if (!lstDocumento.isEmpty()) {
            List<Account> lstAccounts = [SELECT Id,
                                           FirstName,
                                                LastName,
                                                isPersonAccount,
                                                PersonEmail,
                                                Email__c,
                                                Other_Email__c,
                                             	OtherEmail__pc,
                                                Phone,
                                                Other_Phone__c,
                                             	PersonOtherPhone, 
                                                PersonMobilePhone,
                                             	Mobile__c,
                                                Other_Mobile__c,
                                             	OtherMobilePhone__pc,
                                             	RecordTypeId,
                                                Name,
                                                Marca_registrada__c,
                                                Pais__c,
                                             	Pais__r.ISO_31661_alfa2__c,
                                                Tipo_de_documento_cuenta_personal__c,
                                                Tipo_de_documento_empresa__c,
                                                Documento__c,
                                                Salutation,
                                             	BillingAddressId__c,
                                                BillingStreet,
                                                BillingCity,
                                                BillingCountry,
                                                BillingPostalCode,
                                                BillingState,
                                             	ShippingAddressId__c,
                                                ShippingStreet,
                                                ShippingCity,
                                                ShippingCountry,
                                                ShippingPostalCode,
                                                ShippingState,
                                                Cliente_VN__c,
                                             	Fecha_primera_compra_VN__c,
                                             	Fecha_ultima_compra_VN__c,
                                               	Importe_VN__c,
                                                Cliente_Postventa__c,
                                                Fecha_primera_compra_Postventa__c,
                                                Fecha_ultima_compra_Postventa__c,
                                                Importe_Postventa__c,
                                                Cliente_Recambios__c,
                                                Fecha_primera_compra_Recambios__c,
                                                Fecha_ltima_compra_Recambios__c,
                                                Importe_Recambios__c,
                                                Cliente_VO__c,
                                                Fecha_primera_compra_VO__c, 
                                                Fecha_ultima_compra_VO__c,
                                                Importe_VO__c,
                                                PersonContactId,
                                                Consentimiento_target__c,
                                             	Fecha_Alta_Sima__c,
                                             	ultima_modificacion_DMS__c,
                        						Fecha_ultima_factura__c,
                        						Marca__c,
                        						IsCustomerPortal,
    	                                        Occupation__pc,
                                             	ChildrenCount__pc,
                                              	PersonBirthdate,
                                             	gender__pc,
                                             	incomes__pc,
                                             	position__pc,
                                             	maritalStatus__pc,
                                             	economicSector__pc,
                                                Cliente_Propio__c,
                                                Fecha_Limite_Cliente_Propio__c,
                                                AceptadoComunicacionesWAH__c,
                                                n_ventas_VO_3_ultimos_anos__c,
                                                isFichaUnica__c,
                                                PoliticaPrivacidadAceptada__c,
                                                drivingLicense__c,
                                                typeCustomer__c,
 												Cliente_Mobility__c,
												Fecha_primera_compra_Mobility__c,
												Fecha_ultima_compra_Mobility__c,
												Importe_Mobility__c,
												ConCasosMKTImp__c,
												ConCasosMKTNoImp__c,
												ConEcosistema__c,
												SyncMKTCloud__c,
												ConTUA__c,
												ConVehiculo__c,
												ConEnvioFUMobility__c,
												LimiteEnvioFUMobility__c,
												ConOportunidad__c

                                       FROM Account
                                      WHERE Documento__c in :lstDocumento
                                      LIMIT 2000];
            
            for (Account acc : lstAccounts) {
                mapDocumentoToAccount.put(acc.Documento__c.toUpperCase(), acc);
            }
        }
        
        return mapDocumentoToAccount;
    }
    /*
    public static Account getAccountByIdExternal(String customerId, String companyId) {
        Account acc;
        
        if (!String.isBlank(customerId) && !String.isBlank(companyId)) {
      List<Account> listaCliente = [SELECT Id,
                                                 IsPersonAccount,
                                               Occupation__pc,
                                               ChildrenCount__pc,
                                                PersonBirthdate,
                                               gender__pc,
                                               incomes__pc,
                                               position__pc,
                                               maritalStatus__pc,
                                               economicSector__pc
                                           FROM Account
                                           WHERE Id IN (SELECT Cliente__c
                                                       FROM Cliente_Concesionario__c
                                                       WHERE Id_Cliente_DMS__c = :customerId
                                                         AND Concesionario__r.Id_Concesionario_Sima__c = :companyId)];
            
            if (!listaCliente.isEmpty()) {
                acc = listaCliente[0];
            }
        }
        
        return acc;
    }
  */
 /* 
    public static Map<String, List<String>> getAccountIdByEmails(List<String> lstEmail) {
        Map<String, List<String>> mapEmailToAccounts = new Map<String, List<String>>();
        
        if (!lstEmail.isEmpty()) {
            for(Account acc : [SELECT Id, FirstName, LastName, isPersonAccount, PersonEmail, Email__c, Other_Email__c,
                                   OtherEmail__pc, RecordTypeId, Name     
                               FROM Account
                               WHERE Email__c in :lstEmail OR PersonEmail in :lstEmail
                                 OR Other_Email__c = :lstEmail OR OtherEmail__pc = :lstEmail LIMIT 2000]) {
                Set<String> conjuntoEmail = new Set<String>{acc.PersonEmail, acc.Other_Email__c, acc.Email__c, acc.OtherEmail__pc};
                
                for (String email : conjuntoEmail) {
                  List<String> listCuenta = mapEmailToAccounts.containsKey(email) ? mapEmailToAccounts.get(email) : new List<String>();
                    listCuenta.add(acc.Id);
                    mapEmailToAccounts.put(email, listCuenta);
                }
            }
        }
        
        return mapEmailToAccounts;
    }
*/
}