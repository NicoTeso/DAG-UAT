@isTest
public class UpdateLimiteEnvioFUMobilityBatch_Test {

    @testSetup
    static void setup() {
    	TriggersTest.activaTriggers();

        Account cli =  CreaObjetos.creaCuentaPersonal('nombrePropietario', 'apellido');
        cli.PersonEmail ='emailprueba@prueba.com';
        cli.PersonMobilePhone ='+34699999999';
        cli.LimiteEnvioFUMobility__c = date.today().addDays(-30);
        insert cli;
        
        }

    @isTest
    static void batchTest() {
        Test.startTest();
        Database.executeBatch(new UpdateLimiteEnvioFUMobilityBatch(),10);
        Test.stopTest();
    }

    @isTest
    static void schedulableTest() {
        Test.startTest();
        UpdateLimiteEnvioFUMobilityBatch sch = new UpdateLimiteEnvioFUMobilityBatch();
        String chron = '0 0 1 * * ?';
        system.schedule('Test for UpdateLimiteEnvioFUMobilityBatch', chron, sch);
		Test.stopTest();
	}
    
}