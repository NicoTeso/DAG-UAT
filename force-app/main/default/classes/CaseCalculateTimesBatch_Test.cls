@isTest
public class CaseCalculateTimesBatch_Test {
	@testSetup
    static void setup() {

        Concesionario__c conces = CreaObjetos.creaConcesionario('A000001');
        conces.Domicilio__c = 'Test domicilio';
        conces.CIF__c = '123123123';
        insert conces;
        
        Centro__c center = new Centro__c();
        center.Name = 'Centro01';
        center.Concesionario__c = conces.Id;
        center.Gestiona_LEAD__c = true;
        insert center;

        Campaign camp = new Campaign();
        camp.Name = 'CampaginTest';
        insert camp;
        
        Lead le = new Lead();
        le.LastName = 'CaseLead';
        insert le;
        
        Case ca = new Case();
        ca.Centro__c = center.Id;
        ca.Marca__c = 'AUDI';
        ca.Origin ='Web';
        ca.Intencion_de_compra__c = 'Prueba';
        ca.Campana__c = camp.Id;
        ca.Lead__c = le.Id;
        ca.SuppliedPhone = '918887765';
        ca.SuppliedEmail = 'case@test.com';
        ca.EnvioMulesoft__c = 'OK';
		ca.Fecha_Hora_de_contacto_c__c = Datetime.newInstanceGmt(2021, 04, 20, 12, 00, 00);
		ca.FirstCallDate__c = Datetime.newInstanceGmt(2021, 04, 20, 13, 00, 00);
		ca.SecondCallDate__c = Datetime.newInstanceGmt(2021, 04, 20, 14, 00, 00);
		ca.ThirdCallDate__c = Datetime.newInstanceGmt(2021, 04, 20, 15, 00, 00);
		ca.FourthCallDate__c = Datetime.newInstanceGmt(2021, 04, 20, 15, 30, 00);
		ca.FifthCallDate__c = Datetime.newInstanceGmt(2021, 04, 20, 15, 40, 00);
		ca.SixthCallDate__c = Datetime.newInstanceGmt(2021, 04, 20, 15, 50, 00);

        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        insert ca;        

    }
    
    @isTest
    static void batchTest() {
        Test.startTest();
        Database.executeBatch(new CaseCalculateTimesBatch());
        Test.stopTest();
        
    }
    
    @isTest
    static void scheduledTest() {
        Test.startTest();
        String jobId = System.schedule('testCaseCalculateTimesBatch', '0 59 12 1/1 * ? *', new CaseCalculateTimesBatch());
        System.debug('Scheduled jobs fired: ' + [SELECT TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobID]);
        Test.stopTest();
    }
}