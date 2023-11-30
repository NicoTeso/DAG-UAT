@isTest
public class MergeLeadBatchTest {
    @testSetup
    static void setup() {
        Lead ld = CreaObjetos.creaLead('Test', 'Prueba1');
        ld.Documento__c = '73681355G';
        ld.Phone ='917776655';
        insert ld;
        
        Lead ld2 = CreaObjetos.creaLead('Test', 'Prueba2');
        ld2.Phone = '917776655';
        ld2.ConCasosMKTImp__c = true;
        ld2.ConCasosMKTNoImp__c = true;
        ld2.ConEcosistema__c = true;
        insert ld2;
        
        Campaign camp = new Campaign();
        camp.Name = 'CampaginTest';
        insert camp;
        
        Case ca = new Case();
        ca.Marca__c = 'AUDI';
        ca.Origin ='Web';
        ca.Intencion_de_compra__c = 'Prueba';
        ca.Campana__c = camp.Id;
        ca.Lead__c = ld2.Id;
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
        	chat.LeadId = ld2.Id;
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
        Lead primero, segundo;
        List<DuplicateRule> drules = [select id, DeveloperName from DuplicateRule where DeveloperName = 'LeadTodos'];
        for (Lead ld :[Select id, Documento__c from Lead]){
            if(!String.isBlank(ld.Documento__c )){
                primero = ld;
            }
            else {
                segundo = ld;
            }
        }
        Consentimientos__c cons = CreaObjetos.creaConsentimientoOther('917776655', segundo.Id, Label.channelPhone, true);
        insert cons;
        Consentimientos__c cons1 = CreaObjetos.creaConsentimientoOther('917776655', primero.Id, Label.channelPhone, true);
        insert cons1;
        
        Consentimientos__c cons2 = CreaObjetos.creaConsentimientoOther('666666666', segundo.Id, Label.channelMobile, true);
        cons2.Fecha_de_captura__c= Datetime.now();
        insert cons2;
        Consentimientos__c cons3 = CreaObjetos.creaConsentimientoOther('testbatch@test.com', segundo.Id, Label.channelEmail, true);
        insert cons3;
        Consentimientos__c cons4 = CreaObjetos.creaConsentimientoOther('testbatch2@test.com', segundo.Id, Label.channelEmail, true);
        insert cons4;
        
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
        Database.executeBatch(new MergeLeadBatch());
        Test.stopTest();
    }
    
    @isTest
    static void testBatch2() {
        
        Map<String, String> mapDuplicateRuleId = new Map<String,String>();
        Lead primero, segundo;
        List<DuplicateRule> drules = [select id, DeveloperName from DuplicateRule where DeveloperName = 'LeadTodos'];
        for (Lead ld :[Select id, Documento__c from Lead]){
            if(!String.isBlank(ld.Documento__c )){
                segundo = ld;
            }
            else {
                primero = ld;
            }
        }
        Consentimientos__c cons = CreaObjetos.creaConsentimientoOther('917776655', segundo.Id, Label.channelPhone, true);
        insert cons;
        Consentimientos__c cons1 = CreaObjetos.creaConsentimientoOther('917776655', primero.Id, Label.channelPhone, true);
        insert cons1;
        
        Consentimientos__c cons2 = CreaObjetos.creaConsentimientoOther('666666666', segundo.Id, Label.channelMobile, true);
        cons2.Fecha_de_captura__c= Datetime.now();
        insert cons2;
        Consentimientos__c cons3 = CreaObjetos.creaConsentimientoOther('testbatch@test.com', segundo.Id, Label.channelEmail, true);
        insert cons3;
        Consentimientos__c cons4 = CreaObjetos.creaConsentimientoOther('testbatch2@test.com', segundo.Id, Label.channelEmail, true);
        insert cons4;
        
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
        Database.executeBatch(new MergeLeadBatch());
        Test.stopTest();
    }
    
    @isTest
    static void testBatch3() {
        
        Map<String, String> mapDuplicateRuleId = new Map<String,String>();
        Lead primero;
        List<DuplicateRule> drules = [select id, DeveloperName from DuplicateRule where DeveloperName = 'LeadTodos'];
        for (Lead ld :[Select id, Documento__c from Lead]){
            if(String.isBlank(ld.Documento__c )){
                primero = ld;
            }
        }
        Lead segundo = CreaObjetos.creaLead('PruebaLead', 'Prueba 2');
        segundo.Phone = '917776655';
        insert segundo;
        Consentimientos__c cons = CreaObjetos.creaConsentimientoOther('917776655', segundo.Id, Label.channelPhone, true);
        insert cons;
        Consentimientos__c cons1 = CreaObjetos.creaConsentimientoOther('917776655', primero.Id, Label.channelPhone, true);
        insert cons1;
        
        Consentimientos__c cons2 = CreaObjetos.creaConsentimientoOther('666666666', segundo.Id, Label.channelMobile, true);
        cons2.Fecha_de_captura__c= Datetime.now();
        insert cons2;
        Consentimientos__c cons3 = CreaObjetos.creaConsentimientoOther('testbatch@test.com', segundo.Id, Label.channelEmail, true);
        insert cons3;
        Consentimientos__c cons4 = CreaObjetos.creaConsentimientoOther('testbatch2@test.com', segundo.Id, Label.channelEmail, true);
        insert cons4;
        
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
        Database.executeBatch(new MergeLeadBatch());
        Test.stopTest();
    }
    
    @isTest
    static void testBatch4() {
        
        Map<String, String> mapDuplicateRuleId = new Map<String,String>();
        Lead segundo;
        List<DuplicateRule> drules = [select id, DeveloperName from DuplicateRule where DeveloperName = 'LeadTodos'];
        for (Lead ld :[Select id, Documento__c from Lead]){
            if(String.isBlank(ld.Documento__c )){
                segundo = ld;
            }
        }
        Lead primero = CreaObjetos.creaLead('PruebaLead', 'Prueba 2');
        primero.Phone = '917776655';
        insert primero;
        Consentimientos__c cons = CreaObjetos.creaConsentimientoOther('917776655', segundo.Id, Label.channelPhone, true);
        cons.Fecha_de_captura__c = datetime.now();
        insert cons;
        Consentimientos__c cons1 = CreaObjetos.creaConsentimientoOther('917776655', primero.Id, Label.channelPhone, true);
        insert cons1;
        
        Consentimientos__c cons2 = CreaObjetos.creaConsentimientoOther('666666666', segundo.Id, Label.channelMobile, true);
        cons2.Fecha_de_captura__c= Datetime.now();
        insert cons2;
        Consentimientos__c cons3 = CreaObjetos.creaConsentimientoOther('testbatch@test.com', segundo.Id, Label.channelEmail, true);
        insert cons3;
        Consentimientos__c cons4 = CreaObjetos.creaConsentimientoOther('testbatch2@test.com', segundo.Id, Label.channelEmail, true);
        insert cons4;
        
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
        Database.executeBatch(new MergeLeadBatch());
        Test.stopTest();
    }

    @isTest
    static void schedulableTest() {
        Test.startTest();
        MergeLeadBatch sch = new MergeLeadBatch();
        String chron = '0 0 1 * * ?';
        system.schedule('Test for MergeLeadBatch', chron, sch);
		Test.stopTest();
	}
    
}