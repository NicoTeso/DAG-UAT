@isTest
public class VehiculoTriggerTest {
    @testSetup
    static void setup() {
        TriggersTest.activaTriggers();
	}
    
    @isTest static void creaVehiculoHyundaiPersonal() {
        Account cliente = CreaObjetos.creaCuentaPersonal('prueba', 'pruebaLastName');
        insert cliente;
        Concesionario__c concesionario = CreaObjetos.creaConcesionario('1');
        insert concesionario;
        Cliente_Concesionario__c cConcesionario = CreaObjetos.creaClienteConcesionario(cliente.Id, concesionario.Id, 'customer1', '1');
        cConcesionario.External_Id__c = 'customer1/1';
        insert cConcesionario;
        Vehiculo__c vehiculo = CreaObjetos.creaVehiculoTXT('VIN1234', 'customer1/1', 'customer1/1', 'customer1/1', 'HYUNDAI', 'MAT123');
        Test.startTest();
        insert vehiculo;
        vehiculo.Ano_Modelo__c='2020';
        update vehiculo;
        Test.stopTest();
    }
    
       @isTest static void creaVehiculoHyundaiEmpresa() {
        Account cliente = CreaObjetos.creaCuentaEmpresa('prueba');
        insert cliente;
        Concesionario__c concesionario = CreaObjetos.creaConcesionario('1');
        insert concesionario;
        Cliente_Concesionario__c cConcesionario = CreaObjetos.creaClienteConcesionario(cliente.Id, concesionario.Id, 'customer1', '1');
        cConcesionario.External_Id__c = 'customer1/1';
        insert cConcesionario;
        Vehiculo__c vehiculo = CreaObjetos.creaVehiculoTXT('VIN1234', 'customer1/1', 'customer1/1', 'customer1/1', 'HYUNDAI', 'MAT123');
        Test.startTest();
        insert vehiculo;
        vehiculo.Comprador__c = null;
        vehiculo.Propietario__c = null;
        vehiculo.Depositario__c = null;
        vehiculo.Fecha_cumpleanos__c = null;
        vehiculo.Ano_Modelo__c='2020';
        vehiculo.kms__c=125;
        update vehiculo;
        Test.stopTest();
    }
}