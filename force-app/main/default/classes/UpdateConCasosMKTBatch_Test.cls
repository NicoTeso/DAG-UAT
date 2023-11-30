@isTest
public class UpdateConCasosMKTBatch_Test {

    @testSetup
    static void setup() {
    	TriggersTest.activaTriggers();
        

        }

    @isTest
    static void batchTestAccount() {

        Account cli =  CreaObjetos.creaCuentaPersonal('nombrePropietario', 'apellido');
        cli.PersonEmail ='emailprueba@prueba.com';
        cli.PersonMobilePhone ='+34699999999';
        insert cli;
        
        Account cli1 =  CreaObjetos.creaCuentaPersonal('otroPropietario', 'apellido');
        cli.PersonEmail ='emailprueba1@prueba.com';
        cli.PersonMobilePhone ='+34699999888';
        insert cli1;

        Case ca3 = new Case();
        ca3.AccountId = cli.Id;
        ca3.Marca__c = 'HONDA MOTOS';
        ca3.Origin ='Web';
        ca3.Intencion_de_compra__c = 'Prueba';
        ca3.SuppliedPhone = '918887765';
        ca3.SuppliedEmail = 'case@test.com';
        ca3.EnvioMulesoft__c = 'OK';
        ca3.Fecha_ampliacion_impacto__c = date.today().addMonths(-6);
        ca3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();

        Case ca4 = new Case();
        ca4.AccountId = cli.Id;
        ca4.Marca__c = 'HONDA MOTOS';
        ca4.Origin ='Web';
        ca4.Intencion_de_compra__c = 'Prueba';
        ca4.SuppliedPhone = '918887765';
        ca4.SuppliedEmail = 'case@test.com';
        ca4.EnvioMulesoft__c = 'OK';
        ca4.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();

        Case ca5 = new Case();
        ca5.AccountId = cli1.Id;
        ca5.Marca__c = 'HONDA MOTOS';
        ca5.Origin ='Web';
        ca5.Intencion_de_compra__c = 'Prueba';
        ca5.SuppliedPhone = '918887765';
        ca5.SuppliedEmail = 'case@test.com';
        ca5.EnvioMulesoft__c = 'OK';
        ca5.Fecha_ampliacion_impacto__c = date.today().addMonths(-6);
        ca5.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();

        List<Case> lstCasos = new List<Case>{ca3, ca4, ca5};
        insert lstCasos;    
        
        Test.startTest();
        Database.executeBatch(new UpdateConCasosMKTBatch(),10);
        Test.stopTest();
    }

    @isTest
    static void batchTestLead() {

        Lead le = new Lead();
        le.LastName = 'CaseLead';
        insert le;

        Lead le1 = new Lead();
        le1.LastName = 'CaseLead Nuevo';
        insert le1;
        
        Case ca = new Case();
        ca.Marca__c = 'HONDA MOTOS';
        ca.Origin ='Web';
        ca.Intencion_de_compra__c = 'Prueba';
        ca.Lead__c = le.Id;
        ca.SuppliedPhone = '918887765';
        ca.SuppliedEmail = 'case@test.com';
        ca.EnvioMulesoft__c = 'OK';
        ca.Fecha_ampliacion_impacto__c = date.today().addMonths(-6);
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
         
        Case ca1 = new Case();
        ca1.Marca__c = 'HONDA MOTOS';
        ca1.Origin ='Web';
        ca1.Intencion_de_compra__c = 'Prueba';
        ca1.Lead__c = le.Id;
        ca1.SuppliedPhone = '918887765';
        ca1.SuppliedEmail = 'case@test.com';
        ca1.EnvioMulesoft__c = 'OK';
        ca1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();

        Case ca2 = new Case();
        ca2.Marca__c = 'HONDA MOTOS';
        ca2.Origin ='Web';
        ca2.Intencion_de_compra__c = 'Prueba';
        ca2.Lead__c = le1.Id;
        ca2.SuppliedPhone = '918887765';
        ca2.SuppliedEmail = 'case@test.com';
        ca2.EnvioMulesoft__c = 'OK';
        ca2.Fecha_ampliacion_impacto__c = date.today().addMonths(-6);
        ca2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();

        List<Case> lstCasos = new List<Case>{ca, ca1, ca2};
        insert lstCasos;    
        
        Test.startTest();
        Database.executeBatch(new UpdateConCasosMKTBatch(),10);
        Test.stopTest();
    }
    
    @isTest
    static void schedulableTest() {
        Test.startTest();
        UpdateConCasosMKTBatch sch = new UpdateConCasosMKTBatch();
        String chron = '0 0 1 * * ?';
        system.schedule('Test for UpdateConCasosMKTBatch', chron, sch);
		Test.stopTest();
	}
    
}