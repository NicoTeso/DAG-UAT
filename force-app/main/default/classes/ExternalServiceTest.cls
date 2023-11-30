@isTest
public class ExternalServiceTest {

    @testSetup
    static void setup() {
        TriggersTest.activaTriggers();
        ApiConnect.activaApiConnect();
		CreaObjetos.creaPais();
        Concesionario__c concesionario = CreaObjetos.creaConcesionario('001');
        Concesionario.Es_SIMA__c = true;
        insert concesionario;
        Centro__c centro = CreaObjetos.creaCentro(concesionario.Id);
        Gestion_Lead__c gLead = CreaObjetos.creaGestionLead(centro.Id);
        gLead.Origen__c ='Web';
        insert gLead;
        Gestion_Lead__c gLead1 = CreaObjetos.creaGestionLead(centro.Id);
        gLead1.Origen__c ='e-commerce';
        gLead1.Intencion_de_compra__c ='Cita';
        gLead1.RecordTypeId = Schema.SObjectType.Gestion_Lead__c.getRecordTypeInfosByDeveloperName().get('Gestion_Lead_VO').getRecordTypeId();
        insert gLead1;
        CreaObjetos.creaCampaign();
        
    }
	
    @isTest static void ExternalServiceAccountTest() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMock());
        Centro__c center = [SELECT Id, Name,Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c,Marcas_VO__c,Telefono__c,Venta_de_VN__c,Venta_de_VO__c,CentroCdg__c,Concesionario__r.Id_Concesionario_Sima__c, Concesionario__r.Es_SIMA__c 
                            FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String email = 'prueba@prueba.com';
        String telefono ='+34699999999';
        Account cuenta = CreaObjetos.creaCuentaPersonal('Prueba', 'Test');
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
        caso.Origin ='Web';
        caso.Intencion_de_compra__c = 'Prueba';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = telefono;
        caso.SuppliedEmail = email;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        insert caso;
        Test.startTest();
        ExternalService.createAndSendJSON(caso.Id);
        Test.stopTest();
        }
    
    @isTest static void ExternalServiceAccount2Test() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMock());
        Centro__c center = [SELECT Id, Name,Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c,Marcas_VO__c,Telefono__c,Venta_de_VN__c,Venta_de_VO__c,CentroCdg__c,Concesionario__r.Id_Concesionario_Sima__c, Concesionario__r.Es_SIMA__c
                            FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String email = 'prueba@prueba.com';
        String telefono ='+34699999999';
        Account cuenta = CreaObjetos.creaCuentaPersonal('Prueba', 'Test');
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
        caso.Origin ='Web';
        caso.Intencion_de_compra__c = 'Prueba';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = telefono;
        caso.SuppliedEmail = email;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        insert caso;
        Test.startTest();
        ExternalService.createAndSendJSON(caso.Id);
        Test.stopTest();
        }
    
    @isTest static void ExternalServiceLeadTest() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMock());
        Centro__c center = [SELECT Id, Name,Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c,Marcas_VO__c,Telefono__c,Venta_de_VN__c,Venta_de_VO__c,CentroCdg__c,Concesionario__r.Id_Concesionario_Sima__c, Concesionario__r.Es_SIMA__c
                            FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String email = 'prueba@prueba.com';
        String telefono ='+34699999999';
        Lead candidato = CreaObjetos.creaLead('Prueba', 'Test');
        candidato.Email = email;
        candidato.Phone = telefono;
        insert candidato;
        
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
        caso.Origin ='Web';
        caso.Intencion_de_compra__c = 'Prueba';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = telefono;
        caso.SuppliedEmail = email;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        insert caso;
        Test.startTest();
        ExternalService.createAndSendJSON(caso.Id);
        Test.stopTest();
        }
    
    @isTest static void ExternalServiceLeadDuplicadoTest() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMock());
        Centro__c center = [SELECT Id, Name,Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c,Marcas_VO__c,Telefono__c,Venta_de_VN__c,Venta_de_VO__c,CentroCdg__c,Concesionario__r.Id_Concesionario_Sima__c, Concesionario__r.Es_SIMA__c
                            FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String email = 'prueba@prueba.com';
        String telefono ='+34699999999';
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
        caso.Origin ='Web';
        caso.Intencion_de_compra__c = 'Prueba';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = telefono;
        caso.SuppliedEmail = email;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        insert caso;
        Test.startTest();
        ExternalService.createAndSendJSON(caso.Id);
        Test.stopTest();
        }
    
    @isTest static void ExternalServiceAccountEmpresaTest() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMock());
        Centro__c center = [SELECT Id, Name,Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c,Marcas_VO__c,Telefono__c,Venta_de_VN__c,Venta_de_VO__c,CentroCdg__c,Concesionario__r.Id_Concesionario_Sima__c, Concesionario__r.Es_SIMA__c
                            FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String email = 'prueba@prueba.com';
        String telefono ='+34699999999';
        Account cuenta = CreaObjetos.creaCuentaEmpresa('Prueba');
        cuenta.Email__c = email;
        cuenta.Mobile__c = telefono;
        cuenta.BillingCountry ='España';
        cuenta.ShippingCountry='España';
        insert cuenta;
        
        Case caso = new Case();
        caso.AccountId = cuenta.Id;
        caso.Centro__c = center.Id;
        caso.Marca__c = 'AUDI';
        caso.Origin ='Web';
        caso.Intencion_de_compra__c = 'Prueba';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = telefono;
        caso.SuppliedEmail = email;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        insert caso;
        Test.startTest();
        ExternalService.createAndSendJSON(caso.Id);
        Test.stopTest();
        }
    
	@isTest static void ExternalServiceNotSIMATest() {
        Concesionario__c conces = [SELECT Id, Es_SIMA__c FROM Concesionario__c LIMIT 1];
        conces.Es_SIMA__c = false;
        update conces;
        
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMock());
        Centro__c center = [SELECT Id, Name,Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c,Marcas_VO__c,Telefono__c,Venta_de_VN__c,Venta_de_VO__c,CentroCdg__c,Concesionario__r.Id_Concesionario_Sima__c, Concesionario__r.Es_SIMA__c
                            FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String email = 'prueba@prueba.com';
        String telefono ='+34699999999';
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
        caso.Origin ='Web';
        caso.Intencion_de_compra__c = 'Prueba';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = telefono;
        caso.SuppliedEmail = email;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        insert caso;
        Test.startTest();
        ExternalService.createAndSendJSON(caso.Id);
        Test.stopTest();
	}
    
    @isTest
    static void ExternalServiceNoGestionLeadTest() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMock());
        Centro__c center = [SELECT Id, Name,Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c,Marcas_VO__c,Telefono__c,Venta_de_VN__c,Venta_de_VO__c,CentroCdg__c,Concesionario__r.Id_Concesionario_Sima__c, Concesionario__r.Es_SIMA__c
                            FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String email = 'prueba@prueba.com';
        String telefono ='+34699999999';
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
        caso.AccountId = null;
        caso.Lead__c = null;
        caso.Centro__c = center.Id;
        caso.Marca__c = 'AUDI';
        caso.Origin ='Web';
        caso.Intencion_de_compra__c = 'Prueba';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = telefono;
        caso.SuppliedEmail = email;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        insert caso;
        
        Test.startTest();
        ExternalService.createAndSendJSON(caso.Id);
        
        caso.AccountId = cuenta.Id;
        caso.Status = 'New';
        gLead = null;
        update caso;
        
        ExternalService.createAndSendJSON(caso.Id);
        Test.stopTest();
	}
    
    @isTest static void ExternalServiceAccountTestVO() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMock());
        Centro__c center = [SELECT Id, Name,Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c,Marcas_VO__c,Telefono__c,Venta_de_VN__c,Venta_de_VO__c,CentroCdg__c,Concesionario__r.Id_Concesionario_Sima__c, Concesionario__r.Es_SIMA__c 
                            FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String email = 'prueba@prueba.com';
        String telefono ='+34699999999';
        Account cuenta = CreaObjetos.creaCuentaPersonal('Prueba', 'Test');
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
        caso.Origin ='e-commerce';
        caso.Intencion_de_compra__c = 'Cita';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = telefono;
        caso.SuppliedEmail = email;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead_VO').getRecordTypeId();
        insert caso;
        Test.startTest();
        ExternalService.createAndSendJSON(caso.Id);
        Test.stopTest();
    }
    
    @isTest static void ExternalServiceAccountTestVONoGLead() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMock());
        Centro__c center = [SELECT Id, Name,Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c,Marcas_VO__c,Telefono__c,Venta_de_VN__c,Venta_de_VO__c,CentroCdg__c,Concesionario__r.Id_Concesionario_Sima__c, Concesionario__r.Es_SIMA__c 
                            FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String email = 'prueba@prueba.com';
        String telefono ='+34699999999';
        Account cuenta = CreaObjetos.creaCuentaPersonal('Prueba', 'Test');
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
        caso.Origin ='e-commerce';
        caso.Intencion_de_compra__c = 'Reserva';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = telefono;
        caso.SuppliedEmail = email;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead_VO').getRecordTypeId();
        insert caso;
        Test.startTest();
        ExternalService.createAndSendJSON(caso.Id);
        Test.stopTest();
    }
    
    @isTest static void ExternalServiceAccountTestNoGLead() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMock());
        Centro__c center = [SELECT Id, Name,Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c,Marcas_VO__c,Telefono__c,Venta_de_VN__c,Venta_de_VO__c,CentroCdg__c,Concesionario__r.Id_Concesionario_Sima__c, Concesionario__r.Es_SIMA__c 
                            FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String email = 'prueba@prueba.com';
        String telefono ='+34699999999';
        Account cuenta = CreaObjetos.creaCuentaPersonal('Prueba', 'Test');
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
        caso.Origin ='e-commerce';
        caso.Intencion_de_compra__c = 'Prueba';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = telefono;
        caso.SuppliedEmail = email;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        insert caso;
        Test.startTest();
        ExternalService.createAndSendJSON(caso.Id);
        Test.stopTest();
    }

    @isTest static void ExternalServiceAccountTestClosed() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMock());
        Centro__c center = [SELECT Id, Name,Concesionario__c, Domicilio__c, Id_Centro_Sima__c, Imagen_centro__c, Isla__c,
							Marcas_VN__c,Marcas_VO__c,Telefono__c,Venta_de_VN__c,Venta_de_VO__c,CentroCdg__c,Concesionario__r.Id_Concesionario_Sima__c, Concesionario__r.Es_SIMA__c 
                            FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id, Name FROM Campaign LIMIT 1];
        String email = 'prueba@prueba.com';
        String telefono ='+34699999999';
        Account cuenta = CreaObjetos.creaCuentaPersonal('Prueba', 'Test');
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
        caso.Origin ='e-commerce';
        caso.Intencion_de_compra__c = 'Prueba';
        caso.Campana__c = camp.Id;
        caso.SuppliedPhone = telefono;
        caso.SuppliedEmail = email;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        caso.Status = 'Closed';
        caso.Motivo_de_cierre__c = 'Se abre oportunidad';
        insert caso;
        Test.startTest();
        ExternalService.createAndSendJSON(caso.Id);
        Test.stopTest();
    }
    
}