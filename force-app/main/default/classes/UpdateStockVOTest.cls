@isTest
public class UpdateStockVOTest {

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

        Vehiculo__c audi = new Vehiculo__c();
        audi.VIN__c = 'VIN05';
        audi.Concesionario__c = conce.Id;
        audi.MarcaString__c = 'AUDI';
        audi.ModeloString__c = 'HY-01';
        audi.kms__c = 0;
        audi.Fecha_cumpleanos__c = Date.today().addDays(-1);
        audi.Numero_de_cumpleanos__c = 4;
        audi.Fecha_fin_garantia__c = Datetime.now();
        audi.Fecha_inicio_extension_garantia__c = Datetime.now();
        audi.Fecha_fin_extension_garantia__c = Datetime.now().addYears(2);
        audi.Actualizar_Sima__c = true;
        audi.Fecha_inicio_garantia__c = Datetime.now().addYears(-3);
        audi.Fecha_primera_matriculacion__c = Datetime.now().addYears(-3);
        audi.Activo_stock_VO__c = true;
        audi.Fecha_entrada_stock_VO__c = date.today().addDays(-3);
        insert audi;
    }
    
    @isTest
    static void batchTest() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutvehiclesAvailableVOMock());
        
        Test.startTest();
        UpdateStockVO.UpdateStockVO();
        Test.stopTest();

    }
    
    @isTest
    static void batchFailureTest() {
        Test.setMock(HttpCalloutMock.class, new ApiHttpCalloutMockFailure());
        
        Test.startTest();
        UpdateStockVO.UpdateStockVO();
        Test.stopTest();
      
    }

}