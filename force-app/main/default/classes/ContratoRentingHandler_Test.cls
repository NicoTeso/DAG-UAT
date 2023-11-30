@isTest
public class ContratoRentingHandler_Test {

	@testSetup
    static void setup() {
        TriggersTest.activaTriggers();

        ContratoRenting__c cRentingContador = new ContratoRenting__c();
        cRentingContador.ContadorContratoRenting__c = 1;
        insert cRentingContador;
        Account acc = CreaObjetos.creaCuentaPersonal('CaseTest', 'Luis');
        acc.PersonEmail = 'pruebaotheremail@test.com';
        acc.OtherEmail__pc = 'pruebaemail@test.com';
        acc.Phone ='999999999';
        acc.PersonMobilePhone = '699999999';
        insert acc;

        Account acc1 = CreaObjetos.creaCuentaPersonal('CaseTest', 'Maria');
        acc1.PersonEmail = 'pruebaotheremail1@test.com';
        acc1.OtherEmail__pc = 'pruebaemail1@test.com';
        acc1.Phone ='999999800';
        acc1.PersonMobilePhone = '699999800';
        insert acc1;

        Account acc2 = CreaObjetos.creaCuentaPersonal('CaseTest', 'Antonio');
        acc2.PersonEmail = 'pruebaotheremail2@test.com';
        acc2.OtherEmail__pc = 'pruebaemail2@test.com';
        acc2.Phone ='999999700';
        acc2.PersonMobilePhone = '699999700';
        insert acc2;
        
        Concesionario__c conces = CreaObjetos.creaConcesionario('711');
        conces.Domicilio__c = 'Test domicilio';
        conces.CIF__c = '123123123';
        insert conces;

        
    }
    
    @isTest
    static void cRentingTest() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account where PersonEmail = 'pruebaotheremail@test.com' LIMIT 1];
        Account acc1 = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account where PersonEmail = 'pruebaotheremail1@test.com' LIMIT 1];
        Account acc2 = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account where PersonEmail = 'pruebaotheremail2@test.com' LIMIT 1];
        Test.startTest();
        Contrato_renting__c cRenting = creaObjetos.creaContratoRenting('Test', 'CP_TEST1');
        cRenting.Cliente__c = acc.Id;
        cRenting.Persona_firma_contrato__c = acc1.Id;
        cRenting.Forma_de_pago__c = 'Transferencia Intercompany';
        insert cRenting;
        Contrato_renting__c cRenting1 = [SELECT Id, Name, Contrato_Marco__c FROM Contrato_renting__c LIMIT 1];
        cRenting1.Persona_firma_contrato_2__c = acc2.Id;
        CRenting1.Forma_de_pago__c = null;
        cRenting1.Numero_Cuenta__c = 'ES01281240020123456789';
        update cRenting1;
        
        Test.stopTest();
    }

    
    @isTest
    static void cRenting1Test() {
        Test.startTest();
        Contrato_renting__c cRenting = creaObjetos.creaContratoRenting('Test', null);
        insert cRenting;
        Test.stopTest();
    }
    
}