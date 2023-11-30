@isTest
public class PaseTallerTriggerTest {

    @testSetup
    static void setup() {
        TriggersTest.activaTriggers();
	}
    
    @isTest static void creaPaseTaller() {
        Account cliente = CreaObjetos.creaCuentaPersonal('prueba', 'pruebaLastName');
        insert cliente;
        Concesionario__c concesionario = CreaObjetos.creaConcesionario('1');
        insert concesionario;
        Centro__c centro = CreaObjetos.creaCentro(concesionario.Id);
        Cliente_Concesionario__c cConcesionario = CreaObjetos.creaClienteConcesionario(cliente.Id, concesionario.Id, 'customer1', '1');
        cConcesionario.External_Id__c = 'customer1/1';
        insert cConcesionario;
        Vehiculo__c vehiculo = CreaObjetos.creaVehiculoTXT('VIN1234', 'customer1/1', 'customer1/1', 'customer1/1', 'HYUNDAI', 'MAT123');
        insert vehiculo;
        Pase_de_taller__c paseTaller = CreaObjetos.creaPaseTallerTXT(vehiculo.Id, 'customer1/1', 'customer1/1', 'customer1/1', concesionario.Id, centro.Id);
        Test.startTest();
        System.debug('paseTaller: '+paseTaller);
        insert paseTaller;
        paseTaller.customer__c = null;
        paseTaller.customerDepositary__c = null;
        paseTaller.customerOwner__c = null;
        update paseTaller;
        Test.stopTest();
    }

}