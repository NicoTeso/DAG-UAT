@isTest
public class LC_highlightsCustomControllerTest {

    @testSetup
    static void setup() {
        TriggersTest.activaTriggers();
    }

    
    @isTest
    static void getData() {
        Account cuenta = CreaObjetos.creaCuentaPersonal('prueba1', 'lastname');
        insert cuenta;
        Vehiculo__c veh = CreaObjetos.creaVehiculo('PruebaVIN', cuenta.id, 'Audi', 'PruebaVIN');
        insert veh;
        
        Test.startTest();
        LC_highlightsCustomController.getData(veh.Id, 'Vehiculo');
        
        Test.stopTest();
		
    }
}