@isTest
public class MergePersonalAccountBatchTest {
    @testSetup
    static void setup() {
        Account acc = new Account();
        acc.FirstName = 'Test';
        acc.LastName = 'Botch';
        acc.Phone = '917776655';
        acc.PersonEmail = 'testbatch@test.com';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        acc.Documento__c='73681355G';
        acc.Tipo_de_documento_cuenta_personal__c='VATId'; 
        acc.Fecha_primera_compra_VN__c = Datetime.now().addYears(-5);
        acc.Fecha_ultima_compra_VN__c = Datetime.now();
        acc.Importe_VN__c = 10;
        acc.Fecha_primera_compra_VO__c = Datetime.now().addYears(-5);
        acc.Fecha_ultima_compra_VO__c = Datetime.now();
        acc.Importe_VO__c = 10;
        acc.Fecha_primera_compra_Postventa__c = Datetime.now().addYears(-5);
        acc.Fecha_ultima_compra_Postventa__c = Datetime.now();
        acc.Importe_Postventa__c = 10;
        acc.Fecha_primera_compra_Recambios__c = Datetime.now().addYears(-5);
        acc.Fecha_ltima_compra_Recambios__c = Datetime.now();
        acc.Importe_Recambios__c = 10;
        acc.Fecha_primera_compra_Mobility__c = Datetime.now().addYears(-5);
        acc.Fecha_ultima_compra_Mobility__c = Datetime.now();
        acc.Importe_Mobility__c = 10;
        acc.Marca__c ='VOLKSWAGEN;HYUNDAI';
        acc.Cliente_Propio__c = true;
        acc.Fecha_Limite_Cliente_Propio__c = date.today().addDays(20);        
        
        insert acc;
        
        Account acc2 = new Account();
        acc2.FirstName = 'Test';
        acc2.LastName = 'Botch';
        acc2.Phone = '917776655';
        acc2.PersonEmail = 'testbatchSINDNI@test.com';
        acc2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        acc2.Fecha_primera_compra_VN__c = Datetime.now().addYears(-6);
        acc2.Fecha_ultima_compra_VN__c = Datetime.now();
        acc2.Importe_VN__c = 10;
        acc2.Fecha_primera_compra_VO__c = Datetime.now().addYears(-6);
        acc2.Fecha_ultima_compra_VO__c = Datetime.now();
        acc2.Importe_VO__c = 10;
        acc2.Fecha_primera_compra_Postventa__c = Datetime.now().addYears(-6);
        acc2.Fecha_ultima_compra_Postventa__c = Datetime.now();
        acc2.Importe_Postventa__c = 10;
        acc2.Fecha_primera_compra_Recambios__c = Datetime.now().addYears(-6);
        acc2.Fecha_ltima_compra_Recambios__c = Datetime.now();
        acc2.Importe_Recambios__c = 10;
        acc2.Fecha_primera_compra_Mobility__c = Datetime.now().addYears(-6);
        acc2.Fecha_ultima_compra_Mobility__c = Datetime.now();
        acc2.Importe_Mobility__c = 10;
        acc2.Marca__c='VOLKSWAGEN;DUCATI';
        acc2.BillingAddressId__c = '100';
        acc2.BillingStreet = 'calle 1';
        acc2.BillingCity = 'City';
        acc2.BillingCountry = 'España';
        acc2.BillingPostalCode = '38500';
        acc2.BillingState = 'State';
        acc2.ShippingAddressId__c = '100';
        acc2.ShippingStreet = 'calle 1';
        acc2.ShippingCity = 'City';
        acc2.ShippingCountry = 'España';
        acc2.ShippingPostalCode = '38500';
        acc2.ShippingState = 'State';
        acc2.Cliente_Propio__c = true;
        acc2.Fecha_Limite_Cliente_Propio__c = date.today().addDays(90);
        acc2.typeCustomer__c = 'individual';
        acc2.drivingLicense__c = 'yyyy';
        acc2.ConCasosMKTImp__c = true;
        acc2.ConCasosMKTNoImp__c = true;
        acc2.ConEcosistema__c = true;
        acc2.ConEnvioFUMobility__c = true;
        acc2.ConOportunidad__c = true;
        acc2.ConTUA__c = true;
        acc2.ConVehiculo__c = true;
        
        insert acc2;
        
        
        Campaign camp = new Campaign();
        camp.Name = 'CampaginTest';
        insert camp;
        
        Case ca = new Case();
        ca.Marca__c = 'AUDI';
        ca.Origin ='Web';
        ca.Intencion_de_compra__c = 'Prueba';
        ca.Campana__c = camp.Id;
        ca.AccountId = acc2.Id;
        ca.SuppliedPhone = '918887765';
        ca.SuppliedEmail = 'case@test.com';
        ca.EnvioMulesoft__c = 'OK';
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        insert ca;
        
        LiveChatVisitor visitor = new LiveChatVisitor();
        insert visitor;
        
        User us = [SELECT Id FROM User WHERE Name = :Label.UserAutomatedProcess LIMIT 1];
        
        System.runAs(us) {
            LiveChatTranscript chat = new LiveChatTranscript();
        	chat.LiveChatVisitorId = visitor.Id;
        	chat.AccountId = null;
        	chat.AccountId = acc2.Id;
        	chat.CustomerName__c = 'Chat';
        	chat.CustomerLastname__c = 'Test';
        	chat.CustomerEmail__c = 'test@email.com';
            //chat.Status = 'In Progress';
            insert chat;
        }
    }
    
	@isTest
    static void testBatch1() {
        
        Map<String, String> mapDuplicateRuleId = new Map<String,String>();
        Account primero, segundo;
        List<DuplicateRule> drules = [select id, DeveloperName from DuplicateRule where DeveloperName = 'AccPTodos'];
        for (Account acc :[Select id, Documento__c, PersonContactId from Account]){
            if(String.isBlank(acc.Documento__c)){
                segundo = acc;
            }
            else {
                primero = acc;
            }
        }
        Concesionario__c conse = CreaObjetos.creaConcesionario('ISO1');
        insert conse;
        List<Consentimientos__c> lstConsentimientos = new List<Consentimientos__c>();
        Consentimientos__c cons = CreaObjetos.creaConsentimiento('666666666', primero.PersonContactId, Label.channelMobile);
        lstConsentimientos.add(cons);
        Consentimientos__c cons2 = CreaObjetos.creaConsentimiento('666666666', segundo.PersonContactId, Label.channelMobile);
        cons2.Fecha_de_captura__c= Datetime.now();
        lstConsentimientos.add(cons2);
        
        Consentimientos__c cons3 = CreaObjetos.creaConsentimiento('testbatch@test.com', primero.PersonContactId, Label.channelEmail);
        lstConsentimientos.add(cons3);
        Consentimientos__c cons4 = CreaObjetos.creaConsentimiento('testbatch2@test.com', segundo.PersonContactId, Label.channelEmail);
        lstConsentimientos.add(cons4);
        
        Consentimientos__c cons5 = CreaObjetos.creaConsentimiento('', primero.PersonContactId, Label.RtConsentimientoNoEcosistema);
        cons5.Concesionario__c = conse.Id;
        lstConsentimientos.add(cons5);
        Consentimientos__c cons6 = CreaObjetos.creaConsentimiento('', segundo.PersonContactId, Label.RtConsentimientoNoEcosistema);
        cons6.Concesionario__c = conse.Id;
        lstConsentimientos.add(cons6);
        
        Consentimientos__c cons7 = CreaObjetos.creaConsentimiento('', primero.PersonContactId, Label.RtConsentimientoFichaUnica);
        lstConsentimientos.add(cons7);
        Consentimientos__c cons8 = CreaObjetos.creaConsentimiento('', segundo.PersonContactId, Label.RtConsentimientoFichaUnica);
        cons8.oppositionDate__c = Datetime.now();
        lstConsentimientos.add(cons8);
        
        Consentimientos__c cons9 = CreaObjetos.creaConsentimiento('', primero.PersonContactId, Label.RtConsentimientoInterLegMKTCCS);
        cons9.Concesionario__c = conse.Id;
        lstConsentimientos.add(cons9);
        Consentimientos__c cons10 = CreaObjetos.creaConsentimiento('', segundo.PersonContactId, Label.RtConsentimientoInterLegMKTCCS);
        cons10.Concesionario__c = conse.Id;
        lstConsentimientos.add(cons10);
        
        insert lstConsentimientos;
        
        
        
        DuplicateRecordSet dpset = new DuplicateRecordSet();
        dpset.DuplicateRuleId = drules[0].Id;
        insert dpset;
        
        DuplicateRecordItem dp1 = new DuplicateRecordItem();
        dp1.RecordId = primero.Id;
        dp1.DuplicateRecordSetId = dpset.Id;
        
        DuplicateRecordItem dp2 = new DuplicateRecordItem();
        dp2.RecordId = segundo.Id;
        dp2.DuplicateRecordSetId = dpset.Id;
        insert dp1;
        insert dp2;
        
        
        Test.startTest();
        Database.executeBatch(new MergePersonalAccountBatch());
        Test.stopTest();
    }
    
    @isTest
    static void testBatch2(){
        Account primero, segundo;
        List<DuplicateRule> drules = [select id, DeveloperName from DuplicateRule where DeveloperName = 'AccPTodos'];
        for (Account acc :[Select id, Documento__c, PersonContactId from Account]){
            if(String.isBlank(acc.Documento__c)){
                primero = acc;
            }
            else {
                segundo = acc;
            }
        }
        
        Concesionario__c conse = CreaObjetos.creaConcesionario('ISO1');
        insert conse;
        List<Consentimientos__c> lstConsentimientos = new List<Consentimientos__c>();
        Consentimientos__c cons = CreaObjetos.creaConsentimiento('666666666', primero.PersonContactId, Label.channelMobile);
        lstConsentimientos.add(cons);
        Consentimientos__c cons2 = CreaObjetos.creaConsentimiento('666666666', segundo.PersonContactId, Label.channelMobile);
        cons2.Fecha_de_captura__c= Datetime.now();
        lstConsentimientos.add(cons2);
        
        Consentimientos__c cons3 = CreaObjetos.creaConsentimiento('testbatch@test.com', primero.PersonContactId, Label.channelEmail);
        lstConsentimientos.add(cons3);
        Consentimientos__c cons4 = CreaObjetos.creaConsentimiento('testbatch2@test.com', segundo.PersonContactId, Label.channelEmail);
        lstConsentimientos.add(cons4);
        
        Consentimientos__c cons5 = CreaObjetos.creaConsentimiento('', primero.PersonContactId, Label.RtConsentimientoNoEcosistema);
        cons5.Concesionario__c = conse.Id;
        lstConsentimientos.add(cons5);
        
        Consentimientos__c cons6 = CreaObjetos.creaConsentimiento('', primero.PersonContactId, Label.RtConsentimientoFichaUnica);
        lstConsentimientos.add(cons6);
        
        Consentimientos__c cons7 = CreaObjetos.creaConsentimiento('', primero.PersonContactId, Label.RtConsentimientoInterLegMKTCCS);
        cons7.Concesionario__c = conse.Id;
        lstConsentimientos.add(cons7);
        
        insert lstConsentimientos;
        
        DuplicateRecordSet dpset = new DuplicateRecordSet();
        dpset.DuplicateRuleId = drules[0].Id;
        insert dpset;
        
        DuplicateRecordItem dp1 = new DuplicateRecordItem();
        dp1.RecordId = primero.Id;
        dp1.DuplicateRecordSetId = dpset.Id;
        
        DuplicateRecordItem dp2 = new DuplicateRecordItem();
        dp2.RecordId = segundo.Id;
        dp2.DuplicateRecordSetId = dpset.Id;
        insert dp1;
        insert dp2;
        
        Test.startTest();
        Database.executeBatch(new MergePersonalAccountBatch());
        Test.stopTest();
    }
    
     @isTest
    static void testBatch3(){
        Account primero;
        List<DuplicateRule> drules = [select id, DeveloperName from DuplicateRule where DeveloperName = 'AccPTodos'];
        for (Account acc :[Select id, Documento__c, PersonContactId from Account]){
            if(String.isBlank(acc.Documento__c)){
                primero = acc;
            }
        }
        Account segundo = new Account();
        segundo.FirstName = 'Test';
        segundo.LastName = 'BatchSegundo';
        segundo.Phone = '917776655';
        segundo.PersonEmail = 'testbatchPrueba@test.com';
        segundo.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        
        insert segundo;
        
        DuplicateRecordSet dpset = new DuplicateRecordSet();
        dpset.DuplicateRuleId = drules[0].Id;
        insert dpset;
        
        DuplicateRecordItem dp1 = new DuplicateRecordItem();
        dp1.RecordId = primero.Id;
        dp1.DuplicateRecordSetId = dpset.Id;
        
        DuplicateRecordItem dp2 = new DuplicateRecordItem();
        dp2.RecordId = segundo.Id;
        dp2.DuplicateRecordSetId = dpset.Id;
        insert dp1;
        insert dp2;
        
        Test.startTest();
        Database.executeBatch(new MergePersonalAccountBatch());
        Test.stopTest();
    }
    
     @isTest
    static void testBatch4(){
        Account segundo;
        List<DuplicateRule> drules = [select id, DeveloperName from DuplicateRule where DeveloperName = 'AccPTodos'];
        for (Account acc :[Select id, Documento__c from Account]){
            if(String.isBlank(acc.Documento__c)){
                segundo = acc;
            }
        }
        segundo.ultima_modificacion_DMS__c = Datetime.now().addYears(-1);
        update segundo;
        Account primero = new Account();
        primero.FirstName = 'Test';
        primero.LastName = 'BatchSegundo';
        primero.Phone = '917776655';
        primero.PersonEmail = 'testbatchPrueba@test.com';
        primero.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        primero.ultima_modificacion_DMS__c = Datetime.now();
        insert primero;
        
        DuplicateRecordSet dpset = new DuplicateRecordSet();
        dpset.DuplicateRuleId = drules[0].Id;
        insert dpset;
        
        DuplicateRecordItem dp1 = new DuplicateRecordItem();
        dp1.RecordId = primero.Id;
        dp1.DuplicateRecordSetId = dpset.Id;
        
        DuplicateRecordItem dp2 = new DuplicateRecordItem();
        dp2.RecordId = segundo.Id;
        dp2.DuplicateRecordSetId = dpset.Id;
        insert dp1;
        insert dp2;
        
        Test.startTest();
        Database.executeBatch(new MergePersonalAccountBatch());
        Test.stopTest();
    }

    @isTest
    static void schedulableTest() {
        Test.startTest();
        MergePersonalAccountBatch sch = new MergePersonalAccountBatch();
        String chron = '0 0 1 * * ?';
        system.schedule('Test for MergePersonalAccountBatch', chron, sch);
		Test.stopTest();
	}



}