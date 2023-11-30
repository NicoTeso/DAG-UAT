@IsTest
public class MergeEmpresaAccountBatchTest {
    
    @testSetup
    static void setup() {
        Account acc = new Account();
        acc.Name = 'Test Botch';
        acc.Phone = '917776655';
        acc.Email__c = 'testbatch@test.com';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cliente_Empresa').getRecordTypeId();
        acc.Documento__c='AO12332';
        acc.Tipo_de_documento_empresa__c='VATId'; 
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
        acc.Marca__c ='VOLKSWAGEN';
        acc.Cliente_Propio__c = true;
        acc.Fecha_Limite_Cliente_Propio__c = date.today().addDays(20);        
        
        insert acc;
        
        Account acc2 = new Account();
        acc2.Name = 'Test Botch';
        acc2.Phone = '917776655';
        acc2.Email__c = 'testbatchSINDNI@test.com';
        acc2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cliente_Empresa').getRecordTypeId();
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
        acc2.Marca__c ='HYUNDAI';
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
        acc2.typeCustomer__c = 'business';
        
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
        List<DuplicateRule> drules = [select id, DeveloperName from DuplicateRule where DeveloperName = 'AccTodos'];
        for (Account acc :[Select id, Documento__c from Account]){
            if(String.isBlank(acc.Documento__c)){
                segundo = acc;
            }
            else {
                primero = acc;
            }
        }
        
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
        Database.executeBatch(new MergeEmpresaAccountBatch());
        Test.stopTest();
    }
    
    @isTest
    static void testBatch2(){
        Account primero, segundo;
        List<DuplicateRule> drules = [select id, DeveloperName from DuplicateRule where DeveloperName = 'AccTodos'];
        for (Account acc :[Select id, Documento__c from Account]){
            if(String.isBlank(acc.Documento__c)){
                primero = acc;
            }
            else {
                segundo = acc;
            }
        }
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
        Database.executeBatch(new MergeEmpresaAccountBatch());
        Test.stopTest();
    }
    
     @isTest
    static void testBatch3(){
        Account primero;
        List<DuplicateRule> drules = [select id, DeveloperName from DuplicateRule where DeveloperName = 'AccTodos'];
        for (Account acc :[Select id, Documento__c from Account]){
            if(String.isBlank(acc.Documento__c)){
                primero = acc;
            }
        }
        Account segundo = new Account();
        segundo.Name = 'Test BatchSegundo';
        segundo.Phone = '917776655';
        segundo.Email__c = 'testbatchPrueba@test.com';
        segundo.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cliente_Empresa').getRecordTypeId();
        segundo.Marca__c ='AUDI';
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
        Database.executeBatch(new MergeEmpresaAccountBatch());
        Test.stopTest();
    }
    
     @isTest
    static void testBatch4(){
        Account segundo;
        List<DuplicateRule> drules = [select id, DeveloperName from DuplicateRule where DeveloperName = 'AccTodos'];
        for (Account acc :[Select id, Documento__c from Account]){
            if(String.isBlank(acc.Documento__c)){
                segundo = acc;
            }
        }
        segundo.ultima_modificacion_DMS__c = Datetime.now().addYears(-1);
        update segundo;
        Account primero = new Account();
        primero.Name = 'Test BatchSegundo';
        primero.Phone = '917776655';
        primero.Email__c = 'testbatchPrueba@test.com';
        primero.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cliente_Empresa').getRecordTypeId();
        primero.ultima_modificacion_DMS__c = Datetime.now();
        primero.Marca__c ='OTRAS';
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
        Database.executeBatch(new MergeEmpresaAccountBatch());
        Test.stopTest();
    }

}