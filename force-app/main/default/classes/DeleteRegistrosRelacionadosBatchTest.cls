@isTest
public class DeleteRegistrosRelacionadosBatchTest {
  @testSetup
    static void setup() {
        TriggersTest.activaTriggers();
		CreaObjetos.creaPais();
        
        Registros_Relacionados__c rr = new Registros_Relacionados__c();
        rr.Registro_Origen__c = '1111111111111111';
        rr.Registro_Destino__c = '2222222222222222';
        insert rr;
    }
    
    @isTest
    static void batchTest() {
        
        Test.startTest();
        Database.executeBatch(new DeleteRegistrosRelacionadosBatch());
        Test.stopTest();      
    }
}