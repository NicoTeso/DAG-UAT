@isTest
public class ContratoRentingVehicleHandler_Test {

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
        Contrato_renting__c cRenting = creaObjetos.creaContratoRenting('Test', 'CP_TEST1');
        insert cRenting;
        Test.startTest();
        
        Contrato_renting_vehiculo__c cRentingVehiculo = creaObjetos.creaContratoRentingVehiculo('Test', cRenting.Id);
        cRentingVehiculo.Conductor__c = acc.Id;
        cRentingVehiculo.Conductor_2__c = acc1.Id;
        insert cRentingVehiculo;
        Contrato_renting_vehiculo__c cRentingVehiculo1 = [SELECT Id, Name, Contrato_Vehiculo__c, Contrato_Marco__c FROM Contrato_renting_vehiculo__c LIMIT 1];
        CRentingVehiculo1.Estado__c = 'Finalizado'; 
        CRentingVehiculo1.Motivo_de_finalizacion__c = 'Cambio vehículo';
        cRentingVehiculo1.Conductor__c = acc2.Id;
        CRentingVehiculo1.Duracion_en_meses__c = 36;
        CRentingVehiculo1.Forma_de_pago__c = 'Transferencia Intercompany';
        update cRentingVehiculo1;
        
        Test.stopTest();
    }

    
    @isTest
    static void cRenting1Test() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account where PersonEmail = 'pruebaotheremail@test.com' LIMIT 1];
        Account acc1 = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account where PersonEmail = 'pruebaotheremail1@test.com' LIMIT 1];
        Contrato_renting__c cRenting = creaObjetos.creaContratoRenting('Test', 'CP_TEST2');
        insert cRenting;
        Test.startTest();
        
        Contrato_renting_vehiculo__c cRentingVehiculo = creaObjetos.creaContratoRentingVehiculo('Test', cRenting.Id);
        cRentingVehiculo.numero_de_sustituciones__c = 1;
        cRentingVehiculo.Conductor__c = acc.Id;
        cRentingVehiculo.Conductor_2__c = acc1.Id;
        insert cRentingVehiculo;
        Contrato_renting_vehiculo__c cRentingVehiculo1 = [SELECT Id, Name, Contrato_Vehiculo__c, Contrato_Marco__c FROM Contrato_renting_vehiculo__c LIMIT 1];
        CRentingVehiculo1.Estado__c = 'Finalizado'; 
        CRentingVehiculo1.Motivo_de_finalizacion__c = 'Cambio vehículo';
        CRentingVehiculo1.Duracion_en_meses__c = 36;

 		update cRentingVehiculo1;
        
        Test.stopTest();
    }

    
    @isTest
    static void cRenting2Test() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account where PersonEmail = 'pruebaotheremail@test.com' LIMIT 1];
        Account acc1 = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account where PersonEmail = 'pruebaotheremail1@test.com' LIMIT 1];
        Contrato_renting__c cRenting = creaObjetos.creaContratoRenting('Test', 'CP_TEST2');
        insert cRenting;
        Test.startTest();
        
        Contrato_renting_vehiculo__c cRentingVehiculo = creaObjetos.creaContratoRentingVehiculo('Test', cRenting.Id);
        cRentingVehiculo.numero_de_sustituciones__c = 1;
        cRentingVehiculo.Conductor__c = acc.Id;
        cRentingVehiculo.Conductor_2__c = acc1.Id;
        insert cRentingVehiculo;
        Contrato_renting_vehiculo__c cRentingVehiculo1 = [SELECT Id, Name, Contrato_Vehiculo__c, Contrato_Marco__c FROM Contrato_renting_vehiculo__c LIMIT 1];
        CRentingVehiculo1.Estado__c = Label.EstadoVehiculoentregado; 
        CRentingVehiculo1.Duracion_en_meses__c = 36;

 		update cRentingVehiculo1;
        
        Test.stopTest();
    }
    
}