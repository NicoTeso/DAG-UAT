@isTest
public class UpdateTargetBatch_Test {

    @testSetup
    static void setup() {
    	TriggersTest.activaTriggers();

        Account cli =  CreaObjetos.creaCuentaPersonal('otroPropietario', 'apellido');
        cli.PersonEmail ='emailprueba1@prueba.com';
        cli.PersonMobilePhone ='+34699999888';
        insert cli;
        
        Vehiculo__c veh_audi = CreaObjetos.creaVehiculo('VIN01', cli.Id, 'AUDI', 'XXXX1');
        veh_audi.ModeloString__c = 'AU-01';
        veh_audi.kms__c = 0;
        veh_audi.Fecha_fin_garantia__c = Datetime.now();
        veh_audi.Fecha_inicio_extension_garantia__c = Datetime.now();
        veh_audi.Fecha_fin_extension_garantia__c = Datetime.now().addYears(2);
        veh_audi.Fecha_primera_matriculacion__c = Datetime.now();
        veh_audi.Letra_Motor__c = 'CHJB';
        veh_audi.RecalcularTargetBatch__c = true;
        List<Vehiculo__c> lstVehicles = new List<Vehiculo__c>{veh_audi};
        insert lstVehicles;
        
        }

    @isTest
    static void batchTest() {
        Test.startTest();
        Database.executeBatch(new UpdateTargetBatch(),1);
        Test.stopTest();
    }

    @isTest
    static void schedulableTest() {
        Test.startTest();
        UpdateTargetBatch sch = new UpdateTargetBatch();
        String chron = '0 0 1 * * ?';
        system.schedule('Test for UpdateTargetBatch', chron, sch);
		Test.stopTest();
	}
    
}