@isTest
public class Bajas_Transferencias_Batch_Test {
    @testSetup
    static void setup() {
        TriggersTest.activaTriggers();  

        ApiConnect__c api = new ApiConnect__c(ApiVehicleDGT_SubscriptionKey__c = '1aa4e55f3b824b1ebc4fe2bb33604f9c', ApiVehicleDGT__c = 'https://apim-datadag.azure-api.net/dev/vehicles/');
        insert api;

        CreaObjetos.creaPais();

        List<Concesionario__c> listConcesionarios = new List<Concesionario__c>();
        Concesionario__c conce = CreaObjetos.creaConcesionario('20');
        listConcesionarios.add(conce);
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

        /* Bajas_Transferencias_Model model = new Bajas_Transferencias_Model();
        model.vehicles = new List<Bajas_Transferencias_Model.VehicleDGT>();

        Bajas_Transferencias_Model.DGTBlock block = new Bajas_Transferencias_Model.DGTBlock();
        block.date_action_dgt = System.now();
        block.type_action = 'Transfer';

        Bajas_Transferencias_Model.VehicleDGT vehicle = new Bajas_Transferencias_Model.VehicleDGT();
        vehicle.dgt = new List<Bajas_Transferencias_Model.DGTBlock>();
        vehicle.dgt.add(block);
        vehicle.brand = hyundai.MarcaString__c;
        vehicle.model = hyundai.ModeloString__c;
        vehicle.vin = hyundai.VIN__c; */
    }
    
    @isTest
    static void batchTestTransfer() {
        Test.startTest();
        Database.executeBatch(new Bajas_Transferencias_Batch(),1);
        Test.stopTest();
    }
	
    @isTest
    static void batchTestTransferMonth() {
        Test.startTest();
        Database.executeBatch(new Bajas_Transferencias_Batch('transfer','last month'),1);
        Test.stopTest();
    }
    
    @isTest
    static void batchTestDeregistered() {
        Test.startTest();
        // Test.setMock(HttpCalloutMock.class, new Bajas_Transferencias_CalloutMock());
        Database.executeBatch(new Bajas_Transferencias_Batch('deregistered', '01-01-2022', '01-02-2022'));
        Test.stopTest();
    }

    @isTest
    static void batchTestKO() {
        Test.startTest();
        // Test.setMock(HttpCalloutMock.class, new Bajas_Transferencias_CalloutMock());
        Database.executeBatch(new Bajas_Transferencias_Batch('transfer', '01-01-2022', '01-02-2022'));
        Test.stopTest();
    }

    @isTest
    static void schedulableTest() {
        Test.startTest();
        Bajas_Transferencias_Batch sch = new Bajas_Transferencias_Batch('deregistered', '01-01-2022', '01-02-2022');
        String chron = '0 0 1 * * ?';
        Id jobId = System.schedule('Test for Bajas_Transferencias_Batch', chron, sch);
		Test.stopTest();
	}
}