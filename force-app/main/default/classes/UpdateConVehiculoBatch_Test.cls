@isTest
public class UpdateConVehiculoBatch_Test {

    @testSetup
    static void setup() {
    	TriggersTest.activaTriggers();

        Account cli =  CreaObjetos.creaCuentaPersonal('nombrePropietario', 'apellido');
        cli.PersonEmail ='emailprueba@prueba.com';
        cli.PersonMobilePhone ='+34699999999';
        insert cli;

        Account cli1 =  CreaObjetos.creaCuentaPersonal('otroPropietario', 'apellido');
        cli.PersonEmail ='emailprueba1@prueba.com';
        cli.PersonMobilePhone ='+34699999888';
        insert cli1;

        Account cli2 =  CreaObjetos.creaCuentaPersonal('nuevoPropietario', 'apellido');
        cli.PersonEmail ='emailprueba2@prueba.com';
        cli.PersonMobilePhone ='+34699999777';
        insert cli2;

        Account cli3 =  CreaObjetos.creaCuentaPersonal('nuevoOtroPropietario', 'apellido');
        cli.PersonEmail ='emailprueba3@prueba.com';
        cli.PersonMobilePhone ='+34699999666';
        insert cli3;
        
        Vehiculo__c veh_audi = CreaObjetos.creaVehiculo('VIN01', cli.Id, 'AUDI', 'XXXX1');
        veh_audi.ModeloString__c = 'AU-01';
        veh_audi.kms__c = 0;
        veh_audi.Fecha_fin_garantia__c = Datetime.now();
        veh_audi.Fecha_inicio_extension_garantia__c = Datetime.now();
        veh_audi.Fecha_fin_extension_garantia__c = Datetime.now().addYears(2);
        veh_audi.Fecha_primera_matriculacion__c = Datetime.now();
        veh_audi.Letra_Motor__c = 'CHJB';
        veh_audi.PropietarioAnt__c = cli1.Id;
        veh_audi.DepositarioAnt__c = cli1.Id;
        veh_audi.CompradorAnt__c = cli1.Id;
        List<Vehiculo__c> lstVehicles = new List<Vehiculo__c>{veh_audi};
        
        Vehiculo__c veh_audi1 = CreaObjetos.creaVehiculo('VIN02', cli1.Id, 'AUDI', 'XXXX2');
        veh_audi1.ModeloString__c = 'AU-01';
        veh_audi1.kms__c = 0;
        veh_audi1.Fecha_fin_garantia__c = Datetime.now();
        veh_audi1.Fecha_inicio_extension_garantia__c = Datetime.now();
        veh_audi1.Fecha_fin_extension_garantia__c = Datetime.now().addYears(2);
        veh_audi1.Fecha_primera_matriculacion__c = Datetime.now();
        veh_audi1.Letra_Motor__c = 'CHJB';
        veh_audi1.PropietarioAnt__c = cli2.Id;
        veh_audi1.DepositarioAnt__c = cli2.Id;
        veh_audi1.CompradorAnt__c = cli3.Id;
        lstVehicles.add(veh_audi1);
        insert lstVehicles;
        
        }

    @isTest
    static void batchTest() {
        Test.startTest();
        Database.executeBatch(new UpdateConVehiculoBatch(),10);
        Test.stopTest();
    }

    @isTest
    static void schedulableTest() {
        Test.startTest();
        UpdateConVehiculoBatch sch = new UpdateConVehiculoBatch();
        String chron = '0 0 1 * * ?';
        system.schedule('Test for UpdateConVehiculoBatch', chron, sch);
		Test.stopTest();
	}
    
}