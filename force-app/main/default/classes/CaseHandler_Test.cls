@isTest
public class CaseHandler_Test {
    @testSetup
    static void setup() {
        TriggersTest.activaTriggers();
        CreaObjetos.creaPais();
        
        Account acc = CreaObjetos.creaCuentaPersonal('CaseTest', 'Personal');
        acc.PersonEmail = 'pruebaotheremail@test.com';
        acc.OtherEmail__pc = 'pruebaemail@test.com';
        acc.Phone ='999999999';
        acc.PersonMobilePhone = '699999999';
        insert acc;

       
        Concesionario__c conces = CreaObjetos.creaConcesionario('A000001');
        conces.Domicilio__c = 'Test domicilio';
        conces.CIF__c = '123123123';
        insert conces;
        Concesionario__c conces02 = CreaObjetos.creaConcesionario('A0002NO');
        conces02.Es_SIMA__c= false;
        conces02.Domicilio__c ='prueba';
        insert conces02;
        
        Centro__c center = new Centro__c();
        center.Name = 'Centro01';
        center.Concesionario__c = conces.Id;
        center.Gestiona_LEAD__c = true;
        insert center;

        Centro__c center02 = new Centro__c();
        center02.Name = 'Centro02';
        center02.Concesionario__c = conces02.Id;
        center02.Gestiona_LEAD__c = true;
        insert center02;

        Centro__c center03 = new Centro__c();
        center03.Name = 'Centro03';
        center03.Concesionario__c = conces.Id;
        center03.Gestiona_LEAD__c = true;
        center03.Id_Centro_RMS__c = 'cenrms';
        center03.Id_Centro_Sima__c = null;
        insert center03;
        
        Gestion_Lead__c gLead = new Gestion_Lead__c();
        gLead.Centro__c = center.Id;
        gLead.Marca__c = 'AUDI';
        gLead.Intencion_de_compra__c = 'Prueba';
        gLead.Gestor_Lead__c = 'CC';
        gLead.Origen__c = 'Landing';
        gLead.RecordTypeId = Schema.SObjectType.Gestion_Lead__c.getRecordTypeInfosByDeveloperName().get('Gestion_Lead_VN').getRecordTypeId();
        
        insert gLead;
        
        Gestion_Lead__c gLead02 = new Gestion_Lead__c();
        gLead02.Centro__c = center02.Id;
        gLead02.Marca__c = 'AUDI';
        gLead02.Intencion_de_compra__c = 'Prueba';
        gLead02.Gestor_Lead__c = 'CC';
        gLead02.Origen__c = 'Landing';
        gLead02.RecordTypeId = Schema.SObjectType.Gestion_Lead__c.getRecordTypeInfosByDeveloperName().get('Gestion_Lead_VN').getRecordTypeId();
        insert gLead02;

        Gestion_Lead__c gLead03 = new Gestion_Lead__c();
        gLead03.Centro__c = center.Id;
        gLead03.Intencion_de_compra__c = 'Financiar';
        gLead03.Gestor_Lead__c = 'CC';
        gLead03.Origen__c = 'e-commerce';
        gLead03.RecordTypeId = Schema.SObjectType.Gestion_Lead__c.getRecordTypeInfosByDeveloperName().get('Gestion_Lead_VO').getRecordTypeId();
        insert gLead03;
        
        Campaign camp = new Campaign();
        camp.Name = 'CampaginTest';
        insert camp;
        
        Lead le = new Lead();
        le.LastName = 'CaseLead';
        insert le;

        Tarifa_Renting__c tRenting = new Tarifa_Renting__c();
        tRenting.Tipo_Renting__c = 'Fijo';
        tRenting.Tipo_de_vehiculo__c = '13';
        tRenting.Duracion__c = '14';
        tRenting.Importe_Cuota__c = 100;
        tRenting.Valor_del_vehiculo__c = 100;
        tRenting.Fecha_inicio_vigencia__c = Date.today().addDays(-10);
        tRenting.RecordTypeId = Schema.SObjectType.Tarifa_Renting__c.getRecordTypeInfosByDeveloperName().get('Tarifa_xtravans').getRecordTypeId();
        insert tRenting;

        Tarifa_Renting__c tRenting1 = new Tarifa_Renting__c();
        tRenting1.Tipo_Renting__c = 'Fijo';
        tRenting1.Tipo_de_vehiculo__c = '13';
        tRenting1.Duracion__c = '15';
        tRenting1.Importe_Cuota__c = 100;
        tRenting1.Valor_del_vehiculo__c = 100;
        tRenting1.Fecha_inicio_vigencia__c = Date.today().addDays(-10);
        tRenting1.RecordTypeId = Schema.SObjectType.Tarifa_Renting__c.getRecordTypeInfosByDeveloperName().get('Tarifa_xtravans').getRecordTypeId();
        insert tRenting1;

        Tarifa_Renting__c tRenting2 = new Tarifa_Renting__c();
        tRenting2.Tipo_Renting__c = 'Fijo';
        tRenting2.Tipo_de_vehiculo__c = '13';
        tRenting2.Duracion__c = '16';
        tRenting2.Importe_Cuota__c = 100;
        tRenting2.Valor_del_vehiculo__c = 100;
        tRenting2.Fecha_inicio_vigencia__c = Date.today().addDays(-10);
        tRenting2.RecordTypeId = Schema.SObjectType.Tarifa_Renting__c.getRecordTypeInfosByDeveloperName().get('Tarifa_xtravans').getRecordTypeId();
        insert tRenting2;

        Tarifa_Renting__c tRenting3 = new Tarifa_Renting__c();
        tRenting3.Tipo_Renting__c = 'Fijo';
        tRenting3.Tipo_de_vehiculo__c = '13';
        tRenting3.Duracion__c = '17';
        tRenting3.Importe_Cuota__c = 100;
        tRenting3.Valor_del_vehiculo__c = 100;
        tRenting3.Fecha_inicio_vigencia__c = Date.today().addDays(-10);
        tRenting3.RecordTypeId = Schema.SObjectType.Tarifa_Renting__c.getRecordTypeInfosByDeveloperName().get('Tarifa_xtravans').getRecordTypeId();
        insert tRenting3;

        Tarifa_Renting__c tRenting4 = new Tarifa_Renting__c();
        tRenting4.Tipo_Renting__c = 'Fijo';
        tRenting4.Tipo_de_vehiculo__c = '13';
        tRenting4.Duracion__c = '18';
        tRenting4.Importe_Cuota__c = 100;
        tRenting4.Valor_del_vehiculo__c = 100;
        tRenting4.Fecha_inicio_vigencia__c = Date.today().addDays(-10);
        tRenting4.RecordTypeId = Schema.SObjectType.Tarifa_Renting__c.getRecordTypeInfosByDeveloperName().get('Tarifa_xtravans').getRecordTypeId();
        insert tRenting4;

        Tarifa_Renting__c tRenting5 = new Tarifa_Renting__c();
        tRenting5.Tipo_Renting__c = 'Flexible';
        tRenting5.Tipo_de_vehiculo__c = '23';
        tRenting5.Duracion__c = '19';
        tRenting5.Importe_Cuota__c = 100;
        tRenting5.Valor_del_vehiculo__c = 100;
        tRenting5.Fecha_inicio_vigencia__c = Date.today().addDays(-10);
        tRenting5.RecordTypeId = Schema.SObjectType.Tarifa_Renting__c.getRecordTypeInfosByDeveloperName().get('Tarifa_xtravans').getRecordTypeId();
        insert tRenting5;

        Tarifa_Renting__c tRenting6 = new Tarifa_Renting__c();
        tRenting6.Tipo_Renting__c = 'Flexible';
        tRenting6.Tipo_de_vehiculo__c = '23';
        tRenting6.Duracion__c = '20';
        tRenting6.Importe_Cuota__c = 100;
        tRenting6.Valor_del_vehiculo__c = 100;
        tRenting6.Fecha_inicio_vigencia__c = Date.today().addDays(-10);
        tRenting6.RecordTypeId = Schema.SObjectType.Tarifa_Renting__c.getRecordTypeInfosByDeveloperName().get('Tarifa_xtravans').getRecordTypeId();
        insert tRenting6;

        Tarifa_Renting__c tRenting7 = new Tarifa_Renting__c();
        tRenting7.Tipo_Renting__c = 'Flexible';
        tRenting7.Tipo_de_vehiculo__c = '23';
        tRenting7.Duracion__c = '21';
        tRenting7.Importe_Cuota__c = 100;
        tRenting7.Valor_del_vehiculo__c = 100;
        tRenting7.Fecha_inicio_vigencia__c = Date.today().addDays(-10);
        tRenting7.RecordTypeId = Schema.SObjectType.Tarifa_Renting__c.getRecordTypeInfosByDeveloperName().get('Tarifa_xtravans').getRecordTypeId();
        insert tRenting7;

        Tarifa_Renting__c tRenting8 = new Tarifa_Renting__c();
        tRenting8.TarifaID__c = '1';
        tRenting8.Marca__c = 'AUDI';
        tRenting8.Modelo__c = 'A1';
        tRenting8.modelDescription__c = 'des1';
        tRenting8.Valor_del_vehiculo__c = 100;
        tRenting8.Fecha_inicio_vigencia__c = Date.today().addDays(-10);
        tRenting8.RecordTypeId = Schema.SObjectType.Tarifa_Renting__c.getRecordTypeInfosByDeveloperName().get('Tarifa_myCARFLIX').getRecordTypeId();
        insert tRenting8;

        Tarifa_Renting__c tRenting9 = new Tarifa_Renting__c();
        tRenting9.TarifaID__c = '2';
        tRenting9.Marca__c = 'AUDI';
        tRenting9.Modelo__c = 'A4';
        tRenting9.modelDescription__c = 'des1';
        tRenting9.Valor_del_vehiculo__c = 100;
        tRenting9.Fecha_inicio_vigencia__c = Date.today().addDays(-10);
        tRenting9.RecordTypeId = Schema.SObjectType.Tarifa_Renting__c.getRecordTypeInfosByDeveloperName().get('Tarifa_myCARFLIX').getRecordTypeId();
        insert tRenting9;

    }        

    @isTest
    static void ChatCochesTest() {
        
        Case ca = new Case();
        ca.Marca__c = 'HONDA';
        ca.Origin ='Chat Offline';
        ca.CustomerProblemBrand__c = 'Información de modelos';
        ca.ProblemDescription__c = 'prueba chat off line';
        ca.CustomerEmail__c = 'case@test.com';
        ca.CustomerName__c = 'Maria';
        ca.CustomerPhone__c = '918887765';            
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.RTCaseChatHondaCochesCanarias).getRecordTypeId();
        
 		System.debug('Queries 01: ' + Limits.getQueries());
        Test.startTest();
        insert ca;        
 		System.debug('Queries 02: ' + Limits.getQueries());
        Test.stopTest();
 		System.debug('Queries 03: ' + Limits.getQueries());
        
    }

    @isTest
    static void ChatMotosTest() {
        
        Case ca = new Case();
        ca.Marca__c = 'HONDA MOTOS';
        ca.Origin ='Chat Offline';
        ca.CustomerProblemMoto__c = 'Información de modelos';
        ca.ProblemDescription__c = 'prueba chat off line';
        ca.CustomerEmail__c = 'case@test.com';
        ca.CustomerName__c = 'Maria';
        ca.CustomerPhone__c = '918887765';            
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.RTCaseChatHondaMotosCanarias).getRecordTypeId();
        
 		System.debug('Queries 01: ' + Limits.getQueries());
        Test.startTest();
        insert ca;        
 		System.debug('Queries 02: ' + Limits.getQueries());
        Test.stopTest();
 		System.debug('Queries 03: ' + Limits.getQueries());
        
    }

    @isTest
    static void ChatVOTest() {
        
        Case ca = new Case();
        ca.Origin ='Chat Offline';
        ca.CustomerProblemVO__c = 'Financiar';
        ca.ProblemDescription__c = 'prueba chat off line';
        ca.CustomerEmail__c = 'case@test.com';
        ca.CustomerName__c = 'Maria';
        ca.CustomerPhone__c = '918887765';            
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.RTCaseChatTuCarMarket).getRecordTypeId();
        
 		System.debug('Queries 01: ' + Limits.getQueries());
        Test.startTest();
        insert ca;        
 		System.debug('Queries 02: ' + Limits.getQueries());
        Test.stopTest();
 		System.debug('Queries 03: ' + Limits.getQueries());
        
    }

    @isTest
    static void ChatDomingoAlonsoTest() {
        
        Case ca = new Case();
        ca.Marca__c = 'HONDA MOTOS';
        ca.Origin ='Chat Offline';
        ca.CustomerProblemDAG__c = 'Venta';
        ca.ProblemDescription__c = 'prueba chat off line';
        ca.CustomerEmail__c = 'case@test.com';
        ca.CustomerName__c = 'Maria';
        ca.CustomerPhone__c = '918887765';            
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.RTCaseChatDomingoAlonsoGroup).getRecordTypeId();
        
 		System.debug('Queries 01: ' + Limits.getQueries());
        Test.startTest();
        insert ca;        
 		System.debug('Queries 02: ' + Limits.getQueries());
        Test.stopTest();
 		System.debug('Queries 03: ' + Limits.getQueries());
        
    }

    @isTest
    static void EmailOPPTest() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account LIMIT 1];
        Centro__c center = [SELECT Id FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];
        Lead le = [SELECT Id FROM Lead LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        
        
        Case ca = new Case();
        //ca.AccountId = acc.Id;
        ca.Centro__c = center.Id;
        ca.Origin ='Email';
        ca.Intencion_de_compra__c = 'Prueba';
        ca.Campana__c = camp.Id;
        ca.Lead__c = le.Id;
        ca.SuppliedPhone = '918887765';
        ca.SuppliedEmail = 'case@test.com';
        ca.EnvioMulesoft__c = 'OK';
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.RtCaseGestionEmail).getRecordTypeId();
        
 		System.debug('Queries 00: ' + Limits.getQueries());
        Test.startTest();
 		System.debug('Queries 01: ' + Limits.getQueries());
        insert ca;        
 		System.debug('Queries 02: ' + Limits.getQueries());
        Test.stopTest();
 		System.debug('Queries 03: ' + Limits.getQueries());
    }

    @isTest
    static void EmailATTOPPTest() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account LIMIT 1];
        Centro__c center = [SELECT Id, Concesionario__c FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];
        Lead le = [SELECT Id FROM Lead LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        
        Case ca = new Case();
        //ca.AccountId = acc.Id;
        ca.Centro__c = center.Id;
        ca.Origin ='Email';
        ca.Intencion_de_compra__c = 'Prueba';
        ca.Campana__c = camp.Id;
        ca.Lead__c = le.Id;
        ca.SuppliedPhone = '918887765';
        ca.SuppliedEmail = 'case@test.com';
        ca.EnvioMulesoft__c = 'OK';
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.RtCaseGestionAtencionCliente).getRecordTypeId();
        
 		System.debug('Queries 00: ' + Limits.getQueries());
        Test.startTest();
 		System.debug('Queries 01: ' + Limits.getQueries());
        insert ca;        
 		System.debug('Queries 02: ' + Limits.getQueries());
        Test.stopTest();
 		System.debug('Queries 03: ' + Limits.getQueries());
    }

    @isTest
    static void EmailATTOPPTest1() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account LIMIT 1];
        Centro__c center = [SELECT Id, Concesionario__c FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];
        Lead le = [SELECT Id FROM Lead LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id LIMIT 1];

        Salesman__c salesman = new Salesman__c();
        salesman.Email__c = 'foo@bar.com';
        insert salesman;
        
        Opportunity opp = CreaObjetos.creaOportunidad(acc.Id, center.Concesionario__c, center.Id, 'tesrop1' );
        opp.Vendedor__c = salesman.Id;
        opp.Name = 'test/opp';
        insert opp;        
        
        Vehiculo__c vehicle = CreaObjetos.creaVehiculo('VIN01', acc.Id, 'HYUNDAI', 'E9887YYJ');
        insert vehicle; 
        
        Detalle_venta__c detV = CreaObjetos.creaDetalleVenta(center.Concesionario__c, center.Id, vehicle.Id);
        detV.Opportunity__c = opp.Id;
        detV.Vendedor__c = salesman.Id;
        detV.Comprador__c = acc.Id;
        detV.Propietario__c = acc.Id;
        
        insert detV;        
        
        Case ca = new Case();
        //ca.AccountId = acc.Id;
        ca.Centro__c = center.Id;
        ca.Origin ='Email';
        ca.Intencion_de_compra__c = 'Prueba';
        ca.Campana__c = camp.Id;
        ca.Lead__c = le.Id;
        ca.SuppliedPhone = '918887765';
        ca.SuppliedEmail = 'case@test.com';
        ca.EnvioMulesoft__c = 'OK';
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.RtCaseGestionAtencionCliente).getRecordTypeId();
        insert ca;        
        ca.Sale__c = detV.Id;
        
 		System.debug('Queries 00: ' + Limits.getQueries());
        Test.startTest();
 		System.debug('Queries 01: ' + Limits.getQueries());
        update ca;        
 		System.debug('Queries 02: ' + Limits.getQueries());
        Test.stopTest();
 		System.debug('Queries 03: ' + Limits.getQueries());
    }

    @isTest
    static void EmailATTOPPTest2() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account LIMIT 1];
        Centro__c center = [SELECT Id, Concesionario__c FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];
        Lead le = [SELECT Id FROM Lead LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id LIMIT 1];

        Salesman__c salesman = new Salesman__c();
        salesman.Email__c = 'foo@bar.com';
        insert salesman;
        
        Vehiculo__c vehicle = CreaObjetos.creaVehiculo('VIN01', acc.Id, 'HYUNDAI', 'E9887YYJ');
        insert vehicle; 
        
        Pase_de_taller__c pasTaller = CreaObjetos.creaPaseTaller(vehicle.Id, acc.Id, center.Concesionario__c, center.Id);
        insert pasTaller;        
        
        Case ca = new Case();
        //ca.AccountId = acc.Id;
        ca.Centro__c = center.Id;
        ca.Origin ='Email';
        ca.Intencion_de_compra__c = 'Prueba';
        ca.Campana__c = camp.Id;
        ca.Lead__c = le.Id;
        ca.SuppliedPhone = '918887765';
        ca.SuppliedEmail = 'case@test.com';
        ca.EnvioMulesoft__c = 'OK';
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.RtCaseGestionAtencionCliente).getRecordTypeId();
        insert ca;        
        ca.AfterSale__c = pasTaller.Id;
        
 		System.debug('Queries 00: ' + Limits.getQueries());
        Test.startTest();
 		System.debug('Queries 01: ' + Limits.getQueries());
        update ca;        
 		System.debug('Queries 02: ' + Limits.getQueries());
        Test.stopTest();
 		System.debug('Queries 03: ' + Limits.getQueries());
    }
    
    @isTest
    static void EmailMOBTest() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account LIMIT 1];
        Centro__c center = [SELECT Id FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];
        Lead le = [SELECT Id FROM Lead LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        
        
        Case ca = new Case();
        //ca.AccountId = acc.Id;
        ca.Centro__c = center.Id;
        ca.Origin ='Email';
        ca.Intencion_de_compra__c = 'Prueba';
        ca.Campana__c = camp.Id;
        ca.Lead__c = le.Id;
        ca.SuppliedPhone = '918887765';
        ca.SuppliedEmail = 'case@test.com';
        ca.EnvioMulesoft__c = 'OK';
        ca.Unidad_de_negocio__c = 'MOB';
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.RtCaseGestionEmailMobility).getRecordTypeId();
        
 		System.debug('Queries 00: ' + Limits.getQueries());
        Test.startTest();
 		System.debug('Queries 01: ' + Limits.getQueries());
        insert ca;        
 		System.debug('Queries 02: ' + Limits.getQueries());
        Test.stopTest();
 		System.debug('Queries 03: ' + Limits.getQueries());
    }
    
    @isTest
    static void ConsentLeadIdInMapTest() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account LIMIT 1];
        Centro__c center = [SELECT Id FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];
        Lead le = [SELECT Id FROM Lead LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        
        
        Case ca = new Case();
        //ca.AccountId = acc.Id;
        ca.Centro__c = center.Id;
        ca.Marca__c = 'HONDA';
        ca.Origin ='Web';
        ca.Intencion_de_compra__c = 'Prueba';
        ca.Campana__c = camp.Id;
        ca.Lead__c = le.Id;
        ca.SuppliedPhone = '918887765';
        ca.SuppliedEmail = 'case@test.com';
        ca.EnvioMulesoft__c = 'OK';
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        
        List<Consentimientos__c> lstConsents = new List<Consentimientos__c>();
        Consentimientos__c consentPersonEmail = CreaObjetos.creaConsentimiento(acc.PersonEmail, con.Id, Label.channelEmail);
        consentPersonEmail.Lead__c = le.Id;
        lstConsents.add(consentPersonEmail);
        Consentimientos__c consentPersonOtherEmail = CreaObjetos.creaConsentimientoOther(acc.OtherEmail__pc, con.Id, Label.channelEmail,false);
        consentPersonOtherEmail.Lead__c = le.Id;
        lstConsents.add(consentPersonOtherEmail);

        System.debug('Queries 00: ' + Limits.getQueries());
        insert lstConsents;
 		System.debug('Queries 01: ' + Limits.getQueries());
        insert ca;        
 		System.debug('Queries 02: ' + Limits.getQueries());
        
        Test.startTest();
 		System.debug('Queries 03: ' + Limits.getQueries());
        ca.SuppliedPhone = '918887766';
        ca.Numero_de_llamadas__c = '1';
        ca.Contactado__c = true;
        ca.Fecha_Hora_de_cita__c = datetime.now().adddays(3);
 		System.debug('Queries 04: ' + Limits.getQueries());
        update ca;
 		System.debug('Queries 05: ' + Limits.getQueries());
        Test.stopTest();
 		System.debug('Queries 06: ' + Limits.getQueries());
    }
    
    @isTest
    static void ConsentLeadIdInMapTest2() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account LIMIT 1];
        Centro__c center = [SELECT Id FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];
        Lead le = [SELECT Id FROM Lead LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        
        
        Case ca = new Case();
        //ca.AccountId = acc.Id;
        ca.Centro__c = center.Id;
        ca.Marca__c = 'HONDA MOTOS';
        ca.Origin ='Web';
        ca.Intencion_de_compra__c = 'Prueba';
        ca.Campana__c = camp.Id;
        ca.Lead__c = le.Id;
        ca.SuppliedPhone = '918887765';
        ca.SuppliedEmail = 'case@test.com';
        ca.EnvioMulesoft__c = 'OK';
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        
        List<Consentimientos__c> lstConsents = new List<Consentimientos__c>();
        Consentimientos__c consentPersonEmail = CreaObjetos.creaConsentimiento(acc.PersonEmail, con.Id, Label.channelEmail);
        consentPersonEmail.Lead__c = le.Id;
        lstConsents.add(consentPersonEmail);
        Consentimientos__c consentPersonOtherEmail = CreaObjetos.creaConsentimientoOther(acc.OtherEmail__pc, con.Id, Label.channelEmail,false);
        consentPersonOtherEmail.Lead__c = le.Id;
        lstConsents.add(consentPersonOtherEmail);
        
        insert lstConsents;
        insert ca;        

        ca.Numero_de_llamadas__c = '1';
        update ca;
        
        Test.startTest();
        ca.SuppliedPhone = '918887766';
        ca.Numero_de_llamadas__c = '2';
        ca.Contactado__c = true;
        update ca;
        Test.stopTest();
    }
    
    @isTest
    static void ConsentLeadIdInMapTest3() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account LIMIT 1];
        Centro__c center = [SELECT Id FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];
        Lead le = [SELECT Id FROM Lead LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        
        
        Case ca = new Case();
        //ca.AccountId = acc.Id;
        ca.Centro__c = center.Id;
        ca.Marca__c = 'AUDI';
        ca.Origin ='Web';
        ca.Intencion_de_compra__c = 'Prueba';
        ca.Campana__c = camp.Id;
        ca.Lead__c = le.Id;
        ca.SuppliedPhone = '918887765';
        ca.SuppliedEmail = 'case@test.com';
        ca.EnvioMulesoft__c = 'OK';
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        
        List<Consentimientos__c> lstConsents = new List<Consentimientos__c>();
        Consentimientos__c consentPersonEmail = CreaObjetos.creaConsentimiento(acc.PersonEmail, con.Id, Label.channelEmail);
        consentPersonEmail.Lead__c = le.Id;
        lstConsents.add(consentPersonEmail);
        Consentimientos__c consentPersonOtherEmail = CreaObjetos.creaConsentimientoOther(acc.OtherEmail__pc, con.Id, Label.channelEmail,false);
        consentPersonOtherEmail.Lead__c = le.Id;
        lstConsents.add(consentPersonOtherEmail);
        
 		System.debug('Queries 00: ' + Limits.getQueries());
 		System.debug('Queries 01: ' + Limits.getQueries());
        insert lstConsents;
 		System.debug('Queries 02: ' + Limits.getQueries());
        insert ca;        
 		System.debug('Queries 03: ' + Limits.getQueries());
        ca.Numero_de_llamadas__c = '1';
        update ca;
 		System.debug('Queries 04: ' + Limits.getQueries());
        ca.Numero_de_llamadas__c = '2';
        update ca;
        Test.startTest();
 		System.debug('Queries 05: ' + Limits.getQueries());
        ca.SuppliedPhone = '918887766';
        ca.Numero_de_llamadas__c = '3';
        ca.Contactado__c = true;
        update ca;
 		System.debug('Queries 06: ' + Limits.getQueries());
        Test.stopTest();
 		System.debug('Queries 07: ' + Limits.getQueries());
    }
/*    
    @isTest
    static void ConsentLeadIdInMapTest4() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account LIMIT 1];
        Centro__c center = [SELECT Id FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];
        Lead le = [SELECT Id FROM Lead LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        
        
        Case ca = new Case();
        //ca.AccountId = acc.Id;
        ca.Centro__c = center.Id;
        ca.Marca__c = 'AUDI';
        ca.Origin ='Web';
        ca.Intencion_de_compra__c = 'Prueba';
        ca.Campana__c = camp.Id;
        ca.Lead__c = le.Id;
        ca.SuppliedPhone = '918887765';
        ca.SuppliedEmail = 'case@test.com';
        ca.EnvioMulesoft__c = 'OK';
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        
        List<Consentimientos__c> lstConsents = new List<Consentimientos__c>();
        Consentimientos__c consentPersonEmail = CreaObjetos.creaConsentimiento(acc.PersonEmail, con.Id, Label.channelEmail);
        consentPersonEmail.Lead__c = le.Id;
        lstConsents.add(consentPersonEmail);
        Consentimientos__c consentPersonOtherEmail = CreaObjetos.creaConsentimientoOther(acc.OtherEmail__pc, con.Id, Label.channelEmail,false);
        consentPersonOtherEmail.Lead__c = le.Id;
        lstConsents.add(consentPersonOtherEmail);
        
 		System.debug('Queries 00: ' + Limits.getQueries());
 		System.debug('Queries 01: ' + Limits.getQueries());
        insert lstConsents;
 		System.debug('Queries 02: ' + Limits.getQueries());
        insert ca;        
 		System.debug('Queries 03: ' + Limits.getQueries());

        ca.Numero_de_llamadas__c = '1';
        update ca;
 		System.debug('Queries 04: ' + Limits.getQueries());
        
        ca.Numero_de_llamadas__c = '2';
        update ca;
 		System.debug('Queries 05: ' + Limits.getQueries());

        ca.Numero_de_llamadas__c = '3';
        update ca;
 		System.debug('Queries 06: ' + Limits.getQueries());
        
        Test.startTest();
 		System.debug('Queries 07: ' + Limits.getQueries());
        ca.SuppliedPhone = '918887766';
        ca.Numero_de_llamadas__c = '4';
        ca.Contactado__c = true;
        update ca;
 		System.debug('Queries 08: ' + Limits.getQueries());
        Test.stopTest();
 		System.debug('Queries 09: ' + Limits.getQueries());
    }
    
    @isTest
    static void ConsentLeadIdInMapTest5() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account LIMIT 1];
        Centro__c center = [SELECT Id FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];
        Lead le = [SELECT Id FROM Lead LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        
        
        Case ca = new Case();
        //ca.AccountId = acc.Id;
        ca.Centro__c = center.Id;
        ca.Marca__c = 'AUDI';
        ca.Origin ='Web';
        ca.Intencion_de_compra__c = 'Prueba';
        ca.Campana__c = camp.Id;
        ca.Lead__c = le.Id;
        ca.SuppliedPhone = '918887765';
        ca.SuppliedEmail = 'case@test.com';
        ca.EnvioMulesoft__c = 'OK';
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        
        List<Consentimientos__c> lstConsents = new List<Consentimientos__c>();
        Consentimientos__c consentPersonEmail = CreaObjetos.creaConsentimiento(acc.PersonEmail, con.Id, Label.channelEmail);
        consentPersonEmail.Lead__c = le.Id;
        lstConsents.add(consentPersonEmail);
        Consentimientos__c consentPersonOtherEmail = CreaObjetos.creaConsentimientoOther(acc.OtherEmail__pc, con.Id, Label.channelEmail,false);
        consentPersonOtherEmail.Lead__c = le.Id;
        lstConsents.add(consentPersonOtherEmail);
        
        insert lstConsents;
        insert ca;        

        ca.Numero_de_llamadas__c = '1';
        update ca;
        
        ca.Numero_de_llamadas__c = '2';
        update ca;

        ca.Numero_de_llamadas__c = '3';
        update ca;

        ca.Numero_de_llamadas__c = '4';
        update ca;
        
        Test.startTest();
        ca.SuppliedPhone = '918887766';
        ca.Numero_de_llamadas__c = '5';
        ca.Contactado__c = true;
        update ca;
        Test.stopTest();
    }
    
    @isTest
    static void ConsentLeadIdInMapTest6() {
        Centro__c center = [SELECT Id FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];
        Lead le = [SELECT Id FROM Lead LIMIT 1];
        
        Case ca = new Case();
        //ca.AccountId = acc.Id;
        ca.Centro__c = center.Id;
        ca.Marca__c = 'AUDI';
        ca.Origin ='Web';
        ca.Intencion_de_compra__c = 'Prueba';
        ca.Campana__c = camp.Id;
        ca.Lead__c = le.Id;
        ca.SuppliedPhone = '918887765';
        ca.SuppliedEmail = 'case@test.com';
        ca.EnvioMulesoft__c = 'OK';
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        
        List<Consentimientos__c> lstConsents = new List<Consentimientos__c>();
        Consentimientos__c consentPersonEmail = CreaObjetos.creaConsentimiento('case@test.com', null, Label.channelEmail);
        consentPersonEmail.Lead__c = le.Id;
        lstConsents.add(consentPersonEmail);
        
        insert lstConsents;
        insert ca;        

        ca.Numero_de_llamadas__c = '1';
        update ca;
        
        ca.Numero_de_llamadas__c = '2';
        update ca;

        ca.Numero_de_llamadas__c = '3';
        update ca;

        ca.Numero_de_llamadas__c = '4';
        update ca;

        ca.Numero_de_llamadas__c = '5';
        update ca;
        
        Test.startTest();
        ca.SuppliedPhone = '918887766';
        ca.Numero_de_llamadas__c = '6';
        ca.Contactado__c = true;
        update ca;
        Test.stopTest();
    }
*/    
    @isTest
    static void ConsentNoLeadIdInMapTest() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account LIMIT 1];
        Centro__c center = [SELECT Id FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        
        Consentimientos__c consentimiento = CreaObjetos.creaConsentimiento(acc.PersonEmail, con.Id, 'Email');
        SYSTEM.debug('consentimeitno:' + consentimiento);
        insert consentimiento;
        
        Case ca = new Case();
        ca.AccountId = acc.Id;
        ca.Centro__c = center.Id;
        ca.Marca__c = 'AUDI';
        ca.Origin ='Web';
        ca.Intencion_de_compra__c = 'Prueba';
        ca.Campana__c = camp.Id;
        //ca.Lead__c = le.Id;
        ca.SuppliedPhone = '918887765';
        ca.SuppliedEmail = 'case@test.com';
        ca.EnvioMulesoft__c = 'OK';
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        
        Test.startTest();
        insert ca;        
        
        ca.SuppliedPhone = '918887766';
        update ca;
        
        System.debug('===>CASE: ' + ca);
        
        //delete ca;
        Test.stopTest();
    }

    @isTest
    static void FriendANoLeadIdInMapTest() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account LIMIT 1];
        Centro__c center = [SELECT Id, Concesionario__c  FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        
        Consentimientos__c consentimiento = CreaObjetos.creaConsentimiento(acc.PersonEmail, con.Id, 'Email');
        SYSTEM.debug('consentimeitno:' + consentimiento);
        insert consentimiento;

        Salesman__c salesman = new Salesman__c();
        salesman.Email__c = 'foo@bar.com';
        insert salesman;
        
        Opportunity opp = CreaObjetos.creaOportunidad(acc.Id, center.Concesionario__c, center.Id, 'tesrop1' );
        opp.Vendedor__c = salesman.Id;
        opp.Name = 'test/opp';
        insert opp;        

        Account acc1 = CreaObjetos.creaCuentaPersonal('CaseTest21', 'Personal');
        acc1.PersonEmail = 'pruebaotheremail2@test.com';
        acc1.OtherEmail__pc = 'pruebaemail2@test.com';
        acc1.Phone ='999100100';
        acc1.PersonMobilePhone = '699100100';
        insert acc1;
        
        Case ca = new Case();
        ca.AccountId = acc1.Id;
        ca.Centro__c = center.Id;
        ca.Marca__c = 'AUDI';
        ca.Origin ='Landing';
        ca.Intencion_de_compra__c = 'Prueba';
        ca.Campana__c = camp.Id;
        //ca.Lead__c = le.Id;
        ca.SuppliedPhone = '918887765';
        ca.SuppliedEmail = 'case@test.com';
        ca.EnvioMulesoft__c = 'OK';
        ca.RecommendBy__c = opp.Id;
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        
        Test.startTest();
        insert ca;        
        
        ca.SuppliedPhone = '918887766';
        update ca;
        
        System.debug('===>CASE: ' + ca);
        
        //delete ca;
        Test.stopTest();
    }

    @isTest
    static void FriendBNoLeadIdInMapTest() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account LIMIT 1];
        Centro__c center = [SELECT Id, Concesionario__c  FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        
        Consentimientos__c consentimiento = CreaObjetos.creaConsentimiento(acc.PersonEmail, con.Id, 'Email');
        SYSTEM.debug('consentimeitno:' + consentimiento);
        insert consentimiento;

        Salesman__c salesman = new Salesman__c();
        salesman.Email__c = 'foo@bar.com';
        insert salesman;
        
        Opportunity opp = CreaObjetos.creaOportunidad(acc.Id, center.Concesionario__c, center.Id, 'tesrop1' );
        opp.Vendedor__c = salesman.Id;
        opp.Name = 'test/opp';
        insert opp;        

        Account acc1 = CreaObjetos.creaCuentaPersonal('CaseTest21', 'Personal');
        acc1.PersonEmail = 'pruebaotheremail2@test.com';
        acc1.OtherEmail__pc = 'pruebaemail2@test.com';
        acc1.Phone ='999100100';
        acc1.PersonMobilePhone = '699100100';
        insert acc1;
        
        Case ca = new Case();
        ca.AccountId = acc1.Id;
        ca.Centro__c = center.Id;
        ca.Marca__c = 'AUDI';
        ca.Origin ='Landing';
        ca.Intencion_de_compra__c = 'Prueba';
        ca.Campana__c = camp.Id;
        //ca.Lead__c = le.Id;
        ca.SuppliedPhone = '918887765';
        ca.SuppliedEmail = 'case@test.com';
        ca.EnvioMulesoft__c = 'OK';
        ca.RecommendBy__c = opp.Id;
        ca.Description = 'trae a un amigo';
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        
        Test.startTest();
        insert ca;        
        
        ca.SuppliedPhone = '918887766';
        update ca;
        
        System.debug('===>CASE: ' + ca);
        
        //delete ca;
        Test.stopTest();
    }

    @isTest
    static void FriendCNoLeadIdInMapTest() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account LIMIT 1];
        Centro__c center = [SELECT Id, Concesionario__c  FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        
        Consentimientos__c consentimiento = CreaObjetos.creaConsentimiento(acc.PersonEmail, con.Id, 'Email');
        SYSTEM.debug('consentimeitno:' + consentimiento);
        insert consentimiento;

        Salesman__c salesman = new Salesman__c();
        salesman.Email__c = 'foo@bar.com';
        insert salesman;
        
        Opportunity opp = CreaObjetos.creaOportunidad(acc.Id, center.Concesionario__c, center.Id, 'tesrop1' );
        opp.Vendedor__c = salesman.Id;
        opp.Name = 'test/opp';
        insert opp;        
        
        Vehiculo__c vehicle = CreaObjetos.creaVehiculo('VIN01', acc.Id, 'HYUNDAI', 'E9887YYJ');
        insert vehicle; 
        
        Detalle_venta__c detV = CreaObjetos.creaDetalleVenta(center.Concesionario__c, center.Id, vehicle.Id);
        detV.Opportunity__c = opp.Id;
        detV.Vendedor__c = salesman.Id;
        detV.Comprador__c = acc.Id;
        detV.Propietario__c = acc.Id;
        
        insert detV;        

        Account acc1 = CreaObjetos.creaCuentaPersonal('CaseTest21', 'Personal');
        acc1.PersonEmail = 'pruebaotheremail2@test.com';
        acc1.OtherEmail__pc = 'pruebaemail2@test.com';
        acc1.Phone ='999100100';
        acc1.PersonMobilePhone = '699100100';
        insert acc1;
        
        Case ca = new Case();
        ca.AccountId = acc1.Id;
        ca.Centro__c = center.Id;
        ca.Marca__c = 'AUDI';
        ca.Origin ='Landing';
        ca.Intencion_de_compra__c = 'Prueba';
        ca.Campana__c = camp.Id;
        //ca.Lead__c = le.Id;
        ca.SuppliedPhone = '918887765';
        ca.SuppliedEmail = 'case@test.com';
        ca.EnvioMulesoft__c = 'OK';
        ca.RecommendBy__c = opp.Id;
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        
        Test.startTest();
        insert ca;        
        
        ca.SuppliedPhone = '918887766';
        update ca;
        
        System.debug('===>CASE: ' + ca);
        
        //delete ca;
        Test.stopTest();
    }

    @isTest
    static void FriendDNoLeadIdInMapTest() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account LIMIT 1];
        Centro__c center = [SELECT Id, Concesionario__c  FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        
        Consentimientos__c consentimiento = CreaObjetos.creaConsentimiento(acc.PersonEmail, con.Id, 'Email');
        SYSTEM.debug('consentimeitno:' + consentimiento);
        insert consentimiento;

        Salesman__c salesman = new Salesman__c();
        salesman.Email__c = 'foo@bar.com';
        insert salesman;
        
        Opportunity opp = CreaObjetos.creaOportunidad(acc.Id, center.Concesionario__c, center.Id, 'tesrop1' );
        opp.Vendedor__c = salesman.Id;
        opp.Name = 'test/opp';
        insert opp;        
        
        Vehiculo__c vehicle = CreaObjetos.creaVehiculo('VIN01', acc.Id, 'HYUNDAI', 'E9887YYJ');
        insert vehicle; 
        
        Detalle_venta__c detV = CreaObjetos.creaDetalleVenta(center.Concesionario__c, center.Id, vehicle.Id);
        detV.Opportunity__c = opp.Id;
        detV.Vendedor__c = salesman.Id;
        detV.Comprador__c = acc.Id;
        detV.Propietario__c = acc.Id;
        
        insert detV;        

        Account acc1 = CreaObjetos.creaCuentaPersonal('CaseTest21', 'Personal');
        acc1.PersonEmail = 'pruebaotheremail2@test.com';
        acc1.OtherEmail__pc = 'pruebaemail2@test.com';
        acc1.Phone ='999100100';
        acc1.PersonMobilePhone = '699100100';
        insert acc1;
        
        Case ca = new Case();
        ca.AccountId = acc1.Id;
        ca.Centro__c = center.Id;
        ca.Marca__c = 'AUDI';
        ca.Origin ='Landing';
        ca.Intencion_de_compra__c = 'Prueba';
        ca.Campana__c = camp.Id;
        //ca.Lead__c = le.Id;
        ca.SuppliedPhone = '918887765';
        ca.SuppliedEmail = 'case@test.com';
        ca.EnvioMulesoft__c = 'OK';
        ca.RecommendBy__c = opp.Id;
        ca.Description = 'trae a un amigo';
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        
        Test.startTest();
        insert ca;        
        
        ca.SuppliedPhone = '918887766';
        update ca;
        
        System.debug('===>CASE: ' + ca);
        
        //delete ca;
        Test.stopTest();
    }


    @isTest
    static void FriendENoLeadIdInMapTest() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account LIMIT 1];
        Centro__c center = [SELECT Id, Concesionario__c  FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        
        Consentimientos__c consentimiento = CreaObjetos.creaConsentimiento(acc.PersonEmail, con.Id, 'Email');
        SYSTEM.debug('consentimeitno:' + consentimiento);
        insert consentimiento;

        Salesman__c salesman = new Salesman__c();
        salesman.Email__c = 'foo@bar.com';
        insert salesman;
        
        Vehiculo__c vehicle = CreaObjetos.creaVehiculo('VIN01', acc.Id, 'HYUNDAI', 'E9887YYJ');
        insert vehicle; 
        
        Pase_de_taller__c pasTaller = CreaObjetos.creaPaseTaller(vehicle.Id, acc.Id, center.Concesionario__c, center.Id);
        insert pasTaller;        

        Account acc1 = CreaObjetos.creaCuentaPersonal('CaseTest21', 'Personal');
        acc1.PersonEmail = 'pruebaotheremail2@test.com';
        acc1.OtherEmail__pc = 'pruebaemail2@test.com';
        acc1.Phone ='999100100';
        acc1.PersonMobilePhone = '699100100';
        insert acc1;
        
        Case ca = new Case();
        ca.AccountId = acc1.Id;
        ca.Centro__c = center.Id;
        ca.Marca__c = 'AUDI';
        ca.Origin ='Landing';
        ca.Intencion_de_compra__c = 'Prueba';
        ca.Campana__c = camp.Id;
        //ca.Lead__c = le.Id;
        ca.SuppliedPhone = '918887765';
        ca.SuppliedEmail = 'case@test.com';
        ca.EnvioMulesoft__c = 'OK';
        ca.RecommendByPT__c = pasTaller.Id;
        ca.Description = 'trae a un amigo';
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        
        Test.startTest();
        insert ca;        
        
        ca.SuppliedPhone = '918887766';
        update ca;
        
        System.debug('===>CASE: ' + ca);
        
        //delete ca;
        Test.stopTest();
    }

    @isTest
    static void FriendFNoLeadIdInMapTest() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account LIMIT 1];
        Centro__c center = [SELECT Id, Concesionario__c  FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        
        Consentimientos__c consentimiento = CreaObjetos.creaConsentimiento(acc.PersonEmail, con.Id, 'Email');
        SYSTEM.debug('consentimeitno:' + consentimiento);
        insert consentimiento;

        Salesman__c salesman = new Salesman__c();
        salesman.Email__c = 'foo@bar.com';
        insert salesman;
        
        Vehiculo__c vehicle = CreaObjetos.creaVehiculo('VIN01', acc.Id, 'HYUNDAI', 'E9887YYJ');
        insert vehicle; 
        
        Pase_de_taller__c pasTaller = CreaObjetos.creaPaseTaller(vehicle.Id, acc.Id, center.Concesionario__c, center.Id);
        insert pasTaller;        

        Account acc1 = CreaObjetos.creaCuentaPersonal('CaseTest21', 'Personal');
        acc1.PersonEmail = 'pruebaotheremail2@test.com';
        acc1.OtherEmail__pc = 'pruebaemail2@test.com';
        acc1.Phone ='999100100';
        acc1.PersonMobilePhone = '699100100';
        insert acc1;
        
        Case ca = new Case();
        ca.AccountId = acc1.Id;
        ca.Centro__c = center.Id;
        ca.Marca__c = 'AUDI';
        ca.Origin ='Landing';
        ca.Intencion_de_compra__c = 'Prueba';
        ca.Campana__c = camp.Id;
        //ca.Lead__c = le.Id;
        ca.SuppliedPhone = '918887765';
        ca.SuppliedEmail = 'case@test.com';
        ca.EnvioMulesoft__c = 'OK';
        ca.RecommendByPT__c = pasTaller.Id;
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        
        Test.startTest();
        insert ca;        
        
        ca.SuppliedPhone = '918887766';
        update ca;
        
        System.debug('===>CASE: ' + ca);
        
        //delete ca;
        Test.stopTest();
    }    
    
    @isTest
    static void FeedbackClienteTest() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account LIMIT 1];
        Centro__c center = [SELECT Id, Concesionario__c  FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        
        Consentimientos__c consentimiento = CreaObjetos.creaConsentimiento(acc.PersonEmail, con.Id, 'Email');
        SYSTEM.debug('consentimeitno:' + consentimiento);
        insert consentimiento;

        Salesman__c salesman = new Salesman__c();
        salesman.Email__c = 'foo@bar.com';
        insert salesman;
        
        Opportunity opp = CreaObjetos.creaOportunidad(acc.Id, center.Concesionario__c, center.Id, 'tesrop1' );
        opp.Vendedor__c = salesman.Id;
        opp.Name = 'test/opp';
        insert opp;        
        
        Vehiculo__c vehicle = CreaObjetos.creaVehiculo('VIN01', acc.Id, 'HYUNDAI', 'E9887YYJ');
        insert vehicle; 
        
        Detalle_venta__c detV = CreaObjetos.creaDetalleVenta(center.Concesionario__c, center.Id, vehicle.Id);
        detV.Opportunity__c = opp.Id;
        detV.Vendedor__c = salesman.Id;
        detV.Comprador__c = acc.Id;
        detV.Propietario__c = acc.Id;
        
        insert detV;        

        Account acc1 = CreaObjetos.creaCuentaPersonal('CaseTest21', 'Personal');
        acc1.PersonEmail = 'pruebaotheremail2@test.com';
        acc1.OtherEmail__pc = 'pruebaemail2@test.com';
        acc1.Phone ='999100100';
        acc1.PersonMobilePhone = '699100100';
        insert acc1;
        
        Case ca = new Case();
        ca.AccountId = acc1.Id;
        ca.Origin ='Landing';
        ca.FeedbackSale__c = detV.Id;
        ca.Description = 'trae a un amigo';
        ca.FeedbackValue__c = '1'; 
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Feedback_Cliente').getRecordTypeId();
        
        Test.startTest();
        insert ca;        
        
        System.debug('===>CASE: ' + ca);
        
        //delete ca;
        Test.stopTest();
    }

    @isTest
    static void FeedbackClienteBTest() {
        Centro__c center = [SELECT Id, Concesionario__c  FROM Centro__c LIMIT 1];

        Account acc1 = CreaObjetos.creaCuentaPersonal('CaseTest21', 'Personal');
        acc1.PersonEmail = 'pruebaotheremail2@test.com';
        acc1.OtherEmail__pc = 'pruebaemail2@test.com';
        acc1.Phone ='999100100';
        insert acc1;
        
        Salesman__c salesman = new Salesman__c();
        salesman.Email__c = 'foo@bar.com';
        insert salesman;
        
        Opportunity opp = CreaObjetos.creaOportunidad(acc1.Id, center.Concesionario__c, center.Id, 'tesrop1' );
        opp.Vendedor__c = salesman.Id;
        opp.Name = 'test/opp';
        insert opp;        
        
        Vehiculo__c vehicle = CreaObjetos.creaVehiculo('VIN01', acc1.Id, 'HYUNDAI', 'E9887YYJ');
        insert vehicle; 
        
        Detalle_venta__c detV = CreaObjetos.creaDetalleVenta(center.Concesionario__c, center.Id, vehicle.Id);
        detV.Opportunity__c = opp.Id;
        detV.Vendedor__c = salesman.Id;
        detV.Comprador__c = acc1.Id;
        detV.Propietario__c = acc1.Id;
        
        insert detV;        
        
        Case ca = new Case();
        ca.AccountId = acc1.Id;
        ca.Origin ='Landing';
        ca.FeedbackSale__c = detV.Id;
        ca.Description = 'trae a un amigo';
        ca.FeedbackValue__c = '1'; 
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Feedback_Cliente').getRecordTypeId();
        
        Test.startTest();
        insert ca;        

        System.debug('===>CASE: ' + ca);
        Test.stopTest();
    }

    @isTest
    static void IncidenciaMobilityTest() {
        Centro__c center = [SELECT Id, Concesionario__c FROM Centro__c WHERE Name = 'Centro03' LIMIT 1];

        Account acc1 = CreaObjetos.creaCuentaPersonal('CaseTest21', 'Personal');
        acc1.PersonEmail = 'pruebaotheremail2@test.com';
        acc1.OtherEmail__pc = 'pruebaemail2@test.com';
        acc1.Phone ='999100100';
        insert acc1;
        
        Salesman__c salesman = new Salesman__c();
        salesman.Email__c = 'foo@bar.com';
        insert salesman;
        
        Vehiculo__c vehicle = CreaObjetos.creaVehiculo('VIN01', acc1.Id, 'HYUNDAI', 'E9887YYJ');
        insert vehicle;
        
        Contrato_Rent_A_Car__c contratoRentACar = new Contrato_Rent_A_Car__c();
        contratoRentACar.Name = 'CONT1';
        contratoRentACar.uuid__c = 'CONT1';
        contratoRentACar.driver__c = acc1.id;
        contratoRentACar.vehicle__c = vehicle.id;
        contratoRentACar.pickUpLocation__c = center.id;
        contratoRentACar.brand__c = 'AVIS';
        insert contratoRentACar;
        
        Case ca = new Case();
        ca.Origin ='Landing';
        ca.Contrato_Rent_A_Car__c = contratoRentACar.Id;
        ca.Description = 'prueba incidencia mobility';
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Incidencia_Mobility').getRecordTypeId();
        
        Test.startTest();
        insert ca;        

        System.debug('===>CASE: ' + ca);
        Test.stopTest();
    }
    
    @isTest
    static void SorteoNoLeadIdInMapTest() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account LIMIT 1];
        Centro__c center = [SELECT Id, Concesionario__c  FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        
        Consentimientos__c consentimiento = CreaObjetos.creaConsentimiento(acc.PersonEmail, con.Id, 'Email');
        SYSTEM.debug('consentimeitno:' + consentimiento);
        insert consentimiento;
        
        Case ca = new Case();
        ca.AccountId = acc.Id;
        ca.Centro__c = center.Id;
        ca.Marca__c = 'AUDI';
        ca.Origin ='Landing';
        ca.Intencion_de_compra__c = 'Sorteo';
        ca.Campana__c = camp.Id;
        //ca.Lead__c = le.Id;
        ca.SuppliedPhone = '918887765';
        ca.SuppliedEmail = 'case@test.com';
        ca.EnvioMulesoft__c = 'OK';
        ca.Description = 'trae a un amigo';
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        
        Test.startTest();
        insert ca;        
        
        ca.SuppliedPhone = '918887766';
        update ca;
        
        System.debug('===>CASE: ' + ca);
        
        //delete ca;
        Test.stopTest();
    }

    @isTest
    static void EmailNoLeadIdInMapTest() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account LIMIT 1];
        Centro__c center = [SELECT Id, Concesionario__c  FROM Centro__c WHERE Name = 'Centro02' LIMIT 1];
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];
        Lead le = [SELECT Id FROM Lead LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        
        Consentimientos__c consentimiento = CreaObjetos.creaConsentimiento(acc.PersonEmail, con.Id, 'Email');
        SYSTEM.debug('consentimeitno:' + consentimiento);
        insert consentimiento;
        
        Case ca = new Case();
        ca.AccountId = acc.Id;
        ca.Centro__c = center.Id;
        ca.Marca__c = 'AUDI';
        ca.Origin ='Landing';
        ca.Intencion_de_compra__c = 'Prueba';
        ca.Campana__c = camp.Id;
        //ca.Lead__c = le.Id;
        ca.SuppliedPhone = '918887765';
        ca.SuppliedEmail = 'case@test.com';
        ca.EnvioMulesoft__c = 'OK';
        ca.Description = 'trae a un amigo';
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        
        Test.startTest();
        insert ca;        
        
        ca.SuppliedPhone = '918887766';
        update ca;
        
        System.debug('===>CASE: ' + ca);
        
        //delete ca;
        Test.stopTest();
    }

    @isTest
    static void EmailVONoLeadIdInMapTest() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account LIMIT 1];
        Centro__c center = [SELECT Id, Concesionario__c  FROM Centro__c WHERE Name = 'Centro01' LIMIT 1];
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];
        Lead le = [SELECT Id FROM Lead LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        
        Consentimientos__c consentimiento = CreaObjetos.creaConsentimiento(acc.PersonEmail, con.Id, 'Email');
        SYSTEM.debug('consentimeitno:' + consentimiento);
        insert consentimiento;
        
        Case ca = new Case();
        ca.AccountId = acc.Id;
        ca.Centro__c = center.Id;
        ca.Marca__c = 'AUDI';
        ca.Origin ='e-commerce';
        ca.Intencion_de_compra__c = 'Financiar';
        ca.Campana__c = camp.Id;
        //ca.Lead__c = le.Id;
        ca.SuppliedPhone = '918887765';
        ca.SuppliedEmail = 'case@test.com';
        ca.EnvioMulesoft__c = 'OK';
        ca.Description = 'trae a un amigo';
        ca.brandVO__c = 'AUDI';
        ca.modelVO__c = 'A1';    
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead_VO').getRecordTypeId();
        
        System.debug('Inma1-caso:'+ca);
        
        Test.startTest();
        insert ca;        
        
        ca.SuppliedPhone = '918887766';
        update ca;
        
        System.debug('===>CASE: ' + ca);
        
        //delete ca;
        Test.stopTest();
    }
    
     @isTest
    static void ConsentAccountIdNewInMapTest() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account LIMIT 1];
        Centro__c center = [SELECT Id FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];
        Lead le = [SELECT Id FROM Lead LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        
        
        Case ca = new Case();
        ca.AccountId = acc.Id;
        ca.Centro__c = center.Id;
        ca.Marca__c = 'AUDI';
        ca.Origin ='Web';
        ca.Intencion_de_compra__c = 'Prueba';
        ca.Campana__c = camp.Id;
        //ca.Lead__c = le.Id;
        ca.SuppliedPhone = '918887765';
        ca.SuppliedEmail = 'case@test.com';
        ca.EnvioMulesoft__c = 'OK';
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        
        Test.startTest();
        insert ca;        
        
        ca.SuppliedPhone = '918887766';
        update ca;
        
        System.debug('===>CASE: ' + ca);
        
        //delete ca;
        Test.stopTest();
    }
    
     @isTest
    static void ConsentChangeAccountInMapTest() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account LIMIT 1];
        Centro__c center = [SELECT Id FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];
        Lead le = [SELECT Id FROM Lead LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        
        
        Case ca = new Case();
        ca.Lead__c = le.Id;
        ca.Centro__c = center.Id;
        ca.Marca__c = 'AUDI';
        ca.Origin ='Web';
        ca.Intencion_de_compra__c = 'Prueba';
        ca.Campana__c = camp.Id;
        //ca.Lead__c = le.Id;
        ca.SuppliedPhone = '918887765';
        ca.SuppliedEmail = 'case@test.com';
        ca.EnvioMulesoft__c = 'OK';
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        
        Test.startTest();
        insert ca;        
        
        ca.SuppliedPhone = '918887766';
        ca.AccountId = acc.Id;
        ca.Lead__c = null;
        update ca;
        
        System.debug('===>CASE: ' + ca);
        
        //delete ca;
        Test.stopTest();
    }
    
     @isTest
    static void ConsentChangeAccount2InMapTest() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account LIMIT 1];
        Centro__c center = [SELECT Id FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];
        Lead le = [SELECT Id FROM Lead LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        
        Consentimientos__c consentimiento = CreaObjetos.creaConsentimiento(acc.PersonEmail, con.Id, 'Email');
        SYSTEM.debug('consentimeitno:' + consentimiento);
        insert consentimiento;
        
        
        Case ca = new Case();
        ca.Lead__c = le.Id;
        ca.Centro__c = center.Id;
        ca.Marca__c = 'AUDI';
        ca.Origin ='Web';
        ca.Intencion_de_compra__c = 'Prueba';
        ca.Campana__c = camp.Id;
        //ca.Lead__c = le.Id;
        ca.SuppliedPhone = '918887765';
        ca.SuppliedEmail = 'case@test.com';
        ca.EnvioMulesoft__c = 'OK';
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        
        
        Test.startTest();
        insert ca;        
        
        ca.SuppliedPhone = '918887766';
        ca.AccountId = acc.Id;
        ca.Lead__c = null;
        update ca;
        
        System.debug('===>CASE: ' + ca);
        
        //delete ca;
        Test.stopTest();
    }
    
    @isTest
    static void InvalidPhoneTest() {
        Case ca = new Case();
        
        Test.startTest();        
        ca.SuppliedPhone = '555';
        //ca.SuppliedEmail = 'invalid';
        insert ca;
        Test.stopTest();
    }
    
    @isTest
    static void DeleteTest() {
        Case ca = new Case();
        
        Test.startTest();        
        insert ca;
        delete ca;
        Test.stopTest();
    }
    
    @isTest
    static void CasoReservaFeriaAvisCanceladoVOTest() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account LIMIT 1];
        Centro__c center = [SELECT Id FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];
        Lead le = [SELECT Id FROM Lead LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        
        Case caso = new Case();
        caso.Centro__c = center.Id;
        caso.Marca__c = 'AUDI';
        caso.Origin =Label.origenFeriaAvis;
        caso.Intencion_de_compra__c = Label.IntencionCReserva;
        caso.Campana__c = camp.Id;
        caso.Lead__c = le.Id;
        caso.SuppliedPhone = '918887765';
        caso.SuppliedEmail = 'case@test.com';
        caso.bookingStatus__c = 'Cancelado';
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.RtCaseGestionLeadVO).getRecordTypeId();
        
        Test.startTest();
        insert caso;        
        Test.stopTest();
        Case casoComprobacion = [select id, status, Motivo_de_cierre__c from Case where id = :caso.Id];
        system.debug('caso:'+ casoComprobacion);
    }
   
    @isTest
    static void CasoReservaFeriaAvisPagoRealizadoVOTest() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account LIMIT 1];
        Centro__c center = [SELECT Id FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];
        Lead le = [SELECT Id FROM Lead LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        
        Case caso = new Case();
        caso.Centro__c = center.Id;
        caso.Marca__c = 'AUDI';
        caso.Origin = Label.origenFeriaAvis;
        caso.Intencion_de_compra__c = Label.IntencionCReserva;
        caso.Campana__c = camp.Id;
        caso.Lead__c = le.Id;
        caso.SuppliedPhone = '918887765';
        caso.SuppliedEmail = 'case@test.com';
        caso.bookingStatus__c = 'Pago realizado';
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.RtCaseGestionLeadVO).getRecordTypeId();
        
        Test.startTest();
        insert caso;        
        Test.stopTest();
        Case casoComprobacion = [select id, status, Motivo_de_cierre__c from Case where id = :caso.Id];
        system.debug('caso:'+ casoComprobacion);
    }
    
    @isTest
    static void CasoInformacionFeriaAvisVOTest() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account LIMIT 1];
        Centro__c center = [SELECT Id FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];
        Lead le = [SELECT Id FROM Lead LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        
        Case caso = new Case();
        caso.Centro__c = center.Id;
        caso.Marca__c = 'AUDI';
        caso.Origin =Label.origenFeriaAvis;
        caso.Intencion_de_compra__c = Label.IntencionCInformacion;
        caso.Campana__c = camp.Id;
        caso.Lead__c = le.Id;
        caso.SuppliedPhone = '918887765';
        caso.SuppliedEmail = 'case@test.com';
        caso.bookingStatus__c = 'Pago realizado';
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.RtCaseGestionLeadVO).getRecordTypeId();
        
        Test.startTest();
        insert caso;        
        Test.stopTest();
        Case casoComprobacion = [select id, status, Motivo_de_cierre__c from Case where id = :caso.Id limit 1];
        system.debug('caso:'+ casoComprobacion);
    }
    
    @isTest
    static void CasoConcesionarioExternoVOTest() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account LIMIT 1];
        Centro__c center = [SELECT Id FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];
        Concesionario__c concess = [select id FROM Concesionario__c where Id_Concesionario_Sima__c = :'A0002NO' LIMIT 1];
        Lead le = [SELECT Id FROM Lead LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        
        Case caso = new Case();
        caso.Centro__c = center.Id;
        caso.Marca__c = 'AUDI';
        caso.Origin ='Email';
        caso.Intencion_de_compra__c = 'Reserva';
        caso.Campana__c = camp.Id;
        caso.Lead__c = le.Id;
        caso.SuppliedPhone = '918887765';
        caso.SuppliedEmail = 'case@test.com';
        caso.Propietario_Vehiculo__c = concess.Id;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.RtCaseGestionLeadVO).getRecordTypeId();
        
        Test.startTest();
        insert caso;        
        Test.stopTest();
        Case casoComprobacion = [select id, status, Motivo_de_cierre__c from Case where id = :caso.Id];
        system.debug('caso:'+ casoComprobacion);
    }
    
    @isTest
    static void MobilityLeadTest() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account LIMIT 1];
        Centro__c center = [SELECT Id FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];
        Lead le = [SELECT Id FROM Lead LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
                
        Case ca = new Case();
        //ca.AccountId = acc.Id;
        ca.Centro__c = center.Id;
        ca.Marca__c = 'AUDI';
        ca.Origin ='Web';
        ca.Intencion_de_compra__c = 'Prueba';
        ca.Campana__c = camp.Id;
        ca.Lead__c = le.Id;
        ca.SuppliedPhone = '918887765';
        ca.SuppliedEmail = 'case@test.com';
        ca.Origen_Renting__c = 'XTRAVANS';
        ca.RentingType__c = 'Fijo';
        ca.VehicleType__c = '13';
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead_Mobility').getRecordTypeId();
        
        List<Consentimientos__c> lstConsents = new List<Consentimientos__c>();
        Consentimientos__c consentPersonEmail = CreaObjetos.creaConsentimiento(acc.PersonEmail, con.Id, Label.channelEmail);
        consentPersonEmail.Lead__c = le.Id;
        lstConsents.add(consentPersonEmail);
        Consentimientos__c consentPersonOtherEmail = CreaObjetos.creaConsentimientoOther(acc.OtherEmail__pc, con.Id, Label.channelEmail,false);
        consentPersonOtherEmail.Lead__c = le.Id;
        lstConsents.add(consentPersonOtherEmail);
        
        Test.startTest();
        insert lstConsents;
        insert ca;        
        
        ca.SuppliedPhone = '918887766';
        ca.RentingType__c = 'Flexible';
        ca.VehicleType__c = '23';
        update ca;
        Test.stopTest();
    }
    
    @isTest
    static void MobilityLeadTest1() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account LIMIT 1];
        Centro__c center = [SELECT Id FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];
        Lead le = [SELECT Id FROM Lead LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
                
        Case ca = new Case();
        //ca.AccountId = acc.Id;
        ca.Centro__c = center.Id;
        ca.Marca__c = 'AUDI';
        ca.Origin ='Web';
        ca.Intencion_de_compra__c = 'Prueba';
        ca.Campana__c = camp.Id;
        ca.Lead__c = le.Id;
        ca.SuppliedPhone = '918887765';
        ca.SuppliedEmail = 'case@test.com';
        ca.Origen_Renting__c = 'XTRAVANS';
        ca.RentingType__c = 'Flexible';
        ca.VehicleType__c = '23';
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead_Mobility').getRecordTypeId();
        
        List<Consentimientos__c> lstConsents = new List<Consentimientos__c>();
        Consentimientos__c consentPersonEmail = CreaObjetos.creaConsentimiento(acc.PersonEmail, con.Id, Label.channelEmail);
        consentPersonEmail.Lead__c = le.Id;
        lstConsents.add(consentPersonEmail);
        Consentimientos__c consentPersonOtherEmail = CreaObjetos.creaConsentimientoOther(acc.OtherEmail__pc, con.Id, Label.channelEmail,false);
        consentPersonOtherEmail.Lead__c = le.Id;
        lstConsents.add(consentPersonOtherEmail);
        
        Test.startTest();
        insert lstConsents;
        insert ca;        
        
        ca.SuppliedPhone = '918887766';
        ca.RentingType__c = 'Fijo';
        ca.VehicleType__c = '13';
        update ca;
        Test.stopTest();
    }
    
    @isTest
    static void MobilityLeadTest3() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account LIMIT 1];
        Centro__c center = [SELECT Id FROM Centro__c LIMIT 1];
        Campaign camp = [SELECT Id FROM Campaign LIMIT 1];
        Lead le = [SELECT Id FROM Lead LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
                
        Case ca = new Case();
        //ca.AccountId = acc.Id;
        ca.Centro__c = center.Id;
        ca.Marca__c = 'AUDI';
        ca.Modelo__c = 'A1';
        ca.descmodel__c = 'des1';
        ca.Origin ='Web';
        ca.Intencion_de_compra__c = 'Prueba';
        ca.Campana__c = camp.Id;
        ca.Lead__c = le.Id;
        ca.SuppliedPhone = '918887765';
        ca.SuppliedEmail = 'case@test.com';
        ca.Origen_Renting__c = 'MYCARFLIX';
        ca.Duration__c = '14';
        ca.ExpectedKms__c = '10000';
        ca.TarifaID__c = '1';
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead_Mobility').getRecordTypeId();
        
        List<Consentimientos__c> lstConsents = new List<Consentimientos__c>();
        Consentimientos__c consentPersonEmail = CreaObjetos.creaConsentimiento(acc.PersonEmail, con.Id, Label.channelEmail);
        consentPersonEmail.Lead__c = le.Id;
        lstConsents.add(consentPersonEmail);
        Consentimientos__c consentPersonOtherEmail = CreaObjetos.creaConsentimientoOther(acc.OtherEmail__pc, con.Id, Label.channelEmail,false);
        consentPersonOtherEmail.Lead__c = le.Id;
        lstConsents.add(consentPersonOtherEmail);
        
        Test.startTest();
        insert lstConsents;
        insert ca;        
        
        ca.SuppliedPhone = '918887766';
        ca.Modelo__c = 'A4';
        ca.TarifaID__c = '2';
        update ca;
        Test.stopTest();
    }
    
}