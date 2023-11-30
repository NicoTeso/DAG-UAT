@isTest
public class ExternalServiceControllerTest {
    @testSetup
    static void setup() {
        TriggersTest.activaTriggers();
        ApiConnect.activaApiConnect();
		CreaObjetos.creaPais();
        Concesionario__c concesionario = CreaObjetos.creaConcesionario('001');
        insert concesionario;
        Centro__c centro = CreaObjetos.creaCentro(concesionario.Id);
        Gestion_Lead__c gLead = CreaObjetos.creaGestionLead(centro.Id);
        insert gLead;
        CreaObjetos.creaCampaign();
    }
	
    @isTest
    static void ExternalServiceAccountTest() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMock());
        Centro__c center = [SELECT Id, Name,Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c,Marcas_VO__c,Telefono__c,Venta_de_VN__c,Venta_de_VO__c,CentroCdg__c,Concesionario__r.Id_Concesionario_Sima__c 
                            FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String email = 'prueba@prueba.com';
        String phone = '918887766';
        String mobile ='+34699999123';
        Account cuenta = CreaObjetos.creaCuentaPersonal('Prueba', 'Test Tset');
        Gestion_Lead__c gLead = [Select Id, Asesor__c,Centro__c, Centro_destino__c,  Gestor_Lead__c, Intencion_de_compra__c, Marca__c  from Gestion_Lead__c limit 1];
        cuenta.PersonEmail = email;
        cuenta.Phone = phone;
        cuenta.PersonMobilePhone = mobile;
        cuenta.BillingCountry ='España';
        cuenta.ShippingCountry='España';
        cuenta.Tipo_de_documento_cuenta_personal__c = 'VATId';
        cuenta.Documento__c = 'TST001';
        insert cuenta;
        Contact contacto = [SELECT Id, Name FROM Contact where accountId = :cuenta.Id LIMIT 1];
        List<Consentimientos__c> listConsentimientos = new List<Consentimientos__c>();
        Consentimientos__c consentimientoEmail = CreaObjetos.creaConsentimiento(email, contacto.Id, Label.channelEmail);
        Consentimientos__c consentimientoPhone = CreaObjetos.creaConsentimiento(phone, contacto.Id, Label.channelPhone);
        Consentimientos__c consentimientoMobile = CreaObjetos.creaConsentimiento(mobile, contacto.Id, Label.channelMobile);
        listConsentimientos.add(consentimientoEmail);
        listConsentimientos.add(consentimientoMobile);
        insert listConsentimientos;
        
        Case caso = new Case();
        caso.AccountId = cuenta.Id;
        caso.Centro__c = center.Id;
        caso.Marca__c = 'AUDI';
        caso.Intencion_de_compra__c = 'Oferta';
        caso.Origin = 'Web';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = phone;
        caso.SuppliedEmail = email;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        insert caso;
        Test.startTest();
        ExternalServiceController.createExternalLeadOrAccountMulesoft(JSON.serialize(new List<Case>{caso}), JSON.serialize(gLead));
        Test.stopTest();
    }
    
    @isTest
    static void ExternalServiceAccountFailureTest() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMockFailure());
        Centro__c center = [SELECT Id, Name,Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c,Marcas_VO__c,Telefono__c,Venta_de_VN__c,Venta_de_VO__c,CentroCdg__c,Concesionario__r.Id_Concesionario_Sima__c 
                            FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String email = 'prueba@prueba.com';
        String phone = '918887766';
        String mobile ='+34699999123';
        Account cuenta = CreaObjetos.creaCuentaPersonal('Prueba', 'Test Tset');
        Gestion_Lead__c gLead = [Select Id, Asesor__c,Centro__c, Gestor_Lead__c, Intencion_de_compra__c, Marca__c  from Gestion_Lead__c limit 1];
        cuenta.PersonEmail = email;
        cuenta.Phone = phone;
        cuenta.PersonMobilePhone = mobile;
        cuenta.BillingCountry ='España';
        cuenta.ShippingCountry='España';
        cuenta.Tipo_de_documento_cuenta_personal__c = 'VATId';
        cuenta.Documento__c = 'TST001';
        insert cuenta;
        Contact contacto = [SELECT Id, Name FROM Contact where accountId = :cuenta.Id LIMIT 1];
        List<Consentimientos__c> listConsentimientos = new List<Consentimientos__c>();
        Consentimientos__c consentimientoEmail = CreaObjetos.creaConsentimiento(email, contacto.Id, Label.channelEmail);
        Consentimientos__c consentimientoPhone = CreaObjetos.creaConsentimiento(phone, contacto.Id, Label.channelPhone);
        Consentimientos__c consentimientoMobile = CreaObjetos.creaConsentimiento(mobile, contacto.Id, Label.channelMobile);
        listConsentimientos.add(consentimientoEmail);
        listConsentimientos.add(consentimientoMobile);
        insert listConsentimientos;
        
        Case caso = new Case();
        caso.AccountId = cuenta.Id;
        caso.Centro__c = center.Id;
        caso.Marca__c = 'AUDI';
        caso.Intencion_de_compra__c = 'Oferta';
        caso.Origin = 'Web';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = phone;
        caso.SuppliedEmail = email;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        insert caso;
        Test.startTest();
        ExternalServiceController.createExternalLeadOrAccountMulesoft(JSON.serialize(new List<Case>{caso}), JSON.serialize(gLead));
        Test.stopTest();
    }
    
    @isTest
    static void ExternalServiceSendAccountTest() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMock());
        Centro__c center = [SELECT Id, Name,Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c,Marcas_VO__c,Telefono__c,Venta_de_VN__c,Venta_de_VO__c,CentroCdg__c,Concesionario__r.Id_Concesionario_Sima__c 
                            FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String email = 'prueba@prueba.com';
        String telefono ='+34699999123';
        Account cuenta = CreaObjetos.creaCuentaPersonal('Prueba', 'Test');
        Gestion_Lead__c gLead = [Select Id, Asesor__c,Centro__c, Centro_destino__c, Gestor_Lead__c, Intencion_de_compra__c, Marca__c  from Gestion_Lead__c limit 1];
        cuenta.PersonEmail = email;
        cuenta.PersonMobilePhone = telefono;
        cuenta.BillingCountry ='España';
        cuenta.ShippingCountry='España';
        insert cuenta;
        Contact contacto = [SELECT Id, Name FROM Contact where accountId = :cuenta.Id LIMIT 1];
        List<Consentimientos__c> listConsentimientos = new List<Consentimientos__c>();
        Consentimientos__c consentimientoEmail = CreaObjetos.creaConsentimiento(email, contacto.Id, Label.channelEmail);
        Consentimientos__c consentimientoMobile = CreaObjetos.creaConsentimiento(telefono, contacto.Id, Label.channelMobile);
        listConsentimientos.add(consentimientoEmail);
        listConsentimientos.add(consentimientoMobile);
        insert listConsentimientos;
        
        Case caso = new Case();
        caso.AccountId = cuenta.Id;
        caso.Centro__c = center.Id;
        caso.Marca__c = 'AUDI';
        caso.Intencion_de_compra__c = 'Prueba';
        caso.Origin = 'Web';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = telefono;
        caso.SuppliedEmail = email;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        insert caso;
        Test.startTest();
        ExternalServiceController.sendExternalLeadOrAccountEmail(JSON.serialize(new List<Case>{caso}), JSON.serialize(gLead));
        Test.stopTest();
    }
    
    @isTest
    static void ExternalServiceAccountSecTest() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMock());
        Centro__c center = [SELECT Id, Name,Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c,Marcas_VO__c,Telefono__c,Venta_de_VN__c,Venta_de_VO__c,CentroCdg__c,Concesionario__r.Id_Concesionario_Sima__c 
                            FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String email = 'prueba@prueba.com';
        String telefono ='+34699999123';
        Account cuenta = CreaObjetos.creaCuentaPersonal('Prueba', 'Test');
        Gestion_Lead__c gLead = [Select Id, Asesor__c,Centro__c, Centro_destino__c, Gestor_Lead__c, Intencion_de_compra__c, Marca__c  from Gestion_Lead__c limit 1];
        cuenta.PersonEmail = email;
        cuenta.PersonMobilePhone = telefono;
        cuenta.BillingCountry ='España';
        cuenta.ShippingCountry='España';
        insert cuenta;
        Contact contacto = [SELECT Id, Name FROM Contact where accountId = :cuenta.Id LIMIT 1];
        List<Consentimientos__c> listConsentimientos = new List<Consentimientos__c>();
        Consentimientos__c consentimientoEmail = CreaObjetos.creaConsentimiento(email, contacto.Id, Label.channelEmail);
        Consentimientos__c consentimientoMobile = CreaObjetos.creaConsentimiento(telefono, contacto.Id, Label.channelMobile);
        listConsentimientos.add(consentimientoEmail);
        listConsentimientos.add(consentimientoMobile);
        insert listConsentimientos;
        
        Case caso = new Case();
        caso.AccountId = cuenta.Id;
        caso.Centro__c = center.Id;
        caso.Marca__c = 'AUDI';
        caso.Intencion_de_compra__c = 'Prueba';
        caso.Origin = 'Web';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = telefono;
        caso.SuppliedEmail = email;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        insert caso;
        Test.startTest();
        ExternalServiceController.createExternalLeadOrAccountMulesoftSec(JSON.serialize(caso), JSON.serialize(gLead));
        Test.stopTest();
    }
    
    @isTest
    static void ExternalServiceAccountSecFailureTest() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMockFailure());
        Centro__c center = [SELECT Id, Name,Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c,Marcas_VO__c,Telefono__c,Venta_de_VN__c,Venta_de_VO__c,CentroCdg__c,Concesionario__r.Id_Concesionario_Sima__c 
                            FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String email = 'prueba@prueba.com';
        String telefono ='+34699999123';
        Account cuenta = CreaObjetos.creaCuentaPersonal('Prueba', 'Test');
        Gestion_Lead__c gLead = [Select Id, Asesor__c,Centro__c, Centro_destino__c, Gestor_Lead__c, Intencion_de_compra__c, Marca__c  from Gestion_Lead__c limit 1];
        cuenta.PersonEmail = email;
        cuenta.PersonMobilePhone = telefono;
        cuenta.BillingCountry ='España';
        cuenta.ShippingCountry='España';
        insert cuenta;
        Contact contacto = [SELECT Id, Name FROM Contact where accountId = :cuenta.Id LIMIT 1];
        List<Consentimientos__c> listConsentimientos = new List<Consentimientos__c>();
        Consentimientos__c consentimientoEmail = CreaObjetos.creaConsentimiento(email, contacto.Id, Label.channelEmail);
        Consentimientos__c consentimientoMobile = CreaObjetos.creaConsentimiento(telefono, contacto.Id, Label.channelMobile);
        listConsentimientos.add(consentimientoEmail);
        listConsentimientos.add(consentimientoMobile);
        insert listConsentimientos;
        
        Case caso = new Case();
        caso.AccountId = cuenta.Id;
        caso.Centro__c = center.Id;
        caso.Marca__c = 'AUDI';
        caso.Intencion_de_compra__c = 'Prueba';
        caso.Origin = 'Web';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = telefono;
        caso.SuppliedEmail = email;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        insert caso;
        Test.startTest();
        ExternalServiceController.createExternalLeadOrAccountMulesoftSec(JSON.serialize(caso), JSON.serialize(gLead));
        Test.stopTest();
    }
    
    @isTest
    static void ExternalServiceAccountEmailSecTest() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMock());
        Centro__c center = [SELECT Id, Name,Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c,Marcas_VO__c,Telefono__c,Venta_de_VN__c,Venta_de_VO__c,CentroCdg__c,Concesionario__r.Id_Concesionario_Sima__c 
                            FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String email = 'prueba@prueba.com';
        String telefono ='+34699999123';
        Account cuenta = CreaObjetos.creaCuentaPersonal('Prueba', 'Test');
        Gestion_Lead__c gLead = [Select Id, Asesor__c,Centro__c, Centro_destino__c, Gestor_Lead__c, Intencion_de_compra__c, Marca__c  from Gestion_Lead__c limit 1];
        cuenta.PersonEmail = email;
        cuenta.PersonMobilePhone = telefono;
        cuenta.BillingCountry ='España';
        cuenta.ShippingCountry='España';
        insert cuenta;
        Contact contacto = [SELECT Id, Name FROM Contact where accountId = :cuenta.Id LIMIT 1];
        List<Consentimientos__c> listConsentimientos = new List<Consentimientos__c>();
        Consentimientos__c consentimientoEmail = CreaObjetos.creaConsentimiento(email, contacto.Id, Label.channelEmail);
        Consentimientos__c consentimientoMobile = CreaObjetos.creaConsentimiento(telefono, contacto.Id, Label.channelMobile);
        listConsentimientos.add(consentimientoEmail);
        listConsentimientos.add(consentimientoMobile);
        insert listConsentimientos;
        
        Case caso = new Case();
        caso.AccountId = cuenta.Id;
        caso.Centro__c = center.Id;
        caso.Marca__c = 'AUDI';
        caso.Intencion_de_compra__c = 'Prueba';
        caso.Origin = 'Web';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = telefono;
        caso.SuppliedEmail = email;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        insert caso;
        Test.startTest();
        ExternalServiceController.sendExternalLedOrAccountEmailSec(JSON.serialize(caso), JSON.serialize(gLead));
        Test.stopTest();
    }
    
    @isTest
    static void ExternalServiceAccount2Test() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMock());
        Centro__c center = [SELECT Id, Name,Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c,Marcas_VO__c,Telefono__c,Venta_de_VN__c,Venta_de_VO__c,CentroCdg__c,Concesionario__r.Id_Concesionario_Sima__c 
                            FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String email = 'prueba@prueba.com';
        String phone = '918887766';
        String mobile ='+34699999123';
        Account cuenta = CreaObjetos.creaCuentaPersonal('Prueba', 'Test');
        Gestion_Lead__c gLead = [Select Id, Asesor__c,Centro__c, Centro_destino__c, Gestor_Lead__c, Intencion_de_compra__c, Marca__c  from Gestion_Lead__c limit 1];
        cuenta.PersonEmail = email;
        cuenta.Phone = phone;
        cuenta.PersonMobilePhone = mobile;
        insert cuenta;
        Cliente_Concesionario__c cConcesionario = CreaObjetos.creaClienteConcesionario(cuenta.Id, center.Concesionario__c, '111', center.Concesionario__r.Id_Concesionario_Sima__c);
        insert cConcesionario;
        Contact contacto = [SELECT Id, Name FROM Contact where accountId = :cuenta.Id LIMIT 1];
        List<Consentimientos__c> listConsentimientos = new List<Consentimientos__c>();
        Consentimientos__c consentimientoEmail = CreaObjetos.creaConsentimiento(email, contacto.Id, Label.channelEmail);
        Consentimientos__c consentimientoPhone = CreaObjetos.creaConsentimiento(phone, contacto.Id, Label.channelPhone);
        Consentimientos__c consentimientoMobile = CreaObjetos.creaConsentimiento(mobile, contacto.Id, Label.channelMobile);
        listConsentimientos.add(consentimientoEmail);
        listConsentimientos.add(consentimientoMobile);
        insert listConsentimientos;
        
        Case caso = new Case();
        caso.AccountId = cuenta.Id;
        caso.Centro__c = center.Id;
        caso.Marca__c = 'AUDI';
        caso.Intencion_de_compra__c = 'Prueba';
        caso.Origin = 'Web';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = phone;
        caso.SuppliedEmail = email;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        insert caso;
        Test.startTest();
        ExternalServiceController.createExternalLeadOrAccountMulesoft(JSON.serialize(new List<Case>{caso}), JSON.serialize(gLead));
        Test.stopTest();
    }
    
    @isTest
    static void ExternalServiceAccount2SecTest() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMock());
        Centro__c center = [SELECT Id, Name,Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c,Marcas_VO__c,Telefono__c,Venta_de_VN__c,Venta_de_VO__c,CentroCdg__c,Concesionario__r.Id_Concesionario_Sima__c 
                            FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String email = 'prueba@prueba.com';
        String telefono ='+34699999123';
        Account cuenta = CreaObjetos.creaCuentaPersonal('Prueba', 'Test');
        Gestion_Lead__c gLead = [Select Id, Asesor__c,Centro__c, Centro_destino__c, Gestor_Lead__c, Intencion_de_compra__c, Marca__c  from Gestion_Lead__c limit 1];
        cuenta.PersonEmail = email;
        cuenta.PersonMobilePhone = telefono;
        insert cuenta;
        Cliente_Concesionario__c cConcesionario = CreaObjetos.creaClienteConcesionario(cuenta.Id, center.Concesionario__c, '111', center.Concesionario__r.Id_Concesionario_Sima__c );
        insert cConcesionario;
        Contact contacto = [SELECT Id, Name FROM Contact where accountId = :cuenta.Id LIMIT 1];
        List<Consentimientos__c> listConsentimientos = new List<Consentimientos__c>();
        Consentimientos__c consentimientoEmail = CreaObjetos.creaConsentimiento(email, contacto.Id, Label.channelEmail);
        Consentimientos__c consentimientoMobile = CreaObjetos.creaConsentimiento(telefono, contacto.Id, Label.channelMobile);
        listConsentimientos.add(consentimientoEmail);
        listConsentimientos.add(consentimientoMobile);
        insert listConsentimientos;
        
        Case caso = new Case();
        caso.AccountId = cuenta.Id;
        caso.Centro__c = center.Id;
        caso.Marca__c = 'AUDI';
        caso.Intencion_de_compra__c = 'Prueba';
        caso.Origin = 'Web';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = telefono;
        caso.SuppliedEmail = email;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        insert caso;
        Test.startTest();
        ExternalServiceController.createExternalLeadOrAccountMulesoftSec(JSON.serialize(caso), JSON.serialize(gLead));
        Test.stopTest();
    }
    
    @isTest
    static void ExternalServiceLeadTest() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMock());
        Centro__c center = [SELECT Id, Name,Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c,Marcas_VO__c,Telefono__c,Venta_de_VN__c,Venta_de_VO__c,CentroCdg__c,Concesionario__r.Id_Concesionario_Sima__c 
                            FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String email = 'prueba@prueba.com';
        String telefono ='+34699999123';
        Lead candidato = CreaObjetos.creaLead('Prueba', 'Test');
        candidato.Email = email;
        candidato.Phone = telefono;
        insert candidato;
        Gestion_Lead__c gLead = [Select Id, Asesor__c,Centro__c, Centro_destino__c, Gestor_Lead__c, Intencion_de_compra__c, Marca__c  from Gestion_Lead__c limit 1];
        List<Consentimientos__c> listConsentimientos = new List<Consentimientos__c>();
        Consentimientos__c consentimientoEmail = CreaObjetos.creaConsentimientoOther(email, candidato.id, Label.channelEmail, true);
        Consentimientos__c consentimientoMobile = CreaObjetos.creaConsentimientoOther(telefono, candidato.Id, Label.channelMobile, true);
        listConsentimientos.add(consentimientoEmail);
        listConsentimientos.add(consentimientoMobile);
        insert listConsentimientos;
        
        Case caso = new Case();
        caso.Lead__c = candidato.Id;
        caso.Centro__c = center.Id;
        caso.Marca__c = 'AUDI';
        caso.Intencion_de_compra__c = 'Prueba;Oferta';
        caso.Origin = 'Web';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = telefono;
        caso.SuppliedEmail = email;
        caso.Modelo__c = 'A1;A3';
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        insert caso;
        Test.startTest();
        ExternalServiceController.createExternalLeadOrAccountMulesoft(JSON.serialize(new List<Case>{caso}), JSON.serialize(gLead));
        Test.stopTest();
    }
    
    @isTest
    static void ExternalServiceLeadEmailTest() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMock());
        Centro__c center = [SELECT Id, Name,Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c,Marcas_VO__c,Telefono__c,Venta_de_VN__c,Venta_de_VO__c,CentroCdg__c,Concesionario__r.Id_Concesionario_Sima__c 
                            FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String email = 'prueba@prueba.com';
        String telefono ='+34699999123';
        Lead candidato = CreaObjetos.creaLead('Prueba', 'Test');
        candidato.Email = email;
        candidato.Phone = telefono;
        insert candidato;
        Gestion_Lead__c gLead = [Select Id, Asesor__c,Centro__c, Centro_destino__c, Gestor_Lead__c, Intencion_de_compra__c, Marca__c  from Gestion_Lead__c limit 1];
        List<Consentimientos__c> listConsentimientos = new List<Consentimientos__c>();
        Consentimientos__c consentimientoEmail = CreaObjetos.creaConsentimientoOther(email, candidato.id, Label.channelEmail,true);
        Consentimientos__c consentimientoMobile = CreaObjetos.creaConsentimientoOther(telefono, candidato.Id, Label.channelMobile,true);
        listConsentimientos.add(consentimientoEmail);
        listConsentimientos.add(consentimientoMobile);
        insert listConsentimientos;
        
        Case caso = new Case();
        caso.Lead__c = candidato.Id;
        caso.Centro__c = center.Id;
        caso.Marca__c = 'AUDI';
        caso.Intencion_de_compra__c = 'Prueba';
        caso.Origin = 'Web';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = telefono;
        caso.SuppliedEmail = email;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        insert caso;
        Test.startTest();
        ExternalServiceController.sendExternalLeadOrAccountEmail(JSON.serialize(new List<Case>{caso}), JSON.serialize(gLead));
        Test.stopTest();
    }
    
    @isTest
    static void ExternalServiceLeadSecTest() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMock());
        Centro__c center = [SELECT Id, Name,Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c,Marcas_VO__c,Telefono__c,Venta_de_VN__c,Venta_de_VO__c,CentroCdg__c,Concesionario__r.Id_Concesionario_Sima__c 
                            FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String email = 'prueba@prueba.com';
        String telefono ='+34699999123';
        Lead candidato = CreaObjetos.creaLead('Prueba', 'Test');
        candidato.Email = email;
        candidato.Phone = telefono;
        insert candidato;
        Gestion_Lead__c gLead = [Select Id, Asesor__c,Centro__c, Centro_destino__c, Gestor_Lead__c, Intencion_de_compra__c, Marca__c  from Gestion_Lead__c limit 1];
        List<Consentimientos__c> listConsentimientos = new List<Consentimientos__c>();
        Consentimientos__c consentimientoEmail = CreaObjetos.creaConsentimientoOther(email, candidato.id, Label.channelEmail,true);
        Consentimientos__c consentimientoMobile = CreaObjetos.creaConsentimientoOther(telefono, candidato.Id, Label.channelMobile,true);
        listConsentimientos.add(consentimientoEmail);
        listConsentimientos.add(consentimientoMobile);
        insert listConsentimientos;
        
        Case caso = new Case();
        caso.Lead__c = candidato.Id;
        caso.Centro__c = center.Id;
        caso.Marca__c = 'AUDI';
        caso.Intencion_de_compra__c = 'Prueba';
        caso.Origin = 'Web';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = telefono;
        caso.SuppliedEmail = email;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        insert caso;
        Test.startTest();
        ExternalServiceController.createExternalLeadOrAccountMulesoftSec(JSON.serialize(caso), JSON.serialize(gLead));
        Test.stopTest();
    }
    
    @isTest
    static void ExternalServiceLeadDuplicadoTest() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMock());
        Centro__c center = [SELECT Id, Name,Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c,Marcas_VO__c,Telefono__c,Venta_de_VN__c,Venta_de_VO__c,CentroCdg__c,Concesionario__r.Id_Concesionario_Sima__c 
                            FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String email = 'prueba@prueba.com';
        String telefono ='+34699999123';
        Gestion_Lead__c gLead = [Select Id, Asesor__c,Centro__c, Centro_destino__c, Gestor_Lead__c, Intencion_de_compra__c, Marca__c  from Gestion_Lead__c limit 1];
        Lead candidato = CreaObjetos.creaLead('Prueba', 'Test');
        candidato.Email = email;
        candidato.Phone = telefono;
        insert candidato;
        
        Account cuenta = CreaObjetos.creaCuentaPersonal('Prueba', 'Test');
        candidato.Email = email;
        candidato.Phone = telefono;
        insert cuenta;
        Contact contacto = [SELECT Id, Name FROM Contact where accountId = :cuenta.Id LIMIT 1];
        List<Consentimientos__c> listConsentimientos = new List<Consentimientos__c>();
        Consentimientos__c consentimientoEmail = CreaObjetos.creaConsentimientoOther(email, candidato.id, Label.channelEmail,true);
        Consentimientos__c consentimientoMobile = CreaObjetos.creaConsentimientoOther(telefono, candidato.Id, Label.channelMobile,true);
        Consentimientos__c consentimientoEmailP = CreaObjetos.creaConsentimiento(email, contacto.id, Label.channelEmail);
        Consentimientos__c consentimientoMobileP = CreaObjetos.creaConsentimiento(telefono, contacto.Id, Label.channelMobile);
        listConsentimientos.add(consentimientoEmail);
        listConsentimientos.add(consentimientoMobile);
        listConsentimientos.add(consentimientoEmailP);
        listConsentimientos.add(consentimientoMobileP);
        insert listConsentimientos;
        
        Case caso = new Case();
        caso.Lead__c = candidato.Id;
        caso.Centro__c = center.Id;
        caso.Marca__c = 'AUDI';
        caso.Intencion_de_compra__c = 'Prueba';
        caso.Origin = 'Web';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = telefono;
        caso.SuppliedEmail = email;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        insert caso;
        Test.startTest();
        ExternalServiceController.createExternalLeadOrAccountMulesoft(JSON.serialize(new List<Case>{caso}), JSON.serialize(gLead));
        Test.stopTest();
    }
    
    @isTest
    static void ExternalServiceLeadDuplicadoSecTest() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMock());
        Centro__c center = [SELECT Id, Name,Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c,Marcas_VO__c,Telefono__c,Venta_de_VN__c,Venta_de_VO__c,CentroCdg__c,Concesionario__r.Id_Concesionario_Sima__c 
                            FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String email = 'prueba@prueba.com';
        String telefono ='+34699999123';
        Gestion_Lead__c gLead = [Select Id, Asesor__c,Centro__c, Centro_destino__c, Gestor_Lead__c, Intencion_de_compra__c, Marca__c  from Gestion_Lead__c limit 1];
        Lead candidato = CreaObjetos.creaLead('Prueba', 'Test');
        candidato.Email = email;
        candidato.Phone = telefono;
        insert candidato;
        
        Account cuenta = CreaObjetos.creaCuentaPersonal('Prueba', 'Test');
        candidato.Email = email;
        candidato.Phone = telefono;
        insert cuenta;
        Contact contacto = [SELECT Id, Name FROM Contact where accountId = :cuenta.Id LIMIT 1];
        List<Consentimientos__c> listConsentimientos = new List<Consentimientos__c>();
        Consentimientos__c consentimientoEmail = CreaObjetos.creaConsentimientoOther(email, candidato.id, Label.channelEmail,true);
        Consentimientos__c consentimientoMobile = CreaObjetos.creaConsentimientoOther(telefono, candidato.Id, Label.channelMobile,true);
        Consentimientos__c consentimientoEmailP = CreaObjetos.creaConsentimiento(email, contacto.id, Label.channelEmail);
        Consentimientos__c consentimientoMobileP = CreaObjetos.creaConsentimiento(telefono, contacto.Id, Label.channelMobile);
        listConsentimientos.add(consentimientoEmail);
        listConsentimientos.add(consentimientoMobile);
        listConsentimientos.add(consentimientoEmailP);
        listConsentimientos.add(consentimientoMobileP);
        insert listConsentimientos;
        
        Case caso = new Case();
        caso.Lead__c = candidato.Id;
        caso.Centro__c = center.Id;
        caso.Marca__c = 'AUDI';
        caso.Intencion_de_compra__c = 'Prueba';
        caso.Origin = 'Web';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = telefono;
        caso.SuppliedEmail = email;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        insert caso;
        Test.startTest();
        ExternalServiceController.createExternalLeadOrAccountMulesoftSec(JSON.serialize(caso), JSON.serialize(gLead));
        Test.stopTest();
    }
    
    @isTest
    static void ExternalServiceLeadDuplicadoEmailTest() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMock());
        Centro__c center = [SELECT Id, Name,Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c,Marcas_VO__c,Telefono__c,Venta_de_VN__c,Venta_de_VO__c,CentroCdg__c,Concesionario__r.Id_Concesionario_Sima__c 
                            FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String email = 'prueba@prueba.com';
        String telefono ='+34699999123';
        Gestion_Lead__c gLead = [Select Id, Asesor__c,Centro__c, Centro_destino__c, Gestor_Lead__c, Intencion_de_compra__c, Marca__c  from Gestion_Lead__c limit 1];
        Lead candidato = CreaObjetos.creaLead('Prueba', 'Test');
        candidato.Email = email;
        candidato.Phone = telefono;
        insert candidato;
        
        Account cuenta = CreaObjetos.creaCuentaPersonal('Prueba', 'Test');
        candidato.Email = email;
        candidato.Phone = telefono;
        insert cuenta;
        Contact contacto = [SELECT Id, Name FROM Contact where accountId = :cuenta.Id LIMIT 1];
        List<Consentimientos__c> listConsentimientos = new List<Consentimientos__c>();
        Consentimientos__c consentimientoEmail = CreaObjetos.creaConsentimientoOther(email, candidato.id, Label.channelEmail,true);
        Consentimientos__c consentimientoMobile = CreaObjetos.creaConsentimientoOther(telefono, candidato.Id, Label.channelMobile,true);
        Consentimientos__c consentimientoEmailP = CreaObjetos.creaConsentimiento(email, contacto.id, Label.channelEmail);
        Consentimientos__c consentimientoMobileP = CreaObjetos.creaConsentimiento(telefono, contacto.Id, Label.channelMobile);
        listConsentimientos.add(consentimientoEmail);
        listConsentimientos.add(consentimientoMobile);
        listConsentimientos.add(consentimientoEmailP);
        listConsentimientos.add(consentimientoMobileP);
        insert listConsentimientos;
        
        Case caso = new Case();
        caso.Lead__c = candidato.Id;
        caso.Centro__c = center.Id;
        caso.Marca__c = 'AUDI';
        caso.Intencion_de_compra__c = 'Prueba';
        caso.Origin = 'Web';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = telefono;
        caso.SuppliedEmail = email;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        insert caso;
        Test.startTest();
        ExternalServiceController.sendExternalLeadOrAccountEmail(JSON.serialize(new List<Case>{caso}), JSON.serialize(gLead));
        Test.stopTest();
    }
    
    @isTest
    static void ExternalServiceSendAccountVOTest() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMock());
        Centro__c center = [SELECT Id, Name, Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c, Marcas_VO__c, Telefono__c, Venta_de_VN__c, Venta_de_VO__c, CentroCdg__c, Concesionario__r.Id_Concesionario_Sima__c 
                            FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String email = 'prueba@prueba.com';
        String telefono ='+34699999123';
        Account cuenta = CreaObjetos.creaCuentaPersonal('Prueba', 'Test');
        Gestion_Lead__c gLead = [Select Id, Asesor__c, Centro__c, Centro_destino__c, Gestor_Lead__c, Intencion_de_compra__c, Marca__c  from Gestion_Lead__c limit 1];
        cuenta.PersonEmail = email;
        cuenta.PersonMobilePhone = telefono;
        cuenta.BillingCountry ='España';
        cuenta.ShippingCountry='España';
        insert cuenta;
        Contact contacto = [SELECT Id, Name FROM Contact where accountId = :cuenta.Id LIMIT 1];
        List<Consentimientos__c> listConsentimientos = new List<Consentimientos__c>();
        Consentimientos__c consentimientoEmail = CreaObjetos.creaConsentimiento(email, contacto.Id, Label.channelEmail);
        Consentimientos__c consentimientoMobile = CreaObjetos.creaConsentimiento(telefono, contacto.Id, Label.channelMobile);
        listConsentimientos.add(consentimientoEmail);
        listConsentimientos.add(consentimientoMobile);
        insert listConsentimientos;
        
        Case caso = new Case();
        caso.AccountId = cuenta.Id;
        caso.Centro__c = center.Id;
        caso.Marca__c = 'AUDI';
        caso.Intencion_de_compra__c = 'Prueba';
        caso.Origin = 'Web';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = telefono;
        caso.SuppliedEmail = email;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        insert caso;
        Test.startTest();
        ExternalServiceController.sendExternalLeadOrAccountVO(JSON.serialize(new List<Case>{caso}), JSON.serialize(gLead));
        Test.stopTest();
    }
    
    @isTest
    static void ExternalServiceSendAccountVO2Test() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMock());
        Centro__c center = [SELECT Id, Name, Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c, Marcas_VO__c, Telefono__c, Venta_de_VN__c, Venta_de_VO__c, CentroCdg__c, Concesionario__r.Id_Concesionario_Sima__c 
                            FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String email = 'prueba@prueba.com';
        String telefono ='+34699999123';
        Account cuenta = CreaObjetos.creaCuentaPersonal('Prueba', 'Test');
        Gestion_Lead__c gLead = [Select Id, Asesor__c, Centro__c, Centro_destino__c, Gestor_Lead__c, Intencion_de_compra__c, Marca__c  from Gestion_Lead__c limit 1];
        cuenta.PersonEmail = email;
        cuenta.PersonMobilePhone = telefono;
        cuenta.BillingCountry ='España';
        cuenta.ShippingCountry='España';
        insert cuenta;
        Cliente_Concesionario__c cliConc = CreaObjetos.creaClienteConcesionario(cuenta.Id, center.Concesionario__c, 'cli01', center.Concesionario__r.Id_Concesionario_Sima__c );
        insert cliConc;
        Contact contacto = [SELECT Id, Name FROM Contact where accountId = :cuenta.Id LIMIT 1];
        List<Consentimientos__c> listConsentimientos = new List<Consentimientos__c>();
        Consentimientos__c consentimientoEmail = CreaObjetos.creaConsentimiento(email, contacto.Id, Label.channelEmail);
        Consentimientos__c consentimientoMobile = CreaObjetos.creaConsentimiento(telefono, contacto.Id, Label.channelMobile);
        listConsentimientos.add(consentimientoEmail);
        listConsentimientos.add(consentimientoMobile);
        insert listConsentimientos;
        
        Case caso = new Case();
        caso.AccountId = cuenta.Id;
        caso.Centro__c = center.Id;
        caso.Marca__c = 'AUDI';
        caso.Intencion_de_compra__c = 'Prueba';
        caso.Origin = 'Web';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = telefono;
        caso.SuppliedEmail = email;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        insert caso;
        Test.startTest();
        ExternalServiceController.sendExternalLeadOrAccountVO(JSON.serialize(new List<Case>{caso}), JSON.serialize(gLead));
        Test.stopTest();
    }
    
    @isTest
    static void ExternalServiceSendAccountVO3Test() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMock());
        Centro__c center = [SELECT Id, Name, Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c, Marcas_VO__c, Telefono__c, Venta_de_VN__c, Venta_de_VO__c, CentroCdg__c, Concesionario__r.Id_Concesionario_Sima__c 
                            FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String email = 'prueba@prueba.com';
        String telefono ='+34699999123';
        Account cuenta = CreaObjetos.creaCuentaPersonal('Prueba', 'Test');
        Gestion_Lead__c gLead = [Select Id, Asesor__c, Centro__c, Centro_destino__c, Gestor_Lead__c, Intencion_de_compra__c, Marca__c  from Gestion_Lead__c limit 1];
        cuenta.PersonEmail = email;
        cuenta.PersonMobilePhone = telefono;
        cuenta.BillingCountry ='España';
        cuenta.ShippingCountry='España';
        insert cuenta;
        Cliente_Concesionario__c cliConc = CreaObjetos.creaClienteConcesionario(cuenta.Id, center.Concesionario__c, 'cli01', center.Concesionario__r.Id_Concesionario_Sima__c );
        insert cliConc;
        Contact contacto = [SELECT Id, Name FROM Contact where accountId = :cuenta.Id LIMIT 1];
        List<Consentimientos__c> listConsentimientos = new List<Consentimientos__c>();
        Consentimientos__c consentimientoEmail = CreaObjetos.creaConsentimiento(email, contacto.Id, Label.channelEmail);
        Consentimientos__c consentimientoMobile = CreaObjetos.creaConsentimiento(telefono, contacto.Id, Label.channelMobile);
        listConsentimientos.add(consentimientoEmail);
        listConsentimientos.add(consentimientoMobile);
        insert listConsentimientos;
        
        Concesionario__c conces = new Concesionario__c();
        conces.Id_Concesionario_Sima__c = '002';
        conces.Name='conces2';
        conces.Domicilio__c='avenida prueba 12';
        conces.Es_propio__c = true;
        conces.Es_SIMA__c = true;
        conces.Nombre_Comercial__c ='NEG';
        conces.CIF__c = 'CIFConcesionario2';
        insert conces;
        
        center.Concesionario__c = conces.Id;
        update center;
        
        Case caso = new Case();
        caso.AccountId = cuenta.Id;
        caso.Centro__c = center.Id;
        caso.Marca__c = 'AUDI';
        caso.Intencion_de_compra__c = 'Prueba';
        caso.Origin = 'Web';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = telefono;
        caso.SuppliedEmail = email;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        insert caso;
        Test.startTest();
        ExternalServiceController.sendExternalLeadOrAccountVO(JSON.serialize(new List<Case>{caso}), JSON.serialize(gLead));
        Test.stopTest();
    }
    
    @isTest
    static void ExternalServiceSendAccountVOFailureTest() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMockFailure());
        Centro__c center = [SELECT Id, Name, Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c, Marcas_VO__c, Telefono__c, Venta_de_VN__c, Venta_de_VO__c, CentroCdg__c, Concesionario__r.Id_Concesionario_Sima__c 
                            FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String email = 'prueba@prueba.com';
        String telefono ='+34699999123';
        Account cuenta = CreaObjetos.creaCuentaPersonal('Prueba', 'Test');
        Gestion_Lead__c gLead = [Select Id, Asesor__c, Centro__c, Centro_destino__c, Gestor_Lead__c, Intencion_de_compra__c, Marca__c  from Gestion_Lead__c limit 1];
        cuenta.PersonEmail = email;
        cuenta.PersonMobilePhone = telefono;
        cuenta.BillingCountry ='España';
        cuenta.ShippingCountry='España';
        insert cuenta;
        Contact contacto = [SELECT Id, Name FROM Contact where accountId = :cuenta.Id LIMIT 1];
        List<Consentimientos__c> listConsentimientos = new List<Consentimientos__c>();
        Consentimientos__c consentimientoEmail = CreaObjetos.creaConsentimiento(email, contacto.Id, Label.channelEmail);
        Consentimientos__c consentimientoMobile = CreaObjetos.creaConsentimiento(telefono, contacto.Id, Label.channelMobile);
        listConsentimientos.add(consentimientoEmail);
        listConsentimientos.add(consentimientoMobile);
        insert listConsentimientos;
        
        Case caso = new Case();
        caso.AccountId = cuenta.Id;
        caso.Centro__c = center.Id;
        caso.Marca__c = 'AUDI';
        caso.Intencion_de_compra__c = 'Prueba';
        caso.Origin = 'Web';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = telefono;
        caso.SuppliedEmail = email;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        insert caso;
        Test.startTest();
        ExternalServiceController.sendExternalLeadOrAccountVO(JSON.serialize(new List<Case>{caso}), JSON.serialize(gLead));
        Test.stopTest();
    }
    
    @isTest
    static void ExternalServiceSendAccountVOSecTest() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMock());
        Centro__c center = [SELECT Id, Name, Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c, Marcas_VO__c, Telefono__c, Venta_de_VN__c, Venta_de_VO__c, CentroCdg__c, Concesionario__r.Id_Concesionario_Sima__c 
                            FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String email = 'prueba@prueba.com';
        String telefono ='+34699999123';
        Account cuenta = CreaObjetos.creaCuentaPersonal('Prueba', 'Test');
        Cliente_Concesionario__c cliConc = CreaObjetos.creaClienteConcesionario(cuenta.Id, center.Concesionario__c, 'cli01',center.Concesionario__r.Id_Concesionario_Sima__c  );
        Gestion_Lead__c gLead = [Select Id, Asesor__c, Centro__c, Centro_destino__c, Gestor_Lead__c, Intencion_de_compra__c, Marca__c  from Gestion_Lead__c limit 1];
        cuenta.PersonEmail = email;
        cuenta.PersonMobilePhone = telefono;
        cuenta.BillingCountry ='España';
        cuenta.ShippingCountry='España';
        insert cuenta;
        Contact contacto = [SELECT Id, Name FROM Contact where accountId = :cuenta.Id LIMIT 1];
        List<Consentimientos__c> listConsentimientos = new List<Consentimientos__c>();
        Consentimientos__c consentimientoEmail = CreaObjetos.creaConsentimiento(email, contacto.Id, Label.channelEmail);
        Consentimientos__c consentimientoMobile = CreaObjetos.creaConsentimiento(telefono, contacto.Id, Label.channelMobile);
        listConsentimientos.add(consentimientoEmail);
        listConsentimientos.add(consentimientoMobile);
        insert listConsentimientos;
        
        Case caso = new Case();
        caso.AccountId = cuenta.Id;
        caso.Centro__c = center.Id;
        caso.Marca__c = 'AUDI';
        caso.Intencion_de_compra__c = 'Prueba';
        caso.Origin = 'Web';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = telefono;
        caso.SuppliedEmail = email;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        insert caso;
        Test.startTest();
        ExternalServiceController.sendExternalLeadOrAccountVOSec(JSON.serialize(caso), JSON.serialize(gLead));
        Test.stopTest();
    }
    
    @isTest
    static void ExternalServiceSendAccountVOSecFailureTest() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMockFailure());
        Centro__c center = [SELECT Id, Name, Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c, Marcas_VO__c, Telefono__c, Venta_de_VN__c, Venta_de_VO__c, CentroCdg__c, Concesionario__r.Id_Concesionario_Sima__c 
                            FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String email = 'prueba@prueba.com';
        String telefono ='+34699999123';
        Account cuenta = CreaObjetos.creaCuentaPersonal('Prueba', 'Test');
        Cliente_Concesionario__c cliConc = CreaObjetos.creaClienteConcesionario(cuenta.Id, center.Concesionario__c, 'cli01', center.Concesionario__r.Id_Concesionario_Sima__c );
        Gestion_Lead__c gLead = [Select Id, Asesor__c, Centro__c, Centro_destino__c, Gestor_Lead__c, Intencion_de_compra__c, Marca__c  from Gestion_Lead__c limit 1];
        cuenta.PersonEmail = email;
        cuenta.PersonMobilePhone = telefono;
        cuenta.BillingCountry ='España';
        cuenta.ShippingCountry='España';
        insert cuenta;
        Contact contacto = [SELECT Id, Name FROM Contact where accountId = :cuenta.Id LIMIT 1];
        List<Consentimientos__c> listConsentimientos = new List<Consentimientos__c>();
        Consentimientos__c consentimientoEmail = CreaObjetos.creaConsentimiento(email, contacto.Id, Label.channelEmail);
        Consentimientos__c consentimientoMobile = CreaObjetos.creaConsentimiento(telefono, contacto.Id, Label.channelMobile);
        listConsentimientos.add(consentimientoEmail);
        listConsentimientos.add(consentimientoMobile);
        insert listConsentimientos;
        
        Case caso = new Case();
        caso.AccountId = cuenta.Id;
        caso.Centro__c = center.Id;
        caso.Marca__c = 'AUDI';
        caso.Intencion_de_compra__c = 'Prueba';
        caso.Origin = 'Web';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = telefono;
        caso.SuppliedEmail = email;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        insert caso;
        Test.startTest();
        ExternalServiceController.sendExternalLeadOrAccountVOSec(JSON.serialize(caso), JSON.serialize(gLead));
        Test.stopTest();
    }
    
    @isTest
    static void ExternalServiceSendLeadVOTest() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMock());
        Centro__c center = [SELECT Id, Name,Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c,Marcas_VO__c,Telefono__c,Venta_de_VN__c,Venta_de_VO__c,CentroCdg__c,Concesionario__r.Id_Concesionario_Sima__c 
                            FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String email = 'prueba@prueba.com';
        String telefono ='+34699999123';
        Gestion_Lead__c gLead = [Select Id, Asesor__c,Centro__c, Centro_destino__c, Gestor_Lead__c, Intencion_de_compra__c, Marca__c  from Gestion_Lead__c limit 1];
        Lead candidato = CreaObjetos.creaLead('Prueba', 'Test');
        candidato.Email = email;
        candidato.Phone = telefono;
        insert candidato;
        
        Account cuenta = CreaObjetos.creaCuentaPersonal('Prueba', 'Test');
        candidato.Email = email;
        candidato.Phone = telefono;
        insert cuenta;
        Contact contacto = [SELECT Id, Name FROM Contact where accountId = :cuenta.Id LIMIT 1];
        List<Consentimientos__c> listConsentimientos = new List<Consentimientos__c>();
        Consentimientos__c consentimientoEmail = CreaObjetos.creaConsentimientoOther(email, candidato.id, Label.channelEmail,true);
        Consentimientos__c consentimientoMobile = CreaObjetos.creaConsentimientoOther(telefono, candidato.Id, Label.channelMobile,true);
        Consentimientos__c consentimientoEmailP = CreaObjetos.creaConsentimiento(email, contacto.id, Label.channelEmail);
        Consentimientos__c consentimientoMobileP = CreaObjetos.creaConsentimiento(telefono, contacto.Id, Label.channelMobile);
        listConsentimientos.add(consentimientoEmail);
        listConsentimientos.add(consentimientoMobile);
        listConsentimientos.add(consentimientoEmailP);
        listConsentimientos.add(consentimientoMobileP);
        insert listConsentimientos;
        
        Case caso = new Case();
        caso.Lead__c = candidato.Id;
        caso.Centro__c = center.Id;
        caso.Marca__c = 'AUDI';
        caso.Intencion_de_compra__c = 'Prueba';
        caso.Origin = 'Web';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = telefono;
        caso.SuppliedEmail = email;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        insert caso;
        Test.startTest();
        ExternalServiceController.sendExternalLeadOrAccountVO(JSON.serialize(new List<Case>{caso}), JSON.serialize(gLead));
        Test.stopTest();
    }
    
    @isTest
    static void ExternalServiceSendLeadVOFailureTest() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMockFailure());
        Centro__c center = [SELECT Id, Name,Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c,Marcas_VO__c,Telefono__c,Venta_de_VN__c,Venta_de_VO__c,CentroCdg__c,Concesionario__r.Id_Concesionario_Sima__c 
                            FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String email = 'prueba@prueba.com';
        String telefono ='+34699999123';
        Gestion_Lead__c gLead = [Select Id, Asesor__c,Centro__c, Centro_destino__c, Gestor_Lead__c, Intencion_de_compra__c, Marca__c  from Gestion_Lead__c limit 1];
        Lead candidato = CreaObjetos.creaLead('Prueba', 'Test');
        candidato.Email = email;
        candidato.Phone = telefono;
        insert candidato;
        
        Account cuenta = CreaObjetos.creaCuentaPersonal('Prueba', 'Test');
        candidato.Email = email;
        candidato.Phone = telefono;
        insert cuenta;
        Contact contacto = [SELECT Id, Name FROM Contact where accountId = :cuenta.Id LIMIT 1];
        List<Consentimientos__c> listConsentimientos = new List<Consentimientos__c>();
        Consentimientos__c consentimientoEmail = CreaObjetos.creaConsentimientoOther(email, candidato.id, Label.channelEmail,true);
        Consentimientos__c consentimientoMobile = CreaObjetos.creaConsentimientoOther(telefono, candidato.Id, Label.channelMobile,true);
        Consentimientos__c consentimientoEmailP = CreaObjetos.creaConsentimiento(email, contacto.id, Label.channelEmail);
        Consentimientos__c consentimientoMobileP = CreaObjetos.creaConsentimiento(telefono, contacto.Id, Label.channelMobile);
        listConsentimientos.add(consentimientoEmail);
        listConsentimientos.add(consentimientoMobile);
        listConsentimientos.add(consentimientoEmailP);
        listConsentimientos.add(consentimientoMobileP);
        insert listConsentimientos;
        
        Case caso = new Case();
        caso.Lead__c = candidato.Id;
        caso.Centro__c = center.Id;
        caso.Marca__c = 'AUDI';
        caso.Intencion_de_compra__c = 'Prueba';
        caso.Origin = 'Web';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = telefono;
        caso.SuppliedEmail = email;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        insert caso;
        Test.startTest();
        ExternalServiceController.sendExternalLeadOrAccountVO(JSON.serialize(new List<Case>{caso}), JSON.serialize(gLead));
        Test.stopTest();
    }
    
    @isTest
    static void ExternalServiceSendLeadVOSecTest() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMock());
        Centro__c center = [SELECT Id, Name,Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c,Marcas_VO__c,Telefono__c,Venta_de_VN__c,Venta_de_VO__c,CentroCdg__c,Concesionario__r.Id_Concesionario_Sima__c 
                            FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String email = 'prueba@prueba.com';
        String telefono ='+34699999123';
        Gestion_Lead__c gLead = [Select Id, Asesor__c,Centro__c, Centro_destino__c, Gestor_Lead__c, Intencion_de_compra__c, Marca__c  from Gestion_Lead__c limit 1];
        Lead candidato = CreaObjetos.creaLead('Prueba', 'Test Tset');
        candidato.Email = email;
        candidato.Phone = telefono;
        insert candidato;
        
        Account cuenta = CreaObjetos.creaCuentaPersonal('Prueba', 'Test');
        candidato.Email = email;
        candidato.Phone = telefono;
        insert cuenta;
        Contact contacto = [SELECT Id, Name FROM Contact where accountId = :cuenta.Id LIMIT 1];
        List<Consentimientos__c> listConsentimientos = new List<Consentimientos__c>();
        Consentimientos__c consentimientoEmail = CreaObjetos.creaConsentimientoOther(email, candidato.id, Label.channelEmail,true);
        Consentimientos__c consentimientoMobile = CreaObjetos.creaConsentimientoOther(telefono, candidato.Id, Label.channelMobile,true);
        Consentimientos__c consentimientoEmailP = CreaObjetos.creaConsentimiento(email, contacto.id, Label.channelEmail);
        Consentimientos__c consentimientoMobileP = CreaObjetos.creaConsentimiento(telefono, contacto.Id, Label.channelMobile);
        listConsentimientos.add(consentimientoEmail);
        listConsentimientos.add(consentimientoMobile);
        listConsentimientos.add(consentimientoEmailP);
        listConsentimientos.add(consentimientoMobileP);
        insert listConsentimientos;
        
        Case caso = new Case();
        caso.Lead__c = candidato.Id;
        caso.Centro__c = center.Id;
        caso.Marca__c = 'AUDI';
        caso.Intencion_de_compra__c = 'Prueba';
        caso.Origin = 'Web';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = telefono;
        caso.SuppliedEmail = email;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        insert caso;
        Test.startTest();
        ExternalServiceController.sendExternalLeadOrAccountVOSec(JSON.serialize(caso), JSON.serialize(gLead));
        Test.stopTest();
    }
    
    @isTest
    static void ExternalServiceSendLeadVOSecFailureTest() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMockFailure());
        Centro__c center = [SELECT Id, Name,Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c,Marcas_VO__c,Telefono__c,Venta_de_VN__c,Venta_de_VO__c,CentroCdg__c,Concesionario__r.Id_Concesionario_Sima__c 
                            FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String email = 'prueba@prueba.com';
        String telefono ='+34699999123';
        Gestion_Lead__c gLead = [Select Id, Asesor__c,Centro__c, Centro_destino__c, Gestor_Lead__c, Intencion_de_compra__c, Marca__c  from Gestion_Lead__c limit 1];
        Lead candidato = CreaObjetos.creaLead('Prueba', 'Test Tset');
        candidato.Email = email;
        candidato.Phone = telefono;
        insert candidato;
        
        Account cuenta = CreaObjetos.creaCuentaPersonal('Prueba', 'Test');
        candidato.Email = email;
        candidato.Phone = telefono;
        insert cuenta;
        Contact contacto = [SELECT Id, Name FROM Contact where accountId = :cuenta.Id LIMIT 1];
        List<Consentimientos__c> listConsentimientos = new List<Consentimientos__c>();
        Consentimientos__c consentimientoEmail = CreaObjetos.creaConsentimientoOther(email, candidato.id, Label.channelEmail,true);
        Consentimientos__c consentimientoMobile = CreaObjetos.creaConsentimientoOther(telefono, candidato.Id, Label.channelMobile,true);
        Consentimientos__c consentimientoEmailP = CreaObjetos.creaConsentimiento(email, contacto.id, Label.channelEmail);
        Consentimientos__c consentimientoMobileP = CreaObjetos.creaConsentimiento(telefono, contacto.Id, Label.channelMobile);
        listConsentimientos.add(consentimientoEmail);
        listConsentimientos.add(consentimientoMobile);
        listConsentimientos.add(consentimientoEmailP);
        listConsentimientos.add(consentimientoMobileP);
        insert listConsentimientos;
        
        Case caso = new Case();
        caso.Lead__c = candidato.Id;
        caso.Centro__c = center.Id;
        caso.Marca__c = 'AUDI';
        caso.Intencion_de_compra__c = 'Prueba';
        caso.Origin = 'Web';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = telefono;
        caso.SuppliedEmail = email;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        insert caso;
        Test.startTest();
        ExternalServiceController.sendExternalLeadOrAccountVOSec(JSON.serialize(caso), JSON.serialize(gLead));
        Test.stopTest();
    }
        
    @isTest
    static void ExternalServiceLeadDuplicadoEmailSecTest() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMock());
        Centro__c center = [SELECT Id, Name,Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c,Marcas_VO__c,Telefono__c,Venta_de_VN__c,Venta_de_VO__c,CentroCdg__c,Concesionario__r.Id_Concesionario_Sima__c 
                            FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String email = 'prueba@prueba.com';
        String telefono ='699999123';
        Gestion_Lead__c gLead = [Select Id, Asesor__c,Centro__c, Centro_destino__c, Gestor_Lead__c, Intencion_de_compra__c, Marca__c  from Gestion_Lead__c limit 1];
        Lead candidato = CreaObjetos.creaLead('Prueba', 'Test');
        candidato.Email = email;
        candidato.Phone = telefono;
        insert candidato;
        
        Account cuenta = CreaObjetos.creaCuentaPersonal('Prueba', 'Test');
        candidato.Email = email;
        candidato.Phone = telefono;
        insert cuenta;
        Contact contacto = [SELECT Id, Name FROM Contact where accountId = :cuenta.Id LIMIT 1];
        List<Consentimientos__c> listConsentimientos = new List<Consentimientos__c>();
        Consentimientos__c consentimientoEmail = CreaObjetos.creaConsentimientoOther(email, candidato.id, Label.channelEmail,true);
        Consentimientos__c consentimientoMobile = CreaObjetos.creaConsentimientoOther(telefono, candidato.Id, Label.channelMobile,true);
        Consentimientos__c consentimientoEmailP = CreaObjetos.creaConsentimiento(email, contacto.id, Label.channelEmail);
        Consentimientos__c consentimientoMobileP = CreaObjetos.creaConsentimiento(telefono, contacto.Id, Label.channelMobile);
        listConsentimientos.add(consentimientoEmail);
        listConsentimientos.add(consentimientoMobile);
        listConsentimientos.add(consentimientoEmailP);
        listConsentimientos.add(consentimientoMobileP);
        insert listConsentimientos;
        
        Case caso = new Case();
        caso.Lead__c = candidato.Id;
        caso.Centro__c = center.Id;
        caso.Marca__c = 'AUDI';
        caso.Intencion_de_compra__c = 'Prueba';
        caso.Origin = 'Web';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = telefono;
        caso.SuppliedEmail = email;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        insert caso;
        Test.startTest();
        ExternalServiceController.sendExternalLedOrAccountEmailSec(JSON.serialize(caso), JSON.serialize(gLead));
        Test.stopTest();
    }
    
    @isTest
    static void ExternalServiceAccountEmpresaTest() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMock());
        Centro__c center = [SELECT Id, Name,Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c,Marcas_VO__c,Telefono__c,Venta_de_VN__c,Venta_de_VO__c,CentroCdg__c,Concesionario__r.Id_Concesionario_Sima__c 
                            FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String email = 'prueba@prueba.com';
        String telefono ='+34699999123';
        Gestion_Lead__c gLead = [Select Id, Asesor__c,Centro__c, Centro_destino__c, Gestor_Lead__c, Intencion_de_compra__c, Marca__c  from Gestion_Lead__c limit 1];
        Account cuenta = CreaObjetos.creaCuentaEmpresa('Prueba');
        cuenta.Email__c = email;
        cuenta.Mobile__c = telefono;
        cuenta.BillingCountry ='España';
        cuenta.ShippingCountry='España';
        cuenta.Tipo_de_documento_empresa__c = 'VATId';
        cuenta.Documento__c = 'TST001';
        insert cuenta;
        
        Case caso = new Case();
        caso.AccountId = cuenta.Id;
        caso.Centro__c = center.Id;
        caso.Marca__c = 'AUDI';
        caso.Intencion_de_compra__c = 'Prueba';
        caso.Origin = 'Web';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = telefono;
        caso.SuppliedEmail = email;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        insert caso;
        Test.startTest();
        ExternalServiceController.createExternalLeadOrAccountMulesoft(JSON.serialize(new List<Case>{caso}), JSON.serialize(gLead));
        Test.stopTest();
    }
 
    @isTest
    static void ExternalServiceNotSIMATest() {
        Concesionario__c conces = [SELECT Id, Es_SIMA__c FROM Concesionario__c LIMIT 1];
        conces.Es_SIMA__c = false;
        update conces;
        
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMock());
        Centro__c center = [SELECT Id, Name,Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c,Marcas_VO__c,Telefono__c,Venta_de_VN__c,Venta_de_VO__c,CentroCdg__c,Concesionario__r.Id_Concesionario_Sima__c 
                            FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String email = 'prueba@prueba.com';
        String telefono ='+34699999123';
        Account cuenta = CreaObjetos.creaCuentaPersonal('Prueba', 'Test');
        Gestion_Lead__c gLead = [Select Id, Asesor__c,Centro__c, Centro_destino__c, Gestor_Lead__c, Intencion_de_compra__c, Marca__c  from Gestion_Lead__c limit 1];
        cuenta.PersonEmail = email;
        cuenta.PersonMobilePhone = telefono;
        cuenta.BillingCountry ='España';
        cuenta.ShippingCountry='España';
        insert cuenta;
        Contact contacto = [SELECT Id, Name FROM Contact where accountId = :cuenta.Id LIMIT 1];
        List<Consentimientos__c> listConsentimientos = new List<Consentimientos__c>();
        Consentimientos__c consentimientoEmail = CreaObjetos.creaConsentimiento(email, contacto.Id, Label.channelEmail);
        Consentimientos__c consentimientoMobile = CreaObjetos.creaConsentimiento(telefono, contacto.Id, Label.channelMobile);
        listConsentimientos.add(consentimientoEmail);
        listConsentimientos.add(consentimientoMobile);
        insert listConsentimientos;
        
        Case caso = new Case();
        caso.AccountId = cuenta.Id;
        caso.Centro__c = center.Id;
        caso.Marca__c = 'AUDI';
        caso.Intencion_de_compra__c = 'Prueba';
        caso.Origin = 'Web';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = telefono;
        caso.SuppliedEmail = email;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        insert caso;
        Test.startTest();
        ExternalServiceController.createExternalLeadOrAccountMulesoft(JSON.serialize(new List<Case>{caso}), JSON.serialize(gLead));
        Test.stopTest();
	}
    
    @isTest
    static void ExternalServiceternalEmailFeedbackTest() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMockFailure());
        Centro__c center = [SELECT Id, Name,Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c,Marcas_VO__c,Telefono__c,Venta_de_VN__c,Venta_de_VO__c,CentroCdg__c,Concesionario__r.Id_Concesionario_Sima__c 
                            FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String email = 'prueba@prueba.com';
        String phone = '918887766';
        String mobile ='+34699999123';
        Account cuenta = CreaObjetos.creaCuentaPersonal('Prueba', 'Test Tset');
        Gestion_Lead__c gLead = [Select Id, Asesor__c,Centro__c, Gestor_Lead__c, Intencion_de_compra__c, Marca__c  from Gestion_Lead__c limit 1];
        cuenta.PersonEmail = email;
        cuenta.Phone = phone;
        cuenta.PersonMobilePhone = mobile;
        cuenta.BillingCountry ='España';
        cuenta.ShippingCountry='España';
        cuenta.Tipo_de_documento_cuenta_personal__c = 'VATId';
        cuenta.Documento__c = 'TST001';
        insert cuenta;
        Contact contacto = [SELECT Id, Name FROM Contact where accountId = :cuenta.Id LIMIT 1];
        List<Consentimientos__c> listConsentimientos = new List<Consentimientos__c>();
        Consentimientos__c consentimientoEmail = CreaObjetos.creaConsentimiento(email, contacto.Id, Label.channelEmail);
        Consentimientos__c consentimientoPhone = CreaObjetos.creaConsentimiento(phone, contacto.Id, Label.channelPhone);
        Consentimientos__c consentimientoMobile = CreaObjetos.creaConsentimiento(mobile, contacto.Id, Label.channelMobile);
        listConsentimientos.add(consentimientoEmail);
        listConsentimientos.add(consentimientoMobile);
        insert listConsentimientos;
        
        Case caso = new Case();
        caso.AccountId = cuenta.Id;
        caso.Centro__c = center.Id;
        caso.Marca__c = 'DUCATI';
        caso.Intencion_de_compra__c = 'Oferta';
        caso.Origin = 'Email';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = phone;
        caso.SuppliedEmail = email;
        
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        caso.SalesmanEmail__c = 'vendedor1@prueba.com';
        insert caso;
        Test.startTest();
        ExternalServiceController.sendExternalEmailFeedback(JSON.serialize(new List<Case>{caso}));
        Test.stopTest();
    }

    @isTest
    static void ExternalServiceternalEmailATTClienteTest() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMockFailure());
        Centro__c center = [SELECT Id, Name,Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c,Marcas_VO__c,Telefono__c,Venta_de_VN__c,Venta_de_VO__c,CentroCdg__c,Concesionario__r.Id_Concesionario_Sima__c 
                            FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String email = 'prueba@prueba.com';
        String phone = '918887766';
        String mobile ='+34699999123';
        Account cuenta = CreaObjetos.creaCuentaPersonal('Prueba', 'Test Tset');
        Gestion_Lead__c gLead = [Select Id, Asesor__c,Centro__c, Gestor_Lead__c, Intencion_de_compra__c, Marca__c  from Gestion_Lead__c limit 1];
        cuenta.PersonEmail = email;
        cuenta.Phone = phone;
        cuenta.PersonMobilePhone = mobile;
        cuenta.BillingCountry ='España';
        cuenta.ShippingCountry='España';
        cuenta.Tipo_de_documento_cuenta_personal__c = 'VATId';
        cuenta.Documento__c = 'TST001';
        insert cuenta;
        Contact contacto = [SELECT Id, Name FROM Contact where accountId = :cuenta.Id LIMIT 1];
        List<Consentimientos__c> listConsentimientos = new List<Consentimientos__c>();
        Consentimientos__c consentimientoEmail = CreaObjetos.creaConsentimiento(email, contacto.Id, Label.channelEmail);
        Consentimientos__c consentimientoPhone = CreaObjetos.creaConsentimiento(phone, contacto.Id, Label.channelPhone);
        Consentimientos__c consentimientoMobile = CreaObjetos.creaConsentimiento(mobile, contacto.Id, Label.channelMobile);
        listConsentimientos.add(consentimientoEmail);
        listConsentimientos.add(consentimientoMobile);
        insert listConsentimientos;
        
        Case caso = new Case();
        caso.AccountId = cuenta.Id;
        caso.Centro__c = center.Id;
        caso.Marca__c = 'DUCATI';
        caso.Intencion_de_compra__c = 'Oferta';
        caso.Origin = 'Email';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = phone;
        caso.SuppliedEmail = email;
        
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        caso.SalesmanEmail__c = 'vendedor1@prueba.com';
        insert caso;
        Test.startTest();
        ExternalServiceController.sendExternalEmailATTCliente(JSON.serialize(new List<Case>{caso}));
        Test.stopTest();
    }

    @isTest
    static void ExternalServiceternalEmailXtravansDiarioTest() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMockFailure());
        Centro__c center = [SELECT Id, Name,Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c,Marcas_VO__c,Telefono__c,Venta_de_VN__c,Venta_de_VO__c,CentroCdg__c,Concesionario__r.Id_Concesionario_Sima__c 
                            FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String email = 'prueba@prueba.com';
        String phone = '918887766';
        String mobile ='+34699999123';
        Account cuenta = CreaObjetos.creaCuentaPersonal('Prueba', 'Test Tset');
        Gestion_Lead__c gLead = [Select Id, Asesor__c,Centro__c, Gestor_Lead__c, Intencion_de_compra__c, Marca__c  from Gestion_Lead__c limit 1];
        cuenta.PersonEmail = email;
        cuenta.Phone = phone;
        cuenta.PersonMobilePhone = mobile;
        cuenta.BillingCountry ='España';
        cuenta.ShippingCountry='España';
        cuenta.Tipo_de_documento_cuenta_personal__c = 'VATId';
        cuenta.Documento__c = 'TST001';
        insert cuenta;
        Contact contacto = [SELECT Id, Name FROM Contact where accountId = :cuenta.Id LIMIT 1];
        List<Consentimientos__c> listConsentimientos = new List<Consentimientos__c>();
        Consentimientos__c consentimientoEmail = CreaObjetos.creaConsentimiento(email, contacto.Id, Label.channelEmail);
        Consentimientos__c consentimientoPhone = CreaObjetos.creaConsentimiento(phone, contacto.Id, Label.channelPhone);
        Consentimientos__c consentimientoMobile = CreaObjetos.creaConsentimiento(mobile, contacto.Id, Label.channelMobile);
        listConsentimientos.add(consentimientoEmail);
        listConsentimientos.add(consentimientoMobile);
        insert listConsentimientos;
        
        Case caso = new Case();
        caso.AccountId = cuenta.Id;
        caso.Centro__c = center.Id;
        caso.Marca__c = 'DUCATI';
        caso.Intencion_de_compra__c = 'Oferta';
        caso.Origin = 'Email';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = phone;
        caso.SuppliedEmail = email;
        
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        caso.SalesmanEmail__c = 'vendedor1@prueba.com';
        insert caso;
        Test.startTest();
        ExternalServiceController.sendExternalEmailXtravansDiario(JSON.serialize(new List<Case>{caso}));
        Test.stopTest();
    }
    
}