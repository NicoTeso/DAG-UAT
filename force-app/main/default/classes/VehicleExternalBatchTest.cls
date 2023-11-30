@isTest
public class VehicleExternalBatchTest {

    @testSetup
    static void setup() {
        TriggersTest.activaTriggers();
        ApiConnect.activaApiConnect();
		CreaObjetos.creaPais();

        List<Concesionario__c> listConcesionarios = new List<Concesionario__c>();
        Concesionario__c conce = CreaObjetos.creaConcesionario('20');
        //insert conce;
        listConcesionarios.add(conce);
        Concesionario__c conce2 = CreaObjetos.creaConcesionario('21');
        conce2.Integrado_con_SIMA__c = true;
        listConcesionarios.add(conce2);
        insert listConcesionarios;
        
        Vehiculo__c hyundai = new Vehiculo__c();
        hyundai.VIN__c = 'VIN04';
        hyundai.Concesionario__c = conce.Id;
        hyundai.MarcaString__c = 'HYUNDAI';
        hyundai.ModeloString__c = 'HY-01';
        hyundai.kms__c = 0;
        hyundai.Fecha_cumpleanos__c = Date.today().addDays(-1);
        hyundai.Numero_de_cumpleanos__c = 4;
        hyundai.Fecha_fin_garantia__c = Datetime.now();
        hyundai.Fecha_inicio_extension_garantia__c = Datetime.now();
        hyundai.Fecha_fin_extension_garantia__c = Datetime.now().addYears(2);
        hyundai.Actualizar_Sima__c = true;
        hyundai.Fecha_inicio_garantia__c = Datetime.now().addYears(-3);
        hyundai.Fecha_primera_matriculacion__c = Datetime.now().addYears(-3);
        insert hyundai;
    }
    
    @isTest
    static void batchTest() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutVehicleMock());
        
        Test.startTest();
        Database.executeBatch(new VehicleExternalBatch());
        Test.stopTest();
       
        List<Vehiculo__c> vehiculos = [Select id, Actualizar_Sima__c from Vehiculo__c];
        system.assertEquals(vehiculos[0].Actualizar_Sima__c, false);
    }
    
    @isTest
    static void batchFailureTest() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMockFailure());
        
        Test.startTest();
        Database.executeBatch(new VehicleExternalBatch());
        Test.stopTest();
      
    }

    @isTest
    static void schedulableTest() {
        Test.startTest();
        VehicleExternalBatch sch = new VehicleExternalBatch();
        String chron = '0 0 1 * * ?';
        system.schedule('Test for gender batch', chron, sch);
		Test.stopTest();
	}

}